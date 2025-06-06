local M = {}

---@alias StdIO integer|uv.uv_stream_t|nil

---@alias SpawnCommandCallback fun(code:integer, signal:integer, handle:uv.uv_process_t, pid:integer)

---@class SpawnCommandParams
---@field args string[] The arguments to run on the exectuable
---@field cwd? string @[default=vim.fn.getcwd()] Set the current working directory for the sub-process.
---@field env? table<string,string> @[default=vim.fn.environ()] Set environment variables for the new process.
---@field stdio? { [1]: integer|uv.uv_stream_t|nil, [2]: integer|uv.uv_stream_t|nil, [3]: integer|uv.uv_stream_t|nil } @[default={nil,nil,nil}] Set the file descriptors that will be made available to the child process. The convention is that the first entries are stdin, stdout, and stderr. (**Note**: On Windows, file descriptors after the third are available to the child process only if the child processes uses the MSVCRT runtime.)
---@field detatched? boolean @[default=true] If true, spawn the child process in a detached state - this will make it a process group leader, and will effectively enable the child to keep running after the parent exits. Note that the child process will still keep the parent's event loop alive unless the parent process calls `uv.unref()` on the child's process handle.
---@field hide? boolean @[default=true] If true, hide the subprocess console window that would normally be created. This option is only meaningful on Windows systems. On Unix it is silently ignored.
---@field uid? integer @[default=vim.uv.getuid()] Set the child process' user id.
---@field verbatim? boolean @[default=false] If true, do not wrap any arguments in quotes, or perform any other escaping, when converting the argument list into a command line string. This option is only meaningful on Windows systems. On Unix it is silently ignored.
---@field gid? integer @[default=vim.uv.getgid()] Set the child process' group id.
---The callback to run after the command has returned
---@field callback? SpawnCommandCallback
---@field close? boolean @[default=true] Request the handle to be closed (to simplify callbacks)

---A wrapper for uv.spawn that includes defaults. This makes it easier to spawn commands in the background. Also automatically closes the handle unless close is specified to false.
---@param path string the exectuable path
---@param p SpawnCommandParams
function M.spawn(path, p)
	local args = p.args
	local stdio = p.stdio or { nil, nil, nil }
	local cwd = p.cwd or vim.fn.getcwd()
	local env = p.env or vim.fn.environ()
	local detached = p.detatched ~= nil and p.detatched or true
	local hide = p.hide ~= nil and p.hide or true
	local uid = p.uid or vim.uv.getuid()
	local verbatim = p.verbatim ~= nil and p.verbatim or false
	local gid = p.gid ~= nil and p.gid or vim.uv.getgid()
	local close = p.close ~= nil and p.close or true

	local handle, pid
	handle, pid = vim.uv.spawn(path, {
		args = args,
		stdio = stdio,
		cwd = cwd,
		env = env,
		detached = detached,
		hide = hide,
		---@diagnostic disable-next-line: assign-type-mismatch
		uid = uid,
		verbatim = verbatim,
		---@diagnostic disable-next-line: assign-type-mismatch
		gid = gid,
	}, function(code, signal)
		if p.callback then
			p.callback(code, signal, handle, pid)
		end
		if close then
			handle:close()
		end
	end)
	return handle, pid
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
