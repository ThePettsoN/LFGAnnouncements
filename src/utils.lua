local _, LFGAnnouncements = ...

local tClone = function(t)
	local clone = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			clone[k] = LFGAnnouncements.Utils.tClone(v)
		else
			clone[k] = v
		end
	end

	return clone
end

local tMergeArray = function(dest, source)
	for i = 1, #source do
		dest[#dest+1] = source[i]
	end
end

local tMergeRecursive = function(dest, source)
	for k, v in pairs(source) do
		local isTable = type(v) == "table"

		if isTable and v[1] and type(dest[k]) == "table" and dest[k][1] then
			tMergeArray(dest[k], v)
		elseif isTable and type(dest[k]) == "table" then
			LFGAnnouncements.Utils.tMergeRecursive(dest[k], v)
		elseif isTable then
			dest[k] = tClone(v)
		else
			dest[k] = v
		end
	end

	return dest
end

local tCount = tcount or function(tbl)
	local n = 0
	for _ in pairs(tbl) do
		n = n + 1
	end

	return n
end

local tKeys = function(tbl)
	local t = {}
	for k, _ in pairs(tbl) do
		t[#t+1] = k
	end

	return t
end

LFGAnnouncements.Utils = {
	tClone = tClone,
	tMergeRecursive = tMergeRecursive,
	tCount = tCount,
	tKeys = tKeys,
}
