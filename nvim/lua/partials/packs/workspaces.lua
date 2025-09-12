vim.pack.load({
  src = 'natecraddock/workspaces.nvim',
  config = function()
    require('workspaces').setup({
      path = vim.fs.normalize('~/Dropbox/workspaces'),
      hooks = {
        open = function()
          local workspace_name = require('workspaces').name()
          local workspace_path = require('workspaces').path()
          vim.notify((' Switched to project: %s\n %s'):format(workspace_name, workspace_path), vim.log.levels.INFO, {
            title = 'Workspaces',
          })
          local local_nvimrc = vim.fn.getcwd() .. '/.nvim.lua'
          if vim.secure.read(local_nvimrc) then
            vim.cmd.source(local_nvimrc)
          end
        end,
      },
    })

    vim.keymap.set('n', '<leader>w', function()
      return require('partials.picker').workspaces()
    end, { desc = 'Workspaces' })
  end,
})
