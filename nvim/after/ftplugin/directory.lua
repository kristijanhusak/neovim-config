if not vim.g.builtin_dir then
  return
end

local dir = require('partials.custom_plugins.dir')

vim.api.nvim_create_autocmd('TextChanged', {
  buffer = 0,
  callback = function(event)
    dir.attach(event.buf)
  end,
})
