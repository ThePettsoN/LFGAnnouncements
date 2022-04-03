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

function LFGAnnouncementsUI:Toggle()
	if self:IsShown() then
		self:Hide()
	else
		self:Show()
	end
end

function LFGAnnouncementsUI:_createUI()
	local frame = AceGUI:Create("Frame")
	frame:SetTitle(AddonName)
	frame:SetLayout("List")
	frame.statustext:GetParent():Hide()

	local container = AceGUI:Create("ScrollFrame")
	container:SetFullWidth(true)
	container:SetLayout("List")
	container.RemoveChild = function(self, widget)
		for i = 1, #self.children do
			local child = self.children[i]
			if child == widget then
				tremove(self.children, i)
				break
			end
		end
	end
	frame:AddChild(container)

	local settingsButton = AceGUI:Create("Button")
	settingsButton:ClearAllPoints()
	settingsButton:SetPoint("BOTTOMLEFT", 27, 17)
	settingsButton:SetHeight(20)
	settingsButton:SetWidth(100)
	settingsButton:SetText("Settings")
	frame:AddChild(settingsButton)

	self._frame = frame
	self._scrollContainer = container
end

function LFGAnnouncementsUI:_createDungeonContainer(dungeonId)
	local dungeons = Dungeons
	local name = dungeons:GetDungeonName(dungeonId)

	local group = AceGUI:Create("CollapsableInlineGroup")
	group.name = name
	group.counter = 0
	group:SetFullWidth(true)
	group:SetLayout("Flow")
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

	return self._dungeonContainers[dungeonId]
end

function LFGAnnouncementsUI:_removeDungeonContainer(dungeonId)
	LFGAnnouncements.dprintf("RemoveDungeonContainer: %q", dungeonId)
	local container = self._dungeonContainers[dungeonId]
	if not container then
		return
	end

	local group = container.group
	self._scrollContainer:RemoveChild(group)
	group:Release()
	self._dungeonContainers[dungeonId] = nil -- TODO: This will force us to re-create container tables everytime we remove/add. Might want to change
	self._scrollContainer:DoLayout()
end

local DifficultyTextLookup = {
	NORMAL = " |cff00ff00[N]|r ",
	HEROIC = " |cffff0000[H]|r ",
}

local function getAnchors(frame)
	local x, y = frame:GetCenter()
	if not x or not y then return "CENTER" end
	local hhalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end

local function onTooltipEnter(widget, event)
	if widget.is_truncated then
		local tooltip = AceGUI.tooltip
		tooltip:SetOwner(widget.frame, "ANCHOR_NONE")
		tooltip:SetPoint(getAnchors(widget.frame))
		tooltip:SetText(widget.label:GetText() or "", 1, .82, 0, true)
		tooltip:Show()
	end
end

local function onTooltipLeave(widget, event)
	AceGUI.tooltip:Hide()
end

function LFGAnnouncementsUI:_createEntryLabel(dungeonId, difficulty, message, time, authorGUID)
	local container = self._dungeonContainers[dungeonId]
	if not container then
		container = self:_createDungeonContainer(dungeonId)
	end

	local _, class, _, _, _, author = GetPlayerInfoByGUID(authorGUID)
	local _,_,_, hex = GetClassColor(class)

	local entry = container.entries[authorGUID]
	local temp = false
	if not entry then
		local group = container.group
		local onClick = function(widget, event, button) -- TODO: This is stupid. Should use one function instead of creating a new one every time
			if button == "LeftButton" then
				ChatFrame_OpenChat(string.format("/w %s ", author))
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
		messageLabel:SetCallback("OnEnter", onTooltipEnter)
		messageLabel:SetCallback("OnLeave", onTooltipLeave)
		group:AddChild(messageLabel)

		local timeLabel = AceGUI:Create("InteractiveLabel")
		timeLabel.label:SetJustifyH("RIGHT")
		timeLabel:SetCallback("OnClick", onClick)
		group:AddChild(timeLabel)

		entry = {
			name = nameLabel,
			difficulty = difficultyLabel,
			message = messageLabel,
			time = timeLabel,
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
	entry.time:SetText(self:_format_time(time))

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

			local counter = group.counter - 1

			if counter <= 0 then
				self:_removeDungeonContainer(dungeonId)
			else
				local containerName = group.name
				group.counter = counter
				group:SetTitle(string.format("%s (%d)", containerName, counter))
			end
		end
	end
end

local TimeColorLookup = {
	NEW = "|cff00ff00",
	MEDIUM = "|cffeed202",
	OLD = "|cffff0000",
}
function LFGAnnouncementsUI:_format_time(time)
	local time_visible_sec = LFGAnnouncements.DB:GetProfileData("search_settings", "time_visible_sec") -- TODO: Might be slow. Cache?
	local percentage = time / time_visible_sec
	local color
	if percentage < 0.33 then
		color = TimeColorLookup.NEW
	elseif percentage < 0.66 then
		color = TimeColorLookup.MEDIUM
	else
		color = TimeColorLookup.OLD
	end

	local min = math.floor(time / 60)
	return string.format("%s%dm %02ds|r", color, min, time % 60)
end

-- TODO - This is maybe not the best solution, but we give the max font width of a name
local nameSize, timeSize
local function temp()
	if nameSize then
		return nameSize, timeSize
	end

	local frame = CreateFrame("Frame", nil, UIParent)
	local s = frame:CreateFontString(frame, "BACKGROUND", "GameFontHighlightSmall")
	s:SetText("XXXXXXXXXXXX")
	nameSize = s:GetStringWidth()

	s:SetText("99m 59s")
	timeSize = s:GetStringWidth()

	frame:Hide()
	return nameSize, timeSize
end

function LFGAnnouncementsUI:_calculateSize(entry, group, newEntry)
	local diffWidth = entry.difficulty.label:GetStringWidth()
	local nameWidth, timeWidth = temp()

	if newEntry then
		entry.difficulty:SetWidth(diffWidth)
		entry.name:SetWidth(nameWidth)
		entry.time:SetWidth(timeWidth)
	end

	local groupWidth = group.frame:GetWidth()

	local messageTextWidth = entry.message.label:GetStringWidth()
	local availableWidth = groupWidth - diffWidth - timeWidth - nameWidth - 8 - 8 - 8
	entry.message.is_truncated = messageTextWidth > availableWidth
	entry.message:SetWidth(availableWidth)
end

function LFGAnnouncementsUI:OnDungeonActivated(event, dungeonId)
	LFGAnnouncements.dprintf("OnDungeonActivated: %s", dungeonId)
end

function LFGAnnouncementsUI:OnDungeonDeactivated(event, dungeonId)
	LFGAnnouncements.dprintf("OnDungeonDeactivated: %s", dungeonId)
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