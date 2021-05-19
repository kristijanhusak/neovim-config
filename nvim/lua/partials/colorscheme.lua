local colorscheme = {}
local opt = require'partials/utils'.opt

vim.cmd [[augroup vimrc_colorscheme]]
  vim.cmd [[autocmd!]]
  vim.cmd [[autocmd FileType dbout syn match dbout_null /(null)/ | hi link dbout_null Comment]]
  vim.cmd [[autocmd ColorScheme edge lua kris.colorscheme.setup_edge()]]
vim.cmd [[augroup END]]

function colorscheme.setup_edge()
  vim.cmd[[
    hi WarningText guibg=NONE
    hi ErrorText guibg=NONE
    hi HintText guibg=NONE
    hi link dotoo_timestamp Comment
  ]]
  if vim.o.background == 'light' then
    vim.cmd[[hi DiffText guibg=#bdd4fc guifg=NONE]]
  else
    -- TODO
  end
end

opt('o', 'termguicolors', true)
opt('o', 'background', vim.env.NVIM_COLORSCHEME_BG or 'light')
opt('o', 'synmaxcol', 300)


vim.g.edge_sign_column_background = 'none'
vim.cmd[[filetype plugin indent on]]
vim.cmd[[syntax on]]

_G.kris.colorscheme = colorscheme

vim.cmd('colorscheme '..(vim.env.NVIM_COLORSCHEME or 'edge'))

