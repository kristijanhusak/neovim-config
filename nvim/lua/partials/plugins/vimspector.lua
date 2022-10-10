local vimspector = {
  install = function(packager)
    return packager.add('puremourning/vimspector')
  end,
}
vimspector.setup = function()
  vim.keymap.set('n', '<F1>', '<Plug>VimspectorToggleBreakpoint')
  vim.keymap.set('n', '<F2>', '<Plug>VimspectorToggleConditionalBreakpoint')
  vim.keymap.set('n', '<F3>', '<Plug>VimspectorAddFunctionBreakpoint')
  vim.keymap.set('n', '<F4>', '<Plug>VimspectorRunToCursor')
  vim.keymap.set('n', '<F5>', '<Plug>VimspectorContinue')
  vim.keymap.set('n', '<Right>', '<Plug>VimspectorStepOver')
  vim.keymap.set('n', '<Up>', '<Plug>VimspectorStepOut')
  vim.keymap.set('n', '<Down>', '<Plug>VimspectorStepInto')

  vim.api.nvim_create_user_command('VimspectorPause', 'vimspector#Pause()', { force = true })
  vim.api.nvim_create_user_command('VimspectorStop', 'vimspector#Stop()', { force = true })

  return vimspector
end

return vimspector
