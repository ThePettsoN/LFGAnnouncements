local _, LFGAnnouncements = ...

local LSM = LibStub("LibSharedMedia-3.0")

local function getFonts()
	local fonts = {}
	for name, path in next, LSM:HashTable("font") do
		fonts[path] = name
	end

	return fonts
end

local function fontGroup(order, db)
	return {
		type = "group",
		name = "Font",
		order = order,
		inline = true,
		args = {
			
		}
	}
end

local function formatGroup(order, db)
	return {
		type = "group",
		name = "Messages Formatting",
		order = order,
		inline = true,
		args = {
			name = {
				type = "select",
				order = 1,
				name = "Font",
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
				name = "Size",
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
			raid_marker_filter= {
				type = "toggle",
				width = "full",
				order = 3,
				name = "Remove raid markers from messages",
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
				name = "Show total time instead of time since last request",
				get = function(info)
					return db:GetProfileData("general", "format", "show_total_time")
				end,
				set = function(info, newValue)
					LFGAnnouncements.UI:ShowTotalTime(newValue)
				end,
			},
		}
	}
end

local function minimapGroup(order, db)
	return {
		type = "group",
		name = "Minimap",
		order = order,
		inline = true,
		args = {
			visible = {
				type = "toggle",
				width = "full",
				order = 1,
				name = "Show minimap button",
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
				name = "Lock minimap button",
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
			name = "General",
		},

		duration = {
			type = "range",
			width = "full",
			order = 2,
			name = "Duration, in seconds, each request should be visible",
			min = 1,
			max = 300,
			step = 1,
			get = function(info)
				return db:GetProfileData("general", "time_visible_sec")
			end,
			set = function(info, newValue)
				LFGAnnouncements.Core:SetDuration(newValue)
			end
		},

		enable_in_areas = {
			name = "Enable addon in areas",
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

		-- font = fontGroup(4, db),
		format = formatGroup(4, db),
		minimap = minimapGroup(5, db),
	}

	return {
		type = "group",
		name = "General",
		order = 1,
		args = args
	}
end

LFGAnnouncements.Options.AddOptionTemplate("general", optionsTemplate)