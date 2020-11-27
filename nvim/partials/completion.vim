set pumheight=15                                                                "Maximum number of entries in autocomplete popup

augroup vimrc_autocomplete
  autocmd!
  autocmd VimEnter * call s:setup_completion()
  autocmd FileType javascript,javascriptreact,vim,php,go,lua setlocal omnifunc=v:lua.vim.lsp.omnifunc
augroup END

let g:compe_enabled = v:true
let g:compe_min_length = 1
let g:compe_auto_preselect = v:false
let g:compe_source_timeout = 200
let g:compe_incomplete_delay = 400

function! s:setup_completion() abort
  lua require'lsp_setup'
  call compe#source#vim_bridge#register('path', compe_path#source#create())
  call compe#source#vim_bridge#register('vsnip', compe_vsnip#source#create())
  call compe#source#vim_bridge#register('tags', compe_tags#source#create())
endfunction

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction

function s:tab_completion() abort
  if vsnip#jumpable(1)
    return "\<Plug>(vsnip-jump-next)"
  endif

  if pumvisible()
    return "\<C-n>"
  endif

  if s:check_back_space()
    return "\<TAB>"
  endif

  if vsnip#expandable()
    return "\<Plug>(vsnip-expand)"
  endif

  return compe#complete()
endfunction

imap <expr> <TAB> <sid>tab_completion()

imap <expr><S-TAB> pumvisible() ? "\<C-p>" : vsnip#jumpable(-1) ? "\<Plug>(vsnip-jump-prev)" : "\<S-TAB>"
smap <expr><TAB> vsnip#available(1)  ? "\<Plug>(vsnip-expand-or-jump)" : "\<TAB>"
smap <expr><S-TAB> vsnip#available(-1)  ? "\<Plug>(vsnip-jump-prev)" : "\<S-TAB>"
imap <expr> <CR> pumvisible() && complete_info()['selected'] != '-1'
      \ ? compe#confirm('<CR>')
      \ : vsnip#expandable() ? "\<Plug>(vsnip-expand)" : "\<Plug>(PearTreeExpand)"

nmap <leader>ld <cmd>lua vim.lsp.buf.definition()<CR>
nmap <leader>lc <cmd>lua vim.lsp.buf.declaration()<CR>
nmap <leader>lg <cmd>lua vim.lsp.buf.implementation()<CR>
nmap <leader>lu <cmd>lua vim.lsp.buf.references()<CR>
nmap <leader>lr <cmd>lua vim.lsp.buf.rename()<CR>
nmap <leader>lh <cmd>lua vim.lsp.buf.hover()<CR>
nmap <leader>ls <cmd>lua vim.lsp.buf.signature_help()<CR>
nmap <leader>lf <cmd>lua vim.lsp.buf.formatting()<CR>
vmap <leader>lf :<C-u>call v:lua.vim.lsp.buf.range_formatting()<CR>
nmap <leader>la :call v:lua.vim.lsp.buf.code_action()<CR>
vmap <leader>la :<C-u>call v:lua.vim.lsp.buf.range_code_action()<CR>
nmap <leader>li <cmd>lua vim.lsp.buf.incoming_calls()<CR>
nmap <leader>lo <cmd>lua vim.lsp.buf.outgoing_calls()<CR>
nmap <leader>le <cmd>lua vim.lsp.util.show_line_diagnostics()<CR>
nmap <leader>lt <cmd>lua vim.lsp.buf.document_symbol()<CR>
nmap <leader>lT <cmd>lua vim.lsp.buf.workspace_symbol()<CR>

set wildoptions=pum
set wildignore=*.o,*.obj,*~                                                     "stuff to ignore when tab completing
set wildignore+=*.git*
set wildignore+=*.meteor*
set wildignore+=*vim/backups*
set wildignore+=*sass-cache*
set wildignore+=*mypy_cache*
set wildignore+=*__pycache__*
set wildignore+=*cache*
set wildignore+=*logs*
set wildignore+=*node_modules*
set wildignore+=**/node_modules/**
set wildignore+=*DS_Store*
set wildignore+=*.gem
set wildignore+=log/**
set wildignore+=tmp/**
set wildignore+=*.png,*.jpg,*.gif
