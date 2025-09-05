local SnacksPicker = {
  files = function()
    return Snacks.picker.files_with_symbols()
  end,
  resume = function()
    return Snacks.picker.resume()
  end,
  buffers = function()
    return Snacks.picker.buffers()
  end,
  live_grep = function()
    return Snacks.picker.grep({ live = true })
  end,
  recent_files = function()
    return Snacks.picker.recent()
  end,
  smart = function()
    return Snacks.picker.smart()
  end,
  git_status = function()
    return Snacks.picker.git_status()
  end,
  lsp_implementations = function()
    return Snacks.picker.lsp_implementations()
  end,
  lsp_definitions = function()
    return Snacks.picker.lsp_definitions()
  end,
  lsp_type_definitions = function()
    return Snacks.picker.lsp_type_definitions()
  end,
  lsp_document_symbols = function()
    Snacks.picker.lsp_symbols({
      filter = {
        default = {
          'Class',
          'Constructor',
          'Enum',
          'Field',
          'Function',
          'Interface',
          'Method',
          'Module',
          'Namespace',
          'Package',
          'Property',
          'Struct',
          'Trait',
          'Constant'
        },
      },
    })
  end,
  lsp_references = function()
    return Snacks.picker.lsp_references()
  end,
  workspaces = function()
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
  end,
  rest = function()
    return Snacks.picker.files({
      cwd = '~/code/requests',
      confirm = function(picker, item)
        if not item then
          return vim.cmd.edit(('~/code/requests/%s.http'):format(picker.finder.filter.pattern))
        end
        return picker:action('jump')
      end,
    })
  end,
}

local Picker = SnacksPicker

vim.keymap.set('n', '<C-p>', function()
  return Picker.files()
end)
vim.keymap.set('n', '<C-y>', function()
  return Picker.resume()
end)
vim.keymap.set('n', '<Leader>b', function()
  return Picker.buffers()
end, { desc = 'Buffers' })
vim.keymap.set('n', '<Leader>fg', function()
  return Picker.live_grep()
end, { desc = 'Live grep' })
vim.keymap.set('n', '<Leader>m', function()
  return Picker.recent_files()
end, { desc = 'Recent files' })
vim.keymap.set('n', '<Leader>r', function()
  return Picker.smart()
end, { desc = 'Smart picker' })
vim.keymap.set('n', '<Leader>gs', function()
  return Picker.git_status()
end, { desc = 'Git status' })
vim.keymap.set('n', '<Leader>R', function()
  return Picker.rest()
end, { desc = 'Requests' })

return Picker
