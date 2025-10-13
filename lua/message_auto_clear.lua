-- Auto-clear command line messages on most user actions and on pressing ESC

local M = {}

function M.setup()
	-- Create an augroup for auto-clearing messages
	local clear_msg_grp = vim.api.nvim_create_augroup('AutoClearMessages', { clear = true })

	-- Clear messages on common user actions
	vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'InsertEnter', 'InsertLeave', 'TextChanged', 'TextChangedI' }, {
		group = clear_msg_grp,
		callback = function()
			vim.cmd 'echo ""' -- Clear the message/command line
		end,
	})

	-- Clear messages when pressing ESC in normal and visual modes
	vim.keymap.set('n', '<Esc>', '<Esc><Cmd>echo ""<CR>', { noremap = true, silent = true })
	vim.keymap.set('v', '<Esc>', '<Esc><Cmd>echo ""<CR>', { noremap = true, silent = true })
end

return M
