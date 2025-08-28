local M = {}

M.generate_uuid = function()
  local random = math.random
  local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
  return string.gsub(template, "[xy]", function(c)
    local v = (c == "x") and random(0, 0xf) or random(8, 0xb)
    return string.format("%x", v)
  end)
end

M.get_os = function()
  if vim.fn.has("win32") == 1 then
    return "Windows"
  elseif vim.fn.has("mac") == 1 then
    return "macOS"
  elseif vim.fn.has("unix") == 1 then
    return "Linux"
  else
    return nil
  end
end

M.correct_path = function(path)
  if M.get_os() == "Windows" then
    return string.gsub(path, "/", "\\")
  else
    return string.gsub(path, "\\", "/")
  end
end

M.is_buf_modifying = function(bufnr)
  return vim.api.nvim_get_option_value("modified", { buf = bufnr })
end

return M
