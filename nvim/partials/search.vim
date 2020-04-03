let s:last_search = ''

augroup init_vim_search
  autocmd!
  autocmd ShellCmdPost * call timer_start(0, function('s:save_search'))
  autocmd FileType qf nnoremap <buffer><Leader>r :call <sid>execute_search()<CR>
augroup END

" Search mappings
nnoremap <expr><Leader>f ':grep '
nnoremap <expr><Leader>F ':grep '.<sid>esc(expand('<cword>')).' '
vnoremap <Leader>F :<C-u>call <sid>get_visual_search_cmd()<CR>

function s:esc(val) abort
  let l:val = fnameescape(a:val)
  for i in range(1, 3)
    let l:val = escape(l:val, '()')
  endfor
  return l:val
endfunction

function s:save_search(timer) abort
  let l:search = getreg(':')
  if l:search =~? 'grep'
    let s:last_search = getreg(':')
  endif
endfunction

function s:execute_search() abort
  if !empty(s:last_search)
    call execute(':'.s:last_search)
    call execute('wincmd p')
  endif
endfunction

function s:get_visual_search_cmd() abort
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][:col2 - (&selection ==? 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]
  return feedkeys(':grep '.s:esc(join(lines, "\n")).' ')
endfunction


