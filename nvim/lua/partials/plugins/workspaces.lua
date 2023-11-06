return {
  'natecraddock/workspaces.nvim',
  cmd = { 'WorkspacesAdd', 'WorkspacesOpen' },
  opts = {
    path = vim.fs.normalize('~/Dropbox/workspaces'),
    hooks = {
      open = function()
        vim.notify((' Switched to project: %s '):format(vim.fn.getcwd()))
      end,
    },
  },
}
