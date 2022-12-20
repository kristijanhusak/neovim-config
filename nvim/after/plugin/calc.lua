local utils = require('partials.utils')
local ns = vim.api.nvim_create_namespace('custom_calc')

local function calculate_selection(append)
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

vim.keymap.set('v', '<Leader>ks', [[:<C-u>call luaeval('require("partials.plugins.custom.calc")()')<CR>]])
vim.keymap.set('v', '<Leader>kS', [[:<C-u>call luaeval('require("partials.plugins.custom.calc")(true)')<CR>]])

return calculate_selection
