-- Unless you are still migrating, remove the deprecated commands from v1.x
vim.cmd [[ let g:neo_tree_remove_legacy_commands = 1 ]]

return {
	'nvim-neo-tree/neo-tree.nvim',
	version = '*',
	dependencies = {
		'nvim-lua/plenary.nvim',
		'nvim-tree/nvim-web-devicons',
		'MunifTanjim/nui.nvim',
	},
	config = function()
		-- Handling deleted file or folder buffers, marking them as removed
		local function delete_file_mark_removed(state)
			local node = state.tree:get_node()
			if not node then
				return true
			end
			local path = node.path
			local is_dir = (node.type == 'directory')
			-- Ask for confirmation
			local label = vim.fn.fnamemodify(path, ':t') .. (is_dir and '/' or '')
			local choice = vim.fn.confirm('Are you sure you want to delete: ' .. label .. '?', '&Yes\n&No', 2)
			if choice ~= 1 then
				return true
			end -- user chose "No"
			-- Delete file or folder recursively
			if is_dir then
				local function rm_dir_recursive(target)
					local fs = vim.loop.fs_scandir(target)
					if not fs then
						return
					end
					while true do
						local name, t = vim.loop.fs_scandir_next(fs)
						if not name then
							break
						end
						local fullpath = target .. '/' .. name
						if t == 'directory' then
							rm_dir_recursive(fullpath)
						else
							vim.loop.fs_unlink(fullpath)
						end
					end
					vim.loop.fs_rmdir(target)
				end
				rm_dir_recursive(path)
			else
				vim.loop.fs_unlink(path)
			end
			-- Refresh Neo-tree
			state.commands.refresh(state)
			-- Mark all open buffers showing this path (for files only)
			if not is_dir then
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if vim.api.nvim_buf_is_valid(buf) then
						local name = vim.api.nvim_buf_get_name(buf)
						if name == path then
							local filename = vim.fn.fnamemodify(path, ':t')
							local new_name = string.format('[%s]: file removed', filename)
							vim.api.nvim_buf_set_option(buf, 'buflisted', false)
							vim.api.nvim_buf_set_name(buf, new_name)
							vim.api.nvim_buf_set_option(buf, 'buflisted', true)
							-- Optionally tag for wipe later
							vim.api.nvim_buf_set_var(buf, 'marked_for_wipe', true)
						end
					end
				end
			end
			return true
		end
		-- Track last created file or folder
		local last_created_path = nil
		vim.api.nvim_set_hl(0, 'NeoTreeLastCreated', { fg = '#00ff00', bold = true })
		local function normalize_path(path)
			return vim.fn.fnamemodify(path, ':p')
		end
		local function smart_open(state)
			local node = state.tree:get_node()
			if not node then
				return
			end
			local path = node.path
			-- If the node is a directory, just toggle expand/collapse
			if node.type == 'directory' then
				state.commands.toggle_node(state, node)
				return
			end
			-- --- File handling starts here ---
			-- Reuse already open buffer in any tab safely
			for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
				if vim.api.nvim_tabpage_is_valid(tab) then
					for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
						if vim.api.nvim_win_is_valid(win) then
							local buf = vim.api.nvim_win_get_buf(win)
							if vim.api.nvim_buf_is_valid(buf) and normalize_path(vim.api.nvim_buf_get_name(buf)) == normalize_path(path) then
								vim.api.nvim_set_current_tabpage(tab)
								vim.api.nvim_set_current_win(win)
								-- close Neo-tree if open
								for _, w in ipairs(vim.api.nvim_list_wins()) do
									if vim.api.nvim_win_is_valid(w) then
										local b = vim.api.nvim_win_get_buf(w)
										if vim.api.nvim_buf_is_valid(b) and vim.api.nvim_buf_get_option(b, 'filetype') == 'neo-tree' then
											vim.api.nvim_win_close(w, true)
										end
									end
								end
								return
							end
						end
					end
				end
			end
			-- Reuse empty buffer in current tab
			local wins = vim.api.nvim_tabpage_list_wins(0)
			local empty_buf = nil
			for _, win in ipairs(wins) do
				if vim.api.nvim_win_is_valid(win) then
					local buf = vim.api.nvim_win_get_buf(win)
					if vim.api.nvim_buf_is_valid(buf) then
						local bufname = vim.api.nvim_buf_get_name(buf)
						local buftype = vim.api.nvim_buf_get_option(buf, 'buftype')
						local modified = vim.api.nvim_buf_get_option(buf, 'modified')
						if bufname == '' and buftype == '' and not modified then
							empty_buf = buf
							vim.api.nvim_set_current_win(win)
							break
						end
					end
				end
			end
			if empty_buf then
				vim.cmd('edit ' .. vim.fn.fnameescape(path))
			else
				vim.cmd('tabnew ' .. vim.fn.fnameescape(path))
			end
			-- Always close Neo-tree window if open
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				if vim.api.nvim_win_is_valid(win) then
					local buf = vim.api.nvim_win_get_buf(win)
					if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, 'filetype') == 'neo-tree' then
						vim.api.nvim_win_close(win, true)
					end
				end
			end
		end
		-- Smart_open_split for split windows
		local function smart_open_split(state, direction)
			local node = state.tree:get_node()
			if not node then
				return
			end
			local path = node.path

			if node.type == 'directory' then
				state.commands.toggle_node(state, node)
				return
			end
			-- Check if file is open in another tab
			local open_tab, open_win
			for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
				for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
					local buf = vim.api.nvim_win_get_buf(win)
					if vim.api.nvim_buf_is_valid(buf) and normalize_path(vim.api.nvim_buf_get_name(buf)) == normalize_path(path) then
						open_tab = tab
						open_win = win
						break
					end
				end
				if open_tab then
					break
				end
			end
			if open_tab then
				local choice = vim.fn.confirm('File is already open in a tab. Open split here anyway?', '&Yes\n&No', 2)
				if choice ~= 1 then
					-- User chose No → jump to the tab where file is open
					vim.api.nvim_set_current_tabpage(open_tab)
					vim.api.nvim_set_current_win(open_win)
					return
				end
				-- Else user chose Yes → continue to open split in current tab
			end
			-- Open split in current tab
			if direction == 'v' then
				state.commands.open_vsplit(state)
				vim.schedule(function()
					vim.cmd 'wincmd L'
				end)
			else
				state.commands.open_split(state)
				vim.schedule(function()
					vim.cmd 'wincmd J'
				end)
			end

			vim.cmd('edit ' .. vim.fn.fnameescape(path))
		end
		require('neo-tree').setup {
			close_if_last_window = true,
			popup_border_style = 'rounded',
			enable_git_status = true,
			enable_diagnostics = true,
			default_component_configs = {
				indent = { padding = 1, indent_size = 2 },
				icon = { folder_closed = '', folder_open = '', folder_empty = 'ﰊ' },
			},
			window = {
				position = 'float',
				width = 40,
				mapping_options = { noremap = true, nowait = true },
				mappings = {
					['<cr>'] = smart_open,
					['v'] = function(state)
						smart_open_split(state, 'h')
					end,
					['h'] = function(state)
						smart_open_split(state, 'v')
					end,
					['t'] = 'noop',
					['d'] = delete_file_mark_removed,
					['a'] = function(state)
						-- Get the current node
						local node = state.tree:get_node()
						local root
						-- If on a directory, expand it immediately before prompting
						if node and node.type == 'directory' then
							root = node.path
							if not node:is_expanded() then
								state.commands.toggle_node(state, node)
								vim.cmd 'redraw' -- ensure UI updates before input
							end
						elseif node then
							root = vim.fn.fnamemodify(node.path, ':h')
						else
							root = vim.loop.cwd()
						end
						-- Small delay before input to allow UI to redraw
						vim.defer_fn(function()
							local input = vim.fn.input 'New file/folder name (use / at end for folder): '
							if input == '' then
								return
							end
							local new_path = normalize_path(root .. '/' .. input)
							local is_folder = vim.endswith(input, '/') or vim.endswith(input, '\\')
							if is_folder then
								vim.fn.mkdir(new_path, 'p')
							else
								vim.fn.mkdir(vim.fn.fnamemodify(new_path, ':h'), 'p')
								local f = io.open(new_path, 'w')
								if f then
									f:close()
								end
							end
							last_created_path = new_path
							-- Refresh the tree to show the new item
							state.commands.refresh(state)
							-- Expand folder if folder was created
							if is_folder then
								vim.defer_fn(function()
									for _, n in pairs(state.tree.nodes) do
										if normalize_path(n.path) == last_created_path then
											state.commands.toggle_node(state, n)
											break
										end
									end
								end, 20)
							end
						end, 40)
					end,
				},
			},
			filesystem = {
				follow_current_file = {
					enabled = true, -- updated to table format
				},
				use_libuv_file_watcher = true,
				hijack_netrw_behavior = 'open_default',
				filtered_items = {
					visible = true,
					hide_dotfiles = false,
					hide_gitignored = true,
				},
				components = {
					-- Highlight last created file or folder in green
					name = function(config, node)
						local node_path = normalize_path(node.path)
						local hl = nil
						if last_created_path and node_path == last_created_path then
							hl = 'NeoTreeLastCreated'
						end
						return { text = node.name, highlight = hl }
					end,
				},
			},
		}
	end,
}
