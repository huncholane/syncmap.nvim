local M = {
	opts = require("syncmap.default"),
}
local state = require("syncmap.state")

function M.setup()
	vim.api.nvim_create_user_command("SyncmapRestart", state.restart, {})
	vim.api.nvim_create_user_command("SyncmapStop", state.clear, {})
end

return M
