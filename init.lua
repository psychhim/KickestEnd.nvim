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
	'tpope/vim-fugitive',
	'tpope/vim-rhubarb',

	-- NOTE: This is where your plugins related to LSP can be installed.
	--  The configuration is done below. Search for lspconfig to find it below.
	{
		-- LSP Configuration & Plugins
		'neovim/nvim-lspconfig',
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
	{ 'folke/which-key.nvim', opts = {} },
	{
		-- Adds git related signs to the gutter, as well as utilities for managing changes
		'lewis6991/gitsigns.nvim',
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
		opts = {},
	},
	-- "gc" to comment visual regions/lines
	{ 'numToStr/Comment.nvim', opts = {} },
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
	require 'kickstart.plugins.autoformat',
	--require 'kickstart.plugins.debug'

	-- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
	--    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
	--    up-to-date with whatever is in the kickstart repo.
	--    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
	--    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
	{ import = 'custom.plugins' },
}, {})

-- custom/keymaps.lua file
require 'keymaps'

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

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
	require('nvim-treesitter.configs').setup {
		-- Add languages to be installed here that you want installed for treesitter
		ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash' },

		-- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
		auto_install = false,

		highlight = { enable = true },
		indent = { enable = true },
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = '<c-space>',
				node_incremental = '<c-space>',
				scope_incremental = '<c-s>',
				node_decremental = '<M-space>',
			},
		},
		textobjects = {
			select = {
				enable = true,
				lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
				keymaps = {
					-- You can use the capture groups defined in textobjects.scm
					['aa'] = '@parameter.outer',
					['ia'] = '@parameter.inner',
					['af'] = '@function.outer',
					['if'] = '@function.inner',
					['ac'] = '@class.outer',
					['ic'] = '@class.inner',
				},
			},
			move = {
				enable = true,
				set_jumps = true, -- whether to set jumps in the jumplist
				goto_next_start = {
					[']m'] = '@function.outer',
					[']]'] = '@class.outer',
				},
				goto_next_end = {
					[']M'] = '@function.outer',
					[']['] = '@class.outer',
				},
				goto_previous_start = {
					['[m'] = '@function.outer',
					['[['] = '@class.outer',
				},
				goto_previous_end = {
					['[M'] = '@function.outer',
					['[]'] = '@class.outer',
				},
			},
			swap = {
				enable = true,
				swap_next = {
					['<leader>a'] = '@parameter.inner',
				},
				swap_previous = {
					['<leader>A'] = '@parameter.inner',
				},
			},
		},
	}
end, 0)

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
	-- NOTE: Remember that lua is a real programming language, and as such it is possible
	-- to define small helper and utility functions so you don't have to repeat yourself
	-- many times.
	-- In this case, we create a function that lets us more easily define mappings specific
	-- for LSP related items. It sets the mode, buffer and description for us each time.
	local nmap = function(keys, func, desc)
		if desc then
			desc = 'LSP: ' .. desc
		end

		vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
	end

	nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
	nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

	nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
	nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
	nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
	nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
	nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
	nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

	-- See `:help K` for why this keymap
	nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
	nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

	-- Lesser used LSP functionality
	nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
	nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
	nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
	nmap('<leader>wl', function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, '[W]orkspace [L]ist Folders')

	-- Create a command `:Format` local to the buffer using Conform
	vim.api.nvim_buf_create_user_command(bufnr, 'Format', function()
		require('conform').format { bufnr = bufnr }
	end, { desc = 'Format current buffer with Conform' })
end

-- document existing key chains
require('which-key').register {
	['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
	['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
	['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
	['<leader>h'] = { name = 'Git [H]unk', _ = 'which_key_ignore' },
	['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
	['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
	['<leader>t'] = { name = '[T]oggle', _ = 'which_key_ignore' },
	['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
}
-- register which-key VISUAL mode
-- required for visual <leader>hs (hunk stage) to work
require('which-key').register({
	['<leader>'] = { name = 'VISUAL <leader>' },
	['<leader>h'] = { 'Git [H]unk' },
}, { mode = 'v' })

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
	-- clangd = {},
	-- gopls = {},
	-- pyright = {},
	-- rust_analyzer = {},
	-- tsserver = {},
	-- html = { filetypes = { 'html', 'twig', 'hbs'} },

	lua_ls = {
		Lua = {
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
			-- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
			-- diagnostics = { disable = { 'missing-fields' } },
		},
	},
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
	ensure_installed = vim.tbl_keys(servers),
	handlers = {
		function(server_name)
			require('lspconfig')[server_name].setup {
				capabilities = capabilities,
				on_attach = on_attach,
				settings = servers[server_name],
				filetypes = (servers[server_name] or {}).filetypes,
			}
		end,
	},
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
--require("luasnip.loaders.from_vscode").lazy_load()
--require('luasnip.loaders.from_vscode').lazy_load({ paths = { "~/.config/nvim/my_snippets" } })
luasnip.config.setup {}

cmp.setup {
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	completion = {
		completeopt = 'menu,menuone,noinsert',
	},
	mapping = cmp.mapping.preset.insert {
		['<C-n>'] = cmp.mapping.select_next_item(),
		['<C-p>'] = cmp.mapping.select_prev_item(),
		['<C-d>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete {},
		['<CR>'] = cmp.mapping.confirm {
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		},
		['<Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_locally_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { 'i', 's' }),
		['<S-Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.locally_jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { 'i', 's' }),
	},
	sources = {
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' },
		{ name = 'path' },
	},
}
--Load Luasnip.loaders
require('luasnip.loaders.from_vscode').lazy_load()

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

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
