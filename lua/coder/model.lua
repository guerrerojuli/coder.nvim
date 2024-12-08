-- lua/coder/model.lua

local M = {}

M.GROQ_KEY = ""
M.MODEL = ""
M.API_URL = "https://api.groq.com/openai/v1/chat/completions"


local function create_request_body(messages)
  return vim.fn.json_encode({
    messages = messages,
    model = M.MODEL
  })
end


function M.chat(messages, process_message)
  local request_body = create_request_body(messages)

  -- Use plenary.job to run the curl command
  require("plenary.job"):new({
    command = "curl",
    args = {
      "-X", "POST",
      M.API_URL,
      "-H", "Authorization: Bearer " .. M.GROQ_KEY,
      "-H", "Content-Type: application/json",
      "-d", request_body
    },
    on_exit = vim.schedule_wrap(function(j, code)
      if code ~= 0 then
        -- Handle error
        local error_message = "Error sending request: " .. j:stderr_result()
        error(error_message)
        return
      end

      local response_body = vim.fn.json_decode(table.concat(j:result(), "\n"))
      if response_body.choices == nil then
        error("An error has ocurred")
      end
      local response_message = response_body["choices"][1]["message"]
      process_message(response_message)
    end),
  }):start()
end

return M
