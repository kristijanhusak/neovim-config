return {
  'natecraddock/workspaces.nvim',
  cmd = { 'WorkspacesAdd', 'WorkspacesOpen' },
  init = function()
    vim.keymap.set('n', '<Leader>w', function()
      return require('telescope').extensions.workspaces.workspaces()
    end, { desc = 'Workspaces' })
  end,
  config = function()
    require('workspaces').setup({
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
