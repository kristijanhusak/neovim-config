return {
  'ibhagwan/fzf-lua',
  init = function()
    vim.keymap.set('n', '<C-p>', function()
      return require('fzf-lua').files({ headers = false })
    end)
    vim.keymap.set('n', '<C-y>', function()
      return require('fzf-lua').resume()
    end)
    vim.keymap.set('n', '<Leader>b', function()
      return require('fzf-lua').buffers()
    end)
    vim.keymap.set('n', '<Leader>m', function()
      return require('fzf-lua').oldfiles()
    end)
    vim.keymap.set('n', '<Leader>g', function()
      return require('fzf-lua').git_status({ headers = false })
    end)
    vim.keymap.set('n', '<Leader>lt', function()
      return require('fzf-lua').btags()
    end)
  end,

  config = function()
    local actions = require('fzf-lua.actions')
    require('fzf-lua').setup({
      headers = false,
      winopts = {
        width = 0.9,
        preview = {
          horizontal = 'right:50%',
        },
      },
      keymap = {
        fzf = {
          ['ctrl-d'] = 'preview-page-down',
          ['f4'] = 'toggle-preview',
          ['ctrl-u'] = 'preview-page-up',
          ['ctrl-q'] = 'select-all+accept',
        },
      },
      actions = {
        files = {
          ['default'] = actions.file_edit_or_qf,
          ['ctrl-s'] = actions.file_split,
          ['ctrl-v'] = actions.file_vsplit,
          ['ctrl-t'] = actions.file_tabedit,
          ['ctrl-r'] = function(...)
            actions.file_edit_or_qf(...)
            vim.schedule(function()
              require('fzf-lua').lsp_document_symbols()
            end)
          end,
          ['ctrl-l'] = function(...)
            actions.file_edit_or_qf(...)
            vim.schedule(function()
              require('fzf-lua').lines()
            end)
          end,
        },
      },
      oldfiles = {
        include_current_session = true,
      },
    })
  end,
}
