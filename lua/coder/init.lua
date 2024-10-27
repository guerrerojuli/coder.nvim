-- lua/coder/init.lua
local prompts = require("coder.prompts")
local context = require("coder.context")

local M = {}

-- Constants
local GROQ_KEY
local API_URL = "https://api.groq.com/openai/v1/chat/completions"
local MODEL
local ask_messages = {}


function M.setup(config)
  GROQ_KEY = config.key or ""
  MODEL = config.model or ""
end


-- Helper functions
local function create_request_body(messages)
  return vim.fn.json_encode({
    messages = messages,
    model = MODEL
  })
end


local function print_in_buffer(message)
  local response_content = message["content"]
  -- Open a new buffer
  vim.api.nvim_command('new') -- Opens a new split window

  -- Get the current buffer
  local buf = vim.api.nvim_get_current_buf()

  -- Set the content into the new buffer
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(response_content, "\n"))
end


local function get_code_to_cursor()
  -- Get the current cursor position (returns a table with {line, column})
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local current_line = cursor_pos[1] -- Cursor line (1-based index)
  local current_col = cursor_pos[2]  -- Cursor column (0-based index)

  -- Get all the lines from the start of the file to the current line
  local lines = vim.api.nvim_buf_get_lines(0, 0, current_line, false)

  -- If the cursor is not at the end of the line, trim the last line to the cursor column
  if #lines > 0 then
    local last_line = lines[#lines]                       -- Get the last line (current line)
    lines[#lines] = string.sub(last_line, 1, current_col) -- Trim the line up to the current column
  end

  -- Concatenate the lines into a single string of code
  local code = table.concat(lines, "\n")

  return code
end


local function insert_after_cursor(text)
  -- Get the current cursor position (returns a table with {line, column})
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local current_line = cursor_pos[1] -- Line (1-based)
  local current_col = cursor_pos[2]  -- Column (0-based)

  -- Get the current line content
  local line_content = vim.api.nvim_buf_get_lines(0, current_line - 1, current_line, false)[1]

  -- Split the incoming text into lines in case it contains newlines
  local new_lines = vim.split(text, "\n")

  -- If there is more than one line, split the current line at the cursor position
  -- Insert the first part of the current line before the cursor, and the rest after the last new line
  new_lines[1] = string.sub(line_content, 1, current_col) .. new_lines[1]
  new_lines[#new_lines] = new_lines[#new_lines] .. string.sub(line_content, current_col + 1)

  -- Set the new lines (replace the current line with the new lines)
  vim.api.nvim_buf_set_lines(0, current_line - 1, current_line, false, new_lines)

  -- Move the cursor to the end of the inserted text
  local new_cursor_col = #new_lines[#new_lines] -- The column at the end of the last new line
  vim.api.nvim_win_set_cursor(0, { current_line + #new_lines - 1, new_cursor_col })
end


local function insert_completion(message)
  local response_content = message["content"]

  -- Find the starting position of the "Completion:" section
  local start_pos = response_content:find("%- %*%*Completion%:%*%*\n")

  -- Check if the "Completion:" section was found
  if not start_pos then
    print("Error: Completion section not found in the response content.")
    print_in_buffer(message)
    return
  end

  -- Calculate the length of the "Completion:" header
  local header_length = #"- **Completion:**\n"

  -- Extract everything after the "Completion:" header
  local completion_text = response_content:sub(start_pos + header_length)
  insert_after_cursor(completion_text)
end


local function insert_replacement(message)
  local response_content = message["content"]

  -- Find the starting position of the "Replacement:" section
  local start_pos = response_content:find("%- %*%*Replacement%:%*%*\n")

  -- Check if the "Replacement:" section was found
  if not start_pos then
    print("Error: Replacement section not found in the response content.")
    print_in_buffer(message)
    return
  end

  -- Calculate the length of the "Replacement:" header
  local header_length = #"- **Replacement:**\n"

  -- Extract everything after the "Replacement:" header
  local completion_text = response_content:sub(start_pos + header_length)
  insert_after_cursor(completion_text)
end


-- Main function
local function chat(messages, process_message)
  local request_body = create_request_body(messages)
  local response_body = ""

  -- Use plenary.job to run the curl command
  require("plenary.job"):new({
    command = "curl",
    args = {
      "-X", "POST",
      API_URL,
      "-H", "Authorization: Bearer " .. GROQ_KEY,
      "-H", "Content-Type: application/json",
      "-d", request_body
    },
    on_exit = vim.schedule_wrap(function(j, _)
      response_body = vim.fn.json_decode(table.concat(j:result(), "\n"))
      local response_message = response_body["choices"][1]["message"]
      table.insert(ask_messages, response_message)
      process_message(response_message)
    end),
  }):start()
end


function M.ask_code(start_line, end_line, message)
  local messages = {}

  -- Convert to zero-indexed for Lua API
  start_line = start_line - 1
  end_line = end_line - 1

  -- Get the lines from the current buffer
  local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line + 1, false)
  local code = table.concat(lines, "\n")

  table.insert(messages, {
    role = "system",
    content = prompts.ask_code_system_prompt
  })

  table.insert(messages, {
    role = "system",
    content = context.get_context_prompt()
  })

  for _, ask_message in ipairs(ask_messages) do table.insert(messages, ask_message) end

  table.insert(messages, {
    role = "user",
    content =
        "Filename: " .. vim.fn.expand("%:t") ..
        "\nCode Fragment: " .. code ..
        "\nQuestion: " .. message
  })

  chat(messages, print_in_buffer)
end

function M.ask(message)
  local messages = {}

  table.insert(messages, {
    role = "system",
    content = prompts.ask_system_prompt
  })

  table.insert(messages, {
    role = "system",
    content = context.get_context_prompt()
  })

  for _, ask_message in ipairs(ask_messages) do table.insert(messages, ask_message) end

  table.insert(messages, {
    role = "user",
    content = message
  })

  chat(messages, print_in_buffer)
end

function M.complete(message)
  local messages = {}

  table.insert(messages, {
    role = "system",
    content = prompts.completion_system_prompt
  })

  table.insert(messages, {
    role = "system",
    content = context.get_context_prompt()
  })

  table.insert(messages, {
    role = "user",
    content =
        "- **Filename:**\n" ..
        vim.fn.expand("%:t") ..
        "\n- **Code:**\n" ..
        get_code_to_cursor() ..
        "\n- **Instruction:**\n" ..
        message
  })

  chat(messages, insert_completion)
end

function M.replace(start_line, end_line, message)
  local messages = {}

  -- Convert to zero-indexed for Lua API
  start_line = start_line - 1
  end_line = end_line - 1

  -- Get the lines from the current buffer
  local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line + 1, false)
  local code = table.concat(lines, "\n")

  table.insert(messages, {
    role = "system",
    content = prompts.replacement_system_prompt
  })

  table.insert(messages, {
    role = "system",
    content = context.get_context_prompt()
  })

  table.insert(messages, {
    role = "user",
    content =
        "- **Filename:**\n" .. vim.fn.expand("%:t") ..
        "\n- **Code:**\n" .. get_code_to_cursor() ..
        "\n- **Selection:**\n" .. code ..
        "\n- **Instruction:**\n" .. message
  })

  -- Remove the code selection
  vim.api.nvim_buf_set_lines(0, start_line, end_line + 1, false, { "" })

  chat(messages, insert_replacement)
end

M.get_context = context.get_context


M.add_context = context.add_context


M.rm_context = context.rm_context


return M
