vim.pack.load({
  src = 'folke/snacks.nvim',
  config = function()
    vim.keymap.set('n', '<leader>gl', function()
      return Snacks.lazygit()
    end, { silent = true, desc = 'Lazygit' })

    vim.keymap.set('n', '<leader>Z', function()
      return Snacks.zen.zen()
    end, { silent = true, desc = 'Zen mode' })
    vim.keymap.set({ 'n', 'v' }, '<leader>gy', function()
      return Snacks.gitbrowse.open({
        open = function(url)
          vim.fn.setreg('+', url)
          vim.ui.open(url)
          vim.notify('Opening url\n' .. url, vim.log.levels.INFO, {
            title = 'Git browse',
          })
        end,
        notify = false,
      })
    end, { silent = true, desc = 'Git browse' })

    require('snacks').setup({
      bigfile = { enabled = true },
      statuscolumn = { enabled = true },
      quickfile = { enabled = false },
      input = {
        enabled = true,
      },
      image = {},
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
      terminal = {
        win = {
          wo = {
            winbar = '',
          },
        },
      },
      picker = {
        formatters = {
          file = {
            truncate = 80,
          },
        },
        previewers = {
          diff = {
            style = 'syntax',
          },
        },
        icons = {
          git = {
            staged = '✓',
            deleted = '',
            ignored = ' ',
            modified = '✗',
            renamed = '',
            unmerged = ' ',
            untracked = '★',
          },
        },
        sources = {
          lsp_symbols = {
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
                'Constant',
              },
            },
          },
          files_with_symbols = {
            title = 'Files',
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
        layout = 'custom_telescope',
        layouts = {
          custom_telescope = {
            layout = {
              box = 'horizontal',
              backdrop = false,
              width = 0.8,
              height = 0.9,
              border = 'none',
              {
                box = 'vertical',
                {
                  win = 'input',
                  height = 1,
                  border = 'solid',
                  -- title = '{title} {live} {flags}',
                  -- title_pos = 'center',
                },
                { win = 'list', border = 'solid' },
              },
              {
                win = 'preview',
                title = '{preview:Preview}',
                width = 0.45,
                border = 'solid',
                title_pos = 'center',
              },
            },
          },
          select = {
            preview = false,
            layout = {
              backdrop = false,
              width = 70,
              row = 1,
              min_width = 0,
              height = 0.4,
              min_height = 3,
              box = 'vertical',
              relative = 'cursor',
              border = 'none',
              title = '{title}',
              title_pos = 'center',
              { win = 'input', height = 1, border = 'none' },
              { win = 'list', border = 'none' },
              { win = 'preview', title = '{preview}', height = 0.4, border = 'none' },
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

    vim.keymap.set('n', '<leader>T', function()
      return Snacks.terminal.toggle()
    end, { desc = 'Toggle terminal' })
    vim.keymap.set('t', '<leader>T', function()
      vim.cmd('stopinsert')
      return Snacks.terminal.toggle()
    end, { desc = 'Close terminal' })

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
      vim.schedule(function()
        vim.w.quickfix_title = picker.title
      end)
    end
  end,
})
