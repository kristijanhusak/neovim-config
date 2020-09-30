let s:is_toggle = 0
let s:mode = 'term'
let s:last_search = ''

augroup init_vim_search
  autocmd!
  autocmd FileType qf nnoremap <silent><buffer><Leader>r :call <sid>do_search('')<CR>
  autocmd QuickFixCmdPost [^l]* nested cwindow
  autocmd QuickFixCmdPost l* nested lwindow
augroup END

" Search mappings
nnoremap <Leader>f :call <sid>search('')<CR>
nnoremap <Leader>F :call <sid>search(expand('<cword>'))<CR>
vnoremap <Leader>F :<C-u>call <sid>search(<sid>get_visual_search_cmd())<CR>

function! s:toggle_search_mode() abort
  let s:is_toggle = 1
  let s:mode = s:mode ==? 'regex' ? 'term' : 'regex'

  return getcmdline()
endfunction

function! s:search(term) abort
  let term = a:term

  cmap <tab> <C-\>e<sid>toggle_search_mode()<CR><CR>

  try
    call inputsave()
    let term = input('Enter '.s:mode.': ', term)
    call inputrestore()

    if s:is_toggle
      let s:is_toggle = 0
      return s:search(term)
    endif

    call s:cleanup('no_reset_mode')
    redraw!
    if empty(term)
      echom 'Empty search.'
      return
    endif

    echo 'Searching for word -> '.term
    let dir = input('Path: ', '', 'file')
  catch /^Vim:Interrupt$/
    return s:cleanup()
  endtry

  let grepprg = &grepprg
  if s:mode ==? 'term'
    let cmd = join([&grepprg, '--fixed-strings', shellescape(term), dir])
  else
    let cmd = join([&grepprg, term, dir])
  endif

  return s:do_search(cmd)
endfunction

function! s:do_search(cmd) abort
  if empty(a:cmd) && empty(s:last_search)
    echom 'Empty search.'
    return s:cleanup()
  endif

  let cmd = !empty(a:cmd) ? a:cmd : s:last_search
  let s:last_search = cmd

  let results = systemlist(cmd)

  if empty(results)
    echom 'No results for search -> '.cmd
    return s:cleanup()
  endif
  if !empty(v:shell_error) && ! empty(results)
    echom 'Search error (status: '.v:shell_error.'): '.string(results)
    return s:cleanup()
  endif

  cgetexpr results
  return s:cleanup()
endfunction

function s:get_visual_search_cmd() abort
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][:col2 - (&selection ==? 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]
  return join(lines, "\n")
endfunction


function! s:cleanup(...) abort
  let s:is_toggle = 0
  if a:0 ==? 0
    let s:mode = 'term'
  endif
  silent! cunmap <tab>
  return
endfunction
