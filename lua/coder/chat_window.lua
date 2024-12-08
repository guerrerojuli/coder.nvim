-- lua/coder/chat_window.lua

local model = require("coder.model")

local M = {}

local display_buf, display_win
local input_buf, input_win

local conversation = {}

local function open_display_window()
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.6)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  display_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(display_buf, "filetype", "markdown")
  vim.api.nvim_buf_set_option(display_buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(display_buf, "modifiable", false)

  display_win = vim.api.nvim_open_win(display_buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })

  vim.api.nvim_win_set_option(display_win, "wrap", true)
  vim.api.nvim_win_set_option(display_win, "cursorline", true)
end

local function open_input_window()
  local display_config = vim.api.nvim_win_get_config(display_win)
  local width = display_config.width
  local row = display_config.row + display_config.height
  local col = display_config.col
  local height = 5

  input_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(input_buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(input_buf, "modifiable", true)

  input_win = vim.api.nvim_open_win(input_buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })

  -- Mapeamos <C-s> para enviar el mensaje
  vim.api.nvim_buf_set_keymap(
    input_buf,
    "i",
    "<C-s>",
    "<Esc>:lua require('coder.chat_window').send_message()<CR>",
    { noremap = true, silent = true }
  )

  -- Mapeamos <C-c> para cerrar el chat
  vim.api.nvim_buf_set_keymap(
    input_buf,
    "i",
    "<C-c>",
    "<Esc>:lua require('coder.chat_window').close_chat()<CR>",
    { noremap = true, silent = true }
  )

  vim.api.nvim_command("startinsert!")
end

function M.render_conversation()
  vim.api.nvim_buf_set_option(display_buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(display_buf, 0, -1, false, {})

  for _, msg in ipairs(conversation) do
    local prefix = (msg.role == "user") and "User: " or "Assistant: "
    local lines = vim.split(msg.content, "\n")
    vim.api.nvim_buf_set_lines(display_buf, -1, -1, false, { prefix })
    for _, l in ipairs(lines) do
      vim.api.nvim_buf_set_lines(display_buf, -1, -1, false, { l })
    end
    vim.api.nvim_buf_set_lines(display_buf, -1, -1, false, { "" })
  end

  vim.api.nvim_buf_set_option(display_buf, "modifiable", false)

  -- Mover el cursor a la última línea para hacer scroll hacia abajo
  local line_count = vim.api.nvim_buf_line_count(display_buf)
  vim.api.nvim_win_set_cursor(display_win, {line_count, 0})
end

function M.send_message()
  local lines = vim.api.nvim_buf_get_lines(input_buf, 0, 1, false)
  local message = table.concat(lines, "\n")

  if message == "" then
    return
  end

  vim.api.nvim_buf_set_lines(input_buf, 0, -1, false, {""})
  vim.api.nvim_command("startinsert!")

  table.insert(conversation, { role = "user", content = message })
  M.render_conversation()

  model.chat(conversation, function(response_message)
    table.insert(conversation, { role = "assistant", content = response_message.content })
    M.render_conversation()
  end)
end

function M.close_chat()
  if input_win and vim.api.nvim_win_is_valid(input_win) then
    vim.api.nvim_win_close(input_win, true)
  end
  if display_win and vim.api.nvim_win_is_valid(display_win) then
    vim.api.nvim_win_close(display_win, true)
  end
  conversation = {}
end

function M.start_chat()
  open_display_window()
  open_input_window()
  if #conversation == 0 then
    table.insert(conversation, {role = "assistant", content = "¡Hola! ¿En qué puedo ayudarte hoy?"})
    M.render_conversation()
  end
end

return M
