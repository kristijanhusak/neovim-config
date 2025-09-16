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
    {
      '<leader>op',
      function()
        Snacks.picker.files({
          cwd = '~/orgfiles',
          ft = 'org',
        })
      end,
    },
  },
}

orgmode.config = function()
  require('orgmode').setup(require('partials.orgmode_config'))
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
