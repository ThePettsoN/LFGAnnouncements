local _, LFGAnnouncements = ...
Utils = LFGAnnouncements.Utils

-- Lua APIs
local wipe = wipe
local pairs = pairs
local max = max
local min = min

-- WoW APIs
local UnitLevel = UnitLevel
local tContains = tContains

-- Vanilla
local Dungeons = {
	Order = {
		"RFC",
		"WC",
		"DM",
		"SFK",
		"STOCKS",
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
		RFK 			= "Razorfen Kraul",
		-- SM
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
		RFK				= { 30, 40, },
		-- SM
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
		-- DIRE_MAUL
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
		DIRE_MAUL_E		= { "dme", "dmeast", "east", "puzilin", "jumprun", },
		DIRE_MAUL_N		= { "dmn", "dmnorth", "north", "tribute", },
		DIRE_MAUL_W		= { "dmw", "dmwest", "west", },
	}
}

local Raids = {
	Order = {
	},
	Names = {
	},
	Levels = {
	},
	Tags = {
	}
}

if Utils.game.compareGameVersion(Utils.game.GameVersionLookup.SeasonOfDiscovery) then
	-- BFD
	Raids.Order[#Raids.Order + 1] = "BFD"
	Raids.Names.BFD = "Blackfathom Deeps"
	Raids.Levels.BFD = { 25, 35, }
	Raids.Tags.BFD = { "bfd", "fathom", "blackfathom", }

	-- Gnomeregan
	Raids.Order[#Raids.Order + 1] = "GNOMER"
	Raids.Names.GNOMER = "Gnomeregan"
	Raids.Levels.GNOMER = { 40, 40, }
	Raids.Tags.GNOMER = { "gno", "gnom", "gnomeregan", "gnomeragan", "gnome", "gnomregan", "gnomragan", "gnomer" }

else
	table.insert(Dungeons.Order, 6, "BFD")
	Dungeons.Names.BFD = "Blackfathom Deeps"
	Dungeons.Levels.BFD = { 24, 32, }
	Dungeons.Tags.BFD = { "bfd", "fathom", "blackfathom", }

	table.insert(Dungeons.Order, 7, "GNOMER")
	Dungeons.Names.GNOMER = "Gnomeregan"
	Dungeons.Levels.GNOMER = { 29, 38, }
	Dungeons.Tags.GNOMER = { "gno", "gnom", "gnomeregan", "gnomeragan", "gnome", "gnomregan", "gnomragan", "gnomer" }
end

LFGAnnouncements.Instances.Register("DUNGEONS", Utils.game.GameExpansionLookup.Vanilla, Dungeons)
LFGAnnouncements.Instances.Register("RAIDS", Utils.game.GameExpansionLookup.Vanilla, Raids)
