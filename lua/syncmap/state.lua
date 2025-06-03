local rsync = require("syncmap.rsync")
local utils = require("syncmap.utils")
local log = require("syncmap.log")
local simple_cmd = require("syncmap.simple_cmd")
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

---@alias RunningPid string|integer The process id for a SyncmapWatchItem
---@alias RunningTag string A key based on src:dst for a SyncmapWatchItem
---@alias RunningSrcs table<RsyncPath, RunningPid>

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
	---@type table<RunningTag, SyncmapWatchItem>
	local lookup = {}
	for _, m in ipairs(opts.map) do
		local tag = vim.fn.expand(m[1]) .. ":" .. vim.fn.expand(m[2])
		lookup[tag] = m
	end

	-- Iterate active and sync what exists
	for tag, pid in pairs(M.active) do
		if not lookup[tag] then
			log.info(string.format("Removed from the config.\n%s\nRemoving the process %d.", tag, pid))
			M.active[tag] = nil
			simple_cmd.kill(pid)
		elseif not simple_cmd.exists(pid) then
			log.info(
				string.format(
					"In active table but the process %d is not running.\n%s\nStarting a new process.",
					pid,
					tag
				)
			)
			local m = lookup[tag]
			local r = utils.row_to_rsync_params(m)
			M.active[tag] = rsync.spawn_watcher(r)
		end
	end

	---Iterate config and add new items
	for _, m in ipairs(opts.map) do
		local tag = vim.fn.expand(m[1]) .. ":" .. vim.fn.expand(m[2])
		if not M.active[tag] then
			log.info(string.format("%s\nIn the config but not in the active table. Starting a new process.", tag))
			local r = utils.row_to_rsync_params(m)
			M.active[tag] = rsync.spawn_watcher(r)
		end
	end
	M.save()
end

function M.save()
	local ok, encoded = pcall(vim.json.encode, M.active)
	if not ok then
		log.error("Failed to encode state")
		return
	end

	local fd = io.open(M.state_file, "w")
	if not fd then
		log.error("Failed to open state file for writing")
		return
	end

	fd:write(encoded)
	fd:close()
end

---Kills all the active inotifywatch servers
function M.killall()
	local s = ""
	for tag, pid in pairs(M.active) do
		s = string.format("%s\n%d: %s", s, pid, tag)
		simple_cmd.kill(pid)
	end
	log.info(string.format("Killed the following watch items\n%s", s))
	M.active = {}
end

---Clears the saved information by deleting the state file
function M.clean()
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

---List active
function M.show_active()
	local s = ""
	for tag, pid in M.active do
		s = string.format("%d: %s", pid, tag)
	end
	log.print("Current active watchers\n" .. s)
end

---Shows the current options of Syncmap
function M.show_opts()
	vim.print(M.opts)
end

return M
