local M = {}
vim.api.nvim_create_autocmd('TextYankPost', {
	pattern = '*',
	callback = function(ev)
		local regname = ev.regname or '"'
		-- Ignore clipboard yanks
		if regname == '+' or regname == '*' then
			return
		end
		local content = vim.fn.getreg(regname)
		if not content or content == '' then
			return
		end
		local lines = vim.split(content, '\n', true)
		if lines[#lines] == '' then
			table.remove(lines, #lines)
		end
		local line_count = #lines
		vim.schedule(function()
			local plural = line_count == 1 and '' or 's'
			vim.notify(string.format('Yanked %d line%s', line_count, plural), vim.log.levels.INFO, { title = 'Yank' })
		end)
	end,
})

return M
