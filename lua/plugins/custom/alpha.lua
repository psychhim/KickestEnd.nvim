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
			dashboard.button('i', '  New File', function()
				local alpha_buf = vim.api.nvim_get_current_buf()
				vim.api.nvim_buf_delete(alpha_buf, { force = true })
				vim.cmd 'enew'
				vim.cmd 'startinsert'
			end),
			-- Open Neo-tree in starting directory
			dashboard.button('<leader>n', '  Open Neo-tree', '<Cmd>cd ' .. vim.fn.fnameescape(start_dir) .. ' | Neotree toggle float<CR>'),
			-- Close Alpha window
			dashboard.button('<leader>q', '  Close this window', function()
				local current_buf = vim.api.nvim_get_current_buf()
				-- Count listed buffers
				local listed_count = 0
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if vim.api.nvim_buf_get_option(buf, 'buflisted') then
						listed_count = listed_count + 1
					end
				end
				-- If only 1 listed buffer left, force quit Neovim
				if listed_count == 1 then
					vim.cmd 'qa!'
				else
					-- Delete current buffer
					if vim.api.nvim_buf_is_valid(current_buf) then
						vim.api.nvim_buf_delete(current_buf, { force = true })
					end
					-- Delete one listed, unmodified, no-name buffer
					for _, buf in ipairs(vim.api.nvim_list_bufs()) do
						if vim.api.nvim_buf_is_valid(buf) then
							local listed = vim.api.nvim_buf_get_option(buf, 'buflisted')
							local modified = vim.api.nvim_buf_get_option(buf, 'modified')
							local name = vim.api.nvim_buf_get_name(buf)
							-- target buffers that are listed, have no modifications, and no name
							if listed and not modified and name == '' then
								vim.api.nvim_buf_delete(buf, { force = true })
								break -- delete only one buffer
							end
						end
					end
				end
			end),
		}

		-- Ensure Alpha buffer is a scratch buffer so closing it doesn’t leave [No Name]
		local opts = dashboard.opts
		opts.hide = true -- hide it from buffer list
		alpha.setup(opts)

		-- Open Alpha in a dedicated scratch buffer if no file is loaded
		if vim.fn.bufnr '$' == 1 and vim.fn.bufname(0) == '' then
			vim.cmd 'enew' -- create a proper empty buffer
			vim.cmd 'Alpha' -- open Alpha in that buffer
			vim.bo.buflisted = false -- mark it unlisted so it doesn’t pollute buffer pickers
			vim.bo.buftype = 'nofile' -- make it a scratch buffer
			--			vim.bo.bufhidden = 'wipe' -- critical: buffer is automatically deleted when hidden
		end
	end,
}
