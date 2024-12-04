return {
  'saghen/blink.cmp',
  lazy = false,
  enabled = function()
    return not require('partials.utils').enable_builtin_lsp_completion()
  end,
  version = '*',
  config = function()
    local tab = function()
      local utils = require('partials.utils')

      if vim.fn['vsnip#jumpable'](1) > 0 then
        utils.feedkeys('<Plug>(vsnip-jump-next)')
        return true
      end

      if vim.fn['vsnip#expandable']() > 0 then
        utils.feedkeys('<Plug>(vsnip-expand)')
        return true
      end

      if require('copilot.suggestion').is_visible() then
        require('copilot.suggestion').accept()
        return true
      end

      if utils.has_words_before() then
        require('copilot.suggestion').next()
        return true
      end

      return false
    end

    local stab = function()
      local utils = require('partials.utils')
      if vim.fn['vsnip#jumpable'](-1) == 1 then
        utils.feedkeys('<Plug>(vsnip-jump-prev)')
        return true
      end
      return false
    end

    require('blink.cmp').setup({
      sources = {
        completion = {
          enabled_providers = function()
            if vim.bo.filetype == 'sql' then
              return { 'dadbod' }
            end
            if vim.bo.filetype == 'org' then
              return { 'orgmode', 'buffer' }
            end
            return { 'lsp', 'path', 'snippets', 'buffer', 'dadbod' }
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
        },
      },
      completion = {
        list = {
          selection = 'auto_insert',
        },
        menu = {
          draw = {
            gap = 2,
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
          function()
            return tab()
          end,
          'select_and_accept',
          'fallback',
        },
        ['<S-tab>'] = {
          function()
            return stab()
          end,
          'fallback',
        },
      },
      snippets = {
        expand = function(snippet)
          vim.fn['vsnip#anonymous'](snippet)
        end,
        active = function(filter)
          if not filter or not filter.direction then
            return false
          end
          return vim.fn['vsnip#jumpable'](filter.direction) > 0
        end,
        jump = function(direction)
          if vim.fn['vsnip#jumpable'](direction) > 0 then
            local session = vim.fn['vsnip#get_session']()
            if session then
              session.jump(direction)
            end
          end
        end,
      },
    })

    vim.keymap.set('s', '<Tab>', function()
      local exec = tab()

      if not exec then
        return require('partials.utils').feedkeys('<Tab>')
      end
    end, { noremap = false })
    vim.keymap.set('s', '<S-Tab>', function()
      local exec = stab()

      if not exec then
        return require('partials.utils').feedkeys('<S-Tab>')
      end
    end, { noremap = false })
  end,
}
