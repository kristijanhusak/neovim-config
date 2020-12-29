_G.kris.colorscheme = {}
vim.cmd [[augroup vimrc_colorscheme]]
  vim.cmd [[autocmd!]]
  vim.cmd [[autocmd BufEnter * :syntax sync fromstart]]
  vim.cmd [[autocmd FileType dbout syn match dbout_null /(null)/ | hi link dbout_null Comment]]
  vim.cmd [[autocmd ColorScheme * hi QuickScopePrimary gui=bold,undercurl]]
vim.cmd [[augroup END]]

vim.o.termguicolors = true
vim.o.background = vim.env.NVIM_COLORSCHEME_BG or 'dark'
vim.o.synmaxcol = 300

vim.g.edge_sign_column_background = 'none'
vim.cmd[[filetype plugin indent on]]
vim.cmd[[syntax on]]
vim.cmd('colorscheme '..(vim.env.NVIM_COLORSCHEME or 'edge'))
