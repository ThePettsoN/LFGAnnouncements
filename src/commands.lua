local _, LFGAnnouncements = ...

local COMMANDS_LOOKUP = {
		show = "show",
		open = "show",
		hide = "hide",
		close = "hide",
		enable = "enable",
		disable = "disable",
		settings = "settings",
		config = "settings",
		options = "settings",
}

local LFGAnnouncementsCommands = {}
function LFGAnnouncementsCommands:OnInitialize()
	LFGAnnouncements.Commands = self
end

function LFGAnnouncementsCommands:OnEnable()
	self:RegisterChatCommand("lfga", "OnChatCommand")
end

-- TODO: Move to own file?
function LFGAnnouncementsCommands:OnChatCommand(args)
	local command, nextPosition = self:GetArgs(args, 1)
	if not command then
		command = COMMANDS_LOOKUP.show
	end

	local funcName = COMMANDS_LOOKUP[command]
	if not funcName then
		funcName = COMMANDS_LOOKUP.show
	end

	self[funcName](self, nextPosition, args)
end

function LFGAnnouncementsCommands:show()
	local module = LFGAnnouncements.UI
	module:Show()
end

function LFGAnnouncementsCommands:hide()
	local module = LFGAnnouncements.UI
	module:Hide()
end

function LFGAnnouncementsCommands:enable(nextPosition, args)
	local dungeonId = self:GetArgs(args, 1, nextPosition)
	if not dungeonId then
		return
	end

	local module = LFGAnnouncements.Dungeons
	if dungeonId == "all" then
		module:ActivateAll()
	elseif module:IsValid(dungeonId) then
		module:SetActivated(dungeonId, true)
	end
end

function LFGAnnouncementsCommands:disable(nextPosition, args)
	local dungeonId = self:GetArgs(args, 1, nextPosition)
	if not dungeonId then
		return
	end

	local module = LFGAnnouncements.Dungeons
	if dungeonId == "all" then
		module:DisableAll()
	elseif module:IsValid(dungeonId) then
		module:SetActivated(dungeonId, false)
	end
end

function LFGAnnouncementsCommands:settings()
	local module = LFGAnnouncements.Options
	module.Toggle()
end

LFGAnnouncements.Core:RegisterModule("Commands", LFGAnnouncementsCommands, "AceConsole-3.0")