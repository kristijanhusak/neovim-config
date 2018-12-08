set termguicolors                                                               "Enable true colors
set background=dark                                                             "Use dark background by default
set synmaxcol=300                                                               "Use syntax highlighting only for 300 columns

let g:gruvbox_italic = 1                                                        "Enable italics in Gruvbox colorscheme
let g:gruvbox_invert_selection = 0                                              "Do not invert selection in Gruvbox colorscheme
let g:gruvbox_sign_column = 'bg0'                                               "Use default bg color in sign column
let g:gruvbox_contrast_light = 'soft'                                           "Use soft contrast for light version

filetype plugin indent on
syntax on
silent! colorscheme gruvbox

augroup vimrc_colorscheme
  autocmd!
  autocmd Syntax,ColorScheme * call s:set_user_colors()
augroup END

function! s:set_user_colors() abort
  hi link jsFuncCall GruvboxBlue
  hi link ALEVirtualTextError GruvboxRed
  hi link ALEVirtualTextWarning GruvboxYellow
  hi link ALEVirtualTextInfo GruvboxBlue
  hi Operator guifg=NONE guibg=NONE
  hi User1 guifg=#504945 gui=bold
  let s:bg3 = synIDattr(synIDtrans(hlID('GruvboxBg3')), 'fg')
  let s:fg1 = synIDattr(synIDtrans(hlID('GruvboxFg1')), 'fg')
  exe 'hi User2 guifg='.s:fg1.' guibg='.s:bg3
  hi User3 guifg=#ebdbb2 guibg=#fb4934 gui=NONE

  hi! link DiffAdd GruvboxGreen
  hi! link DiffChange GruvboxGreen
  hi! link DiffDelete GruvboxRed
  hi DiffText guibg=#92931d guifg=#111111 gui=NONE
endfunction

