-- lua/coder/init.lua
local model = require("coder.model")
local context = require("coder.context")
local chat = require("coder.chat")
local completion = require("coder.completion")

local M = {}

function M.setup(config)
  if not config.key or config.key == "" then
    error("GROQ key is not set. Plugin cannot be loaded.")
  end
  model.GROQ_KEY = config.key
  model.MODEL = config.model or ""
  M.ask = chat.ask
  M.complete = completion.complete
  M.ask_code = chat.ask_code
  M.replace = completion.replace
  M.get_context = context.get_context
  M.add_context = context.add_context
  M.rm_context = context.rm_context
end

return M
