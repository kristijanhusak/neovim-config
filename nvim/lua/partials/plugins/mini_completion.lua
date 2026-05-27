return {
  'nvim-mini/mini.completion',
  config = function()
    vim.api.nvim_create_autocmd('InsertEnter', {
      pattern = '*',
      callback = function(ev)
        local is_valid_buffer = vim.bo[ev.buf].buftype ~= 'prompt' and vim.bo[ev.buf].filetype ~= 'snacks_input'
        if not is_valid_buffer then
          vim.b.minicompletion_disable = true
        end
      end,
    })

    local kinds_map = {}
    local mappings = {
      omnifunc = vim.api.nvim_replace_termcodes('<C-x><C-o>', true, false, true),
      ctrl_n = vim.api.nvim_replace_termcodes('<C-g><C-g><C-n>', true, false, true),
    }
    require('mini.completion').setup({
      lsp_completion = {
        source_func = 'omnifunc',
        process_items = function(items, base, opts)
          local res = MiniCompletion.default_process_items(items, base, opts)
          for _, item in ipairs(res) do
            local kind = kinds_map[item.kind] or 'Text'
            if not item.labelDetails then
              item.labelDetails = {}
            end
            item.labelDetails.detail = item.labelDetails.detail or '[LSP]'
            item.kind_hlgroup = ('CmpItemKind%s'):format(kind)
          end
          return res
        end,
      },
      fallback_action = function()
        local key = vim.bo.filetype == 'sql' and mappings.omnifunc or mappings.ctrl_n
        vim.api.nvim_feedkeys(key, 'n', false)
      end,
    })

    local utils = require('partials.utils')
    local icons = utils.lsp_kind_icons()

    local protocol = vim.lsp.protocol
    for i, kind in ipairs(protocol.CompletionItemKind) do
      kinds_map[i] = kind
      protocol.CompletionItemKind[i] = icons[kind] or kind
    end
    for i, kind in ipairs(protocol.SymbolKind) do
      protocol.SymbolKind[i] = icons[kind] or kind
    end

    vim.keymap.set('i', '<Tab>', function()
      if vim.snippet.active({ direction = 1 }) then
        return vim.snippet.jump(1)
      end

      if utils.expand_snippet() then
        return
      end

      if vim.lsp.inline_completion.get() then
        return
      end

      if utils.has_words_before() then
        return vim.lsp.inline_completion.select()
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
      if vim.fn.complete_info({ 'selected' }).selected ~= -1 then
        return utils.esc('<C-y>')
      end
      return require('mini.pairs').cr()
    end, { expr = true, noremap = true, replace_keycodes = false })
  end,
}
