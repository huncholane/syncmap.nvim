local log = require("syncmap.log")
local simple_cmd = require("syncmap.simple_cmd")
local M = {
	opts = require("syncmap.default"),
}

---Runs rsync
---@param args RsyncParams
function M.run(args)
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

---@param args RsyncParams
function M.spawn_watcher(args)
	if M.opts.reverse_sync_on_startup then
		M.run({
			src = args.dst,
			dst = args.src,
			reverse_sync_on_spawn = args.reverse_sync_on_spawn,
			flags = args.flags,
		})
	end

	local cmd = "while inotifywait "
	if vim.uv.fs_stat(args.src).type == "directory" then
		log.debug(string.format("Setting up inotify for a file.\n%s", args.src))
		cmd = cmd .. string.format("-r -e modify,create,delete %q; ", args.src)
	else
		log.debug(string.format("Setting up inotify for a file.\n%s", args.src))
		cmd = cmd .. string.format("-e  %q; ", args.src)
	end
	cmd = cmd .. string.format("do rsync %s %q %q; done", table.concat(args.flags, " "), args.src, args.dst)
	local cmd_str_for_log = "sh -c '" .. cmd .. "'"

	local handle, pid = simple_cmd.spawn("sh", {
		args = { "-c", cmd },
		path = "sh",
		-- cwd = args.src,
		callback = function(code, status, _, pid)
			log.debug(string.format("%s\n%d completed with %d code and %d status", cmd_str_for_log, pid, code, status))
		end,
	})
	if not handle then
		log.error(string.format("Failed to start the following command.\n%s\nErr: %s", cmd_str_for_log, pid))
	else
		log.debug(string.format("Started the following command with pid %d\n%s", pid, cmd_str_for_log))
	end
	return pid
end

return M
