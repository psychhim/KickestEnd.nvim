local M = {}

function M.trim_clipboard()
  local content = vim.fn.getreg '+'
  -- Remove single trailing newline if present
  content = content:gsub('\n$', '')
  vim.fn.setreg('+', content)
  vim.fn.setreg('*', content)
  vim.notify('Copied to clipboard', vim.log.levels.INFO)
end

return M
