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
		minimap_visible = {
			type = "toggle",
			width = "full",
			name = "Show minimap button",
			get = function(info)
				return not db:GetProfileData("minimap", "hide")
			end,
			set = function(info, newValue)
				db:SetProfileData("hide", not newValue, "minimap")
				LFGAnnouncements.MinimapButton:SetVisibility(newValue)
			end,
		},
		minimap_locked = {
			type = "toggle",
			width = "full",
			name = "Lock minimap button",
			get = function(info)
				return db:GetProfileData("minimap", "lock")
			end,
			set = function(info, newValue)
				db:SetProfileData("lock", newValue, "minimap")
				LFGAnnouncements.MinimapButton:SetPositionLocked(newValue)
			end,
		}
	}

	return {
		type = "group",
		name = "General",
		order = 1,
		args = args
	}
end

LFGAnnouncements.Options.AddOptionTemplate("general", optionsTemplate)