return {
  'lukas-reineke/indent-blankline.nvim',
  event = 'VeryLazy',
  config = function()
    require('ibl').setup({
      indent = {
        char = '▏',
        highlight = 'IndentBlanklineChar',
      },
      scope = {
        highlight = 'IndentBlanklineContextChar',
        show_start = false,
        show_end = false,
        include = {
          node_type = {
            lua = {
              'chunk',
              'do_statement',
              'while_statement',
              'repeat_statement',
              'if_statement',
              'for_statement',
              'function_declaration',
              'function_definition',
              'table_constructor',
              'assignment_statement',
            },
            typescript = {
              'statement_block',
              'function',
              'arrow_function',
              'function_declaration',
              'method_definition',
              'for_statement',
              'for_in_statement',
              'catch_clause',
              'object_pattern',
              'arguments',
              'switch_case',
              'switch_statement',
              'switch_default',
              'object',
              'object_type',
              'ternary_expression',
            },
          },
        },
      },
    })
  end,
}
