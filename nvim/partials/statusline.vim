augroup VimrcLightline
  autocmd!
  autocmd User ALEFixPre   call lightline#update()
  autocmd User ALEFixPost  call lightline#update()
  autocmd User ALELintPre  call lightline#update()
  autocmd User ALELintPost call lightline#update()
  autocmd VimEnter * call SetupLightlineColors()
augroup end

let g:lightline = {
      \ 'colorscheme': 'cosmic_latte_'.$NVIM_COLORSCHEME_BG,
      \ 'active': {
                  \ 'left': [[ 'mode', 'paste', 'git_status' ], [ 'readonly', 'relativepath', 'custom_modified' ]],
                  \ 'right': [['linter_errors', 'linter_warnings', 'lineinfo'], ['indent', 'percent'], ['anzu', 'filetype']],
                  \ },
      \ 'inactive': {
                  \ 'left': [[ 'readonly', 'relativepath', 'modified' ]],
                  \ 'right': [['lineinfo'], ['percent'], ['filetype']]
                  \ },
      \ 'component_expand': {
                  \ 'linter_warnings': 'LightlineLinterWarnings',
                  \ 'linter_errors': 'LightlineLinterErrors',
                  \ 'git_status': 'GitStatusline',
                  \ 'custom_modified': 'StatuslineModified',
                  \ 'indent': 'IndentInfo',
                  \ },
      \ 'component_function': {
                  \ 'anzu': 'anzu#search_status',
                  \ },
      \ 'component_type': {
                  \ 'linter_errors': 'error',
                  \ 'custom_modified': 'error',
                  \ 'linter_warnings': 'warning'
                  \ },
      \ 'subseparator': { 'left': '│', 'right': '│' }
      \ }

function! IndentInfo() abort
  let l:indent_type = &expandtab ? 'spaces' : 'tabs'
  return l:indent_type.': '.&shiftwidth
endfunction


function! StatuslineModified() abort
  return &modified ? '+' : &modifiable ? '' : '-'
endfunction

function SetupLightlineColors() abort
  let l:pallete = g:lightline#colorscheme#cosmic_latte_light#palette
  let l:pallete.normal.error = [['#fff8e7', '#c44756', 231, 131]]
  let l:pallete.normal.warning =  [['#fff8e7', '#a154ae', 231, 133]]
  call lightline#colorscheme()
endfunction

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
  return (empty(l:result) ? '' : printf('%s', l:result))
endfunction
