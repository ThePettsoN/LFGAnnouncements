local _, LFGAnnouncements = ...

-- Lua APIs
local floor = floor
local type = type

-- WoW APIs
local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local PlaySound = PlaySound
local PlaySoundFile = PlaySoundFile
local FlashClientIcon = FlashClientIcon

local AceGUI = LibStub("AceGUI-3.0", "AceEvent-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

local function onClickToaster(frame)
	local ui = LFGAnnouncements.UI
	ui:Show()
	ui:CloseAll()
	ui:OpenGroup(frame.dungeonId)
end

local LFGAnnouncementsNotification = {}
function LFGAnnouncementsNotification:OnInitialize()
	LFGAnnouncements.Notifications = self
	self:RegisterMessage("OnDungeonEntry", "OnDungeonEntry")
end

function LFGAnnouncementsNotification:OnEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnteringWorld")

	self._dungeons = LFGAnnouncements.Dungeons
	self._db = LFGAnnouncements.DB

	self._enabledForInstanceTypes = self._db:GetProfileData("notifications", "general", "enable_in_instance")

	local soundId = self._db:GetProfileData("notifications", "sound", "id")
	local soundPath = self._db:GetProfileData("notifications", "sound", "path")
	self:SetSound(soundId, soundPath, true)

	self:_createUI()
end

function LFGAnnouncementsNotification:_scheduleToasterTimer()
	self._toasterTimer = self:ScheduleTimer(function()
		self._toaster:StartFadeOut()
	end, self._toasterDuration)
end

function LFGAnnouncementsNotification:_cancelToasterTimer()
	if self._toasterTimer then
		self:CancelTimer(self._toasterTimer)
	end
end

function LFGAnnouncementsNotification:_createUI()
	self._toaster = AceGUI:Create("Toaster")
	self._toaster:SetLayout("Fill")
	self._toaster:SetTitle("LFGAnnouncements")
	self._toaster.titletext:SetWordWrap(false)
	self._toaster.titletext:SetNonSpaceWrap(false)
	self._toaster:SetCallback("StopMoving", function (widget, event, x, y)
		self._db:SetProfileData("x", floor(x + 0.5), "notifications", "toaster", "position")
		self._db:SetProfileData("y", floor(y + 0.5), "notifications", "toaster", "position")
		self._db:SetProfileData("stored", true, "notifications", "toaster", "position")

		if self._toaster:IsShown() and self._toasterTimer then
			self:_scheduleToasterTimer()
		end

	end)
	self._toaster:SetCallback("StartMoving", function (widget, event)
		self:_cancelToasterTimer()
		self._toaster:SetAlpha(1)
		self._toaster:StopFadeOut()
	end)
	self._toasterDuration = self._db:GetProfileData("notifications", "toaster", "duration")

	self._label = AceGUI:Create("Label")
	self._label:SetText("Label")
	self._label.label:SetWordWrap(false)
	self._label.label:SetNonSpaceWrap(false)
	self._toaster:AddChild(self._label)

	local toasterPosition = self._db:GetProfileData("notifications", "toaster", "position")
	if toasterPosition.stored then
		self._toaster:ClearAllPoints()
		self._toaster:SetPoint("BOTTOMLEFT", toasterPosition.x, toasterPosition.y)
	end
	self._toaster:Hide()

	self._button = CreateFrame("Button", nil, self._toaster.frame)
	self._button:SetPoint("TOPLEFT", 0, 0)
	self._button:SetPoint("BOTTOMRIGHT", 0, 0)
	self._button:SetScript("OnMouseDown", onClickToaster)
end

function LFGAnnouncementsNotification:_triggerSound()
	if self._soundPath then
		PlaySoundFile(self._soundPath, "master")
	else
		PlaySound(self._soundId, "master")
	end
end

function LFGAnnouncementsNotification:_triggerToaster(dungeonId, message)
	self:_cancelToasterTimer()

	self._button.dungeonId = dungeonId
	self._label:SetText(message)

	self._toaster:SetTitle(self._dungeons:GetDungeonName(dungeonId))
	self._toaster:Show()
	self._toaster:SetAlpha(1)

	if not self._toaster:IsMoving() then
		self:_scheduleToasterTimer()
	end
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

function LFGAnnouncementsNotification:OnPlayerEnteringWorld(event, isInitialLogin, isReloadingUi)
	local _, instanceType = GetInstanceInfo()
	self._instanceType = instanceType == "none" and "world" or instanceType
end

function LFGAnnouncementsNotification:OnDungeonEntry(event, dungeonId, difficulty, message, time, authorGUID, reason)
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
		self:_triggerToaster(dungeonId, message)
	end

	if self._db:GetProfileData("notifications", "sound", "enabled") then
		self:_triggerSound()
	end

	if self._db:GetProfileData("notifications", "flash", "enabled") then
		FlashClientIcon()
	end
end

LFGAnnouncements.Core:RegisterModule("Notification", LFGAnnouncementsNotification, "AceEvent-3.0", "AceTimer-3.0")