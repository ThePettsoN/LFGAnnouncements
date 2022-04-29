local _, LFGAnnouncements = ...

-- Lua APIs
local select = select

local LFGAnnouncementsDBModule = {}
local defaults = {
	profile = {
		general = {
			time_visible_sec = 120,
			channels = {},
			new_on_top = false,
			position = {
				x = 0,
				y = 0,
				stored = false,
			},
			font = {
				path = "Fonts\\FRIZQT__.TTF",
				size = 12,
				flags = "",
			}
		},
		minimap = {
			hide = false,
			lock = false,
		},
		notifications = {
			general = {
				enable_in_instance = {
					world = true,
					party = false,
					raid = false,
					arena = false,
					pvp = false,
				},
			},
			toaster = {
				enabled = true,
				duration = 1,
				position = {
					x = 0,
					y = 0,
					stored = false,
				},
				size = {
					width = 300,
					height = 52,
				}
			},
			sound = {
				enabled = true,
				id = 3081,
				path = "",
			},
			chat = {
				enabled = false,
				channel = 1,
			},
			flash = {
				enabled = false,
			},
		},
	},
	char = {
		initialized = false,
		dungeons = {
			activated = {},
			custom_instances = {},
		},
		filters = {
			difficulty = "ALL",
			boost = false,
			level_range = false,
		}
	}
}

function LFGAnnouncementsDBModule:OnInitialize()
	LFGAnnouncements.DB = self
	self._db = LibStub("AceDB-3.0"):New("LFGAnnouncementsDB", defaults)
	self.dungeonDifficulties = {
		ALL = "Show all",
		NORMAL = "Normal Only",
		HEROIC = "Heroic Only",
	}

	self.instanceTypes = {
		world = "World",
		party = "Dungeons",
		raid = "Raids",
		arena = "Arenas",
		pvp = "Battlegrounds",
	}
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