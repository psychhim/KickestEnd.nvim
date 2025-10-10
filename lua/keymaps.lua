-- [[ Few useful keymaps ]]
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")
vim.keymap.set('n', 'J', 'mzJ`z')
vim.keymap.set('n', '<leader>j', '<C-d>zz', { desc = 'Scroll down and center cursor' })
vim.keymap.set('n', '<leader>k', '<C-u>zz', { desc = 'Scroll up and center cursor' })
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- [[ Replace all occurrences of word under cursor (normal) or selection (visual) ]]
-- Normal mode
vim.keymap.set('n', '<leader>F', function()
	-- Get word under cursor
	local word = vim.fn.expand '<cword>'
	if word == '' then
		return
	end
	-- Escape for literal search
	local esc_word = vim.fn.escape(word, '/\\')
	-- Count occurrences in the buffer (case-insensitive)
	local occurrences = vim.fn.searchcount({ pattern = '\\<' .. esc_word .. '\\>', maxcount = 0, exact = 1 }).total
	-- Prompt with only the count
	local replacement = vim.fn.input(string.format('Replace %d occurrences with: ', occurrences))
	if replacement == '' then
		return
	end
	-- Escape replacement
	local esc_replacement = vim.fn.escape(replacement, '\\/&')
	-- Save cursor position before substitution
	local original_pos = vim.api.nvim_win_get_cursor(0)
	-- Perform global, case-insensitive substitution
	vim.cmd(string.format('silent! %%s/\\<%s\\>/%s/gI', esc_word, esc_replacement))
	-- Move cursor at the last character of the first replaced occurrence
	vim.schedule(function()
		local pattern = '\\<' .. esc_word .. '\\>'
		vim.fn.cursor(original_pos)
		vim.cmd 'silent! normal! n'
		local row, col = unpack(vim.api.nvim_win_get_cursor(0))
		pcall(vim.api.nvim_win_set_cursor, 0, { row, col + #replacement + 1 })
	end)
end, { desc = 'Replace all occurrences of word under cursor', silent = true })
-- Visual mode
vim.keymap.set('x', '<leader>F', function()
	-- Exit visual mode so input() works
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'nx', false)
	vim.schedule(function()
		local mode = vim.fn.visualmode()
		local start_pos = vim.api.nvim_buf_get_mark(0, '<')
		local end_pos = vim.api.nvim_buf_get_mark(0, '>')
		local start_row, start_col = start_pos[1] - 1, start_pos[2]
		local end_row, end_col = end_pos[1] - 1, end_pos[2] + 1
		if mode == 'V' then
			start_col = 0
			local line = vim.api.nvim_buf_get_lines(0, end_row, end_row + 1, false)[1] or ''
			end_col = #line
		end
		local lines = vim.api.nvim_buf_get_text(0, start_row, start_col, end_row, end_col, {})
		if not lines or #lines == 0 then
			return
		end
		local selection = table.concat(lines, '\n')
		if selection == '' then
			return
		end
		-- Escape selection for literal search
		local esc_selection = vim.fn.escape(selection, '/\\'):gsub('\n', '\\n')
		-- Count occurrences in the buffer
		local count = vim.fn.searchcount({ pattern = esc_selection, maxcount = 0, exact = 1 }).total
		-- Show prompt with only number of occurrences
		local replacement = vim.fn.input(string.format('Replace %d occurrences with: ', count))
		if replacement == '' then
			return
		end
		local esc_replacement = vim.fn.escape(replacement, '\\/&'):gsub('\n', '\\n')
		local original_pos = { start_row + 1, start_col + 1 }
		-- Silent global substitution
		vim.cmd(string.format('silent! %%s/\\V%s/%s/g', esc_selection, esc_replacement))
		-- Move cursor at the last character of the first replaced occurrence
		vim.schedule(function()
			vim.fn.cursor(original_pos)
			vim.cmd 'silent! normal! n'
			local found_row, found_col = unpack(vim.api.nvim_win_get_cursor(0))
			-- +1 to put cursor after the last character of replacement
			pcall(vim.api.nvim_win_set_cursor, 0, { found_row, found_col + #replacement })
		end)
	end)
end, { desc = 'Replace all occurrences of selection', silent = true })

-- [[ Basic Keymaps ]]
-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- [[ Remap for dealing with word wrap ]]
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Diagnostic keymaps ]]
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, { desc = 'Diagnostics: floating message' })
vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Diagnostics: location list' })

-- [[ Custom keymaps ]]
-- [[ Neo-tree sync to current directory & toggle ]]
vim.keymap.set('n', '<leader>n', '<Cmd>cd %:p:h | Neotree toggle float<CR>')

-- [[ Terminal open in new tab ]]
vim.keymap.set('n', '<leader>t', '<Cmd>tabnew +term<CR>i')

-- [[ Create an empty buffer in a new tab ]]
vim.keymap.set('n', '<Leader>e', function()
	vim.cmd 'tabnew' -- create a new tab
	vim.cmd 'enew' -- create a new empty buffer in it
end, { noremap = true, silent = true, desc = 'Create an empty buffer' })

-- [[ Horizontal split with new empty buffer below ]]
vim.keymap.set('n', '<leader>sv', function()
	vim.cmd 'split' -- create horizontal split (above by default)
	vim.cmd 'wincmd j' -- move to the new split below
	vim.cmd 'enew' -- open new empty buffer
end, { desc = 'New buffer in horizontal split (below)' })

-- [[ Vertical split with new empty buffer to the right ]]
vim.keymap.set('n', '<leader>sh', function()
	vim.cmd 'vsplit' -- create vertical split (left by default)
	vim.cmd 'wincmd l' -- move to the new split to the right
	vim.cmd 'enew' -- open new empty buffer
end, { desc = 'New buffer in vertical split (right)' })

-- [[ Save current buffer (asks for filename if new/unsaved) ]]
vim.keymap.set('n', '<leader>w', function()
	if vim.api.nvim_buf_get_name(0) == '' then
		-- Ask user for a filename
		local filename = vim.fn.input('Save as: ', '', 'file')
		if filename ~= '' then
			vim.cmd('saveas ' .. vim.fn.fnameescape(filename))
		else
			print 'Save cancelled'
		end
	else
		vim.cmd 'w'
	end
end, { desc = 'Save buffer (prompt if new file)' })

-- [[ Close current window (asks if buffer is unsaved) ]]
vim.keymap.set('n', '<leader>q', function()
	if vim.bo.modified then
		local choice = vim.fn.input 'Buffer modified! Save (y), Discard (n), Cancel (any other key)? '
		if choice:lower() == 'y' then
			if vim.api.nvim_buf_get_name(0) == '' then
				local filename = vim.fn.input('Save as: ', '', 'file')
				if filename ~= '' then
					vim.cmd('saveas ' .. vim.fn.fnameescape(filename))
					vim.cmd 'q'
				else
					print 'Save cancelled'
				end
			else
				vim.cmd 'wq'
			end
		elseif choice:lower() == 'n' then
			vim.cmd 'q!'
		else
			print 'Quit cancelled'
		end
	else
		vim.cmd 'q'
	end
end, { desc = 'Close buffer (prompt if modified)' })

-- [[ Save changes and close current window (asks for filename if new/unsaved) ]]
vim.keymap.set('n', '<leader>qy', function()
	if vim.api.nvim_buf_get_name(0) == '' then
		-- Ask user for a filename
		local filename = vim.fn.input('Save as: ', '', 'file')
		if filename ~= '' then
			vim.cmd('saveas ' .. vim.fn.fnameescape(filename))
			vim.cmd 'q'
		else
			print 'Save cancelled'
		end
	else
		vim.cmd 'wq'
	end
end, { desc = 'Save & quit (prompt if new file)' })

-- [[ Discard changes and Close current window ]]
vim.keymap.set('n', '<leader>qn', '<Cmd>q!<CR>')

-- [[ Switch below/right split windows ]]
vim.keymap.set('n', '<leader><Tab>', '<C-W><C-W>')

-- [[ Switch above/left split windows ]]
vim.keymap.set('n', '<Tab>', '<C-W>W')

-- [[ Select all ]]
vim.keymap.set('n', '<leader>ll', 'ggVG', { desc = 'Select all' })

-- [[ Select all and copy to clipboard ]]
vim.keymap.set('n', '<leader>lY', function()
	-- Get all lines from the buffer
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local content = table.concat(lines, '\n')
	-- Set to system clipboard
	vim.fn.setreg('+', content)
	vim.fn.setreg('*', content)
	-- Highlight the full buffer
	local ns = vim.api.nvim_create_namespace 'custom_yank_highlight'
	local hl_group = vim.g.highlightedyank_highlight_group or 'IncSearch'
	local end_row = #lines - 1
	local end_col = #lines[#lines]
	vim.highlight.range(
		0, -- bufnr
		ns,
		hl_group,
		{ 0, 0 }, -- start at beginning
		{ end_row, end_col }, -- end at last line's end
		{ inclusive = true }
	)
	-- Clear highlight after delay
	vim.defer_fn(function()
		vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
	end, 200)
	-- Notify
	vim.schedule(function()
		vim.notify('Copied all to clipboard', vim.log.levels.INFO)
	end)
end, { desc = 'Copy all to clipboard' })

-- [[ Copy to clipboard ]]
-- Normal mode: copy current line
vim.keymap.set('n', 'Y', function()
	local line = vim.api.nvim_get_current_line()
	-- Copy to system clipboard
	vim.fn.setreg('+', line)
	vim.fn.setreg('*', line)
	-- Use user-defined highlight group or fallback to 'IncSearch'
	local hl_group = vim.g.highlightedyank_highlight_group or 'IncSearch'
	-- Highlight the line
	local ns = vim.api.nvim_create_namespace 'custom_yank_highlight'
	local row = vim.api.nvim_win_get_cursor(0)[1] - 1
	vim.highlight.range(
		0, -- bufnr
		ns, -- namespace
		hl_group, -- highlight group (dynamic)
		{ row, 0 }, -- start pos
		{ row, #line }, -- end pos
		{ inclusive = true }
	)
	-- Clear highlight after short delay
	vim.defer_fn(function()
		vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
	end, 200)
	-- Notification
	vim.schedule(function()
		vim.notify('Copied line to clipboard', vim.log.levels.INFO)
	end)
end, { desc = 'Copy current line to clipboard' })
-- Visual mode: copy selection, trim trailing newline if needed
vim.keymap.set('x', 'Y', function()
	vim.cmd 'normal! y'
	require('copy_to_clipboard_fix').trim_clipboard()
end, { noremap = true, silent = true })

-- [[ Custom inline Paste ]]
local function paste_register(regname, before_cursor, is_clipboard)
	local content_lines = vim.fn.getreg(regname, 1, true)
	if vim.tbl_isempty(content_lines) then
		return
	end
	local mode = vim.fn.mode()
	local line_count = #content_lines
	-- Visual Mode: replace selection
	if mode == 'v' or mode == 'V' or mode == '\22' then
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
		vim.schedule(function()
			local start_pos = vim.api.nvim_buf_get_mark(0, '<')
			local end_pos = vim.api.nvim_buf_get_mark(0, '>')
			local start_row, start_col = start_pos[1] - 1, start_pos[2]
			local end_row, end_col = end_pos[1] - 1, end_pos[2]
			local visual_mode = vim.fn.visualmode()
			if visual_mode == 'V' then
				start_col = 0
				local line = vim.api.nvim_buf_get_lines(0, end_row, end_row + 1, false)[1] or ''
				end_col = #line
			else
				end_col = end_col + 1
			end
			vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, content_lines)
			local last_line_text = tostring(content_lines[#content_lines] or '')
			local last_line = start_row + #content_lines - 1
			local last_col = #last_line_text
			if visual_mode == 'v' then
				pcall(vim.api.nvim_win_set_cursor, 0, { start_row + 1, start_col + #last_line_text })
			else
				pcall(vim.api.nvim_win_set_cursor, 0, { last_line + 1, last_col })
			end
		end)
	else
		-- Normal Mode
		local row, col = unpack(vim.api.nvim_win_get_cursor(0))
		row = row - 1
		local current_line = vim.api.nvim_get_current_line()
		if #content_lines == 1 then
			-- Single-line inline paste
			local insert_col = before_cursor and col or col + 1
			local new_line = current_line:sub(1, insert_col) .. content_lines[1] .. current_line:sub(insert_col + 1)
			vim.api.nvim_set_current_line(new_line)
			vim.api.nvim_win_set_cursor(0, { row + 1, insert_col + #content_lines[1] })
		else
			-- Multi-line paste
			local before = current_line:sub(1, col)
			local after = current_line:sub(col + 1)
			local to_insert = vim.deepcopy(content_lines)
			to_insert[1] = before .. to_insert[1]
			to_insert[#to_insert] = to_insert[#to_insert] .. after
			vim.api.nvim_buf_set_lines(0, row, row + 1, false, to_insert)
			vim.api.nvim_win_set_cursor(0, { row + #to_insert, #to_insert[#to_insert] - #after })
		end
	end
	-- Notify
	vim.defer_fn(function()
		local plural = line_count > 1 and 's' or ''
		local text = is_clipboard and 'pasted from clipboard' or 'pasted'
		vim.notify(line_count .. ' line' .. plural .. ' ' .. text, vim.log.levels.INFO)
	end, 0)
end
-- Keymaps
-- Clipboard
vim.keymap.set('n', '<leader>P', function()
	paste_register('+', true, true)
end, { desc = 'Paste from clipboard before cursor' })
vim.keymap.set('x', '<leader>P', function()
	paste_register('+', nil, true)
end, { desc = 'Paste clipboard over selection' })
-- Neovim yanks
vim.keymap.set('n', '<leader>p', function()
	paste_register('"', true)
end, { desc = 'Paste yanks before cursor inline' })
vim.keymap.set('x', '<leader>p', function()
	paste_register '"'
end, { desc = 'Paste yanks over selection' })

-- [[ Redo ]]
vim.keymap.set('n', 'U', '<C-r>')

-- [[ Smart open a file path, reusing empty buffers or tabs if possible ]]
local function smart_open_file(path)
	if not path or path == '' then
		return
	end
	path = vim.fn.fnamemodify(path, ':p') -- make absolute
	-- 1. If file is already open → jump to it
	for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
		for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
			local buf = vim.api.nvim_win_get_buf(win)
			if vim.api.nvim_buf_get_name(buf) == path then
				vim.api.nvim_set_current_tabpage(tab)
				vim.api.nvim_set_current_win(win)
				return
			end
		end
	end
	-- 2. If current tab has an empty "No Name" buffer → reuse it
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local buf = vim.api.nvim_win_get_buf(win)
		local name = vim.api.nvim_buf_get_name(buf)
		local buftype = vim.api.nvim_buf_get_option(buf, 'buftype')
		local modified = vim.api.nvim_buf_get_option(buf, 'modified')
		if name == '' and buftype == '' and not modified then
			vim.api.nvim_set_current_win(win)
			vim.cmd('edit ' .. vim.fn.fnameescape(path))
			return
		end
	end
	-- 3. Otherwise → open in a new tab
	vim.cmd('tabedit ' .. vim.fn.fnameescape(path))
end

-- [[ Remap gf to use smart_open_file ]]
vim.keymap.set('n', 'gf', function()
	local path = vim.fn.expand '<cfile>' -- get file under cursor
	smart_open_file(path)
end, { desc = 'Smart gf: open file under cursor in new tab or reuse buffer' })

-- [[ Remap Tab+q to exit insert/visual/command/terminal modes ]]
local function tab_q_escape()
	local mode = vim.api.nvim_get_mode().mode
	if mode:match '[iIcR]' then
		return vim.api.nvim_replace_termcodes('<Esc>', true, false, true)
	elseif mode:match '[vV\x16]' then
		return vim.api.nvim_replace_termcodes('<Esc>', true, false, true)
	elseif mode:match 't' then
		return vim.api.nvim_replace_termcodes('<C-\\><C-n>', true, false, true)
	else
		return '' -- normal mode, do nothing
	end
end
vim.keymap.set({ 'i', 'v', 't', 'n' }, '<Tab>q', tab_q_escape, { noremap = true, expr = true, silent = true })
