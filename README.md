# AntHill
Ant Target menu for neovim

## Description
Allows for quick selection and building of targets from Java Ant Projects

## Installation
### Packer
`use({joshahussey/anthill})`

### Tree-Sitter Ant output highlighting

Add the following to your tree-sitter-config

```
local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.antout= {
        install_info = {
                url = "https://github.com/joshahussey/tree-sitter-antout",
                files = { "src/parser.c" },
                generate_requires_npm = false,
                requires_generate_from_grammar = false,
                branch = "master", 
        },
        filetype = "antout"
}
```

For default highlighting, copy queries/highlights.scm to whereever your highlighting schemes are located.
It could be any of the following, or eslewhere:

```
~/.config/nvim/queries/
~/.local/share/nvim/site/pack/packer/start/nvim-treesitter/queries/
```

### dependencies
- xmlreader `luarocks install xmlreader`

## Usage
Open AntHill menu, select the target you want to build

## Keymap
To map a different key call:
`require("anthill.menu").toggle_ant_menu()`

### Defaults:
Open/Close menu: `<Leader>r` <br />
Toggle Build Info: `d` <br />
Open Build File: `o` <br />
Jump to Target in Build File: `t` <br />
Run Target: `<CR>` 

## TODO
- [x] Add list of builds - Core Functionality
- [x] Add building from selection - Core Functionality
- [x] Add Build Description support - 2023/06/18
- [x] Add dependency support - 2023/06/18
- [x] Add "Open Build XML" support
- [x] Implement opening build file to selected target
- [x] Remove dependencies on JDTLS
- [ ] Verify last build target is shown from build files larger than window size

## Suggestions/requests/issues are greatly appreciated!

## Credit
### ThePrimeagen/Harpoon
A lot of the UI code for AntHill is based off of [@ThePrimeagen's "Harpoon" plugin](https://github.com/ThePrimeagen/Harpoon) for Neovim.
If you enjoy this plugin, you'll love Harpoon. (If you would rather this plugin not exist I will take it down.)






