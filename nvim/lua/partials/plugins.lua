local plugins = {}
vim.cmd([[packadd vim-packager]])
vim.g.mapleader = ','

local custom_plugins = {}

local plugins_dir = ('%s/lua/partials/plugins'):format(vim.fn.stdpath('config'))
for file in vim.fs.dir(plugins_dir) do
  local stat = vim.loop.fs_stat(('%s/%s'):format(plugins_dir, file))
  if stat and stat.type == 'file' then
    table.insert(custom_plugins, ('partials.plugins.%s'):format(file:sub(0, -5)))
  end
end

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
