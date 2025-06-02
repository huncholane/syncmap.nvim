local M = {
	opts = require("syncmap.default"),
}
local state = require("syncmap.state")

function M.setup()
	vim.api.nvim_create_user_command(
		"SyncmapRestart",
		state.restart,
		{ desc = "Clears everything and starts all the inotify servers again" }
	)
	vim.api.nvim_create_user_command(
		"SyncmapStop",
		state.clear,
		{ desc = "Clears the active map and all of it's processes" }
	)
	vim.api.nvim_create_user_command(
		"SyncmapActive",
		state.show_active,
		{ desc = "Shows currently active inotify servers" }
	)
	vim.api.nvim_create_user_command(
		"SyncmapOpts",
		state.show_opts,
		{ desc = "Shows the current settings for Syncmap" }
	)
end

return M
