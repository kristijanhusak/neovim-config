local filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }

local template_string = {
  'axelvc/template-string.nvim',
  ft = filetypes,
}
template_string.config = function()
  require('template-string').setup({
    remove_template_string = true,
  })
end

return template_string
