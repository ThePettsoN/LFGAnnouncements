local _, LFGAnnouncements = ...

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

		minimap = {
			type = "group",
			name = "Minimap",
			order = 3,
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
		},
	}

	return {
		type = "group",
		name = "General",
		order = 1,
		args = args
	}
end

LFGAnnouncements.Options.AddOptionTemplate("general", optionsTemplate)