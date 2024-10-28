-- lua/coder/init.lua
local model = require("coder.model")
local context = require("coder.context")
local chat = require("coder.chat")
local completion = require("coder.completion")


local M = {}


function M.setup(config)
  model.GROQ_KEY = config.key or ""
  model.MODEL = config.model or ""
end


M.ask = chat.ask


M.ask_code = chat.ask_code


M.complete = completion.complete


M.replace = completion.replace


M.get_context = context.get_context


M.add_context = context.add_context


M.rm_context = context.rm_context


return M
