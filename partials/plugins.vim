function! s:packager_init() abort
  packadd vim-packager
  call packager#init()
  call packager#add('kristijanhusak/vim-packager', { 'type': 'opt' })
  call packager#add('kristijanhusak/vim-js-file-import', { 'do': 'npm install', 'type': 'opt' })
  call packager#add('kristijanhusak/defx-git', { 'type': 'opt' })
  call packager#add('kristijanhusak/defx-icons', { 'type': 'opt' })
  call packager#add('fatih/vim-go', { 'do': ':GoInstallBinaries', 'type': 'opt' })
  call packager#add('mgedmin/python-imports.vim', { 'type': 'opt' })
  call packager#add('prabirshrestha/async.vim', { 'type': 'opt' })
  call packager#add('prabirshrestha/vim-lsp', { 'type': 'opt' })
  call packager#add('phpactor/phpactor', { 'do': 'composer install --no-dev', 'type': 'opt' })
  call packager#add('Shougo/defx.nvim')
  call packager#add('w0rp/ale')
  call packager#add('Raimondi/delimitMate')
  call packager#add('manasthakur/vim-commentor')
  call packager#add('tpope/vim-surround')
  call packager#add('tpope/vim-repeat')
  call packager#add('tpope/vim-fugitive')
  call packager#add('tpope/vim-sleuth')
  call packager#add('tpope/vim-endwise')
  call packager#add('lambdalisue/vim-backslash')
  call packager#add('AndrewRadev/splitjoin.vim')
  call packager#add('airblade/vim-gitgutter')
  call packager#add('sheerun/vim-polyglot')
  call packager#add('junegunn/fzf', { 'do': './install --all && ln -sf $(pwd) ~/.fzf'})
  call packager#add('junegunn/fzf.vim')
  call packager#add('ludovicchabant/vim-gutentags')
  call packager#add('vimwiki/vimwiki')
  call packager#add('editorconfig/editorconfig-vim')
  call packager#add('morhetz/gruvbox')
  call packager#add('andymass/vim-matchup')
  call packager#add('haya14busa/vim-asterisk')
  call packager#add('osyo-manga/vim-anzu')
  call packager#add('dyng/ctrlsf.vim')
  call packager#add('kronos-io/kronos.vim')
endfunction

command! -nargs=0 PackagerInstall call s:packager_init() | call packager#install()
command! -bang PackagerUpdate call s:packager_init() | call packager#update({ 'force_hooks': '<bang>' })
command! PackagerClean call s:packager_init() | call packager#clean()
command! PackagerStatus call s:packager_init() | call packager#status()

let g:mapleader = ','                                                           "Change leader to a comma

augroup packager_filetype
  autocmd!
  autocmd FileType javascript packadd vim-js-file-import
  autocmd FileType defx packadd defx-git | packadd defx-icons
  autocmd FileType go packadd! vim-go
  autocmd FileType python packadd python-imports.vim
  autocmd FileType javascript,python,go packadd async.vim | packadd vim-lsp | call lsp#enable()
  autocmd FileType php packadd phpactor
augroup END

" Better search status
nnoremap <silent><Leader><space> :AnzuClearSearchStatus<BAR>noh<CR>
nmap n <Plug>(anzu-n)zz
nmap N <Plug>(anzu-N)zz
map * <Plug>(asterisk-z*)<Plug>(anzu-update-search-status)
map # <Plug>(asterisk-z#)<Plug>(anzu-update-search-status)
map g* <Plug>(asterisk-gz*)<Plug>(anzu-update-search-status)
map g# <Plug>(asterisk-gz#)<Plug>(anzu-update-search-status)

" Search mappings
nmap <Leader>f <Plug>CtrlSFPrompt
vmap <Leader>F <Plug>CtrlSFVwordPath
nmap <Leader>F <Plug>CtrlSFCwordPath

" Reformat and fix linting errors
nnoremap <Leader>R :ALEFix<CR>
nnoremap [e :ALEPrevious<CR>
nnoremap ]e :ALENext<CR>

" Fuzzy finder
nnoremap <C-p> :Files<CR>
nnoremap <Leader>b :Buffers<CR>
nnoremap <Leader>t :BTags<CR>
nnoremap <Leader>m :History<CR>
nnoremap <Leader>g :GFiles?<CR>

let g:ctrlsf_auto_close = 0                                                     "Do not close search when file is opened
let g:ctrlsf_mapping = {'vsplit': 's'}                                          "Mapping for opening search result in vertical split

let g:delimitMate_expand_cr = 1                                                 "Auto indent on enter

let g:ale_virtualtext_cursor = 1                                                "Enable neovim's virtualtext support
let g:ale_virtualtext_prefix = '  > '                                           "Move virtual text a bit more right
let g:ale_linters = {'javascript': ['eslint']}                                  "Lint js with eslint
let g:ale_fixers = {'javascript': ['prettier', 'eslint']}                       "Fix eslint errors
let g:ale_javascript_prettier_options = '--print-width 100'                     "Set max width to 100 chars for prettier
let g:ale_lint_delay = 400                                                      "Increase linting delay
let g:ale_sign_error = '✖'                                                      "Lint error sign
let g:ale_sign_warning = '⚠'                                                    "Lint warning sign

let g:jsx_ext_required = 1                                                      "Force jsx extension for jsx filetype
let g:javascript_plugin_jsdoc = 1                                               "Enable syntax highlighting for js doc blocks
let g:vim_markdown_conceal = 0                                                  "Disable concealing in markdown

let g:vimwiki_list = [{'path': '~/Dropbox/vimwiki'}]                            "Use dropbox folder for easier syncing of wiki

let g:matchup_matchparen_status_offscreen = 0                                   "Do not show offscreen closing match in statusline
let g:matchup_matchparen_nomode = "ivV\<c-v>"                                   "Enable matchup only in normal mode
let g:matchup_matchparen_deferred = 1                                           "Defer matchup highlights to allow better cursor movement performance

let g:go_fmt_command = 'goimports'                                              "Auto import go packages on save

let g:kronos_database = expand('~/Dropbox/kronos')
