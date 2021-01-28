_G.kris.treesitter = {}

vim.cmd [[augroup vimrc_treesitter]]
  vim.cmd [[autocmd!]]
  vim.cmd [[autocmd FocusGained * ++nested call v:lua.kris.treesitter.reset_on_focus()]]
vim.cmd [[augroup END]]

function _G.kris.treesitter.reset_on_focus()
  if not vim.bo.modifiable or vim.bo.buftype == 'quickfix' or vim.fn.filereadable(vim.fn.expand('%')) == 0 then return end
  if vim.bo.modified then
    vim.cmd[[write]]
  end
  vim.cmd[[edit]]
end

require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
  },
  playground = {
    enable = true,
    disable = {},
    updatetime = 25,
    persist_queries = false
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = 'gnn',
      node_incremental = ".",
      scope_incremental = "grc",
      node_decremental = ",",
    }
  },
  refactor = {
    highlight_definitions = {
      enable = true
    },
    smart_rename = {
      enable = true,
      keymaps = {
        smart_rename = "grr"
      }
    },
    navigation = {
      enable = true,
      keymaps = {
        goto_definition = "gnd",
        list_definitions = "gnD"
      }
    }
  },
  textobjects = {
    enable = true,
    disable = {},
    select = {
      enable = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["aC"] = "@class.outer",
        ["iC"] = "@class.inner",
        ["ac"] = "@conditional.outer",
        ["ic"] = "@conditional.inner",
        ["ae"] = "@block.outer",
        ["ie"] = "@block.inner",
        ["al"] = "@loop.outer",
        ["il"] = "@loop.inner",
        ["is"] = "@statement.inner",
        ["as"] = "@statement.outer",
        ["ad"] = "@comment.outer",
        ["am"] = "@call.outer",
        ["im"] = "@call.inner"
      }
    },
    swap = {
      enable = true,
      swap_next = {
        ["<leader>a"] = "@parameter.inner",
      },
      swap_previous = {
        ["<leader>A"] = "@parameter.inner",
      },
    },
    move = {
      enable = true,
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = "@class.outer",
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["]["] = "@class.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@class.outer",
      },
    },
    lsp_interop = {
      enable = false,
    }
  },
  ensure_installed = {"javascript", "typescript", "php", "go", "python", "lua", "jsdoc"}
}
