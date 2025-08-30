local utils = require("navimark.utils")

local M = {}

M.current_mark_index = 1
M.marks = {}
M.ns_id = 0

local group_name = "navimark_hl_group"

local extmark_options = {
  sign_hl_group = group_name,
  undo_restore = false,
}

M.init = function(sign_options)
  extmark_options.sign_text = sign_options.text
  vim.api.nvim_set_hl(M.ns_id, group_name, { fg = sign_options.color })
end

M.load = function(marks, ns_id)
  M.marks = marks
  M.ns_id = ns_id
  M.current_mark_index = 1
end

M.reload_buf_marks = function(bufnr, handler)
  local seen = {}
  for i = #M.marks, 1, -1 do
    local mark = M.marks[i]

    if bufnr == vim.fn.bufadd(mark.file) then
      if handler then
        handler(mark)
      end

      vim.api.nvim_buf_del_extmark(bufnr, M.ns_id, mark.mark_id)

      local key = mark.file .. ":" .. mark.line
      if seen[key] then
        table.remove(M.marks, i)
      else
        seen[key] = true
        local id = vim.api.nvim_buf_set_extmark(bufnr, M.ns_id, mark.line - 1, 0, extmark_options)
        mark.mark_id = id
      end
    end
  end
end

M.clear_all_marks = function()
  for _, mark in ipairs(M.marks) do
    local bufnr = vim.fn.bufadd(mark.file)
    if vim.api.nvim_buf_is_loaded(bufnr) then
      vim.api.nvim_buf_del_extmark(bufnr, M.ns_id, mark.mark_id)
    end
  end
end

M.mark_add = function(pos)
  local current_pos = pos
  if utils.is_buf_modifying(current_pos.bufnr) then
    vim.notify("Can't add mark when file is modifying")
    return
  end

  for _, mark in ipairs(M.marks) do
    if mark.file == current_pos.file and mark.line == current_pos.line then
      return
    end
  end

  local mark_id = vim.api.nvim_buf_set_extmark(current_pos.bufnr, M.ns_id, current_pos.line - 1, 0, extmark_options)
  table.insert(M.marks, {
    file = current_pos.file,
    line = current_pos.line,
    mark_id = mark_id,
  })
  M.current_mark_index = #M.marks
end

M.mark_remove = function(pos)
  local current_pos = pos
  if utils.is_buf_modifying(current_pos.bufnr) then
    vim.notify("Can't remove mark when file is modifying")
    return
  end

  local removed_index = nil
  for i, mark in ipairs(M.marks) do
    if mark.file == current_pos.file and mark.line == current_pos.line then
      vim.api.nvim_buf_del_extmark(current_pos.bufnr, M.ns_id, mark.mark_id)
      table.remove(M.marks, i)
      removed_index = i
      break
    end
  end
  M.current_mark_index = removed_index or M.current_mark_index
end

M.mark_toggle = function(pos)
  for _, mark in ipairs(M.marks) do
    if mark.file == pos.file and mark.line == pos.line then
      M.mark_remove(pos)
      return
    end
  end
  M.mark_add(pos)
end

M.goto_mark = function(current_mark_index)
  local mark = M.marks[current_mark_index]
  if not mark then
    vim.notify("BookMark not found")
    return
  end

  if vim.fn.filereadable(mark.file) ~= 1 then
    vim.notify("File not found")
    return
  end

  vim.api.nvim_command("edit " .. mark.file)
  vim.api.nvim_win_set_cursor(0, { mark.line, 0 })
end

return M
