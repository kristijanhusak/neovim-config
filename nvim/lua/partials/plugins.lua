local plugins = {}
vim.g.mapleader = ','

local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
    vim.cmd([[packadd packer.nvim]])
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

local custom_plugins = {
  'wbthomason/packer.nvim',
  'tpope/vim-repeat',
  'tpope/vim-sleuth',
  'tpope/vim-abolish',
  'tpope/vim-surround',
  'windwp/nvim-ts-autotag',
  'nvim-lua/plenary.nvim',
  'ludovicchabant/vim-gutentags',
  'stefandtw/quickfix-reflector.vim',
  'wakatime/vim-wakatime',
  'Raimondi/delimitMate',
  'lewis6991/impatient.nvim',
}

local plugins_dir = ('%s/lua/partials/plugins'):format(vim.fn.stdpath('config'))

for file in vim.fs.dir(plugins_dir) do
  local stat = vim.loop.fs_stat(('%s/%s'):format(plugins_dir, file))
  if stat and stat.type == 'file' then
    table.insert(custom_plugins, require(('partials.plugins.%s'):format(file:sub(0, -5))))
  end
end

require('packer').startup({
  custom_plugins,
})

if packer_bootstrap then
  vim.cmd([[PackerSync]])
end

vim.g.delimitMate_expand_cr = 1

_G.kris.plugins = plugins
