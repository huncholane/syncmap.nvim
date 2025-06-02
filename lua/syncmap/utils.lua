local M = {
	opts = require("syncmap.default"),
}

---Correctly extracts reverse_sync_on_spawn
---@param row SyncmapConfigMatch
function M.extract_reverse(row)
	if row.reverse_sync_on_spawn == nil then
		if M.opts.reverse_sync_on_startup == nil then
			return true
		else
			return M.opts.reverse_sync_on_startup
		end
	else
		return row.reverse_sync_on_spawn
	end
end

---Checks if a file exists
---@param path string
local function file_exists(path)
	local f = io.open(path, "r")
	if f then
		f:close()
		return true
	end
	return false
end

---Checks if a path is a directory
---@param path string
local function is_dir(path)
	local stat = vim.uv.fs_stat(path)
	return stat and stat.type == "directory"
end

--- Ensures trailing slash
---@param path string
local function with_trailing_slash(path)
	if path:sub(-1) ~= "/" then
		return path .. "/"
	end
	return path
end

---@param s string
function M.string_to_exclude_from(s)
	return "--exclude_from='" .. s .. "'"
end

---Gets the exclude from using parent pattern
---@param m SyncmapConfigMatch
function M.extract_exclude_from(m)
	if m.exclude_from == nil then
		if M.opts.exclude_from ~= nil then
			return M.string_to_exclude_from(M.opts.exclude_from)
		end
		return nil
	else
		return M.string_to_exclude_from(m.exclude_from)
	end
end

---Makes sure to extract flags correctly
---@param m SyncmapConfigMatch
---@return RsyncFlag[]
function M.extract_flags(m)
	local flags = m.rsync
	if flags == nil then
		flags = M.opts.rsync
	end
	if m.exclude_from == nil then
		return flags
	end
	if is_dir(m[1]) then
		if file_exists(with_trailing_slash(m[1]) .. m.exclude_from) then
			table.insert(flags, M.extract_exclude_from(m))
		end
	end
	return flags
end

---@param m SyncmapConfigMatch
function M.row_to_rsync_params(m)
	local flags = M.extract_flags(m)
	---@type RsyncParams
	return {
		src = vim.fn.expand(m[1]),
		dst = vim.fn.expand(m[2]),
		flags = flags,
		reverse_sync_on_spawn = M.extract_reverse(m),
	}
end

---Kills an inotifywait instance based on the src name
---@param src string
function M.kill(src)
	vim.fn.system({ "pkill", "-f", "^inotifywait.*" .. src })
end

---Searches for an existing inotifywait instance based on the src name
---@param src string
function M.search(src)
	return vim.fn.system({ "pgrep", "-f", "^inotifywait.*" .. src })
end

return M
