local template_string = {
  install = function(packager)
    return packager.add('axelvc/template-string.nvim')
  end,
}
template_string.setup = function()
  require('template-string').setup({
    remove_template_string = true,
  })
  return template_string
end

return template_string
