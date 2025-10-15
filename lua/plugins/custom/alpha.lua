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
			-- Create new tab
			dashboard.button('<leader>e', '  New Tab', function()
				-- Open a new tab
				vim.cmd 'tabnew'
				-- Open Alpha in that new tab
				require('alpha').start(true)
			end),
			-- Open Neo-tree in current directory
			dashboard.button('<leader>n', '  Open Neo-tree', '<Cmd>Neotree toggle float<CR>'),
			-- Close Alpha window or quit Neovim
			dashboard.button('<leader>q', '  Exit', function()
				-- Get current tab windows
				local wins = vim.api.nvim_tabpage_list_wins(0)
				if #wins > 1 then
					-- If there are other windows in this tab, just close the Alpha window
					vim.cmd 'close'
				else
					-- If this is the only window in the tab, check total tabs
					local tab_count = #vim.api.nvim_list_tabpages()
					if tab_count > 1 then
						-- Close only the current tab
						vim.cmd 'tabclose'
					else
						-- Quit Neovim if this is the last tab
						vim.cmd 'qa!'
					end
				end
			end),
		}

		-- Setup Alpha dashboard
		alpha.setup(dashboard.opts)
	end,
}
