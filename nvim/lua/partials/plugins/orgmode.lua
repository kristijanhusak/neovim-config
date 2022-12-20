local org_path = function(path)
  local org_directory = '~/orgfiles'
  return ('%s/%s'):format(org_directory, path)
end

local orgmode = {
  'nvim-orgmode/orgmode',
  dependencies = {
    'akinsho/org-bullets.nvim',
  },
  event = 'VeryLazy',
}

local orgmode_config = {
  org_agenda_files = org_path('**/*'),
  org_default_notes_file = org_path('refile.org'),
  org_hide_emphasis_markers = true,
  org_agenda_text_search_extra_files = { 'agenda-archives' },
  org_agenda_start_on_weekday = false,
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
              '--icon=/home/kristijan/.config/nvim/pack/packager/start/orgmode/assets/orgmode_nvim.png',
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
  return orgmode
end

return orgmode
