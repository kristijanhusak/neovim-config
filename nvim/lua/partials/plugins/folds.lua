local folds = {
  install = function(packager)
    return packager.add('kevinhwang91/nvim-ufo', {
      requires = 'kevinhwang91/promise-async',
    })
  end,
}
folds.setup = function()
  vim.o.foldlevel = 99
  vim.o.foldlevelstart = 99
  vim.o.foldenable = true
  local ufo = require('ufo')
  ufo.setup({
    provider_selector = function(_, filetype)
      if filetype == 'org' then
        return ''
      end
      return { 'treesitter', 'indent' }
    end,
  })
  vim.keymap.set('n', 'zR', ufo.openAllFolds)
  vim.keymap.set('n', 'zM', ufo.closeAllFolds)
  vim.keymap.set('n', '<C-Space>', 'za')
  return folds
end

return folds
