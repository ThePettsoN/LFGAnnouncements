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
		"UK",
		"NEXUS",
		"AN",
		"AK",
		"DT",
		"VH",
		"GD",
		"HOS",
		"HOL",
		"COS",
		"OCU",
		"UP",
		"FOS",
		"POS",
		"HOR",
		"TOC",
	},
	Names = {
		UK 		= "Utgarde Keep",
		NEXUS 	= "Nexus",
		AN 		= "Ajzol-Nerub",
		AK 		= "Ahn'kahet: The Old Kingdom",
		DT 		= "Drak’Tharon Keep",
		VH 		= "Violet Hold",
		GD 		= "Gundrak",
		HOS 	= "Halls of Stone",
		HOL		= "Halls of Lightning",
		COS 	= "The Culling of Stratholme",
		OCU 	= "The Oculus",
		UP 		= "Utgarde Pinnacle",
		FOS 	= "Forge of Souls",
		POS 	= "Pit of Saron",
		HOR 	= "Halls of Reflection",
		TOC 	= "Trial of the Champion",
	},
	Levels = {
		UK 		= { 69, 72, },
		NEXUS 	= { 69, 73, },
		AN 		= { 72, 74, },
		AK 		= { 73, 75, },
		DT 		= { 74, 76, },
		VH 		= { 75, 77, },
		GD 		= { 76, 78, },
		HOS 	= { 77, 79, },
		HOL		= { 78, 80, },
		COS 	= { 78, 80, },
		OCU 	= { 79, 80, },
		UP 		= { 79, 80, },
		FOS 	= { 80, 80, },
		POS 	= { 80, 80, },
		HOR 	= { 80, 80, },
		TOC 	= { 80, 80, },
	},
	Tags = {
		UK = 	{"uk", "keep", "utgardekeep", },
		NEXUS = { "nexus", },
		AN = 	{ "Ajzol", "an", "nerub", },
		AK = 	{ "ahnkahet", "ahn'kahet", "kingdom", },
		DT = 	{ "dt", "dkt", "drak", "tharon", },
		VH = 	{ "violet", "hold", "vh", },
		GD = 	{ "gundrak", "gd", },
		HOS = 	{ "hos", "stone", },
		HOL = 	{ "hol", "lightning", },
		COS = 	{ "culling", "stratholme", "strat", },
		OCU = 	{ "oculus", "ocu", },
		UP = 	{ "up", "pinnacle", },
		FOS = 	{ "forge", "soul", "souls", "fos", },
		POS = 	{ "pit", "saron", "pos"},
		HOR = 	{ "reflection", "reflections", "hor", },
		TOC = 	{ "champion", "toc", "totc", },
	},
}

local Raids = {
	Order = {
		"NAXX",
		"EOE",
		"VOA",
		"OS",
		"ULD",
		"TOTC",
		"ONY",
		"ICC",
		"RS",
	},
	Names = {
		NAXX = 	"Naxxramas",
		EOE = 	"The Eye of Eternity",
		VOA = 	"Vault of Archavon",
		OS = 	"Obsidian Sanctum",
		ULD = 	"Ulduar",
		TOTC = 	"Trial of the Crusader",
		ONY = 	"Onyxia’s Lair",
		ICC = 	"Icecrown Citadel",
		RS = 	"The Ruby Sanctum",
	},
	Levels = {
		NAXX = 	{ 80, 80, },
		EOE = 	{ 80, 80, },
		VOA = 	{ 80, 80, },
		OS = 	{ 80, 80, },
		ULD = 	{ 80, 80, },
		TOTC = 	{ 80, 80, },
		ONY = 	{ 80, 80, },
		ICC = 	{ 80, 80, },
		RS = 	{ 80, 80, },
	},
	Tags = {
		NAXX = 	{ "naxx", "naxxramas", "naxramas", "nax", },
		EOE = 	{ "eye", "eoe", "eternity", },
		VOA = 	{ "voa", "vault", "archavon", },
		OS = 	{ "os", "obsidian", "obsidan", "obsdian", },
		ULD = 	{ "ulduar", "uldu", "uld", },
		TOTC = 	{ "totc", "crusader", "crusade", },
		ONY = 	{ "ony", "nyxia", "onyxia", },
		ICC = 	{ "icc", "icecron", "citadel", "icecrown", },
		RS = 	{ "ruby", "rs", },
	}
}

LFGAnnouncements.Instances.Register("DUNGEONS", LFGAnnouncements.GameExpansionLookup.WOTLK, Dungeons)
LFGAnnouncements.Instances.Register("RAIDS", LFGAnnouncements.GameExpansionLookup.WOTLK, Raids)
