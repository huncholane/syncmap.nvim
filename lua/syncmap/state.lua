local rsync = require("syncmap.rsync")
local utils = require("syncmap.utils")
local log = require("syncmap.log")
local M = {
	opts = require("syncmap.default"),
}

M.dir = vim.fn.expand("~/.local/share/nvim/syncmap/")

---Make sure the directory exists
if vim.fn.isdirectory(M.dir) == 0 then
	vim.fn.mkdir(M.dir, "p")
end

M.state_file = vim.fn.expand("~/.local/share/nvim/syncmap/state.json")

-- Create file if it doesn't exist
local function create_state_file()
	if vim.fn.filereadable(M.state_file) == 0 then
		local fd = io.open(M.state_file, "w")
		if fd then
			fd:write("{}") -- empty JSON object
			fd:close()
		else
			utils.log("Failed to create state file", vim.log.levels.ERROR)
		end
	end
end
create_state_file()

---@alias RunningSrcs table<RsyncPath, boolean>

---A dictionairy keyed on the src for a match located in ~/.local/share/nvim/syncmap/state.json
---@type RunningSrcs
M.active = {}

---Load the existing config if possible
local function load_state()
	local content = vim.fn.readfile(M.state_file)
	local joined = table.concat(content, "\n")
	local ok, parsed = pcall(vim.json.decode, joined)
	if ok and type(parsed) == "table" then
		M.active = parsed
	else
		utils.log("Failed to parse state file", vim.log.levels.ERROR)
	end
end
load_state()

---Removes stale states, calls reverse_rsync on new folders, and starts watch on dead pids
function M.sync()
	local opts = M.opts
	---@type table<RsyncPath, SyncmapConfigMatch>
	local lookup = {}
	for _, m in ipairs(opts.map) do
		lookup[m[1]] = m
	end

	for src in pairs(M.active) do
		if not lookup[src] then
			M.active[src] = nil
			utils.kill(src)
		elseif utils.search(src) == "" then
			local m = lookup[src]
			local r = utils.row_to_rsync_params(m)
			log.info("Couldn't find process for " .. m[1] .. " " .. m[2])
			rsync.spawn_watcher(r)
			M.active[r.src] = true
		end
	end

	for _, m in ipairs(opts.map) do
		if not M.active[m[1]] then
			local r = utils.row_to_rsync_params(m)
			rsync.spawn_watcher(r)
			M.active[r.src] = true
		end
	end
	M.save()
end

function M.save()
	local ok, encoded = pcall(vim.json.encode, M.active)
	if not ok then
		utils.log("Failed to encode state", vim.log.levels.ERROR)
		return
	end

	local fd = io.open(M.state_file, "w")
	if not fd then
		utils.log("Failed to open state file for writing", vim.log.levels.ERROR)
		return
	end

	fd:write(encoded)
	fd:close()
end

---Kills all the active inotifywatch servers
function M.killall()
	for src in M.active do
		utils.kill(src)
	end
end

---Clears the saved information by deleting the state file
function M.clear()
	M.killall()
	local ok, err = os.remove(M.state_file)
	if not ok then
		log.error("Failed to delete state file: " .. err)
	else
		log.info("State file deleted")
	end
end

---Restarts Syncmap
function M.restart()
	M.killall()
	M.sync()
end

return M
