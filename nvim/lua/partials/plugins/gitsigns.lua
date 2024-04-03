local gitsigns_nvim = {
  'lewis6991/gitsigns.nvim',
  event = 'VeryLazy'
}
gitsigns_nvim.config = function()
  local gitsigns = require('gitsigns')

  gitsigns.setup({
    signs = {
      add = { text = '▌' },
      change = { text = '▌' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '▌' },
    },
    numhl = true,
    on_attach = function(bufnr)
      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end
      map('n', ']c', "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", { expr = true, replace_keycodes = false })
      map('n', '[c', "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", { expr = true, replace_keycodes = false })
      map({ 'n', 'v' }, '<leader>hs', ':Gitsigns stage_hunk<CR>')
      map({ 'n', 'v' }, '<leader>hr', ':Gitsigns reset_hunk<CR>')
      map('n', '<leader>hS', gitsigns.stage_buffer)
      map('n', '<leader>hu', gitsigns.undo_stage_hunk)
      map('n', '<leader>hR', gitsigns.reset_buffer)
      map('n', '<leader>hp', gitsigns.preview_hunk)
      map('n', '<leader>hb', function()
        gitsigns.blame_line({ full = true })
      end)
      map('n', '<leader>hd', gitsigns.toggle_deleted)
      map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
    end,
  })

  return gitsigns_nvim
end

return gitsigns_nvim
