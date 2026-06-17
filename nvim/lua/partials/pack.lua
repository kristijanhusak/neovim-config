require('partials.utils.pack')

local plugins = require('partials.plugins')

for plugin in ipairs(plugins) do
  vim.pack.load(plugins[plugin])
end

local cur_file_dir = vim.fs.dirname(debug.getinfo(1, 'S').source:sub(2))
local plugins_path = vim.fs.joinpath(cur_file_dir, 'plugins')
local handle = vim.loop.fs_scandir(plugins_path)

if not handle then
  error('Could not scan plugins directory')
end

while true do
  local name = vim.loop.fs_scandir_next(handle)
  if not name then
    break
  end
  vim.pack.load(require(('partials.plugins.%s'):format(name:gsub('%.lua$', ''))))
end

vim.pack.init()
