local M = {}

M.exec = function(options)
  if not vim.tbl_contains({ "auto", "manual" }, options.stack_mode) then
    error("Invalid stack_mode. Must be 'auto' or 'manual'")
  end

  if not vim.tbl_contains({ "above", "eol", "eol_right_align", "right_align", "none" }, options.sign.title_position) then
    error("Invalid sign.title_pos. Must be 'above', 'eol', 'eol_right_align', 'right_align' or 'none'.")
  end
end

return M
