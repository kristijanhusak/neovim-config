local org_path = function(path)
  local org_directory = '~/orgfiles'
  return ('%s/%s'):format(org_directory, path)
end

local orgmode = {
  'nvim-orgmode/orgmode',
  dev = true,
  dependencies = {
    { 'akinsho/org-bullets.nvim' },
  },
  ft = { 'org', 'orgagenda' },
  keys = {
    { '<leader>oa', '<Cmd>lua require("orgmode").action("agenda.prompt")<CR>' },
    { '<leader>oc', '<Cmd>lua require("orgmode").action("capture.prompt")<CR>' },
  },
}

local orgmode_config = {
  org_agenda_files = org_path('**/*'),
  org_default_notes_file = org_path('refile.org'),
  org_hide_emphasis_markers = true,
  org_agenda_text_search_extra_files = { 'agenda-archives' },
  org_agenda_start_on_weekday = false,
  org_startup_indented = true,
  org_log_into_drawer = 'LOGBOOK',
  org_todo_keywords = { 'TODO(t)', 'PROGRESS(p)', '|', 'DONE(d)', 'REJECTED(r)' },
  org_capture_templates = {
    t = {
      description = 'Refile',
      template = '* TODO %?\n  DEADLINE: %T',
    },
    T = {
      description = 'Todo',
      template = '* TODO %?\n  DEADLINE: %T',
      target = org_path('todos.org'),
    },
    w = {
      description = 'Work todo',
      template = '* TODO %?\n  DEADLINE: %T',
      target = org_path('work.org'),
    },
    d = {
      description = 'Daily',
      template = '* Daily %U \n  %?',
      target = org_path('work.org'),
      headline = 'Meetings',
    },
  },
  notifications = {
    reminder_time = { 0, 1, 5, 10 },
    repeater_reminder_time = { 0, 1, 5, 10 },
    deadline_warning_reminder_time = { 0 },
    cron_notifier = function(tasks)
      for _, task in ipairs(tasks) do
        local title = string.format('%s (%s)', task.category, task.humanized_duration)
        local subtitle = string.format('%s %s %s', string.rep('*', task.level), task.todo, task.title)
        local date = string.format('%s: %s', task.type, task.time:to_string())

        if vim.fn.executable('notify-send') then
          vim.loop.spawn('notify-send', {
            args = {
              '--icon=/home/kristijan/.local/share/nvim/lazy/orgmode/assets/nvim-orgmode-small.png',
              string.format('%s\n%s\n%s', title, subtitle, date),
            },
          })
        end
      end
    end,
  },
}

orgmode.orgmode_config = orgmode_config

orgmode.config = function()
  require('orgmode').setup_ts_grammar()
  require('orgmode').setup(orgmode_config)
  require('org-bullets').setup({
    concealcursor = true,
    symbols = {
      checkboxes = {
        half = { '', 'OrgTSCheckboxHalfChecked' },
        done = { '✓', 'OrgDone' },
        todo = { ' ', 'OrgTODO' },
      },
    },
  })

  local set_cr_mapping = function()
    vim.keymap.set('i', '<S-CR>', '<cmd>lua require("orgmode").action("org_mappings.meta_return")<CR>', {
      silent = true,
      buffer = true,
    })
  end

  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'org',
    callback = set_cr_mapping,
  })

  if vim.bo.filetype == 'org' then
    set_cr_mapping()
  end

  return orgmode
end

return orgmode
