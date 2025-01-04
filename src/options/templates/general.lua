local _, LFGAnnouncements = ...

local LSM = LibStub("LibSharedMedia-3.0")
local L = LFGAnnouncements.Localize

local function getFonts()
	local fonts = {}
	for name, path in next, LSM:HashTable("font") do
		fonts[path] = name
	end

	return fonts
end

local function formatGroup(order, db)
	return {
		type = "group",
		name = L("options_general_msg_formatting_header"),
		order = order,
		inline = true,
		args = {
			name = {
				type = "select",
				order = 1,
				name = L("options_general_msg_formatting_font_name"),
				values = getFonts(),
				get = function(info)
					return LFGAnnouncements.DB:GetProfileData("general", "font", "path")
				end,
				set = function(info, newFont)
					LFGAnnouncements.UI:SetFont(newFont, nil, nil)
					LFGAnnouncements.Notifications:SetFont(newFont, nil, nil)
				end,
			},
			size = {
				type = "range",
				order = 2,
				name = L("options_general_msg_formatting_size_name"),
				min = 8,
				max = 64,
				step = 1,
				get = function(info)
					return db:GetProfileData("general", "font", "size")
				end,
				set = function(info, newSize)
					LFGAnnouncements.UI:SetFont(nil, newSize, nil)
					LFGAnnouncements.Notifications:SetFont(nil, newSize, nil)
				end
			},
			raid_marker_filter = {
				type = "toggle",
				width = "full",
				order = 3,
				name = L("options_general_msg_formatting_raid_marker_filter_name"),
				get = function(info)
					return db:GetProfileData("general", "format", "remove_raid_markers")
				end,
				set = function(info, newValue)
					LFGAnnouncements.Core:SetRaidMarkersFilter(newValue)
				end,
			},
			show_total_time = {
				type = "toggle",
				width = "full",
				order = 4,
				name = L("options_general_msg_formatting_show_total_time_name"),
				get = function(info)
					return db:GetProfileData("general", "format", "show_total_time")
				end,
				set = function(info, newValue)
					LFGAnnouncements.UI:ShowTotalTime(newValue)
				end,
			},
			show_level_range = {
				type = "toggle",
				width = "full",
				order = 5,
				name = L("options_general_msg_formatting_show_level_range_name"),
				get = function(info)
					return db:GetProfileData("general", "format", "show_level_range")
				end,
				set = function(info, newValue)
					LFGAnnouncements.UI:ShowLevelRange(newValue)
				end,
			},
		}
	}
end

local function minimapGroup(order, db)
	return {
		type = "group",
		name = L("options_general_minimap_header"),
		order = order,
		inline = true,
		args = {
			visible = {
				type = "toggle",
				width = "full",
				order = 1,
				name = L("options_general_minimap_visible_name"),
				get = function(info)
					return not db:GetProfileData("minimap", "hide")
				end,
				set = function(info, newValue)
					db:SetProfileData("hide", not newValue, "minimap")
					LFGAnnouncements.MinimapButton:SetVisibility(newValue)
				end,
			},
			locked = {
				type = "toggle",
				width = "full",
				order = 2,
				name = L("options_general_minimap_locked_name"),
				get = function(info)
					return db:GetProfileData("minimap", "lock")
				end,
				set = function(info, newValue)
					db:SetProfileData("lock", newValue, "minimap")
					LFGAnnouncements.MinimapButton:SetPositionLocked(newValue)
				end,
			},
		}
	}
end

local function optionsTemplate()
	local db = LFGAnnouncements.DB
	local args = {
		header = {
			order = 1,
			type = "header",
			width = "full",
			name = L("options_general_header"),
		},

		duration = {
			type = "range",
			width = "full",
			order = 2,
			name = L("options_general_duration_name"),
			min = 1,
			max = 3600,
			step = 1,
			get = function(info)
				return db:GetProfileData("general", "time_visible_sec")
			end,
			set = function(info, newValue)
				LFGAnnouncements.Core:SetDuration(newValue)
			end
		},

		enable_in_areas = {
			name = L("options_general_enable_in_areas_header"),
			type = "multiselect",
			width = "full",
			order = 3,
			values = db.instanceTypes,
			get = function(info, key)
				return db:GetProfileData("general", "enable_in_instance", key)
			end,
			set = function(info, key, newValue)
				LFGAnnouncements.Core:SetEnabledInInstance(key, newValue)
			end,
		},

		format = formatGroup(4, db),
		minimap = minimapGroup(5, db),
	}

	return {
		type = "group",
		name = L("options_general_header"),
		order = 1,
		args = args
	}
end

LFGAnnouncements.Options.AddOptionTemplate("general", optionsTemplate)