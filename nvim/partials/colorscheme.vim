let s:bg_color = $NVIM_COLORSCHEME_BG ==? 'light' ? 'light' : 'dark'
set termguicolors                                                               "Enable true colors
silent exe 'set background='.s:bg_color
set synmaxcol=300                                                               "Use syntax highlighting only for 300 columns

let g:gruvbox_italic = 1
let g:gruvbox_sign_column = 'bg0'
let g:gruvbox_invert_selection = 0
let g:gruvbox_contrast_light = 'soft'
let g:solarized_extra_hi_groups = 1

filetype plugin indent on
syntax on
silent! colorscheme solarized8_flat

augroup vimrc_colorscheme
  autocmd!
  autocmd BufEnter * :syntax sync fromstart
augroup END
