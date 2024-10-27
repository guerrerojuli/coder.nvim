-- plugin/coder.lua
-- This file is automatically sourced on startup

-- Commands

-- CoderAddContext file1 file2 ...
-- this command is for adding files to the model context

-- CoderRmContext file1 file2 ...
-- this command is for removing files to the model context

-- CoderAsk "question"
-- this command is for asking using the context

-- n,m CoderAskCode "question"
-- this command is for asking about a code using the context

-- n,m CoderReplace "question"
-- this command is for replacing the code in the n, m lines with the generated code using the context

-- CoderComplete "question"
-- this command is for completing the code with the generated code using the context

-- Require the main module of the plugin
local coder = require("coder")

vim.api.nvim_create_user_command(
  "CoderAsk",                 -- Command name
  function(opts)
    local message = opts.args -- Get the message argument

    -- Call the function to ask the ai
    coder.ask(message)
  end,
  { range = false, nargs = 1 }
)


vim.api.nvim_create_user_command(
  "CoderAskCode", -- Command name
  function(opts)
    local range_start = opts.line1
    local range_end = opts.line2
    local message = opts.args or "" -- Get the message argument

    -- Call the function to ask the ai
    coder.ask_code(range_start, range_end, message)
  end,
  { range = true, nargs = 1 }
)

vim.api.nvim_create_user_command(
  "CoderGetContext",
  function()
    coder.get_context()
  end,
  { nargs = 0 }
)

vim.api.nvim_create_user_command(
  "CoderAddContext", -- Command name
  function(opts)
    coder.add_context(opts.fargs)
  end,
  { nargs = "+", complete = "file" }
)

vim.api.nvim_create_user_command(
  "CoderRmContext", -- Command name
  function(opts)
    coder.rm_context(opts.fargs)
  end,
  { nargs = "+", complete = "file" }
)

vim.api.nvim_create_user_command(
  "CoderComplete", -- Command name
  function(opts)
    local message = opts.args
    coder.complete(message)
  end,
  { nargs = 1 }
)

vim.api.nvim_create_user_command(
  "CoderReplace", -- Command name
  function(opts)
    local range_start = opts.line1
    local range_end = opts.line2
    local message = opts.args
    coder.replace(range_start, range_end, message)
  end,
  { range = true, nargs = 1 }
)
