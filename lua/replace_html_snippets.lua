local uv = vim.loop
local home = uv.os_homedir()
-- Detect OS and friendly-snippets path
local function get_friendly_snippets_html_path()
	local os_name = uv.os_uname().sysname
	if os_name == 'Windows_NT' then
		return home .. '\\.local\\share\\nvim\\lazy\\friendly-snippets\\snippets\\html.json'
	else
		return home .. '/.local/share/nvim/lazy/friendly-snippets/snippets/html.json'
	end
end
local target_path = get_friendly_snippets_html_path()
local source_path = vim.fn.stdpath 'config' .. '/lua/custom_html_snippets.json'
-- Read source file
local source_file = io.open(source_path, 'r')
if not source_file then
	vim.notify('Custom html.json not found at ' .. source_path, vim.log.levels.ERROR)
	return
end
local source_content = source_file:read '*a'
source_file:close()
-- Read target file
local target_content = ''
local target_file = io.open(target_path, 'r')
if target_file then
	target_content = target_file:read '*a'
	target_file:close()
end
-- Only update if the contents differ
if target_content ~= source_content then
	-- Create backup only if it doesn't exist
	local backup_path = target_path .. '.bak'
	if not uv.fs_stat(backup_path) and target_content ~= '' then
		local backup_file = io.open(backup_path, 'w')
		if backup_file then
			backup_file:write(target_content)
			backup_file:close()
		else
			vim.notify('Failed to create backup: ' .. backup_path, vim.log.levels.ERROR)
		end
	end
	-- Write custom file
	local output = io.open(target_path, 'w')
	if output then
		output:write(source_content)
		output:close()
	else
		vim.notify('Failed to write custom html.json to ' .. target_path, vim.log.levels.ERROR)
	end
end
