local notify = {
  install = function(packager)
    return packager.add('rcarriga/nvim-notify')
  end,
}
notify.setup = function()
  vim.notify = require('notify')
  return notify
end

return notify
