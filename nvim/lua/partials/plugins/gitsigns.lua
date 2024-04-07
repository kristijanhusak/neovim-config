local gitsigns_nvim = {
  'lewis6991/gitsigns.nvim',
  event = 'VeryLazy',
}
gitsigns_nvim.config = function()
  require('gitsigns').setup({
    signs = {
      add = { text = '▌' },
      change = { text = '▌' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '▌' },
    },
    numhl = true,
    on_attach = function(bufnr)
      local gitsigns = require('gitsigns')

      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      -- Navigation
      map('n', ']c', function()
        if vim.wo.diff then
          vim.cmd.normal({ ']c', bang = true })
        else
          gitsigns.nav_hunk('next')
        end
      end)

      map('n', '[c', function()
        if vim.wo.diff then
          vim.cmd.normal({ '[c', bang = true })
        else
          gitsigns.nav_hunk('prev')
        end
      end)

      -- Actions
      map('n', '<leader>hp', gitsigns.preview_hunk)
      map('n', '<leader>hr', gitsigns.reset_hunk)
      map('n', '<leader>hb', function()
        gitsigns.blame_line({ full = true })
      end)
      map('n', '<leader>hB', gitsigns.toggle_current_line_blame)
      map('n', '<leader>hd', gitsigns.diffthis)
      map('n', '<leader>hD', function()
        gitsigns.diffthis('~')
      end)
      map('n', '<leader>hy', gitsigns.toggle_deleted)

      -- Text object
      map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
    end,
  })

  return gitsigns_nvim
end

return gitsigns_nvim
