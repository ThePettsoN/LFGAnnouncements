local _, LFGAnnouncements = ...
local L = LFGAnnouncements.Localize

local ceil = ceil

local GetScreenWidth = GetScreenWidth
local GetScreenHeight = GetScreenHeight

local LSM = LibStub("LibSharedMedia-3.0")

local function getSounds()
	local sounds = {
		[3081] = L("options_notifications_sound_default"),
		[110981] = L("options_notifications_sound_voice_chat_join_channel"),
		[39517] = L("options_notifications_sound_ingame_store_purchase_delivered"),
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
			name = L("options_notifications_header"),
		},

		existing_requests = {
			type = "group",
			name = "Existing Requests",
			order = 2,
			inline = true,
			args = {
				notify_existing_requests = {
					type = "toggle",
					width = "full",
					order = 1,
					name = "Show notifications on existing requests",
					get = function(info)
						return db:GetProfileData("notifications", "existing_requests", "enabled")
					end,
					set = function(info, newValue)
						LFGAnnouncements.Notifications:SetExistingRequestsEnabled(newValue)
					end,
				},
		
				time_before_notifying_existing_requests = {
					type = "range",
					width = "full",
					order = 2,
					name = "Time before notifications should show for existing requests",
					min = 0,
					max = 60,
					step = 1,
					get = function(info)
						return db:GetProfileData("notifications", "existing_requests", "wait_duration")
					end,
					set = function(info, newValue)
						LFGAnnouncements.Notifications:SetExistingRequestsWaitDuration(newValue)
					end
				},
			}
		},

		sound = {
			type = "group",
			name = L("options_notifications_sound_header"),
			order = 3,
			inline = true,
			args = {
				enabled = {
					type = "toggle",
					width = "full",
					order = 1,
					name = L("options_notifications_sound_enabled_name"),
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
					name = L("options_notifications_sound_sound_id_name"),
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
					name = L("options_notifications_sound_play_sound_name"),
					func = function()
						LFGAnnouncements.Notifications:_triggerSound()
					end
				}
			}
		},

		toaster = {
			type = "group",
			name = L("options_notifications_toaster_header"),
			order = 4,
			inline = true,
			args = {
				enabled = {
					type = "toggle",
					width = "full",
					order = 1,
					name = L("options_notifications_toaster_enabled_name"),
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
					name = L("options_notifications_toaster_collapse_other_name"),
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
					name = L("options_notifications_toaster_duration_name"),
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
					name = L("options_notifications_toaster_width_name"),
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
					name = L("options_notifications_toaster_height_name"),
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
					name = L("options_notifications_toaster_num_toasters_name"),
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
			name = L("options_notifications_flash_icon_header"),
			order = 5,
			inline = true,
			args = {
				enabled = {
					type = "toggle",
					width = "full",
					order = 1,
					name = L("options_notifications_flash_icon_enabled_name"),
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
			name = L("options_notifications_show_in_areas_header"),
			type = "multiselect",
			width = "full",
			order = 6,
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
		name = L("options_notifications_header"),
		order = 1,
		args = args
	}
end

LFGAnnouncements.Options.AddOptionTemplate("notifications", optionsTemplate)
