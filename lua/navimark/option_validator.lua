local M = {}

M.exec = function(options)
  if options.stack_mode ~= "auto" and options.stack_mode ~= "manual" then
    error("Invalid stack_mode. Must be 'auto' or 'manual'")
  end
end

return M
