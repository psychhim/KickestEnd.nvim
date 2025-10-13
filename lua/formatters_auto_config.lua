-- Auto-create config files for formatters (cross-platform)

local M = {}
local uv = vim.loop

-- Determine OS paths
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

-- Helper function to create a file if it doesn't exist
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

-- Function to run the auto-creation for all formatters
function M.setup()
	for _, fmt in ipairs(formatters) do
		ensure_file(fmt.path, fmt.content)
	end
end

return M
