-- lua/coder/context.lua

local M = {}


M.context_files = {}


function M.get_context_prompt()
  local prompt =
  [[In addition to the previous instructions, you will now be provided with multiple files as context to assist you in answering the user's question more accurately. Each file will include its filename and corresponding code. These files are intended to give you a broader understanding of the project or codebase but are not meant for error analysis unless specifically requested by the user.

Instructions:

Contextual Use Only:

Utilize the information from the provided files to inform your response.
Understand how these files relate to the code fragment and the user's question.
Consider dependencies, interactions, and the overall structure they contribute to.
Do Not Analyze for Errors:

Do not search for or point out errors in these files unless the user explicitly asks you to do so.
Focus on using them to enhance the accuracy and relevance of your answer.
Incorporate Relevant Information:

Reference functions, classes, or variables from the context files if they are pertinent to your explanation.
Explain how the context may affect the code fragment or the solution to the user's question.

**Files Provided:**
]]
  for _, filename in ipairs(M.context_files) do
    if vim.fn.filereadable(filename) == 1 then
      local file_code = vim.fn.readfile(filename)
      prompt = prompt .. "**" .. filename .. "**\n" .. table.concat(file_code, "\n") .. "\n\n"
    end
  end

  prompt = prompt .. [[Your Response Should:

Address the User's Question:

Provide a clear and detailed answer to the question asked.
Use information from the context files to enhance your explanation.
Be Accurate and Reflective:

Ensure your answer is correct by working through it step by step.
Reflect on your reasoning to identify and correct any mistakes before presenting the final answer.
Stay Focused:

Keep your response relevant to the user's question.
Avoid unnecessary analysis or commentary on the context files unless it directly relates to the answer.
Remember:

Clarity and Accuracy: Strive for precision and simplicity in your explanations to aid the user's understanding.
Contextual Awareness: Use the additional files to provide a more comprehensive and accurate response.
Professionalism: Maintain a helpful and respectful tone throughout your interaction.
By following these guidelines, you will effectively utilize the provided files as context to deliver accurate and insightful answers to the user's programming questions]]

  return prompt
end

function M.get_context()
  for i, file in ipairs(M.context_files) do
    print(i .. "- " .. file)
  end
end

-- Add a function to add files to the context
function M.add_context(files)
  for _, file in ipairs(files) do
    table.insert(M.context_files, file)
  end
end

-- Add a function to remove files from the context
function M.rm_context(files)
  for _, file in ipairs(files) do
    for i, context_file in ipairs(M.context_files) do
      if context_file == file then
        table.remove(M.context_files, i)
      end
    end
  end
end

return M
