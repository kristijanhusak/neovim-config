augroup VimrcLightline
  autocmd!
  autocmd User ALEFixPre   call lightline#update()
  autocmd User ALEFixPost  call lightline#update()
  autocmd User ALELintPre  call lightline#update()
  autocmd User ALELintPost call lightline#update()
augroup end

let g:lightline = {
      \ 'colorscheme': 'cosmic_latte_'.$NVIM_COLORSCHEME_BG,
      \ 'active': {
                  \ 'left': [ [ 'mode', 'paste', 'git_status' ], [ 'readonly', 'relativepath', 'modified' ] ],
                  \ 'right': [['lineinfo'], ['percent'], ['filetype', 'linter_errors', 'linter_warnings']]
                  \ },
      \ 'component_expand': {
                  \ 'linter_warnings': 'LightlineLinterWarnings',
                  \ 'linter_errors': 'LightlineLinterErrors',
                  \ 'git_status': 'GitStatusline'
                  \ },
      \ 'component_type': {
                  \ 'linter_errors': 'error',
                  \ 'linter_warnings': 'warning'
                  \ }
      \ }

function! LightlineLinterWarnings() abort
  return AleStatus('warning')
endfunction

function! LightlineLinterErrors() abort
  return AleStatus('error')
endfunction

function AleStatus(type) abort
  let l:count = ale#statusline#Count(bufnr(''))
  let l:items = l:count[a:type] + l:count['style_'.a:type]

  if l:items
    return printf('%d %s', l:items, toupper(strpart(a:type, 0, 1)))
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
