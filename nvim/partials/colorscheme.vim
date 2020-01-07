let s:bg_color = $NVIM_COLORSCHEME_BG ==? 'light' ? 'light' : 'dark'
set termguicolors                                                               "Enable true colors
silent exe 'set background='.s:bg_color
set synmaxcol=300                                                               "Use syntax highlighting only for 300 columns

filetype plugin indent on
syntax on
let s:colorscheme  = $NVIM_COLORSCHEME_BG ==? 'light' ? 'onehalflight' : 'onehalfdark'
silent! exe 'colorscheme '.s:colorscheme

hi DiffAdd ctermfg=71 guifg=#379b5f guibg=#bcf2d0
hi DiffDelete ctermfg=167 guifg=#DE1840 guibg=#FAB9B7
hi DiffChange ctermfg=136 guifg=#166faa guibg=#cce6f7
hi DiffText ctermfg=31 guifg=#a69f03 guibg=#f1eeaa

augroup vimrc_colorscheme
  autocmd!
  autocmd BufEnter * :syntax sync fromstart
augroup END
