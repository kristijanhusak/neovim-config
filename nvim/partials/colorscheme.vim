set termguicolors                                                               "Enable true colors
silent exe 'set background='.$NVIM_COLORSCHEME_BG
set synmaxcol=300                                                               "Use syntax highlighting only for 300 columns

let g:nord_italic = 1
let g:nord_underline = 1
let g:nord_italic_comments = 1
let g:nord_comment_brightness = 10
let g:nord_uniform_diff_background = 1

let s:colorscheme = $NVIM_COLORSCHEME_BG ==? 'dark' ? 'nord' : 'cosmic_latte'

filetype plugin indent on
syntax on
silent exe 'colorscheme '.s:colorscheme

augroup vimrc_colorscheme
  autocmd!
  autocmd Syntax,ColorScheme * call call('s:set_'.g:colors_name.'_colors', [])
augroup END

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

function! s:set_cosmic_latte_colors() abort
  hi Operator guifg=NONE guibg=NONE
  hi User1 guifg=#fff8e7 gui=bold
  hi User2 guifg=#fff8e7 guibg=#485a62
  hi CocHighlightText guibg=#efe4d2
  hi ALEVirtualTextError guifg=#c44756
  hi ALEVirtualTextWarning guifg=#a154ae
  hi link User3 Error
  hi Comment gui=italic
  if &background ==? 'dark'
    hi StatusLine guifg=#2b3740 guibg=#abb0c0
    hi StatusLineNC guifg=#2b3740 guibg=#abb0c0
    hi WildMenu guifg=#2b3740 guibg=#abb0c0
  else
    hi StatusLine guifg=#efe4d2 guibg=#485a62
    hi StatusLineNC guifg=#efe4d2 guibg=#485a62
    hi WildMenu guifg=#efe4d2 guibg=#485a62
  endif
endfunction

