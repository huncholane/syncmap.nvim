local M = {}
M.state = require("syncmap.state")
M.rsync = require("syncmap.rsync")
M.utils = require("syncmap.utils")
M.default = require("syncmap.default")
M.log = require("syncmap.log")
M.commands = require("syncmap.commands")

M.opts = M.default

---Setup the sync map plugin
---@param opts SyncmapOpts
function M.setup(opts)
	M.opts = vim.tbl_deep_extend("force", {}, M.default, opts or {})
	M.utils.opts = M.opts
	M.state.opts = M.opts
	M.rsync.opts = M.opts
	M.log.opts = M.opts
	M.commands.opts = M.opts
	M.commands.setup()
	vim.api.nvim_create_autocmd("User", {
		pattern = "VeryLazy",
		callback = M.state.sync,
	})
end

return M
