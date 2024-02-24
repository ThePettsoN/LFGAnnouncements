local _, LFGAnnouncements = ...

-- Lua APIs
local wipe = wipe
local pairs = pairs
local max = max
local min = min

-- WoW APIs
local UnitLevel = UnitLevel
local tContains = tContains

local Dungeons = {
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

local Raids = {
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
		GRUUL = { "gruul", "gruuls", },
		MAG = { "mag", "mahtheridon", "magth", },
		SSC = { "ssc", "serpentshrin", "serpentshine", },
		TK = { "tk", "tempest", "eye", },
		MH = { "mh", "hyjal", "hyj", },
		BT = { "bt", "temple", },
		ZA = { "za", "zulaman", "aman", },
		SWP = { "swp", "sunwell", "plateau", "sunwel", "plataeu", },
	}
}

LFGAnnouncements.Instances.Register("DUNGEONS", LFGAnnouncements.GameExpansionLookup.TBC, Dungeons)
LFGAnnouncements.Instances.Register("RAIDS", LFGAnnouncements.GameExpansionLookup.TBC, Raids)
