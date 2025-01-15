local diffview = {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory' },
}
diffview.init = function()
  vim.keymap.set('n', '<leader>gd', function()
    if vim.t.diffview_view_initialized then
      return vim.cmd.DiffviewClose()
    end
    return vim.cmd.DiffviewOpen()
  end, { silent = true, desc = 'Toggle diffview' })
  vim.keymap.set('n', '<leader>ghh', ':DiffviewFileHistory %<CR>', { silent = true, desc = 'Diffview file history' })
  vim.keymap.set('n', '<leader>gc', function()
    vim.cmd.DiffviewClose()
    vim.cmd('botright Git commit')
  end, { silent = true, desc = 'Git commit' })
  vim.keymap.set('n', '<leader>ga', function()
    vim.cmd.DiffviewClose()
    vim.cmd('botright Git commit --amend')
  end, { silent = true, desc = 'Git commit --amend' })
  vim.keymap.set('n', '<leader>gp', ':Git push<CR>', { silent = true, desc = 'Git push' })
  vim.keymap.set(
    'n',
    '<leader>gF',
    ':Git push --force-with-lease<CR>',
    { silent = true, desc = 'Git push --force-with-lease' }
  )
end

return diffview
