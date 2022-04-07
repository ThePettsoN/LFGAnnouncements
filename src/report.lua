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

function LFGAnnouncementsReport:_createUI()
	self._frame = AceGUI:Create("Toaster")
	self._frame:SetLayout("Fill")
	self._frame:SetTitle("LFGAnnouncements")
	self._frame.titletext:SetWordWrap(false)
	self._frame.titletext:SetNonSpaceWrap(false)
	self._frame:SetCallback("StopMoving", function (widget, event, x, y)
		self._db:SetProfileData("x", floor(x + 0.5), "position")
		self._db:SetProfileData("y", floor(y + 0.5), "position")
		self._db:SetProfileData("stored", true, "position")
	end)

	self._label = AceGUI:Create("Label")
	self._label:SetText("Label")
	self._label.label:SetWordWrap(false)
	self._label.label:SetNonSpaceWrap(false)
	self._frame:AddChild(self._label)

	local position = self._db:GetProfileData("position")
	if position.stored then
		self._frame:ClearAllPoints()
		self._frame:SetPoint("BOTTOMLEFT", position.x, position.y)
	end


	self._button = CreateFrame("Button", nil, self._frame.frame)
	self._button:SetPoint("TOPLEFT", 0, 0)
	self._button:SetPoint("BOTTOMRIGHT", 0, 0)
	self._button:SetScript("OnMouseDown", onClick)

	self._frame:Hide()
end

local fadeInfo = {
	mode = "OUT",
	timeToFade = 1,
	startAlpha = 1,
	endAlpha = 0,
	finishedFunc = function(frame)
		frame:Hide()
	end
}
function LFGAnnouncementsReport:OnDungeonEntry(event, dungeonId, difficulty, message, time, authorGUID, reason)
	if reason ~= LFGAnnouncements.DungeonEntryReason.NEW then
		return
	end

	-- if self._db:GetProfileData("announcements", "chat") then
		-- print(message)
	-- end

	if self._db:GetProfileData("announcements", "toaster") then
		if self._timer then
			self:CancelTimer(self._timer)
		end

		self._frame:SetTitle(self._dungeons:GetDungeonName(dungeonId))
		self._button.dungeonId = dungeonId
		self._label:SetText(message)
		self._frame:Show()
		self._frame.frame:SetAlpha(1)
		self._timer = self:ScheduleTimer(function()
			fadeInfo.finishedArg1 = self._frame
			UIFrameFade(self._frame.frame, fadeInfo)
		end, 4)
	end

	if self._db:GetProfileData("announcements", "sound") then
		PlaySound(self._db:GetProfileData("announcements", "sound_id"), "master")
	end
end

LFGAnnouncements.Core:RegisterModule("Report", LFGAnnouncementsReport, "AceEvent-3.0", "AceTimer-3.0")