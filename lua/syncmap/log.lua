local M = {
	opts = require("syncmap.default"),
}

---@param opts FinalSyncmapOpts
function M.setup(opts)
	M.opts = opts
end

---@type table<LogLevel, vim.log.levels>
M.log_table = {
	["info"] = vim.log.levels.INFO,
	["error"] = vim.log.levels.ERROR,
	["none"] = vim.log.levels.OFF,
}

---Logs a message based on options log level
---@param msg any
---@param level vim.log.levels
function M.log(msg, level)
	if level >= M.log_table[M.opts.log_level] then
		vim.schedule(function()
			vim.notify("[syncmap] " .. msg, level)
		end)
	end
end

---Logs message as info
---@param msg any
function M.info(msg)
	M.log(msg, vim.log.levels.INFO)
end

---Logs message as error
---@param msg any
function M.error(msg)
	M.log(msg, vim.log.levels.ERROR)
end

return M
