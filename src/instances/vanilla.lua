local _, LFGAnnouncements = ...
local PUtils = LFGAnnouncements.PUtils
local GameUtils = PUtils.Game

-- Lua APIs
local wipe = wipe
local pairs = pairs
local max = max
local min = min

-- WoW APIs
local UnitLevel = UnitLevel
local tContains = tContains

local isSoD = GameUtils.IsSeasonOfDiscovery()

local Instances = {
	-- Dungeons
	{ "RFC", 798, },
	{ "WC", 796, },
	not GameUtils.CompareGameVersion(GameUtils.GameVersionLookup.CATACLYSM) and { "DM", 799, } or nil,
	not GameUtils.CompareGameVersion(GameUtils.GameVersionLookup.CATACLYSM) and { "SFK", 800, } or nil,
	{ "BFD", isSoD and 1604 or 801, },
	{ "STOCKS", 802, },
	{ "GNOMER", isSoD and 1605 or 803, },
	{ "RFK", 804},
	{ "SM_GY", 805, },
	{ "SM_LIB", 829, },
	{ "SM_ARM", 827, },
	{ "SM_CATH", 828, },
	{ "RFD", 806, },
	{ "ULDA", 807, },
	{ "ZF", 808, },
	{ "MARA", 809, },
	{ "ST", isSoD and 1606 or 810, },
	{ "BRD", 811, },
	{ "LBRS", 812, },
	{ "UBRS", 837, },
	{ "SCHOLO", 797, },
	{ "STRAT", 816, },
	{ "DIRE_MAUL_E", 813, },
	{ "DIRE_MAUL_N", 815, },
	{ "DIRE_MAUL_W", 814, },
	not GameUtils.CompareGameVersion(GameUtils.GameVersionLookup.CATACLYSM) and { "ZG", 836, } or nil,
	-- Raids
	{ "ONY", 838, },
	{ "MC", 839, },
	{ "BWL", 840, },
	{ "AQ20", 842, },
	{ "AQ40", 843, },
	not GameUtils.CompareGameVersion(GameUtils.GameVersionLookup.WOTLK) and { "NAXX", 841, } or nil,
}

local Tags = {
	RFC				= { "rfc", "ragefire", "chasm", },
	WC				= { "wc", "wailing", "caverns", },
	DM				= { "deadmines", "vc", "vancleef", "mine", "mines", },
	SFK				= { "sfk", "shadowfang", },
	BFD				= { "bfd", "fathom", "blackfathom", },
	STOCKS			= { "stk", "stock", "stockade", "stockades", "stocks" },
	GNOMER 			= { "gno", "gnom", "gnomeregan", "gnomeragan", "gnome", "gnomregan", "gnomragan", "gnomer" },
	RFK				= { "rfk", "kraul", },
	-- SM
	SM_GY			= { "smgy", "smg", "gy", "graveyard", },
	SM_LIB			= { "smlib", "sml", "lib", "library", },
	SM_ARM			= { "smarm", "sma", "arm", "armory", "herod", "armoury", "arms", },
	SM_CATH			= { "smcath", "smc", "cath", "cathedral", },
	RFD				= { "rfd", "downs", },
	ULDA			= { "uld", "ulda", "uldaman", "ulduman", "uldman", "uldama", "udaman", },
	ZF				= { "zf", "farrak", "zulfarrak", "zulfarak", "zulfa", "zulf", },
	MARA			= { "mar", "mara", "maraudon", "mauradon", "mauro", "maurodon", "princessrun", "maraudin", "maura", "marau", "mauraudon" },
	ST				= { "sunken", "atal", },
	BRD				= { "brd", "emp", "arenarun", "angerforge", "blackrockdepth", },
	LBRS			= { "lbrs", "lrbs", },
	UBRS			= { "ubrs", "urbs", "rend", },
	SCHOLO			= { "scholomance", "scholo", "sholo", "sholomance", },
	STRAT			= { "stratlive", "live", "living", "stratud", "undead", "ud", "baron", "stratholme", "stath", "stratholm", "strah", "strath", "strat", "starth" },
	-- DIRE_MAUL
	DIRE_MAUL_E		= { "dme", "dmeast", "dm:e", "east", "puzilin", "jumprun", },
	DIRE_MAUL_N		= { "dmn", "dmnorth", "dm:n", "north", "tribute", },
	DIRE_MAUL_W		= { "dmw", "dmwest", "dm:w", "west", },
	-- RAIDS
	ONY 			= { "ony", "onyxia", },
	ZG 				= { "zg", "gurub", "zulgurub", "zulg" },
	MC 				= { "mc", "molten", "core", "moltencore", },
	BWL 			= { "blackwing", "bwl", },
	AQ20 			= { "ruins", "aq20", "aq10", "aq 10", "aq 20", },
	AQ40 			= { "aq40", "aq 40", },
	NAXX 			= { "naxxramas", "nax", "naxx", "nax10", "naxx10", "nax25", "naxx25", "naxx 10", "nax 10", "naxx 25", "nax 25" },
}

local Levels = {
	-- Dungeons
	RFC				= { 13, 18, },
	WC				= { 15, 25, },
	BFD				= { 24, 32, },
	DM				= { 18, 23, },
	SFK				= { 22, 30, },
	STOCKS			= { 22, 30, },
	GNOMER			= { 29, 38, },
	RFK				= { 30, 40, },
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
	DIRE_MAUL_E		= { 58, 60, },
	DIRE_MAUL_N		= { 58, 60, },
	DIRE_MAUL_W		= { 58, 60, },
	-- Raids
	ONY 			= { 60, 60, },
	ZG 				= { 60, 60, },
	MC 				= { 60, 60, },
	BWL 			= { 60, 60, },
	AQ20 			= { 60, 60, },
	AQ40 			= { 60, 60, },
	NAXX 			= { 60, 60, },
}

if isSoD then
	Instances[#Instances + 1] = { "DFC", 1607, }
	Instances[#Instances + 1] = { "KZ_CRYPTS", -1, {
		categoryID = 2,
		shortName = "Karazhan Crypts",
		mapID = 16074
	}}
	Instances[#Instances + 1] = { "AZURE", 1608, }
	Instances[#Instances + 1] = { "KAZZAK", 1609, }
	Instances[#Instances + 1] = { "EMRLD_DRGN", 1610, }
	Instances[#Instances + 1] = { "THUNDERAAN", 1611, }

	Tags.DFC = { "demonfall", "dfc", "demon", "fall", "canyon", }
	Tags.KZ_CRYPTS = { "kara", "cara", "crypt", "crypts", "kc", }

	Tags.AZURE = { "azu", "azuregos", "azregos", }
	Tags.KAZZAK = { "kazzak", "kaz", }
	Tags.EMRLD_DRGN = { "grove", "nmg", "dragons", }
	Tags.THUNDERAAN = { "crystal", "vale", "thunderan", "thunderaan", }

	Levels.DFC = { 60, 60, }
	Levels.KZ_CRYPTS = { 60, 60, }
	Levels.AZURE = { 60, 60, }
	Levels.KAZZAK = { 60, 60, }
	Levels.EMRLD_DRGN = { 60, 60, }
	Levels.THUNDERAAN = { 60, 60, }
end

LFGAnnouncements.Instances.Register(GameUtils.GameVersionLookup.CLASSIC, Instances, Tags, Levels)

