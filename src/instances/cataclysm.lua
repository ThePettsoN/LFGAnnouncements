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
	{ "BRC", 134 },
	{ "TOTT", 146 },
	{ "SC", 137 },
	{ "VP", 138 },
	{ "LCOTT", 139 },
	{ "HOO", 136 },
	{ "GB", 135 },
	{ "DM", 799 },
	{ "SFK", 800 },
	{ "ZG", 150 },
	{ "ZA", 151 },
	{ "ET", 152 },
	{ "WOE", 153 },
	{ "HOT", 154 },
	-- Raids
	{ "BH", 1517 },
	{ "BOT", 1527 },
	{ "TFW", 1531 },
	{ "BWD", 1523 },
	{ "FL", 1586 },
	{ "DS", 1703 },
}

local Tags = {
	BRC 	= { "blackrock", "brc", },
	TOTT 	= { "tides", "tott", },
	SC 		= { "sc", "stonecore", },
	VP 		= { "vortex", "vp", },
	LCOTT 	= { "lcot", "tol", "vir", "tol'vir", },
	HOO 	= { "origination", "hoo", },
	GB 		= { "grim", "batol", "gb", },
	DM 		= { "deadmines", "dm", "vc", "vancleef", },
	SFK 	= { "sfk", "shadowfang", },
	ZG 		= { "zg", "gurub", },
	ZA 		= { "za", "aman", },
	ET 		= { "et", "endtime", "end time", "end-time" },
	WOE 	= { "woe", "well", "eternity", },
	HOT 	= { "hot", "hour", },
	-- Raids
	BH 		= { "baradin", "bh", },
	BOT 	= { "bastion", "bot", "twilight", },
	TFW 	= { "totfw", "tfw", "toftw", "tofw", "winds", "tot4w" },
	BWD 	= { "blackwing", "descent", "bd", "bwd" },
	FL 		= { "fl", "firelands", },
	DS 		= { "ds", "soul", "dragon soul" },
}

local Levels = {
	-- Dungeons
	BRC		= { 80, 83, },
	TOTT	= { 80, 83, },
	SC		= { 82, 85, },
	VP		= { 82, 85, },
	LCOTT	= { 83, 85, },
	HOO		= { 83, 85, },
	GB		= { 84, 85, },
	DM		= { 85, 85, },
	SFK		= { 85, 85, },
	ZG		= { 85, 85, },
	ZA		= { 85, 85, },
	ET		= { 85, 85, },
	WOE		= { 85, 85, },
	HOT		= { 85, 85, },
	-- Raids
	BH 		= { 85, 85, },
	BOT 	= { 85, 85, },
	TFW 	= { 85, 85, },
	BWD 	= { 85, 85, },
	FL 		= { 85, 85, },
	DS 		= { 85, 85, },
}

LFGAnnouncements.Instances.Register(GameUtils.GameVersionLookup.CATACLYSM, Instances, Tags, Levels)
