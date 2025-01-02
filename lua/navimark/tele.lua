local stack = require("navimark.stack")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local action_state = require("telescope.actions.state")

local M = {}

M.attach_mappings = nil

local picker = {}

local previewer = previewers.new_buffer_previewer({
  title = "Preview",
  define_preview = function(self, entry)
    local content = vim.fn.readfile(entry.value.file)
    vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, content)

    local ft = vim.filetype.match({ filename = entry.value.file })
    if ft then
      vim.bo[self.state.bufnr].filetype = ft
    end

    vim.schedule(function()
      vim.api.nvim_win_set_cursor(self.state.winid, { entry.value.line, 0 })
      vim.api.nvim_buf_add_highlight(self.state.bufnr, -1, "TelescopeSelection", entry.value.line - 1, 0, -1)
    end)
  end,
})

local entry_to_pos = function(entry)
  return {
    file = entry.file,
    line = entry.line,
    bufnr = vim.fn.bufadd(entry.file),
  }
end

local new_picker = function()
  local current_stack = stack.get_current_stack()
  picker = pickers.new({}, {
    prompt_title = current_stack.name,
    finder = finders.new_table({
      results = current_stack.marks,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.file .. ":" .. entry.line,
          ordinal = 1,
        }
      end,
    }),
    previewer = previewer,
    attach_mappings = function(_, map)
      if M.attach_mappings then
        M.attach_mappings(map)
      end
      return true
    end,
  })
  picker:find()
end

M.delete_mark = function()
  local selection = action_state.get_selected_entry()
  if not selection then
    return
  end
  local pos = entry_to_pos(selection.value)
  stack.delete_mark(pos)
  new_picker()
end

M.open_bookmark_picker = function()
  new_picker()
end

M.new_stack = function()
  stack.new_stack()
  M.next_stack()
end

M.next_stack = function()
  stack.next_stack()
  new_picker()
end

M.prev_stack = function()
  stack.prev_stack()
  new_picker()
end

M.rename_stack = function()
  stack.rename_stack()
  new_picker()
end

M.delete_stack = function()
  stack.delete_stack()
  new_picker()
end

M.clear_marks = function()
  stack.clear_marks()
  new_picker()
end

return M
