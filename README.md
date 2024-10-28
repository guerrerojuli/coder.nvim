# coder.nvim

**coder.nvim** is a Neovim plugin written in Lua that enhances coding productivity by providing intelligent code completions, contextual assistance, and an interactive chat interface directly within Neovim.

## Features

- **Code Completion**: Leverages a model-based completion system to suggest code snippets and help complete lines or blocks of code.
- **Chat Interface**: Offers a chat-like interactive assistant to help with coding queries or contextual advice.
- **Context Management**: Analyzes and retains code context to provide relevant suggestions and responses.
- **Custom Prompts**: Allows users to create and manage custom prompts for enhanced flexibility in responses and completions.

## Installation

Use your favorite plugin manager to install `coder.nvim`. For example, with [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use 'guerrerojuli/coder.nvim'
```

## Usage

1. **Code Completion**: Invoke the completion function to generate code suggestions based on context.
2. **Chat Assistance**: Start a chat session to receive coding help or general assistance.

## Configuration

You can customize `coder.nvim` in your `init.lua` file as follows:

```lua
require('coder').setup({
    key = "GROQ_KEY",
    model = "GROQ_MODEL"
})
```

## File Overview

- **coder.lua**: Main file that initializes the plugin and sets up the core functionality.
- **completion.lua**: Contains functions related to code completion.
- **chat.lua**: Manages the interactive chat interface.
- **prompts.lua**: Handles prompt management for varied responses.
- **context.lua**: Deals with context management, allowing the plugin to understand and use relevant coding context.
- **utils.lua**: Contains helper functions used throughout the plugin.

## Contributing

Contributions are welcome! Please submit a pull request or open an issue for any bug reports or feature requests.

## License

This project is licensed under the MIT License.
