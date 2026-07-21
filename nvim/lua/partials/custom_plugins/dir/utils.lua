local M = {
  sep = (vim.fn.exists('+shellslash') == 1 and not vim.o.shellslash) and '\\' or '/',
}
local utils = require('partials.utils')

function M.reload()
  vim.api.nvim_feedkeys(utils.esc('<Plug>(nvim-dir-reload)'), 'n', false)
end

function M.trim_sep(path)
  if vim.endswith(path, M.sep) then
    return path:sub(1, #path - 1)
  end
  return path
end

function M.current_entry(bufnr)
  local current_dir = vim.api.nvim_buf_get_name(bufnr)
  local line = vim.api.nvim_get_current_line()

  local full_path = vim.fs.joinpath(current_dir, line)

  return full_path, current_dir, line, vim.endswith(line, M.sep)
end

M.rename_loaded_buffers = function(old_path, new_path)
  -- delete new if it exists
  for _, buf in pairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local buf_name = vim.api.nvim_buf_get_name(buf)
      if buf_name == new_path then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end
  end

  -- rename old to new
  for _, buf in pairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local buf_name = vim.api.nvim_buf_get_name(buf)
      local exact_match = buf_name == old_path
      local child_match = (buf_name:sub(1, #old_path) == old_path and buf_name:sub(#old_path + 1, #old_path + 1) == M.sep)
      if exact_match or child_match then
        vim.api.nvim_buf_set_name(buf, new_path .. buf_name:sub(#old_path + 1))
        -- to avoid the 'overwrite existing file' error message on write for
        -- normal files
        local buftype = vim.api.nvim_get_option_value('buftype', { buf = buf })

        if buftype == '' then
          vim.api.nvim_buf_call(buf, function()
            vim.cmd('silent! write!')
            vim.cmd('edit')
          end)
        end
      end
    end
  end
end

function M.lsp_create(path)
  local fname = M.trim_sep(path)
  return {
    before = function()
      local will_create = require('lsp-file-operations.will-create')
      will_create.callback({ fname = fname })
    end,
    after = function()
      local did_create = require('lsp-file-operations.did-create')
      did_create.callback({ fname = fname })
    end,
  }
end

function M.lsp_delete(path)
  local fname = M.trim_sep(path)
  return {
    before = function()
      local will_delete = require('lsp-file-operations.will-delete')
      will_delete.callback({ fname = fname })
    end,
    after = function()
      local did_delete = require('lsp-file-operations.did-delete')
      did_delete.callback({ fname = fname })
    end,
  }
end

function M.lsp_rename(old_path, new_path)
  local payload = {
    old_fname = M.trim_sep(old_path),
    new_fname = M.trim_sep(new_path),
  }
  return {
    before = function()
      local will_rename = require('lsp-file-operations.will-rename')
      will_rename.callback(payload)
    end,
    after = function()
      M.rename_loaded_buffers(old_path, old_path)
      local did_rename = require('lsp-file-operations.did-rename')
      did_rename.callback(payload)
    end,
  }
end

return M
