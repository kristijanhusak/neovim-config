if not vim.g.builtin_dir then
  return
end

local dir = require('partials.custom_plugins.dir')
dir.attach(vim.api.nvim_get_current_buf())

vim.api.nvim_create_autocmd('TextChanged', {
  buffer = 0,
  callback = function()
    dir.attach(vim.api.nvim_get_current_buf())
  end,
})
