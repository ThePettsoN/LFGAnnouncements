local _, LFGAnnouncements = ...

local LFGAnnouncementsDBModule = {}
local defaults = {
	profile = {
		minimap = {
			enanbled = true,
		},
		search_settings = {
			time_visible_sec = 120,
			channels = {},
			new_on_top = true,
		},
	},
	char = {
		first_time = true,
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
	self.data = LibStub("AceDB-3.0"):New("LFGAnnouncementsDB", defaults)
end

function LFGAnnouncementsDBModule:OnEnable()
end

LFGAnnouncements.Core:RegisterModule("DB", LFGAnnouncementsDBModule)