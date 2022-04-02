local _, LFGAnnouncements = ...

LFGAnnouncementsDBModule = {}
test = nil
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
	-- LFGAnnouncements.DB = self
	self.test = LibStub("AceDB-3.0"):New("LFGAnnouncementsDB", defaults)
	test = self
end

function LFGAnnouncementsDBModule:OnEnable()
end

LFGAnnouncements.Core:RegisterModule("DB", LFGAnnouncementsDBModule)