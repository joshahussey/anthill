# AntHill
Ant Target menu for neovim

## Description
Allows for quick selection and building of targets from Java Ant Projects

## Installation
### Packer
`use({joshahussey/anthill})`

### dependencies
- xmlreader `luarocks install xmlreader`
- JDTLS, download and install JDTLS, configuration not required. (To be removed soon)

## Usage
Open AntHill menu, select the target you want to build

## Keymap
To map a different key call:
`require("anthill.menu").toggle_ant_menu()`

### Defaults:
Open/Close menu: <Leader>r
Toggle Build Info: d
Open Build File: o
Run Target: <CR>

## TODO
- [x] Add list of builds - Core Functionality
- [x] Add building from selection - Core Functionality
- [x] Add Build Description support - 2023/06/18
- [x] Add dependency support - 2023/06/18
- [x] Add "Open Build XML" support
- [ ] Implement opening build file to selected target
- [ ] Remove dependencies on JDTLS

## Credit
### ThePrimeagen/Harpoon
A lot of the UI code for AntHill is based off of [@ThePrimeagen's "Harpoon" plugin](https://github.com/ThePrimeagen/Harpoon) for Neovim.
If you enjoy this plugin, you'll love Harpoon. (If you would rather this plugin not exist I will take it down.)






