-- When a file is deleted externally, rename all its buffers to "[file]: file removed"

local M = {}

-- List of buffer names or filetypes to skip (UndoTree, Neo-tree, etc.)
local skip_buffers = { 'undotree', 'neo-tree' }

-- Helper function to determine if a buffer should be skipped in future
local function should_skip(buf)
	if not vim.api.nvim_buf_is_valid(buf) then
		return true
	end
	local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
	local bufname = vim.api.nvim_buf_get_name(buf)
	if bufname == '' then
		return true
	end
	for _, v in ipairs(skip_buffers) do
		if ft == v or bufname:match(v) then
			return true
		end
	end
	return false
end

-- Detect deleted files and rename their buffers
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost' }, {
	callback = function()
		local current_buf = vim.api.nvim_get_current_buf()
		if should_skip(current_buf) then
			return
		end
		local bufname = vim.api.nvim_buf_get_name(current_buf)
		-- If this file no longer exists, mark all buffers showing it
		if vim.fn.filereadable(bufname) == 0 then
			local filename = vim.fn.fnamemodify(bufname, ':t')
			local new_name = string.format('[%s]: file removed', filename)
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if vim.api.nvim_buf_is_valid(buf) then
					local name = vim.api.nvim_buf_get_name(buf)
					if name == bufname and not name:match 'file removed' then
						-- Temporarily unlist so renaming works cleanly
						vim.api.nvim_buf_set_option(buf, 'buflisted', false)
						vim.api.nvim_buf_set_name(buf, new_name)
						vim.api.nvim_buf_set_option(buf, 'buflisted', true)
					end
				end
			end
		end
	end,
})

return M
