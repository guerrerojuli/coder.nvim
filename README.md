# coder.nvim

**coder.nvim** is a Neovim plugin written in Lua that enhances coding productivity by providing intelligent code completions, contextual assistance, and an interactive chat interface directly within Neovim.

## Features

- **Code Completion**: Leverages a model-based completion system to suggest code snippets and complete lines or blocks of code.
- **Chat Interface**: Offers an interactive assistant for coding queries or contextual advice.
- **Context Management**: Analyzes and retains code context from selected files to improve the relevance of suggestions and responses.

## Installation

Install `coder.nvim` using your preferred plugin manager. For example, with [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use 'guerrerojuli/coder.nvim'
```

## Usage

### Setup

Configure `coder.nvim` in your `init.lua` file as follows:

```lua
require('coder').setup({
    key = "GROQ_KEY",
    model = "GROQ_MODEL"
})
```

### Commands

- **`CoderAddContext file1 file2 ...`**  
  Adds specified files to the model context. This enables the assistant to refer to these files when providing completions or answering questions.

- **`CoderRmContext file1 file2 ...`**  
  Removes specified files from the model context, reducing the assistant's focus to the remaining files.

- **`CoderAsk "question"`**  
  Allows you to ask a general coding question, leveraging any provided context.

- **`n,m CoderAskCode "question"`**  
  Ask a question specific to a code segment, selecting the line range (`n, m`) to limit the assistant’s focus.

- **`n,m CoderReplace "question"`**  
  Replaces code within lines `n` to `m` with model-generated code based on the provided context.

- **`CoderComplete "question"`**  
  Completes the current code based on context, useful for finishing functions or filling in boilerplate code.

### Example Workflow

1. Add context files using `CoderAddContext`.
2. Ask coding-related questions with `CoderAsk` or `CoderAskCode`.
3. Use `CoderComplete` or `CoderReplace` for inline assistance or code replacement.

## File Overview

- **coder.lua**: Initializes the plugin, defining commands and managing core functionality.
- **completion.lua**: Contains code completion functions.
- **chat.lua**: Handles chat interactions and query processing.
- **model.lua**: Manages model configurations and API requests.
- **context.lua**: Manages file context for relevant suggestions.
- **prompts.lua**: Custom prompts for specific responses.
- **utils.lua**: Utility functions for Neovim buffer handling.

## Contributing

Feel free to contribute or open issues to help improve `coder.nvim`. Contributions are welcome!
