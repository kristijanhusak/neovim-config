local utils = require('partials.utils')
_G.kris = _G.kris or {}

function _G.kris.calculate_selection(append)
  local selection = utils.get_visual_selection()
  local result = vim.fn.eval(selection)
  print(result)
  if append then
    local line = vim.fn.getline('.')
    if not line:match('=%s*$') then
      result = ' = ' .. result
    end
    vim.fn.setline('.', line .. result)
  end
end

vim.keymap.set('v', '<Leader>ks', [[:<C-u>call v:lua.kris.calculate_selection()<CR>]])
vim.keymap.set('v', '<Leader>kS', [[:<C-u>call v:lua.kris.calculate_selection(v:true)<CR>]])
