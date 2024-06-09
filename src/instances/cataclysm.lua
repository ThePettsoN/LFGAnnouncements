local _, LFGAnnouncements = ...
local Utils = LFGAnnouncements.Utils

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
		"BRCCata",
		"TOTTCata",
		"SCCata",
		"VPCata",
		"LCOTTCata",
		"HOOCata",
		"GBCata",
		"DMCata",
		"SFKCata",
		"ZGCata",
		"ZACata",
		"ETCata",
		"WOECata",
		"HOTCata",
	},
	Names = {
		BRCCata		= "Blackrock Caverns",
		TOTTCata 	= "Throne of the Tides",
		SCCata		= "The Stonecore",
		VPCata		= "Vortex Pinnacle",
		LCOTTCata	= "Lost City of the Tol'vir",
		HOOCata		= "Halls of Origination",
		GBCata		= "Grim Batol",
		DMCata		= "The Deadmines",
		SFKCata		= "Shadowfang Keep",
		ZGCata		= "Zul'Gurub",
		ZACata		= "Zul'Aman",
		ETCata		= "End Time",
		WOECata		= "Well of Eternity",
		HOTCata		= "Hour of Twilight",
	},
	Levels = {
		BRCCata		= { 80, 83, },
		TOTTCata	= { 80, 83, },
		SCCata		= { 82, 85, },
		VPCata		= { 82, 85, },
		LCOTTCata	= { 83, 85, },
		HOOCata		= { 83, 85, },
		GBCata		= { 84, 85, },
		DMCata		= { 85, 85, },
		SFKCata		= { 85, 85, },
		ZGCata		= { 85, 85, },
		ZACata		= { 85, 85, },
		ETCata		= { 85, 85, },
		WOECata		= { 85, 85, },
		HOTCata		= { 85, 85, },
	},
	Tags = {
		BRCCata		= { "blackrock", "brc", },
		TOTTCata	= { "tides", "tott", },
		SCCata		= { "sc", "stonecore", },
		VPCata		= { "vortex", "vp", },
		LCOTTCata	= { "lcot", "tol", "vir", "tol'vir", },
		HOOCata		= { "origination", "hoo", },
		GBCata		= { "grim", "batol", "gb", },
		DMCata		= { "deadmines", "dm", "vc", "vancleef", },
		SFKCata		= { "sfk", "shadowfang", },
		ZGCata		= { "zg", "gurub", },
		ZACata		= { "za", "aman", },
		ETCata		= { "et", "time" },
		WOECata		= { "woe", "well", "eternity", },
		HOTCata		= { "hot", "hour", },
	},
}

local Raids = {
	Order = {
		"BHCata",
		"BOTCata",
		"TFWCata",
		"BWDCata",
		"FLCata",
		"DSCata",
	},
	Names = {
		BHCata = "Baradin Hold",
		BOTCata = "The Bastion of Twilight",
		TFWCata = "Throne of the Four Winds",
		BWDCata = "Blackwing Descent",
		FLCata = "Firelands",
		DSCata = "Dragon Soul",
	},
	Levels = {
		BHCata = 	{ 85, 85, },
		BOTCata = 	{ 85, 85, },
		TFWCata = 	{ 85, 85, },
		BWDCata = 	{ 85, 85, },
		FLCata = 	{ 85, 85, },
		DSCata = 	{ 85, 85, },
	},
	Tags = {
		BHCata = 	{ "baradin", "bh", },
		BOTCata = 	{ "bastion", "bot", "twilight", },
		TFWCata = 	{ "totfw", "tfw", "toftw", "tofw", "winds", "tot4w" },
		BWDCata = 	{ "blackwing", "descent", "bd", "bwd" },
		FLCata = 	{ "fl", "firelands", },
		DSCata = 	{ "ds", "soul", },
	}
}

LFGAnnouncements.Instances.Register("DUNGEONS", Utils.game.GameExpansionLookup.Cataclysm, Dungeons)
LFGAnnouncements.Instances.Register("RAIDS", Utils.game.GameExpansionLookup.Cataclysm, Raids)
