return {
  'axelvc/template-string.nvim',
  ft = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  config = function()
    require('template-string').setup({
      remove_template_string = true,
    })
  end,
}
