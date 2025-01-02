local M = {}

local statepath = vim.fn.stdpath("state")
if type(statepath) == "table" then
  statepath = statepath[1]
end
local state_dir = vim.fs.joinpath(statepath, "navimark")
local persist_file = vim.fs.joinpath(state_dir, "navimark.json")

M.save = function(stacks)
  local json = vim.fn.json_encode(stacks)
  vim.fn.mkdir(state_dir, "p")
  vim.fn.writefile({ json }, persist_file)
end

M.load = function()
  if vim.fn.filereadable(persist_file) == 0 then
    return nil
  end
  local json = vim.fn.readfile(persist_file)
  return vim.fn.json_decode(json[1])
end

return M
