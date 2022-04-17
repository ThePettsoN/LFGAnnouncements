local _, LFGAnnouncements = ...

-- Lua APIs
local pairs = pairs
local type = type

-- WoW APIs
local CopyTable = CopyTable

local tMergeArray = function(dest, source)
	for i = 1, #source do
		dest[#dest+1] = source[i]
	end
end

local tMergeRecursive = function(dest, source)
	for k, v in pairs(source) do
		local isTable = type(v) == "table"

		if isTable and v[1] and type(dest[k]) == "table" and dest[k][1] then -- Stupid check that assumes that all tables where index 1 exists in both dest and source are arrays.
			tMergeArray(dest[k], v)
		elseif isTable and type(dest[k]) == "table" then
			LFGAnnouncements.Utils.tMergeRecursive(dest[k], v)
		elseif isTable then
			dest[k] = CopyTable(v)
		else
			dest[k] = v
		end
	end

	return dest
end

LFGAnnouncements.Utils = {
	tMergeRecursive = tMergeRecursive,
}
