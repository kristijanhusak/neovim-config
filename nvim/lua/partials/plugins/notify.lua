local notify = {
  install = function(packager)
    return packager.add('rcarriga/nvim-notify')
  end,
}
notify.setup = function()
  local n = require('notify')
  n.setup({
    top_down = false,
    render = 'minimal',
  })
  vim.notify = n
  return notify
end

return notify
