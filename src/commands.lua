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
		debug = "debug",
}

local LFGAnnouncementsCommands = {}
function LFGAnnouncementsCommands:OnInitialize()
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


local random = math.random
local function uuid()
    local template ='Player-xxx-xxxxxxxx'
    return string.gsub(template, '[x]', function (c)
        return string.format('%x', random(0, 0xf))
    end)
end




function LFGAnnouncementsCommands:debug(nextPosition, args)
	local command = self:GetArgs(args, 1, nextPosition)
	if not command then
		return
	end

	LFGAnnouncements.DEBUG = true
	LFGAnnouncements.Instances:DisableAll()
	local total = 0
	local found = 0

	if command == "tags" then
		LFGAnnouncements.Instances:ActivateAll()
		local instances = LFGAnnouncements.Instances:GetActivatedInstances()

		for id, _ in pairs(instances) do
			local tags = LFGAnnouncements.Instances:GetInstanceTags(id)
			for i = 1, #tags do
				total = total + 1
				if LFGAnnouncements.Core:OnChatMsgChannel(nil, tags[i], nil, nil, nil, nil, nil, nil, 1, nil, nil, nil, uuid()) then
					found = found + 1
				else
					LFGAnnouncements.dprintf("Failed to find dungeon from tag: %s", tags[i])
				end
			end
		end
	elseif command == "symbols" then
		local symbols = {"\"", "§", "½", "!", "\"", "#", "¤", "%", "&", "/", "(", ")", "=", "?", "`", "´", "@", "£", "$", "€", "{", "[", "]", "}", "\\", "¨", "'", "^", "*", "~", "-", ".", ",", ";", ":", "_", "<", ">", "|",}
		local num_symbols = #symbols

		local order = LFGAnnouncements.Instances:GetInstancesOrder()
		local instance = order[1]
		LFGAnnouncements.Instances:ActivateInstance(instance)

		local tags = LFGAnnouncements.Instances:GetInstanceTags(instance)
		local tag = tags[1]

		total = num_symbols * num_symbols
		found = 0

		for i = 1, num_symbols do
			local startSymbol = symbols[i]
			for j = 1, num_symbols do
				local endSymbol = symbols[j]
				local message = string.format("%s%s%s", startSymbol, tag, endSymbol)
				if LFGAnnouncements.Core:OnChatMsgChannel(nil, string.format("%s%s%s", startSymbol, tag, endSymbol), nil, nil, nil, nil, nil, nil, 1, nil, nil, nil, uuid()) then
					found = found + 1
				else
					LFGAnnouncements.dprintf("Failed to find dungeon from message: %s", message)
				end
			end
		end
	elseif command == "clear" then
		LFGAnnouncements.Core:DeleteAllEntries()
	end

	LFGAnnouncements.dprintf("Expected to find: %d. Found: %d. Diff: %d", total, found, total - found)
end

LFGAnnouncements.Core:RegisterModule("Commands", LFGAnnouncementsCommands, "AceConsole-3.0")
