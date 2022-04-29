local _, LFGAnnouncements = ...
local LFGAnnouncementsInstances = {}

-- Lua APIs
local wipe = wipe
local pairs = pairs
local max = max
local min = min

-- WoW APIs
local UnitLevel = UnitLevel
local tContains = tContains

-- Vanilla
local VanillaDungeons = {
	Order = {
		"RFC",
		"WC",
		"DM",
		"SFK",
		"STOCKS",
		"BFD",
		"GNOMER",
		"RFK",
		-- "SM",
		"SM_GY",
		"SM_LIB",
		"SM_ARM",
		"SM_CATH",
		"RFD",
		"ULDA",
		"ZF",
		"MARA",
		"ST",
		"BRD",
		"LBRS",
		"UBRS",
		"SCHOLO",
		"STRAT",
		-- "DIRE_MAUL",
		"DIRE_MAUL_E",
		"DIRE_MAUL_N",
		"DIRE_MAUL_W",
	},
	Names = {
		RFC 			= "Ragefire Chasm",
		WC 				= "Wailing Caverns",
		DM 				= "The Deadmines",
		SFK 			= "Shadowfang Keep",
		STOCKS 			= "The Stockade",
		BFD 			= "Blackfathom Deeps",
		GNOMER 			= "Gnomeregan",
		RFK 			= "Razorfen Kraul",
		-- SM 				= "Scarlet Monastery: Graveyard",
		SM_GY 			= "Scarlet Monastery: Graveyard",
		SM_LIB 			= "Scarlet Monastery: Library",
		SM_ARM 			= "Scarlet Monastery: Armory",
		SM_CATH 		= "Scarlet Monastery: Cathedral",
		RFD 			= "Razorfen Downs",
		ULDA 			= "Uldaman",
		ZF 				= "Zul'Farrak",
		MARA 			= "Maraudon",
		ST 				= "The Temple of Atal'Hakkar",
		BRD 			= "Blackrock Depths",
		LBRS 			= "Lower Blackrock Spire",
		UBRS 			= "Upper Blackrock Spire",
		SCHOLO 			= "Scholomance",
		STRAT 			= "Stratholme",
		-- DIRE_MAUL 		= "Dire Maul",
		DIRE_MAUL_E 	= "Dire Maul: East",
		DIRE_MAUL_N 	= "Dire Maul: North",
		DIRE_MAUL_W 	= "Dire Maul: West",
	},
	Levels = {
		RFC				= { 13, 18, },
		WC				= { 15, 25, },
		DM				= { 18, 23, },
		SFK				= { 22, 30, },
		STOCKS			= { 22, 30, },
		BFD				= { 24, 32, },
		GNOMER			= { 29, 38, },
		RFK				= { 30, 40, },
		-- SM 				= { 28, 45, },
		SM_GY			= { 28, 38, },
		SM_LIB			= { 29, 39, },
		SM_ARM			= { 32, 42, },
		SM_CATH			= { 35, 45, },
		RFD				= { 40, 50, },
		ULDA			= { 42, 52, },
		ZF				= { 44, 54, },
		MARA			= { 46, 55, },
		ST				= { 50, 60, },
		BRD				= { 52, 60, },
		LBRS			= { 55, 60, },
		UBRS			= { 58, 60, },
		SCHOLO			= { 58, 60, },
		STRAT			= { 58, 60, },
		-- DIRE_MAUL		= { 58, 60, },
		DIRE_MAUL_E		= { 58, 60, },
		DIRE_MAUL_N		= { 58, 60, },
		DIRE_MAUL_W		= { 58, 60, },
	},
	Tags = {
		RFC				= { "rfc", "ragefire", "chasm", },
		WC				= { "wc", "wailing", "caverns", },
		DM				= { "deadmines", "vc", "vancleef", "mine", "mines", },
		SFK				= { "sfk", "shadowfang", },
		STOCKS			= { "stk", "stock", "stockade", "stockades" },
		BFD				= { "bfd", "fathom", "blackfathom", },
		GNOMER			= { "gno", "gnom", "gnomeregan", "gnomeragan", "gnome", "gnomregan", "gnomragan" },
		RFK				= { "rfk", "kraul", },
		-- SM 				= { "sm", "scarlet", "mona", "monastery", },
		SM_GY			= { "smgy", "smg", "gy", "graveyard", },
		SM_LIB			= { "smlib", "sml", "lib", "library", },
		SM_ARM			= { "smarm", "sma", "arm", "armory", "herod", "armoury", "arms", },
		SM_CATH			= { "smcath", "smc", "cath", "cathedral", },
		RFD				= { "rfd", "downs", },
		ULDA			= { "uld", "ulda", "uldaman", "ulduman", "uldman", "uldama", "udaman", },
		ZF				= { "zf", "zul", "farrak", "zul'farrak", "zulfarrak", "zulfarak", "zul´farrak", "zul`farrak", "zulfa", "zulf", },
		MARA			= { "mar", "mara", "maraudon", "mauradon", "mauro", "maurodon", "princessrun", "maraudin", "maura", "marau", "mauraudon" },
		ST				= { "sunken", "atal", },
		BRD				= { "brd", "emp", "arenarun", "angerforge", "blackrockdepth", },
		LBRS			= { "lbrs", "lrbs", },
		UBRS			= { "ubrs", "urbs", "rend", },
		SCHOLO			= { "scholomance", "scholo", "sholo", "sholomance", },
		STRAT			= { "stratlive", "live", "living", "stratUD", "undead", "ud", "baron", "stratholme", "stath", "stratholm", "strah", "strath", "strat", "starth" },
		-- DIRE_MAUL		= { "dire", "maul", "diremaul", },
		DIRE_MAUL_E		= { "dme", "dmeast", "east", "puzilin", "jumprun", },
		DIRE_MAUL_N		= { "dmn", "dmnorth", "north", "tribute", },
		DIRE_MAUL_W		= { "dmw", "dmwest", "west", },
	}
}

-- TBC
local BurningCrusadeDungeons = {
	Order = {
		"RAMP",
		"BF",
		"SHH",
		"SP",
		"UB",
		"SV",
		"MT",
		"AC",
		"SETH",
		"SL",
		"OHB",
		"BM",
		"BOT",
		"MECHA",
		"ARCA",
		"MGT",
	},
	Names = {
		RAMP 	= "Hellfire Citadel: Hellfire Ramparts",
		BF 		= "Hellfire Citadel: The Blood Furnace",
		SHH 	= "Hellfire Citadel: The Shattered Halls",
		SP 		= "Coilfang Reservoir: The Slave Pens",
		UB 		= "Coilfang Reservoir: The Underbog",
		SV 		= "Coilfang Reservoir: The Steamvault",
		MT 		= "Auchindoun: Mana-Tombs",
		AC 		= "Auchindoun: Auchenai Crypts",
		SETH	= "Auchindoun: Sethekk Halls",
		SL 		= "Auchindoun: Shadow Labyrinth",
		OHB 	= "Caverns of Time: Old Hillsbrad Foothills",
		BM 		= "Caverns of Time: The Black Morass",
		BOT 	= "Tempest Keep: The Botanica",
		MECHA 	= "Tempest Keep: The Mechanar",
		ARCA 	= "Tempest Keep: The Arcatraz",
		MGT 	= "Magisters' Terrace",
	},
	Levels = {
		RAMP 	= { 60, 62, },
		BF 		= { 61, 63, },
		SHH 	= { 69, 70, },
		SP 		= { 62, 64, },
		UB 		= { 63, 65, },
		SV 		= { 68, 70, },
		MT 		= { 64, 66, },
		AC 		= { 65, 67, },
		SETH	= { 67, 69, },
		SL 		= { 69, 70, },
		OHB 	= { 66, 68, },
		BM 		= { 70, 70, },
		BOT 	= { 70, 70, },
		MECHA 	= { 70, 70, },
		ARCA 	= { 70, 70, },
		MGT 	= { 70, 70, },
	},
	Tags = {
		RAMP 	= { "ramparts", "rampart", "ramp", "ramps", },
		BF 		= { "furnace", "furn", "bf", },
		SHH 	= { "sh", "shattered", "shatered", "shaterred", "shh", },
		SP 		= { "slavepens", "slave", "pens", "sp", },
		UB 		= { "underbog", "ub", },
		SV 		= { "sv", "steamvault", "steamvaults", "steam", "vault", "valts", },
		MT 		= { "manatombs", "mana", "mt", "tomb", "tombs", },
		AC 		= { "crypts", "crypt", "auchenai", "ac", "acrypts", "acrypt", },
		SETH	= { "ethekk", "seth", "sethek", },
		SL 		= { "sl", "slab", "labyrinth", "lab", "shadowlabs", },
		OHB 	= { "ohb", "oh", "ohf", "durnholde", "hillsbrad", "escape", },
		BM 		= { "morass", "bm", "moras", },
		BOT 	= { "botanica", "bot", },
		MECHA 	= { "mech", "mecha", "mechanar", },
		ARCA 	= { "arc", "arcatraz", "alcatraz", },
		MGT 	= { "mgt", "mrt", "terrace", "magisters", "magister", },
	},
}

local BurningCrusadeRaids = {
	Order = {
		"KZ",
		"GRUUL",
		"MAG",
		"SSC",
		"TK",
		"MH",
		"BT",
		"ZA",
		"SWP",
	},
	Names = {
		KZ = "Karazhan",
		GRUUL = "Gruul's Lair",
		MAG = "Magtheridon's Lair",
		SSC = "Coilfang Reservoir: Serpentshrine Cavern",
		TK = "Tempest Keep: The Eye",
		MH = "The Battle for Mount Hyjal",
		BT = "Black Temple",
		ZA = "Zul'Aman",
		SWP = "Sunwell Plateau",
	},
	Levels = {
		KZ = { 70, 70, },
		GRUUL = { 70, 70, },
		MAG = { 70, 70, },
		SSC = { 70, 70, },
		TK = { 70, 70, },
		MH = { 70, 70, },
		BT = { 70, 70, },
		ZA = { 70, 70, },
		SWP = { 70, 70, },
	},
	Tags = {
		KZ = { "karazhan", "kz", "kara", },
		GRUUL = { "gruul", "gruuls", "gruul's", },
		MAG = { "mag", "mahtheridon", "magtheridon's", "magth", },
		SSC = { "ssc", "serpentshrin", "serpentshine", },
		TK = { "tk", "tempest", "eye", },
		MH = { "mh", "hyjal", "hyj", },
		BT = { "bt", "temple", },
		ZA = { "za", "zul'aman", "zulaman", "aman", "z'a", },
		SWP = { "swp", "sunwell", "plateau", "sunwel", "plataeu", },
	}
}

local CustomInstances = {
	Order = {},
	Names = {},
	Levels = {},
	Tags = {},
}

local Dungeons = {}

local utils = LFGAnnouncements.Utils
utils.tMergeRecursive(Dungeons, VanillaDungeons)
utils.tMergeRecursive(Dungeons, BurningCrusadeDungeons)

local Raids = BurningCrusadeRaids

local Instances = {}
utils.tMergeRecursive(Instances, Dungeons)
utils.tMergeRecursive(Instances, Raids)

local InstanceType = {
	DUNGEON = "DUNGEON",
	RAID = "RAID",
	CUSTOM = "CUSTOM",
}
LFGAnnouncementsInstances.InstanceType = InstanceType

function LFGAnnouncementsInstances:OnInitialize()
	self._activatedInstances = {}
	self._activeTags = {}

	LFGAnnouncements.Instances = self
end

local customLevelRange = {0, 70}
local function addCustom(tbl, id, name, tags)
	tbl.Order[#tbl.Order+1] = id
	tbl.Names[id] = name
	tbl.Levels[id] = customLevelRange
	tbl.Tags[id] = tags
end

local function removeCustom(tbl, id)
	for i = 1, #tbl.Order do
		if tbl.Order[i] == id then
			tremove(tbl.Order, i)
			break
		end
	end
	tbl.Names[id] = nil
	tbl.Levels[id] = nil
	tbl.Tags[id] = nil
end

function LFGAnnouncementsInstances:OnEnable()
	local db = LFGAnnouncements.DB
	local initialized = db:GetCharacterData("initialized")

	if not initialized then
		local playerLevel = UnitLevel("player")
		local instancesPerLevel = self:GetInstancesByLevel(playerLevel)
		for i = 1, #instancesPerLevel do
			self:ActivateInstance(instancesPerLevel[i])
		end

		db:SetCharacterData("initialized", true)
	else
		local activatedInstances = db:GetCharacterData("dungeons", "activated")
		for key, activated in pairs(activatedInstances) do
			if Instances.Names[key] then
				if activated then
					self:ActivateInstance(key)
				end
			else
				db:SetCharacterData(key, false, "dungeons", "activated")
			end
		end

		local customInstances = db:GetCharacterData("dungeons", "custom_instances")
		for id, entry in pairs(customInstances) do
			addCustom(CustomInstances, id, entry.name, entry.tags)
			addCustom(Instances, id, entry.name, entry.tags)
		end
	end
end

function LFGAnnouncementsInstances:GetActivatedInstances()
	return self._activatedInstances
end

local random = math.random
local function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

function LFGAnnouncementsInstances:AddCustomInstance(name)
	local id = uuid()
	local tags = {}
	LFGAnnouncements.DB:SetCharacterData(id, {name = name, tags = tags, activated = true}, "dungeons", "custom_instances")

	addCustom(CustomInstances, id, name, tags)
	addCustom(Instances, id, name, tags)
end

function LFGAnnouncementsInstances:RemoveCustomInstance(id)
	LFGAnnouncements.DB:SetCharacterData(id, nil, "dungeons", "custom_instances")
	removeCustom(CustomInstances, id)
	removeCustom(Instances, id)
end

function LFGAnnouncementsInstances:SetCustomTags(id, tags)
	LFGAnnouncements.DB:SetCharacterData("tags", tags, "dungeons", "custom_instances", id)
	CustomInstances.Tags[id] = tags
	Instances.Tags[id] = tags
end

function LFGAnnouncementsInstances:ActivateInstance(id)
	if self._activatedInstances[id] then
		return
	end

	self._activatedInstances[id] = true
	LFGAnnouncements.DB:SetCharacterData(id, true, "dungeons", "activated")

	local tags = Instances.Tags[id]
	for i = 1, #tags do
		self._activeTags[tags[i]] = id
	end

	self:SendMessage("OnInstanceActivated", id)
end

function LFGAnnouncementsInstances:DeactivateInstance(id)
	if not self._activatedInstances[id] then
		return
	end

	self._activatedInstances[id] = nil
	LFGAnnouncements.DB:SetCharacterData(id, false, "dungeons", "activated")

	local activeTags = self._activeTags
	for key, value in pairs(activeTags) do
		if value == id then
			self._activeTags[key] = nil
		end
	end

	self:SendMessage("OnInstanceDeactivated", id)
end

function LFGAnnouncementsInstances:IsValid(instanceId)
	return Instances.Names[instanceId] ~= nil
end

function LFGAnnouncementsInstances:IsActive(instanceId)
	return self._activatedInstances[instanceId] ~= nil
end

function LFGAnnouncementsInstances:ActivateAll()
	for id, _ in pairs(Instances.Names) do
		self:ActivateInstance(id)
	end
end

function LFGAnnouncementsInstances:DisableAll()
	for id, _ in pairs(Instances.Names) do
		self:DeactivateInstance(id)
	end
end

function LFGAnnouncementsInstances:GetInstanceName(id)
	return Instances.Names[id]
end

function LFGAnnouncementsInstances:GetLevelRange(id)
	return Instances.Levels[id]
end

local instancesFound = {}
function LFGAnnouncementsInstances:GetInstancesByLevel(level)
	local maxLevel = LFGAnnouncements.GameExpansion == "TBC" and 70 or 60
	wipe(instancesFound)

	local minDiff, maxDiff
	if level == maxLevel then
		minDiff = level - 10
		maxDiff = level
	else
		minDiff = max(level - 5, 0)
		maxDiff = min(level + 5, maxLevel)
	end

	for id, range in pairs(Instances.Levels) do
		if range[1] >= minDiff and range[2] <= maxDiff then
			instancesFound[#instancesFound+1] = id
		end
	end

	return instancesFound
end

function LFGAnnouncementsInstances:GetDungeons(expansion)
	wipe(instancesFound)
	if expansion == "VANILLA" then
		return VanillaDungeons.Order
	end

	return BurningCrusadeDungeons.Order
end

function LFGAnnouncementsInstances:GetRaids(expansion)
	return BurningCrusadeRaids.Order
end

function LFGAnnouncementsInstances:GetCustomInstances()
	return CustomInstances
end

function LFGAnnouncementsInstances:GetInstanceType(instanceId)
	if CustomInstances.Names[instanceId] then
		return InstanceType.CUSTOM
	end

	if Instances.Names[instanceId] ~= nil then
		return InstanceType.DUNGEON
	end

	return InstanceType.RAID
end

function LFGAnnouncementsInstances:FindInstances(splitMessage)
	wipe(instancesFound)

	local found = false
	local customTags = CustomInstances.Tags
	for i = 1, #splitMessage do
		local word = splitMessage[i]
		local id = self._activeTags[word]
		if id then
			found = true
			instancesFound[id] = true
		end

		for id, tags in pairs(customTags) do
			if tContains(tags, word) then --TODO: Create lookup table instead?
				found = true
				instancesFound[id] = true
			end
		end
	end

	return found and instancesFound
end

LFGAnnouncements.Core:RegisterModule("Instances", LFGAnnouncementsInstances, "AceEvent-3.0")