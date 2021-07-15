return {
  org_agenda_files = '~/Dropbox/org/*',
  org_default_notes_file = '~/Dropbox/org/refile.org',
  -- Experimental settings. Currently available only on feature/notifications branch of orgmode
  notifications = {
    reminder_time = {0, 1, 5, 10},
    repeater_reminder_time = {0, 1, 5, 10},
    deadline_warning_reminder_time = { 0 },
    cron_notifier = function(tasks)
      for _, task in ipairs(tasks) do
        local title = string.format('%s (in %d min.)', task.category, task.minutes)
        local subtitle = string.format('%s %s %s', string.rep('*', task.level), task.todo, task.title)
        local date = string.format('%s: %s', task.type, task.time:to_string())

        vim.loop.spawn('notify-send', { args = {
          '--icon=/home/kristijan/.config/nvim/pack/packager/start/orgmode.nvim/assets/orgmode_nvim.png',
          string.format('%s\n%s\n%s', title, subtitle, date),
        }})
      end
    end
  }
}
