local _, LFGAnnouncements = ...

local LFGAnnouncementsCore = LibStub("AceAddon-3.0"):NewAddon("LFGAnnouncementsCore", "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0")
local DEBUG = false

local dprintf = function(s, ...)
	if DEBUG then
		print(string.format(s, ...))
	end
end

LFGAnnouncements.Core = LFGAnnouncementsCore
LFGAnnouncements.DEBUG = DEBUG
LFGAnnouncements.dprintf = dprintf
LFGAnnouncements.DungeonEntryReason = {
	NEW = 1,
	UPDATE = 2,
	SHOW = 3,
}

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

	self:RegisterChatCommand("lfga", "OnChatCommand")

	self:ScheduleRepeatingTimer("OnUpdate", UpdateTime)

	local db = LFGAnnouncements.DB
	self._timeToShow = db:GetProfileData("general", "time_visible_sec")
	self._difficultyFilter = db:GetCharacterData("filters", "difficulty")
	self._boostFilter = db:GetCharacterData("filters", "boost")
end

function LFGAnnouncementsCore:OnDisable()
end

local dungeonsToRemove = {}
local removeDungeons = false
function LFGAnnouncementsCore:OnUpdate()
	wipe(dungeonsToRemove)
	removeDungeons = false
	local currentTime = time()
	for dungeonId, data in pairs(self._dungeonEntries) do
		for authorGUID, entry in pairs(data) do
			if currentTime >= entry.timestamp_to_remove then
				dungeonsToRemove[dungeonId] = authorGUID
				removeDungeons = true
				self._dungeonEntries[dungeonId][authorGUID] = nil
			else
				local time = self._dungeonEntries[dungeonId][authorGUID].time + UpdateTime
				self._dungeonEntries[dungeonId][authorGUID].time = time
				self:SendMessage("OnDungeonEntry", dungeonId, entry.difficulty, entry.message, time, authorGUID, LFGAnnouncements.DungeonEntryReason.UPDATE)
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
			self:SendMessage("OnDungeonEntry", dungeonId, entry.difficulty, entry.message, entry.time, authorGUID, LFGAnnouncements.DungeonEntryReason.SHOW)
		end
	end
end

function LFGAnnouncementsCore:OnChatCommand(args)
	local command = self:GetArgs(args, 1)
	if command == "show" or command == "open" then
		local module = self:GetModule("UI")
		if not module:IsShown() then
			module:Toggle()
		end
	elseif command == "hide" or command == "close" then
		local module = self:GetModule("UI")
		module:Hide()
	elseif command == "enableall" then
		local module = self:GetModule("Dungeons")
		module:ActivateAll()
	elseif command == "disableall" then
		local module = self:GetModule("Dungeons")
		module:DisableAll()
	elseif command == "config" or command == "settings" or command == "options" then
		LFGAnnouncements.Options.Toggle()
	elseif command then
		dprintf("Unkown command: %s", command)
	end
end

local module
local splitMessage = {}
function LFGAnnouncementsCore:_parseMessage(message, authorGUID)
	if #message < 3 then
		return
	end

	wipe(splitMessage)
	for v in string.gmatch(strlower(message), "[^| /\\.{},+]+") do
		splitMessage[#splitMessage+1] = v
	end

	module = LFGAnnouncements.Dungeons
	local foundDungeons = module:FindDungeons(splitMessage)
	if foundDungeons then
		local difficulty = self:_findDifficulty(splitMessage)
		if self._difficultyFilter == "ALL" or self._difficultyFilter == difficulty then
			if self:_tryFilterBoost(splitMessage) then
				for dungeonId, _ in pairs(foundDungeons) do
					self:_createDungeonEntry(dungeonId, difficulty, message, authorGUID)
				end
			end
		end
	end
end

function LFGAnnouncementsCore:_createDungeonEntry(dungeonId, difficulty, message,  authorGUID)
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
	}

	self:SendMessage("OnDungeonEntry", dungeonId, difficulty, message, 0, authorGUID, newEntry and LFGAnnouncements.DungeonEntryReason.NEW or LFGAnnouncements.DungeonEntryReason.UPDATE)
end

local normal = "NORMAL"
local heroic = "HEROIC"
local tags = {
	n = normal,
	normal = normal,
	h = heroic,
	hc = heroic,
	heroic = heroic,
}
function LFGAnnouncementsCore:_findDifficulty(splitMessage)
	for i = 1, #splitMessage do
		local difficulty = tags[splitMessage[i]]
		if difficulty then
			return difficulty
		end
	end

	return normal
end

local boostTags = {
	boost = true,
	boosts = true,
	wts = true,
	wst = true,
	-- sell = true,
	-- selling = true,
}
function LFGAnnouncementsCore:_tryFilterBoost(splitMessage)
	if not self._boostFilter then
		return true
	end

	for i = 1, #splitMessage do
		if boostTags[splitMessage[i]] then
			return false
		end
	end

	return true
end