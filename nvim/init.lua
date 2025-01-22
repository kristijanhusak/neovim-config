_G.kris = {}

local ok, err = pcall(require, 'main')
if not ok then
  vim.notify('Error loading main.lua, loading fallback.\n' .. err)
  vim.cmd.runtime('minvimrc.vim')
end
