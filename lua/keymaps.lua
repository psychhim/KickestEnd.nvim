-- [[ Few useful keymaps ]]
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")
vim.keymap.set('n', 'J', 'mzJ`z')
vim.keymap.set('n', '<leader>j', '<C-d>zz', { desc = 'Scroll down and center cursor' })
vim.keymap.set('n', '<leader>k', '<C-u>zz', { desc = 'Scroll up and center cursor' })
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- [[ Replace all occurrences of the word under cursor ]]
vim.keymap.set('n', '<leader>F', function()
	-- Save current cursor position
	local pos = vim.api.nvim_win_get_cursor(0)
	-- Get the word under the cursor
	local word = vim.fn.expand '<cword>'
	-- Ask user for the replacement
	local replacement = vim.fn.input("Replace '" .. word .. "' with: ")
	-- If user typed something, do the substitution
	if replacement ~= '' then
		-- %%s/.../.../gI = substitute globally, case-insensitive
		vim.cmd(string.format('%%s/\\<%s\\>/%s/gI', word, replacement))
	end
	-- Restore cursor position
	vim.api.nvim_win_set_cursor(0, pos)
end, { desc = 'Replace all occurrences of word under cursor' })

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

-- [[ Paste from clipboard with line count ]]
local function paste_from_clipboard()
	-- Get clipboard lines
	local lines = vim.fn.getreg('+', 1, true)
	if vim.tbl_isempty(lines) then
		return
	end
	local line_count = #lines
	local mode = vim.fn.mode()
	if mode == 'v' or mode == 'V' or mode == '\22' then
		-- Visual mode: replace selection with clipboard
		local start_line = vim.fn.line 'v'
		local start_col = vim.fn.col 'v'
		local end_line = vim.fn.line '.'
		local end_col = vim.fn.col '.'
		if start_line > end_line or (start_line == end_line and start_col > end_col) then
			start_line, end_line = end_line, start_line
			start_col, end_col = end_col, start_col
		end
		-- Determine register type
		local reg_type
		if #lines > 1 or (end_line - start_line + 1) > 1 then
			reg_type = 'l' -- linewise
		else
			reg_type = 'c' -- characterwise
		end
		vim.fn.setreg('"', vim.fn.getreg '+', reg_type)
		-- Delete selection into blackhole and paste from unnamed (clipboard)
		vim.cmd 'normal! "_dP'
		-- Move cursor to end of pasted text
		local buf = vim.api.nvim_get_current_buf()
		local last_line = start_line + #lines - 1
		local last_col
		if reg_type == 'l' then
			local line_content = vim.api.nvim_buf_get_lines(buf, last_line - 1, last_line, false)[1]
			last_col = #line_content
		else
			local first_line = vim.api.nvim_buf_get_lines(buf, start_line - 1, start_line, false)[1]
			last_col = start_col - 1 + #lines[1]
		end
		vim.api.nvim_win_set_cursor(0, { last_line, last_col })
		-- Exit visual mode
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)
	else
		-- Normal mode: paste before cursor
		vim.api.nvim_put(lines, 'c', false, true)
	end
	-- Notify line count
	vim.defer_fn(function()
		local plural = line_count > 1 and 's' or ''
		vim.notify(line_count .. ' line' .. plural .. ' pasted from clipboard', vim.log.levels.INFO)
	end, 0)
end
vim.keymap.set('n', '<leader>P', paste_from_clipboard, { desc = 'Paste from clipboard before cursor' })
vim.keymap.set('x', '<leader>P', paste_from_clipboard, { desc = 'Paste clipboard over selection' })

-- [[ Paste Neovim yanks ]]
-- In Normal Mode before cursor inline
vim.keymap.set('n', '<leader>p', function()
	local lines = vim.fn.getreg('"', 1, true) -- get as list of lines
	if vim.tbl_isempty(lines) then
		return
	end
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	row = row - 1 -- Lua index is 0-based
	local current_line = vim.api.nvim_get_current_line()
	if #lines == 1 then
		-- Single-line paste (inline)
		local new_line = current_line:sub(1, col) .. lines[1] .. current_line:sub(col + 1)
		vim.api.nvim_set_current_line(new_line)
		vim.api.nvim_win_set_cursor(0, { row + 1, col + #lines[1] })
	else
		-- Multi-line paste
		local before = current_line:sub(1, col)
		local after = current_line:sub(col + 1)
		local to_insert = vim.deepcopy(lines)
		to_insert[1] = before .. to_insert[1]
		to_insert[#to_insert] = to_insert[#to_insert] .. after
		vim.api.nvim_buf_set_lines(0, row, row + 1, false, to_insert)
		vim.api.nvim_win_set_cursor(0, { row + #to_insert, #to_insert[#to_insert] - #after })
	end
end, { desc = 'Paste before cursor inline' })
-- In Visual Mode, paste over selection without yanking
vim.keymap.set('x', '<leader>p', function()
	-- Force the unnamed register to characterwise
	local reg = vim.fn.getreg('"', 1, true) -- get list of lines
	vim.fn.setreg('"', table.concat(reg, '\n'), 'c') -- set as charwise

	vim.cmd 'normal! "_dP' -- paste over selection
	vim.cmd 'normal! `]' -- move to end of pasted text
end, { desc = 'Paste over selection without yanking' })

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

-- [[ Function to exit insert/visual/command/terminal modes ]]
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
