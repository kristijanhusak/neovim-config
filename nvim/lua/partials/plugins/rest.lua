return {
  'rest-nvim/rest.nvim',
  event = 'VeryLazy',
  init = function()
    vim.api.nvim_create_autocmd('BufWritePost', {
      pattern = '*.http',
      command = 'Rest run',
    })
  end,
}
