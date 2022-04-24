local _, LFGAnnouncements = ...

-- Lua APIs
local stringformat = string.format

local function formatName(id)
	local dungeonsModule = LFGAnnouncements.Dungeons
	local levelRange = dungeonsModule:GetLevelRange(id)
	local name = dungeonsModule:GetDungeonName(id)

	return stringformat("%s (%d - %d)", name, levelRange[1], levelRange[2])
end

local function UpdateData(object, funcName, ...)
	object[funcName](object, ...)
	LFGAnnouncements.Core:UpdateInvalidEntries()
end

local function createEntry(id, order)
	return {
		type = "toggle",
		width = "full",
		order = order,
		name = formatName(id),
		get = function(info)
			return LFGAnnouncements.DB:GetCharacterData("dungeons", "activated", id)
		end,
		set = function(info, newValue)
			UpdateData(LFGAnnouncements.Dungeons, "SetActivated", id, newValue)
		end,
	}
end

local function createGroup(args, instances)
	local num = #instances
	for i = 1, num do
		local id = instances[i]
		args["instance_filter_" .. id] = createEntry(id, i)
	end

	args["enable_all"] = {
		type = "execute",
		name = "Enable All",
		width = "normal",
		order = num + 1,
		func = function()
			for i = 1, num do
				local id = instances[i]
				LFGAnnouncements.Dungeons:ActivateDungeon(id, false)
			end
		end,
	}
	args["disable_all"] = {
		type = "execute",
		name = "Disable All",
		width = "normal",
		order = num + 2,
		func = function()
			for i = 1, num do
				local id = instances[i]
				LFGAnnouncements.Dungeons:DeactivateDungeon(id, false)
			end
		end,
	}
end

local function createCustomFilters(args, customEntries)
	for id, name in pairs(customEntries.Names) do
		local group = {
			type = "group",
			name = name,
			order = 1,
			inline = true,
			args = {
					tags = {
						type = "input",
						name = "Tags",
						desc = "Custom tags separated by spaces",
						width = "double",
						order = 1,
						get = function()
							return strjoin(" ", unpack(customEntries.Tags[id]))
						end,
						set = function(info, newValue)
						end,
					},
					remove = {
						type = "execute",
						name = "Remove",
						width = "half",
						order = 2,
					}
			}
		}

		args[id] = group
	end

	args.new = {
		type = "group",
		name = "New",
		order = 2,
		inline = true,
		args = {
			name = {
				type = "input",
				name = "Name",
				width = "double",
				order = 1,
				get = function()
					return ""
				end,
				set = function(info, value)
				end,
			},
			button = {
				type = "execute",
				name = "Add",
				width = "half",
				order = 2,
			},
		}
	}
end

local function optionsTemplate()
	local dungeonsModule = LFGAnnouncements.Dungeons
	local db = LFGAnnouncements.DB
	local core = LFGAnnouncements.Core
	local vanilla_dungeons = {
		type = "group",
		name = "Vanilla Dungeons",
		order = 4,
		inline = false,
		args = {}
	}
	local tbc_dungeons = {
		type = "group",
		name = "TBC Dungeons",
		order = 5,
		inline = false,
		args = {}
	}
	local tbc_raids = {
		type = "group",
		name = "TBC Raids",
		order = 6,
		inline = false,
		args = {}
	}
	local custom_entries = {
		type = "group",
		name = "Custom",
		order = 7,
		inline = false,
		args = {},
	}

	local args = {
		header = {
			order = 1,
			type = "header",
			width = "full",
			name = "Filters",
		},
		difficulty_filter = {
			type = "select",
			width = "full",
			order = 2,
			name = "Filter on dungeon difficulty",
			values = db.dungeonDifficulties,
			get = function(info)
				return db:GetCharacterData("filters", "difficulty")
			end,
			set = function(info, newValue)
				UpdateData(core, "SetDifficultyFilter", newValue)
			end,
		},
		boost_filter = {
			type = "toggle",
			width = "full",
			order = 3,
			name = "Try filter boost requests",
			get = function(info)
				return db:GetCharacterData("filters", "boost")
			end,
			set = function(info, newValue)
				UpdateData(core, "SetBoostFilter", newValue)
			end,
		},
		vanilla_dungeons = vanilla_dungeons,
		tbc_dungeons = tbc_dungeons,
		tbc_raids = tbc_raids,
		custom_entries = custom_entries,
	}

	-- Vanilla Dungeons
	local instances = dungeonsModule:GetDungeons("VANILLA")
	createGroup(vanilla_dungeons.args, instances)

	-- TBC Dungeons
	instances = dungeonsModule:GetDungeons("TBC")
	createGroup(tbc_dungeons.args, instances)

	-- TBC Raids
	instances = dungeonsModule:GetRaids("TBC")
	createGroup(tbc_raids.args, instances)

	createCustomFilters(custom_entries.args, dungeonsModule:GetCustomEntries())

	return {
		type = "group",
		name = "Filters",
		order = 2,
		args = args
	}
end

LFGAnnouncements.Options.AddOptionTemplate("filters", optionsTemplate)