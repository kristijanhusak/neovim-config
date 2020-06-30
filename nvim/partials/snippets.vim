let s:snippets = {
      \ 'cl': "console.log();\<Left>\<Left>",
      \ 'clax': "class {\<CR>}\<C-o>% \<Left>",
      \ }

function snippets#check() abort
  let word = matchlist(getline('.')[0:(col('.') - 1)], '\k*$')
  if !empty(word[0]) && has_key(s:snippets, word[0])
    return word[0]
  endif
  return ''
endfunction

function! snippets#expand(word) abort
  return "\<C-w>".s:snippets[a:word]
endfunction
