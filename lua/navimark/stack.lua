local mark = require("navimark.mark")
local utils = require("navimark.utils")
local persistence = require("navimark.persistence")
local autocmd = require("navimark.autocmd")

local M = {}

local currnet_stack_index = 1
local persist_state

M.stacks = {
  {
    id = utils.generate_uuid(),
    name = "stack",
    marks = {},
  },
}

local try_save = function()
  if persist_state then
    persistence.save(M.stacks)
  end
end

local get_ns_id = function()
  return vim.api.nvim_create_namespace("navimark" .. M.stacks[currnet_stack_index].id)
end

local loadstack = function(index)
  mark.clear_all_marks()
  currnet_stack_index = index
  mark.load(M.stacks[currnet_stack_index].marks, get_ns_id())
end

local get_current_pos = function()
  local file = vim.api.nvim_buf_get_name(0)
  return {
    line = vim.fn.line("."),
    file = file,
    bufnr = vim.fn.bufadd(file),
  }
end

M.init = function(persist, stack_mode)
  persist_state = persist
  if persist_state then
    local loaded_stacks = persistence.load()
    if loaded_stacks ~= nil then
      M.stacks = loaded_stacks
    end
  end

  autocmd.init(try_save)

  if stack_mode == "auto" then
    local find_matched_stack = function()
      local cwd = vim.fn.getcwd()
      for i, stack in ipairs(M.stacks) do
        if stack.root_dir == cwd then
          currnet_stack_index = i
          loadstack(i)
          return
        end
      end
    end

    vim.api.nvim_create_autocmd("DirChanged", {
      callback = function()
        find_matched_stack()
      end,
    })

    find_matched_stack()
  end

  loadstack(currnet_stack_index)
end

M.mark_toggle = function()
  mark.mark_toggle(get_current_pos())
  try_save()
end

M.mark_add = function()
  mark.mark_add(get_current_pos())
  try_save()
end

M.mark_remove = function()
  mark.mark_remove(get_current_pos())
  try_save()
end

M.delete_mark = function(pos)
  mark.mark_remove(pos)
  try_save()
end

M.correct_marks = function(stack)
  local cache = {}

  for i = #stack.marks, 1, -1 do
    local m = stack.marks[i]
    if not vim.fn.filereadable(m.file) then
      table.remove(stack.marks, i)
    else
      local buf_line_count

      if cache[m.file] then
        buf_line_count = cache[m.file]
      else
        local bufnr = vim.fn.bufadd(m.file)
        buf_line_count = vim.api.nvim_buf_line_count(bufnr)

        if buf_line_count == 0 then
          buf_line_count = #vim.fn.readfile(m.file)
        end

        cache[m.file] = buf_line_count
      end

      if m.line > buf_line_count then
        m.line = buf_line_count
      end
    end
  end

  try_save()
end

M.get_current_stack = function()
  return M.stacks[currnet_stack_index]
end

M.goto_next_mark = function()
  mark.current_mark_index = mark.current_mark_index + 1
  if mark.current_mark_index > #mark.marks then
    mark.current_mark_index = 1
  end
  mark.goto_mark(mark.current_mark_index)
end

M.goto_prev_mark = function()
  mark.current_mark_index = mark.current_mark_index - 1
  if mark.current_mark_index < 1 then
    mark.current_mark_index = #mark.marks
  end
  mark.goto_mark(mark.current_mark_index)
end

M.save_root_dir = function(path)
  local cwd
  if path then
    cwd = path
  else
    cwd = vim.fn.getcwd()
  end
  local stack = M.get_current_stack()
  stack.root_dir = cwd
  vim.notify("[" .. stack.name .. "] RootDir set to: " .. cwd)
  try_save()
end

M.new_stack = function(name, root_dir)
  if name == "" then
    vim.notify("Name can't be empty")
    return
  end
  local pos = currnet_stack_index + 1
  if pos > #M.stacks then
    pos = 1
  end
  table.insert(M.stacks, pos, {
    id = utils.generate_uuid(),
    name = name,
    root_dir = root_dir,
    marks = {},
  })
  try_save()
end

M.rename_stack = function(name)
  if name == "" then
    vim.notify("Name can't be empty")
    return
  end
  M.stacks[currnet_stack_index].name = name
  try_save()
end

M.next_stack = function()
  currnet_stack_index = currnet_stack_index + 1
  if currnet_stack_index > #M.stacks then
    currnet_stack_index = 1
  end
  loadstack(currnet_stack_index)
end

M.prev_stack = function()
  currnet_stack_index = currnet_stack_index - 1
  if currnet_stack_index < 1 then
    currnet_stack_index = #M.stacks
  end
  loadstack(currnet_stack_index)
end

M.delete_stack = function()
  if #M.stacks == 1 then
    vim.notify("Can't delete the last stack")
    return
  end
  table.remove(M.stacks, currnet_stack_index)
  currnet_stack_index = currnet_stack_index - 1
  if currnet_stack_index < 1 then
    currnet_stack_index = 1
  end
  loadstack(currnet_stack_index)
  try_save()
end

M.clear_marks = function()
  M.stacks[currnet_stack_index].marks = {}
  loadstack(currnet_stack_index)
  try_save()
end

return M
