return {
	'mbbill/undotree',
	keys = {
		{ '<leader>u', vim.cmd.UndotreeToggle, desc = 'Toggle UndoTree' },
	},
	config = function()
		-- Optional settings
		vim.g.undotree_WindowLayout = 2 -- vertical split
		vim.g.undotree_SplitWidth = 30 -- width of undo tree window
		vim.g.undotree_SetFocusWhenToggle = 1
		vim.g.undotree_EnableDiff = 1
	end,
}
