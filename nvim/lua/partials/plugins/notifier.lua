local notifier = {
  install = function(packager)
    return packager.add('vigoux/notifier.nvim')
  end,
}
notifier.setup = function()
  require('notifier').setup({
    components = { 'lsp' },
  })
  return notifier
end

return notifier
