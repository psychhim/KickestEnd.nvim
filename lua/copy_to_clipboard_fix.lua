local M = {}
function M.trim_clipboard()
	-- Get content from default register
	local content = vim.fn.getreg '"'
	if not content or content == '' then
		return
	end
	-- Remove trailing newline
	content = content:gsub('\n$', '')
	-- Copy to system clipboard
	vim.fn.setreg('+', content)
	vim.fn.setreg('*', content)
	-- Count lines
	local line_count = select(2, content:gsub('\n', '')) + 1
	local plural = line_count == 1 and '' or 's'
	-- Delay clipboard notification slightly to appear after yank notification
	vim.defer_fn(function()
		vim.notify(string.format('Copied %d line%s to clipboard', line_count, plural), vim.log.levels.INFO, { title = 'Clipboard' })
	end, 50) -- 50ms delay
end

return M
