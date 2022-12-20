local template_string = {
  'axelvc/template-string.nvim',
  ft = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
}
template_string.config = function()
  require('template-string').setup({
    remove_template_string = true,
  })
  return template_string
end

return template_string
