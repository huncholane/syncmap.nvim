local log = require("syncmap.log")
local simple_cmd = require("syncmap.simple_cmd")
local M = {
	opts = require("syncmap.default"),
}

---@param args RsyncParams
function M.rsync(args)
	simple_cmd.spawn()
	local cmd = { "rsync", unpack(args.flags), args.src, args.dst }
	local result = vim.fn.system(cmd)
	if vim.v.shell_error ~= 0 then
		log.error(
			string.format(
				"Failed to run the the following rsync command.\n%s\nResult: %s",
				table.concat(cmd, " "),
				result
			)
		)
	else
		log.debug("Successfully ran the following rsync command.\n" .. table.concat(cmd, " "))
	end
	return result
end

---Kills a process and all of its descendents
---@param pid integer|string
function M.kill(pid)
	vim.fn.system({ "kill", "-TERM", "-" .. tostring(pid) })
end

---Checks if a process is running
---@param pid string|integer
function M.exists(pid)
	local result = false
	local done = false
	M.spawn("ps", {
		args = { "-s", tostring(pid) },
		callback = function(code, _, _, _)
			result = code == 0
			done = true
		end,
	})
	vim.wait(100, function()
		return done
	end, 10)
	return result
end

return M
