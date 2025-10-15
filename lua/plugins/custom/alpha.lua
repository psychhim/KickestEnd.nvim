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

		-- Setup Alpha dashboard
		alpha.setup(dashboard.opts)
	end,
}
