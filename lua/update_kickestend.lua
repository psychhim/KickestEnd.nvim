-- ~/.config/nvim/lua/update_kickestend.lua
-- Command: :UpdateKickestEnd
-- Safely updates your KickestEnd.nvim config to the latest commit on origin/master

vim.api.nvim_create_user_command('UpdateKickestEnd', function()
	local config_path = vim.fn.expand '~/.config/nvim'

	-- Ensure this is a git repo
	if vim.fn.isdirectory(config_path .. '/.git') == 0 then
		vim.notify('Not a git repository: ' .. config_path, vim.log.levels.ERROR)
		return
	end

	-- Check for local modifications
	local status = vim.fn.systemlist { 'git', '-C', config_path, 'status', '--porcelain' }
	local dirty = #status > 0

	if dirty then
		local answer = vim.fn.input 'Local changes detected! Overwrite them and lose all changes? (y/N): '
		if answer:lower() ~= 'y' then
			vim.notify('Update cancelled to preserve your modifications.', vim.log.levels.WARN)
			return
		end

		vim.notify('Discarding local modifications...', vim.log.levels.WARN)
		vim.fn.system { 'git', '-C', config_path, 'reset', '--hard' }
	end

	-- Fetch and update
	vim.notify('Fetching latest changes from GitHub...', vim.log.levels.INFO)
	local fetch = vim.fn.systemlist { 'git', '-C', config_path, 'fetch', '--all' }
	if vim.v.shell_error ~= 0 then
		vim.notify('Git fetch failed:\n' .. table.concat(fetch, '\n'), vim.log.levels.ERROR)
		return
	end

	vim.notify('Resetting to latest commit on origin/master...', vim.log.levels.INFO)
	local reset = vim.fn.systemlist { 'git', '-C', config_path, 'reset', '--hard', 'origin/master' }
	if vim.v.shell_error ~= 0 then
		vim.notify('Git reset failed:\n' .. table.concat(reset, '\n'), vim.log.levels.ERROR)
		return
	end

	vim.notify('KickestEnd.nvim successfully updated to the latest commit on master!', vim.log.levels.INFO)
end, { desc = 'Safely update KickestEnd.nvim config from origin/master' })
