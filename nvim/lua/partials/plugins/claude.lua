return {
  'coder/claudecode.nvim',
  event = 'VeryLazy',
  config = function()
    require('claudecode').setup({
      terminal = {
        provider = 'native',
      },
    })
    vim.keymap.set('n', '<leader>ac', '<cmd>ClaudeCode<CR>', { desc = 'Toggle Claude' })
    vim.keymap.set('n', '<leader>af', '<cmd>ClaudeCodeFocus<CR>', { desc = 'Focus Claude' })
    vim.keymap.set('n', '<leader>ar', '<cmd>ClaudeCode --resume<CR>', { desc = 'Resume Claude' })
    vim.keymap.set('n', '<leader>aC', '<cmd>ClaudeCode --continue<CR>', { desc = 'Continue Claude' })
    vim.keymap.set('n', '<leader>am', '<cmd>ClaudeCodeSelectModel<CR>', { desc = 'Select Claude model' })
    vim.keymap.set('n', '<leader>ab', '<cmd>ClaudeCodeAdd %<CR>', { desc = 'Add current buffer' })
    vim.keymap.set('v', '<leader>as', '<cmd>ClaudeCodeSend<CR>', { desc = 'Send to Claude' })
    vim.keymap.set('n', '<leader>as', '<cmd>ClaudeCodeTreeAdd<CR>', { desc = 'Add file' })
    vim.keymap.set('n', '<leader>aa', '<cmd>ClaudeCodeDiffAccept<CR>', { desc = 'Accept diff' })
    vim.keymap.set('n', '<leader>ad', '<cmd>ClaudeCodeDiffDeny<CR>', { desc = 'Deny diff' })
  end,
}
