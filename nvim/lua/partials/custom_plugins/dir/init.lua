vim.bo.bufhidden = 'wipe'

local function global_mappings()
  vim.keymap.set('n', '<Leader>n', function()
    if vim.bo.filetype == 'directory' then
      vim.cmd.bdelete()
      return
    end
    vim.cmd.edit(vim.fn.getcwd())
  end, { silent = true, desc = 'Toggle dir browser' })

  local function dir_at_current_file()
    local filename = vim.fn.expand('%:t')
    vim.api.nvim_feedkeys(require('partials.utils').esc('<Plug>(nvim-dir-up)'), 'n', false)
    vim.schedule(function()
      vim.fn.search(vim.fn.escape(filename, '.#~/'), 'cw')
    end)
  end

  vim.keymap.set('n', '<Leader>hf', dir_at_current_file, { silent = true, desc = 'Current file in dir browser' })
  vim.keymap.set('n', '-', dir_at_current_file, { silent = true, desc = 'Current file in dir browser' })
end

local function attach(bufnr)
  vim.bo[bufnr].bufhidden = 'wipe'
  local git = require('partials.custom_plugins.dir.git')
  local icons = require('partials.custom_plugins.dir.icons')
  local actions = require('partials.custom_plugins.dir.actions')
  icons.attach(bufnr)
  git.attach(bufnr)
  actions.attach(bufnr)
end

return {
  attach = attach,
  global_mappings = global_mappings,
}
