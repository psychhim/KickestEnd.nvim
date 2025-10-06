# kickstart.nvim

https://github.com/kdheepak/kickstart.nvim/assets/1813121/f3ff9a2b-c31f-44df-a4fa-8a0d7b17cf7b

### Introduction

Many modifications I have done with the original kickstart script. This is what I use daily.
It's way ahead of the starting point for Neovim that is: a fork of https://github.com/nvim-lua/kickstart.nvim

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


Neovim Custom Keymaps


A collection of custom keymaps for Neovim aimed at improving productivity, navigation, and clipboard management. These keymaps are written in Lua for Neovim ≥0.7 and include enhanced visual/normal mode operations, smart buffer/file handling, and more.


Features


[[ Navigation ]]

Smooth scrolling with centered cursor: <leader>j / <leader>k

Enhanced search: n / N keeps cursor centered

Move lines visually: J / K in visual mode

Switch between splits quickly: <leader><Tab> / <Tab>

[[ Buffer & File Management ]]

Smart buffer switch using Telescope: <leader><leader>

Smart file open (gf) reuses empty buffers or opens in a new tab

Create new empty buffers in splits or tabs:

Horizontal: <leader>sv

Vertical: <leader>sh

New tab: <leader>e

Save buffers safely:

<leader>w — Save current buffer (prompts if new)

<leader>qy — Save and quit

<leader>qn — Quit without saving

[[ Clipboard & Copying ]]

Copy current line: Y (normal mode)

Copy selection: Y (visual mode, trims extra newlines)

Select all and copy: <leader>lY (entire buffer without trailing newline)

Paste from clipboard: <leader>P (at cursor, or over selection without yanking it)

Notifications when content is copied to clipboard

[[ Diagnostics ]]

[d] / ]d — Navigate diagnostics

<leader>de — Open diagnostic floating window

<leader>dq — Set location list for diagnostics

[[ Misc ]]

Reselect last visual selection after moving lines

Better word wrap handling: j / k intelligently move through wrapped lines

Smart J in normal mode joins lines without moving cursor

Paste over selection without yanking replaced text: <leader>p


Keymaps Overview

Normal Mode Keymaps:

| Key                | Action              | Description                                                      |
| ------------------ | ------------------- | ---------------------------------------------------------------- |
| `J`                | Join line           | Join current line with next without moving cursor                |
| `<leader>j`        | Scroll down         | `<C-d>` + center cursor                                          |
| `<leader>k`        | Scroll up           | `<C-u>` + center cursor                                          |
| `n` / `N`          | Search              | Keep cursor centered on matches                                  |
| `Y`                | Copy line           | Copy current line to system clipboard                            |
| `<leader>lY`       | Copy all            | Select entire buffer and copy to clipboard (no trailing newline) |
| `<leader>w`        | Save                | Save current buffer (prompts if new)                             |
| `<leader>q`        | Quit                | Close buffer (prompts if modified)                               |
| `<leader>qy`       | Save & quit         | Save and close buffer                                            |
| `<leader>qn`       | Quit without saving | Discard changes and close buffer                                 |
| `<leader><leader>` | Smart buffer switch | Open Telescope buffer switcher                                   |
| `gf`               | Smart file open     | Open file under cursor in current/new tab                        |


Visual Mode Keymaps:

| Key         | Action         | Description                                               |
| ----------- | -------------- | --------------------------------------------------------- |
| `J` / `K`   | Move selection | Move selected lines up or down                            |
| `Y`         | Copy selection | Copy selected text to system clipboard (no extra newline) |
| `<leader>p` | Paste          | Paste over selection without yanking replaced text        |
| `<leader>P` | Paste          | Paste from clipboard without replacing selection          |


Split/Window Management:

| Key             | Action           | Description                    |
| --------------- | ---------------- | ------------------------------ |
| `<leader>sv`    | Horizontal split | New empty buffer below current |
| `<leader>sh`    | Vertical split   | New empty buffer to the right  |
| `<leader>t`     | New terminal     | Open terminal in new tab       |
| `<leader><Tab>` | Switch splits    | Switch to next window          |
| `<Tab>`         | Switch splits    | Switch to previous window      |


Diagnostics Keymaps:

| Key          | Action        | Description                                |
| ------------ | ------------- | ------------------------------------------ |
| `[d` / `]d`  | Previous/Next | Go to previous/next diagnostic             |
| `<leader>de` | Float         | Show diagnostic message in floating window |
| `<leader>dq` | Location list | Set location list for diagnostics          |


Contributing

Contributions, bug reports, and suggestions are welcome. Please open an issue or submit a pull request if you have improvements for keymaps, new features, or optimizations.

License

MIT License — feel free to use and modify these keymaps in your own Neovim setup.

