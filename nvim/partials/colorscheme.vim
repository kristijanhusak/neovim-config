let s:bg_color = $NVIM_COLORSCHEME_BG ==? 'light' ? 'light' : 'dark'
set termguicolors                                                               "Enable true colors
silent exe 'set background='.s:bg_color
set synmaxcol=300                                                               "Use syntax highlighting only for 300 columns

let g:gruvbox_italic = 1
let g:gruvbox_sign_column = 'bg0'
let g:gruvbox_invert_selection = 0
let g:gruvbox_contrast_light = 'soft'

filetype plugin indent on
syntax on
silent! colorscheme gruvbox

augroup vimrc_colorscheme
  autocmd!
  autocmd VimEnter,Syntax,ColorScheme * call s:set_gruvbox_colors()
  autocmd BufEnter * :syntax sync fromstart
augroup END

function! s:set_gruvbox_colors() abort
  let g:fzf_colors = extend(get(g:, 'fzf_colors', {}), {
        \ 'fg': ['fg', 'GruvboxFg1'],
        \ 'bg': ['fg', 'GruvboxBg1'],
        \ 'fg+': ['fg', 'GruvboxFg2'],
        \ 'bg+': ['fg', 'GruvboxBg2'],
        \ })
endfunction
