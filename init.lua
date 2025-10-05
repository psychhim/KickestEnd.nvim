vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure plugins ]]
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.

-- Disables which-key healthcheck notifications
do
  local orig_notify = vim.notify
  vim.notify = function(msg, ...)
    if type(msg) == 'string' and msg:match 'which%-key' then
      return -- ignore WhichKey health messages
    end
    return orig_notify(msg, ...)
  end
end

require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration
  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Conform
      {
        'stevearc/conform.nvim',
        opts = {
          formatters_by_ft = {
            lua = { 'stylua' },
            python = { 'isort', 'yapf' },
            javascript = {
              'prettierd',
            },
            typescript = {
              'prettierd',
            },
            css = {
              'prettierd',
            },
            html = {
              'prettierd',
            },
            json = {
              'prettierd',
            },
            c = {
              'clang-format',
            },
            cpp = {
              'clang-format',
            },
            bash = { 'shfmt' },
            rust = { 'rustfmt' },
          },
          format_on_save = {
            timeout_ms = 500,
            lsp_format = 'fallback',
          },
        },
      },

      -- Install formatters automatically
      {
        'zapling/mason-conform.nvim',
        dependencies = { 'williamboman/mason.nvim', 'stevearc/conform.nvim' },
        config = function()
          require('mason-conform').setup {
            ensure_installed = true, -- auto-install all formatters listed in Conform
          }
        end,
      },
      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },
  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      dependencies = { 'rafamadriz/friendly-snippets' },
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',

      -- Adds a number of user-friendly snippets

      'rafamadriz/friendly-snippets',
    },
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim',  opts = {} },
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to next hunk' })

        map({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to previous hunk' })

        -- Actions
        -- visual mode
        map('v', '<leader>hs', function()
          gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'stage git hunk' })
        map('v', '<leader>hr', function()
          gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'reset git hunk' })
        -- normal mode
        map('n', '<leader>hs', gs.stage_hunk, { desc = 'git stage hunk' })
        map('n', '<leader>hr', gs.reset_hunk, { desc = 'git reset hunk' })
        map('n', '<leader>hS', gs.stage_buffer, { desc = 'git Stage buffer' })
        map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
        map('n', '<leader>hR', gs.reset_buffer, { desc = 'git Reset buffer' })
        map('n', '<leader>hp', gs.preview_hunk, { desc = 'preview git hunk' })
        map('n', '<leader>hb', function()
          gs.blame_line { full = false }
        end, { desc = 'git blame line' })
        map('n', '<leader>hd', gs.diffthis, { desc = 'git diff against index' })
        map('n', '<leader>hD', function()
          gs.diffthis '~'
        end, { desc = 'git diff against last commit' })

        -- Toggles
        map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
        map('n', '<leader>td', gs.toggle_deleted, { desc = 'toggle git show deleted' })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
      end,
    },
  },
  {
    --kanagawa colorscheme
    'rebelot/kanagawa.nvim',
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = true,
        component_separators = '|',
        section_separators = '',
      },
    },
  },
  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },
  { --Autopairs
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = true,
    -- use opts = {} for passing setup options
    -- this is equalent to setup({}) function
  },
  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  require 'kickstart.plugins.autoformat',
  --require 'kickstart.plugins.debug'

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  { import = 'custom.plugins' },
}, {})

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = ''

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
-- vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- Tabs and indentation
vim.o.expandtab = false  -- use spaces instead of tabs
vim.o.shiftwidth = 4     -- number of spaces for autoindent
vim.o.softtabstop = 0    -- number of spaces per Tab in insert mode
vim.o.tabstop = 4        -- number of spaces a Tab counts for
vim.o.smartindent = true -- auto-indent new lines

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
  vim.cmd 'enew'   -- create a new empty buffer in it
end, { noremap = true, silent = true })

-- Horizontal split with new empty buffer below
vim.keymap.set('n', '<leader>sv', function()
  vim.cmd 'split'    -- create horizontal split (above by default)
  vim.cmd 'wincmd j' -- move to the new split below
  vim.cmd 'enew'     -- open new empty buffer
end, { desc = 'New buffer in horizontal split (below)' })

-- Vertical split with new empty buffer to the right
vim.keymap.set('n', '<leader>sh', function()
  vim.cmd 'vsplit'   -- create vertical split (left by default)
  vim.cmd 'wincmd l' -- move to the new split to the right
  vim.cmd 'enew'     -- open new empty buffer
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
vim.keymap.set('n', '<leader>p', '"+p')

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

-- Map to <leader><leader>
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

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- smart_open function for Telescope to check if the current tab has an empty "No Name" buffer. If it has, it replaces the empty buffer and open a file in the same tab
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'

local function smart_open(prompt_bufnr)
  local entry = action_state.get_selected_entry()
  if not entry then
    return
  end

  local path = entry.path or entry.filename
  if not path then
    return
  end

  if prompt_bufnr and vim.api.nvim_buf_is_valid(prompt_bufnr) then
    pcall(actions.close, prompt_bufnr)
  end

  -- 1. If file is already open → jump to it
  local tabpages = vim.api.nvim_list_tabpages()
  for _, tab in ipairs(tabpages) do
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.api.nvim_buf_get_name(buf) == path then
        vim.api.nvim_set_current_tabpage(tab) -- jump to tab
        vim.api.nvim_set_current_win(win)     -- jump to window
        return
      end
    end
  end

  -- 2. If current tab has an empty "No Name" buffer → reuse it
  local wins = vim.api.nvim_tabpage_list_wins(0)
  for _, win in ipairs(wins) do
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
  vim.cmd('tabnew ' .. vim.fn.fnameescape(path))
end

-- Split option in Telescope file picker with smart_open
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'

local function smart_open_split(prompt_bufnr, split_type)
  local entry = action_state.get_selected_entry()
  if not entry then
    return
  end

  local path = entry.path or entry.filename
  if not path then
    return
  end

  if prompt_bufnr and vim.api.nvim_buf_is_valid(prompt_bufnr) then
    pcall(actions.close, prompt_bufnr)
  end

  -- Check if file is already open
  local open_tab, open_win
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.api.nvim_buf_get_name(buf) == path then
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

  -- Open in split
  if split_type == 'v' then
    -- horizontal → always below
    vim.cmd('belowright split ' .. vim.fn.fnameescape(path))
  elseif split_type == 'h' then
    -- vertical → always right
    vim.cmd('vertical rightbelow split ' .. vim.fn.fnameescape(path))
  end
end

-- Telescope keymap using Smart Open
vim.keymap.set('n', '<leader>sf', function()
  require('telescope.builtin').find_files {
    attach_mappings = function(_, map)
      map('i', '<CR>', function(prompt_bufnr)
        smart_open(prompt_bufnr)
      end)
      map('n', '<CR>', function(prompt_bufnr)
        smart_open(prompt_bufnr)
      end)
      -- Horizontal split with 'h'
      map('n', 'h', function(prompt_bufnr)
        smart_open_split(prompt_bufnr, 'h')
      end)
      -- Vertical split with 'v'
      map('n', 'v', function(prompt_bufnr)
        smart_open_split(prompt_bufnr, 'v')
      end)
      return true
    end,
  }
end, { desc = '[S]earch [F]iles (Smart Open)' })

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == '' then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    print 'Not a git repository. Searching on current working directory'
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep {
      search_dirs = { git_root },
    }
  end
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

local function telescope_live_grep_open_files()
  require('telescope.builtin').live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end
vim.keymap.set('n', '<leader>s/', telescope_live_grep_open_files, { desc = '[S]earch [/] in Open Files' })
vim.keymap.set('n', '<leader>ss', require('telescope.builtin').builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>gf', function()
  local is_git_dir = vim.fn.system('git rev-parse --is-inside-work-tree'):gsub('%s+', '') == 'true'
  if not is_git_dir then
    vim.notify('Not a git repository', vim.log.levels.WARN, { title = 'Telescope Git Files' })
    return
  end

  require('telescope.builtin').git_files {
    attach_mappings = function(_, map)
      local actions = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'

      local function open_smart(prompt_bufnr)
        local entry = action_state.get_selected_entry()
        if not entry then
          return
        end
        pcall(actions.close, prompt_bufnr)
        smart_open(prompt_bufnr)
      end

      map('i', '<CR>', open_smart)
      map('n', '<CR>', open_smart)
      return true
    end,
  }
end, { desc = 'Search [G]it [F]iles (Smart Open)' })
vim.keymap.set('n', '<leader>si', require('telescope.builtin').help_tags, { desc = '[S]earch [I]nfo' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash' },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,

    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<c-space>',
        node_incremental = '<c-space>',
        scope_incremental = '<c-s>',
        node_decremental = '<M-space>',
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = '@function.outer',
          [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['<leader>a'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>A'] = '@parameter.inner',
        },
      },
    },
  }
end, 0)

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the buffer using Conform
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function()
    require('conform').format { bufnr = bufnr }
  end, { desc = 'Format current buffer with Conform' })
end

-- document existing key chains
require('which-key').register {
  ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
  ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
  ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
  ['<leader>h'] = { name = 'Git [H]unk', _ = 'which_key_ignore' },
  ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
  ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
  ['<leader>t'] = { name = '[T]oggle', _ = 'which_key_ignore' },
  ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
}
-- register which-key VISUAL mode
-- required for visual <leader>hs (hunk stage) to work
require('which-key').register({
  ['<leader>'] = { name = 'VISUAL <leader>' },
  ['<leader>h'] = { 'Git [H]unk' },
}, { mode = 'v' })

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  -- tsserver = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
      -- diagnostics = { disable = { 'missing-fields' } },
    },
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup {
        capabilities = capabilities,
        on_attach = on_attach,
        settings = servers[server_name],
        filetypes = (servers[server_name] or {}).filetypes,
      }
    end,
  },
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
--require("luasnip.loaders.from_vscode").lazy_load()
--require('luasnip.loaders.from_vscode').lazy_load({ paths = { "~/.config/nvim/my_snippets" } })
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
  },
}
--Load Luasnip.loaders
require('luasnip.loaders.from_vscode').lazy_load()

-- Theme
require('kanagawa').setup { transparent = true }
vim.cmd [[colorscheme kanagawa]]

-- Custom native-looking tabline that matches Kanagawa theme
vim.o.showtabline = 1
_G.tab_offset = 1
local max_visible_tabs = 8 -- maximum number of tabs visible at once

function _G.Tabline()
  local current_tab = vim.fn.tabpagenr()
  local tab_count = vim.fn.tabpagenr '$'
  local win_width = vim.o.columns
  local tab_width = math.floor(win_width / max_visible_tabs) -- FIXED width

  local tabs = {}
  for i = 1, tab_count do
    local buflist = vim.fn.tabpagebuflist(i)
    local winnr = vim.fn.tabpagewinnr(i)
    local bufname = vim.fn.bufname(buflist[winnr])
    if bufname == '' then
      bufname = '[No Name]'
    end
    local modified = vim.fn.getbufvar(buflist[winnr], '&mod') == 1 and ' ●' or ''
    local label = i .. ': ' .. vim.fn.fnamemodify(bufname, ':t') .. modified

    -- truncate/pad to fixed tab_width
    if #label > tab_width - 2 then
      label = label:sub(1, tab_width - 3) .. '…'
    end
    label = label .. string.rep(' ', tab_width - #label)

    tabs[i] = (i == current_tab and '%#TabLineSel#' or '%#TabLine#') .. label
  end

  -- scrolling logic to keep active tab visible
  local start_index = _G.tab_offset
  if current_tab < start_index then
    start_index = current_tab
  elseif current_tab >= start_index + max_visible_tabs then
    start_index = current_tab - max_visible_tabs + 1
  end
  _G.tab_offset = start_index

  -- select visible tabs
  local visible_tabs = {}
  for i = start_index, math.min(start_index + max_visible_tabs - 1, tab_count) do
    table.insert(visible_tabs, tabs[i])
  end

  -- scrolling arrows
  local left_arrow = start_index > 1 and '< ' or '  '
  local right_arrow = start_index + max_visible_tabs - 1 < tab_count and ' >' or '  '

  return '%#TabLine#' .. left_arrow .. table.concat(visible_tabs, '') .. right_arrow .. '%#TabLineFill#'
end

vim.o.tabline = '%!v:lua.Tabline()'

-- adjust offset if tabs are closed
vim.api.nvim_create_autocmd({ 'TabClosed' }, {
  callback = function()
    local tab_count = vim.fn.tabpagenr '$'
    if _G.tab_offset > tab_count then
      _G.tab_offset = math.max(tab_count - max_visible_tabs + 1, 1)
    end
  end,
})

-- Auto-create config files for formatters (cross-platform)
local uv = vim.loop
local home = uv.os_homedir()
local os_name = uv.os_uname().sysname
local appdata = os.getenv 'APPDATA' or (home .. '/AppData/Roaming')

-- List of formatter configs
local formatters = {
  {
    name = 'clang-format',
    path = (os_name:match 'Windows' and home .. '\\.clang-format' or home .. '/.clang-format'),
    content = [[
BasedOnStyle: LLVM
IndentWidth: 4
TabWidth: 4
UseTab: Always
]],
  },
  {
    name = 'prettier',
    path = (os_name:match 'Windows' and appdata .. '\\Prettier\\.prettierrc' or home .. '/.prettierrc'),
    content = [[
{
  "tabWidth": 4,
  "useTabs": true,
  "semi": true,
  "singleQuote": true,
  "trailingComma": "es5",
  "printWidth": 100
}
]],
  },
  {
    name = 'yapf',
    path = (os_name:match 'Windows' and home .. '\\.style.yapf' or home .. '/.style.yapf'),
    content = [[
[style]
based_on_style = pep8
indent_width = 4
use_tabs = True
]],
  },
  {
    name = 'isort',
    path = (os_name:match 'Windows' and home .. '\\.isort.cfg' or home .. '/.isort.cfg'),
    content = [[
[settings]
profile = black
force_single_line = true
]],
  },
}

-- Helper to create file if it doesn't exist
local function ensure_file(path, content)
  if not path then
    print 'Invalid path, skipping file creation'
    return
  end

  local stat = uv.fs_stat(path)
  if not stat then
    -- Make parent directory if needed
    local dir = vim.fn.fnamemodify(path, ':h')
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, 'p') -- recursively create directories
      print('Created directory: ' .. dir)
    end

    -- Write the file
    local fd = uv.fs_open(path, 'w', 420) -- 0644
    if fd then
      uv.fs_write(fd, content, -1)
      uv.fs_close(fd)
      print('Created file: ' .. path)
    else
      print('Failed to create file: ' .. path)
    end
  end
end

-- Loop through all formatter configs
for _, fmt in ipairs(formatters) do
  ensure_file(fmt.path, fmt.content)
end

-- Auto-clear messages on most user actions
local clear_msg_grp = vim.api.nvim_create_augroup('AutoClearMessages', { clear = true })

vim.api.nvim_create_autocmd(
{ 'CursorMoved', 'CursorMovedI', 'InsertEnter', 'InsertLeave', 'TextChanged', 'TextChangedI' }, {
  group = clear_msg_grp,
  callback = function()
    vim.cmd 'echo ""' -- Clear the message/command line
  end,
})

-- Auto-clear messages on pressing ESC
vim.keymap.set('n', '<Esc>', '<Esc><Cmd>echo ""<CR>', { noremap = true, silent = true })
vim.keymap.set('v', '<Esc>', '<Esc><Cmd>echo ""<CR>', { noremap = true, silent = true })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
