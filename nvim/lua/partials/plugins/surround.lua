local surround = {
  install = function(packager)
    return packager.add('kylechui/nvim-surround')
  end,
}
surround.setup = function()
  require('nvim-surround').setup()
  return surround
end

return surround
