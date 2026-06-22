local M = {}

function M.update_popup_window(winid, bufnr, kind)
  if winid and vim.api.nvim_win_is_valid(winid) and bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    if kind == vim.lsp.protocol.MarkupKind.Markdown then
      vim.wo[winid].conceallevel = 2
      vim.treesitter.start(bufnr, kind)
    end
    local all = vim.api.nvim_win_text_height(winid, {}).all
    vim.api.nvim_win_set_height(winid, all)
    vim.api.nvim_win_set_config(winid, { border = 'rounded' })
  end
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
        return
      end
      local client = vim.lsp.get_client_by_id(lsp_data.client_id)
      if not client or not client:supports_method('completionItem/resolve') then
        return
      end
      local bufnr = vim.api.nvim_get_current_buf()
      local sel = vim.fn.complete_info({ 'selected' }).selected
      local ok, request_id = client:request('completionItem/resolve', lsp_data.completion_item, function(err, result)
        resolve_cancel = nil
        if err or not result or vim.fn.pumvisible() == 0 then
          return
        end
        local info = ''
        if result.detail and result.detail ~= '' then
          info = ('```%s\n%s\n```'):format(vim.bo.filetype, result.detail)
        end
        local doc = result.documentation
        local doc_kind = vim.lsp.protocol.MarkupKind.Markdown
        if doc then
          local doc_str = type(doc) == 'string' and doc or (type(doc) == 'table' and doc.value or '')
          info = info ~= '' and (info .. '\n' .. doc_str) or doc_str
        end
        if info == '' then
          return
        end
        if type(doc) == 'table' and doc.kind then
          doc_kind = doc.kind
        end
        vim.schedule(function()
          if vim.fn.pumvisible() == 0 then
            return
          end
          local cur = vim.fn.complete_info({ 'selected' })
          if cur.selected == sel then
            local windata = vim.api.nvim__complete_set(cur.selected, { info = info })
            M.update_popup_window(windata.winid, windata.bufnr, doc_kind)
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
