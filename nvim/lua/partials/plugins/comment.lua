local comment = {
  'numToStr/Comment.nvim',
}
comment.config = function()
  require('Comment').setup()
  -- Comment map
  vim.keymap.set('n', '<Leader>c', 'gcc', { remap = true })
  -- Line comment command
  vim.keymap.set('v', '<Leader>c', 'gc', { remap = true })
end

return comment
