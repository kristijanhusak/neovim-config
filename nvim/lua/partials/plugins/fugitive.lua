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
  keys = {
    {
      '<leader>gf',
      function()
        vim.cmd('vert Git')
      end,
      desc = 'Open fugitive',
    },
    {
      '<leader>gc',
      function()
        vim.cmd('botright Git commit')
      end,
      desc = 'Git commit',
    },
    {
      '<leader>ga',
      function()
        vim.cmd('botright Git commit --amend')
      end,
      desc = 'Git commit --amend',
    },
    {
      '<leader>gF',
      function()
        vim.cmd('Git push --force-with-lease')
      end,
      desc = 'Git push --force-with-lease',
    },
    {
      '<leader>gd',
      function()
        vim.cmd.tabnew(vim.api.nvim_buf_get_name(0))
        vim.cmd('Gclog --follow %')
      end,
      desc = 'Show file git history',
    },
  },
  cmd = { 'G', 'Git', 'Gdiffsplit', 'Gclog', 'GcLog', 'Gread' },
}
