local gitlinker = {
  'linrongbin16/gitlinker.nvim',
  cmd = { 'GitLink' },
}

gitlinker.init = function()
  vim.keymap.set({ 'n', 'v' }, '<leader>yg', function()
    vim.cmd('GitLink!')
  end, { silent = true, desc = 'Copy git link' })
end

gitlinker.config = function()
  require('gitlinker').setup()
end

return gitlinker
