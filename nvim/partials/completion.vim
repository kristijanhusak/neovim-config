set pumheight=15                                                                "Maximum number of entries in autocomplete popup

augroup vimrc_autocomplete
  autocmd!
  autocmd VimEnter * lua require'lsp_setup'
  autocmd FileType javascript,javascriptreact,vim,php,gopls,lua setlocal omnifunc=v:lua.vim.lsp.omnifunc
  autocmd BufEnter * lua require'completion'.on_attach()
  autocmd FileType sql let g:completion_trigger_character = ['.', '"']
augroup END

set completeopt=menuone,noinsert,noselect

let g:completion_confirm_key = ''
let g:completion_sorting = 'none'
let g:completion_matching_strategy_list = ['exact', 'substring']
let g:completion_enable_snippet = 'vim-vsnip'
let g:completion_matching_ignore_case = 1
let g:completion_chain_complete_list = {
      \ 'sql': [
      \   {'complete_items': ['vim-dadbod-completion']},
      \   {'mode': '<c-n>'},
      \],
      \ 'default': [
      \    {'complete_items': ['snippet', 'ts', 'lsp']},
      \    {'mode': '<c-n>'},
      \    {'complete_items': ['path'], 'triggered_only': ['/']},
      \  ]}

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

  return "\<Plug>(completion_next_source)"
endfunction

imap <expr> <TAB> <sid>tab_completion()

imap <expr><S-TAB> pumvisible() ? "\<C-p>" : vsnip#jumpable(-1) ? "\<Plug>(vsnip-jump-prev)" : "\<S-TAB>"
smap <expr><TAB> vsnip#available(1)  ? "\<Plug>(vsnip-expand-or-jump)" : "\<TAB>"
smap <expr><S-TAB> vsnip#available(-1)  ? "\<Plug>(vsnip-jump-prev)" : "\<S-TAB>"
imap <expr> <CR> pumvisible() && complete_info()['selected'] != '-1'
      \ ? "\<Plug>(completion_confirm_completion)"
      \ : vsnip#expandable() ? "\<Plug>(vsnip-expand)" : "\<Plug>(PearTreeExpand)"

imap  <c-j> <Plug>(completion_next_source)
imap  <c-k> <Plug>(completion_prev_source)

nmap <leader>ld <cmd>lua vim.lsp.buf.definition()<CR>
nmap <leader>lc <cmd>lua vim.lsp.buf.declaration()<CR>
nmap <leader>lg <cmd>lua vim.lsp.buf.implementation()<CR>
nmap <leader>lu <cmd>lua vim.lsp.buf.references()<CR>
nmap <leader>lr <cmd>lua vim.lsp.buf.rename()<CR>
nmap <leader>lh <cmd>lua vim.lsp.buf.hover()<CR>
nmap <leader>lf <cmd>lua vim.lsp.buf.formatting()<CR>
nmap <leader>la <cmd>lua vim.lsp.buf.code_action()<CR>
vmap <leader>la <cmd>lua vim.lsp.buf.code_action()<CR>

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
