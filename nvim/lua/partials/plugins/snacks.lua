return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
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
        ui_select = true,
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
      layout = {
        select = {
          relative = 'cursor',
          row = 1,
          col = 3,
          bo = {
            buftype = '',
          },
        },
      },
    })

    vim.keymap.set('n', '<leader>gl', function()
      return Snacks.lazygit()
    end, { desc = 'Lazygit' })

    vim.keymap.set('n', '<leader>Z', function()
      return Snacks.zen.zen()
    end, { desc = 'Zen mode' })
    vim.keymap.set({ 'n', 'v' }, '<leader>gy', function()
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
    end, { desc = 'Git browse' })

    vim.keymap.set('n', '<C-p>', function()
      local should_open_symbols = false
      local last_item = nil
      local main_picker = Snacks.picker.files({
        on_change = function(_, item)
          if item then
            last_item = item
          end
        end,
        confirm = function(picker, item)
          if last_item and should_open_symbols then
            picker:close()
            vim.schedule(function()
              vim.cmd(('e %s'):format(last_item.cwd .. '/' .. last_item.file))
              Snacks.picker.lsp_symbols()
            end)
            return
          end
          vim.cmd(('e %s'):format(item.cwd .. '/' .. item.file))
        end,
      })

      local win = main_picker.input.win
      win:on(
        { 'TextChangedI' },
        Snacks.util.throttle(function()
          local line = win:line()
          if line:match('@$') then
            should_open_symbols = true
            main_picker:action('confirm')
            return
          end
        end, { ms = 30 })
      )
    end)
    vim.keymap.set('n', '<C-y>', function()
      return Snacks.picker.resume()
    end)
    vim.keymap.set('n', '<Leader>b', function()
      return Snacks.picker.buffers({
        sort_lastused = true,
      })
    end, { desc = 'Buffers' })
    vim.keymap.set('n', '<Leader>fg', function()
      return Snacks.picker.grep()
    end, { desc = 'Live grep' })
    vim.keymap.set('n', '<Leader>m', function()
      return Snacks.picker.recent({
        finder = 'recent_files',
        format = 'file',
      })
    end, { desc = 'Recent files' })
    vim.keymap.set('n', '<Leader>gs', function()
      return Snacks.picker.git_status()
    end, { desc = 'Git status' })

    vim.api.nvim_create_user_command('Notifications', function()
      Snacks.notifier.show_history()
    end, {
      nargs = 0,
    })
  end,
}
