local config = require("navimark.config")
local keymap = require("navimark.keymap")
local sign = require("navimark.sign")
local stack = require("navimark.stack")
local autocmd = require("navimark.autocmd")
local option_validator = require("navimark.option_validator")

local M = {}

M.setup = function(opts)
  M.options = vim.tbl_deep_extend("force", config.defaults, opts or {})
  option_validator.exec(M.options)
  keymap.init(M.options.keymap)
  sign.init(M.options.sign)
  stack.init(M.options.persist, M.options.stack_mode)
  autocmd.init()
end

return M
