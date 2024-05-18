local _, LFGAnnouncements = ...

local ceil = ceil

local GetScreenWidth = GetScreenWidth
local GetScreenHeight = GetScreenHeight

local LSM = LibStub("LibSharedMedia-3.0")

local function getSounds()
	local sounds = {
		[3081] = "Default",
		[110981] = "VoiceChat - Join Channel",
		[39517] = "InGame Store - Purchase Delivered",
	}

	for name, _ in next, LSM:HashTable("sound") do
		sounds[name] = name
	end

	return sounds
end

local function optionsTemplate()
	local db = LFGAnnouncements.DB

	local args = {
		header = {
			order = 1,
			type = "header",
			width = "full",
			name = "Notifications",
		},

		sound = {
			type = "group",
			name = "Sound",
			order = 2,
			inline = true,
			args = {
				enabled = {
					type = "toggle",
					width = "full",
					order = 1,
					name = "Play sound on new requests",
					get = function(info)
						return db:GetProfileData("notifications", "sound", "enabled")
					end,
					set = function(info, newValue)
						db:SetProfileData("enabled", newValue, "notifications", "sound")
					end,
				},
				sound_id = {
					type = "select",
					width = "double",
					order = 2,
					name = "Sound To Play",
					values = getSounds(),
					get = function(info)
						return LFGAnnouncements.DB:GetProfileData("notifications", "sound", "id")
					end,
					set = function(info, newValue)
						local path = LSM:Fetch("sound", newValue)
						LFGAnnouncements.Notifications:SetSound(newValue, path)
					end,
				},
				play_sound = {
					type = "execute",
					width = "half",
					order = 3,
					name = "Play",
					func = function()
						LFGAnnouncements.Notifications:_triggerSound()
					end
				}
			}
		},

		toaster = {
			type = "group",
			name = "Toaster",
			order = 3,
			inline = true,
			args = {
				enabled = {
					type = "toggle",
					width = "full",
					order = 1,
					name = "Show a toast window on new requests",
					get = function(info)
						return db:GetProfileData("notifications", "toaster", "enabled")
					end,
					set = function(info, newValue)
						db:SetProfileData("enabled", newValue, "notifications", "toaster")
					end,
				},
				collapse_other = {
					type = "toggle",
					width = "full",
					order = 2,
					name = "Collapse other categories when opening request",
					get = function(info)
						return db:GetProfileData("notifications", "toaster", "collapse_other")
					end,
					set = function(info, newValue)
						LFGAnnouncements.Notifications:SetCollapseOther(newValue)
					end,
				},
				duration = {
					type = "range",
					width = "full",
					order = 3,
					name = "Duration, in seconds, the toaster should be visible",
					min = 1,
					max = 10,
					step = 1,
					get = function(info)
						return db:GetProfileData("notifications", "toaster", "duration")
					end,
					set = function(info, newValue)
						LFGAnnouncements.Notifications:SetToasterDuration(newValue)
					end
				},

				width = {
					type = "range",
					-- width = "full",
					order = 4,
					name = "Width",
					min = 1,
					max = ceil(GetScreenWidth()),
					step = 1,
					get = function(info)
						return db:GetProfileData("notifications", "toaster", "size", "width")
					end,
					set = function(info, newWidth)
						LFGAnnouncements.Notifications:SetToasterSize(newWidth, nil)
					end
				},
				height = {
					type = "range",
					-- width = "full",
					order = 5,
					name = "Height",
					min = 52,
					max = ceil(GetScreenHeight()),
					step = 1,
					get = function(info)
						return db:GetProfileData("notifications", "toaster", "size", "height")
					end,
					set = function(info, newHeight)
						LFGAnnouncements.Notifications:SetToasterSize(nil, newHeight)
					end
				},
				num_toasters = {
					type = "range",
					width = "full",
					order = 6,
					name = "Number of toasters that can be shown at once",
					min = 1,
					max = 10,
					step = 1,
					get = function(info)
						return db:GetProfileData("notifications", "toaster", "num_toasters")
					end,
					set = function(info, newValue)
						LFGAnnouncements.Notifications:SetNumToasters(newValue)
					end
				},
			}
		},

		flash_icon = {
			type = "group",
			name = "Flash Client Icon",
			order = 4,
			inline = true,
			args = {
				enabled = {
					type = "toggle",
					width = "full",
					order = 1,
					name = "Flash the client game icon on new requests",
					get = function(info)
						return db:GetProfileData("notifications", "flash", "enabled")
					end,
					set = function(info, newValue)
						db:SetProfileData("enabled", newValue, "notifications", "flash")
					end,
				},
			}
		},
		show_in_areas = {
			name = "Show notifications in areas",
			type = "multiselect",
			width = "full",
			order = 5,
			values = db.instanceTypes,
			get = function(info, key)
				return db:GetProfileData("notifications", "general", "enable_in_instance", key)
			end,
			set = function(info, key, newValue)
				LFGAnnouncements.Notifications:SetNotificationInInstance(key, newValue)
			end,
		},
	}

	return {
		type = "group",
		name = "Notifications",
		order = 1,
		args = args
	}
end

LFGAnnouncements.Options.AddOptionTemplate("notifications", optionsTemplate)
