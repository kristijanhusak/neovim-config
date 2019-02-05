set termguicolors                                                               "Enable true colors
set background=dark                                                             "Use dark background by default
set synmaxcol=300                                                               "Use syntax highlighting only for 300 columns

let g:gruvbox_italic = 1                                                        "Enable italics in Gruvbox colorscheme
let g:gruvbox_invert_selection = 0                                              "Do not invert selection in Gruvbox colorscheme
let g:gruvbox_sign_column = 'bg0'                                               "Use default bg color in sign column

let g:nord_italic = 1
let g:nord_underline = 1
let g:nord_italic_comments = 1
let g:nord_comment_brightness = 10
let g:nord_uniform_diff_background = 1

filetype plugin indent on
syntax on
silent! colorscheme $COLORSCHEME

augroup vimrc_colorscheme
  autocmd!
  autocmd Syntax,ColorScheme * call call('s:set_'.g:colors_name.'_colors', [])
augroup END

function! s:set_gruvbox_colors() abort
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

function! s:set_nord_colors() abort
  hi ALEVirtualTextError guifg=#BF616A
  hi ALEVirtualTextWarning guifg=#EBCB8B
  hi Operator guifg=NONE guibg=NONE
  hi User1 guifg=#3B4252 gui=bold
  hi User2 guifg=#2E3440 guibg=#5E81AC

  hi link User3 Error
  hi CocHighlightText guibg=#434C5E
  hi DiffChange guifg=#A3BE8C
  hi DiffText gui=bold guibg=#A3BE8C guifg=#3B4252
endfunction

