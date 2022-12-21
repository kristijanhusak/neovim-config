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
  end, { silent = true })
  vim.keymap.set('n', '<leader>dh', ':DiffviewFileHistory %<CR>', { silent = true })
  vim.keymap.set('n', '<leader>dc', function()
    vim.cmd.DiffviewClose()
    vim.cmd('botright Git commit')
  end, { silent = true })
  vim.keymap.set('n', '<leader>da', function()
    vim.cmd.DiffviewClose()
    vim.cmd('botright Git commit --amend')
  end, { silent = true })
  vim.keymap.set('n', '<leader>dp', ':Git push<CR>', { silent = true })
  vim.keymap.set('n', '<leader>df', ':Git push --force-with-lease<CR>', { silent = true })
end

return diffview
