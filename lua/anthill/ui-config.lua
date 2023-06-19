local M = {}

M.info_highlight_group_name = "info_group"
M.info_highlight_text_colour = "#ff0000"

-- UI FUNCTIONS --
function M.remove_colour_highlight(bufnr, line_start, line_end)
	-- Remove the highlight from the specified lines
	vim.api.nvim_buf_clear_highlight(bufnr, -1, line_start - 1, 0, -1)
	vim.api.nvim_buf_clear_highlight(bufnr, -1, line_end - 1, 0, -1)
end
function M.add_colour_highlight(bufnr, line_start, line_end)
	-- Add the highlight to the specified lines
	vim.api.nvim_buf_add_highlight(bufnr, -1, M.info_highlight_group_name, line_start - 1, 0, -1)
	vim.api.nvim_buf_add_highlight(bufnr, -1, M.info_highlight_group_name, line_end - 1, 0, -1)

	-- Set the highlight group's colors
	vim.cmd("highlight " .. M.info_highlight_group_name .. " guifg=" .. M.info_highlight_text_colour)
end

return M
