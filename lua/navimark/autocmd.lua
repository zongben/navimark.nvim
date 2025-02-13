local mark = require("navimark.mark")
local sign = require("navimark.sign")

local detect_line_change = function(lastline, new_lastline)
  if lastline == new_lastline then
    return "same"
  elseif lastline > new_lastline then
    return "delete"
  else
    return "add"
  end
end

local buf_list = {}
local buf_attched = function(bufnr)
  if buf_list[bufnr] then
    return 1
  end
  vim.api.nvim_buf_attach(bufnr, false, {
    on_lines = function(_, _, _, firstline, lastline, new_lastline)
      buf_list[bufnr] = true
      local line_detect = detect_line_change(lastline, new_lastline)
      if line_detect == "delete" then
        mark.update_marks(bufnr, function(i, _mark, _)
          if _mark.line >= firstline and _mark.line <= lastline then
            vim.api.nvim_buf_del_extmark(bufnr, mark.ns_id, _mark.mark_id)
            table.remove(mark.marks, i)
          end
        end)
      end
    end,
    on_detach = function()
      buf_list[bufnr] = nil
    end,
  })
  return 0
end

local M = {}

M.init = function()
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*",
    callback = function(handler)
      mark.update_marks(handler.buf, function(_, _mark, _extmark)
        _mark.line = _extmark[1] + 1
      end)
    end,
  })

  vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function(handler)
      local bufnr = handler.buf
      -- if buf_attched(bufnr) == 1 then
      --   return
      -- end
      for _, _mark in ipairs(mark.marks) do
        if string.lower(_mark.file) == string.lower(vim.api.nvim_buf_get_name(bufnr)) then
          vim.api.nvim_buf_set_extmark(bufnr, mark.ns_id, _mark.line - 1, 0, {})
          sign.set_sign(bufnr, _mark.line)
        end
      end
    end,
  })
end

return M
