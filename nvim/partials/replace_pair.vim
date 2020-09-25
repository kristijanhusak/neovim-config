let s:chars = {
      \ '{': ['}', 'left'],
      \ '}': ['{', 'right'],
      \ '[': [']', 'left'],
      \ ']': ['[', 'right'],
      \ '(': [')', 'left'],
      \ ')': ['(', 'right'],
      \ }

nnoremap R :call <sid>handle_replace()<CR>

function! s:handle_replace() abort
  let char = getline('.')[col('.') - 1]
  let new_char = nr2char(getchar())
  if has_key(s:chars, char) && has_key(s:chars, new_char)
    let flags = 'nW'
    let search_char = char
    if s:chars[char][1] ==? 'right'
      let flags .= 'b'
      let search_char = s:chars[char][0]
    endif
    let [lnum, col] = searchpairpos(escape(search_char, '[]'), '', escape(s:chars[search_char][0], '[]'), flags)
    exe 'norm!r'.new_char
    let view = winsaveview()
    call cursor(lnum, col)
    exe 'norm!r'.s:chars[new_char][0]
    call winrestview(view)
    return
  endif

  return feedkeys('R', 'n')
endfunction
