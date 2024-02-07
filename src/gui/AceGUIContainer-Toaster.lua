local AceGUI = LibStub("AceGUI-3.0")
local AceTimer = LibStub("AceTimer-3.0")

-- Lua APIs
local pairs = pairs
local assert = assert
local type = type

-- WoW APIs
local PlaySound = PlaySound
local CreateFrame = CreateFrame
local UIParent = UIParent
local CopyTable = CopyTable
local UIFrameFade = UIFrameFade
local UIFrameFadeRemoveFrame = UIFrameFadeRemoveFrame
local BackdropTemplateMixin = BackdropTemplateMixin
local GameFontNormal = GameFontNormal

local Type = "Toaster"
local Version = 2
local AceContainerToast = {}
local PaneBackdrop = {
	edgeFile = "Interface\\AddOns\\LFGAnnouncements\\Media\\Textures\\White8x8",
	bgFile = "Interface\\AddOns\\LFGAnnouncements\\Media\\Textures\\White8x8",
	edgeSize = 1,
}

-- Private Functions --
local function CancelFadeout(frame, timer)
	if UIFrameIsFading(frame) then 
		UIFrameFadeRemoveFrame(frame)
	end

	if timer then
		AceTimer:CancelTimer(timer)
	end
end

local function onClickCloseButton(button)
	PlaySound(799)
	button.obj:Hide()
end

local function CreateTitle(self, frame)
	local closeButton = CreateFrame("Button", "CloseButtonFrame", frame, "UIPanelCloseButton")
	closeButton:SetPoint("TOPRIGHT", 0, 0)
	closeButton:SetScript("OnClick", onClickCloseButton)
	closeButton.obj = self

	local titlebg = frame:CreateTexture(nil, "BACKGROUND")
	titlebg:SetPoint("TOPLEFT", 0, 0)
	titlebg:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
	titlebg:SetPoint("BOTTOMRIGHT", closeButton, "BOTTOMRIGHT", 10, 0)

	local dialogbg = frame:CreateTexture(nil, "BACKGROUND")
	dialogbg:SetPoint("TOPLEFT", titlebg, "BOTTOMLEFT", 0, 0)
	dialogbg:SetPoint("BOTTOMRIGHT", 0, 0)

	local titleText = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	titleText:SetPoint("TOPLEFT", 10, 0)
	titleText:SetPoint("BOTTOMRIGHT", titlebg, "BOTTOMRIGHT", -10, 0)
	titleText:SetJustifyH("LEFT")
	titleText:SetWordWrap(false)
	titleText:SetNonSpaceWrap(false)

	local title = CreateFrame("Button", "TitleButtonFrame", frame)
	title:SetPoint("TOPLEFT", titlebg)
	title:SetPoint("BOTTOMRIGHT", closeButton, "BOTTOMLEFT", 0, 0)

	return title, titleText, closeButton
end

local function CreateContainer(self, frame)
	local content = CreateFrame("Frame", "ContainerFrame", frame)
	content:ClearAllPoints()
	content:SetPoint("TOPLEFT", self.title, "BOTTOMLEFT", 0, 0)
	content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
	content.obj = self

	return content
end

local function CreateLabel(self, frame)
	local label = self.content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	label:ClearAllPoints()
	label:SetPoint("TOPLEFT", 10, 0)
	label:SetPoint("BOTTOMRIGHT", -10, 0)
	label:SetJustifyH("LEFT")
	label:SetJustifyV("TOP")
	label:Show()
	label.obj = self

	return label
end

local function CreateButton(self, frame)
	local button = CreateFrame("Button", "ToasterWindowButton", self.content)
	button:SetPoint("TOPLEFT", self.content, "TOPLEFT", 0, 0)
	button:SetPoint("BOTTOMRIGHT", self.content, "BOTTOMRIGHT", 0, 0)
	button.obj = self

	button:EnableMouse()
	return button
end

-- Callbacks --

local function onShowFrame(frame)
	frame.obj:Fire("OnShow")
end

local function onHideFrame(frame)
	frame.obj:Fire("OnClose")
end

local function onMouseDownTitle(title)
	local frame = title:GetParent()
	frame:StartMoving()
	AceGUI:ClearFocus()

	local self = frame.obj
	self._isMoving = true
	CancelFadeout(self)
	self:Fire("StartMoving")
end

local function onMouseUpTitle(title)
	local frame = title:GetParent()
	frame:StopMovingOrSizing()
	local self = frame.obj
	local status = self.status or self.localstatus
	status.width = frame:GetWidth()
	status.height = frame:GetHeight()
	status.top = frame:GetTop()
	status.left = frame:GetLeft()

	self._isMoving = false
	self:Fire("StopMoving", status.left, status.top - status.height)
end

local function fadeFinishedFunction(self)
	self:Hide()
	self:Fire("FadeOutComplete")
end

local function onFadeOutComplete(self)
	self.fadeInfo.fadeTimer = nil
	self.fadeInfo.finishedFunc = fadeFinishedFunction

	UIFrameFade(self.frame, self.fadeInfo)
end

local function onMouseUpFrameButton(button)
	button.obj:Fire("OnClickBody")
end

-- AceGUI functions --
function AceContainerToast:OnAcquire()
	self.frame:SetParent(UIParent)
	self.frame:SetFrameStrata("FULLSCREEN_DIALOG")
	self:ApplyStatus()
	self:Show()
end

function AceContainerToast:ApplyStatus()
	local status = self.status or self.localstatus
	local frame = self.frame
	self:SetWidth(status.width or 300)
	self:SetHeight(status.height or 50)
	if status.top and status.left then
		frame:SetPoint("TOP", UIParent,"BOTTOM", 0, status.top)
		frame:SetPoint("LEFT", UIParent,"LEFT", status.left, 0)
	else
		frame:SetPoint("CENTER", UIParent, "CENTER")
	end
end

function AceContainerToast:Show()
	self.frame:Show()
end

function AceContainerToast:Hide()
	self.frame:Hide()
end

function AceContainerToast:OnRelease()
	self.status = nil
	for k in pairs(self.localstatus) do
		self.localstatus[k] = nil
	end
end

function AceContainerToast:SetStatusTable(status)
	assert(type(status) == "table")
	self.status = status
	self:ApplyStatus()
end

function AceContainerToast:OnWidthSet(width)
	local content = self.content
	local contentwidth = width - 34
	if contentwidth < 0 then
		contentwidth = 0
	end
	content:SetWidth(contentwidth)
	content.width = contentwidth
end

function AceContainerToast:OnHeightSet(height)
	local content = self.content
	local contentheight = height - 57
	if contentheight < 0 then
		contentheight = 0
	end
	content:SetHeight(contentheight)
	content.height = contentheight
end

-- Public Functions --
function AceContainerToast:SetTitle(title)
	self.titletext:SetText(title)
end

function AceContainerToast:SetSize(width, height)
	self:SetWidth(width)
	self:SetHeight(height)
end

function AceContainerToast:SetIsMovable(isMovable)
	if isMovable then
		self.frame:SetMovable(true)
		self.title:EnableMouse()
		self.title:SetScript("OnMouseDown", onMouseDownTitle)
		self.title:SetScript("OnMouseUp", onMouseUpTitle)
	end
end

function AceContainerToast:SetId(id)
	self.id = id
end

function AceContainerToast:SetAlpha(alpha)
	self.frame:SetAlpha(alpha)
end

function AceContainerToast:IsMoving()
	return self._isMoving
end

function AceContainerToast:SetFadeOutDuration(duration)
	FadeInfo.timeToFade = duration
end

function AceContainerToast:Trigger(duration)
	self:Show()
	self:SetAlpha(1)

	CancelFadeout(self.frame, self.timer)
	self.timer = AceTimer:ScheduleTimer(onFadeOutComplete, duration, self)
end

function AceContainerToast:SetLabelFontSettings(path, size, flags)
	self.label:SetFont(path, size, flags)
end

function AceContainerToast:SetText(text)
	self.label:SetText(text)
end

function AceContainerToast:SetInstanceId(instanceId)
	self.instanceId = instanceId
end

-- Constructor --
local function Constructor()
	local self = AceContainerToast

	local frame = CreateFrame("Frame", "ToasterFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	self.type = "Toaster"
	self.localstatus = {}
	self.frame = frame
	frame.obj = self

	-- Default Values
	frame:SetWidth(300)
	frame:SetHeight(60)
	frame:SetPoint("BOTTOMLEFT", UIParent, "CENTER", 0, 0)
	frame:EnableMouse()
	frame:SetFrameStrata("FULLSCREEN_DIALOG")
	frame:SetBackdrop(PaneBackdrop)
	frame:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
	frame:SetBackdropBorderColor(0, 0, 0)
	frame:SetToplevel(true)
	self.fadeInfo = {
		mode = "OUT",
		timeToFade = 1,
		startAlpha = 1,
		endAlpha = 0,
		finishedFunc = fadeFinishedFunction,
		finishedArg1 = self,
	}

	-- Create Objects
	self.title, self.titletext, self.closebutton = CreateTitle(self, frame)
	self.content = CreateContainer(self, frame)
	AceGUI:RegisterAsContainer(self)
	self:SetLayout("Fill")

	self.label = CreateLabel(self, frame)
	self.button = CreateButton(self, frame)

	-- Callbacks
	frame:SetScript("OnShow", onShowFrame)
	frame:SetScript("OnHide", onHideFrame)
	self.button:SetScript("OnMouseUp", onMouseUpFrameButton)

	return self
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
