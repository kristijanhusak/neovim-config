runtime! partials/plugins.vim
runtime! partials/settings.vim
runtime! partials/colorscheme.vim
runtime! partials/statusline.vim
runtime! partials/filetype/*.vim
runtime! partials/coc.vim
runtime! partials/mappings.vim
runtime! partials/abbreviations.vim
runtime! partials/fzf.vim

let s:peek_win = 0
function! s:peek() abort
  let tag = get(taglist('^'.expand('<cword>').'$'), 0, {})
  if empty(tag)
    return 0
  endif

  let curr_win = win_getid()
  let height = float2nr(&lines * 0.3)
  let width = &columns - 20
  let opts = {
        \ 'relative': 'win',
        \ 'width': width,
        \ 'height': height,
        \ 'style': 'minimal',
        \ 'col': 10,
        \ 'row': max([1, line('.') - line('w0') + 1])
        \ }
  let win = nvim_open_win(0, v:true, opts)
  exe 'edit '.tag.filename
  call search(tag.cmd[1:-2])
  call nvim_set_current_win(curr_win)
  call nvim_win_set_config(win, { 'focusable': v:false })
  let s:peek_win = win
endfunction

function! s:close_peek() abort
  if !empty(s:peek_win)
    call nvim_win_close(s:peek_win, v:true)
    let s:peek_win = 0
  endif
endfunction


augroup peeks
  autocmd!
  autocmd CursorMoved,CursorMovedI * call s:close_peek()
augroup END

nnoremap <Leader>y :call <sid>peek()<CR>
