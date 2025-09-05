vim.pack.on_event({
  src = 'axelvc/template-string.nvim',
  event = 'FileType',
  pattern = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  config = function()
    require('template-string').setup({
      remove_template_string = true,
    })
  end,
})
