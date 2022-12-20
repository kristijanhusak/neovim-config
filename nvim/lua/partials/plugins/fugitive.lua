local fugitive = {
  'tpope/vim-fugitive',
  event = 'VeryLazy',
}
fugitive.config = function()
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
  vim.keymap.set('n', '<Leader>G', ':vert G<CR>', { silent = true })

  return fugitive
end

return fugitive
