local log = require("syncmap.log")
local spawn = require("syncmap.spawn")

---@param src string
---@param dst string
---@param debounce integer
---@param rsync_flags RsyncFlag[]
return function(src, dst, debounce, rsync_flags)
	local cmd = "while inotifywait "
	local stat = vim.uv.fs_stat(src)
	if stat and stat.type == "directory" then
		log.debug(string.format("Setting up inotify for a file.\n%s", src))
		cmd = cmd .. string.format("-r -e modify,create,delete %q; ", src)
	elseif stat and stat.type == "file" then
		log.debug(string.format("Setting up inotify for a file.\n%s", src))
		cmd = cmd .. string.format("-e modify %q; ", src)
	else
		log.error(string.format("Could not stat %s", src))
		return "NO STAT"
	end
	cmd = cmd .. string.format("do rsync %s %q %q sleep %d; done", table.concat(rsync_flags, " "), src, dst, debounce)
	local cmd_str_for_log = "sh -c '" .. cmd .. "'"

	local handle, pid = spawn("sh", {
		args = { "-c", cmd },
		path = "sh",
		callback = function(code, status, _, pid)
			log.debug(string.format("%s\n%d completed with %d code and %d status", cmd_str_for_log, pid, code, status))
		end,
	})
	if not handle then
		log.error(string.format("Failed to start the following command.\n%s\nErr: %s", cmd_str_for_log, pid))
	else
		log.debug(string.format("Started the following command with pid %d\n%s", pid, cmd_str_for_log))
	end
end
