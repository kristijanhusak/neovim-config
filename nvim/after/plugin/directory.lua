if not vim.g.builtin_dir then
  return
end

vim.keymap.set('n', '<Leader>n', function()
  if vim.bo.filetype == 'directory' then
    vim.cmd.bdelete()
    return
  end
  vim.cmd.edit(vim.fn.getcwd())
end, { silent = true, desc = 'Toggle dir browser' })
vim.keymap.set('n', '<Leader>hf', function()
  local filename = vim.fn.expand('%:t')
  vim.api.nvim_feedkeys(require('partials.utils').esc('<Plug>(nvim-dir-up)'), 'n', false)
  vim.schedule(function()
    vim.fn.search(vim.fn.escape(filename, '.#~/'), 'cw')
  end)
end, { silent = true, desc = 'Current file in dir browser' })
