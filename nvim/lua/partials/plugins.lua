_G.kris.plugins = {}
local api = vim.api
local utils = require'partials/utils'
vim.cmd [[packadd vim-packager]]

require('packager').setup(function(packager)
 packager.add('kristijanhusak/vim-packager', { type = 'opt' })
 packager.add('kristijanhusak/vim-js-file-import', { ['do'] = 'npm install', type = 'opt' })
 packager.add('fatih/vim-go', { ['do'] = ':GoInstallBinaries', type = 'opt' })
 packager.add('vimwiki/vimwiki', { type = 'opt' })
 packager.add('tpope/vim-commentary')
 packager.add('tpope/vim-surround')
 packager.add('tpope/vim-repeat')
 packager.add('tpope/vim-fugitive')
 packager.add('tpope/vim-sleuth')
 packager.add('kristijanhusak/vim-create-pr')
 packager.add('kristijanhusak/vim-dadbod')
 packager.add('kristijanhusak/vim-dadbod-completion', { requires = 'kristijanhusak/vim-dadbod' })
 packager.add('kristijanhusak/vim-dadbod-ui', { requires = 'kristijanhusak/vim-dadbod' })
 packager.add('lambdalisue/vim-backslash')
 packager.add('lambdalisue/reword.vim')
 packager.add('AndrewRadev/tagalong.vim')
 packager.add('AndrewRadev/splitjoin.vim')
 packager.add('lewis6991/gitsigns.nvim', { requires = 'nvim-lua/plenary.nvim' })
 packager.add('sheerun/vim-polyglot')
 packager.add('junegunn/fzf', { ['do'] = './install --all && ln -sf $(pwd) ~/.fzf' })
 packager.add('junegunn/fzf.vim')
 packager.add('ludovicchabant/vim-gutentags')
 packager.add('editorconfig/editorconfig-vim')
 packager.add('andymass/vim-matchup')
 packager.add('haya14busa/vim-asterisk')
 packager.add('osyo-manga/vim-anzu')
 packager.add('stefandtw/quickfix-reflector.vim')
 packager.add('dense-analysis/ale')
 packager.add('wakatime/vim-wakatime')
 packager.add('tmsvg/pear-tree')
 packager.add('neovim/nvim-lspconfig')
 packager.add('nvim-treesitter/nvim-treesitter')
 packager.add('nvim-treesitter/nvim-treesitter-refactor')
 packager.add('nvim-treesitter/nvim-treesitter-textobjects')
 packager.add('hrsh7th/vim-vsnip')
 packager.add('hrsh7th/vim-vsnip-integ')
 packager.add('kyazdani42/nvim-tree.lua', { requires = 'kyazdani42/nvim-web-devicons' })
 packager.add('kristijanhusak/any-jump.vim')
 packager.add('tommcdo/vim-exchange')
 packager.add('unblevable/quick-scope')
 packager.add('hrsh7th/nvim-compe')
 packager.add('sainnhe/edge')
 packager.add('voldikss/vim-skylight')
 packager.add('RishabhRD/nvim-lsputils', { requires = 'RishabhRD/popfix' })
end)

vim.g.mapleader = ','

vim.cmd[[augroup packager_filetype]]
  vim.cmd[[autocmd!]]
  vim.cmd[[autocmd FileType javascript,javascriptreact,typescript,typescriptreact packadd vim-js-file-import]]
  vim.cmd[[autocmd FileType go packadd vim-go]]
  vim.cmd[[autocmd FileType NvimTree call v:lua.kris.plugins.setup_nvimtree() ]]
  vim.cmd[[autocmd VimEnter * call v:lua.kris.plugins.handle_vimenter() ]]
vim.cmd[[augroup END]]

function _G.kris.plugins.setup_nvimtree()
  vim.wo.signcolumn = 'yes'
  local buf = api.nvim_get_current_buf()
  utils.buf_keymap(buf, 'n', 'j', 'line(".") == line("$") ? "gg" : "j"', { expr = true })
  utils.buf_keymap(buf, 'n', 'k', 'line(".") == 1 ? "G" : "k"', { expr = true })
  utils.buf_keymap(buf, 'n', 'J', ':call search("[]")<CR>')
  utils.buf_keymap(buf, 'n', 'K', ':call search("[]", "b")<CR>')
  api.nvim_feedkeys(api.nvim_replace_termcodes('<C-w>w', true, false, true), 'n', true)
end

function _G.kris.plugins.handle_vimenter()
  vim.g.vsnip_snippet_dir = vim.fn.fnamemodify(vim.env.MYVIMRC, ':p:h')..'/snippets'
end

utils.keymap('n', '<Leader><space>', ':AnzuClearSearchStatus<BAR>noh<CR>')

utils.keymap('n', 'n', '<Plug>(anzu-n)zz', {noremap = false})
utils.keymap('n', 'N', '<Plug>(anzu-N)zz', {noremap = false})
utils.keymap('', '*', '<Plug>(asterisk-z*)<Plug>(anzu-update-search-status)', {noremap = false})
utils.keymap('', '#', '<Plug>(asterisk-z#)<Plug>(anzu-update-search-status)', {noremap = false})
utils.keymap('', 'g*', '<Plug>(asterisk-gz*)<Plug>(anzu-update-search-status)', {noremap = false})
utils.keymap('', 'g#', '<Plug>(asterisk-gz#)<Plug>(anzu-update-search-status)', {noremap = false})
utils.keymap('n', '<Leader>ww', ':unmap <Leader>ww<BAR>packadd vimwiki<BAR>VimwikiIndex<CR>')

utils.keymap('n', '<Leader>R', ':ALEFix<CR>')
utils.keymap('n', '[e', ':ALEPrevious<CR>')
utils.keymap('n', ']e', ':ALENext<CR>')

utils.keymap('n', '<Leader>G', ':vert G<CR>')

utils.keymap('n', '<Leader>n', ':NvimTreeToggle<CR>')
utils.keymap('n', '<Leader>hf', ':NvimTreeFindFile<CR>')

utils.keymap('i', '<BS>', '<Plug>(PearTreeBackspace)', {noremap = false})
utils.keymap('i', '<Esc>', '<Plug>(PearTreeFinishExpansion)', {noremap = false})

utils.keymap('n', '<Leader>y', ':Skylight tag<CR>')

-- Load .nvimrc manually until this PR is merged.
-- https://github.com/neovim/neovim/pull/13503
local local_vimrc = vim.fn.getcwd()..'/.nvimrc'
if vim.loop.fs_stat(local_vimrc) then
  vim.cmd('source '..local_vimrc)
end

require'gitsigns'.setup({
  signs = {
    add          = {hl = 'diffAdded', text = '▌'},
    change       = {hl = 'diffChanged', text = '▌'},
    delete       = {hl = 'diffRemoved', text = '_'},
    topdelete    = {hl = 'diffRemoved', text = '‾'},
    changedelete = {hl = 'diffChanged', text = '▌'},
  },
})

vim.g.nvim_tree_bindings = {
  edit_vsplit = 's',
  cd = 'C',
}
vim.g.nvim_tree_icons = {
  default = '',
  git = {
    unstaged = '✹',
  }
}
vim.g.nvim_tree_follow = 1
vim.g.nvim_tree_auto_open = 1
vim.g.nvim_tree_size = 40
vim.g.nvim_tree_git_hl = 1
vim.g.nvim_tree_hide_dotfiles = 1
vim.g.nvim_tree_width_allow_resize = true

vim.g.ale_virtualtext_cursor = 1
vim.g.ale_linters = {javascript = {'eslint'}}
vim.g.ale_fixers = {
  javascript = {'prettier', 'eslint'},
  javascriptreact = {'prettier', 'eslint'},
}
vim.g.ale_javascript_prettier_options = '--print-width 120'
vim.g.ale_lint_delay = 400
vim.g.ale_sign_error = ''
vim.g.ale_sign_warning = ''
vim.g.ale_disable_lsp = 1

vim.g.jsx_ext_required = 1
vim.g.javascript_plugin_jsdoc = 1
vim.g.vim_markdown_conceal = 0

vim.g.vimwiki_list = {{
    path = '~/Dropbox/vimwiki',
    syntax = 'markdown',
    ext = '.md'
}}

vim.g.matchup_matchparen_status_offscreen = 0
vim.g.matchup_matchparen_nomode = "ivV"

vim.g.db_ui_show_help = 0
vim.g.db_ui_win_position = 'right'
vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_async = 1

vim.g.js_file_import_use_fzf = 1

vim.g.db_ui_save_location = '~/Dropbox/dbui'
vim.g.db_ui_tmp_query_location = '~/code/queries'

vim.g.pear_tree_repeatable_expand = 0
vim.g.pear_tree_map_special_keys = 0

vim.g.sql_type_default = 'pgsql'

vim.g.qs_second_highlight = 0
vim.g.qs_highlight_on_keys = {'f', 'F', 't', 'T'}

vim.g.skylight_position = 'auto'
