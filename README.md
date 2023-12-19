# kickstart.nvim

https://github.com/kdheepak/kickstart.nvim/assets/1813121/f3ff9a2b-c31f-44df-a4fa-8a0d7b17cf7b

### Introduction

Some modifications I have done with the original kickstart script. This is what I use daily.
A starting point for Neovim that is: a fork of https://github.com/nvim-lua/kickstart.nvim

This repo is meant to be used by **YOU** to begin your Neovim journey; remove the things you don't use and add what you miss.

### Installation

Neovim's configurations are located under the following paths, depending on your OS:

| OS | PATH |
| :- | :--- |
| Linux | `$XDG_CONFIG_HOME/nvim`, `~/.config/nvim` |
| MacOS | `$XDG_CONFIG_HOME/nvim`, `~/.config/nvim` |
| Windows (cmd)| `%userprofile%\AppData\Local\nvim\` |
| Windows (powershell)| `$env:USERPROFILE\AppData\Local\nvim\` |

Clone kickstart.nvim:

- on Linux and Mac

git clone https://github.com/psychhim/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim

- on Windows (cmd)

git clone https://github.com/psychhim/kickstart.nvim.git %userprofile%\AppData\Local\nvim\ 

- on Windows (powershell)

git clone https://github.com/psychhim/kickstart.nvim.git $env:USERPROFILE\AppData\Local\nvim\ 


### Post Installation

Start Neovim

nvim
