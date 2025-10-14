-- Auto-apply all preferred settings to every normal buffer
local M = {}

function M.setup()
	vim.api.nvim_create_autocmd({ 'BufWinEnter', 'WinEnter', 'BufEnter' }, {
		callback = function()
			local ft = vim.bo.filetype
			local bt = vim.bo.buftype

			-- Skip floating or special buffers
			if ft == 'neo-tree' or ft == 'TelescopePrompt' or bt == 'terminal' or bt == 'nofile' then
				return
			end

			-- Window-local options
			vim.wo.number = true
			vim.wo.relativenumber = true
			vim.wo.signcolumn = 'yes'
			vim.wo.scrolloff = 8

			-- Global options
			vim.o.hlsearch = false
			vim.o.mouse = '' -- disable mouse
			vim.o.breakindent = true
			vim.o.undofile = true
			vim.o.ignorecase = true
			vim.o.smartcase = true
			vim.o.updatetime = 250
			vim.o.timeoutlen = 300
			vim.o.completeopt = 'menuone,noselect'
			vim.o.termguicolors = true
			vim.o.showtabline = 1

			-- Tabs and indentation
			vim.o.expandtab = false
			vim.o.shiftwidth = 4
			vim.o.softtabstop = 0
			vim.o.tabstop = 4
			vim.o.smartindent = true
		end,
	})
end

return M
