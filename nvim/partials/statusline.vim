augroup vimrc_statusline
  autocmd!
  autocmd WinEnter,BufWinEnter * setlocal statusline=%!Statusline(1)            "Set focused statusline
  autocmd WinLeave,BufWinLeave * setlocal statusline=%!Statusline(0)            "Set not active statusline
  autocmd VimEnter * set statusline=%!Statusline(0)                             "Render statusline on vim start
augroup END

function! Statusline(is_bufenter) abort
  if exists('g:packager') && g:packager.is_running()
    return ''
  endif
  let l:bufnr = expand('<abuf>')
  let l:statusline = '%1* %{StatuslineMode()}'                                  "Mode
  let l:statusline .= ' %*%2*%{GitStatusline()}%*'                              "Git branch and status
  if &modified && a:is_bufenter
    let l:statusline .= '%3*'
  endif
  let l:statusline .= ' %f'                                                     "File path
  let l:statusline .= ' %m'                                                     "Modified indicator
  let l:statusline .= ' %w'                                                     "Preview indicator
  let l:statusline .= ' %r'                                                     "Read only indicator
  let l:statusline .= ' %q'                                                     "Quickfix list indicator
  let l:statusline .= ' %='                                                     "Start right side layout
  let l:statusline .= ' %{anzu#search_status()}'                                "Search status
  let l:statusline .= ' %2* %{&ft}'                                             "Filetype
  let l:statusline .= ' │ %p%%'                                                 "Percentage
  let l:statusline .= ' │ %c'                                                   "Column number
  let l:statusline .= ' │ %l/%L'                                                "Current line number/Total line numbers
  let l:statusline .= ' %*%#Error#%{AleStatus(''error'')}%*'                    "Errors count
  let l:statusline .= '%#WarningMsg#%{AleStatus(''warning'')}%*'                "Warning count
  return l:statusline
endfunction


function! AleStatus(type) abort
  let l:count = ale#statusline#Count(bufnr(''))
  let l:errors = l:count.error + l:count.style_error
  let l:warnings = l:count.warning + l:count.style_warning

  if a:type ==? 'error' && l:errors
    return printf(' %d E ', l:errors)
  endif

  if a:type ==? 'warning' && l:warnings
    let l:space = l:errors ? ' ': ''
    return printf('%s %d W ', l:space, l:warnings)
  endif

  return ''
endfunction

function! GitStatusline() abort
  let l:head = fugitive#head()
  if !exists('b:gitgutter')
    return (empty(l:head) ? '' : printf(' %s ', l:head))
  endif
  let [l:added, l:modified, l:removed] = get(b:gitgutter, 'summary', [0, 0, 0])
  let l:result = l:added == 0 ? '' : ' +'.l:added
  let l:result .= l:modified == 0 ? '' : ' ~'.l:modified
  let l:result .= l:removed == 0 ? '' : ' -'.l:removed
  let l:result = join(filter([l:head, l:result], {-> !empty(v:val) }), '')
  return (empty(l:result) ? '' : printf(' %s ', l:result))
endfunction

function! StatuslineMode() abort
  let l:mode = mode()
  call ModeHighlight(l:mode)
  let l:modeMap = {
  \ 'n'  : 'NORMAL',
  \ 'i'  : 'INSERT',
  \ 'R'  : 'REPLACE',
  \ 'v'  : 'VISUAL',
  \ 'V'  : 'V-LINE',
  \ 'c'  : 'COMMAND',
  \ '' : 'V-BLOCK',
  \ 's'  : 'SELECT',
  \ 'S'  : 'S-LINE',
  \ '' : 'S-BLOCK',
  \ 't'  : 'TERMINAL',
  \ }

  return get(l:modeMap, l:mode, 'UNKNOWN')
endfunction

function! ModeHighlight(mode) abort
  if a:mode ==? 'i'
    hi User1 guibg=#83a598
  elseif a:mode =~? '\(v\|V\|\)'
    hi User1 guibg=#fe8019
  elseif a:mode ==? 'R'
    hi User1 guibg=#8ec07c
  else
    let s:colors = { 'nord': '#81A1C1', 'gruvbox': '#928374' }
    silent! exe 'hi User1 guibg='.s:colors[g:colors_name]
  endif
endfunction
