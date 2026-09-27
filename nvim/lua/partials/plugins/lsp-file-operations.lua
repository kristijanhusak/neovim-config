return {
  'antosha417/nvim-lsp-file-operations',
  event = 'VeryLazy',
  config = function()
    require('lsp-file-operations').setup()
  end,
}
