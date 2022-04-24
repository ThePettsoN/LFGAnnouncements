local _, LFGAnnouncements = ...

-- Lua APIs
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
local DEBUG = true

local DIFFICULTIES = {
	NORMAL = "NORMAL",
	HEROIC = "HEROIC",
	RAID = "RAID",
	CUSTOM = "CUSTOM",
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

LFGAnnouncementsCore.DUNGEON_ENTRY_REASON = DUNGEON_ENTRY_REASON

LFGAnnouncementsCore.DIFFICULTIES = DIFFICULTIES

LFGAnnouncements.Core = LFGAnnouncementsCore
LFGAnnouncements.DEBUG = DEBUG
LFGAnnouncements.dprintf = dprintf

function LFGAnnouncementsCore:OnInitialize()
	self._modules = {}
	self._enabledChannels = {
		[1] = true,
		[2] = true,
		[3] = true,
		[4] = true,
		[5] = true,
	}
	self._dungeonEntries = {}

	LFGAnnouncements.GameExpansion = GetBuildInfo():sub(1,1) == '2' and "TBC" or "VANILLA"
end

local UpdateTime = 1
function LFGAnnouncementsCore:OnEnable()
	self:RegisterEvent("CHAT_MSG_CHANNEL", "OnChatMsgChannel")
	self:RegisterEvent("CHAT_MSG_GUILD", "OnChatMsgGuild")
	self:RegisterEvent("CHAT_MSG_SAY", "OnChatMsgSay")

	self:RegisterMessage("OnDungeonDeactivated", "OnDungeonDeactivated")
	self:RegisterMessage("OnShowUI", "OnShowUI")

	self:ScheduleRepeatingTimer("OnUpdate", UpdateTime)

	local db = LFGAnnouncements.DB
	self._dungeons = LFGAnnouncements.Dungeons
	self._timeToShow = db:GetProfileData("general", "time_visible_sec")
	self._difficultyFilter = db:GetCharacterData("filters", "difficulty")
	self._boostFilter = db:GetCharacterData("filters", "boost")
end

function LFGAnnouncementsCore:OnDisable()
end

local dungeonsToRemove = {}
local removeDungeons, currentTime
function LFGAnnouncementsCore:OnUpdate()
	wipe(dungeonsToRemove)
	removeDungeons = false
	currentTime = time()

	local index = 1
	for dungeonId, data in pairs(self._dungeonEntries) do
		for authorGUID, entry in pairs(data) do
			if currentTime >= entry.timestamp_to_remove then
				dungeonsToRemove[index] = dungeonId
				dungeonsToRemove[index + 1] = authorGUID
				index = index + 2
				removeDungeons = true
				self._dungeonEntries[dungeonId][authorGUID] = nil
			else
				local time = entry.time + UpdateTime
				entry.time = time
				self:SendMessage("OnDungeonEntry", dungeonId, entry.difficulty, entry.message, time, authorGUID, DUNGEON_ENTRY_REASON.UPDATE)
			end
		end
	end

	if removeDungeons then
		self:SendMessage("OnRemoveDungeons", dungeonsToRemove)
	end
end

function LFGAnnouncementsCore:UpdateInvalidEntries()
	local dungeonsModule = self._dungeons
	removeDungeons = false
	wipe(dungeonsToRemove)

	local index = 1
	for dungeonId, data in pairs(self._dungeonEntries) do
		if not dungeonsModule:IsActive(dungeonId) then
			for authorGUID, _ in pairs(data) do
				dungeonsToRemove[index] = dungeonId
				dungeonsToRemove[index + 1] = authorGUID
				index = index + 2
			end
			removeDungeons = true
			wipe(data)
		else
			for authorGUID, entry in pairs(data) do
				local difficulty = entry.difficulty
				if not self:_isAllowedDifficulty(difficulty) or (self._boostFilter and entry.boost) then
					data[authorGUID] = nil
					dungeonsToRemove[index] = dungeonId
					dungeonsToRemove[index + 1] = authorGUID
					index = index + 2
					removeDungeons = true
				end
			end
		end
	end

	if removeDungeons then
		self:SendMessage("OnRemoveDungeons", dungeonsToRemove)
	end
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

function LFGAnnouncementsCore:SetDuration(newDuration)
	local diff = self._timeToShow - newDuration
	if diff == 0 then
		return
	end

	for _, data in pairs(self._dungeonEntries) do
		for _, entry in pairs(data) do
			entry.timestamp_to_remove = entry.timestamp_to_remove - diff
		end
	end

	self._timeToShow = newDuration
	LFGAnnouncements.DB:SetProfileData("time_visible_sec", newDuration, "general")
end

local module, i
local splitMessage = {}
local regex = "[^| /\\.{},+()]+"
function LFGAnnouncementsCore:_parseMessage(message, authorGUID)
	if #message < 3 then
		return
	end

	wipe(splitMessage)
	i = 1

	for v in stringgmatch(strlower(message), regex) do
		splitMessage[i] = v
		i = i + 1
	end

	module = self._dungeons
	local foundDungeons = module:FindDungeons(splitMessage)
	if foundDungeons then
		local difficulty = self:_findDifficulty(splitMessage)
		local isBoostEntry = self:_isBoostEntry(splitMessage)
		if not self._boostFilter or not isBoostEntry then
			for dungeonId, _ in pairs(foundDungeons) do
				self:_createDungeonEntry(dungeonId, difficulty, message, authorGUID, isBoostEntry)
			end
		end
	end
end

function LFGAnnouncementsCore:_createDungeonEntry(dungeonId, difficulty, message, authorGUID, isBoostEntry)
	dprintf("DUNGEON: %q | Diff: %q", dungeonId, difficulty)
	local instanceType = self._dungeons:GetInstanceType(dungeonId)
	dprintf("Type: %q", instanceType)
	if instanceType == LFGAnnouncements.Dungeons.InstanceType.RAID then
		difficulty = DIFFICULTIES.RAID
	elseif instanceType == LFGAnnouncements.Dungeons.InstanceType.CUSTOM then
		difficulty = DIFFICULTIES.CUSTOM
	elseif not self:_isAllowedDifficulty(difficulty) then
		return
	end

	local dungeonEntriesForId = self._dungeonEntries[dungeonId]
	if not dungeonEntriesForId then
		dungeonEntriesForId = {}
		self._dungeonEntries[dungeonId] = dungeonEntriesForId
	end

	local newEntry = not dungeonEntriesForId[authorGUID]
	dungeonEntriesForId[authorGUID] = {
		message = message,
		difficulty = difficulty,
		timestamp_to_remove = time() + self._timeToShow,
		time = 0,
		boost = isBoostEntry,
	}

	self:SendMessage("OnDungeonEntry", dungeonId, difficulty, message, 0, authorGUID, newEntry and DUNGEON_ENTRY_REASON.NEW or DUNGEON_ENTRY_REASON.UPDATE)
end

function LFGAnnouncementsCore:_findDifficulty(splitMessage)
	for i = 1, #splitMessage do
		local difficulty = DIFFICULTY_TAGS[splitMessage[i]]
		if difficulty then
			return difficulty
		end
	end

	return DIFFICULTIES.NORMAL
end

function LFGAnnouncementsCore:_isBoostEntry(splitMessage)
	for i = 1, #splitMessage do
		if BOOST_TAGS[splitMessage[i]] then
			return true
		end
	end
	return false
end

function LFGAnnouncementsCore:_isAllowedDifficulty(difficulty)
	if self._difficultyFilter == "ALL" then
		return true
	end

	if difficulty == DIFFICULTIES.RAID or difficulty == DIFFICULTIES.CUSTOM then
		return true
	end

	return self._difficultyFilter == difficulty
end


--Events

function LFGAnnouncementsCore:OnChatMsgChannel(event, message, _, _, _, playerName, _, _, channelIndex, _, _, _, guid)
	self:_parseMessage(message, guid)
end

function LFGAnnouncementsCore:OnChatMsgGuild(event, message, author, language, lineId, senderGUID)
end

function LFGAnnouncementsCore:OnChatMsgSay(event, message, _, _, _, playerName, _, _, _, _, _, _, guid)
	self:_parseMessage(message, guid)
end

function LFGAnnouncementsCore:OnDungeonDeactivated(event, dungeonId)
	self._dungeonEntries[dungeonId] = nil
end

function LFGAnnouncementsCore:OnShowUI(event)
	for dungeonId, data in pairs(self._dungeonEntries) do
		for authorGUID, entry in pairs(data) do
			self:SendMessage("OnDungeonEntry", dungeonId, entry.difficulty, entry.message, entry.time, authorGUID, DUNGEON_ENTRY_REASON.SHOW)
		end
	end
end
