local comment = {
  install = function(packager)
    return packager.add('numToStr/Comment.nvim')
  end,
}
comment.setup = function()
  require('Comment').setup()
  return comment
end

return comment
