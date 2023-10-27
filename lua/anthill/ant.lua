API = vim.api

local function close_win(buf_handle)
    vim.api.nvim_buf_delete(buf_handle, { force = true, unload = true })
end
local function run_ant(command)--build_file_path, target)
    local build_file_path = command.fargs[1]
    local target = command.fargs[2]
    local Job = require'plenary.job'
    API.nvim_command("botright split new")
    API.nvim_win_set_height(0, 30)
    WIN_HANDLE = API.nvim_tabpage_get_win(0)
    BUF_HANDLE = API.nvim_win_get_buf(0)
    API.nvim_buf_set_keymap(0, 'n', 'q', '', { callback = function() close_win(BUF_HANDLE) end, noremap = true, silent = true })
    API.nvim_buf_set_keymap(0, 'n', '<CR>', '', { callback = function() close_win(BUF_HANDLE) end, noremap = true, silent = true })
    API.nvim_buf_set_option(BUF_HANDLE, 'buftype', 'nofile')
    API.nvim_buf_set_option(BUF_HANDLE, 'filetype', 'antout')
    local line = 0;
    Job:new({
        command = 'ant',
        args = { '-f', build_file_path, target },
        cwd = '/home/josh/Documents/WES/WebEnterpriseSuite/wes/Cesium',
        env = {},
        interactive = true,
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
    }):start()
end

vim.api.nvim_create_user_command('Ant', run_ant, {});
