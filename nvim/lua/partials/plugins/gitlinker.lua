local gitlinker = {
  'linrongbin16/gitlinker.nvim',
}

gitlinker.init = function()
  vim.keymap.set({ 'n', 'v' }, '<leader>yg', function()
    require('gitlinker').link({ action = require('gitlinker.actions').system })
  end, { silent = true })
end

gitlinker.config = function()
  require('gitlinker').setup({
    mapping = {},
  })
end

return gitlinker
