local mark = require("navimark.mark")
local uitls = require("navimark.utils")
local persistence = require("navimark.persistence")

local M = {}

local currnet_stack_index = 1
local persist_state

M.stacks = {
  {
    id = uitls.generate_uuid(),
    name = "stack",
    marks = {},
  },
}

local try_save = function()
  if persist_state then
    persistence.save(M.stacks)
  end
end

local get_ns_id = function()
  return vim.api.nvim_create_namespace("navimark" .. M.stacks[currnet_stack_index].id)
end

local loadstack = function(index)
  vim.schedule(function()
    currnet_stack_index = index
    mark.init(M.stacks[currnet_stack_index].marks, get_ns_id(), try_save)
  end)
end

local get_current_pos = function()
  local file = vim.api.nvim_buf_get_name(0)
  return {
    line = vim.fn.line("."),
    file = file,
    bufnr = vim.fn.bufadd(file),
  }
end

local init_stack_auto_mode = function()
  vim.api.nvim_create_autocmd({ "LspAttach" }, {
    pattern = "*",
    callback = function(handler)
      local bufnr = handler.buf
      local clients = vim.lsp.get_clients({
        bufnr = bufnr,
      })

      local cwd = utils.correct_path(vim.fn.getcwd())
      for _, client in ipairs(clients) do
        local root_dir = client.root_dir
        if root_dir == nil then
          return
        end

        if cwd == utils.correct_path(root_dir) then
          if M.stacks[currnet_stack_index].root_dir == root_dir then
            return
          end

          local repo_name = vim.fn.fnamemodify(root_dir, ":t")
          local founded = false
          for i, stack in ipairs(M.stacks) do
            if stack.root_dir == root_dir then
              founded = true
              currnet_stack_index = i
              loadstack(currnet_stack_index)
            end
          end

          if not founded then
            table.insert(M.stacks, {
              id = uitls.generate_uuid(),
              name = repo_name,
              root_dir = root_dir,
              marks = {},
            })
            currnet_stack_index = #M.stacks
            loadstack(currnet_stack_index)
          end

          vim.notify("Stack for " .. repo_name .. " is autoloaded")
        end
      end
    end,
  })
end

M.init = function(persist, stack_mode)
  persist_state = persist
  if persist_state then
    local loaded_stacks = persistence.load()
    if loaded_stacks ~= nil then
      M.stacks = loaded_stacks
    end
  end
  if stack_mode == "auto" then
    init_stack_auto_mode()
  end
  loadstack(currnet_stack_index)
end

M.mark_toggle = function()
  mark.mark_toggle(get_current_pos())
  try_save()
end

M.mark_add = function()
  mark.mark_add(get_current_pos())
  try_save()
end

M.mark_remove = function()
  mark.mark_remove(get_current_pos())
  try_save()
end

M.delete_mark = function(pos)
  mark.mark_remove(pos)
  try_save()
end

M.get_current_stack = function()
  return M.stacks[currnet_stack_index]
end

M.goto_next_mark = function()
  mark.current_mark_index = mark.current_mark_index + 1
  if mark.current_mark_index > #mark.marks then
    mark.current_mark_index = 1
  end
  mark.goto_mark(mark.current_mark_index)
end

M.goto_prev_mark = function()
  mark.current_mark_index = mark.current_mark_index - 1
  if mark.current_mark_index < 1 then
    mark.current_mark_index = #mark.marks
  end
  mark.goto_mark(mark.current_mark_index)
end

M.new_stack = function()
  local name = vim.fn.input("Enter name for new stack: ")
  if name == "" then
    vim.notify("Name can't be empty")
    return
  end
  table.insert(M.stacks, {
    id = uitls.generate_uuid(),
    name = name,
    marks = {},
  })
  try_save()
end

M.rename_stack = function()
  local name = vim.fn.input("Enter new name for stack: ", M.stacks[currnet_stack_index].name)
  if name == "" then
    vim.notify("Name can't be empty")
    return
  end
  M.stacks[currnet_stack_index].name = name
  try_save()
end

M.next_stack = function()
  currnet_stack_index = currnet_stack_index + 1
  if currnet_stack_index > #M.stacks then
    currnet_stack_index = 1
  end
  loadstack(currnet_stack_index)
end

M.prev_stack = function()
  currnet_stack_index = currnet_stack_index - 1
  if currnet_stack_index < 1 then
    currnet_stack_index = #M.stacks
  end
  loadstack(currnet_stack_index)
end

M.delete_stack = function()
  if #M.stacks == 1 then
    vim.notify("Can't delete the last stack")
    return
  end
  table.remove(M.stacks, currnet_stack_index)
  currnet_stack_index = currnet_stack_index - 1
  if currnet_stack_index < 1 then
    currnet_stack_index = 1
  end
  loadstack(currnet_stack_index)
  try_save()
end

M.clear_marks = function()
  M.stacks[currnet_stack_index].marks = {}
  loadstack(currnet_stack_index)
  try_save()
end

return M
