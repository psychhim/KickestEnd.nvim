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
    local function smart_open(state)
      local node = state.tree:get_node()
      if not node then
        return
      end
      local path = node:get_id()

      -- Reuse already open buffer in any tab safely
      for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        if vim.api.nvim_tabpage_is_valid(tab) then
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
            if vim.api.nvim_win_is_valid(win) then
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_name(buf) == path then
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
          ['t'] = 'noop',
        },
      },
      filesystem = {
        follow_current_file = true,
        use_libuv_file_watcher = true,
        hijack_netrw_behavior = 'open_default',
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = true,
        },
      },
    }
  end,
}
