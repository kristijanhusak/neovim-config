_G.kris.dap = {}
local utils = require'partials/utils'
local dap = require'dap'
local running_debug = false

vim.g.dap_virtual_text = true

utils.keymap('n', '<F1>', ':lua require"dap".toggle_breakpoint()<CR>')
utils.keymap('n', '<F2>', ':lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>')
utils.keymap('n', '<F3>', ':lua require"dap".set_breakpoint(nil, nil, vim.fn.input("Log point message: "))<CR>')
utils.keymap('n', '<F4>', ':lua require"dap.ui.variables".hover()<CR>')
utils.keymap('n', '<F6>', ':lua require"dap".repl.toggle()<CR>')

dap.adapters.node2 = {
  type = 'executable',
  command = 'node',
  args = {os.getenv('HOME') .. '/github/vscode-node-debug2/out/src/nodeDebug.js'},
}

dap.configurations.javascript = {
  {
    type = 'node2',
    request = 'attach',
    name = 'Attach to docker node.js',
    port = 9229,
    localRoot = '${workspaceFolder}',
    skipFiles = {
      "<node_internals>/**",
      "node_modules/**"
    },
    remoteRoot = '/src',
    protocol = 'inspector',
    console = 'integratedTerminal',
    restart = true,
  },
}

vim.cmd[[command! DebugStart call v:lua.kris.dap.start()]]
vim.cmd[[command! DebugStop call v:lua.kris.dap.stop()]]

function _G.kris.dap.start()
  dap.continue()
  print('Started debug mode.')
  running_debug = true
end

function _G.kris.dap.stop()
  dap.disconnect()
  print('Stopped debug mode.')
  running_debug = false
end

function _G.kris.dap.action(lhs, action)
  if not running_debug then
    return vim.fn.feedkeys(utils.esc(string.format('<%s>', lhs)), 'n')
  end
  dap[action]()
end

utils.keymap('n', '<Right>', ":call v:lua.kris.dap.action('right', 'step_over')<CR>")
utils.keymap('n', '<Up>', ":call v:lua.kris.dap.action('up', 'step_out')<CR>")
utils.keymap('n', '<Down>', ":call v:lua.kris.dap.action('down', 'step_into')<CR>")
utils.keymap('n', '<C-Up>', ":call v:lua.kris.dap.action('c-up', 'up')<CR>")
utils.keymap('n', '<C-Down>', ":call v:lua.kris.dap.action('c-down', 'down')<CR>")
