return {
  'saghen/blink.cmp',
  lazy = false,
  version = '*',
  opts = {
    enabled = function()
      return not (vim.bo.buftype == 'prompt' or vim.b.disable_blink)
    end,
    sources = {
      completion = {
        enabled_providers = function()
          if vim.bo.filetype == 'sql' then
            return { 'snippets', 'dadbod' }
          end

          if vim.bo.filetype == 'org' then
            return { 'orgmode', 'buffer' }
          end

          return { 'lsp', 'snippets', 'path', 'buffer' }
        end,
      },
      providers = {
        dadbod = {
          name = 'Dadbod',
          module = 'vim_dadbod_completion.blink',
        },
        orgmode = {
          name = 'Orgmode',
          module = 'orgmode.org.autocompletion.blink',
        },
        buffer = {
          fallback_for = { 'lsp', 'dadbod', 'orgmode' },
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
        selection = 'auto_insert',
      },
      menu = {
        draw = {
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
