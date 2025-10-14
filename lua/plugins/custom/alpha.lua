return {
	'goolord/alpha-nvim',
	lazy = false,
	config = function()
		local alpha = require 'alpha'
		local dashboard = require 'alpha.themes.dashboard'

		local splash = require 'ascii_splash'
		dashboard.section.header.val = splash

		dashboard.section.buttons.val = {
			dashboard.button('e', '  New File', ':ene <BAR> startinsert <CR>'),
			dashboard.button('q', '  Quit', ':qa<CR>'),
		}

		alpha.setup(dashboard.opts)
	end,
}
