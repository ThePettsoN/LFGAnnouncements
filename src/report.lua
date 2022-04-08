local _, LFGAnnouncements = ...
local AceGUI = LibStub("AceGUI-3.0", "AceEvent-3.0")

local LFGAnnouncementsReport = {}
function LFGAnnouncementsReport:OnInitialize()
	LFGAnnouncements.Announcement = self
	self:RegisterMessage("OnDungeonEntry", "OnDungeonEntry")
end

function LFGAnnouncementsReport:OnEnable()
	self._dungeons = LFGAnnouncements.Dungeons
	self._db = LFGAnnouncements.DB

	self:_createUI()
end

local function onClick(frame, button)
	LFGAnnouncements.UI:Show()
	LFGAnnouncements.UI:CloseAll()
	LFGAnnouncements.UI:OpenGroup(frame.dungeonId)
end

function LFGAnnouncementsReport:_scheduleToasterTimer()
	self._toasterTimer = self:ScheduleTimer(function()
		self._toaster:StartFadeOut()
	end, 5)
end

function LFGAnnouncementsReport:_cancelToasterTimer()
	if self._toasterTimer then
		self:CancelTimer(self._toasterTimer)
	end
end

function LFGAnnouncementsReport:_createUI()
	self._toaster = AceGUI:Create("Toaster")
	self._toaster:SetLayout("Fill")
	self._toaster:SetTitle("LFGAnnouncements")
	self._toaster.titletext:SetWordWrap(false)
	self._toaster.titletext:SetNonSpaceWrap(false)
	self._toaster:SetCallback("StopMoving", function (widget, event, x, y)
		self._db:SetProfileData("x", floor(x + 0.5), "position")
		self._db:SetProfileData("y", floor(y + 0.5), "position")
		self._db:SetProfileData("stored", true, "position")

		if self._toaster:IsShown() and self._toasterTimer then
			self:_scheduleToasterTimer()
		end

	end)
	self._toaster:SetCallback("StartMoving", function (widget, event)
		self:_cancelToasterTimer()
		self._toaster:SetAlpha(1)
		self._toaster:StopFadeOut()
	end)

	self._label = AceGUI:Create("Label")
	self._label:SetText("Label")
	self._label.label:SetWordWrap(false)
	self._label.label:SetNonSpaceWrap(false)
	self._toaster:AddChild(self._label)

	local position = self._db:GetProfileData("position")
	if position.stored then
		self._toaster:ClearAllPoints()
		self._toaster:SetPoint("BOTTOMLEFT", position.x, position.y)
	end
	self._toaster:Hide()

	self._button = CreateFrame("Button", nil, self._toaster.frame)
	self._button:SetPoint("TOPLEFT", 0, 0)
	self._button:SetPoint("BOTTOMRIGHT", 0, 0)
	self._button:SetScript("OnMouseDown", onClick)
end

function LFGAnnouncementsReport:OnDungeonEntry(event, dungeonId, difficulty, message, time, authorGUID, reason)
	if reason ~= LFGAnnouncements.DungeonEntryReason.NEW then
		return
	end

	-- if self._db:GetProfileData("announcements", "chat") then
		-- print(message)
	-- end

	if self._db:GetProfileData("announcements", "toaster") then
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

	if self._db:GetProfileData("announcements", "sound") then
		PlaySound(self._db:GetProfileData("announcements", "sound_id"), "master")
	end
end

LFGAnnouncements.Core:RegisterModule("Report", LFGAnnouncementsReport, "AceEvent-3.0", "AceTimer-3.0")