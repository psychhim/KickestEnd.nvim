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
			-- New file
			dashboard.button('i', '  New File', '<Cmd>ene <Bar> startinsert<CR>'),
			-- Open Neo-tree in starting directory
			dashboard.button('<leader>n', '  Open Neo-tree', '<Cmd>cd ' .. vim.fn.fnameescape(start_dir) .. ' | Neotree toggle float<CR>'),
			-- Quit Neovim
			dashboard.button('<leader>q', '  Quit', '<Cmd>qa<CR>'),
		}

		alpha.setup(dashboard.opts)
	end,
}
