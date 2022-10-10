local asterisk = {
  install = function(packager)
    return packager.add('haya14busa/vim-asterisk')
  end,
}
asterisk.setup = function()
  vim.keymap.set('', '*', '<Plug>(asterisk-z*)')
  vim.keymap.set('', '#', '<Plug>(asterisk-z#)')
  vim.keymap.set('', 'g*', '<Plug>(asterisk-gz*)')
  vim.keymap.set('', 'g#', '<Plug>(asterisk-gz#)')
  return asterisk
end

return asterisk
