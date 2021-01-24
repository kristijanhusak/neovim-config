_G.kris.dap = {}
local utils = require'partials/utils'
local dap = require'dap'

vim.g.dap_virtual_text = true

utils.keymap('n', '<F5>', ':lua require"dap".continue()<CR>')
utils.keymap('n', '<F10>', ':lua require"dap".step_over()<CR>')
utils.keymap('n', '<F11>', ':lua require"dap".step_into()<CR>')
utils.keymap('n', '<F12>', ':lua require"dap".step_out()<CR>')
utils.keymap('n', '<F1>', ':lua require"dap".toggle_breakpoint()<CR>')
utils.keymap('n', '<F2>', ':lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>')
utils.keymap('n', '<F3>', ':lua require"dap".set_breakpoint(nil, nil, vim.fn.input("Log point message: "))<CR>')
utils.keymap('n', '<F4>', ':lua require"dap.ui.variables".hover()<CR>')
utils.keymap('n', '<F6>', ':lua require"dap".repl.open()<CR>')
utils.keymap('n', '<F7>', ':lua require"dap".repl.run_last()<CR>')

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
