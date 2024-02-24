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
			},
			format = {
				remove_raid_markers = false,
				show_total_time = false,
				show_level_range = true,
			},
			enable_in_instance = {
				world = true,
				party = true,
				raid = true,
				arena = true,
				pvp = true,
			},
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
				enabled = false,
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
				enabled = false,
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
			gkpd = false,
			level_range = false,
			fake_amount = 50,
		}
	}
}

function LFGAnnouncementsDBModule:OnInitialize()
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
