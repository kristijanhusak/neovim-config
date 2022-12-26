return {
  'numToStr/Comment.nvim',
  event = 'VeryLazy',
  init = function()
    -- Comment map
    vim.keymap.set('n', '<Leader>c', 'gcc', { remap = true })
    -- Line comment command
    vim.keymap.set('v', '<Leader>c', 'gc', { remap = true })
  end,
  config = {},
}
