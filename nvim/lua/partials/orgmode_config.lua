return {
  org_agenda_files = '~/Dropbox/org/*',
  org_default_notes_file = '~/Dropbox/org/refile.org',
  -- Experimental settings. Currently available only on feature/notifications branch of orgmode
  notifications = {
    reminder_time = {0, 1, 5, 10},
    repeater_reminder_time = {0, 1, 5, 10},
    deadline_warning_reminder_time = { 0 },
    cron_notifier = function(task)
    return vim.loop.spawn('notify-send', { args = {
      '--icon=/home/kristijan/.config/nvim/pack/packager/start/orgmode.nvim/assets/orgmode_nvim.png',
      string.format('%s (in %d min.)\n%s\n%s: %s', task.category, task.minutes, task.line, task.type, task.time:to_string()),
      }})
  end
  }
}
