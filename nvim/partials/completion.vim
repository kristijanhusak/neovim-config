set pumheight=15                                                                "Maximum number of entries in autocomplete popup

augroup vimrc_autocomplete
  autocmd!
  autocmd VimEnter * call s:setup_lsp()
  autocmd FileType javascript,javascriptreact,vim,php,gopls setlocal omnifunc=v:lua.vim.lsp.omnifunc
  autocmd BufEnter * lua require'completion'.on_attach()
  autocmd FileType sql let g:completion_trigger_character = ['.', '"']
augroup END

function! s:setup_lsp() abort
  lua require'nvim_lsp'.tsserver.setup{on_attach=require'completion'.on_attach}
  lua require'nvim_lsp'.vimls.setup{on_attach=require'completion'.on_attach}
  lua require'nvim_lsp'.intelephense.setup{on_attach=require'completion'.on_attach}
  lua require'nvim_lsp'.gopls.setup{on_attach=require'completion'.on_attach}
lua <<EOF
  require'nvim-treesitter.configs'.setup {
      highlight = { enable = true },
      incremental_selection = {
	  enable = true,
	  keymaps = {                       -- mappings for incremental selection (visual mappings)
	    init_selection = 'gnn',         -- maps in normal mode to init the node/scope selection
	    node_incremental = "grn",       -- increment to the upper named parent
	    scope_incremental = "grc",      -- increment to the upper scope (as defined in locals.scm)
	    node_decremental = "grm",       -- decrement to the previous node
	  }
      },
      refactor = {
	highlight_definitions = { enable = true },
	highlight_current_scope = { enable = true },
	smart_rename = {
	  enable = true,
	  keymaps = {
	    smart_rename = "grr"
	  }
	},
	navigation = {
	  enable = true,
	  keymaps = {
	    goto_definition = "gnd",
	    list_definitions = "gnD"
	  }
	}
      },
      textobjects = {
	  enable = true,
	  keymaps = {
	      ["af"] = "@function.outer",
	      ["if"] = "@function.inner",
	      ["aC"] = "@class.outer",
	      ["iC"] = "@class.inner",
	      ["ac"] = "@conditional.outer",
	      ["ic"] = "@conditional.inner",
	      ["ae"] = "@block.outer",
	      ["ie"] = "@block.inner",
	      ["al"] = "@loop.outer",
	      ["il"] = "@loop.inner",
	      ["is"] = "@statement.inner",
	      ["as"] = "@statement.outer",
	      ["ad"] = "@comment.outer",
	      ["am"] = "@call.outer",
	      ["im"] = "@call.inner"
	  }
      },
      ensure_installed = {"javascript", "typescript"}
  }
EOF
endfunction
set completeopt=menuone,noinsert,noselect

let g:completion_confirm_key = "\<C-y>"
let g:completion_sorting = 'none'
let g:completion_auto_change_source = 1
let g:completion_chain_complete_list = {
      \ 'sql': [
      \   {'complete_items': ['vim-dadbod-completion']},
      \   {'mode': '<c-n>'},
      \],
      \ 'default': [
      \    {'complete_items': ['lsp']},
      \    {'mode': '<c-n>'},
      \  ]}

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction


function s:tab_completion() abort
   let snippet = snippets#check()
   if !empty(snippet)
     return snippets#expand(snippet)
   endif

  if pumvisible()
    return "\<C-n>"
  endif

  if s:check_back_space()
    return "\<TAB>"
  endif

  return completion#trigger_completion()
endfunction

inoremap <silent><expr> <TAB> <sid>tab_completion()

imap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"

imap <c-j> <cmd>lua require'source'.prevCompletion()<CR>
imap <c-k> <cmd>lua require'source'.nextCompletion()<CR>

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
