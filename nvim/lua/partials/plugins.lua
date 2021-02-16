_G.kris.plugins = {}
local api = vim.api
local utils = require'partials/utils'
vim.cmd [[packadd vim-packager]]

require('packager').setup(function(packager)
 packager.add('kristijanhusak/vim-packager', { type = 'opt' })
 packager.add('kristijanhusak/vim-js-file-import', { ['do'] = 'npm install', type = 'opt' })
 packager.add('vimwiki/vimwiki', { type = 'opt' })
 packager.add('b3nj5m1n/kommentary')
 packager.add('tpope/vim-surround')
 packager.add('tpope/vim-repeat')
 packager.add('tpope/vim-fugitive')
 packager.add('tpope/vim-sleuth')
 packager.add('kristijanhusak/vim-create-pr')
 packager.add('kristijanhusak/vim-dadbod')
 packager.add('kristijanhusak/vim-dadbod-completion', { requires = 'kristijanhusak/vim-dadbod' })
 packager.add('kristijanhusak/vim-dadbod-ui', { requires = 'kristijanhusak/vim-dadbod' })
 packager.add('lambdalisue/reword.vim')
 packager.add('AndrewRadev/tagalong.vim')
 packager.add('AndrewRadev/splitjoin.vim')
 packager.add('lewis6991/gitsigns.nvim', { requires = 'nvim-lua/plenary.nvim' })
 packager.add('nvim-telescope/telescope.nvim', { requires = {'nvim-lua/popup.nvim'} })
 packager.add('sheerun/vim-polyglot')
 packager.add('ludovicchabant/vim-gutentags')
 packager.add('editorconfig/editorconfig-vim')
 packager.add('andymass/vim-matchup')
 packager.add('haya14busa/vim-asterisk')
 packager.add('osyo-manga/vim-anzu')
 packager.add('stefandtw/quickfix-reflector.vim')
 packager.add('wakatime/vim-wakatime')
 packager.add('windwp/nvim-autopairs')
 packager.add('neovim/nvim-lspconfig')
 packager.add('nvim-treesitter/nvim-treesitter')
 packager.add('nvim-treesitter/nvim-treesitter-refactor')
 packager.add('nvim-treesitter/nvim-treesitter-textobjects')
 packager.add('nvim-treesitter/playground')
 packager.add('hrsh7th/vim-vsnip')
 packager.add('hrsh7th/vim-vsnip-integ')
 packager.add('kyazdani42/nvim-tree.lua', { requires = 'kyazdani42/nvim-web-devicons' })
 packager.add('kristijanhusak/any-jump.vim')
 packager.add('tommcdo/vim-exchange')
 packager.add('unblevable/quick-scope')
 packager.add('hrsh7th/nvim-compe')
 packager.add('sainnhe/edge')
 packager.add('kristijanhusak/line-notes.nvim')
 packager.add('glepnir/lspsaga.nvim')
 packager.add('puremourning/vimspector')
 packager.add('kosayoda/nvim-lightbulb')
end)

vim.g.mapleader = ','

vim.cmd[[augroup packager_filetype]]
  vim.cmd[[autocmd!]]
  vim.cmd[[autocmd FileType javascript,javascriptreact,typescript,typescriptreact packadd vim-js-file-import]]
  vim.cmd[[autocmd FileType NvimTree call v:lua.kris.plugins.setup_nvimtree() ]]
  vim.cmd[[autocmd VimEnter * call v:lua.kris.plugins.handle_vimenter() ]]
vim.cmd[[augroup END]]

function _G.kris.plugins.setup_nvimtree()
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

utils.keymap('n', '<Leader>G', ':vert G<CR>')

utils.keymap('n', '<Leader>n', ':NvimTreeToggle<CR>')
utils.keymap('n', '<Leader>hf', ':NvimTreeFindFile<CR>')

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

require'line-notes'.setup({
  path = vim.fn.expand('~/Dropbox/line-notes.json')
})
require'nvim-autopairs'.setup()
require'kommentary.config'.configure_language('default', {
  prefer_single_line_comments = true,
  ignore_whitespace = true,
  use_consistent_indentation = true,
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
vim.g.nvim_tree_disable_netrw = 0

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

vim.g.db_ui_save_location = '~/Dropbox/dbui'
vim.g.db_ui_tmp_query_location = '~/code/queries'

vim.g.sql_type_default = 'pgsql'

vim.g.qs_second_highlight = 0
vim.g.qs_highlight_on_keys = {'f', 'F', 't', 'T'}

vim.g.vsnip_filetypes = {
  typescript = {'javascript'}
}
