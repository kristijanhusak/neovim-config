function! s:packager_init() abort
  packadd vim-packager
  call packager#init()
  call packager#add('kristijanhusak/vim-packager', { 'type': 'opt' })
  call packager#add('kristijanhusak/vim-js-file-import', { 'do': 'npm install', 'type': 'opt' })
  call packager#add('kristijanhusak/defx-git', { 'type': 'opt' })
  call packager#add('kristijanhusak/defx-icons', { 'type': 'opt' })
  call packager#add('phpactor/phpactor', { 'do': 'composer install --no-dev', 'type': 'opt' })
  call packager#add('fatih/vim-go', { 'do': ':GoUpdateBinaries', 'type': 'opt' })
  call packager#add('vimwiki/vimwiki', { 'type': 'opt' })
  call packager#add('Shougo/defx.nvim')
  call packager#add('tpope/vim-commentary')
  call packager#add('tpope/vim-surround')
  call packager#add('tpope/vim-repeat')
  call packager#add('tpope/vim-fugitive')
  call packager#add('tpope/vim-sleuth')
  call packager#add('tpope/vim-dadbod')
  call packager#add('tpope/vim-rsi')
  call packager#add('lambdalisue/vim-backslash')
  call packager#add('AndrewRadev/splitjoin.vim')
  call packager#add('airblade/vim-gitgutter')
  call packager#add('sheerun/vim-polyglot')
  call packager#add('junegunn/fzf', { 'do': './install --all && ln -sf $(pwd) ~/.fzf'})
  call packager#add('junegunn/fzf.vim')
  call packager#add('ludovicchabant/vim-gutentags')
  call packager#add('editorconfig/editorconfig-vim')
  call packager#add('andymass/vim-matchup')
  call packager#add('haya14busa/vim-asterisk')
  call packager#add('osyo-manga/vim-anzu')
  call packager#add('dyng/ctrlsf.vim')
  call packager#add('neoclide/coc.nvim', { 'do': 'yarn install --frozen-lockfile' })
  call packager#add('w0rp/ale')
  call packager#add('honza/vim-snippets')
  call packager#add('AndrewRadev/tagalong.vim')
  call packager#add('kristijanhusak/vim-create-pr')
  call packager#add('wakatime/vim-wakatime')
  call packager#add('sonph/onehalf', {'rtp': 'vim'})
endfunction

command! -nargs=0 PackagerInstall call s:packager_init() | call packager#install()
command! -bang PackagerUpdate call s:packager_init() | call packager#update({ 'force_hooks': '<bang>' })
command! PackagerClean call s:packager_init() | call packager#clean()
command! PackagerStatus call s:packager_init() | call packager#status()

let g:mapleader = ','                                                           "Change leader to a comma

augroup packager_filetype
  autocmd!
  autocmd FileType javascript,javascriptreact,typescript packadd vim-js-file-import
  autocmd FileType defx packadd defx-git | packadd defx-icons
  autocmd FileType php packadd phpactor
  autocmd FileType go packadd vim-go
  autocmd FileType fugitive nmap <buffer><silent> <Space> =
augroup END

" Better search status
nnoremap <silent><Leader><space> :AnzuClearSearchStatus<BAR>noh<CR>
nmap n <Plug>(anzu-n)zz
nmap N <Plug>(anzu-N)zz
map * <Plug>(asterisk-z*)<Plug>(anzu-update-search-status)
map # <Plug>(asterisk-z#)<Plug>(anzu-update-search-status)
map g* <Plug>(asterisk-gz*)<Plug>(anzu-update-search-status)
map g# <Plug>(asterisk-gz#)<Plug>(anzu-update-search-status)
nnoremap <silent><Leader>ww :unmap <Leader>ww<BAR>packadd vimwiki<BAR>VimwikiIndex<CR>

" Search mappings
nmap <Leader>f <Plug>CtrlSFPrompt
vmap <Leader>F <Plug>CtrlSFVwordPath
nmap <Leader>F <Plug>CtrlSFCwordPath

" Reformat and fix linting errors
nnoremap <Leader>R :ALEFix<CR>
nnoremap [e :ALEPrevious<CR>
nnoremap ]e :ALENext<CR>

" Open fugitive git status in vertical split
nnoremap <silent> <Leader>G :vert G<CR>

let g:ctrlsf_auto_close = 0                                                     "Do not close search when file is opened
let g:ctrlsf_mapping = {'vsplit': 's'}                                          "Mapping for opening search result in vertical split
let g:ctrlsf_search_mode = 'sync'                                               "Use sync mode for searching, more precise and reliable

let g:ale_linters = {'javascript': ['eslint']}                                  "Lint js with eslint
let g:ale_fixers = {'javascript': ['prettier', 'eslint']}                       "Fix eslint errors
let g:ale_javascript_prettier_options = '--print-width 120'                     "Set max width to 120 chars for prettier
let g:ale_lint_delay = 400                                                      "Increase linting delay
let g:ale_sign_error = '✖'                                                      "Lint error sign
let g:ale_sign_warning = '⚠'                                                    "Lint warning sign

let g:jsx_ext_required = 1                                                      "Force jsx extension for jsx filetype
let g:javascript_plugin_jsdoc = 1                                               "Enable syntax highlighting for js doc blocks
let g:vim_markdown_conceal = 0                                                  "Disable concealing in markdown

let g:vimwiki_list = [{
      \ 'path': '~/Dropbox/vimwiki',
      \ 'syntax': 'markdown',
      \ 'ext': '.md'
      \ }]

let g:matchup_matchparen_status_offscreen = 0                                   "Do not show offscreen closing match in statusline
let g:matchup_matchparen_nomode = "ivV\<c-v>"                                   "Enable matchup only in normal mode
let g:matchup_matchparen_deferred = 1                                           "Defer matchup highlights to allow better cursor movement performance
