augroup vimrc_colorscheme
  autocmd!
  autocmd BufEnter * :syntax sync fromstart
  autocmd FileType dbout syn match dbout_null /(null)/ | hi link dbout_null Comment
  autocmd ColorScheme * hi QuickScopePrimary gui=bold,undercurl
augroup END

set termguicolors                                                               "Enable true colors
silent exe 'set background='.$NVIM_COLORSCHEME_BG
set synmaxcol=300                                                               "Use syntax highlighting only for 300 columns

let g:edge_sign_column_background = 'none'
filetype plugin indent on
syntax on
silent! exe  'colorscheme '.$NVIM_COLORSCHEME
