if not vim.g.builtin_dir then
  return
end

local dir = require('partials.custom_plugins.dir')
dir.global_mappings()
