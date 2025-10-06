-- [[ Few useful keymaps]]
vim.keymap.set('v', 'J', ":m '<+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")
vim.keymap.set('n', 'J', 'mzJ`z')
vim.keymap.set('n', 'J', 'mzJ`z')
vim.keymap.set('n', '<leader>j', '<C-d>zz', { desc = 'Scroll down and center cursor' })
vim.keymap.set('n', '<leader>k', '<C-u>zz', { desc = 'Scroll up and center cursor' })
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')
vim.keymap.set('x', '<leader>p', '"_dP', { desc = 'Paste over selection without yanking' })

-- Replace all occurrences of the word under cursor
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

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, { desc = 'Diagnostics: floating message' })
vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Diagnostics: location list' })

-- [[ Custom keymaps ]]

-- Neo-tree sync to current directory & toggle
vim.keymap.set('n', '<leader>n', '<Cmd>cd %:p:h | Neotree toggle float<CR>')

-- Terminal open in new tab
vim.keymap.set('n', '<leader>t', '<Cmd>tabnew +term<CR>i')

-- Create an empty buffer in a new tab
vim.keymap.set('n', '<Leader>e', function()
  vim.cmd 'tabnew' -- create a new tab
  vim.cmd 'enew' -- create a new empty buffer in it
end, { noremap = true, silent = true })

-- Horizontal split with new empty buffer below
vim.keymap.set('n', '<leader>sv', function()
  vim.cmd 'split' -- create horizontal split (above by default)
  vim.cmd 'wincmd j' -- move to the new split below
  vim.cmd 'enew' -- open new empty buffer
end, { desc = 'New buffer in horizontal split (below)' })

-- Vertical split with new empty buffer to the right
vim.keymap.set('n', '<leader>sh', function()
  vim.cmd 'vsplit' -- create vertical split (left by default)
  vim.cmd 'wincmd l' -- move to the new split to the right
  vim.cmd 'enew' -- open new empty buffer
end, { desc = 'New buffer in vertical split (right)' })

-- Save current buffer (asks for filename if new/unsaved)
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

-- Close current window (asks if buffer is unsaved)
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

-- Save changes and close current window (asks for filename if new/unsaved)
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

-- Discard changes and Close current window
vim.keymap.set('n', '<leader>qn', '<Cmd>q!<CR>')

-- Switch below/right split windows
vim.keymap.set('n', '<leader><Tab>', '<C-W><C-W>')

-- Switch above/left split windows
vim.keymap.set('n', '<Tab>', '<C-W>W')

-- Select all
vim.keymap.set('n', '<leader>ll', 'ggVG')

-- Select all and copy to clipboard
vim.keymap.set('n', '<leader>lY', 'ggVG"+y')

-- Copy to clipboard a single line
vim.keymap.set('n', 'Y', '"+yy')

-- Copy to clipboard selected text in Visual mode
vim.keymap.set('v', 'Y', '"+y')

-- Paste from clipboard
vim.keymap.set('n', '<leader>P', '"+p')

-- Redo
vim.keymap.set('n', 'U', '<C-r>')

-- Smart Open current buffers for Telescope (switch to already open buffer)
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local builtin = require 'telescope.builtin'

local function smart_open_buffer()
  builtin.buffers {
    attach_mappings = function(_, map)
      local function open_selected(prompt_bufnr)
        local entry = action_state.get_selected_entry()
        if not entry then
          return
        end
        actions.close(prompt_bufnr)

        local bufname = vim.api.nvim_buf_get_name(entry.bufnr)
        if bufname == '' then
          return
        end

        -- Check all windows in current tab
        local current_tab = vim.api.nvim_get_current_tabpage()
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(current_tab)) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.api.nvim_buf_get_name(buf) == bufname then
            vim.api.nvim_set_current_win(win)
            return
          end
        end

        -- Check other tabs
        for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
          if tab ~= current_tab then
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.api.nvim_buf_get_name(buf) == bufname then
                -- Switch tab first, then window
                vim.api.nvim_set_current_tabpage(tab)
                vim.api.nvim_set_current_win(win)
                return
              end
            end
          end
        end

        -- Not open anywhere → open in current window
        vim.cmd('buffer ' .. entry.bufnr)
      end

      map('i', '<CR>', open_selected)
      map('n', '<CR>', open_selected)
      return true
    end,
  }
end
-- Map it to <leader><leader>
vim.keymap.set('n', '<leader><leader>', smart_open_buffer, { desc = 'Switch to Open Buffers' })
-- which-key, register it to show a description
require('which-key').register {
  ['<leader><leader>'] = { smart_open_buffer, 'Switch to Open Buffers' },
}

-- Smart open a file path, reusing empty buffers or tabs if possible
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

-- Remap gf to use smart_open_file
vim.keymap.set('n', 'gf', function()
  local path = vim.fn.expand '<cfile>' -- get file under cursor
  smart_open_file(path)
end, { desc = 'Smart gf: open file under cursor in new tab or reuse buffer' })
