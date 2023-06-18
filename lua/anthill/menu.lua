local popup = require("plenary.popup")
local T = require("anthill.targets")
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
Info = L.info
Targets = L.targets
Target_count = L.target_count
local M = {}
if Target_count == 0 then
	return
end

--Menu State
Menu_id = nil
Menu_bufnr = nil

local function close_menu()
	vim.api.nvim_win_close(Menu_id, true)
	Menu_id = nil
	Menu_bufnr = nil
end

local function create_window()
	local width = 60
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
	--local info = Info[idx]
	local target = vim.fn.getbufline(Menu_bufnr, idx, idx)[1]
	local isTarget = table_contains(Targets, target)
	if not isTarget then
		local count = 0
		while not isTarget do
			count = count + 1
			target = vim.fn.getbufline(Menu_bufnr, idx - count, idx - count)[1]
			isTarget = table_contains(Targets, target)
		end
		vim.api.nvim_buf_set_lines(Menu_bufnr, idx - count, idx - count + 2, false, {})
		return
	end
	local infoIdx = get_target_index(Targets, target)
	local info = Info[infoIdx]
	local description = info.description
	local depends = info.depends
	vim.api.nvim_buf_set_lines(
		Menu_bufnr,
		idx,
		idx,
		false,
		{ "  |  Description: " .. description, "  |  Depends: " .. depends }
	)
end

return M
