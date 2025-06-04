---@class MapConfig
---@field entries Entry[]

---@class Map : MapConfig
Map = {}

---@field o MapConfig
function Map:new(o)
	o = o or {}
end
