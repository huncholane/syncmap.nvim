local log = require("syncmap.log")
local simple_cmd = require("syncmap.simple_cmd")
local rsync = require("syncmap.rsync")
local M = {
	opts = require("syncmap.default"),
}

---@alias File string
---@alias Folder string

---@alias Filetype "file"|"dir"

---@class DirEntry
---@field path File|Folder
---@field rsync_flags RsyncFlag[]
---@field isfile? boolean
---@field isdir? boolean
DirEntry = {}

---@return DirEntry|nil
---@param o DirEntry
function DirEntry:new(o)
	local stat = vim.uv.fs_stat(o.path)
	if stat and stat.type == "file" then
		o.isfile = true
	elseif stat and stat.type == "directory" then
		o.isdir = true
	else
		log.error(string.format("%q is not a valid file or directory", o.path))
		return nil
	end

	setmetatable(o, self)
	self.__index = self
	return o
end

---@param src string
function DirEntry:rsync_from(src)
	local cmd = { "rsync", unpack(self.rsync_flags), src, self.path }
end

---@param dst string
function DirEntry:rsync_to(dst) end

return M
