let s:bg_color = $NVIM_COLORSCHEME_BG ==? 'light' ? 'light' : 'dark'
set termguicolors                                                               "Enable true colors
silent exe 'set background='.s:bg_color
set synmaxcol=300                                                               "Use syntax highlighting only for 300 columns

let g:gruvbox_sign_column = 'bg0'
let g:gruvbox_invert_selection = 0
filetype plugin indent on
syntax on
let s:colorscheme = $NVIM_COLORSCHEME_BG ==? 'light' ? 'xcodelight' : 'gruvbox'
silent! exe  'colorscheme '.s:colorscheme

augroup vimrc_colorscheme
  autocmd!
  autocmd BufEnter * :syntax sync fromstart
  autocmd FileType dbout syn match dbout_null /(null)/ | hi link dbout_null Comment
  autocmd ColorScheme xcodelight hi! VertSplit guibg=NONE guifg=#8a99a6 | hi! Comment gui=italic
augroup END
