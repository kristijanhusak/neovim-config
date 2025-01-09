return {
  'saghen/blink.cmp',
  event = 'VeryLazy',
  version = '*',
  opts = {
    sources = {
      default = { 'lsp', 'snippets', 'path', 'buffer' },
      per_filetype = {
        org = { 'orgmode' },
        sql = { 'snippets', 'dadbod' },
      },
      cmdline = {},
      providers = {
        dadbod = {
          name = 'Dadbod',
          module = 'vim_dadbod_completion.blink',
          fallbacks = { 'buffer' },
        },
        orgmode = {
          name = 'Orgmode',
          module = 'orgmode.org.autocompletion.blink',
          fallbacks = { 'buffer' },
        },
        snippets = {
          score_offset = -5,
          enabled = function()
            return vim.trim(vim.fn.getline('.')) ~= ''
          end,
        },
      },
    },
    completion = {
      list = {
        selection = {
          auto_insert = true,
          preselect = false
        }
      },
      menu = {
        draw = {
          treesitter = { 'lsp' },
          gap = 2,
          columns = { { 'kind_icon' }, { 'label', 'kind', 'source_name', gap = 1 } },
          components = {
            kind = {
              highlight = 'BlinkCmpSource',
            },
            source_name = {
              text = function(ctx)
                return table.concat({ '[', ctx.source_name, ']' }, '')
              end,
            },
          },
        },
      },
      documentation = {
        auto_show = true,
        window = {
          border = 'rounded',
        },
      },
    },
    keymap = {
      preset = 'enter',
      ['<Tab>'] = {
        function(cmp)
          local list = require('blink.cmp.completion.list')
          local line_to_cursor = vim.fn.getline('.'):sub(1, vim.fn.col('.') - 1)
          local keyword = vim.fn.matchstr(line_to_cursor, [[\k*$]])
          if not list.get_selected_item() and list.items then
            for idx, item in ipairs(list.items) do
              if item.label == keyword and item.source_id == 'snippets' then
                vim.schedule(function()
                  list.select(idx)
                  return cmp.accept()
                end)
                return true
              end
            end
          end

          if cmp.snippet_active() then
            return cmp.snippet_forward()
          end

          if require('copilot.suggestion').is_visible() then
            require('copilot.suggestion').accept()
            return true
          end

          if require('partials.utils').has_words_before() then
            require('copilot.suggestion').next()
            return true
          end

          return false
        end,
        'fallback',
      },
      ['<C-n>'] = {
        'show',
        'select_next',
        'fallback',
      },
    },
  },
}
