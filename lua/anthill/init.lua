local path = require('plenary.path')
local menu = require('anthill.menu')

local keymap = vim.api.nvim_set_keymap
keymap('n', '<leader>r', '<cmd>lua require("anthill.menu").toggle_ant_menu()<cr>', {noremap = true, silent = true})

local M = {}
menu.toggle_ant_menu()
