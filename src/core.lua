local TOCNAME, LFGAnnouncements = ...

-- Lua APIs
local stringgsub = string.gsub
local stringformat = string.format
local stringgmatch = string.gmatch
local strlower = strlower
local wipe = wipe
local time = time
local pairs = pairs

-- WoW APIs
local GetBuildInfo = GetBuildInfo

local LFGAnnouncementsCore = LibStub("AceAddon-3.0"):NewAddon("LFGAnnouncementsCore", "AceEvent-3.0", "AceTimer-3.0")
local PUtils = LibStub:GetLibrary("PUtils-2.0")
local DebugUtils = PUtils.Debug
LFGAnnouncements.PUtils = PUtils

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
	boosting = true,
	wts = true,
	wtb = true,
	wbt = true,
	buying = true,
	buy = true,
	wst = true,
	selling = true,
}

local LFM_TAGS = {
	["lf[0-9]*m"] = true,
	["lf [0-9]*"] = true,
	["lf [0-9 ]* tank[s]*"] = true,
	["lf [0-9 ]* healer[s]*"] = true,
	["lf [0-9 ]* dps"] = true,
	["lf [0-9 ]* dd[s]*"] = true,
	["need [0-9 ]* tank[s]*"] = true,
	["need [0-9 ]* healer[s]*"] = true,
	["need [0-9 ]* dps"] = true,
	["need [0-9 ]* dd[s]*"] = true,
}

local LFG_TAGS = {
	["lf[0-9]*g"] = true,
}

local GDKP_TAGS = {
	gdkp = true,
	gbid = true,
}

local DUNGEON_ENTRY_REASON = {
	NEW = 1,
	ENTRY_UPDATE = 2,
	SHOW = 3,
	TIME_UPDATE = 4,
	SETTINGS_UPDATE = 5,
}

local tbl = {}
local index = 1

LFGAnnouncementsCore.DUNGEON_ENTRY_REASON = DUNGEON_ENTRY_REASON

LFGAnnouncementsCore.DIFFICULTIES = DIFFICULTIES

LFGAnnouncements.Core = LFGAnnouncementsCore
function LFGAnnouncementsCore:OnInitialize()
	DebugUtils.initialize(self, TOCNAME)
	for name, mod in pairs(self.modules) do
		DebugUtils.initializeModule(mod, self, name)
	end

	-- self:setSeverity(DebugUtils.Severities.Debug)
	self._instanceEntries = {}
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
	self._gdkpFilter = db:GetCharacterData("filters", "gdkp")
	self._lfgFilter = db:GetCharacterData("filters", "lfg")
	self._lfmFilter = db:GetCharacterData("filters", "lfm")
	self._fakeRequestFilterAmount = db:GetCharacterData("filters", "fake_amount")
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

				self:SendMessage("OnInstanceEntry", instanceId, authorGUID, DUNGEON_ENTRY_REASON.TIME_UPDATE, entry) -- TOOD: Could group together and send at once
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
				if not self:_isAllowedDifficulty(difficulty) or (self._boostFilter and entry.boost) or (self._gdkpFilter and entry.gdkp) or (self._lfgFilter and entry.lfg) or (self._lfmFilter and entry.lfm) then
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
	local mod = self:NewModule(name, module, ...)
	LFGAnnouncements[name] = mod

	if self.__putils_debug then
		DebugUtils.initializeModule(mod, self, name)
		-- self:setSeverity(DebugUtils.Severities.Debug)
	end
end

function LFGAnnouncementsCore:SetDifficultyFilter(difficulty)
	if self._difficultyFilter ~= difficulty then
		self._difficultyFilter = difficulty
		LFGAnnouncements.DB:SetCharacterData("difficulty", difficulty, "filters")
		self:info("Changed 'Difficulty' setting to %s", difficulty)
	end
end

function LFGAnnouncementsCore:SetBoostFilter(enabled)
	if self._boostFilter ~= enabled then
		self._boostFilter = enabled
		LFGAnnouncements.DB:SetCharacterData("boost", enabled, "filters")
		self:info("Changed 'BoostFilter' setting to %s", tostring(enabled))
	end
end

function LFGAnnouncementsCore:SetGdkpFilter(enabled)
	if self._gdkpFilter ~= enabled then
		self._gdkpFilter = enabled
		LFGAnnouncements.DB:SetCharacterData("gdkp", enabled, "filters")
		self:info("Changed 'GdkpFilter' setting to %s", tostring(enabled))
	end
end

function LFGAnnouncementsCore:SetLFGFilter(enabled)
	if self._lfgFilter ~= enabled then
		self._lfgFilter = enabled
		LFGAnnouncements.DB:SetCharacterData("lfg", enabled, "filters")
		self:info("Changed 'LFGFilter' setting to %s", tostring(enabled))
	end
end

function LFGAnnouncementsCore:SetLFMFilter(enabled)
	if self._lfmFilter ~= enabled then
		self._lfmFilter = enabled
		LFGAnnouncements.DB:SetCharacterData("lfm", enabled, "filters")
		self:info("Changed 'LFMFilter' setting to %s", tostring(enabled))
	end
end

function LFGAnnouncementsCore:SetFakeFilter(amount)
	if self._fakeRequestFilterAmount ~= amount then
		self._fakeRequestFilterAmount = amount
		LFGAnnouncements.DB:SetCharacterData("fake_amount", amount, "filters")
		self:info("Changed 'FakeFilter' setting to %d", amount)
	end
end

function LFGAnnouncementsCore:SetRaidMarkersFilter(enabled)
	if self._removeRaidMarkers ~= enabled then
		self._removeRaidMarkers = enabled
		LFGAnnouncements.DB:SetProfileData("remove_raid_markers", enabled, "general", "format")
		self:info("Changed 'RaidMarkersFilter' setting to %s", tostring(enabled))

		if enabled then
			local msg, changed
			for instanceId, data in pairs(self._instanceEntries) do
				for authorGUID, entry in pairs(data) do
					msg, changed = self:_formatMessage(entry.message)
					if changed then
						self:info("Updated %s's %s entry due to raid markers setting", authorGUID, instanceId)
						entry.message = msg

						self:SendMessage("OnInstanceEntry", instanceId, authorGUID, DUNGEON_ENTRY_REASON.SETTINGS_UPDATE, entry) -- TOOD: Could group together and send at once
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
	self:info("Changed 'Duration' setting to %d", newDuration)
end

function LFGAnnouncementsCore:SetEnabledInInstance(key, value)
	self._enabledForInstanceTypes[key] = value
	LFGAnnouncements.DB:SetProfileData(key, value, "general", "enable_in_instance")
	self:info("Changed 'EnabledInInstance' setting to %s:%s", tostring(key), tostring(value))
end

local module
local regex = {
	"[%a]+",
	"[%w]+",
	"[%a]+ [0-9][0-9]",
	"[%a]+:[%a]+",
}
local numRegex = #regex

local matchLookup = {}
function LFGAnnouncementsCore:_parseMessage(message, authorGUID)
	if not authorGUID or not message then
		return false
	end

	self:debug("Parsing message '%s' from '%s'", message, authorGUID)
	if #message < 3 then
		self:debug("Ignoring due to size")
		return false
	end

	if not self._enabledForInstanceTypes[self._instanceType] then
		self:debug("Ignoring due to player in disabled area")
		return
	end

	wipe(tbl)
	wipe(matchLookup)
	index = 1

	message = self:_formatMessage(message)
	if not message then
		self:debug("Failed to format message")
		return
	end

	local lowerMsg = strlower(message)
	for i = 1, numRegex do
		for v in stringgmatch(lowerMsg, regex[i]) do
			if not matchLookup[v] then
				tbl[index] = v
				index = index + 1
				matchLookup[v] = true
			end
		end
	end

	local filter, isBoostEntry, isGdkpEntry = self:_filterMessage(tbl)
	if filter then
		self:debug("Ignoring due to filter. isBoostEntry: %s, isGdkpEntry: %s", tostring(isBoostEntry), tostring(isGdkpEntry))
		return
	end

	local filter, isLfgEntry, isLfmEntry = self:_filterRegexMessage(lowerMsg)
	if filter then
		self:debug("Ignoring due to filter. isLfgEntry: %s, isLfmEntry: %s", tostring(isLfgEntry), tostring(isLfmEntry))
		return
	end

	module = self._instances
	local foundInstances, numTotalInstancesFound = module:FindInstances(tbl)
	if foundInstances and numTotalInstancesFound <= self._fakeRequestFilterAmount then
		self:debug("Found %d instances from %s's message", #foundInstances, authorGUID)
		local difficulty = self:_findDifficulty(tbl)
		for i = 1, #foundInstances do
			self:_createInstanceEntry(foundInstances[i], difficulty, message, authorGUID, isBoostEntry, isGdkpEntry, isLfgEntry, isLfmEntry)
		end

		return true
	end

	self:debug("Found 0 instances from %s's message", authorGUID)
	return false
end

function LFGAnnouncementsCore:_filterMessage(tbl, author)
	local isBoostEntry = self:_checkFilterEntry(tbl, BOOST_TAGS)
	if self._boostFilter and isBoostEntry then
		return true
	end

	local isGdkpEntry = self:_checkFilterEntry(tbl, GDKP_TAGS)
	if self._gdkpFilter and isGdkpEntry then
		return true
	end

	return false, isBoostEntry, isGdkpEntry, isLfgEntry, isLfmEntry
end

function LFGAnnouncementsCore:_filterRegexMessage(lowerMsg)
	local isLfgEntry, isLfmEntry

	for pattern, _ in pairs(LFG_TAGS) do
		if string.find(lowerMsg, pattern) then
			isLfgEntry = true
			break
		end
	end

	-- If we match the LFG filter then we assume there's no need to match LFM
	-- Saves us from having to regex against the LFM as well
	if isLfgEntry then
		if self._lfgFilter then
			return true, isLfgEntry, isLfmEntry
		end
		return false, isLfgEntry, isLfmEntry
	end

	for pattern, _ in pairs(LFM_TAGS) do
		if string.find(lowerMsg, pattern) then
			isLfmEntry = true
			break
		end
	end

	if self._lfmFilter and isLfmEntry then
		return true, isLfgEntry, isLfmEntry
	end

	return false, isLfgEntry, isLfmEntry
end

function LFGAnnouncementsCore:_checkFilterEntry(tbl, filter)
	for i = 1, #tbl do
		if filter[tbl[i]] then
			return true
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

function LFGAnnouncementsCore:_createInstanceEntry(instanceId, difficulty, message, authorGUID, isBoostEntry, isGdkpEntry, isLfgEntry, isLfmEntry)
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
		entry.gdkp = isGdkpEntry
		entry.lfg = isLfgEntry
		entry.lfm = isLfmEntry
	else
		newEntry = true
		entry = {
			message = message,
			difficulty = difficulty,
			timestamp_to_remove = time() + self._timeToShow,
			time = 0,
			total_time = 0,
			boost = isBoostEntry,
			gdkp = isGdkpEntry,
			lfg = isLfgEntry,
			lfm = isLfmEntry,
		}
		instanceEntriesForId[authorGUID] = entry
	end

	self:SendMessage("OnInstanceEntry", instanceId, authorGUID, newEntry and DUNGEON_ENTRY_REASON.NEW or DUNGEON_ENTRY_REASON.ENTRY_UPDATE, entry)
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
			self:SendMessage("OnInstanceEntry", instanceId, authorGUID, DUNGEON_ENTRY_REASON.SHOW, entry)
		end
	end
end
