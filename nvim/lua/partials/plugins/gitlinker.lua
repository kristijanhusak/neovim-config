local gitlinker = {
  install = function(packager)
    return packager.add('ruifm/gitlinker.nvim')
  end,
}
gitlinker.setup = function()
  require"gitlinker".setup()
  return gitlinker
end

return gitlinker
