vim.pack.load({
  src = 'olimorris/codecompanion.nvim',
  event = 'VeryLazy',
  dependencies = {
    'ravitemer/codecompanion-history.nvim',
  },
  config = function()
    vim.keymap.set({ 'n', 'x' }, '<leader>ea', function()
      vim.cmd('CodeCompanionActions')
    end, { desc = 'Open Code Companion Actions' })
    vim.keymap.set({ 'n', 'x' }, '<leader>ee', function()
      vim.cmd('CodeCompanionChat')
    end, { desc = 'Open Code Companion Chat' })

    require('codecompanion').setup({
      extensions = {
        history = {
          enabled = true,
          opts = {
            picker = 'default',
          },
        },
      },
      strategies = {
        chat = { adapter = 'copilot' },
        inline = { adapter = 'copilot' },
      },
      adapters = {
        http = {
          gemini = function()
            return require('codecompanion.adapters').extend('gemini', {
              env = {
                api_key = vim.env.GEMINI_API_KEY,
              },
            })
          end,
        },
      },
    })

    vim.api.nvim_create_autocmd({ 'User' }, {
      pattern = 'CodeCompanionRequest*',
      group = vim.api.nvim_create_augroup('CodeCompanionStatus', { clear = true }),
      callback = function(request)
        if request.match == 'CodeCompanionRequestStarted' then
          Snacks.notify.info('  CodeCompanion Running...', {
            id = 'codecompanion_status',
            timeout = 0,
          })
        elseif request.match == 'CodeCompanionRequestFinished' then
          Snacks.notifier.hide('codecompanion_status')
        end
      end,
    })
  end,
})
