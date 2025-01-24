if not vim.g.enable_custom_completion then
  return
end

local utils = require('partials.utils')
local augroup = vim.api.nvim_create_augroup('custom_lsp_completion', { clear = true })

local timer = nil
local last_char = ''

local stop_timer = function()
  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end
end

local function debounce(fn, delay)
  return function(...)
    local args = { ... }
    stop_timer()
    timer = vim.loop.new_timer()
    timer:start(
      delay,
      0,
      vim.schedule_wrap(function()
        fn(unpack(args))
      end)
    )
  end
end

local function pumvisible()
  return vim.fn.pumvisible() > 0
end

local feedkeys = function(key)
  stop_timer()
  vim.api.nvim_feedkeys(utils.esc(key), 'n', false)
end

local trigger_with_fallback = function(fn, still_running)
  local win = vim.api.nvim_get_current_win()
  local cursor = vim.api.nvim_win_get_cursor(win)

  fn()

  vim.defer_fn(function()
    local mode = vim.api.nvim_get_mode().mode
    local is_insert_mode = mode == 'i' or mode == 'ic'
    local cursor_changed = not vim.deep_equal(cursor, vim.api.nvim_win_get_cursor(win))
    if cursor_changed or not is_insert_mode or pumvisible() or (still_running and still_running()) then
      return stop_timer()
    end
    if not pumvisible() then
      feedkeys('<C-g><C-g><C-n>')
    end
  end, 50)
end

local complete_ins = debounce(function()
  if pumvisible() then
    return stop_timer()
  end
  local lsp_client = vim.b.lsp_completion_enabled
  ---@diagnostic disable-next-line: undefined-field
  local has_omnifunc = vim.opt_local.omnifunc:get() ~= ''

  if not lsp_client and not has_omnifunc then
    return feedkeys('<C-n>')
  end

  if not lsp_client then
    return trigger_with_fallback(function()
      return feedkeys('<C-x><C-o>')
    end)
  end

  return trigger_with_fallback(vim.lsp.completion.trigger, function()
    return #vim.tbl_filter(function(request)
      return request.method == vim.lsp.protocol.Methods.textDocument_completion
    end, vim.lsp.get_client_by_id(vim.b.lsp_completion_enabled).requests) > 0
  end)
end, 100)

local trigger_complete = function(char, buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if vim.bo[buf].buftype == 'prompt' then
    return
  end
  if pumvisible() or last_char == ' ' then
    last_char = char
    return
  end
  last_char = char
  complete_ins()
end

vim.api.nvim_create_autocmd('InsertCharPre', {
  group = augroup,
  pattern = '*',
  callback = function(args)
    vim.schedule(function()
      trigger_complete(vim.v.char, args.buf)
    end)
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = augroup,
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == 'copilot' then
      return
    end
    vim.b[args.buf].lsp_completion_enabled = args.data.client_id
    vim.lsp.completion.enable(true, args.data.client_id, args.buf, {
      convert = function(item)
        local icons = utils.lsp_kind_icons()
        local kind = vim.lsp.protocol.CompletionItemKind[item.kind] or 'Text'
        return {
          kind = icons[kind],
          kind_hlgroup = ('CmpItemKind%s'):format(kind),
          menu = kind,
        }
      end,
    })
  end,
})

vim.keymap.set('i', '<Tab>', function()
  if vim.snippet.active({ direction = 1 }) then
    return vim.snippet.jump(1)
  end

  if utils.expand_snippet() then
    return
  end

  if require('copilot.suggestion').is_visible() then
    return require('copilot.suggestion').accept()
  end
  if utils.has_words_before() then
    return require('copilot.suggestion').next()
  end

  utils.feedkeys('<Tab>', 'n')
end, { silent = true })

vim.keymap.set({ 'i', 's' }, '<S-Tab>', function()
  if vim.snippet.active({ direction = -1 }) then
    return vim.snippet.jump(-1)
  end

  return utils.feedkeys('<S-Tab>', 'n')
end, { silent = true })

vim.keymap.set('i', '<C-n>', function()
  if pumvisible() then
    return utils.feedkeys('<C-n>', 'n')
  end

  local char = vim.api.nvim_get_current_line():sub(-1)
  trigger_complete(char)
end)

vim.keymap.set('i', '<CR>', function()
  local npairs = require('nvim-autopairs')

  if not pumvisible() then
    return npairs.autopairs_cr()
  end

  if vim.fn.complete_info({ 'selected' }).selected ~= -1 then
    return npairs.esc('<c-y>')
  end
  return npairs.autopairs_cr()
end, { expr = true, noremap = true, replace_keycodes = false })

vim.keymap.set('i', '<BS>', function()
  vim.fn.feedkeys(utils.esc('<BS>'), 'n')
  vim.schedule(function()
    local char = vim.api.nvim_get_current_line():sub(-1)
    trigger_complete(char)
  end)
end, { noremap = true })
