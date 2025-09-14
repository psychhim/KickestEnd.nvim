-- Unless you are still migrating, remove the deprecated commands from v1.x
vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

return {
  "nvim-neo-tree/neo-tree.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
  },
  config = function()
  
  -- smart_open function: If there's an empty "No Name" buffer, replace it and open files in the same tab
local function smart_open(state)
	local node = state.tree:get_node()
	if not node then return end
	local path = node:get_id()

	-- Get the window in the current tab that is NOT Neo-tree
	local wins = vim.api.nvim_tabpage_list_wins(0)
	local target_buf = nil
	for _, win in ipairs(wins) do
		local buf = vim.api.nvim_win_get_buf(win)
		local bufname = vim.api.nvim_buf_get_name(buf)
		local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
		local modified = vim.api.nvim_buf_get_option(buf, "modified")
		-- find a window with empty, unmodified buffer
		if bufname == "" and buftype == "" and not modified then
			   target_buf = buf
			   vim.api.nvim_set_current_win(win)
			   break
		end
	end

	if target_buf then
		-- replace the empty buffer
		vim.cmd("edit " .. path)
	else
		-- otherwise open in new tab
		require("neo-tree.sources.filesystem.commands").open_tabnew(state)
	end
end

    require('neo-tree').setup {
    -- Open Neo-tree in a floating window in middle at first launch when Neovim is opened inside a directory with "nvim ."
    	close_if_last_window = true, -- close Neo-tree if it's the last window
  	popup_border_style = "rounded",
	enable_git_status = true,
	enable_diagnostics = true,
	default_component_configs = {
	  indent = {
	    padding = 1,
	    indent_size = 2,
	  },
    	  icon = {
		folder_closed = "",
	        folder_open = "",
	        folder_empty = "ﰊ",
    	  },
  	},
    	window = {
    	  position = "float",  -- this makes Neo-tree open in the middle
          width = 40,
          mapping_options = {
           noremap = true,
           nowait = true,
          },
	  mappings = {
	   ["<cr>"] = smart_open, -- Enter → always open file in new tab if there's no empty buffer
	   ["t"]    = "noop",        -- disable t
	  },
	},
        filesystem = {
	  follow_current_file = true,
	  use_libuv_file_watcher = true,
	  hijack_netrw_behavior = "open_default",
          filtered_items = {
          visible = true, -- This is what you want: If you set this to `true`, all "hide" just mean "dimmed out"
          hide_dotfiles = false,
          hide_gitignored = true,
          },
        }, 
      }
  end,
}
