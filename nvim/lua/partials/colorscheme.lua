local colorscheme = {}
local opt = require('partials/utils').opt

vim.cmd([[augroup vimrc_colorscheme]])
vim.cmd([[autocmd!]])
vim.cmd([[autocmd ColorScheme * lua kris.colorscheme.setup_colors()]])
vim.cmd([[augroup END]])

function colorscheme.setup_colors()
  vim.cmd([[
    hi clear VertSplit
    hi link VertSplit Comment
    hi! link LspSignatureActiveParameter Search
  ]])
  if vim.o.background == 'light' then
    vim.cmd([[hi IndentBlanklineChar guifg=#e5e5e6]])
  end
end

opt('o', 'termguicolors', true)
opt('o', 'background', vim.env.NVIM_COLORSCHEME_BG or 'dark')
opt('o', 'synmaxcol', 300)

vim.cmd([[filetype plugin indent on]])
vim.cmd([[syntax on]])

_G.kris.colorscheme = colorscheme

vim.cmd('colorscheme ' .. (vim.env.NVIM_COLORSCHEME or 'base16-onedark'))
