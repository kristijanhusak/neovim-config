local notify = {
  'rcarriga/nvim-notify',
  lazy = true,
}
notify.config = function()
  local n = require('notify')
  n.setup({
    top_down = false,
    render = 'minimal',
  })
  vim.notify = n
  return notify
end

return notify
