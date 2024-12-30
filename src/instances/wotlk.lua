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

local Instances = {
	-- Dungeons
	{ "UK", 1074, },
	{ "NEXUS", 1077, },
	{ "AN", 1066, },
	{ "AK", 1072, },
	{ "DT", 1070, },
	{ "VH", 1073, },
	{ "GD", 1071, },
	{ "HOS", 1069, },
	{ "HOL", 1068, },
	{ "COS", 1065, },
	{ "OCU", 1067, },
	{ "UP", 1075, },
	{ "FOS", 1078, },
	{ "POS", 1079, },
	{ "HOR", 1080, },
	{ "TOC", 1076, },
	-- Raids
	{ "NAXX", 1098, },
	{ "EOE", 1102, },
	{ "VOA", 1095, },
	{ "OS", 1101, },
	{ "ULD", 1106, },
	{ "TOTC", 1103, },
	{ "ONY", 1099, },
	{ "ICC", 1110, },
	{ "RS", 1108, },
}

local Tags = {
	-- Dungeons
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
	-- Raids
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

local Levels = {
	-- Dungeons
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
	-- Raids
	NAXX 	= { 80, 80, },
	EOE 	= { 80, 80, },
	VOA 	= { 80, 80, },
	OS 		= { 80, 80, },
	ULD 	= { 80, 80, },
	TOTC 	= { 80, 80, },
	ONY 	= { 80, 80, },
	ICC 	= { 80, 80, },
	RS 		= { 80, 80, },
}

LFGAnnouncements.Instances.Register(GameUtils.GameVersionLookup.WOTLK, Instances, Tags, Levels)
