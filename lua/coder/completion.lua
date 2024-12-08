-- lua/coder/completion.lua

local model = require("coder.model")
local context = require("coder.context")
local prompts = require("coder.prompts")
local utils = require("coder.utils")


local M = {}


local function parse_response(response, pattern, header)
  -- Find the starting position of the pattern section
  local start_pos = response:find(pattern)

  -- Check if the pattern section was found
  if not start_pos then
    return nil
  end

  -- Calculate the length of the header
  local header_length = #header

  -- Extract everything after the header
  local completion_text = response:sub(start_pos + header_length)
  return completion_text
end



local function insert_completion(message)
  local content = message["content"]
  local pattern = "%- %*%*Completion%:%*%*\n"
  local header = "- **Completion:**\n"

  local completion = parse_response(content, pattern, header)

  if completion == nil then
    print("Error: Completion section not found in the response content.")
    utils.print_in_buffer(content)
    return
  end

  utils.insert_after_cursor(completion)
end


local function insert_replacement(message)
  local content = message["content"]
  local pattern = "%- %*%*Replacement%:%*%*\n"
  local header = "- **Replacement:**\n"

  local completion = parse_response(content, pattern, header)

  if completion == nil then
    print("Error: Replacement section not found in the response content.")
    utils.print_in_buffer(content)
    return
  end

  utils.insert_after_cursor(completion)
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
        utils.get_code_to_cursor() ..
        "\n- **Instruction:**\n" ..
        message
  })

  model.chat(messages, insert_completion)
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
        "\n- **Code:**\n" .. utils.get_code_to_cursor() ..
        "\n- **Selection:**\n" .. code ..
        "\n- **Instruction:**\n" .. message
  })

  -- Remove the code selection
  vim.api.nvim_buf_set_lines(0, start_line, end_line + 1, false, { "" })

  model.chat(messages, insert_replacement)
end


return M
