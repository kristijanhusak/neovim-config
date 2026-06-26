local M = {}

function M.update_popup_doc(info, opts)
  if not info or info == '' then
    return
  end
  opts = opts or {}
  local selected = opts.selected or vim.fn.complete_info({ 'selected' }).selected
  local c = vim.api.nvim__complete_set(selected, { info = info })
  local kind = opts.kind or vim.lsp.protocol.MarkupKind.Markdown

  if c.winid and vim.api.nvim_win_is_valid(c.winid) and c.bufnr and vim.api.nvim_buf_is_valid(c.bufnr) then
    if kind == vim.lsp.protocol.MarkupKind.Markdown then
      vim.wo[c.winid].conceallevel = 2
      vim.treesitter.start(c.bufnr, kind)
    end
    local all = vim.api.nvim_win_text_height(c.winid, {}).all
    vim.api.nvim_win_set_height(c.winid, all)
    vim.api.nvim_win_set_config(c.winid, { border = 'rounded' })
  end
end

---Returns an item's documentation value and its markup kind.
---@param item lsp.CompletionItem
---@return string
---@return lsp.MarkupKind
local function get_doc(item)
  local doc = item.documentation
  local default_kind = vim.lsp.protocol.MarkupKind.Markdown
  if not doc then
    return '', default_kind
  end
  if type(doc) == 'string' then
    return doc, default_kind
  end
  if type(doc) == 'table' and type(doc.value) == 'string' then
    return doc.value, doc.kind
  end

  vim.notify('invalid documentation value: ' .. vim.inspect(doc), vim.log.levels.WARN)
  return '', default_kind
end

---@param item lsp.CompletionItem
---@return string
---@return lsp.MarkupKind
function M.complete_item_info(item)
  local info, kind = get_doc(item)

  if item.detail and item.detail ~= '' then
    local detail_block = ('```%s\n%s\n```'):format(vim.bo.filetype, item.detail)
    if info == '' then
      info = detail_block
    elseif not info:find(item.detail, 1, true) then
      info = detail_block .. '\n' .. info
    end
  end

  return info, kind
end

--- Registers CompleteChanged (completionItem/resolve for docs) and
--- CompleteDone (additionalTextEdits, snippet expansion, commands).
function M.setup(augroup)
  local resolve_cancel = nil

  vim.api.nvim_create_autocmd('CompleteChanged', {
    group = augroup,
    callback = function()
      if resolve_cancel then
        resolve_cancel()
        resolve_cancel = nil
      end
      local completed_item = vim.v.event.completed_item or {}
      local lsp_data = vim.tbl_get(completed_item, 'user_data', 'nvim', 'lsp')
      if not lsp_data then
        M.update_popup_doc(completed_item.info)
        return
      end
      local client = vim.lsp.get_client_by_id(lsp_data.client_id)
      if not client or not client:supports_method('completionItem/resolve') then
        M.update_popup_doc(completed_item.info)
        return
      end
      local bufnr = vim.api.nvim_get_current_buf()
      local sel = vim.fn.complete_info({ 'selected' }).selected
      local ok, request_id = client:request('completionItem/resolve', lsp_data.completion_item, function(err, result)
        resolve_cancel = nil
        if err or not result or vim.fn.pumvisible() == 0 then
          return
        end
        local info, doc_kind = M.complete_item_info(result)
        if info == '' then
          return
        end
        vim.schedule(function()
          if vim.fn.pumvisible() == 0 then
            return
          end
          local cur = vim.fn.complete_info({ 'selected' })
          if cur.selected == sel then
            M.update_popup_doc(info, { kind = doc_kind, selected = cur.selected })
          end
        end)
      end, bufnr)
      if ok and request_id then
        resolve_cancel = function()
          client:cancel_request(request_id)
        end
      end
    end,
  })

  vim.api.nvim_create_autocmd('CompleteDone', {
    group = augroup,
    callback = function()
      local reason = vim.v.event.reason
      if reason ~= 'accept' then
        return
      end
      local completed_item = vim.v.completed_item
      if not completed_item or not completed_item.word then
        return
      end
      local lsp_data = vim.tbl_get(completed_item, 'user_data', 'nvim', 'lsp')
      if not lsp_data then
        return
      end
      local completion_item = lsp_data.completion_item
      local client = vim.lsp.get_client_by_id(lsp_data.client_id)
      if not completion_item or not client then
        return
      end
      local bufnr = vim.api.nvim_get_current_buf()
      local encoding = client.offset_encoding or 'utf-16'
      local inserted_word = completed_item.word

      local function apply(item)
        if item.additionalTextEdits then
          vim.lsp.util.apply_text_edits(item.additionalTextEdits, bufnr, encoding)
        end
        local is_snippet = item.insertTextFormat == vim.lsp.protocol.InsertTextFormat.Snippet
        if is_snippet then
          local text = (item.textEdit and item.textEdit.newText) or item.insertText
          if text then
            local cursor = vim.api.nvim_win_get_cursor(0)
            local row, col = cursor[1] - 1, cursor[2]
            vim.api.nvim_buf_set_text(bufnr, row, col - #inserted_word, row, col, { '' })
            vim.snippet.expand(text)
          end
        end
        if item.command then
          client:exec_cmd(item.command, { bufnr = bufnr })
        end
      end

      local resolve_provider = (client.server_capabilities.completionProvider or {}).resolveProvider
      if resolve_provider then
        client:request('completionItem/resolve', completion_item, function(err, result)
          apply(err and completion_item or (result or completion_item))
        end, bufnr)
      else
        apply(completion_item)
      end
    end,
  })
end

return M
