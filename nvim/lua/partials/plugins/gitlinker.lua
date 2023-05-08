local gitlinker = {
  'ruifm/gitlinker.nvim',
  lazy = true,
}

gitlinker.init = function()
  vim.keymap.set('n', '<leader>yg', function()
    return require('gitlinker').get_buf_range_url(
      'n',
      { action_callback = require('gitlinker.actions').open_in_browser }
    )
  end, { silent = true })

  vim.keymap.set('v', '<leader>yg', function()
    return require('gitlinker').get_buf_range_url(
      'v',
      { action_callback = require('gitlinker.actions').open_in_browser }
    )
  end, {})
end

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
