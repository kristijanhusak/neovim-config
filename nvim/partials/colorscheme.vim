augroup vimrc_colorscheme
  autocmd!
  autocmd BufEnter * :syntax sync fromstart
  autocmd FileType dbout syn match dbout_null /(null)/ | hi link dbout_null Comment
  autocmd ColorScheme xcodelight call s:setup_xcodelight()
augroup END

function! s:setup_xcodelight() abort
  hi VertSplit guibg=NONE guifg=#8a99a6
  hi Comment gui=italic
endfunction

set termguicolors                                                               "Enable true colors
silent exe 'set background='.$NVIM_COLORSCHEME_BG
set synmaxcol=300                                                               "Use syntax highlighting only for 300 columns

let g:gruvbox_sign_column = 'bg0'
let g:gruvbox_invert_selection = 0
let g:gruvbox_italic = 1
filetype plugin indent on
syntax on
silent! exe  'colorscheme '.$NVIM_COLORSCHEME
