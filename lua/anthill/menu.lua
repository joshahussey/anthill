local popup = require("plenary.popup")
local L = require("anthill.list")
local ui_config = require("anthill.ui-config")
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
local function update_targets()
	local N = L.update()
	Info = N.info
	Targets = N.targets
	Target_count = N.target_count
    Build_File_Path = N.build_file_path
end
local function get_open_info_indices(idx)
	local startIdx = idx
	local endIdx = idx
	local lastLine = vim.fn.line("$")
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
	if endIdx ~= lastLine then
		endIdx = endIdx + 1
		local nextLineString = vim.fn.getbufline(Menu_bufnr, endIdx, endIdx)[1]
		while (not table_contains(Targets, nextLineString)) and (endIdx ~= lastLine) do
			endIdx = endIdx + 1
			nextLineString = vim.fn.getbufline(Menu_bufnr, endIdx, endIdx)[1]
		end
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
local function splitStringByLength(str, length)
	local result = {}
	local startIndex = 1
	local endIndex = length
	while startIndex <= #str do
		if endIndex > #str then
			endIndex = #str
		end
		table.insert(result, string.sub(str, startIndex, endIndex))
		startIndex = endIndex + 1
		endIndex = startIndex + length - 1
	end
	return result
end

local function create_table_from_string(string, lineLength, name)
	string = string.gsub(string, "%s%s+", " ")
	local stringTable = splitStringByLength(string, lineLength)
	for i, v in ipairs(stringTable) do
		if i == 1 then
			stringTable[i] = "  |  " .. name .. ": " .. v
		else
			stringTable[i] = "  |  " .. get_start_padding(name) .. ": " .. v
		end
	end
	return stringTable
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
	local infoStartIdx, infoEndIdx = get_open_info_indices(idx)
	ui_config.add_colour_highlight(Menu_bufnr, infoStartIdx, infoEndIdx)
end
local function close_info(idx)
	local infoStartIdx, infoEndIdx = get_open_info_indices(idx)
	ui_config.remove_colour_highlight(Menu_bufnr, infoStartIdx, infoStartIdx)
	vim.api.nvim_buf_set_lines(Menu_bufnr, infoStartIdx, infoEndIdx, false, {})
end

Info = L.info
Targets = L.targets
Target_count = L.target_count
Build_File_Path = L.build_file_path
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
	update_targets()
    if Build_File_Path == nil then
        return
    end
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
	vim.api.nvim_buf_set_keymap(Menu_bufnr, "n", "o", "<Cmd>lua require('anthill.menu').open_build_file()<CR>", {})
	vim.api.nvim_buf_set_keymap(
		Menu_bufnr,
		"n",
		"t",
		"<Cmd>lua require('anthill.menu').open_build_file_to_target()<CR>",
		{}
	)
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
	local lastLine = vim.fn.line("$")
	local lineString = vim.fn.getbufline(Menu_bufnr, idx, idx)[1]
	local isTarget = table_contains(Targets, lineString)
	if (idx == lastLine) and not isTarget then
		close_info(idx)
		return
	end
	if (idx == lastLine) and isTarget then
		open_info(idx, lineString)
		return
	end
	local nextLineString = vim.fn.getbufline(Menu_bufnr, idx + 1, idx + 1)[1]
	local isNextTarget = table_contains(Targets, nextLineString)
	if isTarget and isNextTarget then
		open_info(idx, lineString)
		return
	elseif (isTarget and not isNextTarget) or not isTarget then
		close_info(idx)
		return
	end
end

function M.open_build_file()
	close_menu()
	ui_config.new_build_file_buffer(L.build_file_path)
end

function M.open_build_file_to_target()
	local string = vim.fn.getbufline(Menu_bufnr, vim.fn.line("."), vim.fn.line("."))[1]
	--local line_number = Info[get_target_index(Targets, string)].line_number
	close_menu()
	--ui_config.new_build_file_buffer_to_target(L.build_file_path, line_number)
	ui_config.jump_to_target_from_name(L.build_file_path, string)
end

return M
