local M = {}

local enable_fuzzy = nil

--- Returns `matched, score`. Score is non-nil only for fuzzy matches.
function M.match(value, prefix)
  if prefix == '' then
    return true, nil
  end
  if M.fuzzy_enabled() then
    local score = vim.fn.matchfuzzypos({ value }, prefix)[3] ---@type table
    if #score > 0 then
      return true, score[1]
    end
    return false, nil
  end
  if vim.o.ignorecase and (not vim.o.smartcase or not prefix:find('%u')) then
    return vim.startswith(value:lower(), prefix:lower()), nil
  end
  return vim.startswith(value, prefix), nil
end

function M.fuzzy_enabled()
  if enable_fuzzy == nil then
    enable_fuzzy = vim.list_contains(vim.opt.completeopt:get(), 'fuzzy')
  end
  return enable_fuzzy
end

return M
