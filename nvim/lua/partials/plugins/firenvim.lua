return {
  'glacambre/firenvim',
  lazy = not vim.g.started_by_firenvim,
  build = function()
    vim.fn['firenvim#install'](0)
  end,
  init = function()
    vim.api.nvim_create_autocmd({ 'BufEnter' }, {
      group = vim.api.nvim_create_augroup('firenvim', { clear = true }),
      pattern = { 'github.com_*.txt', 'app.asana.com*.txt' },
      command = 'set filetype=markdown',
    })

    vim.g.firenvim_config = {
      localSettings = {
        ['.*'] = {
          takeover = 'never',
        },
        ['^https?://app.asana.com/*'] = {
          selector = '.ProseMirror',
        },
      },
    }
  end,
}
