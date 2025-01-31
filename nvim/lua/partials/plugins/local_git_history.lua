return {
  'm42e/lgh.nvim',
  event = 'VeryLazy',
  config = function()
    local lgh = require('lgh')
    lgh.setup({})

    local function on_open(file)
      vim.cmd(('vsplit %s'):format(file))
      vim.bo.buftype = 'nofile'
      vim.bo.modifiable = false
      vim.bo.readonly = true
    end

    vim.api.nvim_create_user_command('LGHFind', function()
      local path = ('%s%s/%s'):format(lgh.config.basedir, vim.fn.hostname(), vim.uv.cwd())
      Snacks.picker.files({
        cwd = path,
        confirm = function(picker)
          local file = picker:current()
          picker:close()
          on_open(file._path)
        end,
      })
    end, {
      nargs = 0,
    })
    vim.api.nvim_create_user_command('LGH', function(args)
      local file = args.fargs[1] and vim.fn.fnamemodify(args.fargs[1], ':p') or vim.fn.expand('%:p')
      local path = ('%s%s/%s'):format(lgh.config.basedir, vim.fn.hostname(), file)
      if not vim.uv.fs_stat(path) then
        return vim.notify('No history found for this file', vim.log.levels.WARN)
      end
      on_open(path)
    end, {
      nargs = '?',
      complete = 'file'
    })
  end,
}
