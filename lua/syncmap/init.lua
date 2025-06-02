local M = {}
M.state = require("syncmap.state")
M.rsync = require("syncmap.rsync")
M.utils = require("syncmap.utils")
M.default = require("syncmap.default")
M.log = require("syncmap.log")

M.opts = M.default

---Setup the sync map plugin
---@param opts SyncmapOpts
function M.setup(opts)
	M.opts = vim.tbl_deep_extend("force", {}, M.default, opts or {})
	M.utils.opts = M.opts
	M.state.opts = M.opts
	M.rsync.opts = M.opts
	M.log.opts = M.opts
	M.state.sync(M.opts)
end

---Shows the current state of Syncmap
function M.show_state()
	vim.print(M.state.active)
end

---Shows the current options of Syncmap
function M.show_opts()
	vim.print(M.opts)
end

return M
