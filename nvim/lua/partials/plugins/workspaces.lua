return {
  'natecraddock/workspaces.nvim',
  cmd = { 'WorkspacesAdd', 'WorkspacesOpen' },
  init = function()
    vim.keymap.set('n', '<Leader>w', function()
      local items = {}
      local longest_name = 0
      for i, workspace in ipairs(require('workspaces').get()) do
        table.insert(items, {
          idx = i,
          score = i,
          text = workspace.path,
          name = workspace.name,
        })
        longest_name = math.max(longest_name, #workspace.name)
      end
      longest_name = longest_name + 2
      return Snacks.picker({
        items = items,
        format = function(item)
          local ret = {}
          ret[#ret + 1] = { ('%-' .. longest_name .. 's'):format(item.name), 'SnacksPickerLabel' }
          ret[#ret + 1] = { item.text, 'SnacksPickerComment' }
          return ret
        end,
        confirm = function(picker, item)
          picker:close()
          vim.cmd(('WorkspacesOpen %s'):format(item.name))
        end,
      })
    end)
  end,
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
          local local_nvimrc = vim.fn.getcwd() .. '/.nvimrc'
          if vim.secure.read(local_nvimrc) then
            vim.cmd.source(local_nvimrc)
          end
        end,
      },
    })
  end,
}
