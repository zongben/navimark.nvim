local mark = require("navimark.mark")
local uitl = require("navimark.util")
local persistence = require("navimark.persistence")

local M = {}

local currnet_stack_index = 1
local persist_state

M.stacks = {
	{
		id = uitl.generate_uuid(),
		name = "default",
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
	currnet_stack_index = index
	mark.init(M.stacks[currnet_stack_index].marks, get_ns_id())
end

local get_current_pos = function()
	local file = vim.api.nvim_buf_get_name(0)
	return {
		line = vim.fn.line("."),
		file = file,
		bufnr = vim.fn.bufadd(file),
	}
end

M.init = function(persist)
	persist_state = persist
	if persist_state then
		local loaded_stacks = persistence.load()
		if loaded_stacks ~= nil then
			M.stacks = loaded_stacks
		end
	end
	loadstack(currnet_stack_index)
end

M.bookmark_toggle = function()
	mark.toggle_mark(get_current_pos())
	try_save()
end

M.bookmark_add = function()
	mark.add_mark(get_current_pos())
	try_save()
end

M.bookmark_remove = function()
	mark.remove_mark(get_current_pos())
	try_save()
end

M.delete_mark = function(pos)
	mark.remove_mark(pos)
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
		id = uitl.generate_uuid(),
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

return M
