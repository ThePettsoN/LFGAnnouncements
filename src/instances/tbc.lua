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
	{ "RAMP", 817 },
	{ "BF", 818, },
	{ "SHH", 819, },
	{ "SP", 820, },
	{ "UB", 821, },
	{ "SV", 822, },
	{ "MT", 823, },
	{ "AC", 824, },
	{ "SETH", 825, },
	{ "SL", 826, },
	{ "OHB", 830, },
	{ "BM", 831, },
	{ "BOT", 833, },
	{ "MECHA", 832, },
	{ "ARCA", 834, },
	{ "MGT", 835, },
	-- Raids
	{ "KZ", 844, },
	{ "GRUUL", 846, },
	{ "MAG", 845, },
	{ "SSC", 848, },
	{ "TK", 847, },
	{ "MH", 849, },
	{ "BT", 850, },
	not GameUtils.CompareGameVersion(GameUtils.GameVersionLookup.CATACLYSM) and { "ZA", 851, } or nil,
	{ "SWP", 852, },
}

local Tags = {
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
	-- Raids
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

local Levels = {
	-- Dungeons
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
	-- Raids
	KZ 		= { 70, 70, },
	GRUUL 	= { 70, 70, },
	MAG 	= { 70, 70, },
	SSC 	= { 70, 70, },
	TK 		= { 70, 70, },
	MH 		= { 70, 70, },
	BT 		= { 70, 70, },
	ZA 		= { 70, 70, },
	SWP 	= { 70, 70, },
}

LFGAnnouncements.Instances.Register(GameUtils.GameVersionLookup.TBC, Instances, Tags, Levels)
