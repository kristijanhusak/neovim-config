local octo = {
  install = function(packager)
    return packager.add('pwntester/octo.nvim')
  end,
}
octo.setup = function()
  require('octo').setup()
  return octo
end

return octo
