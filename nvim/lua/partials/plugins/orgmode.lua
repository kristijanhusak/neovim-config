local org_path = function(path)
  local org_directory = '~/orgfiles'
  return ('%s/%s'):format(org_directory, path)
end

local orgmode = {
  'nvim-orgmode/orgmode',
  dev = true,
  dependencies = {
    { 'nvim-orgmode/org-bullets.nvim' },
  },
  ft = { 'org', 'orgagenda' },
  keys = {
    {
      '<leader>oa',
      function()
        return Org.agenda()
      end,
    },
    {
      '<leader>oc',
      function()
        return Org.capture()
      end,
    },
  },
}

---@type OrgConfigOpts
local orgmode_config = {
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
}

orgmode.orgmode_config = orgmode_config

orgmode.config = function()
  require('orgmode').setup(orgmode_config)
  require('org-bullets').setup({
    concealcursor = true,
    symbols = {
      checkboxes = {
        half = { '', '@org.checkbox.halfchecked' },
        done = { '✓', '@org.checkbox.checked' },
        todo = { ' ', '@org.checkbox' },
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

  -- Preview the agenda item content with <Space>
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'orgagenda',
    callback = function(event)
      vim.keymap.set('n', '<Space>', function()
        local headline = require('orgmode.api.agenda').get_headline_at_cursor()
        if not headline then
          return
        end
        -- TODO: Expose lines in the API
        local lines = headline._section:get_lines()
        local width = lines[1]:len() + 4 -- Add 4 columns buffer
        vim.tbl_map(function(line)
          width = math.max(width, line:len() + 4)
        end, lines)
        local buf = vim.lsp.util.open_floating_preview(lines, '', {
          border = 'single',
          wrap = false,
          width = width,
        })
        vim.api.nvim_set_option_value('filetype', 'org', { buf = buf })
      end, {
        buffer = event.buf,
      })
    end,
  })

  vim.api.nvim_create_user_command('OrgGenerateToc', function(...)
    local file = require('orgmode').files:get_current_file()
    local toc = {}
    local min_level = tonumber(vim.fn.input('Min level: ', '2'))
    local max_level = tonumber(vim.fn.input('Max level: ', '10'))

    ---@param headline OrgHeadline
    ---@param level? number
    local function generate_toc(headline, level)
      if level > max_level then
        return
      end

      if level >= min_level then
        local content = {}
        table.insert(content, ('%s-'):format((' '):rep((level - min_level) * 2)))
        local custom_id = headline:get_property('CUSTOM_ID')
        local link = custom_id and ('#%s'):format(custom_id) or ('*%s'):format(headline:get_title())
        local desc = headline:get_title()
        table.insert(content, ('[[%s][%s]]'):format(link, desc))
        table.insert(toc, table.concat(content, ' '))
      end

      for _, child in ipairs(headline:get_child_headlines()) do
        generate_toc(child, level + 1)
      end
    end

    for _, top_headline in ipairs(file:get_top_level_headlines()) do
      generate_toc(top_headline, 1)
    end

    vim.api.nvim_buf_set_lines(0, vim.fn.line('.') - 1, vim.fn.line('.') - 1, false, toc)
  end, {
    nargs = 0,
  })

  return orgmode
end

return orgmode
