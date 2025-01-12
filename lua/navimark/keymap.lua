local stack = require("navimark.stack")
local tele = require("navimark.tele")

local M = {}

M.keymap = {}

local map = function(mode, key, cmd)
  if key == "" then
    return
  end
  local opts = { noremap = true, silent = true }
  vim.keymap.set(mode, key, cmd, opts)
end

M.init = function(keymap)
  M.keymap = keymap
  M.base_init()
  M.tele_init()
end

M.base_init = function()
  local base = M.keymap.base
  map("n", base.mark_toggle, stack.bookmark_toggle)
  map("n", base.mark_add, stack.bookmark_add)
  map("n", base.mark_remove, stack.bookmark_remove)
  map("n", base.goto_next_mark, stack.goto_next_mark)
  map("n", base.goto_prev_mark, stack.goto_prev_mark)

  map("n", base.open_mark_picker, tele.open_bookmark_picker)
end

M.tele_init = function()
  tele.picker_mappings = function(tele_map)
    local telescope = M.keymap.telescope
    tele_map("n", telescope.n.delete_mark, tele.delete_mark)
    tele_map("n", telescope.n.new_stack, tele.new_stack)
    tele_map("n", telescope.n.next_stack, tele.next_stack)
    tele_map("n", telescope.n.prev_stack, tele.prev_stack)
    tele_map("n", telescope.n.rename_stack, tele.rename_stack)
    tele_map("n", telescope.n.delete_stack, tele.delete_stack)
    tele_map("n", telescope.n.clear_marks, tele.clear_marks)
    tele_map("n", telescope.n.open_all_marked_files, tele.open_all_marked_files)
  end
end

return M
