local plugins = {}
local api = vim.api
local utils = require'partials/utils'
vim.cmd [[packadd vim-packager]]

require('packager').setup(function(packager)
 packager.add('kristijanhusak/vim-packager', { type = 'opt' })
 packager.add('kristijanhusak/vim-js-file-import', { ['do'] = 'npm install', type = 'opt' })
 packager.add('b3nj5m1n/kommentary')
 packager.add('tpope/vim-surround')
 packager.add('tpope/vim-repeat')
 packager.add('tpope/vim-fugitive')
 packager.add('tpope/vim-sleuth')
 packager.add('kristijanhusak/vim-dadbod', { branch = 'async-query' })
 packager.add('kristijanhusak/vim-dadbod-completion', { type = 'opt', branch = 'async' })
 packager.add('kristijanhusak/vim-dadbod-ui', { branch = 'async' })
 packager.add('kristijanhusak/orgmode.nvim')
 packager.add('lambdalisue/reword.vim')
 packager.add('AndrewRadev/tagalong.vim')
 packager.add('AndrewRadev/splitjoin.vim')
 packager.add('lewis6991/gitsigns.nvim', { requires = 'nvim-lua/plenary.nvim' })
 packager.add('junegunn/fzf', { ['do'] = './install --all && ln -sf $(pwd) ~/.fzf' })
 packager.add('junegunn/fzf.vim')
 packager.add('ludovicchabant/vim-gutentags')
 packager.add('editorconfig/editorconfig-vim')
 packager.add('andymass/vim-matchup')
 packager.add('haya14busa/vim-asterisk')
 packager.add('stefandtw/quickfix-reflector.vim')
 packager.add('wakatime/vim-wakatime')
 packager.add('neovim/nvim-lspconfig')
 packager.add('ray-x/lsp_signature.nvim')
 packager.add('nvim-treesitter/nvim-treesitter')
 packager.add('nvim-treesitter/nvim-treesitter-refactor')
 packager.add('nvim-treesitter/nvim-treesitter-textobjects')
 packager.add('hrsh7th/vim-vsnip')
 packager.add('kyazdani42/nvim-tree.lua', { requires = 'kyazdani42/nvim-web-devicons' })
 packager.add('hrsh7th/nvim-compe')
 packager.add('puremourning/vimspector')
 packager.add('lukas-reineke/indent-blankline.nvim')
 packager.add('Raimondi/delimitMate')
 packager.add('folke/lua-dev.nvim')
 packager.add('RRethy/nvim-base16')
 packager.add('projekt0n/github-nvim-theme')
end)

vim.g.mapleader = ','

vim.cmd[[augroup packager_filetype]]
  vim.cmd[[autocmd!]]
  vim.cmd[[autocmd FileType javascript,javascriptreact,typescript,typescriptreact packadd vim-js-file-import]]
  vim.cmd[[autocmd FileType NvimTree call v:lua.kris.plugins.setup_nvimtree() ]]
  vim.cmd[[autocmd FileType sql packadd vim-dadbod-completion | runtime after/plugin/vim_dadbod_completion.vim]]
  vim.cmd[[autocmd VimEnter * call v:lua.kris.plugins.handle_vimenter() ]]
vim.cmd[[augroup END]]

function plugins.setup_nvimtree()
  local buf = api.nvim_get_current_buf()
  utils.buf_keymap(buf, 'n', 'j', 'line(".") == line("$") ? "gg" : "j"', { expr = true })
  utils.buf_keymap(buf, 'n', 'k', 'line(".") == 1 ? "G" : "k"', { expr = true })
  vim.defer_fn(function()
    api.nvim_feedkeys(api.nvim_replace_termcodes('<C-w>w', true, false, true), 'n', true)
  end, 0)
end

function plugins.handle_vimenter()
  vim.g.vsnip_snippet_dir = vim.fn.fnamemodify(vim.env.MYVIMRC, ':p:h')..'/snippets'
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

require'gitsigns'.setup({
  signs = {
    add          = { text = '▌'},
    change       = { text = '▌'},
    delete       = { text = '_'},
    topdelete    = { text = '‾'},
    changedelete = { text = '▌'},
  },
})

require'kommentary.config'.configure_language('default', {
  prefer_single_line_comments = true,
  ignore_whitespace = true,
  use_consistent_indentation = true,
})

require('orgmode').setup(require('partials.orgmode_config'))

vim.g.nvim_tree_bindings = {
  { key = {'s'}, cb = ':lua require"nvim-tree".on_keypress("vsplit")<CR>' },
  { key = {'C'}, cb = ':lua require"nvim-tree".on_keypress("cd")<CR>'}
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
vim.g.nvim_tree_hijack_cursor = 0
vim.g.nvim_tree_update_cwd = 0

vim.g.matchup_matchparen_status_offscreen = 0
vim.g.matchup_matchparen_nomode = "ivV"

vim.g.db_ui_show_help = 0
vim.g.db_ui_win_position = 'right'
vim.g.db_ui_use_nerd_fonts = 1

vim.g.db_ui_save_location = '~/Dropbox/dbui'
vim.g.db_ui_tmp_query_location = '~/code/queries'

vim.g.vsnip_filetypes = {
  typescript = {'javascript'}
}

vim.g.js_file_import_use_fzf = 1

vim.g.indent_blankline_char = '▏'
vim.g.indent_blankline_show_current_context = true
vim.g.indent_blankline_context_patterns = {'class', 'function', 'method', '^if', '^while', '^for', '^object', '^table', 'block', 'arguments'}

_G.kris.plugins = plugins
