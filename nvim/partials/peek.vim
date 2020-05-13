let s:state = {
      \ 'buf': 0,
      \ 'win': 0,
      \ 'mapping_down': {},
      \ 'mapping_up': {},
      \ 'mapping_reset': {},
      \ 'line': 0,
      \ }

function! s:get_word_tag() abort
  return get(taglist(expand('<cword>')), 0, {})
endfunction

function! s:peek() abort
  let tag_fetcher = get(b:, 'peek_tag_fetcher', 's:get_word_tag')
  let tag = call(tag_fetcher, [])
  if empty(tag)
    echo 'No tag found.'
    return 0
  endif

  let curr_win = win_getid()
  let height = float2nr(&lines * 0.3)
  let width = &columns - 20
  let opts = {
        \ 'relative': 'editor',
        \ 'width': width,
        \ 'height': height,
        \ 'style': 'minimal',
        \ 'col': 10,
        \ 'row': max([1, line('.') - line('w0') + 1])
        \ }

  let win = nvim_open_win(0, v:true, opts)
  silent! exe 'edit '.tag.filename
  echom 'Viewing filename '.tag.filename
  let s:state.buf = bufnr('')
  call search(tag.cmd[1:-2])
  let s:state.line = line('.')
  call s:set_mappings()
  call nvim_set_current_win(curr_win)
  call nvim_win_set_config(win, { 'focusable': v:false })
  let s:state.win = win
endfunction

function! s:set_mappings() abort
  let s:state.mapping_down = maparg('J', 'n', v:false, v:true)
  let s:state.mapping_up = maparg('K', 'n', v:false, v:true)
  let s:state.mapping_reset = maparg('R', 'n', v:false, v:true)
  nnoremap <silent> J :call <sid>scroll('down')<CR>
  nnoremap <silent> K :call <sid>scroll('up')<CR>
  nnoremap <silent> R : call <sid>scroll('reset')<CR>
endfunction

function s:restore_old_mapping(info, key)
  if empty(a:info)
    silent! exe 'unmap '.a:key
    return v:true
  endif

  let str = a:info.noremap ? 'nnoremap' : 'nmap'
  for lhs_type in ['silent', 'nowait', 'expr']
    if a:info[lhs_type]
      let str .= '<'.lhs_type.'>'
    endif
  endfor

  let str .= ' '.a:key.' '.a:info.rhs
  silent! exe str
  return v:true
endfunction

function! s:close_peek() abort
  if !empty(s:state.win)
    echo ''
    call nvim_win_close(s:state.win, v:true)
    let s:state.win = 0
    call s:restore_old_mapping(s:state.mapping_down, 'J')
    call s:restore_old_mapping(s:state.mapping_up, 'K')
    call s:restore_old_mapping(s:state.mapping_up, 'R')
  endif
endfunction

function! s:scroll(direction) abort
  let [row, col] = nvim_win_get_cursor(s:state.win)
  let by_direction = {
        \ 'up': row - 1,
        \ 'down': row + 1,
        \ 'reset': s:state.line,
        \ }

  return nvim_win_set_cursor(s:state.win, [by_direction[a:direction], col])
endfunction

augroup peeks
  autocmd!
  autocmd CursorMoved,CursorMovedI * call s:close_peek()
augroup END

nnoremap <silent><Leader>y :call <sid>peek()<CR>
