scriptencoding utf-8
let s:cache = {'branch': ''}

augroup custom_statusline
  autocmd!
  autocmd VimEnter * silent! call FugitiveDetect(expand('<afile>')) | let s:cache.branch = fugitive#head()
  autocmd BufEnter,WinEnter * setlocal statusline=%!Statusline()
  autocmd BufLeave,WinLeave * setlocal statusline=%f\ %y\ %m
  autocmd User FugitiveChanged let s:cache.branch = fugitive#head()
  autocmd VimEnter,ColorScheme * call s:set_statusline_colors()
augroup END

function! s:set_statusline_colors() abort
  let s:normal_bg = synIDattr(hlID('Normal'), 'bg')
  let s:normal_fg = synIDattr(hlID('Normal'), 'fg')
  let s:warning_fg = synIDattr(hlID(&background ==? 'dark' ? 'GruvboxYellow' : 'PreProc'), 'fg')
  let s:error_fg = synIDattr(hlID('ErrorMsg'), &background ==? 'dark' ? 'bg' : 'fg')

  silent! exe 'hi StItem guibg='.s:normal_fg.' guifg='.s:normal_bg.' gui=NONE'
  silent! exe 'hi StSep guifg='.s:normal_fg.' guibg=NONE gui=NONE'
  silent! exe 'hi StErr guibg='.s:error_fg.' guifg='.s:normal_bg.' gui=bold'
  silent! exe 'hi StErrSep guifg='.s:error_fg.' guibg=NONE gui=NONE'
  silent! exe 'hi StWarn guibg='.s:warning_fg.' guifg='.s:normal_bg.' gui=bold'
  silent! exe 'hi StWarnSep guifg='.s:warning_fg.' guibg=NONE gui=NONE'
  silent! exe 'hi Statusline guifg=NONE guibg='.s:normal_bg.' gui=NONE cterm=NONE'
endfunction

function! s:sep(item, ...) abort
  let l:opts = get(a:, '1', {})
  let l:no_after = get(l:opts, 'no_after', 0)
  let l:no_before = get(l:opts, 'no_before', 0)
  let l:sep_color = get(l:opts, 'sep_color', '%#StSep#')
  let l:sep_before = '█'
  let l:sep_after = '█'
  let l:color = get(l:opts, 'color', '%#StItem#')
  let l:side = get(l:opts, 'side', 'left')
  if l:side !=? 'left'
    let l:sep_before = '█'
    let l:sep_after = '█'
  endif

  if l:no_before
    let l:sep_before = '█'
  endif

  if l:no_after
    let l:sep_after = '█'
  endif

  return l:sep_color.l:sep_before.l:color.a:item.l:sep_color.l:sep_after.'%*'
endfunction

function! s:sep_if(item, condition, ...) abort
  if !a:condition
    return ''
  endif
  let l:opts = get(a:, '1', {})
  return s:sep(a:item, l:opts)
endfunction

let s:st_mode = {'color': '%#StMode#', 'sep_color': '%#StModeSep#'}
let s:st_err = {'color': '%#StErr#', 'sep_color': '%#StErrSep#'}
let s:st_mode_right = extend({'side': 'right'}, s:st_mode)
let s:st_err_right = extend({'side': 'right'}, s:st_err)
let s:st_warn = {'color': '%#StWarn#', 'sep_color': '%#StWarnSep#', 'side': 'right', 'no_after': 1}

function! Statusline() abort
  let l:mode = s:mode_statusline()
  let l:statusline = s:sep(l:mode, extend({'no_before': 1}, s:st_mode))
  let l:git_status = s:git_statusline()
  let l:statusline .= s:sep_if(l:git_status, !empty(l:git_status))
  let l:statusline .= s:sep(s:get_path(), &modified ? s:st_err : {})                                                    "File path
  let l:statusline .= s:sep_if(' + ', &modified, s:st_err)                                                              "Modified indicator
  let l:statusline .= s:sep_if(' - ', !&modifiable, s:st_err)                                                           "Modifiable indicator
  let l:statusline .= s:sep_if('%w', &previewwindow)                                                                    "Preview indicator
  let l:statusline .= s:sep_if('%r', &readonly)                                                                         "Read only indicator
  let l:statusline .= s:sep_if('%q', &buftype ==? 'quickfix')                                                           "Quickfix list indicator
  let l:statusline .= '%='                                                                                              "Start right side layout
  let l:anzu = exists('*anzu#search_status') ? anzu#search_status() : ''
  let l:statusline .= s:sep_if(l:anzu, !empty(l:anzu), {'side': 'right'})                                               "Search status
  let l:ft = &filetype
  let l:statusline .= s:sep_if(l:ft, !empty(l:ft), {'side': 'right'})                                                   "Filetype
  let l:statusline .= s:sep(': %c', s:st_mode_right)                                              "Column number
  let l:statusline .= s:sep(': %l/%L', s:st_mode_right)                                           "Current line number/Total line numbers
  let l:err = s:ale_status('error')
  let l:warn = s:ale_status('warning')
  let l:statusline .= s:sep('%p%%', extend({'no_after': empty(l:err) && empty(l:warn)}, s:st_mode_right))    "Percentage
  let l:statusline .= s:sep_if(l:err, !empty(l:err), extend({ 'no_after': empty(l:warn) }, s:st_err_right))
  let l:statusline .= s:sep_if(l:warn, !empty(l:warn), s:st_warn)
  let l:statusline .= '%<'
  return l:statusline
endfunction


function! s:ale_status(type) abort
  if !exists('g:loaded_ale')
    return ''
  endif

  let l:count = ale#statusline#Count(bufnr(''))
  let l:errors = l:count.error + l:count.style_error
  let l:warnings = l:count.warning + l:count.style_warning

  if a:type ==? 'error' && l:errors
    return printf('%d E', l:errors)
  endif

  if a:type ==? 'warning' && l:warnings
    return printf('%d W', l:warnings)
  endif

  return ''
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

function! s:mode_statusline() abort
  let l:mode = mode()
  call s:mode_highlight(l:mode)
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

function! s:mode_highlight(mode) abort
  if a:mode ==? 'i'
    hi StMode guibg=#83a598 guifg=#3c3836
    hi StModeSep guifg=#83a598 guibg=NONE
  elseif a:mode =~? '\(v\|V\|\)'
    hi StMode guibg=#fe8019 guifg=#3c3836
    hi StModeSep guifg=#fe8019 guibg=NONE
  elseif a:mode ==? 'R'
    hi StMode guibg=#8ec07c guifg=#3c3836
    hi StModeSep guifg=#8ec07c guibg=NONE
  else
    silent! exe 'hi StMode guibg='.s:normal_fg.' guifg='.s:normal_bg.' gui=NONE'
    silent! exe 'hi StModeSep guifg='.s:normal_fg.' guibg=NONE gui=NONE'
  endif
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
