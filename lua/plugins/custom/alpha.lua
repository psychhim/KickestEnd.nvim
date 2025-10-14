return {
	'goolord/alpha-nvim',
	lazy = false,
	config = function()
		local alpha = require 'alpha'
		local dashboard = require 'alpha.themes.dashboard'

		-- Load ASCII splash
		local splash = require 'ascii_splash'
		dashboard.section.header.val = splash

		-- Get Neovim starting directory
		local start_dir = vim.fn.getcwd()

		-- Setup buttons
		dashboard.section.buttons.val = {
			dashboard.button('i', '  New File', ':ene <BAR> startinsert <CR>'),
			dashboard.button('<leader>n', '  Open Neo-tree', ':cd ' .. start_dir .. ' | Neotree toggle float<CR>'),
			dashboard.button('<leader>q', '  Quit', ':qa<CR>'),
		}

		alpha.setup(dashboard.opts)
	end,
}
