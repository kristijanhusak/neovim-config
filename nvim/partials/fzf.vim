scriptencoding utf-8
let $FZF_DEFAULT_OPTS='--layout=reverse'
let g:fzf_layout = { 'window': {'width': 0.9, 'height': 0.9 } }
let g:fzf_history_dir = '~/.local/share/fzf-history'

nnoremap <silent><C-p> :Files<CR>
nnoremap <silent><Leader>b :Buffers<CR>
nnoremap <silent><Leader>t :BTags<CR>
nnoremap <silent><Leader>m :History<CR>
nnoremap <silent><Leader>g :GFiles?<CR>

function! s:goto_def(lines) abort
  silent! exe 'e +BTags '.a:lines[0]
  call timer_start(10, {-> execute('startinsert') })
endfunction

function! s:goto_line(lines) abort
  silent! exe 'e '.a:lines[0]
  call timer_start(10, {-> feedkeys(':') })
endfunction

let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit',
  \ '@': function('s:goto_def'),
  \ ':': function('s:goto_line')
  \  }
