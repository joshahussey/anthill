API = vim.api
BUF_HANDLE = nil
local function close_win(BUF_HANDLE)
    local current_win = vim.api.nvim_get_current_win()
    P(vim.api.nvim_win_get_buf(current_win))
    P(BUF_HANDLE)

    -- Check if the buffer is in use by any other windows
    local other_wins = vim.fn.getbufinfo(BUF_HANDLE)[1].windows
    for _, win_id in ipairs(other_wins) do
        if win_id ~= current_win then
            vim.api.nvim_set_current_win(win_id)
            vim.api.nvim_win_close({ force = true })
        end
    end

    vim.api.nvim_set_current_win(current_win)
    vim.schedule(function()
        vim.api.nvim_buf_delete(BUF_HANDLE, { force = true, unload = true })
    end)
end
-- local function close_win(BUF_HANDLE)
--     P(vim.api.nvim_win_get_buf(0))
--     P(BUF_HANDLE)
--     vim.schedule(vim.api.nvim_buf_delete(BUF_HANDLE, { force = true, unload=true }))
--     --vim.api.nvim_command("q")
-- end
local function run_ant(command) --build_file_path, target)
    local build_file_path = command.fargs[1]
    local target = command.fargs[2]
    local Job = require 'plenary.job'
    API.nvim_command("botright split new")
    API.nvim_win_set_height(0, 30)
    local line = 0;
    Job:new({
        command = 'ant',
        args = { '-f', build_file_path, target },
        interactive = true,
        on_start = function()
            BUF_HANDLE = API.nvim_win_get_buf(0)
            API.nvim_buf_set_option(BUF_HANDLE, 'buftype', 'nofile')
            API.nvim_buf_set_option(BUF_HANDLE, 'filetype', 'antout')
            API.nvim_buf_set_keymap(0, 'n', 'q', '',
            { callback = function() close_win(BUF_HANDLE) end, noremap = true, silent = true })
            API.nvim_buf_set_keymap(0, 'n', '<CR>', '',
            { callback = function() close_win(BUF_HANDLE) end, noremap = true, silent = true })
        end,
        on_stdout = function(j, return_val)
            if not j == nil then
                P(return_val)
                P(j:result())
            else
                vim.schedule(function()
                    local value = { return_val }
                    API.nvim_buf_set_lines(0, line, line, true, value)
                    line = line + 1
                end)
            end
        end,
        on_stderr = function(j, return_val)
            if not j == nil then
                P(return_val)
                P(j:result())
            else
                vim.schedule(function()
                    local value = { return_val }
                    API.nvim_buf_set_lines(0, line, line, true, value)
                    line = line + 1
                end)
            end
        end,
        on_exit = function()
            P("DONE")
        end,
    }):start()
end
local opts = { nargs = "*" }
vim.api.nvim_create_user_command('Ant', run_ant, opts);
