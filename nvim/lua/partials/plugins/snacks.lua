return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  keys = {
    {
      '<leader>gl',
      function()
        Snacks.lazygit()
      end,
      desc = 'Lazygit',
    },
    {
      '<leader>Z',
      function()
        Snacks.zen.zen()
      end,
      desc = 'Zen mode',
    },
    {
      '<leader>gy',
      function()
        Snacks.gitbrowse.open({
          open = function(url)
            vim.fn.setreg('+', url)
            vim.ui.open(url)
            vim.notify('Opening url\n' .. url, vim.log.levels.INFO, {
              title = 'Git browse',
            })
          end,
          notify = false,
        })
      end,
      desc = 'Git browse',
      mode = { 'n', 'v' },
    },
  },
  config = function()
    require('snacks').setup({
      bigfile = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true, debounce = 100 },
      quickfile = { enabled = false },
      input = {
        enabled = true,
      },
      notifier = {
        enabled = true,
        top_down = false,
        margin = { bottom = 1 },
      },
      dim = {
        animate = {
          enabled = false,
          duration = {
            total = 0,
          },
        },
      },
      picker = {
        formatters = {
          file = {
            filename_first = true,
            truncate = 60
          }
        },
        sources = {
          files_with_symbols = {
            multi = { 'files', 'lsp_symbols' },
            filter = {
              ---@param p snacks.Picker
              ---@param filter snacks.picker.Filter
              transform = function(p, filter)
                local symbol_pattern = filter.pattern:match('^.-@(.*)$')
                local line_nr_pattern = filter.pattern:match('^.-:(%d*)$')
                local search_pattern = filter.pattern:match('^.-#(.*)$')
                local pattern = symbol_pattern or line_nr_pattern or search_pattern

                if pattern then
                  local item = p:current()
                  if item and item.file then
                    filter.meta.buf = vim.fn.bufadd(item.file)
                  end
                end

                if not filter.meta.buf then
                  filter.source_id = 1
                  return
                end

                if symbol_pattern then
                  filter.pattern = symbol_pattern
                  filter.current_buf = filter.meta.buf
                  filter.source_id = 2
                  return
                end

                if line_nr_pattern then
                  filter.pattern = filter.pattern:gsub(':%d*$', '')
                  filter.current_buf = filter.meta.buf
                  filter.source_id = 1
                  local item = p:current()
                  if item then
                    item.pos = { tonumber(line_nr_pattern) or 1, 0 }
                    p.preview:loc()
                  end
                  return
                end

                if search_pattern then
                  filter.pattern = filter.pattern:gsub('#.*$', '')
                  filter.current_buf = filter.meta.buf
                  filter.source_id = 1
                  if search_pattern == '' then
                    return
                  end
                  local item = p:current()
                  vim.api.nvim_buf_call(p.preview.win.buf, function()
                    vim.api.nvim_win_set_cursor(0, { 1, 0 })
                    local search = vim.fn.search(search_pattern, 'ncW')
                    if search > 0 then
                      vim.cmd('/' .. search_pattern)
                      if vim.fn.line('w$') < search then
                        vim.api.nvim_win_set_cursor(0, { math.max(1, search - 8), 0 })
                      end
                      item.pos = { search, 0 }
                    end
                  end)
                  return
                end

                filter.source_id = 1
              end,
            },
          },
        },
        ui_select = true,
        prompt = '   ',
        layout = {
          layout = {
            backdrop = false,
          },
        },
        layouts = {
          select = {
            layout = {
              relative = 'cursor',
              width = 70,
              min_width = 0,
              row = 1,
            },
          },
        },
        win = {
          input = {
            keys = {
              ['<Esc>'] = { 'close', mode = { 'n', 'i' } },
              ['<c-d>'] = { 'preview_scroll_down', mode = { 'i', 'n' } },
              ['<c-u>'] = { 'preview_scroll_up', mode = { 'i', 'n' } },
            },
          },
        },
      },
      dashboard = {
        enabled = false,
        sections = {
          { section = 'header' },
          { section = 'keys', gap = 1, padding = 1 },
          {
            title = 'Orgmode',
            icon = ' ',
          },
          {
            title = 'Agenda',
            indent = 3,
            action = ':lua require("orgmode").agenda:agenda()',
            key = 'a',
          },
          {
            title = 'Capture',
            indent = 3,
            action = '<leader>oc',
            key = 'C',
            padding = 1,
          },
          { icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 2 },
          { section = 'startup' },
        },
      },
      styles = {
        input = {
          relative = 'cursor',
          row = 1,
          col = 3,
          bo = {
            buftype = '',
          },
        },
      },
    })

    vim.api.nvim_create_user_command('Notifications', function()
      Snacks.notifier.show_history()
    end, {
      nargs = 0,
    })

    Snacks.picker.actions.qflist = function(picker, opts)
      picker:close()
      local sel = picker:selected()
      local items = #sel > 0 and sel or picker:items()
      local qf = {}
      for _, item in ipairs(items) do
        local text = item.text
        if vim.startswith(text, item.file) then
          text = text:sub(#item.file + 2)
        end
        qf[#qf + 1] = {
          filename = Snacks.picker.util.path(item),
          bufnr = item.buf,
          lnum = item.pos and item.pos[1] or 1,
          col = item.pos and item.pos[2] or 1,
          end_lnum = item.end_pos and item.end_pos[1] or nil,
          end_col = item.end_pos and item.end_pos[2] or nil,
          text = text,
          pattern = item.search,
          valid = true,
        }
      end
      if opts and opts.win then
        vim.fn.setloclist(opts.win, qf)
        vim.cmd('lopen')
      else
        vim.fn.setqflist(qf)
        vim.cmd('copen')
      end
    end
  end,
}
