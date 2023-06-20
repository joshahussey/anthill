local M = {}

M.info_highlight_group_name = "info_group_text_colour"
M.info_highlight_target_name = "info_group_target_colour"
M.info_highlight_text_colour = "#FAD8D6"
M.info_highlight_target_colour = "#EDB88B"

-- UI FUNCTIONS --
function M.remove_colour_highlight(bufnr, line_start, line_end)
	for line = line_start, line_end do
		vim.api.nvim_buf_clear_namespace(bufnr, -1, line, line + 1)
	end
end

function M.add_colour_highlight(bufnr, line_start, line_end)
	vim.api.nvim_buf_add_highlight(bufnr, -1, M.info_highlight_target_name, line_start - 1, 0, -1)
	for line = line_start + 1, line_end do
		vim.api.nvim_buf_add_highlight(bufnr, -1, M.info_highlight_group_name, line - 1, 0, -1)
	end
	vim.cmd("highlight " .. M.info_highlight_group_name .. " guifg=" .. M.info_highlight_text_colour)
	vim.cmd("highlight " .. M.info_highlight_target_name .. " guifg=" .. M.info_highlight_target_colour)
end

function M.new_build_file_buffer(path)
	vim.api.nvim_command("edit " .. path)
end

function M.new_build_file_buffer_to_target(path, line)
	vim.api.nvim_command("edit +" .. line .. " " .. path .. " | normal! zz")
end

function M.jump_to_target_from_name(path, name)
	vim.api.nvim_command("edit +/<target name=" .. name .. " " .. path .. " | normal! zz")
end
return M
