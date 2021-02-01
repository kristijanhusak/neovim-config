_G.kris.colorscheme = {}
vim.cmd [[augroup vimrc_colorscheme]]
  vim.cmd [[autocmd!]]
  vim.cmd [[autocmd BufEnter * :syntax sync fromstart]]
  vim.cmd [[autocmd FileType dbout syn match dbout_null /(null)/ | hi link dbout_null Comment]]
  vim.cmd [[autocmd ColorScheme * hi QuickScopePrimary gui=bold,undercurl]]
  vim.cmd [[autocmd ColorScheme edge call v:lua.kris.colorscheme.setup_edge()]]
vim.cmd [[augroup END]]

function _G.kris.colorscheme.setup_edge()
  vim.cmd[[
    hi WarningText guibg=NONE
    hi ErrorText guibg=NONE
    hi HintText guibg=NONE
  ]]
  if vim.o.background == 'light' then
    vim.cmd[[hi DiffText guibg=#bdd4fc guifg=NONE]]
  else
    -- TODO
  end
end

vim.o.termguicolors = true
vim.o.background = vim.env.NVIM_COLORSCHEME_BG or 'dark'
vim.o.synmaxcol = 300

vim.g.edge_sign_column_background = 'none'
vim.cmd[[filetype plugin indent on]]
vim.cmd[[syntax on]]
vim.cmd('colorscheme '..(vim.env.NVIM_COLORSCHEME or 'edge'))
