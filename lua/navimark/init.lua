local config = require("navimark.config")
local keymap = require("navimark.keymap")
local stack = require("navimark.stack")
local options_validator = require("navimark.options_validator")
local mark = require("navimark.mark")
local cmd = require("navimark.cmd")

local M = {}

M.setup = function(opts)
  M.options = vim.tbl_deep_extend("force", config.defaults, opts or {})
  options_validator.exec(M.options)
  keymap.init(M.options.keymap)
  mark.init(M.options.sign)
  stack.init(M.options.persist, M.options.stack_mode)
  cmd.init()
end

return M
