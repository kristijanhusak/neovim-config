return {
  { 'tpope/vim-repeat', event = 'VeryLazy' },
  { 'tpope/vim-sleuth', event = 'VeryLazy' },
  { 'tpope/vim-abolish', event = 'VeryLazy' },
  { 'tpope/vim-surround', event = 'VeryLazy' },
  { 'nvim-lua/plenary.nvim' },
  { 'stefandtw/quickfix-reflector.vim', event = 'VeryLazy' },
  { 'wakatime/vim-wakatime', event = 'VeryLazy' },
  { 'LunarVim/bigfile.nvim', lazy = false, priority = 2000 },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      preset = 'helix',
    },
  },
  {
    'echasnovski/mini.completion',
    event = 'VeryLazy',
    config = function()
      local icons = require('partials.utils').lsp_kind_icons()
      local kind_names = {}
      for name, kind in pairs(vim.lsp.protocol.CompletionItemKind) do
        kind_names[tostring(kind)] = name
      end
      for i, kind in ipairs(vim.lsp.protocol.CompletionItemKind) do
        vim.lsp.protocol.CompletionItemKind[i] = icons[kind]
      end

      local match = function(item, base)
        if not base or base == '' then
          return true
        end
        local text = item.filterText or (item.textEdit and item.textEdit.newText) or item.insertText or item.label
        if not text then
          return false
        end
        local match = vim.fn.matchfuzzypos({ text }, base)
        if #match[1] > 0 then
          return match[3][1]
        end
        return false
      end

      require('mini.completion').setup({
        window = {
          info = { border = 'single' },
          signature = { border = 'single' },
        },
        lsp_completion = {
          process_items = function(items, base)
            local result = {}
            for _, item in ipairs(items) do
              local score = match(item, base)
              if score then
                if type(score) == 'number' then
                  item.fuzzy_score = score
                end
                local kind_name = kind_names[tostring(item.kind)] or 'Unknown'
                item.kind_hlgroup = ('CmpItemKind%s'):format(kind_name)
                if not item.detail or item.detail == '' then
                  item.detail = kind_name
                end
                table.insert(result, item)
              end
            end

            table.sort(result, function(a, b)
              if a.fuzzy_score and b.fuzzy_score then
                return a.fuzzy_score > b.fuzzy_score
              end
              return (a.sortText or a.label) < (b.sortText or b.label)
            end)

            return result
          end,
        },
        set_vim_settings = false,
      })
    end,
  },
}
