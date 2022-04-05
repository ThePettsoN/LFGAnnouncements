local _, LFGAnnouncements = ...

local LFGAnnouncementsDBModule = {}
local defaults = {
	profile = {
		minimap = {
			hide = false,
			lock = false,
		},
		search_settings = {
			time_visible_sec = 120,
			channels = {},
			new_on_top = true,
		},
		announcements = {
			toaster = false,
			sound = false,
			sound_id = 3081,
			chat = false,
			chat_channel = 1,
		},
		position = {
			x = 0,
			y = 0,
			stored = false,
		}
	},
	char = {
		initialized = false,
		dungeons = {
			activated = {},
			custom_tags = {},
		},
		filters = {
			difficulty = "ALL",
			level_range = false,
		}
	}
}

function LFGAnnouncementsDBModule:OnInitialize()
	LFGAnnouncements.DB = self
	self._db = LibStub("AceDB-3.0"):New("LFGAnnouncementsDB", defaults)
end

function LFGAnnouncementsDBModule:OnEnable()
end

function LFGAnnouncementsDBModule:SetCharacterData(key, value, ...)
	local data = self._db.char
	for i = 1, select("#", ...) do
		data = data[select(i, ...)]
	end
	data[key] = value
end

function LFGAnnouncementsDBModule:GetCharacterData(...)
	local data = self._db.char
	for i = 1, select("#", ...) do
		data = data[select(i, ...)]
	end
	return data
end

function LFGAnnouncementsDBModule:SetProfileData(key, value, ...)
	local data = self._db.profile
	for i = 1, select("#", ...) do
		data = data[select(i, ...)]
	end
	data[key] = value
end

function LFGAnnouncementsDBModule:GetProfileData(...)
	local data = self._db.profile
	for i = 1, select("#", ...) do
		data = data[select(i, ...)]
	end

	return data
end

LFGAnnouncements.Core:RegisterModule("DB", LFGAnnouncementsDBModule)