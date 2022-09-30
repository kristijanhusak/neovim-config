local plugins = {}
vim.cmd([[packadd vim-packager]])
vim.g.mapleader = ','

local custom_plugins = {
  'partials.plugins.treesitter',
  'partials.plugins.orgmode',
  'partials.plugins.comment',
  'partials.plugins.surround',
  'partials.plugins.fugitive',
  'partials.plugins.template_string',
  'partials.plugins.gitsigns',
  'partials.plugins.telescope',
  'partials.plugins.nvim_tree',
  'partials.plugins.indent_blankline',
  'partials.plugins.pqf',
  'partials.plugins.notifier',
  'partials.plugins.completion',
}

local plugin_errors = {}
for _, plugin in ipairs(custom_plugins) do
  local ok = pcall(require(plugin).setup)
  if not ok then
    table.insert(plugin_errors, plugin)
  end
end

if #plugin_errors > 0 then
  vim.notify(('Error loading plugins:\n%s'):format(table.concat(plugin_errors, '\n')), vim.log.levels.WARN)
end

require('packager').setup(function(packager)
  packager.add('kristijanhusak/vim-packager', { type = 'opt' })

  for _, plugin in ipairs(custom_plugins) do
    require(plugin).install(packager)
  end

  packager.add('kristijanhusak/vim-js-file-import', { ['do'] = 'npm install', type = 'opt' })
  packager.add('tpope/vim-repeat')
  packager.add('tpope/vim-sleuth')
  packager.add('tpope/vim-dadbod')
  packager.add('tpope/vim-abolish')
  packager.add('kristijanhusak/vim-dadbod-completion', { type = 'opt' })
  packager.add('kristijanhusak/vim-dadbod-ui')
  packager.add('windwp/nvim-ts-autotag')
  packager.add('AndrewRadev/splitjoin.vim')
  packager.add('nvim-lua/plenary.nvim')
  packager.add('ludovicchabant/vim-gutentags')
  packager.add('andymass/vim-matchup')
  packager.add('haya14busa/vim-asterisk')
  packager.add('stefandtw/quickfix-reflector.vim')
  packager.add('wakatime/vim-wakatime')
  packager.add('neovim/nvim-lspconfig')
  packager.add('hrsh7th/vim-vsnip')
  packager.add('puremourning/vimspector')
  packager.add('Raimondi/delimitMate')
  packager.add('lewis6991/impatient.nvim')
  packager.add('rmehri01/onenord.nvim')
  packager.add('jose-elias-alvarez/null-ls.nvim')
  packager.add('SmiteshP/nvim-navic')
  packager.add('antoinemadec/FixCursorHold.nvim')
  packager.add('jose-elias-alvarez/typescript.nvim')
  packager.add('https://gitlab.com/yorickpeterse/nvim-pqf')
  packager.add('github/copilot.vim')
  packager.add('sindrets/diffview.nvim')
end)

local plugins_group = vim.api.nvim_create_augroup('packager_filetype', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  command = [[packadd vim-js-file-import | exe 'runtime ftplugin/'.&ft.'.vim']],
  group = plugins_group,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'sql',
  command = 'packadd vim-dadbod-completion | runtime after/plugin/vim_dadbod_completion.lua',
  group = plugins_group,
})
vim.g.vsnip_snippet_dir = vim.fn.fnamemodify(vim.env.MYVIMRC, ':p:h') .. '/snippets'

vim.keymap.set('n', '<Leader><space>', ':noh<CR>')

vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')
vim.keymap.set('', '*', '<Plug>(asterisk-z*)')
vim.keymap.set('', '#', '<Plug>(asterisk-z#)')
vim.keymap.set('', 'g*', '<Plug>(asterisk-gz*)')
vim.keymap.set('', 'g#', '<Plug>(asterisk-gz#)')

vim.keymap.set('n', '<Leader>G', ':vert G<CR>', { silent = true })

vim.keymap.set('n', '<leader>do', function()
  if vim.t.diffview_view_initialized then
    return vim.cmd('DiffviewClose')
  end
  return vim.cmd('DiffviewOpen')
end, { silent = true })
vim.keymap.set('n', '<leader>dh', ':DiffviewFileHistory %<CR>', { silent = true })
vim.keymap.set('n', '<leader>dc', function()
  vim.cmd([[DiffviewClose]])
  vim.cmd([[botright Git commit]])
end, { silent = true })
vim.keymap.set('n', '<leader>da', function()
  vim.cmd([[DiffviewClose]])
  vim.cmd([[botright Git commit --amend]])
end, { silent = true })
vim.keymap.set('n', '<leader>dp', ':Git push<CR>', { silent = true })
vim.keymap.set('n', '<leader>df', ':Git push --force-with-lease<CR>', { silent = true })

vim.g.matchup_matchparen_status_offscreen = 0
vim.g.matchup_matchparen_nomode = 'ivV'
vim.g.matchup_matchparen_deferred = 100

vim.g.db_ui_show_help = 0
vim.g.db_ui_win_position = 'right'
vim.g.db_ui_use_nerd_fonts = 1

vim.g.db_ui_save_location = '~/Dropbox/dbui'
vim.g.db_ui_tmp_query_location = '~/code/queries'

vim.g.vsnip_filetypes = {
  typescript = { 'javascript' },
  typescriptreact = { 'javascript' },
  javascriptreact = { 'javascript' },
}

vim.g.js_file_import_use_telescope = 1

vim.g.delimitMate_expand_cr = 1

vim.g.db_ui_hide_schemas = { 'pg_toast_temp.*' }

vim.g.copilot_no_tab_map = true
vim.keymap.set('i', '<Plug>(vimrc:copilot-map)', [[copilot#Accept("\<Tab>")]], {
  expr = true,
  remap = true,
})

vim.g.copilot_filetypes = {
  TelescopePrompt = false,
  TelescopeResults = false,
}

vim.env.GIT_EDITOR = "nvr -cc tabedit --remote-wait +'set bufhidden=wipe'"

_G.kris.plugins = plugins
