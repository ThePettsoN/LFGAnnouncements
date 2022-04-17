local TOCNAME, LFGAnnouncements = ...

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")

-- Lua APIs
local pairs = pairs

local LFGAnnouncementsOptions = {
	optionTemplates = {},
}
LFGAnnouncements.Options = LFGAnnouncementsOptions

function LFGAnnouncementsOptions:OnInitialize()
end

function LFGAnnouncementsOptions:OnEnable()
	AceConfig:RegisterOptionsTable(TOCNAME, self.GetConfig)
	AceConfigDialog:AddToBlizOptions(TOCNAME, "LFGAnnouncements")
end

function LFGAnnouncementsOptions.Toggle()
	if AceConfigDialog.OpenFrames[TOCNAME] then
		AceConfigDialog:Close(TOCNAME)
	else
		AceConfigDialog:Open(TOCNAME)
	end
end

local config_template = {
	type = "group",
	name = "LFGAnnouncements",
	args = {},
}
function LFGAnnouncementsOptions.GetConfig()
	local args = config_template.args
	for name, func in pairs(LFGAnnouncementsOptions.optionTemplates) do
		args[name] = func()
	end

	config_template.args.profiles = AceDBOptions:GetOptionsTable(LFGAnnouncements.DB._db)
	return config_template
end

function LFGAnnouncementsOptions.AddOptionTemplate(name, template_func)
	assert(not LFGAnnouncementsOptions.optionTemplates[name])
	LFGAnnouncementsOptions.optionTemplates[name] = template_func
end


LFGAnnouncements.Core:RegisterModule("Options", LFGAnnouncementsOptions)
