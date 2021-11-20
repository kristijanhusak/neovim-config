return {
  org_agenda_files = '~/Dropbox/org/**/*',
  org_default_notes_file = '~/Dropbox/org/refile.org',
  org_hide_emphasis_markers = true,
  org_agenda_text_search_extra_files = { 'agenda-archives' },
  org_agenda_start_on_weekday = false,
  org_todo_keywords = { 'TODO(t)', 'PROGRESS(p)', '|', 'DONE(d)', 'REJECTED(r)' },
  org_agenda_templates = {
    T = {
      description = 'Todo',
      template = '* TODO %?\n  DEADLINE: %T',
      target = '~/Dropbox/org/todos.org',
    },
    w = {
      description = 'Work todo',
      template = '* TODO %?\n  DEADLINE: %T',
      target = '~/Dropbox/org/work.org',
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
