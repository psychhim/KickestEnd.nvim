local M = {}
vim.api.nvim_create_autocmd('TextYankPost', {
	pattern = '*',
	callback = function()
		local content = vim.fn.getreg '"'
		if not content or content == '' then
			return
		end
		-- Split by newline
		local lines = vim.split(content, '\n', true)
		-- Remove trailing empty line if present
		if lines[#lines] == '' then
			table.remove(lines, #lines)
		end
		local line_count = #lines
		vim.schedule(function()
			local plural = line_count == 1 and '' or 's'
			vim.notify(string.format('Yanked %d line%s', line_count, plural), vim.log.levels.INFO)
		end)
	end,
})

return M
