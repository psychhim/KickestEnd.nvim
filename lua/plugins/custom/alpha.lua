return {
	'goolord/alpha-nvim',
	lazy = false,
	config = function()
		local alpha = require 'alpha'
		local dashboard = require 'alpha.themes.dashboard'

		-- Load random ASCII arts
		-- Keep track of last shown ASCII art
		local last_ascii = nil
		-- load a random ASCII art
		local function load_random_ascii()
			local ascii_dir = vim.fn.stdpath 'config' .. '/lua/ascii_arts/'
			local pattern = ascii_dir .. 'ascii_art_*.lua'
			local ascii_art_files = vim.fn.glob(pattern, false, true)
			if vim.tbl_isempty(ascii_art_files) then
				return { 'Alpha' }
			end
			-- Convert file paths to module names (for require)
			local ascii_modules = {}
			for _, path in ipairs(ascii_art_files) do
				local name = path:match 'ascii_arts/([^/]+)%.lua$'
				if name then
					table.insert(ascii_modules, 'ascii_arts.' .. name)
				end
			end
			-- If only one ASCII exists, return it
			if #ascii_modules == 1 then
				last_ascii = ascii_modules[1]
				local ok, splash = pcall(require, last_ascii)
				return ok and splash or { 'Alpha' }
			end
			-- Pick a random one that isn't the same as last
			math.randomseed(os.time() + vim.loop.hrtime())
			local selected = ascii_modules[math.random(#ascii_modules)]
			while selected == last_ascii and #ascii_modules > 1 do
				selected = ascii_modules[math.random(#ascii_modules)]
			end
			last_ascii = selected
			local ok, splash = pcall(require, selected)
			return (ok and type(splash) == 'table') and splash or { 'Alpha' }
		end
		-- Function to refresh dashboard header dynamically
		local function refresh_header()
			dashboard.section.header.val = load_random_ascii()
			alpha.redraw()
		end

		-- Setup buttons
		dashboard.section.buttons.val = {
			-- New file
			dashboard.button('i', '  New File', '<Cmd>enew<CR><Cmd>startinsert<CR>'),
			-- Create new tab and open Alpha
			dashboard.button('<leader>e', '  New Tab', '<Cmd>tabnew<CR><Cmd>lua require("alpha").start(true)<CR>'),
			-- Open Neo-tree in current directory
			dashboard.button('<leader>n', '  Open Neo-tree', '<Cmd>Neotree toggle float<CR>'),
			-- Close Alpha window or quit Neovim
			dashboard.button(
				'<leader>q',
				'  Exit',
				'<Cmd>lua (function() local wins = vim.api.nvim_tabpage_list_wins(0) if #wins > 1 then vim.cmd("close") else local tab_count = #vim.api.nvim_list_tabpages() if tab_count > 1 then vim.cmd("tabclose") else vim.cmd("qa!") end end end)()<CR>'
			),
		}

		-- Setup Alpha initially
		dashboard.section.header.val = load_random_ascii()
		alpha.setup(dashboard.opts)

		-- Auto-refresh header whenever Alpha is opened
		vim.api.nvim_create_autocmd('User', {
			pattern = 'AlphaReady',
			callback = function()
				refresh_header()
			end,
		})
	end,
}
