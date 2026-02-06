require('partials.utils.pack')

local plugins = require('partials.plugins')

for plugin in ipairs(plugins) do
  vim.pack.load(plugins[plugin])
end

vim.pack.dir('./plugins')
