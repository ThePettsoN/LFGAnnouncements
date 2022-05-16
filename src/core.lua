local _, LFGAnnouncements = ...

-- Lua APIs
local stringgsub = string.gsub
local stringformat = string.format
local stringgmatch = string.gmatch
local strlower = strlower
local print = print
local wipe = wipe
local time = time
local pairs = pairs

-- WoW APIs
local GetBuildInfo = GetBuildInfo

local LFGAnnouncementsCore = LibStub("AceAddon-3.0"):NewAddon("LFGAnnouncementsCore", "AceEvent-3.0", "AceTimer-3.0")
local DEBUG = false

local DIFFICULTIES = {
	NORMAL = "NORMAL",
	HEROIC = "HEROIC",
	RAID = "RAID",
}

local DIFFICULTY_TAGS = {
	n = DIFFICULTIES.NORMAL,
	normal = DIFFICULTIES.NORMAL,
	h = DIFFICULTIES.HEROIC,
	hc = DIFFICULTIES.HEROIC,
	heroic = DIFFICULTIES.HEROIC,
}

local BOOST_TAGS = {
	boost = true,
	boosts = true,
	wts = true,
	wst = true,
	-- sell = true,
	-- selling = true,
}

local DUNGEON_ENTRY_REASON = {
	NEW = 1,
	UPDATE = 2,
	SHOW = 3,
}

local dprintf = function(s, ...)
	if DEBUG then
		print(stringformat(s, ...))
	end
end
local tbl = {}
local index = 1

LFGAnnouncementsCore.DUNGEON_ENTRY_REASON = DUNGEON_ENTRY_REASON

LFGAnnouncementsCore.DIFFICULTIES = DIFFICULTIES

LFGAnnouncements.Core = LFGAnnouncementsCore
LFGAnnouncements.DEBUG = DEBUG
LFGAnnouncements.dprintf = dprintf

function LFGAnnouncementsCore:OnInitialize()
	self._modules = {}
	self._instanceEntries = {}

	LFGAnnouncements.GameExpansion = GetBuildInfo():sub(1,1) == '2' and "TBC" or "VANILLA"
end

local UpdateTime = 1
function LFGAnnouncementsCore:OnEnable()
	self:RegisterEvent("CHAT_MSG_CHANNEL", "OnChatMsgChannel")
	self:RegisterEvent("CHAT_MSG_GUILD", "OnChatMsgGuild")
	self:RegisterEvent("CHAT_MSG_SAY", "OnChatMsg")
	self:RegisterEvent("CHAT_MSG_YELL", "OnChatMsg")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnteringWorld")

	self:RegisterMessage("OnInstanceDeactivated", "OnInstanceDeactivated")
	self:RegisterMessage("OnShowUI", "OnShowUI")

	self:ScheduleRepeatingTimer("OnUpdate", UpdateTime)

	local db = LFGAnnouncements.DB
	self._instances = LFGAnnouncements.Instances
	self._timeToShow = db:GetProfileData("general", "time_visible_sec")
	self._difficultyFilter = db:GetCharacterData("filters", "difficulty")
	self._boostFilter = db:GetCharacterData("filters", "boost")
	self._removeRaidMarkers = db:GetProfileData("general", "format", "remove_raid_markers")
	self._enabledForInstanceTypes = db:GetProfileData("general", "enable_in_instance")
end

function LFGAnnouncementsCore:OnDisable()
end

local removeInstances, currentTime
function LFGAnnouncementsCore:OnUpdate()
	removeInstances = false
	currentTime = time()
	wipe(tbl)

	index = 1
	for instanceId, data in pairs(self._instanceEntries) do
		for authorGUID, entry in pairs(data) do
			if currentTime >= entry.timestamp_to_remove then
				tbl[index] = instanceId
				tbl[index + 1] = authorGUID
				index = index + 2
				removeInstances = true
				self._instanceEntries[instanceId][authorGUID] = nil
			else
				local time = entry.time + UpdateTime
				local total_time = entry.total_time + UpdateTime
				entry.time = time
				entry.total_time = total_time
				self:SendMessage("OnInstanceEntry", instanceId, entry.difficulty, entry.message, time, total_time, authorGUID, DUNGEON_ENTRY_REASON.UPDATE) -- TOOD: Could group together and send at once
			end
		end
	end

	if removeInstances then
		self:SendMessage("OnRemoveInstances", tbl)
	end
end

function LFGAnnouncementsCore:UpdateInvalidEntries()
	local instancesModule = self._instances
	removeInstances = false
	index = 1
	wipe(tbl)

	for instanceId, data in pairs(self._instanceEntries) do
		if not instancesModule:IsActive(instanceId) then
			for authorGUID, _ in pairs(data) do
				tbl[index] = instanceId
				tbl[index + 1] = authorGUID
				index = index + 2
			end
			removeInstances = true
			wipe(data)
		else
			for authorGUID, entry in pairs(data) do
				local difficulty = entry.difficulty
				if not self:_isAllowedDifficulty(difficulty) or (self._boostFilter and entry.boost) then
					data[authorGUID] = nil
					tbl[index] = instanceId
					tbl[index + 1] = authorGUID
					index = index + 2
					removeInstances = true
				end
			end
		end
	end

	if removeInstances then
		self:SendMessage("OnRemoveInstances", tbl)
	end
end

function LFGAnnouncementsCore:DeleteAllEntries()
	index = 1
	wipe(tbl)

	for instanceId, data in pairs(self._instanceEntries) do
		for authorGUID, entry in pairs(data) do
			data[authorGUID] = nil
			tbl[index] = instanceId
			tbl[index + 1] = authorGUID
			index = index + 2
		end
	end

	self:SendMessage("OnRemoveInstances", tbl)
end

function LFGAnnouncementsCore:RegisterModule(name, module, ...)
	self:NewModule(name, module, ...)
end

function LFGAnnouncementsCore:SetDifficultyFilter(difficulty)
	if self._difficultyFilter ~= difficulty then
		self._difficultyFilter = difficulty
		LFGAnnouncements.DB:SetCharacterData("difficulty", difficulty, "filters")
	end
end

function LFGAnnouncementsCore:SetBoostFilter(enabled)
	if self._boostFilter ~= enabled then
		self._boostFilter = enabled
		LFGAnnouncements.DB:SetCharacterData("boost", enabled, "filters")
	end
end

function LFGAnnouncementsCore:SetRaidMarkersFilter(enabled)
	if self._removeRaidMarkers ~= enabled then
		self._removeRaidMarkers = enabled
		LFGAnnouncements.DB:SetProfileData("remove_raid_markers", enabled, "general", "format")

		if enabled then
			local msg, changed
			for instanceId, data in pairs(self._instanceEntries) do
				for authorGUID, entry in pairs(data) do
					msg, changed = self:_formatMessage(entry.message)
					if changed then
						entry.message = msg
						self:SendMessage("OnInstanceEntry", instanceId, entry.difficulty, msg, entry.time, entry.total_time, authorGUID, DUNGEON_ENTRY_REASON.UPDATE) -- TOOD: Could group together and send at once
					end
				end
			end
		end
	end
end

function LFGAnnouncementsCore:SetDuration(newDuration)
	local diff = self._timeToShow - newDuration
	if diff == 0 then
		return
	end

	for _, data in pairs(self._instanceEntries) do
		for _, entry in pairs(data) do
			entry.timestamp_to_remove = entry.timestamp_to_remove - diff
		end
	end

	self._timeToShow = newDuration
	LFGAnnouncements.DB:SetProfileData("time_visible_sec", newDuration, "general")
end

function LFGAnnouncementsCore:SetEnabledInInstance(key, value)
	self._enabledForInstanceTypes[key] = value
	LFGAnnouncements.DB:SetProfileData(key, value, "general", "enable_in_instance")
end

local module
local regex = "[%w]+"
function LFGAnnouncementsCore:_parseMessage(message, authorGUID)
	if #message < 3 then
		return false
	end

	if not self._enabledForInstanceTypes[self._instanceType] then
		return
	end

	wipe(tbl)
	index = 1

	message = self:_formatMessage(message)
	for v in stringgmatch(strlower(message), regex) do
		tbl[index] = v
		index = index + 1
	end

	module = self._instances
	local foundInstances = module:FindInstances(tbl)
	if foundInstances then
		local difficulty = self:_findDifficulty(tbl)
		local isBoostEntry = self:_isBoostEntry(tbl)
		if not self._boostFilter or not isBoostEntry then
			for instanceId, _ in pairs(foundInstances) do
				self:_createInstanceEntry(instanceId, difficulty, message, authorGUID, isBoostEntry)
			end
			return true
		else
			LFGAnnouncements.dprintf("Ignoring message '%s' due to boosting filter", message)
		end
	end

	return false
end

local formattedMessage
local raidSymbols = { -- This is ugly, but since LUA can't do ignore case on pattern matching, and we don't want all messages to be in lowercase we have to check for all combinations with both upper and lower case letters
	"{[Ss][Tt][Aa][Rr]}",
	"{[Cc][ii][Rr][Cc][Ll][Ee]}",
	"{[Dd][Ii][Aa][Mm][Oo][Nn][Dd]}",
	"{[Tt][Rr][Ii][Aa][Nn][Gg][Ll][Ee]}",
	"{[Mm][Oo][Oo][Nn]}",
	"{[Ss][Qq][Uu][Aa][Rr][Ee]}",
	"{[Cc][Rr][Oo][Ss][Ss]}",
	"{[Ss][Kk][Uu][Ll][Ll]}",
	"{[Rr][Tt]1}",
	"{[Rr][Tt]2}",
	"{[Rr][Tt]3}",
	"{[Rr][Tt]4}",
	"{[Rr][Tt]5}",
	"{[Rr][Tt]6}",
	"{[Rr][Tt]7}",
	"{[Rr][Tt]8}",
	"{[Gg][Oo][Ll][Dd]}",
	"{[Oo][Rr][Aa][Nn][Gg][Ee]}",
	"{[Pp][Uu][Rr][Pp][Ll][Ee]}",
	"{[Gg][Rr][Ee][Ee][Nn]}",
	"{[Ss][Ii][Ll][Vv][Ee][Rr]}",
	"{[Bb][Ll][Uu][Ee]}",
	"{[Rr][Ee][Dd]}",
	"{[Ww][Hh][Ii][Tt][Ee]}",
}

function LFGAnnouncementsCore:_formatMessage(message)
	formattedMessage = message
	local changed
	if self._removeRaidMarkers then
		local count
		for i = 1, #raidSymbols do
			formattedMessage, count = stringgsub(formattedMessage, raidSymbols[i], "")
			changed = changed or count > 0
		end
	end

	if changed then
		-- Trim
		return formattedMessage:match"^%s*(.*%S)", true
	end

	return formattedMessage, false
end

function LFGAnnouncementsCore:_createInstanceEntry(instanceId, difficulty, message, authorGUID, isBoostEntry)
	local instanceType = self._instances:GetInstanceType(instanceId)
	local types = LFGAnnouncements.Instances.InstanceType
	if instanceType == types.RAID then
		difficulty = DIFFICULTIES.RAID
	elseif instanceType ~= types.CUSTOM and not self:_isAllowedDifficulty(difficulty) then
		return
	end

	local instanceEntriesForId = self._instanceEntries[instanceId]
	if not instanceEntriesForId then
		instanceEntriesForId = {}
		self._instanceEntries[instanceId] = instanceEntriesForId
	end

	local entry = instanceEntriesForId[authorGUID]
	local newEntry
	if entry then
		entry.message = message
		entry.difficulty = difficulty
		entry.timestamp_to_remove = time() + self._timeToShow
		entry.time = 0
		entry.boost = isBoostEntry
	else
		newEntry = true
		entry = {
			message = message,
			difficulty = difficulty,
			timestamp_to_remove = time() + self._timeToShow,
			time = 0,
			total_time = 0,
			boost = isBoostEntry,
		}
		instanceEntriesForId[authorGUID] = entry
	end

	self:SendMessage("OnInstanceEntry", instanceId, difficulty, message, 0, entry.total_time, authorGUID, newEntry and DUNGEON_ENTRY_REASON.NEW or DUNGEON_ENTRY_REASON.UPDATE)
end

function LFGAnnouncementsCore:_findDifficulty(tbl)
	for i = 1, #tbl do
		local difficulty = DIFFICULTY_TAGS[tbl[i]]
		if difficulty then
			return difficulty
		end
	end

	return DIFFICULTIES.NORMAL
end

function LFGAnnouncementsCore:_isBoostEntry(tbl)
	for i = 1, #tbl do
		if BOOST_TAGS[tbl[i]] then
			return true
		end
	end
	return false
end

function LFGAnnouncementsCore:_isAllowedDifficulty(difficulty)
	if self._difficultyFilter == "ALL" then
		return true
	end

	if difficulty == DIFFICULTIES.RAID then
		return true
	end

	return self._difficultyFilter == difficulty
end


--Events
function LFGAnnouncementsCore:OnChatMsgChannel(event, message, _, _, _, playerName, _, _, channelIndex, _, _, _, guid)
	return self:_parseMessage(message, guid)
end

function LFGAnnouncementsCore:OnChatMsgGuild(event, message, author, language, lineId, senderGUID)
end

function LFGAnnouncementsCore:OnChatMsg(event, message, _, _, _, playerName, _, _, _, _, _, _, guid)
	return self:_parseMessage(message, guid)
end

function LFGAnnouncementsCore:OnPlayerEnteringWorld(event, isInitialLogin, isReloadingUi)
	local _, instanceType = GetInstanceInfo()
	self._instanceType = instanceType == "none" and "world" or instanceType
end

function LFGAnnouncementsCore:OnInstanceDeactivated(event, instanceId)
	self._instanceEntries[instanceId] = nil
end

function LFGAnnouncementsCore:OnShowUI(event)
	for instanceId, data in pairs(self._instanceEntries) do
		for authorGUID, entry in pairs(data) do
			self:SendMessage("OnInstanceEntry", instanceId, entry.difficulty, entry.message, entry.time, entry.total_time, authorGUID, DUNGEON_ENTRY_REASON.SHOW)
		end
	end
end
