local ns_id = vim.api.nvim_create_namespace('directory_browser_actions')
local utils = require('partials.utils')
local dir_utils = require('partials.custom_plugins.dir.utils')
local create_action = require('partials.custom_plugins.dir.actions.create')
local rename_action = require('partials.custom_plugins.dir.actions.rename')
local clipboard_action = require('partials.custom_plugins.dir.actions.clipboard')
local delete_action = require('partials.custom_plugins.dir.actions.delete')

vim.api.nvim_set_hl(0, 'DirectoryCut', { undercurl = true })
vim.api.nvim_set_hl(0, 'DirectoryCopy', { underline = true })

local position_state = {}

local function render_state()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for row, line in ipairs(lines) do
    local current_dir = vim.api.nvim_buf_get_name(0)
    local full_path = vim.fs.joinpath(current_dir, line)
    if clipboard_action.cut_state[full_path] then
      vim.api.nvim_buf_set_extmark(0, ns_id, row - 1, 0, {
        virt_text = { { '󰆐 ', 'Title' } },
        hl_mode = 'combine',
      })

      vim.api.nvim_buf_set_extmark(0, ns_id, row - 1, 0, {
        end_col = #line,
        hl_group = 'DirectoryCut',
      })
    end

    if clipboard_action.copy_state[full_path] then
      vim.api.nvim_buf_set_extmark(0, ns_id, row - 1, 0, {
        virt_text = { { ' ', 'Title' } },
        hl_mode = 'combine',
      })

      vim.api.nvim_buf_set_extmark(0, ns_id, row - 1, 0, {
        end_col = #line,
        hl_group = 'DirectoryCopy',
      })
    end
  end
end

local function add_mappings()
  vim.keymap.set('n', 'a', function()
    create_action.execute()
  end, { buffer = true, nowait = true, desc = 'Create file' })

  vim.keymap.set('n', 'd', function()
    delete_action.execute()
  end, { buffer = true, nowait = true, desc = 'Delete file' })

  vim.keymap.set('n', 'r', function()
    rename_action.execute()
  end, { buffer = true, nowait = true, desc = 'Rename file' })

  local function keymap(key)
    return function()
      local view = vim.fn.winsaveview()
      position_state[vim.api.nvim_buf_get_name(0)] = view
      vim.api.nvim_feedkeys(utils.esc(key), 'n', false)
      vim.schedule(function()
        if vim.bo.filetype ~= 'directory' then
          return
        end
        local restview = position_state[vim.api.nvim_buf_get_name(0)] or view
        vim.fn.winrestview(restview)
      end)
    end
  end

  vim.keymap.set('n', 'o', keymap('<Plug>(nvim-dir-open)'), { buffer = true, nowait = true, desc = 'Open file/dir' })
  vim.keymap.set('n', 'L', keymap('<Plug>(nvim-dir-open)'), { buffer = true, nowait = true, desc = 'Open file/dir' })
  vim.keymap.set('n', 'H', keymap('<Plug>(nvim-dir-up)'), { buffer = true, nowait = true, desc = 'Go up dir' })
  vim.keymap.set('n', '-', keymap('<Plug>(nvim-dir-up)'), { buffer = true, nowait = true, desc = 'Go up dir' })

  vim.keymap.set('n', 'q', function()
    vim.cmd('bw!')
  end, { buffer = true, nowait = true, desc = 'Quit' })

  vim.keymap.set('n', 's', function()
    local full_path, _, _, _ = dir_utils.current_entry()
    vim.cmd.vnew(full_path)
  end, { buffer = true, nowait = true, desc = 'Open file/dir in vert split' })

  vim.keymap.set('n', 'X', function()
    local full_path, _, _, _ = dir_utils.current_entry()
    vim.fn.execute(('silent !xdg-open %s'):format(vim.fn.shellescape(full_path)))
  end, { buffer = true, nowait = true, desc = 'Open file/dir in vert split' })

  vim.keymap.set('n', 'c', function()
    clipboard_action.mark_copy()
    dir_utils.reload()
  end, { buffer = true, nowait = true, desc = 'Mark/Unmark for copy' })

  vim.keymap.set('n', 'x', function()
    clipboard_action.mark_cut()
  end, { buffer = true, nowait = true, desc = 'Mark/Unmark for cut' })

  vim.keymap.set('n', 'p', function()
    clipboard_action.paste()
  end, { buffer = true, nowait = true, desc = 'Paste marked files' })
end

local function attach()
  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
  render_state()
  add_mappings()
end

return {
  attach = attach,
}
