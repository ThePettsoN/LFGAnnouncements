local _, LFGAnnouncements = ...
local VanillaDungeons = {
	Names = {
		RFC 			= "Ragefire Chasm",
		WC 				= "Wailing Caverns",
		DM 				= "The Deadmines",
		SFK 			= "Shadowfang Keep",
		STOCKS 			= "The Stockade",
		BFD 			= "Blackfathom Deeps",
		GNOMER 			= "Gnomeregan",
		RFK 			= "Razorfen Kraul",
		SM 				= "Scarlet Monastery: Graveyard",
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
		DIRE_MAUL 		= "Dire Maul",
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
		SM 				= { 28, 45, },
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
		DIRE_MAUL		= { 58, 60, },
		DIRE_MAUL_E		= { 58, 60, },
		DIRE_MAUL_N		= { 58, 60, },
		DIRE_MAUL_W		= { 58, 60, },
	},
	Tags = {
		RFC				= { "rfc", "ragefire", "chasm", },
		WC				= { "wc", "wailing", "caverns", },
		DM				= { "deadmines", "vc", "vancleef", "dead", "mine", "mines", },
		SFK				= { "sfk", "shadowfang", },
		STOCKS			= { "stk", "stock", "stockade", "stockades" },
		BFD				= { "bfd", "fathom", "blackfathom", },
		GNOMER			= { "gno", "gnom", "gnomeregan", "gnomeragan", "gnome", "gnomregan", "gnomragan" },
		RFK				= { "rfk", "kraul", },
		SM 				= { "sm", "scarlet", "mona", "monastery", },
		SM_GY			= { "smgy", "smg", "gy", "graveyard", },
		SM_LIB			= { "smlib", "sml", "lib", "library", },
		SM_ARM			= { "smarm", "sma", "arm", "armory", "herod", "armoury", "arms", },
		SM_CATH			= { "smcath", "smc", "cath", "cathedral", },
		RFD				= { "rfd", "downs", },
		ULDA			= { "uld", "ulda", "uldaman", "ulduman", "uldman", "uldama", "udaman", },
		ZF				= { "zf", "zul", "farrak", "zul'farrak", "zulfarrak", "zulfarak", "zul´farrak", "zul`farrak", "zulfa", "zulf", },
		MARA			= { "mar", "mara", "maraudon", "mauradon", "mauro", "maurodon", "princessrun", "maraudin", "maura", "marau", "mauraudon" },
		ST				= { "st", "sunken", "atal", "temple", },
		BRD				= { "brd", "emp", "arenarun", "angerforge", "blackrockdepth", },
		LBRS			= { "lower", "lbrs", "lrbs", },
		UBRS			= { "upper", "ubrs", "urbs", "rend", },
		SCHOLO			= { "scholomance", "scholo", "sholo", "sholomance", },
		STRAT			= { "stratlive", "live", "living", "stratUD", "undead", "ud", "baron", "stratholme", "stath", "stratholm", "strah", "strath", "strat", "starth" },
		DIRE_MAUL		= { "dire", "maul", "diremaul", },
		DIRE_MAUL_E		= { "dme", "dmeast", "east", "puzilin", "jumprun", },
		DIRE_MAUL_N		= { "dmn", "dmnorth", "north", "tribute", },
		DIRE_MAUL_W		= { "dmw", "dmwest", "west", },
	}
}

local BurningCrusadeDungeons = {
	Names = {
		RAMP 	= "Hellfire Citadel: Hellfire Ramparts",
		BF 		= "Hellfire Citadel: The Blood Furnace",
		SHH 	= "Hellfire Citadel: The Shattered Halls",
		SP 		= "Coilfang Reservoir: The Slave Pens",
		UB 		= "Coilfang Reservoir: The Underbog",
		SV 		= "Coilfang Reservoir: The Steamvault",
		MT 		= "Auchindoun: Mana-Tombs",
		AC 		= "Auchindoun: Auchenai Crypts",
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
		ZA = { "za", "zul'aman", "zulaman", "aman", },
		SWP = { "swp", "sunwell", "plateau", "sunwel", "plataeu", },
	}
}

local dungeons = LFGAnnouncements.Utils.tMergeRecursive(VanillaDungeons, BurningCrusadeDungeons)
local raids = BurningCrusadeRaids
local instances = LFGAnnouncements.Utils.tMergeRecursive(dungeons, raids)


local LFGAnnouncementsDungeons = {}
function LFGAnnouncementsDungeons:OnInitialize()
	self._activatedDungeons = {}
	self._activeTags = {}

	LFGAnnouncements.Dungeons = self
end

function LFGAnnouncementsDungeons:OnEnable()
	local db = LFGAnnouncements.DB
	local firstTime = db.data.char.first_time
	if firstTime then
		local playerLevel = UnitLevel("player")
		local dungeonsPerLevel = self:GetDungeonsByLevel(playerLevel)
		for i = 1, #dungeonsPerLevel do
			self:ActivateDungeon(dungeonsPerLevel[i])
		end

		db.data.char.first_time = nil
	else
		local dungeons = db.data.dungeons.activated
		for key, _ in pairs(dungeons) do
			self:ActivateDungeon(key)
		end
	end

	db.data.char.dungeons.activated = self._activatedDungeons
end

function LFGAnnouncementsDungeons:GetActivatedDungeons()
	return self._activatedDungeons
end

function LFGAnnouncementsDungeons:ActivateDungeon(id)
	self._activatedDungeons[id] = true

	local tags = instances.Tags[id]
	for i = 1, #tags do
		self._activeTags[tags[i]] = id
	end

	self:SendMessage("OnDungeonActivated", id)
end

function LFGAnnouncementsDungeons:DeactivateDungeon(id)
	self._activatedDungeons[id] = nil
	local activeTags = self._activeTags
	for key, value in pairs(activeTags) do
		if value == id then
			self._activeTags[key] = nil
		end
	end

	self:SendMessage("OnDungeonDeactivated", id)
end

function LFGAnnouncementsDungeons:ActivateAll()
	for id, _ in pairs(instances.Names) do
		self:ActivateDungeon(id)
	end
end

function LFGAnnouncementsDungeons:GetDungeonName(id)
	return instances.Names[id]
end

local dungeonsFound = {}
function LFGAnnouncementsDungeons:GetDungeonsByLevel(level)
	local maxLevel = LFGAnnouncements.GameExpansion == "TBC" and 70 or 60
	wipe(dungeonsFound)

	local minDiff, maxDiff
	if level == maxLevel then
		minDiff = level - 10
		maxDiff = level
	else
		minDiff = math.max(level - 5, 0)
		maxDiff = math.min(level + 5, maxLevel)
	end

	for id, range in pairs(instances.Levels) do
		if range[1] >= minDiff and range[2] <= maxDiff then
			dungeonsFound[#dungeonsFound+1] = id
		end
	end

	return dungeonsFound
end

function LFGAnnouncementsDungeons:FindDungeons(splitMessage)
	wipe(dungeonsFound)

	local found = false
	for i = 1, #splitMessage do
		local id = self._activeTags[splitMessage[i]]
		if id then
			found = true
			dungeonsFound[id] = true
		end
	end

	return found and dungeonsFound or false
end

LFGAnnouncements.Core:RegisterModule("Dungeons", LFGAnnouncementsDungeons, "AceEvent-3.0")