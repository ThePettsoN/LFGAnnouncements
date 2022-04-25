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
	local instanceId = self:GetArgs(args, 1, nextPosition)
	if not instanceId then
		return
	end

	local module = LFGAnnouncements.Instances
	if instanceId == "all" then
		module:ActivateAll()
	elseif module:IsValid(instanceId) then
		module:ActivateInstance(instanceId)
	end
end

function LFGAnnouncementsCommands:disable(nextPosition, args)
	local instanceId = self:GetArgs(args, 1, nextPosition)
	if not instanceId then
		return
	end

	local module = LFGAnnouncements.Instances
	if instanceId == "all" then
		module:DisableAll()
	elseif module:IsValid(instanceId) then
		module:DeactivateInstance(instanceId)
	end
end

function LFGAnnouncementsCommands:settings()
	local module = LFGAnnouncements.Options
	module.Toggle()
end

LFGAnnouncements.Core:RegisterModule("Commands", LFGAnnouncementsCommands, "AceConsole-3.0")