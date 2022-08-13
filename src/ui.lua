local TOCNAME, LFGAnnouncements = ...

-- Lua APIs
local pairs = pairs
local tremove = tremove
local stringformat = string.format
local floor = floor

-- WoW APIs
local CreateFrame = CreateFrame
local C_FriendList = C_FriendList
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local GetClassColor = GetClassColor
local UIParent = UIParent
local ChatFrame_OpenChat = ChatFrame_OpenChat

local AceGUI = LibStub("AceGUI-3.0", "AceEvent-3.0")

local Instances

local EntryPrefix = {
	NORMAL = " |cff00ff00[N]|r ",
	HEROIC = " |cffff0000[H]|r ",
	RAID = " |cff8000ff[R]|r ",
	CUSTOM = "",
}
local TimeColorLookup = {
	NEW = "|cff00ff00",
	MEDIUM = "|cffeed202",
	OLD = "|cffff0000",
}


local LFGAnnouncementsUI = {}
function LFGAnnouncementsUI:OnInitialize()
	LFGAnnouncements.UI = self

	self._instanceContainers = {}
	self._frame = nil

	self:RegisterMessage("OnInstanceActivated", "OnInstanceActivated")
	self:RegisterMessage("OnInstanceDeactivated", "OnInstanceDeactivated")
	self:RegisterMessage("OnInstanceEntry", "OnInstanceEntry")
	self:RegisterMessage("OnRemoveInstanceEntry", "OnRemoveInstanceEntry")
	self:RegisterMessage("OnRemoveInstances", "OnRemoveInstances")
end

function LFGAnnouncementsUI:OnEnable()
	Instances = LFGAnnouncements.Instances
	self._ready = true

	self._fontSettings = LFGAnnouncements.DB:GetProfileData("general", "font")
	self._showTotalTime = LFGAnnouncements.DB:GetProfileData("general", "format", "show_total_time")
	self._showLevelRange = LFGAnnouncements.DB:GetProfileData("general", "format", "show_level_range")
	self._contextMenu = LFGAnnouncements.ContextMenu
	self._contextMenu:Init(self._fontSettings)

	local playerLevel = UnitLevel("player")
	self._playerLevel = playerLevel

	local maxLevel = MAX_PLAYER_LEVEL_TABLE[GetServerExpansionLevel()]
	if playerLevel ~= maxLevel then
		self:RegisterEvent("PLAYER_LEVEL_UP", "OnPlayerLevelUp")
	end
end

function LFGAnnouncementsUI:IsShown()
	return (not not self._frame) and self._frame:IsShown()
end

function LFGAnnouncementsUI:Show()
	if not self._frame then
		self:_createUI()
		self:SendMessage("OnShowUI")
	elseif not self._frame:IsShown() then
		self._frame:Show()
		self:SendMessage("OnShowUI")
	end
end

function LFGAnnouncementsUI:Hide()
	if self._frame and self._frame:IsShown() then
		self._frame:Hide()
		self:SendMessage("OnHideUI")
	end
end

function LFGAnnouncementsUI:Toggle()
	if self:IsShown() then
		self:Hide()
	else
		self:Show()
	end
end

function LFGAnnouncementsUI:CloseAll()
	for _, container in pairs(self._instanceContainers) do
		container.group:Collapse()
	end
end

function LFGAnnouncementsUI:OpenGroup(instanceId)
	local container = self._instanceContainers[instanceId]
	if not container then
		return
	end

	container.group:Expand()
end

-- TODO - This is maybe not the best solution, but we get the max font width of a name and the time
local nameSize, timeSize
local function temp(fontSettings)
	if nameSize then
		return nameSize, timeSize
	end

	local frame = CreateFrame("Frame", nil, UIParent)
	local s = frame:CreateFontString(frame, "BACKGROUND")
	s:SetFont(fontSettings.path, fontSettings.size, fontSettings.flags)

	s:SetText("XXXXXXXXXXXX")
	nameSize = s:GetStringWidth()

	s:SetText(" 99m 59s ")
	timeSize = s:GetStringWidth()

	frame:Hide()
	return nameSize, timeSize
end

function LFGAnnouncementsUI:SetFont(font, size, flags)
	local settings = self._fontSettings
	settings.path = font and font or settings.path
	settings.size = size and size or settings.size
	settings.flags = flags and flags or settings.flags
	LFGAnnouncements.DB:SetProfileData("font", settings, "general")

	nameSize = nil
	timeSize = nil

	for _, container in pairs(self._instanceContainers) do
		for _, entry in pairs(container.entries) do
			self:_setFont(entry)
			self:_calculateSize(entry, container.group, true)
		end
		container.group:SetTitleFont(settings.path, settings.size, settings.flags)
	end

	if self._scrollContainer then
		self._scrollContainer:DoLayout()
	end

	self._contextMenu:SetFont(font, size, flags)
end

function LFGAnnouncementsUI:ShowTotalTime(show)
	if self._showTotalTime ~= show then
		self._showTotalTime = show
		LFGAnnouncements.DB:SetProfileData("show_total_time", show, "general", "format")
	end
end

local gray = "ffaaaaaa"
local red = "ffAF4134"
local green = "ff00ff00"
local default = "ffffd100"
local function getGroupTitle(name, levelRange, numEntries, playerLevel)
	if levelRange then
		local minLevel = levelRange[1]
		local maxLevel = levelRange[2]

		local color
		if minLevel == 0 then
			color = default
		elseif maxLevel < playerLevel then
			color = gray
		elseif playerLevel < minLevel then
			color = red
		else
			color = green
		end

		return stringformat("|c%s[%d-%d]|r %s (%d)", color, minLevel, maxLevel, name, numEntries)
	end

	return stringformat("%s (%d)", name, numEntries)
end

function LFGAnnouncementsUI:ShowLevelRange(show)
	if self._showLevelRange ~= show then
		self._showLevelRange = show
		LFGAnnouncements.DB:SetProfileData("show_level_range", show, "general", "format")

		local containers = self._instanceContainers
		local instances = Instances
		if show then
			local customInstanceType = instances.InstanceType.CUSTOM
			for id, container in pairs(containers) do
				local isCustomGroup = instances:GetInstanceType(id) == customInstanceType
				local levelRange = not isCustomGroup and instances:GetLevelRange(id)
				local group = container.group
				group:SetTitle(getGroupTitle(group.name, levelRange, group.counter, self._playerLevel))
			end
		else
			for _, container in pairs(containers) do
				local group = container.group
				group:SetTitle(getGroupTitle(group.name, nil, group.counter, self._playerLevel))
			end
		end
	end
end

function LFGAnnouncementsUI:_createUI()
	local frame = AceGUI:Create("Frame")
	frame:SetTitle(TOCNAME)
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
	settingsButton:SetPoint("BOTTOMLEFT", frame.frame, "BOTTOMLEFT", 27, 17)
	settingsButton:SetHeight(20)
	settingsButton:SetWidth(100)
	settingsButton:SetText("Settings")
	settingsButton:SetCallback("OnClick", function(widget, event, button)
		if button == "LeftButton" then
			LFGAnnouncements.ContextMenu:Hide()
			LFGAnnouncements.Options.Toggle()
		end
	end)
	frame:AddChild(settingsButton)

	self._frame = frame
	self._scrollContainer = container
end

function LFGAnnouncementsUI:_createInstanceContainer(instanceId)
	local instances = Instances
	local name = instances:GetInstanceName(instanceId)

	local isCustomGroup = instances:GetInstanceType(instanceId) == instances.InstanceType.CUSTOM
	local levelRange = not isCustomGroup and self._showLevelRange and instances:GetLevelRange(instanceId)

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

	group:SetTitle(getGroupTitle(name, levelRange, 0, self._playerLevel))
	group:SetTitleFont(self._fontSettings.path, self._fontSettings.size, self._fontSettings.flags)
	group:Collapse()

	local order = instances:GetInstancesOrder()
	local _, instanceOrder = LFGAnnouncements.Utils.tArrayFind(order, instanceId)

	local nextGroup, nextOrder
	for _, data in pairs(self._instanceContainers) do
		local order = data.order
		if instanceOrder < order and (not nextOrder or nextOrder > order) then
			nextGroup = data.group
			nextOrder = order
		end
	end

	self._instanceContainers[instanceId] = {
		group = group,
		entries = {},
		order = instanceOrder,
	}

	self._scrollContainer:AddChild(group, nextGroup)

	group:SetCallback("Expand", function() self._scrollContainer:DoLayout() end)
	group:SetCallback("Collapse", function() self._scrollContainer:DoLayout() end)
	group:SetCallback("OnWidthSet", function()
		local entires = self._instanceContainers[instanceId].entries
		for _, entry in pairs(entires) do
			self:_calculateSize(entry, group, false)
		end
	end)

	return self._instanceContainers[instanceId]
end

function LFGAnnouncementsUI:_removeInstanceContainer(instanceId)
	local container = self._instanceContainers[instanceId]
	if not container then
		return
	end

	local group = container.group
	local entries = container.entries
	for _, entry in pairs(entries) do
		for _, widget in pairs(entry) do
			group:RemoveChild(widget)
			widget:Release()
		end
	end

	self._scrollContainer:RemoveChild(group)
	group:Release()
	self._instanceContainers[instanceId] = nil -- TODO: This will force us to re-create container tables everytime we remove/add. Might want to change
	self._scrollContainer:DoLayout()
end

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
		tooltip:SetText(widget.label:GetText() or "", 1, 1, 1, true)
		tooltip:Show()
	end
end

local function onTooltipLeave(widget, event)
	AceGUI.tooltip:Hide()
end

function LFGAnnouncementsUI:_setFont(entry)
	local font = self._fontSettings.path
	local size = self._fontSettings.size
	local flags = self._fontSettings.flags

	for _, obj in pairs(entry) do
		obj:SetFont(font, size, flags)
	end
end

function LFGAnnouncementsUI:_createEntryLabel(instanceId, difficulty, message, time, totalTime, authorGUID, reason)
	local container = self._instanceContainers[instanceId]
	if not container then
		container = self:_createInstanceContainer(instanceId)
	end

	local _, class, _, _, _, author = GetPlayerInfoByGUID(authorGUID)
	if LFGAnnouncements.DEBUG then
		if not class then
			class = "WARLOCK"
		end
		if not author then
			author = authorGUID
		end
	end
	local _,_,_, hex = GetClassColor(class)

	local instances = LFGAnnouncements.Instances
	local entry = container.entries[authorGUID]
	local newEntry = false
	local isCustomGroup = instances:GetInstanceType(instanceId) == instances.InstanceType.CUSTOM
	if not entry then
		local group = container.group
		local onClick = function(widget, event, button) -- TODO: This is stupid. Should use one function instead of creating a new one every time
			if button == "LeftButton" then
				if IsShiftKeyDown() then
					C_FriendList.SendWho(author)
				else
					ChatFrame_OpenChat(stringformat("/w %s ", author))
				end
			elseif button == "RightButton" then
				self._contextMenu:Show(author, message)
			end
		end

		local prefixLabel = AceGUI:Create("InteractiveLabel")
		prefixLabel:SetCallback("OnClick", onClick)
		group:AddChild(prefixLabel)

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
			prefix = prefixLabel,
			message = messageLabel,
			time = timeLabel,
		}
		self:_setFont(entry)

		container.entries[authorGUID] = entry

		local levelRange = not isCustomGroup and self._showLevelRange and instances:GetLevelRange(instanceId)

		local containerName = group.name
		local containerCounter = group.counter + 1
		group.counter = containerCounter

		group:SetTitle(getGroupTitle(containerName, levelRange, containerCounter, self._playerLevel))
		newEntry = true
	end

	local prefix = isCustomGroup and EntryPrefix.CUSTOM or difficulty

	entry.name:SetText(stringformat("|c%s%s|r", hex, author))
	entry.prefix:SetText(EntryPrefix[prefix])
	entry.message:SetText(message)
	entry.time:SetText(self:_formatTime(self._showTotalTime and totalTime or time))

	self:_calculateSize(entry, container.group, newEntry)
end

function LFGAnnouncementsUI:_removeEntryLabel(instanceId, authorGUID)
	local container = self._instanceContainers[instanceId]
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
				self:_removeInstanceContainer(instanceId)
			else
				local instances = Instances
				local isCustomGroup = instances:GetInstanceType(instanceId) == instances.InstanceType.CUSTOM
				local levelRange = not isCustomGroup and self._showLevelRange and instances:GetLevelRange(instanceId)
				local containerName = group.name
				group.counter = counter
				group:SetTitle(getGroupTitle(containerName, levelRange, counter, self._playerLevel))
			end
		end
	end
end

function LFGAnnouncementsUI:_formatTime(time)
	local time_visible_sec = LFGAnnouncements.DB:GetProfileData("general", "time_visible_sec") -- TODO: Might be slow. Cache?
	local percentage = time / time_visible_sec
	local color
	if self._showTotalTime or percentage < 0.33 then
		color = TimeColorLookup.NEW
	elseif percentage < 0.66 then
		color = TimeColorLookup.MEDIUM
	else
		color = TimeColorLookup.OLD
	end

	local min = floor(time / 60)
	return stringformat("%s%dm %02ds|r", color, min, time % 60)
end

function LFGAnnouncementsUI:_calculateSize(entry, group, newEntry)
	local diffWidth = entry.prefix.label:GetStringWidth()
	local nameWidth, timeWidth = temp(self._fontSettings)

	if newEntry then
		entry.prefix:SetWidth(diffWidth)
		entry.name:SetWidth(nameWidth)
		entry.time:SetWidth(timeWidth)
	end

	local groupWidth = group.frame:GetWidth()

	local messageTextWidth = entry.message.label:GetStringWidth()
	local availableWidth = groupWidth - diffWidth - timeWidth - nameWidth - 8 - 8 - 8
	entry.message.is_truncated = messageTextWidth > availableWidth
	entry.message:SetWidth(availableWidth)
end

function LFGAnnouncementsUI:OnInstanceActivated(event, instanceId)
end

function LFGAnnouncementsUI:OnInstanceDeactivated(event, instanceId)
	self:_removeInstanceContainer(instanceId)
end

function LFGAnnouncementsUI:OnInstanceEntry(event, instanceId, difficulty, message, time, totalTime, authorGUID, reason)
	if self:IsShown() then
		self:_createEntryLabel(instanceId, difficulty, message, time, totalTime, authorGUID, reason)
		-- self._scrollContainer:DoLayout()
	end
end

function LFGAnnouncementsUI:OnRemoveInstanceEntry(event, instanceId, authorGUID)
	if self:IsShown() then
		self:_removeEntryLabel(instanceId, authorGUID)
		self._scrollContainer:DoLayout()
	end
end

function LFGAnnouncementsUI:OnRemoveInstances(event, instances)
	for i = 1, #instances, 2 do
		local instanceId = instances[i]
		local authorGUID = instances[i + 1]
		self:_removeEntryLabel(instanceId, authorGUID)
	end

	if self:IsShown() then
		self._scrollContainer:DoLayout()
	end
end

function LFGAnnouncementsUI:OnPlayerLevelUp(event, newLevel)
	self._playerLevel = newLevel
end

LFGAnnouncements.Core:RegisterModule("UI", LFGAnnouncementsUI, "AceEvent-3.0")