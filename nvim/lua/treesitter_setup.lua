require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
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
      enable = true,
      peek_definition_code = {
        ["<Leader>y"] = "@function.outer",
        ["<Leader>Y"] = "@class.outer",
      },
    }
  },
  ensure_installed = {"javascript", "typescript", "php", "go", "python", "lua", "jsdoc"}
}

local patterns = {
  '%s*[%[%(%{]*%s*$',
  '%(.*%)',
  '%s*=>%s*$',
  '^async%s*',
  '^static%s*',
  '^function%s*'
}
function _G.custom_statusline()
return require'nvim-treesitter'.statusline({
    indicator_size = 80,
    transform_fn = function(line)
      for _, p in ipairs(patterns) do line = line:gsub(p, '') end
      return line
    end
  })
end
