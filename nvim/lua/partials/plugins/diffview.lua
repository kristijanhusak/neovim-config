local diffview = {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory' },
}
diffview.init = function()
  vim.keymap.set('n', '<leader>do', function()
    if vim.t.diffview_view_initialized then
      return vim.cmd.DiffviewClose()
    end
    return vim.cmd.DiffviewOpen()
  end, { silent = true, desc = 'Toggle diffview' })
  vim.keymap.set('n', '<leader>dh', ':DiffviewFileHistory %<CR>', { silent = true, desc = 'Diffview file history' })
  vim.keymap.set('n', '<leader>dc', function()
    vim.cmd.DiffviewClose()
    vim.cmd('botright Git commit')
  end, { silent = true, desc = 'Git commit' })
  vim.keymap.set('n', '<leader>da', function()
    vim.cmd.DiffviewClose()
    vim.cmd('botright Git commit --amend')
  end, { silent = true, desc = 'Git commit --amend' })
  vim.keymap.set('n', '<leader>dp', ':Git push<CR>', { silent = true, desc = 'Git push' })
  vim.keymap.set(
    'n',
    '<leader>df',
    ':Git push --force-with-lease<CR>',
    { silent = true, desc = 'Git push --force-with-lease' }
  )
end

return diffview
