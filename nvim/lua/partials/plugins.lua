local plugins = {}
vim.cmd([[packadd vim-packager]])
vim.g.mapleader = ','

local custom_plugins = {
  'partials.plugins.notify',
  'partials.plugins.treesitter',
  'partials.plugins.lsp',
  'partials.plugins.colorscheme',
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
  'partials.plugins.completion',
  'partials.plugins.folds',
  'partials.plugins.db',
  'partials.plugins.vimspector',
  'partials.plugins.javascript',
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

  packager.add('tpope/vim-repeat')
  packager.add('tpope/vim-sleuth')
  packager.add('tpope/vim-abolish')
  packager.add('windwp/nvim-ts-autotag')
  packager.add('AndrewRadev/splitjoin.vim')
  packager.add('nvim-lua/plenary.nvim')
  packager.add('ludovicchabant/vim-gutentags')
  packager.add('stefandtw/quickfix-reflector.vim')
  packager.add('wakatime/vim-wakatime')
  packager.add('Raimondi/delimitMate')
  packager.add('lewis6991/impatient.nvim')
  packager.add('antoinemadec/FixCursorHold.nvim')
  packager.add('https://gitlab.com/yorickpeterse/nvim-pqf')
end)

require('partials.plugins.custom')

vim.g.delimitMate_expand_cr = 1

_G.kris.plugins = plugins
