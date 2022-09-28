local pqf = {
  install = function(packager)
    return packager.add('https://gitlab.com/yorickpeterse/nvim-pqf')
  end,
}
pqf.setup = function()
  require('pqf').setup()
  return pqf
end

return pqf
