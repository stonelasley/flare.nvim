set rtp+=.

" Clone plenary.nvim if it doesn't exist
lua << EOF
local plenary_path = vim.fn.stdpath("data") .. "/site/pack/vendor/start/plenary.nvim"
if vim.fn.isdirectory(plenary_path) == 0 then
  vim.fn.system({"git", "clone", "https://github.com/nvim-lua/plenary.nvim", plenary_path})
end
vim.opt.rtp:prepend(plenary_path)
EOF

runtime! plugin/plenary.vim
