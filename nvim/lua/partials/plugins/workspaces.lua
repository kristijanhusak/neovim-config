return {
  'natecraddock/workspaces.nvim',
  cmd = { 'WorkspacesAdd', 'WorkspacesOpen' },
  init = function()
    vim.keymap.set('n', '<Leader>w', function()
      local workspaces = {}
      for _, workspace in ipairs(require('workspaces').get()) do
        workspaces[workspace.path] = workspace.name
      end
      return require('fzf-lua').fzf_exec(vim.tbl_keys(workspaces), {
        actions = {
          ['default'] = function(selected)
            vim.cmd(('WorkspacesOpen %s'):format(workspaces[selected[1]]))
          end,
        }
      })
    end)
  end,
  config = function()
    local workspaces = require('workspaces')
    workspaces.setup({
      path = vim.fs.normalize('~/Dropbox/workspaces'),
      hooks = {
        open = function()
          vim.notify((' Switched to project: %s '):format(vim.fn.getcwd()))
          local local_nvimrc = vim.fn.getcwd() .. '/.nvimrc'
          if vim.secure.read(local_nvimrc) then
            vim.cmd.source(local_nvimrc)
          end
        end,
      },
    })
  end,
}
