function! s:console_log() abort
  let l:word = expand('<cword>')
  let l:empty_line = search('^[[:blank:]]*$', 'n')
  if l:empty_line > 1 && l:empty_line > line('.')
    call append(l:empty_line - 1, 'console.log('''.l:word.''', '.l:word.'); // eslint-disable-line no-console')
    keepjumps execute 'norm!'.l:empty_line."G==\<C-o>"
  else
    keepjumps execute 'norm!oconsole.log('''.l:word.''', '.l:word.'); // eslint-disable-line no-console'
  endif
  silent! call repeat#set("\<Plug>(JsConsoleLog)")
endfunction

nnoremap <silent><Plug>(JsConsoleLog) :<C-u>call <sid>console_log()<CR>

augroup javascript
  autocmd!
  autocmd FileType javascript nmap <buffer><silent><C-]> <Plug>(JsGotoDefinition)
  autocmd FileType javascript xmap <buffer><silent><C-]> <Plug>(JsGotoDefinition)
  autocmd FileType javascript nmap <buffer><silent><Leader>] <C-W>v<Plug>(JsGotoDefinition)
  autocmd FileType javascript xmap <buffer><silent><Leader>] <C-W>vgv<Plug>(JsGotoDefinition)
  autocmd FileType javascript nmap <buffer><silent><Leader>ll <Plug>(JsConsoleLog)
augroup END

