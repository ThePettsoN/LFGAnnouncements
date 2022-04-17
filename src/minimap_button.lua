local TOCNAME, LFGAnnouncements = ...

local libIcon = LibStub("LibDBIcon-1.0")

local LFGAnnouncementsMinimap = {}
function LFGAnnouncementsMinimap:OnInitialize()
	LFGAnnouncements.MinimapButton = self
end

function LFGAnnouncementsMinimap:OnEnable()
	local db = LFGAnnouncements.DB
	local minimapSettings = db:GetProfileData("minimap")

	local lfgLDB = LibStub("LibDataBroker-1.1"):NewDataObject(TOCNAME, {
		type = "launcher",
		icon = "Interface\\Icons\\inv_misc_groupneedmore",
		OnClick = function(_, button)
			if button == "LeftButton" then
				LFGAnnouncements.UI:Toggle()
			else
				LFGAnnouncements.Options.Toggle()
			end
		end,
		OnTooltipShow = function(tooltip)
			tooltip:SetText("LFG Announcements")
		end
	})
	libIcon:Register(TOCNAME, lfgLDB, minimapSettings)
end

function LFGAnnouncementsMinimap:SetVisibility(value)
	if value then
		libIcon:Show(TOCNAME)
	else
		libIcon:Hide(TOCNAME)
	end
end

function LFGAnnouncementsMinimap:SetPositionLocked(value)
	if value then
		libIcon:Lock(TOCNAME)
	else
		libIcon:Unlock(TOCNAME)
	end
end

LFGAnnouncements.Core:RegisterModule("MinimapButton", LFGAnnouncementsMinimap)
