local sign = require("navimark.sign")

local M = {}

M.current_mark_index = 1
M.marks = {}
M.ns_id = 0

local _try_save = nil

M.init = function(marks, ns_id, try_save)
  M.marks = marks
  M.ns_id = ns_id
  M.current_mark_index = 1

  sign.clear_signs()
  for _, mark in ipairs(M.marks) do
    local bufnr = vim.fn.bufadd(mark.file)
    if vim.api.nvim_buf_is_loaded(bufnr) then
      sign.set_sign(bufnr, mark.line)
    end
  end
  _try_save = try_save
end

M.reload_buf_marks = function(bufnr)
  sign.clear_signs({ buffer = bufnr })
  for _, _mark in ipairs(M.marks) do
    if string.lower(_mark.file) == string.lower(vim.api.nvim_buf_get_name(bufnr)) then
      vim.api.nvim_buf_set_extmark(bufnr, M.ns_id, _mark.line - 1, 0, {})
      sign.set_sign(bufnr, _mark.line)
    end
  end
end

M.update_marks = function(bufnr, handler)
  for i = #M.marks, 1, -1 do
    local mark = M.marks[i]
    if bufnr == vim.fn.bufadd(mark.file) then
      local extmark = vim.api.nvim_buf_get_extmark_by_id(bufnr, M.ns_id, mark.mark_id, {})
      if #extmark > 0 then
        handler(i, mark, extmark)
      end
    end
  end
  if _try_save then
    _try_save()
  end
end

M.mark_add = function(pos)
  local current_pos = pos
  for _, mark in ipairs(M.marks) do
    if mark.file == current_pos.file and mark.line == current_pos.line then
      return
    end
  end
  local mark_id = vim.api.nvim_buf_set_extmark(current_pos.bufnr, M.ns_id, current_pos.line - 1, 0, {})
  sign.set_sign(current_pos.bufnr, current_pos.line)
  table.insert(M.marks, {
    file = current_pos.file,
    line = current_pos.line,
    mark_id = mark_id,
  })
  M.current_mark_index = #M.marks
end

M.mark_remove = function(pos)
  local current_pos = pos
  local removed_index = nil
  for i, mark in ipairs(M.marks) do
    if mark.file == current_pos.file and mark.line == current_pos.line then
      vim.api.nvim_buf_del_extmark(current_pos.bufnr, M.ns_id, mark.mark_id)
      sign.remove_sign(current_pos.bufnr, current_pos.line)
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
