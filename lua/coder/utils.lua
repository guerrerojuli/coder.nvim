-- lua/coder/utils.lua

local M = {}

function M.print_in_buffer(text)
  -- Split the text into lines
  local lines = vim.split(text, "\n")

  -- Calculate the dimensions for the floating window
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.min(#lines + 2, math.floor(vim.o.lines * 0.8)) -- Add padding and ensure it fits
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Create a new buffer
  local buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer

  -- Set the content into the buffer
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Configure the floating window
  local opts = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded", -- "single", "double", or "solid"
  }

  -- Create the floating window
  vim.api.nvim_open_win(buf, true, opts)

  -- Add keymap to close the window
  vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })
end


function M.get_code_to_cursor()
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


function M.insert_after_cursor(text)
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

return M
