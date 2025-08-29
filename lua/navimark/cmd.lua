local stack = require("navimark.stack")

local M = {}

M.init = function()
  vim.api.nvim_create_user_command("Navimark", function(args)
    local subcmd = args.fargs[1]
    if subcmd == "SaveRootDir" then
      stack.save_root_dir()
    end
  end, {
    nargs = 1,
    complete = function()
      return { "SaveRootDir" }
    end,
  })
end

return M
