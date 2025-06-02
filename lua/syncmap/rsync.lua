local log = require("syncmap.log")
local utils = require("syncmap.utils")
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
		M.run(args)
	end
	local cmd = string.format(
		"while inotifywait -r -e modify,create,delete %q; do rsync %s %q %q; done",
		args.src,
		table.concat(utils.extract_flags(args.flags), " "),
		args.src,
		args.dst
	)

	local handle
	handle, _ = vim.uv.spawn("sh", {
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
		stdio = { nil, nil, nil },
		cwd = args.src,
		env = vim.fn.environ(),
		detached = true,
		hide = true,
		---@diagnostic disable-next-line: assign-type-mismatch
		uid = vim.uv.getuid(),
		verbatim = false,
		---@diagnostic disable-next-line: assign-type-mismatch
		gid = vim.uv.getgid(),
	}, function(code, signal)
		log.info(cmd .. "\nEnded with code " .. code .. " and signal " .. signal)
		handle:close()
	end)
end

return M
