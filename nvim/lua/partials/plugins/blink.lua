return {
  'saghen/blink.cmp',
  event = 'InsertEnter',
  enabled = not vim.g.builtin_autocompletion,
  version = '*',
  dependencies = {
    'mikavilpas/blink-ripgrep.nvim',
  },
  opts = {
    cmdline = {
      enabled = false,
    },
    sources = {
      default = { 'lsp', 'path', 'buffer' },
      per_filetype = {
        org = { 'orgmode', 'buffer' },
        sql = { 'snippets', 'dadbod', 'buffer' },
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
        ripgrep = {
          name = 'RG',
          module = 'blink-ripgrep',
          score_offset = -10,
          opts = {
            prefix_min_len = 4,
            project_root_marker = { 'package.json', '.git' },
            backend = {
              use = 'gitgrep-or-ripgrep',
            },
          },
        },
        snippets = {
          score_offset = -5,
        },
      },
    },
    completion = {
      list = {
        selection = {
          auto_insert = true,
          preselect = false,
        },
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
            kind_icon = {
              highlight = function(ctx)
                return ('CmpItemKind%s'):format(ctx.kind)
              end,
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
          if cmp.snippet_active() then
            return cmp.snippet_forward()
          end

          if require('partials.utils').expand_snippet() then
            return false
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
        function(cmp)
          if cmp.is_menu_visible() then
            return cmp.select_next()
          end

          return cmp.show({ providers = { 'ripgrep' } })
        end,
      },
    },
  },
}
