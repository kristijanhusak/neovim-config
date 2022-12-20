local gitlinker = {
  'ruifm/gitlinker.nvim',
  keys = { '<leader>gy' },
}
gitlinker.config = function()
  require('gitlinker').setup({
    opts = {
      action_callback = require('gitlinker.actions').open_in_browser,
    },
    mappings = '<leader>yg',
  })
  return gitlinker
end

return gitlinker
