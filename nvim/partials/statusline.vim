let s:cache = {'branch': ''}

augroup custom_statusline
  autocmd!
  autocmd VimEnter * silent! call FugitiveDetect(expand('<afile>')) | let s:cache.branch = fugitive#head()
  autocmd BufEnter,WinEnter * setlocal statusline=%!StatuslineSimple(1)
  autocmd BufLeave,WinLeave * setlocal statusline=%!StatuslineSimple(0)
  autocmd User FugitiveChanged let s:cache.branch = fugitive#head()
  autocmd VimEnter,ColorScheme * call s:set_statusline_colors()
augroup END

function! s:set_statusline_colors() abort
  let s:normal_fg = synIDattr(hlID('Normal'), &background ==? 'dark' ? 'fg' : 'bg')
  let s:warning_fg = synIDattr(hlID(&background ==? 'dark' ? 'GruvboxYellow' : 'PreProc'), 'fg')
  let s:error_fg = synIDattr(hlID('ErrorMsg'), &background ==? 'dark' ? 'bg' : 'fg')
  let s:statusline_bg = synIDattr(hlID('Statusline'), &background ==? 'dark' ? 'fg' : 'bg')

  silent! exe 'hi StErr guibg='.s:statusline_bg.' guifg='.s:error_fg.' gui=bold'
  silent! exe 'hi StWarn guibg='.s:statusline_bg.' guifg='.s:warning_fg.' gui=bold'
  silent! exe 'hi StModified guifg='.s:normal_fg.' guibg='.s:error_fg.' gui=bold'
  silent! exe 'hi StModifiedEnd guibg='.s:statusline_bg.' guifg='.s:error_fg.' gui=bold'
endfunction

function! StatuslineSimple(is_active) abort
  let l:anzu = exists('*anzu#search_status') ? anzu#search_status() : ''
  return join(filter([
        \    (a:is_active && &modified ? '%#StModified#' : '').' '.toupper(mode()).' ',
        \    s:git_statusline().' ',
        \    s:get_path().' ',
        \    (&modified ? '+ ' : '').(&modified && a:is_active ? '%#StModifiedEnd#' : ''),
        \    '%*%r',
        \    '%h',
        \    '%q',
        \    '%w',
        \    '%=',
        \    !empty(l:anzu) ? l:anzu.' ' : '',
        \    &filetype ? &filetype.' ' : '',
        \    ' %l/%c ',
        \    '%L/%p%% ',
        \    s:ale_status(),
        \  ], '!empty(v:val)'), ' ')
endfunction

function! s:ale_status() abort
  if !exists('g:loaded_ale')
    return ''
  endif

  let l:count = ale#statusline#Count(bufnr(''))
  let l:errors = l:count.error + l:count.style_error
  let l:warnings = l:count.warning + l:count.style_warning
  let l:result = []

  if l:errors
    call add(l:result, '%#StErr# ✘ '.l:errors.' %*')
  endif

  if l:warnings
    call add(l:result, '%#StWarn# ⚠ '.l:warnings.' %*')
  endif

  return join(l:result, '')
endfunction

function! s:git_statusline() abort
  if !exists('b:gitgutter')
    return s:with_icon(s:cache.branch, "\ue0a0")
  endif
  let [l:added, l:modified, l:removed] = get(b:gitgutter, 'summary', [0, 0, 0])
  let l:result = l:added == 0 ? '' : ' +'.l:added
  let l:result .= l:modified == 0 ? '' : ' ~'.l:modified
  let l:result .= l:removed == 0 ? '' : ' -'.l:removed
  let l:result = join(filter([s:cache.branch, l:result], {-> !empty(v:val) }), '')
  return s:with_icon(l:result, "\ue0a0")
endfunction

function! s:with_icon(value, icon) abort
  if empty(a:value)
    return a:value
  endif
  return a:icon.' '.a:value
endfunction

function! s:get_path() abort
  let l:path = expand('%')
  if isdirectory(l:path)
    return '%F'
  endif

  let l:path = substitute(expand('%'), '^'.getcwd(), '', '')

  if len(l:path) < 40
    return '%f'
  endif

  return pathshorten(l:path)
endfunction
