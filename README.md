# 🔥 flare.nvim

**Highlight cursor jumps** with smooth animations that help you track cursor movement across your code.

[![Neovim](https://img.shields.io/badge/Neovim%20≥%200.7-green.svg?style=flat-square&logo=neovim)](https://github.com/neovim/neovim)
[![Lua](https://img.shields.io/badge/Made%20with%20Lua-blue.svg?style=flat-square&logo=lua)](https://lua.org)

<p align="center">
  <img src="https://user-images.githubusercontent.com/1717836/163735786-bbbcb23f-662a-4213-a2c4-b84440766324.gif" alt="flare.nvim in action" width="600"/>
</p>

## ✨ Features

- **Smart cursor tracking** - Highlights only significant cursor jumps (customizable thresholds)
- **Smooth fade animations** - Simple, non-intrusive visual feedback
- **Highly configurable** - Adjust colors, animation speed, trigger thresholds, and more
- **Performance optimized** - Minimal overhead with automatic cleanup
- **File-type aware** - Automatically disables in file trees, terminals, and popups

## 📦 Installation

<details>
<summary><b>lazy.nvim</b> (recommended)</summary>

```lua
{
  'stonelasley/flare.nvim',
  event = "CursorMoved",
  opts = {
    -- your configuration here (optional)
  }
}
```
</details>

<details>
<summary><b>packer.nvim</b></summary>

```lua
use {
  'stonelasley/flare.nvim',
  config = function() 
    require('flare').setup()
  end
}
```
</details>

<details>
<summary><b>vim-plug</b></summary>

```viml
Plug 'stonelasley/flare.nvim'

" In your init.lua or after plugins load:
lua require('flare').setup()
```
</details>

<details>
<summary><b>dein</b></summary>

```viml
call dein#add('stonelasley/flare.nvim')

" In your init.lua or after plugins load:
lua require('flare').setup()
```
</details>

## ⚡ Quick Start

No configuration needed! Just install and flare.nvim will start highlighting cursor jumps with sensible defaults.

```lua
-- Optional: customize to your liking
require('flare').setup({
  -- See configuration section for all options
})
```

## ⚙️ Configuration

### Default Settings

```lua
require('flare').setup({
  enabled = true,              -- Enable/disable the plugin
  hl_group = "IncSearch",      -- Highlight group for the cursor indicator
  hl_group_ul = "FlareUnderline", -- Highlight group for underline mode
  x_threshold = 10,            -- Minimum horizontal jump distance to trigger
  y_threshold = 5,             -- Minimum vertical jump distance to trigger
  expanse = 10,                -- Width of the highlight area
  file_ignore = {              -- File types where flare is disabled
    "NvimTree",
    "fugitive", 
    "TelescopePrompt",
    "TelescopeResult",
  },
  fade = true,                 -- Enable fade animation (false = flash effect)
  fade_speed = 1.0,            -- Animation speed (higher = faster)
  underline = false,           -- Use underline instead of background highlight
  timeout = 150,               -- Delay before showing highlight (ms)
})
```

### Customization Examples

<details>
<summary><b>Subtle underline style</b></summary>

```lua
require('flare').setup({
  underline = true,
  hl_group_ul = "CursorLine",  -- Or any highlight group you prefer
})
```
</details>

<details>
<summary><b>Flash effect (no fade)</b></summary>

```lua
require('flare').setup({
  fade = false,
  timeout = 100,
})
```
</details>

<details>
<summary><b>Only highlight large jumps</b></summary>

```lua
require('flare').setup({
  x_threshold = 20,  -- Only highlight jumps > 20 columns
  y_threshold = 10,  -- Only highlight jumps > 10 lines
})
```
</details>

<details>
<summary><b>Custom highlight colors</b></summary>

```lua
-- Define your custom highlight group
vim.api.nvim_set_hl(0, 'MyFlareHighlight', { 
  bg = '#ff9e64',  -- Orange background
  fg = '#1a1b26',  -- Dark foreground
  bold = true 
})

require('flare').setup({
  hl_group = "MyFlareHighlight",
})
```
</details>

## 🎮 Commands

| Command | Description | Example |
|---------|-------------|---------|
| `:FlareToggle` | Toggle flare on/off | `:FlareToggle` |
| `:FlareSetThreshold x [value]` | Set horizontal jump threshold | `:FlareSetThreshold x 15` |
| `:FlareSetThreshold y [value]` | Set vertical jump threshold | `:FlareSetThreshold y 3` |
| `:FlareSetFadeSpeed [value]` | Set fade animation speed | `:FlareSetFadeSpeed 2.0` |

## 🎯 Use Cases

- **Code navigation** - Never lose track of your cursor when jumping between functions
- **Large file editing** - Essential for navigating files with thousands of lines
- **Split window workflow** - Easily see which window has focus after switching
- **Pair programming** - Help others follow your cursor movement during screen sharing

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs or request features via [issues](https://github.com/stonelasley/flare.nvim/issues)
- Submit pull requests with improvements
- Share your custom configurations

## 📝 License

MIT

## 🌟 Acknowledgments

Inspired by:
- [beacon.nvim](https://github.com/DanilaMihailov/beacon.nvim) - Similar cursor tracking plugin

---

<p align="center">
  Made with ❤️ for the Neovim community
</p>
