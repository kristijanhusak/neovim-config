local rest = {
  'mistweaverco/kulala.nvim',
  ft = { 'http' },
  config = function()
    require('kulala').setup({
      ui = {
        show_request_summary = false
      }
    })
    vim.api.nvim_create_autocmd('BufWritePost', {
      pattern = '*.http',
      callback = function()
        require('kulala').run()
      end,
    })
  end,
}

return rest
