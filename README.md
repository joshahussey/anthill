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

## TODO
- [x] Add list of builds
- [x] Add building from selection
- [ ] Add Build Description support
- [ ] Add Build Location support
- [ ] Add dependency support
- [ ] Add "Open Build File" support
- [ ] Remove dependencies on JDTLS

## Credit
### ThePrimeagen/Harpoon
A lot of this code is based off of [@ThePrimeagen's "Harpoon" plugin](https://github.com/ThePrimeagen/Harpoon) for Neovim.
If you enjoy this plugin, you'll love Harpoon. (If you would rather this plugin not exist I will take it down.)






