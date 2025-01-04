local _, LFGAnnouncements = ...
local LFGAnnouncementsInstances = {}
local PUtils = LFGAnnouncements.PUtils
local GameUtils = PUtils.Game
local TableUtils = PUtils.Table
local StringUtils = PUtils.String

-- Lua APIs
local wipe = wipe
local pairs = pairs
local max = max
local min = min

-- WoW APIs
local UnitLevel = UnitLevel
local tContains = tContains

local Dungeons = {}
local Raids = {}
local Instances = {
	Order = {},
	Names = {},
	Levels = {},
	Tags = {},
	MapIDs = {},
}
local TagsLookup = {}
local CustomInstances = {
	Order = {},
	Names = {},
	Levels = {},
	Tags = {},
}

local InstanceType = {
	DUNGEON = "DUNGEON",
	RAID = "RAID",
	CUSTOM = "CUSTOM",
}
LFGAnnouncementsInstances.InstanceType = InstanceType
LFGAnnouncements.Instances = LFGAnnouncementsInstances

function LFGAnnouncementsInstances:OnInitialize()
	self._activatedInstances = {}
	self._activeTags = {}
	self._lockedInstances = {}
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

	self:UpdateLockedInstances()
	self:RegisterEvent("UPDATE_INSTANCE_INFO", "UpdateLockedInstances")
	self:RegisterEvent("ENCOUNTER_END", "UpdateLockedInstances")
end

function LFGAnnouncementsInstances:UpdateLockedInstances()
	wipe(self._lockedInstances)

	for i = 1, GetNumSavedInstances() do
		local name, _, reset, difficultyId, _, _, _, isRaid, _, _, _, _, _, mapId = GetSavedInstanceInfo(i)
		local instance = Instances.MapIDs[mapId]
		if instance then
			self:DeactivateInstance(instance)
			self._lockedInstances[instance] = true
		end
	end
end

function LFGAnnouncementsInstances:IsLocked(id)
	return self._lockedInstances[id]
end

function LFGAnnouncementsInstances:GetActivatedInstances()
	return self._activatedInstances
end

function LFGAnnouncementsInstances:AddCustomInstance(name)
	local id = StringUtils.uuid("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx")
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
	
	self:debug("Activate instance '%s'", id)
	
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
		self:debug("Tried to deactivate not activated instances '%s'", id)
		return
	end
	
	self:debug("Deactivated instance '%s'", id)
	
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
	return self._activatedInstances[instanceId] ~= nil or Instances.Tags[instanceId] ~= nil
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

function LFGAnnouncementsInstances:GetInstanceTags(id)
	return Instances.Tags[id]
end

local instancesFound = {}
function LFGAnnouncementsInstances:GetInstancesByLevel(level)
	local maxLevel = GameUtils.GetMaxLevel()
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

local instance
function LFGAnnouncementsInstances:GetDungeons(expansionIndex)
	wipe(instancesFound)
	instance = Dungeons[expansionIndex]
	return instance and instance.Order
end

function LFGAnnouncementsInstances:GetRaids(expansionIndex)
	instance = Raids[expansionIndex]
	return instance and instance.Order
end

function LFGAnnouncementsInstances:GetInstancesOrder()
	return Instances.Order
end

function LFGAnnouncementsInstances:GetCustomInstances()
	return CustomInstances
end

function LFGAnnouncementsInstances:GetInstanceType(instanceId)
	if CustomInstances.Names[instanceId] then
		return InstanceType.CUSTOM
	end

	for k, v in pairs(Dungeons) do
		if v.Names[instanceId] then
			return InstanceType.DUNGEON
		end
	end
	
	return InstanceType.RAID
end

local lookup = {}
local allInstancesFound = {}
function LFGAnnouncementsInstances:FindInstances(splitMessage)
	wipe(instancesFound)
	wipe(lookup)
	wipe(allInstancesFound)
	
	local found = false
	for i = 1, #splitMessage do
		local word = splitMessage[i]
		local id = self._activeTags[word]
		if id and not lookup[id] then
			found = true
			instancesFound[#instancesFound + 1] = id
			lookup[id] = true
		end
		
		local customTags = CustomInstances.Tags
		for id, tags in pairs(customTags) do
			if tContains(tags, word) and not lookup[id] then --TODO: Create lookup table instead?
				found = true
				instancesFound[#instancesFound + 1] = id
				lookup[id] = true
			end
		end
	end
	
	if found then
		local numTotalInstancesFound = 0
		for i = 1, #splitMessage do
			local word = splitMessage[i]
			local id = TagsLookup[word]
			if id and not allInstancesFound[id] then
				numTotalInstancesFound = numTotalInstancesFound + 1
			end
		end
		
		return instancesFound, numTotalInstancesFound
	end
end

local function createLevelRange(activityInfo, fallbackLevels)
	local minLevel, maxLevel

	if activityInfo.minLevel and activityInfo.minLevel ~= 0 then
		minLevel = activityInfo.minLevel
	elseif activityInfo.minLevelSuggestion and activityInfo.minLevelSuggestion ~= 0 then
		minLevel = activityInfo.minLevelSuggestion
	elseif fallbackLevels then
		minLevel = fallbackLevels[1] or 0
	else
		minLevel = 0
	end

	if activityInfo.maxLevel and activityInfo.maxLevel ~= 0 then
		maxLevel = activityInfo.maxLevel
	elseif activityInfo.maxLevelSuggestion and activityInfo.maxLevelSuggestion ~= 0 then
		maxLevel = activityInfo.maxLevelSuggestion
	elseif fallbackLevels then
		maxLevel = fallbackLevels[2] or 0
	else
		maxLevel = 0
	end

	return { minLevel, maxLevel }
end

function LFGAnnouncementsInstances.Register(expansionId, instances, tags, levels)
	if not GameUtils.CompareGameVersion(expansionId) then
		return
	end

	local GetActivityInfoTable = C_LFGList.GetActivityInfoTable
	for i = 1, #instances do
		local data = instances[i]
		if data then
			local abriv = data[1]
			local id = data[2]
			local abriv_expansion = string.format("%s_%d", abriv, expansionId)

			local info = GetActivityInfoTable(id)
			local group
			if info.categoryID == 2 then
				group = Dungeons
			elseif info.categoryID == 114 then
				group = Raids
			else
				error("Unsupported group category")
			end

			local perExpansion = group[expansionId] or {
				Order = {},
				Names = {},
				Levels = {},
				Tags = {},
			}

			local name = string.gsub(info.fullName, " %(.*%)", "")
			local levelRange = createLevelRange(info, levels and levels[abriv])

			perExpansion.Order[#perExpansion.Order + 1] = abriv_expansion
			perExpansion.Names[abriv_expansion] = name
			perExpansion.Levels[abriv_expansion] = levelRange
			perExpansion.Tags[abriv_expansion] = tags[abriv]
			group[expansionId] = perExpansion

			Instances.Order[#Instances.Order + 1] = abriv_expansion
			Instances.Names[abriv_expansion] = name
			Instances.MapIDs[info.mapID] = abriv_expansion
			Instances.Levels[abriv_expansion] = levelRange
			Instances.Tags[abriv_expansion] = tags[abriv]
		end
	end
end

LFGAnnouncements.Core:RegisterModule("Instances", LFGAnnouncementsInstances, "AceEvent-3.0")
