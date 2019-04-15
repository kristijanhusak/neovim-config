let g:fzf_layout = { 'window': 'call FloatingFZF()' }

function! FloatingFZF()
  let buf = nvim_create_buf(v:false, v:true)
  call setbufvar(buf, '&signcolumn', 'no')

  let winheight = winheight(0)
  let winwidth = winwidth(0)

  let width = float2nr(winwidth - (winwidth * 2 / 10))

  let opts = {
        \ 'relative': 'editor',
        \ 'row': &lines / 4,
        \ 'col': float2nr((winwidth - width) / 2),
        \ 'width': width,
        \ 'height': &lines / 2
        \ }

  let win = nvim_open_win(buf, v:true, opts)
  call nvim_win_set_option(win, 'winhl', 'Normal:FzfCustomHighlight')
  call nvim_win_set_option(win, 'number', v:false)
  call nvim_win_set_option(win, 'relativenumber', v:false)
endfunction
