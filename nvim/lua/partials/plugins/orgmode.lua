local orgmode_config = {
  org_agenda_files = '~/orgfiles/**/*',
  org_default_notes_file = '~/orgfiles/refile.org',
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
      target = '~/orgfiles/todos.org',
    },
    w = {
      description = 'Work todo',
      template = '* TODO %?\n  DEADLINE: %T',
      target = '~/orgfiles/work.org',
    },
    d = {
      description = 'Daily',
      template = '* Daily %U \n  %?',
      target = '~/orgfiles/work.org',
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

local orgmode = {
  install = function(packager)
    packager.add('nvim-orgmode/orgmode')
    packager.add('akinsho/org-bullets.nvim')
  end,
  orgmode_config = orgmode_config,
}

orgmode.setup = function()
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
