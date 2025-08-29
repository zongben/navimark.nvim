local mark = require("navimark.mark")
local utils = require("navimark.utils")

local M = {}

M.init = function()
  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function(args)
      local bufnr = args.buf

      mark.update_marks(bufnr, function(_, _mark, _extmark)
        _mark.line = _extmark[1] + 1
      end)

      mark.reload_buf_marks(bufnr)
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
    end,
  })
end

return M
