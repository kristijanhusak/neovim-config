let s:bg_color = $NVIM_COLORSCHEME_BG ==? 'light' ? 'light' : 'dark'
set termguicolors                                                               "Enable true colors
silent exe 'set background='.s:bg_color
set synmaxcol=300                                                               "Use syntax highlighting only for 300 columns

filetype plugin indent on
syntax on
let s:colorscheme = $NVIM_COLORSCHEME_BG ==? 'light' ? 'xcodelight' : 'xcodedark'
silent! exe  'colorscheme '.s:colorscheme
hi VertSplit guibg=NONE guifg=#8a99a6

augroup vimrc_colorscheme
  autocmd!
  autocmd BufEnter * :syntax sync fromstart
augroup END
