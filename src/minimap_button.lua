local _, LFGAnnouncements = ...
local AceGUI = LibStub("AceGUI-3.0", "AceEvent-3.0")

local LFGAnnouncementsMinimap = {}
function LFGAnnouncementsMinimap:OnInitialize()
	LFGAnnouncements.MinimapButton = self
end

function LFGAnnouncementsMinimap:OnEnable()
	local db = LFGAnnouncements.DB
	local minimapSettings = db:GetProfileData("minimap")

	local lfgLDB = LibStub("LibDataBroker-1.1"):NewDataObject("LFGAnnouncements", {
		type = "launcher",
		icon = "Interface\\Icons\\inv_misc_groupneedmore",
		OnClick = function(_, button)
			if button == "LeftButton" then
				LFGAnnouncements.UI:Toggle()
			else
			end
		end,
		OnTooltipShow = function(tooltip)
			tooltip:SetText("LFG Announcements")
		end
	})
	LibStub("LibDBIcon-1.0"):Register("LFGAnnouncements", lfgLDB, minimapSettings)
end

LFGAnnouncements.Core:RegisterModule("MinimapButton", LFGAnnouncementsMinimap)
