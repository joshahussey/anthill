local popup = require("plenary.popup")
local L = require("anthill.list")
local function table_contains(table, element)
	for _, value in pairs(table) do
		if value == element then
			return true
		end
	end
	return false
end
local function get_target_index(table, element)
	for index, value in pairs(table) do
		if value == element then
			return index
		end
	end
end
local function get_open_info_indices(idx)
	local startIdx = idx
	local endIdx = idx + 1
	local lineString = vim.fn.getbufline(Menu_bufnr, idx, idx)[1]
	if table_contains(Targets, lineString) then
		startIdx = idx
	else
		local count = 1
		while not table_contains(Targets, lineString) do
			startIdx = idx - count
			lineString = vim.fn.getbufline(Menu_bufnr, startIdx, startIdx)[1]
			count = count + 1
		end
	end
	local nextLineString = vim.fn.getbufline(Menu_bufnr, endIdx, endIdx)[1]
	while not table_contains(Targets, nextLineString) do
		endIdx = endIdx + 1
		nextLineString = vim.fn.getbufline(Menu_bufnr, endIdx, endIdx)[1]
	end
	return startIdx, endIdx - 1
end
local function get_start_padding(name)
	local nameLength = string.len(name)
	local padding = ""
	local i = 1
	while i <= nameLength do
		padding = padding .. " "
		i = i + 1
	end
	return padding
end
local function create_table_from_string(string, lineLength, name)
	string = string.gsub(string, "%s%s+", " ")
	local stringLength = string.len(string)
	local table = {}
	local lineCount = math.ceil(stringLength / lineLength)
	local startPadding = get_start_padding(name)
	local i = 1
	local line = ""
	while i <= lineCount do
		if i == 1 then
			line = "  |  " .. name .. ": " .. string.sub(string, 1, lineLength)
		else
			line = "  |  "
				.. startPadding
				.. ": "
				.. string.sub(string, ((i - 1) * lineLength) + 1, (i * lineLength) + lineLength)
		end
		table[i] = line
		i = i + 1
	end
	return table
end
local function open_info(idx, string)
	local infoIdx = get_target_index(Targets, string)
	local info = Info[infoIdx]
	local description = info.description
	local lineCount = string.len(description) / 50
	if lineCount < 1 and lineCount ~= 0 then
		lineCount = 1
	elseif lineCount > 1 then
		lineCount = math.ceil(lineCount)
	end
	local infoLines = create_table_from_string(description, 50, "Description")
	table.insert(infoLines, "  |  Depends: " .. info.depends)
	vim.api.nvim_buf_set_lines(Menu_bufnr, idx, idx, false, infoLines)
end
local function close_info(idx)
	local infoStartIdx, infoEndIdx = get_open_info_indices(idx)
	vim.api.nvim_buf_set_lines(Menu_bufnr, infoStartIdx, infoEndIdx, false, {})
end

Info = L.info
Targets = L.targets
Target_count = L.target_count
local M = {}
if Target_count == 0 then
	return
end

Menu_id = nil
Menu_bufnr = nil

local function close_menu()
	vim.api.nvim_win_close(Menu_id, true)
	Menu_id = nil
	Menu_bufnr = nil
end

local function create_window()
	local width = 80
	local height = 25
	if Target_count < height then
		height = Target_count + 2
	end
	local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
	local bufnr = vim.api.nvim_create_buf(false, false)
	local menu_id, win = popup.create(bufnr, {
		title = "Ant Build Targets",
		highlight = "Ant_Targets",
		line = math.floor(((vim.o.lines - height) / 2) - 1),
		col = math.floor((vim.o.columns - width) / 2),
		minwidth = width,
		minheight = height,
		borderchars = borderchars,
	})

	vim.api.nvim_win_set_option(win.border.win_id, "winhl", "Normal:Ant_Targets")

	return {
		bufnr = bufnr,
		menu_id = menu_id,
	}
end

function M.toggle_ant_menu()
	--Close Menu if opened
	if Menu_id ~= nil and vim.api.nvim_win_is_valid(Menu_id) then
		close_menu()
		return
	end

	local menu_info = create_window()
	Menu_id = menu_info.menu_id
	Menu_bufnr = menu_info.bufnr

	vim.api.nvim_win_set_option(Menu_id, "number", true)
	vim.api.nvim_buf_set_name(Menu_bufnr, "Ant Targets")
	vim.api.nvim_buf_set_lines(Menu_bufnr, 0, #Targets, false, Targets)
	vim.api.nvim_buf_set_option(Menu_bufnr, "filetype", "anthill")
	vim.api.nvim_buf_set_option(Menu_bufnr, "buftype", "acwrite")
	vim.api.nvim_buf_set_option(Menu_bufnr, "bufhidden", "delete")
	vim.api.nvim_buf_set_keymap(
		Menu_bufnr,
		"n",
		"q",
		"<Cmd>lua require('anthill.menu').toggle_ant_menu()<CR>",
		{ silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		Menu_bufnr,
		"n",
		"<ESC>",
		"<Cmd>lua require('anthill.menu').toggle_ant_menu()<CR>",
		{ silent = true }
	)
	vim.api.nvim_buf_set_keymap(Menu_bufnr, "n", "<CR>", "<Cmd>lua require('anthill.menu').select_menu_item()<CR>", {})
	vim.api.nvim_buf_set_keymap(Menu_bufnr, "n", "d", "<Cmd>lua require('anthill.menu').toggle_show_info()<CR>", {})
end

function M.select_menu_item()
	local idx = vim.fn.line(".")
	local target = vim.fn.getbufline(Menu_bufnr, idx, idx)[1]
	local isTarget = table_contains(Targets, target)
	if not isTarget then
		local count = 0
		while not isTarget do
			count = count + 1
			target = vim.fn.getbufline(Menu_bufnr, idx - count, idx - count)[1]
			isTarget = table_contains(Targets, target)
		end
	end
	close_menu()
	vim.cmd(":Ant " .. target)
end

function M.toggle_show_info()
	local idx = vim.fn.line(".")
	local lineString = vim.fn.getbufline(Menu_bufnr, idx, idx)[1]
	local nextLineString = vim.fn.getbufline(Menu_bufnr, idx + 1, idx + 1)[1]
	print(nextLineString)
	local isTarget = table_contains(Targets, lineString)
	local isNextTarget = table_contains(Targets, nextLineString)
	if isTarget and isNextTarget then
		open_info(idx, lineString)
		return
	elseif (isTarget and not isNextTarget) or not isTarget then
		close_info(idx)
		return
	end
end

return M
