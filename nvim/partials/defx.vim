augroup vimrc_defx
  autocmd!
  autocmd FileType defx call s:defx_mappings()                                  "Defx mappings
  autocmd VimEnter * call s:setup_defx()
  autocmd VimEnter * call fugitive#detect(expand('<afile>')) | call lightline#update()
augroup END

nnoremap <silent><Leader>n :call <sid>defx_open({ 'split': v:true })<CR>
nnoremap <silent><Leader>hf :call <sid>defx_open({ 'split': v:true, 'find_current_file': v:true })<CR>


function! s:setup_defx() abort
  call defx#custom#column('filename', {
        \ 'indent': '  ',
        \ 'directory_icon': '',
        \ 'opened_icon': '',
        \ 'root_icon': '',
        \ 'min_width': 80,
        \ 'max_width': 80,
        \ })

  call defx#custom#option('_', {
        \ 'columns': 'mark:git:filename:size:time',
        \ })

  call s:defx_open({ 'dir': expand('<afile>') })
endfunction

function s:get_project_root() abort
  let l:git_root = ''
  let l:path = expand('%:p:h')
  let l:cmd = systemlist('cd '.l:path.' && git rev-parse --show-toplevel')
  if !v:shell_error
    let l:git_root = fnamemodify(l:cmd[0], ':p:h')
  endif

  if !empty(l:git_root)
    return l:git_root
  endif

  return getcwd()
endfunction

function! s:defx_open(...) abort
  let l:opts = get(a:, 1, {})
  let l:path = get(l:opts, 'dir', getcwd())

  if !isdirectory(l:path) || &filetype ==? 'defx'
    return
  endif

  let l:args = '-winwidth=40 -direction=topleft'
  let l:is_opened = bufwinnr('defx') > 0

  if has_key(l:opts, 'split')
    let l:args .= ' -split=vertical'
  endif

  if has_key(l:opts, 'find_current_file')
    if &filetype ==? 'defx'
      return
    endif
    call execute(printf('Defx %s -search=%s %s', l:args, expand('%:p'), s:get_project_root()))
  else
    call execute(printf('Defx -toggle %s %s', l:args, l:path))
    if l:is_opened
      call execute('wincmd p')
    endif
  endif

  return execute("norm!\<C-w>=")
endfunction

function! s:defx_context_menu() abort
  let l:actions = ['new_multiple_files', 'rename', 'copy', 'move', 'paste', 'remove']
  let l:selection = confirm('Action?', "&New file/directory\n&Rename\n&Copy\n&Move\n&Paste\n&Delete")
  silent exe 'redraw'

  return feedkeys(defx#do_action(l:actions[l:selection - 1]))
endfunction

function s:defx_toggle_tree() abort
  if defx#is_directory()
    return defx#do_action('open_or_close_tree')
  endif
  return defx#do_action('drop')
endfunction

function! s:defx_mappings() abort
  nnoremap <silent><buffer>m :call <sid>defx_context_menu()<CR>
  nnoremap <silent><buffer><expr> o <sid>defx_toggle_tree()
  nnoremap <silent><buffer><expr> O defx#do_action('open_tree_recursive')
  nnoremap <silent><buffer><expr> <CR> <sid>defx_toggle_tree()
  nnoremap <silent><buffer><expr> <2-LeftMouse> <sid>defx_toggle_tree()
  nnoremap <silent><buffer><expr> C defx#is_directory() ? defx#do_action('open') : 'C'
  nnoremap <silent><buffer><expr> s defx#do_action('open', 'botright vsplit')
  nnoremap <silent><buffer><expr> R defx#do_action('redraw')
  nnoremap <silent><buffer><expr> U defx#do_action('cd', ['..'])
  nnoremap <silent><buffer><expr> cd defx#do_action('change_vim_cwd')
  nnoremap <silent><buffer><expr> H defx#do_action('toggle_ignored_files')
  nnoremap <silent><buffer><expr> <Space> defx#do_action('toggle_select') . 'j'
  nnoremap <silent><buffer><expr> j line('.') == line('$') ? 'gg' : 'j'
  nnoremap <silent><buffer><expr> k line('.') == 1 ? 'G' : 'k'
  nnoremap <silent><buffer> J :call search('')<CR>
  nnoremap <silent><buffer> K :call search('', 'b')<CR>
  nnoremap <silent><buffer><expr> yy defx#do_action('yank_path')
  nnoremap <silent><buffer><expr> q defx#do_action('quit')
  nnoremap <silent><buffer><expr> gh defx#do_action('cd', [getcwd()])
endfunction


