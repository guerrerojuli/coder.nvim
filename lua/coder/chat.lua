-- lua/coder/chat.lua

local model = require("coder.model")
local prompts = require("coder.prompts")
local context = require("coder.context")
local utils = require("coder.utils")

local M = {}
M.ask_messages = {}

local function process_answer(message)
  table.insert(M.ask_messages, message)
  utils.print_in_buffer(message["content"])
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

  for _, ask_message in ipairs(M.ask_messages) do table.insert(messages, ask_message) end

  table.insert(messages, {
    role = "user",
    content =
        "Filename: " .. vim.fn.expand("%:t") ..
        "\nCode Fragment: " .. code ..
        "\nQuestion: " .. message
  })

  model.chat(messages, process_answer)
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

  for _, ask_message in ipairs(M.ask_messages) do table.insert(messages, ask_message) end

  table.insert(messages, {
    role = "user",
    content = message
  })

  model.chat(messages, process_answer)
end

return M
