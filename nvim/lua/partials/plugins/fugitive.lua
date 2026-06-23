vim.keymap.set('n', '<Leader>gf', ':vert G<CR>', { silent = true, desc = 'Open fugitive' })
vim.keymap.set('n', '<leader>gc', function()
  vim.cmd('botright Git commit')
end, { silent = true, desc = 'Git commit' })
vim.keymap.set('n', '<leader>ga', function()
  vim.cmd('botright Git commit --amend')
end, { silent = true, desc = 'Git commit --amend' })
vim.keymap.set('n', '<leader>gp', ':Git push<CR>', { silent = true, desc = 'Git push' })
vim.keymap.set(
  'n',
  '<leader>gF',
  ':Git push --force-with-lease<CR>',
  { silent = true, desc = 'Git push --force-with-lease' }
)

vim.keymap.set('n', '<leader>gd', function()
  vim.cmd.tabnew(vim.api.nvim_buf_get_name(0))
  vim.cmd('Gclog --follow %')
end, { silent = true, desc = 'Show file git history' })

local git_group = vim.api.nvim_create_augroup('custom_fugitive', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'fugitive',
  callback = function()
    vim.keymap.set('n', '<Space>', '=zt', { remap = true, silent = true, buffer = true })
    vim.keymap.set('n', '}', ']m=zt', { remap = true, silent = true, buffer = true })
    vim.keymap.set('n', '{', '[m=zt', { remap = true, silent = true, buffer = true })
  end,
  group = git_group,
})

return {
  'tpope/vim-fugitive',
  cmd = { 'G', 'Git', 'Gdiffsplit', 'Gclog', 'GcLog', 'Gread' },
}
