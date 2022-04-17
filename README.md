# flare.nvim

Configurable cursor highlighting using neovims virtual text.

![Preview](https://user-images.githubusercontent.com/1717836/163735786-bbbcb23f-662a-4213-a2c4-b84440766324.gif)

## Installation

[Neovim (v0.7.0)](https://github.com/neovim/neovim/releases/tag/v0.7.0) or the
latest neovim nightly commit is required for `flare.nvim` to work.

Using [vim-plug](https://github.com/junegunn/vim-plug)

```viml
Plug 'stonelasley/flare.nvim'
```

Using [dein](https://github.com/Shougo/dein.vim)

```viml
call dein#add('stonelasley/flare.nvim')
```
Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'stonelasley/flare.nvim',
  config = function() require('flare').setup() end
}
```

### Flare setup
default configuration
```lua
require('flare').setup {
  enabled = true, -- disable highlighting
  hl_group = "IncSearch", -- set highlight group used for highlight
  x_threshold = 10, -- column changes greater than this number trigger highlight
  y_threshold = 5,  -- row changes greater than this number trigger highlight
  expanse = 10,  -- highlight will expand to the left and right of cursor up to this amount (depending on space available)
  file_ignore = { -- suppress highlighting for files of this type
    "NvimTree",
    "fugitive",
    "TelescopePrompt",
    "TelescopeResult",
  },
}
```

## Contributing

All contributions are welcome! Just open a pull request.

## Related and Inspirational Projects

- [beacon.nvim](https://github.com/DanilaMihailov/beacon.nvim)
