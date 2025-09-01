local mark = require("navimark.mark")
local utils = require("navimark.utils")

local M = {}

M.init = function(try_save)
  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function(args)
      local bufnr = args.buf

      mark.reload_buf_marks(bufnr, function(m)
        local extmark = vim.api.nvim_buf_get_extmark_by_id(bufnr, mark.ns_id, m.mark_id, {})

        local new_line = extmark[1] + 1
        local buf_line_count = vim.api.nvim_buf_line_count(bufnr)

        if new_line > buf_line_count then
          new_line = buf_line_count
        end

        m.line = new_line
      end)
      try_save()
    end,
  })

  vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function(args)
      local bufnr = args.buf

      if utils.is_buf_modifying(bufnr) then
        return
      end

      mark.reload_buf_marks(bufnr)
      try_save()
    end,
  })
end

M.dir_changed = function(handler)
  vim.api.nvim_create_autocmd("DirChanged", {
    callback = function()
      handler()
    end,
  })
end

return M
