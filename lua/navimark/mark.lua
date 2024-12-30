local sign = require("navimark.sign")

local M = {}

M.current_mark_index = 1

M.marks = {}

M.ns_id = 0

local update_marks = function(bufnr, handler)
	for i = #M.marks, 1, -1 do
		local mark = M.marks[i]
		local extmark = vim.api.nvim_buf_get_extmark_by_id(bufnr, M.ns_id, mark.mark_id, {})
		if #extmark > 0 then
			handler(i, mark, extmark)
		end
	end
end

local detect_line_change = function(lastline, new_lastline)
	if lastline == new_lastline then
		return "same"
	elseif lastline > new_lastline then
		return "delete"
	else
		return "add"
	end
end

local buf_list = {}
local buf_attch = function(bufnr)
	for _, buf in ipairs(buf_list) do
		if buf == bufnr then
			return nil
		end
	end
	vim.api.nvim_buf_attach(bufnr, false, {
		on_lines = function(_, _, _, firstline, lastline, new_lastline)
			local line_detect = detect_line_change(lastline, new_lastline)
			if line_detect == "delete" then
				update_marks(bufnr, function(i, mark, _)
					if mark.line >= firstline and mark.line <= lastline then
						vim.api.nvim_buf_del_extmark(bufnr, M.ns_id, mark.mark_id)
						table.remove(M.marks, i)
					end
				end)
			end
		end,
		on_detach = function(_, b)
			for i = #buf_list, 1, -1 do
				if buf_list[i] == b then
					table.remove(buf_list, i)
				end
			end
		end,
	})
	table.insert(buf_list, bufnr)
	return 0
end

M.init = function(marks, ns_id)
	M.marks = marks
	M.ns_id = ns_id
	M.current_mark_index = 1

	sign.clear_signs()
	for _, mark in ipairs(M.marks) do
		if vim.api.nvim_buf_is_loaded(vim.fn.bufadd(mark.file)) then
			sign.set_sign(vim.fn.bufadd(mark.file), mark.line)
		end
	end

	vim.api.nvim_create_autocmd("BufEnter", {
		pattern = "*",
		callback = function(handler)
			local bufnr = handler.buf
			if buf_attch(bufnr) == nil then
				return
			end
			for _, mark in ipairs(M.marks) do
				if mark.file == vim.api.nvim_buf_get_name(bufnr) then
					vim.api.nvim_buf_set_extmark(bufnr, M.ns_id, mark.line - 1, 0, {})
					sign.set_sign(bufnr, mark.line)
				end
			end
		end,
	})
end

M.add_mark = function(pos)
	local current_pos = pos
	local found = vim.api.nvim_buf_get_extmarks(
		current_pos.bufnr,
		M.ns_id,
		{ current_pos.line - 1, 0 },
		{ current_pos.line - 1, 0 },
		{}
	)
	if #found > 0 then
		return
	end
	local mark_id = vim.api.nvim_buf_set_extmark(current_pos.bufnr, M.ns_id, current_pos.line - 1, 0, {})
	sign.set_sign(current_pos.bufnr, current_pos.line)
	table.insert(M.marks, {
		file = current_pos.file,
		line = current_pos.line,
		mark_id = mark_id,
	})
	M.current_mark_index = #M.marks
end

M.remove_mark = function(pos)
	local current_pos = pos
	local removed_index = nil
	for i, mark in ipairs(M.marks) do
		if mark.file == current_pos.file and mark.line == current_pos.line then
			vim.api.nvim_buf_del_extmark(current_pos.bufnr, M.ns_id, mark.mark_id)
			sign.remove_sign(current_pos.bufnr, current_pos.line)
			table.remove(M.marks, i)
			removed_index = i
			break
		end
	end
	M.current_mark_index = removed_index or M.current_mark_index
end

M.toggle_mark = function(pos)
	local found = vim.api.nvim_buf_get_extmarks(pos.bufnr, M.ns_id, { pos.line - 1, 0 }, { pos.line - 1, 0 }, {})
	if #found == 0 then
		M.add_mark(pos)
	else
		M.remove_mark(pos)
	end
end

M.goto_mark = function(current_mark_index)
	local mark = M.marks[current_mark_index]
	if not mark then
		vim.notify("BookMark not found", 1)
		return
	end

	if vim.fn.filereadable(mark.file) ~= 1 then
		vim.notify("File not found", 1)
		return
	end

	vim.api.nvim_command("edit " .. mark.file)
	vim.api.nvim_win_set_cursor(0, { mark.line, 0 })
end

vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "*",
	callback = function(handler)
		update_marks(handler.buf, function(_, mark, extmark)
			mark.line = extmark[1] + 1
		end)
	end,
})

return M