_G.kris = {}
-- Monkey patch lsp completion with modifications
vim.lsp.completion = require('partials.lsp_completion')
require('partials.abbreviations')
require('partials.settings')
require('partials.lazy')
require('partials.statusline')
require('partials.mappings')
