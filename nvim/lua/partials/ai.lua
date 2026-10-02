local agentic = require('partials.agentic')

agentic.new({
  provider = 'claude',
  keymap_prefix = 'k',
  env = {
    CLAUDE_CONFIG_DIR = vim.fs.normalize('~/.claude'),
  },
})
agentic.new({
  provider = 'claude',
  name = 'claude-work',
  keymap_prefix = 'a',
  env = { CLAUDE_CONFIG_DIR = vim.fs.normalize('~/.claude-work') },
})
agentic.new({ provider = 'copilot', keymap_prefix = 'z' })
