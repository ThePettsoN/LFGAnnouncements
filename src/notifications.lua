local _, LFGAnnouncements = ...

-- Lua APIs
local floor = floor
local type = type
local max = max

-- WoW APIs
local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local PlaySound = PlaySound
local PlaySoundFile = PlaySoundFile
local FlashClientIcon = FlashClientIcon

local AceGUI = LibStub("AceGUI-3.0", "AceEvent-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

local MAX_TOASTERS = 10
local NEXT_TOASTER = 1

local function onClickToaster(toaster)
	local ui = LFGAnnouncements.UI
	ui:Show()
	ui:CloseAll()
	ui:OpenGroup(toaster.instanceId)
end

local LFGAnnouncementsNotification = {}
function LFGAnnouncementsNotification:OnInitialize()
	self:RegisterMessage("OnInstanceEntry", "OnInstanceEntry")
end

function LFGAnnouncementsNotification:OnEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnteringWorld")

	self._instances = LFGAnnouncements.Instances
	self._db = LFGAnnouncements.DB

	self._fontSettings = LFGAnnouncements.DB:GetProfileData("general", "font")
	self._enabledForInstanceTypes = self._db:GetProfileData("notifications", "general", "enable_in_instance")
	self._numAllowedToasters = self._db:GetProfileData("notifications", "toaster", "num_toasters")

	local soundId = self._db:GetProfileData("notifications", "sound", "id")
	local soundPath = self._db:GetProfileData("notifications", "sound", "path")
	self:SetSound(soundId, soundPath, true)

	self:_createUI()
end

function LFGAnnouncementsNotification:OnStopMoving(toaster, event, x, y)
	self._db:SetProfileData("x", floor(x + 0.5), "notifications", "toaster", "position")
	self._db:SetProfileData("y", floor(y + 0.5), "notifications", "toaster", "position")
	self._db:SetProfileData("stored", true, "notifications", "toaster", "position")

	if toaster:IsShown() then
		toaster:Trigger(self._toasterDuration)
	end
end

function LFGAnnouncementsNotification:OnFadeOutComplete(toaster)
	self._freeSlots[toaster.id] = true
end

local function SetPosition(toasters, x, y, offset, anchor)
	local prevToaster = toasters[1]
	prevToaster:ClearAllPoints()
	prevToaster:SetPoint(anchor or "BOTTOMLEFT", x, y)

	for i = 2, MAX_TOASTERS do
		local toaster = toasters[i]
		toaster:ClearAllPoints()
		toaster:SetPoint("BOTTOMLEFT", prevToaster.frame, 0, 0 + offset)

		prevToaster = toaster
	end
end

function LFGAnnouncementsNotification:_createUI()
	local size = self._db:GetProfileData("notifications", "toaster", "size")

	self._toasterDuration = self._db:GetProfileData("notifications", "toaster", "duration")

	self._freeSlots = {}
	self._toasters = {}
	for i = 1, MAX_TOASTERS do
		local toaster = AceGUI:Create("Toaster")
		toaster:SetSize(size.width, size.height)
		toaster:SetTitle("LFGAnnouncements")
		toaster:SetId(i)
		toaster:SetLabelFontSettings(self._fontSettings.path, self._fontSettings.size, self._fontSettings.flags)

		toaster:SetCallback("StopMoving", function(widget, event, x, y) self:OnStopMoving(widget, event, x, y) end)
		toaster:SetCallback("FadeOutComplete", function(widget) self:OnFadeOutComplete(widget) end)
		toaster:SetCallback("OnClickBody", onClickToaster)
		toaster:Hide()
		self._toasters[i] = toaster
		self._freeSlots[i] = true
	end
	self._toasters[1]:SetIsMovable(true)

	local offset = size.height + 2
	local toasterPosition = self._db:GetProfileData("notifications", "toaster", "position")
	if toasterPosition.stored then
		SetPosition(self._toasters, toasterPosition.x, toasterPosition.y, offset)
	else
		SetPosition(self._toasters, 0, 0, offset, "CENTER")
	end
end

function LFGAnnouncementsNotification:_triggerSound()
	if self._soundPath then
		PlaySoundFile(self._soundPath, "master")
	else
		PlaySound(self._soundId, "master")
	end
end

function LFGAnnouncementsNotification:_triggerToaster(instanceId, message)
	local index
	for i = 1, #self._freeSlots do
		if i > self._numAllowedToasters then
			return
		end

		if self._freeSlots[i] then
			index = i
			break
		end
	end

	if not index then
		return
	end

	local toaster = self._toasters[index]
	toaster:SetInstanceId(instanceId)
	toaster:SetText(message)
	toaster:SetTitle(self._instances:GetInstanceName(instanceId))
	toaster:Trigger(self._toasterDuration)

	self._freeSlots[index] = false
end

function LFGAnnouncementsNotification:SetNotificationInInstance(key, value)
	self._enabledForInstanceTypes[key] = value
	self._db:SetProfileData(key, value, "notifications", "general", "enable_in_instance")
end

function LFGAnnouncementsNotification:SetSound(key, path, skipSave)
	if LSM:IsValid("sound", key) then
		self._soundPath = path
		self._soundId = nil
	else
		self._soundPath = nil
		if type(key) == "number" then
			self._soundId = key
		else
			self._soundId = 3081
			skipSave = false
		end
	end

	if not skipSave then
		self._db:SetProfileData("id", key, "notifications", "sound")
		self._db:SetProfileData("path", path, "notifications", "sound")
	end
end

function LFGAnnouncementsNotification:SetToasterDuration(duration)
	self._toasterDuration = duration
	self._db:SetProfileData("duration", duration, "notifications", "toaster")
end

function LFGAnnouncementsNotification:SetToasterSize(width, height)
	if width then
		for i = 1, #self._toasters do
			self._toasters[i]:SetWidth(width)
		end
		self._db:SetProfileData("width", width, "notifications", "toaster", "size")
	end
	if height then
		for i = 1, #self._toasters do
			self._toasters[i]:SetHeight(height)
		end
		self._db:SetProfileData("height", height, "notifications", "toaster", "size")
	end
end

function LFGAnnouncementsNotification:SetNumToasters(num)
	self._numAllowedToasters = num
	self._db:SetProfileData("num_toasters", num, "notifications", "toaster")
end

function LFGAnnouncementsNotification:SetFont(font, size, flags)
	local settings = self._fontSettings
	settings.path = font and font or settings.path
	settings.size = size and size or settings.size
	settings.flags = flags and flags or settings.flags
	LFGAnnouncements.DB:SetProfileData("font", settings, "general") -- TODO: currently calling this twice in both UI and Notifications. Need to move any db save out of modules and into templates?

	for i = 1, #self._toasters do
		self._toasters[i].label:SetFont(settings.path, settings.size, settings.flags)
	end
end

function LFGAnnouncementsNotification:OnPlayerEnteringWorld(event, isInitialLogin, isReloadingUi)
	local _, instanceType = GetInstanceInfo()
	self._instanceType = instanceType == "none" and "world" or instanceType
end

function LFGAnnouncementsNotification:OnInstanceEntry(event, instanceId, difficulty, message, time, totalTime, authorGUID, reason)
	if reason ~= LFGAnnouncements.Core.DUNGEON_ENTRY_REASON.NEW then
		return
	end

	if not self._enabledForInstanceTypes[self._instanceType] then
		return
	end

	-- if self._db:GetProfileData("notifications", "chat") then
		-- print(message)
	-- end

	if self._db:GetProfileData("notifications", "toaster", "enabled") then
		self:_triggerToaster(instanceId, message)
	end

	if self._db:GetProfileData("notifications", "sound", "enabled") then
		self:_triggerSound()
	end

	if self._db:GetProfileData("notifications", "flash", "enabled") then
		FlashClientIcon()
	end
end

LFGAnnouncements.Core:RegisterModule("Notifications", LFGAnnouncementsNotification, "AceEvent-3.0")
