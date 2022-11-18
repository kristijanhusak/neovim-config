local gitlinker = {
  install = function(packager)
    return packager.add('ruifm/gitlinker.nvim')
  end,
}
gitlinker.setup = function()
  require('gitlinker').setup({
    opts = {
      action_callback = require('gitlinker.actions').open_in_browser,
    },
    mappings = '<leader>yg',
  })
  return gitlinker
end

return gitlinker
