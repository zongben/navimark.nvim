local group_name = "navimark_group"
local hl_name = "navimark_hl"

local M = {}

local sign_text = ""

M.init = function(sign_opt)
  vim.api.nvim_set_hl(0, hl_name, { fg = sign_opt.color })
  sign_text = sign_opt.text
end

M.set_sign = function(bufnr, line)
  local sign_name = "navimark_sign_" .. bufnr .. "_" .. line
  vim.fn.sign_define(sign_name, {
    text = sign_text,
    texthl = hl_name,
  })
  vim.fn.sign_place(0, group_name, sign_name, bufnr, { lnum = line })
end

M.remove_sign = function(bufnr, line)
  local place = vim.fn.sign_getplaced(bufnr, { group = group_name, lnum = line }) or {}

  if #place > 0 then
    if #place[1].signs > 0 then
      vim.fn.sign_unplace(group_name, { buffer = bufnr, id = place[1].signs[1].id })
    end
  end
end

M.clear_signs = function()
  vim.fn.sign_unplace(group_name)
end

return M
