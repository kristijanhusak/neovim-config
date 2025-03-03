if not vim.g.enable_custom_completion then
  return
end

local utils = require('partials.utils')
local augroup = vim.api.nvim_create_augroup('custom_lsp_completion', { clear = true })
local icons = utils.lsp_kind_icons()
local timer = nil

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
    timer:start(delay, 0, function()
      stop_timer()
      vim.schedule_wrap(fn)(unpack(args))
    end)
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
  fn()

  if pumvisible() then
    return stop_timer()
  end

  vim.defer_fn(function()
    local mode = vim.api.nvim_get_mode().mode
    local is_insert_mode = mode == 'i' or mode == 'ic'
    if not is_insert_mode or pumvisible() or (still_running and still_running()) then
      return stop_timer()
    end
    feedkeys('<C-g><C-g><C-n>')
  end, 50)
end

local complete_ins = debounce(function()
  if pumvisible() then
    return stop_timer()
  end
  local lsp_client_id = vim.b.lsp_client_id
  ---@diagnostic disable-next-line: undefined-field
  local has_omnifunc = vim.opt_local.omnifunc:get() ~= ''

  if not lsp_client_id and not has_omnifunc then
    return feedkeys('<C-n>')
  end

  if not lsp_client_id then
    return trigger_with_fallback(function()
      return feedkeys('<C-x><C-o>')
    end)
  end

  return trigger_with_fallback(vim.lsp.completion.trigger, function()
    return #vim.tbl_filter(function(request)
      return request.method == vim.lsp.protocol.Methods.textDocument_completion
    end, vim.lsp.get_client_by_id(lsp_client_id).requests) > 0
  end)
end, 50)

local trigger_complete = function(opts)
  opts = opts or {}
  if opts.force then
    return complete_ins()
  end

  local buf = opts.buf or vim.api.nvim_get_current_buf()
  if vim.bo[buf].buftype == 'prompt' or vim.bo[buf].filetype == 'snacks_input' then
    return
  end
  if pumvisible() or opts.char == ' ' then
    return
  end
  return complete_ins()
end

local function on_complete_changed()
  local completed_item = vim.api.nvim_get_vvar('completed_item')
  if not completed_item or not completed_item.user_data or not completed_item.user_data.nvim then
    return
  end
  local completion_item = completed_item.user_data.nvim.lsp.completion_item --- @type lsp.CompletionItem
  local client_id = completed_item.user_data.nvim.lsp.client_id --- @type integer
  local client = vim.lsp.get_client_by_id(client_id)
  if not client then
    return
  end

  client:request(vim.lsp.protocol.Methods.completionItem_resolve, completion_item, function(err, result)
    if err or not result then
      return
    end

    local text = {}

    if result and result.documentation then
      local docs = type(result.documentation) == 'string' and result.documentation or result.documentation.value
      vim.list_extend(text, vim.split(docs, '\n'))
    end

    if result.detail and not vim.startswith(text[1] or '', '```') then
      text = vim.list_extend({ '```' .. vim.bo.filetype, result.detail, '```' }, text)
    end

    if #text == 0 then
      return
    end

    local _, popup_winid = vim.lsp.util.open_floating_preview(text, 'markdown', {
      border = 'single',
    })
    local pos = vim.fn.pum_getpos()
    if not pos or not pos.row or not pos.col then
      return
    end
    vim.api.nvim_win_set_config(popup_winid, {
      relative = 'win',
      row = pos.row,
      col = pos.col + pos.width + (pos.scrollbar and 1 or 0),
    })
  end)
end

-- Autocmds
vim.api.nvim_create_autocmd('InsertCharPre', {
  group = augroup,
  pattern = '*',
  callback = function(args)
    local char = vim.v.char
    vim.schedule(function()
      trigger_complete({ char = char, buf = args.buf })
    end)
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = augroup,
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or not client:supports_method(vim.lsp.protocol.Methods.textDocument_completion) then
      return
    end

    vim.b[args.buf].lsp_client_id = client.id
    vim.lsp.completion.enable(true, client.id, args.buf, {
      convert = function(item)
        local kind = vim.lsp.protocol.CompletionItemKind[item.kind] or 'Text'
        return {
          kind = icons[kind],
          kind_hlgroup = ('CmpItemKind%s'):format(kind),
          menu = kind,
        }
      end,
    })

    vim.api.nvim_create_autocmd('CompleteChanged', {
      group = augroup,
      buffer = args.buf,
      callback = function()
        on_complete_changed()
      end,
    })
  end,
})

-- Keymaps
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

  trigger_complete({ force = true })
end)

vim.keymap.set('i', '<CR>', function()
  local npairs = require('nvim-autopairs')

  if not pumvisible() then
    return npairs.autopairs_cr()
  end

  if vim.fn.complete_info({ 'selected' }).selected ~= -1 then
    return npairs.esc('<c-y>')
  end
  return npairs.esc('<c-e>') .. npairs.autopairs_cr()
end, { expr = true, noremap = true, replace_keycodes = false })

vim.keymap.set('i', '<BS>', function()
  vim.api.nvim_feedkeys(utils.esc('<BS>'), 'n', false)
  vim.schedule(function()
    local char = vim.api.nvim_get_current_line():sub(-1)
    trigger_complete({ char = char })
  end)
end, { noremap = true })
