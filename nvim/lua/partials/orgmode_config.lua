local org_path = function(path)
  local org_directory = '~/orgfiles'
  return ('%s/%s'):format(org_directory, path)
end

---@type OrgConfigOpts
return {
  org_agenda_files = org_path('**/*'),
  org_default_notes_file = org_path('refile.org'),
  org_hide_emphasis_markers = true,
  org_agenda_text_search_extra_files = { 'agenda-archives' },
  org_agenda_start_on_weekday = false,
  org_startup_indented = true,
  org_log_into_drawer = 'LOGBOOK',
  org_todo_keywords = { 'TODO(t)', 'PROGRESS(p)', '|', 'DONE(d)', 'REJECTED(r)' },
  org_agenda_custom_commands = {
    a = {
      description = 'Agenda',
      types = {
        {
          type = 'tags',
          match = 'REVISIT',
          org_agenda_overriding_header = 'Tasks to revisit',
        },
        {
          type = 'agenda',
          org_agenda_tag_filter_preset = '-REVISIT',
        },
      },
    },
  },
  org_capture_templates = {
    t = {
      description = 'Refile',
      template = '* TODO %?\nDEADLINE: %T',
    },
    T = {
      description = 'Todo',
      template = '* TODO %?\nDEADLINE: %T',
      target = org_path('todos.org'),
    },
    r = {
      description = 'Quick note',
      template = '* TODO %? :REVISIT:',
    },
    w = {
      description = 'Work todo',
      template = '* TODO %?\nDEADLINE: %T',
      target = org_path('work.org'),
    },
    n = {
      description = 'Code note',
      template = '* %(return _G.kris.get_workspace_name()) - %(return vim.fn.expand("%:t")) :CODENOTE:\n%a\n%?',
      target = org_path('code_notes.org'),
    },
    b = {
      description = 'BP log',
      template = '* %<%H:%M> - %?',
      target = org_path('bp_log.org'),
      datetree = true
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
          vim.system({
            'notify-send',
            '--icon=/home/kristijan/github/orgmode/assets/nvim-orgmode-small.png',
            '--app-name=orgmode',
            '--urgency=critical',
            title,
            string.format('%s\n%s', subtitle, date),
          })
        end
      end
    end,
  },
  ui = {
    agenda = {
      preview_window = {
        border = 'single',
        focusable = false,
      },
    },
  },
}
