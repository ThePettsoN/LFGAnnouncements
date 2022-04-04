local _, LFGAnnouncements = ...

local function optionsTemplate()
	local dungeonsModule = LFGAnnouncements.Dungeons
	local db = LFGAnnouncements.DB
	local vanilla_dungeons = {
		type = "group",
		name = "Vanilla Dungeons",
		order = 2,
		inline = false,
		args = {}
	}
	local tbc_dungeons = {
		type = "group",
		name = "TBC Dungeons",
		order = 3,
		inline = false,
		args = {}
	}
	local tbc_raids = {
		type = "group",
		name = "TBC Raids",
		order = 4,
		inline = false,
		args = {}
	}

	local args = {
		header = {
			order = 1,
			type = "header",
			width = "full",
			name = "Filter",
		},
		vanilla_dungeons = vanilla_dungeons,
		tbc_dungeons = tbc_dungeons,
		tbc_raids = tbc_raids,
	}

	-- Vanilla Dungeons
	local dungeons = dungeonsModule:GetDungeons("VANILLA")
	for i = 1, #dungeons do
		local id = dungeons[i]
		local levelRange = dungeonsModule:GetLevelRange(id)
		vanilla_dungeons.args["dungeon_" .. id] = {
			type = "toggle",
			width = "full",
			order = i,
			name = string.format("%s (%d - %d)", dungeonsModule:GetDungeonName(id), levelRange[1], levelRange[2]),
			get = function(info)
				return db:GetCharacterData("dungeons", "activated", id)
			end,
			set = function(info, newValue)
				LFGAnnouncements.Dungeons:SetActivated(id, newValue)
			end,
		}
	end

	-- TBC Dungeons
	dungeons = dungeonsModule:GetDungeons("TBC")
	for i = 1, #dungeons do
		local id = dungeons[i]
		local levelRange = dungeonsModule:GetLevelRange(id)
		tbc_dungeons.args["dungeon_" .. id] = {
			type = "toggle",
			width = "full",
			order = i,
			name = string.format("%s (%d - %d)", dungeonsModule:GetDungeonName(id), levelRange[1], levelRange[2]),
			get = function(info)
				return db:GetCharacterData("dungeons", "activated", id)
			end,
			set = function(info, newValue)
				LFGAnnouncements.Dungeons:SetActivated(id, newValue)
			end,
		}
	end

	-- TBC Raids
	dungeons = dungeonsModule:GetRaids("TBC")
	for i = 1, #dungeons do
		local id = dungeons[i]
		local levelRange = dungeonsModule:GetLevelRange(id)
		tbc_raids.args["raid_" .. id] = {
			type = "toggle",
			width = "full",
			order = i,
			name = string.format("%s (%d - %d)", dungeonsModule:GetDungeonName(id), levelRange[1], levelRange[2]),
			get = function(info)
				return db:GetCharacterData("dungeons", "activated", id)
			end,
			set = function(info, newValue)
				LFGAnnouncements.Dungeons:SetActivated(id, newValue)
			end,
		}
	end

	return {
		type = "group",
		name = "Filter",
		order = 2,
		args = args
	}
end

LFGAnnouncements.Options.AddOptionTemplate("filter", optionsTemplate)