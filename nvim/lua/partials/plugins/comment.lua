return {
  'numToStr/Comment.nvim',
  cond = function()
    local ok = pcall(require, 'vim._comment')
    return not ok
  end,
  event = 'VeryLazy',
  config = function()
    print('setup')
    require('Comment').setup()
    -- Comment map
    vim.keymap.set('n', '<Leader>c', 'gcc', { remap = true })
    -- Line comment command
    vim.keymap.set('v', '<Leader>c', 'gc', { remap = true })
  end,
}
