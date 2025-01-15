local utils = require('partials.utils')

local expand_snippet = function()
  local filetype_map = {
    typescriptreact = 'javascript',
    typescript = 'javascript',
    javascriptreact = 'javascript',
  }
  local line_to_cursor = vim.fn.getline('.'):sub(1, vim.fn.col('.') - 1)
  local keyword = vim.fn.matchstr(line_to_cursor, [[\s*\zs\(.*\)$]])
  local filetype = filetype_map[vim.bo.filetype] or vim.bo.filetype
  local path = vim.fn.stdpath('config') .. '/snippets/' .. filetype .. '.json'
  local fs_stat = vim.uv.fs_stat(path)
  if not fs_stat or fs_stat.type ~= 'file' then
    return
  end
  ---@type { prefix: string[], body: string[] }[]
  local data = vim.json.decode(table.concat(vim.fn.readfile(path), '\n'))

  for _, snippet in pairs(data) do
    if snippet.prefix[1] == keyword then
      vim.fn.feedkeys(utils.esc('<C-w>'), 'n')
      vim.schedule(function()
        vim.snippet.expand(table.concat(snippet.body, '\n'))
      end)
      return true
    end
  end
end

return {
  'saghen/blink.cmp',
  event = 'VeryLazy',
  version = '*',
  opts = {
    sources = {
      default = { 'lsp', 'snippets', 'path', 'buffer' },
      per_filetype = {
        org = { 'orgmode', 'buffer' },
        sql = { 'snippets', 'dadbod', 'buffer' },
      },
      cmdline = {},
      providers = {
        dadbod = {
          name = 'Dadbod',
          module = 'vim_dadbod_completion.blink',
        },
        orgmode = {
          name = 'Orgmode',
          module = 'orgmode.org.autocompletion.blink',
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

          if expand_snippet() then
            return
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
