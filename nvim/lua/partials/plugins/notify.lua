local notify = {
  'rcarriga/nvim-notify',
  after = 'onenord.nvim'
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
