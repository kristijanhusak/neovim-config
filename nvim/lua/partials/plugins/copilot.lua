local copilot = {
  install = function(packager)
    return packager.add('github/copilot.vim')
  end,
}
copilot.setup = function()
  vim.g.copilot_no_tab_map = true
  vim.keymap.set('i', '<Plug>(vimrc:copilot-map)', [[copilot#Accept("\<Tab>")]], {
    expr = true,
    remap = true,
  })

  vim.g.copilot_filetypes = {
    TelescopePrompt = false,
    TelescopeResults = false,
  }

  return copilot
end

return copilot
