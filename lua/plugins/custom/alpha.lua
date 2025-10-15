return {
	'goolord/alpha-nvim',
	lazy = false,
	config = function()
		local alpha = require 'alpha'
		local dashboard = require 'alpha.themes.dashboard'

		-- Load ASCII splash
		local splash = require 'ascii_splash'
		dashboard.section.header.val = splash

		-- Setup buttons
		dashboard.section.buttons.val = {
			-- New file
			dashboard.button('i', '  New File', function()
				local alpha_buf = vim.api.nvim_get_current_buf()
				vim.api.nvim_buf_delete(alpha_buf, { force = true })
				vim.cmd 'enew'
				vim.cmd 'startinsert'
			end),
			-- Create new empty buffer in a new tab
			dashboard.button('<leader>e', '  New Tab', function()
				local alpha_buf = vim.api.nvim_get_current_buf()
				-- Close Alpha buffer
				vim.api.nvim_buf_delete(alpha_buf, { force = true })
				-- Create new tab and empty buffer
				vim.cmd 'tabnew'
				vim.cmd 'enew'
			end),
			-- Open Neo-tree in current directory
			dashboard.button('<leader>n', '  Open Neo-tree', '<Cmd>Neotree toggle float<CR>'),
			-- Close Neovim
			dashboard.button('<leader>q', '  Exit', function()
				vim.cmd 'qa!'
			end),
		}

		-- Setup Alpha dashboard
		alpha.setup(dashboard.opts)
	end,
}
