vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Load yank notification with line counts
require 'yank_notification'

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system {
		'git',
		'clone',
		'--filter=blob:none',
		'https://github.com/folke/lazy.nvim.git',
		'--branch=stable', -- latest stable release
		lazypath,
	}
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure plugins ]]
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.

-- Disables which-key healthcheck notifications
do
	local orig_notify = vim.notify
	vim.notify = function(msg, ...)
		if type(msg) == 'string' and msg:match 'which%-key' then
			return -- ignore WhichKey health messages
		end
		return orig_notify(msg, ...)
	end
end

require('lazy').setup({
	-- NOTE: First, some plugins that don't require any configuration
	-- Git related plugins
	{
		'tpope/vim-fugitive',
		cmd = { 'Git', 'G', 'Gdiffsplit', 'Gread', 'Gwrite', 'Ggrep', 'GMove', 'GDelete', 'GBrowse' },
		dependencies = { 'tpope/vim-rhubarb' },
	},

	{ -- NOTE: This is where your plugins related to LSP can be installed.
		-- LSP Configuration & Plugins
		'neovim/nvim-lspconfig',
		event = { 'BufReadPre', 'BufNewFile' },
		dependencies = {
			-- Automatically install LSPs to stdpath for neovim
			'williamboman/mason.nvim',
			'williamboman/mason-lspconfig.nvim',

			-- Conform
			{
				'stevearc/conform.nvim',
				opts = {
					formatters_by_ft = {
						lua = { 'stylua' },
						python = { 'isort', 'yapf' },
						javascript = {
							'prettierd',
						},
						typescript = {
							'prettierd',
						},
						typescriptreact = {
							'prettierd',
						},
						css = {
							'prettierd',
						},
						html = {
							'prettierd',
						},
						json = {
							'prettierd',
						},
						c = {
							'clang-format',
						},
						cpp = {
							'clang-format',
						},
						bash = { 'shfmt' },
						rust = { 'rustfmt' },
					},
					format_on_save = {
						timeout_ms = 500,
						lsp_format = 'fallback',
					},
				},
				-- format without saving
				vim.keymap.set('n', '<leader>f', function()
					require('conform').format { async = true }
				end, { desc = 'Format buffer' }),
			},

			-- Install formatters automatically
			{
				'zapling/mason-conform.nvim',
				dependencies = { 'williamboman/mason.nvim', 'stevearc/conform.nvim' },
				config = function()
					require('mason-conform').setup {
						ensure_installed = true, -- auto-install all formatters listed in Conform
					}
				end,
			},
			-- Useful status updates for LSP
			-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
			{ 'j-hui/fidget.nvim', opts = {} },

			-- Additional lua configuration, makes nvim stuff amazing!
			'folke/neodev.nvim',
		},
	},
	{ -- Autocompletion
		'hrsh7th/nvim-cmp',
		event = 'InsertEnter',
		dependencies = {
			-- Snippet Engine & its associated nvim-cmp source
			'L3MON4D3/LuaSnip',
			dependencies = { 'rafamadriz/friendly-snippets' },
			'saadparwaiz1/cmp_luasnip',
			-- Adds LSP completion capabilities
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-path',
			-- Adds a number of user-friendly snippets
			'rafamadriz/friendly-snippets',
		},
	},

	-- Useful plugin to show you pending keybinds.
	{ 'folke/which-key.nvim', event = 'VeryLazy', opts = {} },
	{
		-- Adds git related signs to the gutter, as well as utilities for managing changes
		'lewis6991/gitsigns.nvim',
		event = 'BufReadPre',
		opts = {
			-- See `:help gitsigns.txt`
			signs = {
				add = { text = '+' },
				change = { text = '~' },
				delete = { text = '_' },
				topdelete = { text = '‾' },
				changedelete = { text = '~' },
			},
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				-- Navigation
				map({ 'n', 'v' }, ']c', function()
					if vim.wo.diff then
						return ']c'
					end
					vim.schedule(function()
						gs.next_hunk()
					end)
					return '<Ignore>'
				end, { expr = true, desc = 'Jump to next hunk' })

				map({ 'n', 'v' }, '[c', function()
					if vim.wo.diff then
						return '[c'
					end
					vim.schedule(function()
						gs.prev_hunk()
					end)
					return '<Ignore>'
				end, { expr = true, desc = 'Jump to previous hunk' })

				-- Actions
				-- visual mode
				map('v', '<leader>hs', function()
					gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
				end, { desc = 'stage git hunk' })
				map('v', '<leader>hr', function()
					gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
				end, { desc = 'reset git hunk' })
				-- normal mode
				map('n', '<leader>hs', gs.stage_hunk, { desc = 'git stage hunk' })
				map('n', '<leader>hr', gs.reset_hunk, { desc = 'git reset hunk' })
				map('n', '<leader>hS', gs.stage_buffer, { desc = 'git Stage buffer' })
				map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
				map('n', '<leader>hR', gs.reset_buffer, { desc = 'git Reset buffer' })
				map('n', '<leader>hp', gs.preview_hunk, { desc = 'preview git hunk' })
				map('n', '<leader>hb', function()
					gs.blame_line { full = false }
				end, { desc = 'git blame line' })
				map('n', '<leader>hd', gs.diffthis, { desc = 'git diff against index' })
				map('n', '<leader>hD', function()
					gs.diffthis '~'
				end, { desc = 'git diff against last commit' })

				-- Toggles
				map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
				map('n', '<leader>td', gs.toggle_deleted, { desc = 'toggle git show deleted' })

				-- Text object
				map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
			end,
		},
	},
	{
		--kanagawa colorscheme
		'rebelot/kanagawa.nvim',
		lazy = false,
		priority = 1000,
		opts = {},
	},
	{
		-- Set lualine as statusline
		'nvim-lualine/lualine.nvim',
		-- See `:help lualine.txt`
		opts = {
			options = {
				icons_enabled = true,
				component_separators = '|',
				section_separators = '',
			},
		},
	},
	{
		-- Add indentation guides even on blank lines
		'lukas-reineke/indent-blankline.nvim',
		-- Enable `lukas-reineke/indent-blankline.nvim`
		-- See `:help ibl`
		main = 'ibl',
		event = 'BufReadPre',
		opts = {},
	},
	-- "gc" to comment visual regions/lines
	{ 'numToStr/Comment.nvim', event = 'BufReadPre', opts = {} },
	{
		-- Highlight, edit, and navigate code
		'nvim-treesitter/nvim-treesitter',
		dependencies = {
			'nvim-treesitter/nvim-treesitter-textobjects',
		},
		build = ':TSUpdate',
	},
	{ --Autopairs
		'windwp/nvim-autopairs',
		event = 'InsertEnter',
		config = true,
		-- use opts = {} for passing setup options
		-- this is equalent to setup({}) function
	},
	-- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
	--       These are some example plugins that I've included in the kickstart repository.
	--       Uncomment any of the lines below to enable them.
	require 'plugins.kickstart.autoformat',
	--require 'plugins.kickstart.debug'

	-- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/plugins/custom/*.lua`
	--    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
	--    up-to-date with whatever is in the kickstart repo.
	--    Uncomment the following line and add your plugins to `lua/plugins/custom/*.lua` to get going.
	--    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
	{ import = 'plugins.custom' },
}, {})

-- custom/keymaps.lua file
require 'keymaps'

-- Copy custom snippets from custom_friendly_snippets folder
require 'replace_with_custom_snippets'

-- [[ Setting options ]]
-- See `:help vim.o`

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.opt.number = true

-- Relative line number
vim.opt.relativenumber = true

-- Enable mouse mode
vim.o.mouse = ''

-- Always keep a distance of the cursor to the top and bottom of the screen
vim.opt.scrolloff = 8

-- Sync clipboard between OS and Neovim.
--  See `:help 'clipboard'`
-- vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- Tabs and indentation
vim.o.expandtab = false -- use spaces instead of tabs
vim.o.shiftwidth = 4 -- number of spaces for autoindent
vim.o.softtabstop = 0 -- number of spaces per Tab in insert mode
vim.o.tabstop = 4 -- number of spaces a Tab counts for
vim.o.smartindent = true -- auto-indent new lines

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = '*',
})

-- Theme
require('kanagawa').setup { transparent = true }
vim.cmd [[colorscheme kanagawa]]

-- Custom native-looking tabline that matches Kanagawa theme
vim.o.showtabline = 1
_G.tab_offset = 1
local max_visible_tabs = 8 -- maximum number of tabs visible at once

function _G.Tabline()
	local current_tab = vim.fn.tabpagenr()
	local tab_count = vim.fn.tabpagenr '$'
	local win_width = vim.o.columns
	local tab_width = math.floor(win_width / max_visible_tabs) -- FIXED width

	local tabs = {}
	for i = 1, tab_count do
		local buflist = vim.fn.tabpagebuflist(i)
		local winnr = vim.fn.tabpagewinnr(i)
		local bufname = vim.fn.bufname(buflist[winnr])
		if bufname == '' then
			bufname = '[No Name]'
		end
		local modified = vim.fn.getbufvar(buflist[winnr], '&mod') == 1 and ' ●' or ''
		local label = i .. ': ' .. vim.fn.fnamemodify(bufname, ':t') .. modified

		-- truncate/pad to fixed tab_width
		if #label > tab_width - 2 then
			label = label:sub(1, tab_width - 3) .. '…'
		end
		label = label .. string.rep(' ', tab_width - #label)

		tabs[i] = (i == current_tab and '%#TabLineSel#' or '%#TabLine#') .. label
	end

	-- scrolling logic to keep active tab visible
	local start_index = _G.tab_offset
	if current_tab < start_index then
		start_index = current_tab
	elseif current_tab >= start_index + max_visible_tabs then
		start_index = current_tab - max_visible_tabs + 1
	end
	_G.tab_offset = start_index

	-- select visible tabs
	local visible_tabs = {}
	for i = start_index, math.min(start_index + max_visible_tabs - 1, tab_count) do
		table.insert(visible_tabs, tabs[i])
	end

	-- scrolling arrows
	local left_arrow = start_index > 1 and '< ' or '  '
	local right_arrow = start_index + max_visible_tabs - 1 < tab_count and ' >' or '  '

	return '%#TabLine#' .. left_arrow .. table.concat(visible_tabs, '') .. right_arrow .. '%#TabLineFill#'
end

vim.o.tabline = '%!v:lua.Tabline()'

-- adjust offset if tabs are closed
vim.api.nvim_create_autocmd({ 'TabClosed' }, {
	callback = function()
		local tab_count = vim.fn.tabpagenr '$'
		if _G.tab_offset > tab_count then
			_G.tab_offset = math.max(tab_count - max_visible_tabs + 1, 1)
		end
	end,
})

-- Auto-create config files for formatters (cross-platform)
local uv = vim.loop
local home = uv.os_homedir()
local os_name = uv.os_uname().sysname
local appdata = os.getenv 'APPDATA' or (home .. '/AppData/Roaming')

-- List of formatter configs
local formatters = {
	{
		name = 'clang-format',
		path = (os_name:match 'Windows' and home .. '\\.clang-format' or home .. '/.clang-format'),
		content = [[
BasedOnStyle: LLVM
IndentWidth: 4
TabWidth: 4
UseTab: Always
]],
	},
	{
		name = 'prettier',
		path = (os_name:match 'Windows' and appdata .. '\\Prettier\\.prettierrc' or home .. '/.prettierrc'),
		content = [[
{
  "tabWidth": 4,
  "useTabs": true,
  "semi": true,
  "singleQuote": true,
  "trailingComma": "es5",
  "printWidth": 100
}
]],
	},
	{
		name = 'yapf',
		path = (os_name:match 'Windows' and home .. '\\.style.yapf' or home .. '/.style.yapf'),
		content = [[
[style]
based_on_style = pep8
indent_width = 4
use_tabs = True
]],
	},
	{
		name = 'isort',
		path = (os_name:match 'Windows' and home .. '\\.isort.cfg' or home .. '/.isort.cfg'),
		content = [[
[settings]
profile = black
force_single_line = true
]],
	},
}

-- Helper to create file if it doesn't exist
local function ensure_file(path, content)
	if not path then
		print 'Invalid path, skipping file creation'
		return
	end

	local stat = uv.fs_stat(path)
	if not stat then
		-- Make parent directory if needed
		local dir = vim.fn.fnamemodify(path, ':h')
		if vim.fn.isdirectory(dir) == 0 then
			vim.fn.mkdir(dir, 'p') -- recursively create directories
			print('Created directory: ' .. dir)
		end

		-- Write the file
		local fd = uv.fs_open(path, 'w', 420) -- 0644
		if fd then
			uv.fs_write(fd, content, -1)
			uv.fs_close(fd)
			print('Created file: ' .. path)
		else
			print('Failed to create file: ' .. path)
		end
	end
end

-- Loop through all formatter configs
for _, fmt in ipairs(formatters) do
	ensure_file(fmt.path, fmt.content)
end

-- Auto-clear messages on most user actions
local clear_msg_grp = vim.api.nvim_create_augroup('AutoClearMessages', { clear = true })

vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'InsertEnter', 'InsertLeave', 'TextChanged', 'TextChangedI' }, {
	group = clear_msg_grp,
	callback = function()
		vim.cmd 'echo ""' -- Clear the message/command line
	end,
})

-- Auto-clear messages on pressing ESC
vim.keymap.set('n', '<Esc>', '<Esc><Cmd>echo ""<CR>', { noremap = true, silent = true })
vim.keymap.set('v', '<Esc>', '<Esc><Cmd>echo ""<CR>', { noremap = true, silent = true })

-- When a file is deleted externally, rename all its buffers to "[file]: file removed"
-- List of buffer names or filetypes to skip (UndoTree, Neo-tree, etc.)
local skip_buffers = { 'undotree', 'neo-tree' }
-- Helper function to determine if a buffer should be skipped in future
local function should_skip(buf)
	if not vim.api.nvim_buf_is_valid(buf) then
		return true
	end
	local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
	local bufname = vim.api.nvim_buf_get_name(buf)
	if bufname == '' then
		return true
	end
	for _, v in ipairs(skip_buffers) do
		if ft == v or bufname:match(v) then
			return true
		end
	end
	return false
end
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost' }, {
	callback = function()
		local current_buf = vim.api.nvim_get_current_buf()
		if should_skip(current_buf) then
			return
		end
		local bufname = vim.api.nvim_buf_get_name(current_buf)
		-- If this file no longer exists, mark all buffers showing it
		if vim.fn.filereadable(bufname) == 0 then
			local filename = vim.fn.fnamemodify(bufname, ':t')
			local new_name = string.format('[%s]: file removed', filename)
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if vim.api.nvim_buf_is_valid(buf) then
					local name = vim.api.nvim_buf_get_name(buf)
					if name == bufname and not name:match 'file removed' then
						-- Temporarily unlist so renaming works cleanly
						vim.api.nvim_buf_set_option(buf, 'buflisted', false)
						vim.api.nvim_buf_set_name(buf, new_name)
						vim.api.nvim_buf_set_option(buf, 'buflisted', true)
					end
				end
			end
		end
	end,
})
-- Automatically wipe "file removed" buffers when they are closed
vim.api.nvim_create_autocmd('BufWinLeave', {
	callback = function(args)
		local buf = args.buf
		if should_skip(buf) then
			return
		end
		local bufname = vim.api.nvim_buf_get_name(buf)
		-- If the buffer was marked for wipe or name indicates it's deleted
		local marked = pcall(vim.api.nvim_buf_get_var, buf, 'marked_for_wipe') and vim.api.nvim_buf_get_var(buf, 'marked_for_wipe')
		if marked or (bufname ~= '' and bufname:match 'file removed') then
			vim.schedule(function()
				if vim.api.nvim_buf_is_valid(buf) then
					vim.cmd('bwipeout! ' .. buf)
				end
			end)
		end
	end,
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
