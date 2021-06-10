local colorscheme = {}
local opt = require'partials/utils'.opt

vim.cmd [[augroup vimrc_colorscheme]]
  vim.cmd [[autocmd!]]
  vim.cmd [[autocmd FileType dbout syn match dbout_null /(null)/ | hi link dbout_null Comment]]
  vim.cmd [[autocmd ColorScheme base16-one-light lua kris.colorscheme.setup_one_light()]]
vim.cmd [[augroup END]]

function colorscheme.setup_one_light()
  vim.cmd[[
    hi clear VertSplit
    hi link VertSplit Comment
    hi IndentBlanklineChar guifg=#e5e5e6
  ]]
end

opt('o', 'termguicolors', true)
opt('o', 'background', vim.env.NVIM_COLORSCHEME_BG or 'light')
opt('o', 'synmaxcol', 300)


vim.cmd[[filetype plugin indent on]]
vim.cmd[[syntax on]]

_G.kris.colorscheme = colorscheme

vim.cmd('colorscheme '..(vim.env.NVIM_COLORSCHEME or 'base16-one-light'))

