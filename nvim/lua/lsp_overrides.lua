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

vim.lsp.callbacks['textDocument/documentSymbol'] = custom_symbol_callback
vim.lsp.callbacks['workspace/symbol'] = custom_symbol_callback

vim.lsp.callbacks['_typescript.rename'] = function(_, _, result)
  if not result then return end
  vim.fn.cursor(result.position.line + 1, result.position.character + 1)
  local new_name = vim.fn.input('New Name: ', vim.fn.expand('<cword>'))
  result.newName = new_name
  return vim.lsp.buf_request(0, 'textDocument/rename', result)
end

function _G.custom_code_action(context)
  vim.validate { context = { context, 't', true } }
  context = context or { diagnostics = util.get_line_diagnostics() }
  local A = api.nvim_buf_get_mark(0, '<')
  local B = api.nvim_buf_get_mark(0, '>')
  -- convert to 0-index
  A[1] = A[1] - 1
  B[1] = B[1] - 1
  -- account for encoding.
  if A[2] > 0 then
    A = {A[1], util.character_offset(0, A[1], A[2])}
  end
  if B[2] > 0 then
    B = {B[1], util.character_offset(0, B[1], B[2])}
  end
  local params = {
    textDocument = { uri = vim.uri_from_bufnr(0) };
    range = {
      start = { line = A[1]; character = A[2]; };
      ["end"] = { line = B[1]; character = B[2]; };
    };
    context = context;
  }
  vim.lsp.buf_request(0, 'textDocument/codeAction', params)
end


local function get_line_byte_from_position(bufnr, position)
  local col = position.character
  if col > 0 then
    local line = position.line
    local lines = api.nvim_buf_get_lines(bufnr, line, line + 1, false)
    if #lines > 0 then
      local status, byteindex = pcall(vim.str_byteindex, lines[1], col)
      if not status then return col end
      return byteindex
    end
  end
  return col
end

local function sort_by_key(fn)
  return function(a,b)
    local ka, kb = fn(a), fn(b)
    assert(#ka == #kb)
    for i = 1, #ka do
      if ka[i] ~= kb[i] then
        return ka[i] < kb[i]
      end
    end
    return false
  end
end

local edit_sort_key = sort_by_key(function(e)
  return {e.A[1], e.A[2], e.i}
end)

function vim.lsp.util.apply_text_edits(text_edits, bufnr)
  if not next(text_edits) then return end
  if not api.nvim_buf_is_loaded(bufnr) then
    vim.fn.bufload(bufnr)
  end
  api.nvim_buf_set_option(bufnr, 'buflisted', true)
  local start_line, finish_line = math.huge, -1
  local cleaned = {}
  for i, e in ipairs(text_edits) do
    local start_row = e.range.start.line
    local start_col = get_line_byte_from_position(bufnr, e.range.start)
    local end_row = e.range["end"].line
    local end_col = get_line_byte_from_position(bufnr, e.range['end'])
    start_line = math.min(e.range.start.line, start_line)
    finish_line = math.max(e.range["end"].line, finish_line)
    table.insert(cleaned, {
      i = i;
      A = {start_row; start_col};
      B = {end_row; end_col};
      lines = vim.split(e.newText, '\n', true);
    })
  end

  table.sort(cleaned, edit_sort_key)
  local lines = api.nvim_buf_get_lines(bufnr, start_line, finish_line + 1, false)
  local fix_eol = api.nvim_buf_get_option(bufnr, 'fixeol')
  local set_eol = fix_eol and api.nvim_buf_line_count(bufnr) <= finish_line + 1
  if set_eol and #lines[#lines] ~= 0 then
    table.insert(lines, '')
  end

  for i = #cleaned, 1, -1 do
    local e = cleaned[i]
    local A = {e.A[1] - start_line, e.A[2]}
    local B = {e.B[1] - start_line, e.B[2]}
    lines = vim.lsp.util.set_lines(lines, A, B, e.lines)
  end
  if set_eol and #lines[#lines] == 0 then
    table.remove(lines)
  end
  api.nvim_buf_set_lines(bufnr, start_line, finish_line + 1, false, lines)
end

