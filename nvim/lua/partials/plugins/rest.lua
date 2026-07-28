local rest = {
  'mistweaverco/kulala.nvim',
  ft = { 'http' },
  config = function()
    require('kulala').setup({
      ui = {
        show_request_summary = false,
      },
    })
    vim.api.nvim_create_autocmd('BufWritePost', {
      pattern = '*.http',
      callback = function()
        require('kulala').run()
      end,
    })

    vim.api.nvim_create_user_command('RestCopyCurl', function()
      require('kulala').copy()
    end)
  end,
}

return rest
