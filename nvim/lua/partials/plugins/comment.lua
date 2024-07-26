return {
  'numToStr/Comment.nvim',
  keys = {
    '<leader>c',
    'gcip',
    {
      '<leader>c',
      mode = 'v',
    },
  },
  config = function()
    require('Comment').setup()
    -- Comment map
    vim.keymap.set('n', '<Leader>c', 'gcc', { remap = true, desc = 'Comment line' })
    -- Line comment command
    vim.keymap.set('v', '<Leader>c', 'gc', { remap = true, desc = 'Comment selection' })
  end,
}
