vim.keymap.set('n', '<Leader>gf', ':vert G<CR>', { silent = true, desc = 'Open fugitive' })

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
