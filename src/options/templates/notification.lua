local _, LFGAnnouncements = ...

local LSM = LibStub("LibSharedMedia-3.0"); -- TODO: Include in project

local function getSounds()
	local sounds = {
		[3081] = "Default",
		[110981] = "VoiceChat - Join Channel",
		[39517] = "InGame Store - Purchase Delivered",
	}
	for name, path in next, LSM:HashTable("sound") do
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
			name = "Notification",
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
					name = "Play sound on new request",
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
						LFGAnnouncements.Notifications:_playSound()
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
					name = "Show a toast window on new request",
					get = function(info)
						return db:GetProfileData("notifications", "toaster", "enabled")
					end,
					set = function(info, newValue)
						db:SetProfileData("enabled", newValue, "notifications", "toaster")
					end,
				},
			}
		},

		show_in_areas = {
			name = "Show notifications in areas",
			type = "multiselect",
			width = "full",
			order = 4,
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
		name = "Notification",
		order = 1,
		args = args
	}
end

LFGAnnouncements.Options.AddOptionTemplate("notification", optionsTemplate)