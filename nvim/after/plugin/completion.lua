if not vim.g.enable_builtin_completion then
  return
end

local utils = require('partials.utils')
local augroup = vim.api.nvim_create_augroup('custom_lsp_completion', { clear = true })
local icons = utils.lsp_kind_icons()
local protocol = vim.lsp.protocol
vim.opt.complete = '.,w,b,o'

vim.api.nvim_create_autocmd('InsertEnter', {
  pattern = '*',
  group = augroup,
  callback = function(ev)
    local is_valid_buffer = vim.bo[ev.buf].buftype ~= 'prompt' and vim.bo[ev.buf].filetype ~= 'snacks_input'
    local completion_clients = vim.lsp.get_clients({
      bufnr = ev.buf,
      method = protocol.Methods.textDocument_completion,
    })

    local no_valid_lsp_clients = #vim.tbl_filter(function(client)
      return client.name ~= 'buffer_lsp'
    end, completion_clients) == 0

    local enable_autocomplete = is_valid_buffer and no_valid_lsp_clients

    if enable_autocomplete then
      vim.opt_local.autocomplete = true
      vim.tbl_map(function(client)
        vim.lsp.buf_detach_client(ev.buf, client.id)
      end, completion_clients)
    else
      vim.opt_local.autocomplete = false
      vim.tbl_map(function(client)
        vim.lsp.buf_attach_client(ev.buf, client.id)
      end, completion_clients)
    end
  end,
})

require('partials.lsps.buffer')
vim.lsp.enable('buffer_lsp')

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

  client:request(protocol.Methods.completionItem_resolve, completion_item, function(err, result)
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
      relative = 'editor',
      row = pos.row,
      col = pos.col + pos.width + (pos.scrollbar and 1 or 0),
    })
  end)
end

vim.api.nvim_create_autocmd('LspAttach', {
  group = augroup,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client or not client:supports_method(protocol.Methods.textDocument_completion) then
      return
    end

    local chars = {}
    for i = 32, 126 do
      table.insert(chars, string.char(i))
    end
    client.server_capabilities.completionProvider.triggerCharacters = chars

    vim.lsp.completion.enable(true, client.id, ev.buf, {
      autotrigger = true,
      convert = function(item)
        local kind = vim.lsp.protocol.CompletionItemKind[item.kind] or 'Text'
        local menu = ('[%s]'):format(kind)
        if item.data and item.data.bufnames then
          menu = '[Buffer]'
        end
        return {
          kind = icons[kind],
          kind_hlgroup = ('CmpItemKind%s'):format(kind),
          menu = menu,
        }
      end,
    })

    vim.api.nvim_create_autocmd('CompleteChanged', {
      group = augroup,
      buffer = ev.buf,
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
  if vim.fn.pumvisible() > 0 then
    return utils.feedkeys('<C-n>', 'n')
  end

  vim.lsp.completion.get()
end)

vim.keymap.set('i', '<CR>', function()
  local npairs = require('nvim-autopairs')

  if vim.fn.pumvisible() == 0 then
    return npairs.autopairs_cr()
  end

  if vim.fn.complete_info({ 'selected' }).selected ~= -1 then
    return npairs.esc('<c-y>')
  end
  return npairs.esc('<c-e>') .. npairs.autopairs_cr()
end, { expr = true, noremap = true, replace_keycodes = false })
