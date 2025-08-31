local stack = require("navimark.stack")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local conf = require("telescope.config").values

local M = {}

M.picker_mappings = nil

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
      vim.api.nvim_set_option_value("cursorline", true, { win = self.state.winid })
      vim.api.nvim_win_set_cursor(self.state.winid, { entry.value.line, 0 })
    end)
  end,
})

local function create_finder(current_stack)
  return finders.new_table({
    results = current_stack.marks,
    entry_maker = function(entry)
      local title = (entry.title or "") .. ":"
      return {
        display = title .. entry.file .. ":" .. entry.line,
        value = entry,
        ordinal = entry.file .. entry.line,
      }
    end,
  })
end

local entry_to_pos = function(entry)
  return {
    file = entry.file,
    line = entry.line,
    bufnr = vim.fn.bufadd(entry.file),
  }
end

local new_picker = function()
  local current_stack = stack.get_current_stack()
  stack.correct_marks(current_stack)
  pickers
    .new({}, {
      prompt_title = current_stack.name,
      finder = create_finder(current_stack),
      sorter = conf.generic_sorter({}),
      previewer = previewer,
      attach_mappings = function(_, map)
        actions.select_default:replace(function(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          vim.api.nvim_command("edit " .. selection.value.file)
          vim.api.nvim_win_set_cursor(0, { selection.value.line, 0 })
        end)
        if M.picker_mappings then
          M.picker_mappings(map)
        end
        return true
      end,
    })
    :find()
end

local refresh_picker = function(prompt_bufnr)
  local current_stack = stack.get_current_stack()
  local finder = create_finder(current_stack)
  action_state.get_current_picker(prompt_bufnr):refresh(finder)
end

M.delete_mark = function(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  local pos = entry_to_pos(selection.value)
  stack.mark_remove(pos)
  refresh_picker(prompt_bufnr)
end

M.clear_marks = function(prompt_bufnr)
  stack.clear_marks()
  refresh_picker(prompt_bufnr)
end

M.set_mark_title = function(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  local title = vim.fn.input("Enter title for mark: ", selection.value.title or "")
  local pos = entry_to_pos(selection.value)

  stack.set_mark_title(title, pos)
  refresh_picker(prompt_bufnr)
end

M.open_mark_picker = function()
  new_picker()
end

M.new_stack = function()
  local name = vim.fn.input("Enter name for new stack: ")
  stack.new_stack(name)
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
  local name = vim.fn.input("Enter new name for stack: ", stack.get_current_stack().name)
  stack.rename_stack(name)
  new_picker()
end

M.delete_stack = function()
  stack.delete_stack()
  new_picker()
end

M.open_all_marked_files = function()
  local current_stack = stack.get_current_stack()
  for _, mark in ipairs(current_stack.marks) do
    vim.api.nvim_command("edit " .. mark.file)
    vim.api.nvim_win_set_cursor(0, { mark.line, 0 })
  end
end

return M
