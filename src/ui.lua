local AddonName, LFGAnnouncements = ...
local AceGUI = LibStub("AceGUI-3.0", "AceEvent-3.0")

local Dungeons

local LFGAnnouncementsUI = {}
function LFGAnnouncementsUI:OnInitialize()
	LFGAnnouncements.UI = self

	self._dungeonContainers = {}
	self._frame = nil

	self:RegisterMessage("OnDungeonActivated", "OnDungeonActivated")
	self:RegisterMessage("OnDungeonDeactivated", "OnDungeonDeactivated")
	self:RegisterMessage("OnDungeonEntry", "OnDungeonEntry")
	self:RegisterMessage("OnRemoveDungeonEntry", "OnRemoveDungeonEntry")
	self:RegisterMessage("OnRemoveDungeons", "OnRemoveDungeons")
end

function LFGAnnouncementsUI:OnEnable()
	-- Called on PLAYER_LOGIN event
	Dungeons = LFGAnnouncements.Dungeons
	self._ready = true
end

function LFGAnnouncementsUI:IsShown()
	return (not not self._frame) and self._frame:IsShown()
end

function LFGAnnouncementsUI:Show()
	if not self._frame then
		self:_createUI()
	elseif not self._frame:IsShown() then
		self._frame:Show()
	end
end

function LFGAnnouncementsUI:Hide()
	if self._frame:IsShown() then
		self._frame:Hide()
	end
end

function LFGAnnouncementsUI:_createUI()
	local frame = AceGUI:Create("Frame")
	frame:SetTitle(AddonName)
	frame:SetLayout("Fill")

	local container = AceGUI:Create("ScrollFrame")
	container:SetFullWidth(true)
	container:SetLayout("Flow")
	container:SetAutoAdjustHeight(true)
	frame:AddChild(container)

	self._frame = frame
	self._scrollContainer = container

	local dungeons = Dungeons
	local activeDungeons = dungeons:GetActivatedDungeons()
	for dungeonId, _ in pairs(activeDungeons) do
		self:_createDungeonContainer(dungeonId)
	end
end

function LFGAnnouncementsUI:_createDungeonContainer(dungeonId)
	local dungeons = Dungeons
	local name = dungeons:GetDungeonName(dungeonId)

	local group = AceGUI:Create("CollapsableInlineGroup")
	group.name = name
	group.counter = 0
	group:SetFullWidth(true)
	group:SetLayout("Flow")
	group:SetAutoAdjustHeight(true)
	group.RemoveChild = function(self, widget)
		for i = 1, #self.children do
			local child = self.children[i]
			if child == widget then
				tremove(self.children, i)
				break
			end
		end
	end
	group:SetTitle(string.format("%s (0)", name))
	group:Collapse()

	self._scrollContainer:AddChild(group)

	self._dungeonContainers[dungeonId] = {
		group = group,
		entries = {},
	}

	group:SetCallback("Expand", function() self._scrollContainer:DoLayout() end)
	group:SetCallback("Collapse", function() self._scrollContainer:DoLayout() end)
	group:SetCallback("OnWidthSet", function()
		local entires = self._dungeonContainers[dungeonId].entries
		for _, entry in pairs(entires) do
			self:_calculateSize(entry, group, false)
		end
	end)
end

local DifficultyTextLookup = {
	NORMAL = " |cff00ff00[N]|r ",
	HEROIC = " |cffff0000[H]|r ",
}
function LFGAnnouncementsUI:_createEntryLabel(dungeonId, difficulty, message, time, authorGUID)
	local container = self._dungeonContainers[dungeonId]
	if not container then
		return
	end

	local _, class, _, _, _, author = GetPlayerInfoByGUID(authorGUID)
	local _,_,_, hex = GetClassColor(class)

	local entry = container.entries[authorGUID]
	local temp = false
	if not entry then
		local group = container.group

		LFGAnnouncements.dprintf(string.format("New labels for '%s' in dungeon '%s'", author, dungeonId))
		local onClick = function(widget, event, button) -- TODO: This is stupid. Should use one function
			if button == "LeftButton" then
			elseif button == "RightButton" then
				C_FriendList.SendWho(author)
			end
		end

		local difficultyLabel = AceGUI:Create("InteractiveLabel")
		difficultyLabel:SetCallback("OnClick", onClick)
		group:AddChild(difficultyLabel)

		local nameLabel = AceGUI:Create("InteractiveLabel")
		nameLabel:SetCallback("OnClick", onClick)
		group:AddChild(nameLabel)

		local messageLabel = AceGUI:Create("InteractiveLabel")
		messageLabel.label:SetWordWrap(false)
		messageLabel.label:SetNonSpaceWrap(false)
		messageLabel:SetCallback("OnClick", onClick)
		group:AddChild(messageLabel)

		-- local timeLabel = AceGUI:Create("InteractiveLabel")
		-- timeLabel:SetCallback("OnClick", onClick)
		-- group:AddChild(timeLabel)

		entry = {
			name = nameLabel,
			difficulty = difficultyLabel,
			message = messageLabel,
			-- time = timeLabel,
		}

		container.entries[authorGUID] = entry

		local containerName = group.name
		local containerCounter = group.counter + 1
		group.counter = containerCounter
		group:SetTitle(string.format("%s (%d)", containerName, containerCounter))
		temp = true
	end

	entry.name:SetText(string.format("|c%s%s|r", hex, author))
	entry.difficulty:SetText(DifficultyTextLookup[difficulty])
	entry.message:SetText(message)
	-- entry.time:SetText(time)

	self:_calculateSize(entry, container.group, temp)
end

function LFGAnnouncementsUI:_removeEntryLabel(dungeonId, authorGUID)
	local container = self._dungeonContainers[dungeonId]
	if container then
		local group = container.group
		local entry = container.entries[authorGUID]
		if entry then
			for _, widget in pairs(entry) do
				group:RemoveChild(widget)
				widget:Release()
			end
			container.entries[authorGUID] = nil

			local containerName = group.name
			local counter = group.counter - 1
			group.counter = counter
			group:SetTitle(string.format("%s (%d)", containerName, counter))
		end
	end
end

-- TODO - This is maybe not the best solution, but we give the max font width of a name
local size
local function temp()
	if size then
		return size
	end

	local frame = CreateFrame("Frame", nil, UIParent)
	local s = frame:CreateFontString(frame, "BACKGROUND", "GameFontHighlightSmall")
	s:SetText("XXXXXXXXXXXX")
	size = s:GetStringWidth()

	frame:Hide()
	return size
end

function LFGAnnouncementsUI:_calculateSize(entry, group, newEntry)
	local diffWidth = entry.difficulty.label:GetStringWidth()
	local nameWidth = temp()

	if newEntry then
		entry.difficulty:SetWidth(diffWidth)
		entry.name:SetWidth(nameWidth)
	end

	local groupWidth = group.frame:GetWidth()
	entry.message:SetWidth(groupWidth - diffWidth - nameWidth - (diffWidth - 1))
end

function LFGAnnouncementsUI:OnDungeonActivated(event, dungeonId)
	if self:IsShown() then
		self:_createDungeonContainer(dungeonId)
	end
end

function LFGAnnouncementsUI:OnDungeonDeactivated(event, id)
	LFGAnnouncements.dprintf("OnDungeonDeactivated: %s", id)
end

function LFGAnnouncementsUI:OnDungeonEntry(event, dungeonId, difficulty, message, time, authorGUID)
	if self:IsShown() then
		self:_createEntryLabel(dungeonId, difficulty, message, time, authorGUID)
		self._scrollContainer:DoLayout()
	end
end

function LFGAnnouncementsUI:OnRemoveDungeonEntry(event, dungeonId, authorGUID)
	if self:IsShown() then
		self:_removeEntryLabel(dungeonId, authorGUID)
		self._scrollContainer:DoLayout()
	end
end

function LFGAnnouncementsUI:OnRemoveDungeons(event, dungeons)
	if self:IsShown() then
		for dungeonId, authorGUID in pairs(dungeons) do
			self:_removeEntryLabel(dungeonId, authorGUID)
		end
		self._scrollContainer:DoLayout()
	end
end

LFGAnnouncements.Core:RegisterModule("UI", LFGAnnouncementsUI, "AceEvent-3.0")