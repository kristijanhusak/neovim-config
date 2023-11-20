local M = {}

function M.make()
  local lines = {}
  local winnr = vim.fn.win_getid()
  local bufnr = vim.api.nvim_win_get_buf(winnr)

  local makeprg = vim.bo[bufnr].makeprg
  if not makeprg then
    return
  end

  local cmd = vim.fn.expandcmd(makeprg)

  local function on_event(_, data, event)
    if event == 'stdout' or event == 'stderr' then
      if data then
        vim.list_extend(
          lines,
          vim.tbl_filter(function(line)
            return vim.trim(line) ~= ''
          end, data)
        )
      end
    end

    if event == 'exit' then
      vim.fn.setqflist({}, ' ', {
        title = cmd,
        lines = lines,
        efm = vim.bo[bufnr].errorformat,
      })
      if #lines == 0 then
        print('No output from make command')
      else
        print(('make returned %d entries'):format(#vim.fn.getqflist()))
      end
      vim.cmd('doautocmd QuickFixCmdPost')
    end
  end

  print('Running make...')
  local job_id = vim.fn.jobstart(cmd, {
    on_stderr = on_event,
    on_stdout = on_event,
    on_exit = on_event,
    stdout_buffered = true,
    stderr_buffered = true,
  })
end

vim.api.nvim_create_user_command('Make', M.make, {
  force = true,
})
