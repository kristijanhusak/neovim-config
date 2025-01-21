local TelescopePicker = {
  files = function()
    return require('telescope.builtin').find_files({ find_command = { 'rg', '--files', '--hidden', '-g', '!.git/' } })
  end,
  resume = function()
    return require('telescope.builtin').resume()
  end,
  buffers = function()
    return require('telescope.builtin').buffers({ sort_lastused = true })
  end,
  live_grep = function()
    return require('telescope.builtin').live_grep()
  end,
  recent_files = function()
    return require('telescope').extensions.recent_files.pick()
  end,
  git_status = function()
    return require('telescope.builtin').git_status()
  end,
  lsp_implementations = function()
    return require('telescope.builtin').lsp_implementations()
  end,
  lsp_definitions = function()
    return require('telescope.builtin').lsp_definitions()
  end,
  lsp_type_definitions = function()
    return require('telescope.builtin').lsp_type_definitions()
  end,
  lsp_document_symbols = function()
    require('telescope.builtin').lsp_document_symbols({
      symbols = { 'function', 'variable', 'method' },
      show_line = true,
    })
  end,
  lsp_references = function()
    return require('telescope.builtin').lsp_references({
      previewer = false,
      fname_width = (vim.o.columns * 0.4),
    })
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
}

local SnacksPicker = {
  files = function()
    return Snacks.picker.files()
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
    Snacks.picker.lsp_symbols()
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
vim.keymap.set('n', '<Leader>gs', function()
  return Picker.git_status()
end, { desc = 'Git status' })
vim.keymap.set('n', '<Leader>w', function()
  return Picker.workspaces()
end, { desc = 'Workspaces' })

return Picker
