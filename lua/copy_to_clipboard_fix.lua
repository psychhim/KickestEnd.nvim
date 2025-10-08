local M = {}
function M.trim_clipboard()
	-- Get the content of the '+' register
	local content = vim.fn.getreg '+'
	-- Remove single trailing newline if present
	content = content:gsub('\n$', '')
	-- Update '+' and '*' registers
	vim.fn.setreg('+', content)
	vim.fn.setreg('*', content)
	-- Count the number of lines copied
	local line_count = select(2, content:gsub('\n', '')) + 1 -- Number of newlines + 1
	-- Notification with line count
	local plural = line_count == 1 and '' or 's'
	vim.notify(string.format('Copied %d line%s to clipboard', line_count, plural), vim.log.levels.INFO)
end

return M
