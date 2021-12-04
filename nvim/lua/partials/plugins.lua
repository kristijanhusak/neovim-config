local plugins = {}
local api = vim.api
local utils = require('partials/utils')
vim.cmd([[packadd vim-packager]])

require('packager').setup(function(packager)
  packager.add('kristijanhusak/vim-packager', { type = 'opt' })
  packager.add('kristijanhusak/vim-js-file-import', { ['do'] = 'npm install', type = 'opt' })
  packager.add('numToStr/Comment.nvim')
  packager.add('tpope/vim-surround')
  packager.add('tpope/vim-repeat')
  packager.add('tpope/vim-fugitive')
  packager.add('tpope/vim-sleuth')
  packager.add('kristijanhusak/vim-dadbod', { branch = 'async-query' })
  packager.add('kristijanhusak/vim-dadbod-completion', { type = 'opt', branch = 'async' })
  packager.add('kristijanhusak/vim-dadbod-ui', { branch = 'async' })
  packager.add('nvim-orgmode/orgmode')
  packager.add('lambdalisue/reword.vim')
  packager.add('AndrewRadev/tagalong.vim')
  packager.add('AndrewRadev/splitjoin.vim')
  packager.add('lewis6991/gitsigns.nvim', { requires = 'nvim-lua/plenary.nvim' })
  packager.add('nvim-telescope/telescope.nvim')
  packager.add('ludovicchabant/vim-gutentags')
  packager.add('gpanders/editorconfig.nvim')
  packager.add('andymass/vim-matchup')
  packager.add('haya14busa/vim-asterisk')
  packager.add('stefandtw/quickfix-reflector.vim')
  packager.add('wakatime/vim-wakatime')
  packager.add('neovim/nvim-lspconfig')
  packager.add('nvim-treesitter/nvim-treesitter')
  packager.add('nvim-treesitter/nvim-treesitter-refactor')
  packager.add('nvim-treesitter/nvim-treesitter-textobjects')
  packager.add('nvim-treesitter/playground')
  packager.add('hrsh7th/vim-vsnip')
  packager.add('kyazdani42/nvim-tree.lua', { requires = 'kyazdani42/nvim-web-devicons' })
  packager.add('puremourning/vimspector')
  packager.add('lukas-reineke/indent-blankline.nvim')
  packager.add('Raimondi/delimitMate')
  packager.add('folke/lua-dev.nvim')
  packager.add('lewis6991/impatient.nvim')
  packager.add('RRethy/nvim-base16')
  packager.add('hrsh7th/nvim-cmp', {
    requires = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-vsnip',
      'quangnguyen30192/cmp-nvim-tags',
      'lukas-reineke/cmp-rg',
    },
  })
end)

vim.cmd([[packadd splitjoin.vim]])
vim.g.mapleader = ','

vim.cmd([[augroup packager_filetype]])
vim.cmd([[autocmd!]])
vim.cmd([[autocmd FileType javascript,javascriptreact,typescript,typescriptreact packadd vim-js-file-import]])
vim.cmd([[autocmd FileType sql packadd vim-dadbod-completion | runtime after/plugin/vim_dadbod_completion.lua]])
vim.cmd([[autocmd VimEnter * call v:lua.kris.plugins.handle_vimenter() ]])
vim.cmd([[augroup END]])

function plugins.handle_vimenter()
  vim.g.vsnip_snippet_dir = vim.fn.fnamemodify(vim.env.MYVIMRC, ':p:h') .. '/snippets'
  local stats = vim.loop.fs_stat(vim.fn.expand('%:p'))
  if not stats or stats.type == 'directory' then
    vim.cmd([[NvimTreeToggle]])
    vim.cmd([[wincmd p]])
  end
end

utils.keymap('n', '<Leader><space>', ':noh<CR>')

utils.keymap('n', 'n', 'nzz')
utils.keymap('n', 'N', 'Nzz')
utils.keymap('', '*', '<Plug>(asterisk-z*)', { noremap = false })
utils.keymap('', '#', '<Plug>(asterisk-z#)', { noremap = false })
utils.keymap('', 'g*', '<Plug>(asterisk-gz*)', { noremap = false })
utils.keymap('', 'g#', '<Plug>(asterisk-gz#)', { noremap = false })

utils.keymap('n', '<Leader>G', ':vert G<CR>')

utils.keymap('n', '<Leader>n', ':NvimTreeToggle<CR>')
utils.keymap('n', '<Leader>hf', ':NvimTreeFindFile<CR>')

require('gitsigns').setup({
  signs = {
    add = { text = '▌' },
    change = { text = '▌' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '▌' },
  },
  numhl = true,
})

require('Comment').setup()

require('orgmode').setup(require('partials.orgmode_config'))

vim.g.nvim_tree_icons = {
  default = '',
  git = {
    unstaged = '✹',
  },
}
vim.g.nvim_tree_git_hl = 1

require('nvim-tree').setup({
  disable_netrw = false,
  update_focused_file = {
    enable = true,
  },
  view = {
    auto_resize = true,
    mappings = {
      list = {
        { key = { 's' }, cb = ':lua require"nvim-tree".on_keypress("vsplit")<CR>' },
        { key = { 'C' }, cb = ':lua require"nvim-tree".on_keypress("cd")<CR>' },
        { key = { 'X' }, cb = ':lua require"nvim-tree".on_keypress("system_open")<CR>' },
      },
    },
  },
})

vim.g.matchup_matchparen_status_offscreen = 0
vim.g.matchup_matchparen_nomode = 'ivV'

vim.g.db_ui_show_help = 0
vim.g.db_ui_win_position = 'right'
vim.g.db_ui_use_nerd_fonts = 1

vim.g.db_ui_save_location = '~/Dropbox/dbui'
vim.g.db_ui_tmp_query_location = '~/code/queries'

vim.g.vsnip_filetypes = {
  typescript = { 'javascript' },
}

vim.g.js_file_import_use_telescope = 1

vim.g.delimitMate_expand_cr = 1

vim.g.indent_blankline_char = '▏'
vim.g.indent_blankline_show_current_context = true
vim.g.indent_blankline_context_patterns = {
  'class',
  'function',
  'method',
  '^if',
  '^while',
  '^for',
  '^object',
  '^table',
  'block',
  'arguments',
}

_G.kris.plugins = plugins
