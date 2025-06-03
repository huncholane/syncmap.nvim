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
		log.error(table.concat(cmd, " ") .. " failed:\n" .. result)
	else
		log.info(table.concat(cmd, " ") .. " succeeded")
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

	simple_cmd.spawn("sh", {
		args = {
			"-c",
			string.format(
				"while inotifywait -r -e modify,create,delete %q; do rsync %s %q %q; done",
				args.src,
				table.concat(args.flags, " "),
				args.src,
				args.dst
			),
		},
		path = "sh",
		cwd = args.src,
		callback = function(code, status, _, pid)
			log.info(
				string.format(
					"The inotify trigger ended with %d code and status %d.\nThe pid from handle is %d.",
					code,
					status,
					pid
				)
			)
		end,
	})
end

return M
