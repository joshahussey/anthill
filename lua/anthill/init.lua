require('plenary.path')
require('anthill.menu')
local keymap = vim.api.nvim_set_keymap
keymap('n', '<leader>r', '<cmd>lua require("anthill.menu").toggle_ant_menu()<cr>', {noremap = true, silent = true})
