return {
    'echasnovski/mini.diff',
    event = 'VeryLazy',
    config = function()
      require('mini.diff').setup({
        view = {
          style = 'sign',
          signs = { add = '▌', change = '▌', delete = '▌' },
        },
        mappings = {
          goto_first = '',
          goto_prev = '[c',
          goto_next = ']c',
          goto_last = '',
        },
      })
      vim.keymap.set('n', '<leader>hp', function()
        MiniDiff.toggle_overlay(vim.api.nvim_get_current_buf())
      end)
      vim.keymap.set('n', '<leader>hr', 'gHgh', { remap = true })
      vim.keymap.set('x', '<leader>hr', 'gH', { remap = true })
      vim.keymap.set('n', '<leader>hs', 'ghgh', { remap = true })
      vim.keymap.set('x', '<leader>hs', 'gh', { remap = true })
    end,
  }
