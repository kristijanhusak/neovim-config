local api = vim.api
local util = require'vim.lsp.util'

local custom_symbol_callback = function(_, _, result, _, bufnr)
  if not result or vim.tbl_isempty(result) then return end

  local items = util.symbols_to_items(result, bufnr)
  local items_by_name = {}
  for _, item in ipairs(items) do
    items_by_name[item.text] = item
  end

  local opts = vim.fn['fzf#wrap']({
      source = vim.tbl_keys(items_by_name),
      sink = function() end,
      options = {'--prompt', 'Symbol > '},
    })
  opts.sink = function(item)
    local selected = items_by_name[item]
    vim.fn.cursor(selected.lnum, selected.col)
  end
  vim.fn['fzf#run'](opts)
end

vim.lsp.handlers['textDocument/documentSymbol'] = custom_symbol_callback
vim.lsp.handlers['workspace/symbol'] = custom_symbol_callback
vim.lsp.handlers['_typescript.rename'] = function(_, _, result)
  if not result then return end
  vim.fn.cursor(result.position.line + 1, result.position.character + 1)
  local new_name = vim.fn.input('New Name: ', vim.fn.expand('<cword>'))
  result.newName = new_name
  return vim.lsp.buf_request(0, 'textDocument/rename', result)
end

vim.lsp.handlers['textDocument/signatureHelp'] = function(_, method, result)
  if not (result and result.signatures and result.signatures[1]) then return end
  local lines = util.convert_signature_help_to_markdown_lines(result)
  lines = util.trim_empty_lines(lines)
  if vim.tbl_isempty(lines) then return end
  util.focusable_preview(method, function()
    return lines, util.try_trim_markdown_code_blocks(lines)
  end)
end
