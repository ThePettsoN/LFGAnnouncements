local _, LFGAnnouncements = ...
local L = LFGAnnouncements.Localize
local AceGUI = LibStub("AceGUI-3.0", "AceEvent-3.0")
local PUtils = LFGAnnouncements.PUtils
local GameUtils = PUtils.Game

local InviteUnit = InviteUnit
local GetCursorPosition = GetCursorPosition

local stringformat = string.format

local LFGAnnouncementsContextMenu = {}

if not StaticPopupDialogs.LFGA_COPY_URL then
	StaticPopupDialogs.LFGA_COPY_URL = {
		text = "URL",
		button1 = L("ui_close_btn"),
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
		wide = true,
		hasEditBox = true,
		OnShow = function(self, data)
			self.editBox:SetText(data.url)
			self.editBox:HighlightText()
			self.editBox:SetWidth(self:GetWidth() - 32)
		end,
		EditBoxOnEscapePressed = function(self)
			self:GetParent():Hide()
		end,
		EditBoxOnEnterPressed = function(self)
			self:GetParent():Hide()
		end,
	}
end

local function OnClickWho(widget, event, button)
	local self = widget.parent.menu
	C_FriendList.SendWho(self._author)
	self._frame:Hide()
end

local function OnClickWhisper(widget, event, button)
	local self = widget.parent.menu
	ChatFrame_OpenChat(stringformat("/w %s ", self._author))
	self._frame:Hide()
end

local function OnClickInvite(widget, event, button)
	local self = widget.parent.menu
	InviteUnit(self._author)
	self._frame:Hide()
end

local function OnClickIgnore(widget, event, button)
	local self = widget.parent.menu
	C_FriendList.AddIgnore(self._author)
	self._frame:Hide()
end

local popup_data = {}
local function OnClickUrl(widget, event, button)
	local self = widget.parent.menu
	if self._urlLink then
		popup_data.url = stringformat("%s", self._urlLink)
		StaticPopup_Show("LFGA_COPY_URL", "", "", popup_data)
	end
	self._frame:Hide()
end

local data = {}
local function OnClickArmory(widget, event, button)
	local self = widget.parent.menu
	if self._armoryLink then
		popup_data.url = stringformat("%s", self._armoryLink)
		StaticPopup_Show("LFGA_COPY_URL", "", "", popup_data)
	end
	self._frame:Hide()
end

function LFGAnnouncementsContextMenu:Init(fontSettings)
	self._fontSettings = fontSettings
end

local function CreateLabel(text, OnClickCallback, offsetY)
	local label = AceGUI:Create("InteractiveLabel")
	label.frame.offsetY = offsetY or -4
	label:SetCallback("OnClick", OnClickCallback)
	label:SetText(text)
	label:SetHighlight("Interface\\QuestFrame\\UI-QuestTitleHighlight")
	label:SetFullWidth(true)
	return label
end

function LFGAnnouncementsContextMenu:_createUI()
	self._frame = AceGUI:Create("Frame")
	self._frame:SetTitle("FRAME")
	self._frame.frame:SetFrameStrata("TOOLTIP")
	self._frame:SetLayout("OffsetList")
	self._frame:SetWidth(200)
	self._frame:SetHeight(200)
	self._frame:EnableResize(false)
	self._frame.frame:SetBackdropColor(0.1, 0.1, 0.1, 1)
	self._frame.frame:SetBackdropBorderColor(0, 0, 0)
	self._frame.menu = self

	self._who = CreateLabel(L("entry_context_menu_who_name"), OnClickWho)
	self._whisper = CreateLabel(L("entry_context_menu_whisper_name"), OnClickWhisper)
	self._invite = CreateLabel(L("entry_context_menu_invite_name"), OnClickInvite)
	self._ignore = CreateLabel(L("entry_context_menu_ignore_name"), OnClickIgnore)
	self._url = CreateLabel(L("entry_context_menu_copy_url_name"), OnClickUrl)
	self._armory = CreateLabel(L("entry_context_menu_copy_armory_name"), OnClickArmory)

	self._frame:AddChild(self._who)
	self._frame:AddChild(self._whisper)
	self._frame:AddChild(self._invite)
	self._frame:AddChild(self._ignore)
	self._frame:AddChild(self._url)
	self._frame:AddChild(self._armory)
end

local URL_PATTERNS = {
	"(%a+://%S+%s?)",
	"(www%.[_A-Za-z0-9-]+%.%S+%s?)",
}

function LFGAnnouncementsContextMenu:_parseUrl(message)
	for i = 1, #URL_PATTERNS do
		local _, _, match = string.find(message, URL_PATTERNS[i])
		return match
	end
end

function LFGAnnouncementsContextMenu:SetFont(font, size, flags)
	local settings = self._fontSettings or {}
	settings.path = font and font or settings.path
	settings.size = size and size or settings.size
	settings.flags = flags and flags or settings.flags

	if not self._frame then
		return
	end

	self._who:SetFont(settings.path, settings.size, settings.flags)
	self._whisper:SetFont(settings.path, settings.size, settings.flags)
	self._invite:SetFont(settings.path, settings.size, settings.flags)
	self._ignore:SetFont(settings.path, settings.size, settings.flags)
	self._url:SetFont(settings.path, settings.size, settings.flags)

	-- Update Size of frame
	local whisperLabel = self._whisper.label

	local requiredWidth = whisperLabel:GetStringWidth() + 4
	local contentWidth = self._frame.content:GetWidth()
	local frameWidth = self._frame.frame:GetWidth()

	self._frame.frame:SetWidth(math.max(200, (frameWidth - contentWidth) + requiredWidth))

	local requiredHeight = whisperLabel:GetHeight() * 5 + 40
	local contentHeight = self._frame.content:GetHeight()
	local frameHeight = self._frame.frame:GetHeight()
	self._frame.frame:SetHeight(requiredHeight + frameHeight - contentHeight)
end

local armoryUrlPrefix
local function getArmoryLink(author)
	if armoryUrlPrefix == false then
		return nil
	end

	if not armoryUrlPrefix then
		local region
		local regionId = GetCurrentRegion()
		if regionId == 1 then
			region = "us"
		elseif regionId == 3 then
			region = "eu"
		end
		local realmSlug = GetRealmName():gsub("[%p%c]", ""):gsub("[%s]", "-"):lower()

		if region then
			armoryUrlPrefix = string.format("https://classicwowarmory.com/character/%s/%s/", region, realmSlug) .. "%s"
		else
			armoryUrlPrefix = false
		end
	end

	return string.format(armoryUrlPrefix, author)
end

function LFGAnnouncementsContextMenu:Show(author, message)
	local created
	if not self._frame then
		created = true
		self:_createUI()
	end

	local uiScale, x, y = UIParent:GetEffectiveScale(), GetCursorPosition()

	self._frame:ClearAllPoints()
	self._frame:SetPoint("TOPLEFT", "UIParent", "BOTTOMLEFT", x / uiScale, y / uiScale)
	self._frame:SetTitle(author)

	self._who:SetText(L("entry_context_menu_who", author))
	self._who:SetText(L("entry_context_menu_whisper", author))
	self._who:SetText(L("entry_context_menu_invite", author))
	self._who:SetText(L("entry_context_menu_who", author))

	self._author = author

	local url = self:_parseUrl(message)
	if url then
		self._urlLink = url
		self._url:SetDisabled(false)
	else
		self._url:SetDisabled(true)
		self._urlLink = ""
	end

	local armoryUrl = getArmoryLink(author)
	if armoryUrl then
		self._armoryLink = armoryUrl
		self._armory:SetDisabled(false)
	else
		self._armoryLink = ""
		self._armory:SetDisabled(true)
	end

	self._frame:Show()

	-- Need to set found (and update size) after it's visible to make sure all widgets exist
	if created then
		self:SetFont()
	end
end

function LFGAnnouncementsContextMenu:Hide()
	if self._frame then
		self._frame:Hide()
	end
end



LFGAnnouncements.ContextMenu = LFGAnnouncementsContextMenu
