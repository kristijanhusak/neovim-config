function! s:console_log() abort
  let l:word = expand('<cword>')
  keepjumps execute 'norm!oconsole.log('''.l:word.''', '.l:word.'); // eslint-disable-line no-console'
  silent! call repeat#set("\<Plug>(JsConsoleLog)")
endfunction

function! s:inject_dependency() abort
  let view = winsaveview()
  let word = expand('<cword>')
  let old_reg = getreg('@z')
  silent! exe 'norm!"zyib'
  let index_in_list = index(filter(map(split(getreg('@z'), ','), 'trim(v:val)'), 'v:val !=? ""'), word)
  let move_line = ''
  if index_in_list > 0
    let move_line = index_in_list.'j'
  endif
  call search('constructor(')
  let content = 'this._'.tolower(word[0]).word[1:].' = '.word.';'
  silent! exe 'norm!f(%f{%'
  let closing_bracket_line = line('.')
  silent! exe 'norm!%'

  if index_in_list > 0 && ((line('.') + index_in_list) >= closing_bracket_line)
    let move_line = ''
    call cursor(closing_bracket_line - 1, 0)
  endif

  if !empty(move_line)
    silent! exe 'norm!'.move_line
  endif

  let line_content = getline(line('.') + 1)
  if  line_content !~? content
    if empty(trim(line_content))
      silent! exe 'norm!jcc'.content
    else
      silent! exe 'norm!o'.content
    endif
  else
    echo 'Already injected.'
  endif

  call winrestview(view)
  call setreg('@z', old_reg)
  silent! call repeat#set("\<Plug>(JsInjectDependency)")
endfunction

nnoremap <silent><Plug>(JsConsoleLog) :<C-u>call <sid>console_log()<CR>
nnoremap <nowait><silent><Plug>(JsInjectDependency) :<C-u>call <sid>inject_dependency()<CR>
nnoremap <nowait><Plug>(JsGotoFile) :<C-u>call <sid>js_goto_file()<CR>

function! s:js_goto_file() abort
  let full_path = printf('%s/%s', expand('%:p:h'), expand('<cfile>'))
  if !isdirectory(full_path)
    norm! gf
    return
  endif

  for suffix in split(&suffixesadd, ',')
    let index_file = full_path.'/index'.suffix
    if filereadable(index_file)
      exe 'edit '.index_file
      return
    endif
  endfor
endfunction

function! s:setup() abort
  nmap <buffer><silent><C-]> <Plug>(JsGotoDefinition)
  xmap <buffer><silent><C-]> <Plug>(JsGotoDefinition)
  nmap <buffer><silent><Leader>] <C-W>v<Plug>(JsGotoDefinition)
  xmap <buffer><silent><Leader>] <C-W>vgv<Plug>(JsGotoDefinition)
  nmap <buffer><silent><Leader>ll <Plug>(JsConsoleLog)
  nmap <nowait><buffer><silent><Leader>d <Plug>(JsInjectDependency)
  nmap <nowait><buffer><silent> gf <Plug>(JsGotoFile)
  setlocal isfname+=@-@
endfunction

augroup javascript
  autocmd!
  autocmd FileType javascript,javascriptreact,typescript,typescriptreact call s:setup()
augroup END
