require('partials.utils.pack')

local plugins = require('partials.plugins')

for _, plugin in ipairs(plugins) do
  vim.pack.load(plugin)
end

local cur_file_dir = vim.fs.dirname(debug.getinfo(1, 'S').source:sub(2))
local plugins_path = vim.fs.joinpath(cur_file_dir, 'plugins')
local handle = vim.uv.fs_scandir(plugins_path)

if not handle then
  error('Could not scan plugins directory')
end

-- Sort to keep the registration order deterministic
local plugin_files = {}
while true do
  local name = vim.uv.fs_scandir_next(handle)
  if not name then
    break
  end
  table.insert(plugin_files, name)
end
table.sort(plugin_files)

for _, name in ipairs(plugin_files) do
  vim.pack.load(require(('partials.plugins.%s'):format(name:gsub('%.lua$', ''))))
end

vim.pack.init()
