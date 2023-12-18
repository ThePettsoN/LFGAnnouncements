local AceGUI = LibStub("AceGUI-3.0")
local AceTimer = LibStub("AceTimer-3.0")

-- Lua APIs
local pairs = pairs
local assert = assert
local type = type

-- WoW APIs
local PlaySound = PlaySound
local CreateFrame = CreateFrame
local UIParent = UIParent
local CopyTable = CopyTable
local UIFrameFade = UIFrameFade
local UIFrameFadeRemoveFrame = UIFrameFadeRemoveFrame
local BackdropTemplateMixin = BackdropTemplateMixin
local GameFontNormal = GameFontNormal

----------------
-- Main Frame --
----------------
--[[
	Events :
		OnClose

]]
do
	local Type = "Toaster"
	local Version = 6

	-- AceGUI function --
	local function OnAcquire(self)
		self.frame:SetParent(UIParent)
		self.frame:SetFrameStrata("FULLSCREEN_DIALOG")
		self:ApplyStatus()
		self:Show()
	end

	local function ApplyStatus(self)
		local status = self.status or self.localstatus
		local frame = self.frame
		self:SetWidth(status.width or 300)
		self:SetHeight(status.height or 50)
		if status.top and status.left then
			frame:SetPoint("TOP", UIParent,"BOTTOM", 0, status.top)
			frame:SetPoint("LEFT", UIParent,"LEFT", status.left, 0)
		else
			frame:SetPoint("CENTER", UIParent, "CENTER")
		end
	end

	local function Hide(self)
		self.frame:Hide()
	end

	local function Show(self)
		self.frame:Show()
	end

	local function OnRelease(self)
		self.status = nil
		for k in pairs(self.localstatus) do
			self.localstatus[k] = nil
		end
	end

	local function SetStatusTable(self, status)
		assert(type(status) == "table")
		self.status = status
		self:ApplyStatus()
	end

	local function OnWidthSet(self, width)
		local content = self.content
		local contentwidth = width - 34
		if contentwidth < 0 then
			contentwidth = 0
		end
		content:SetWidth(contentwidth)
		content.width = contentwidth
	end

	local function OnHeightSet(self, height)
		local content = self.content
		local contentheight = height - 57
		if contentheight < 0 then
			contentheight = 0
		end
		content:SetHeight(contentheight)
		content.height = contentheight
	end

	-- Private Functions --
	local function CancelFadeout(self)
		if UIFrameIsFading(self.frame) then 
			UIFrameFadeRemoveFrame(self.frame)
		end

		if self.timer then
			AceTimer:CancelTimer(self.timer)
		end
	end

	-- Callbacks --
	local function onClickCloseButton(button)
		PlaySound(799)
		button.obj:Hide()
	end

	local function onMouseDownFrame(frame)
		AceGUI:ClearFocus()
	end

	local function onShowFrame(frame)
		frame.obj:Fire("OnShow")
	end

	local function onHideFrame(frame)
		frame.obj:Fire("OnClose")
	end

	local function onMouseDownTitle(title)
		local frame = title:GetParent()
		frame:StartMoving()
		AceGUI:ClearFocus()

		local self = frame.obj
		self._isMoving = true
		CancelFadeout(self)
		self:Fire("StartMoving")
	end

	local function onMouseUpTitle(title)
		local frame = title:GetParent()
		frame:StopMovingOrSizing()
		local self = frame.obj
		local status = self.status or self.localstatus
		status.width = frame:GetWidth()
		status.height = frame:GetHeight()
		status.top = frame:GetTop()
		status.left = frame:GetLeft()

		self._isMoving = false
		self:Fire("StopMoving", status.left, status.top - status.height)
	end

	local function onFadeOutComplete(self)
		self.fadeInfo.fadeTimer = nil
		UIFrameFade(self.frame, self.fadeInfo)
	end

	local function onMouseUpFrameButton(button)
		button.obj:Fire("OnClickBody")
	end

	-- Public Functions --
	local function SetTitle(self, title)
		self.titletext:SetText(title)
	end

	local function SetSize(self, width, height)
		self:SetWidth(width)
		self:SetHeight(height)
	end

	local function SetIsMovable(self, isMovable)
		if isMovable then
			self.frame:SetMovable(true)
			self.title:EnableMouse()
			self.title:SetScript("OnMouseDown", onMouseDownTitle)
			self.title:SetScript("OnMouseUp", onMouseUpTitle)
		end
	end

	local function SetId(self, id)
		self.id = id
	end

	local function SetAlpha(self, alpha)
		self.frame:SetAlpha(alpha)
	end

	local function IsMoving(self)
		return self._isMoving
	end

	local function SetFadeOutDuration(self, duration)
		FadeInfo.timeToFade = duration
	end
	
	local function Trigger(self, duration)
		self:Show()
		self:SetAlpha(1)

		CancelFadeout(self)
		self.timer = AceTimer:ScheduleTimer(onFadeOutComplete, duration, self)
	end

	local function SetLabelFontSettings(self, path, size, flags)
		self.label:SetFont(path, size, flags)
	end

	local function SetText(self, text)
		self.label:SetText(text)
	end

	local function SetInstanceId(self, instanceId)
		self.instanceId = instanceId
	end


	-- TODO: Move this into a general place where UI can use it as well
	local PaneBackdrop = {
		edgeFile = "Interface\\AddOns\\LFGAnnouncements\\Media\\Textures\\White8x8",
		bgFile = "Interface\\AddOns\\LFGAnnouncements\\Media\\Textures\\White8x8",
		edgeSize = 1,
	}

	local function CreateTitle(self, frame)
		local closeButton = CreateFrame("Button", "CloseButtonFrame", frame, "UIPanelCloseButton")
		closeButton:SetPoint("TOPRIGHT", 0, 0)
		closeButton:SetScript("OnClick", onClickCloseButton)
		closeButton.obj = self

		local titlebg = frame:CreateTexture(nil, "BACKGROUND")
		titlebg:SetPoint("TOPLEFT", 0, 0)
		titlebg:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
		titlebg:SetPoint("BOTTOMRIGHT", closeButton, "BOTTOMRIGHT", 10, 4)

		local dialogbg = frame:CreateTexture(nil, "BACKGROUND")
		dialogbg:SetPoint("TOPLEFT", titlebg, "BOTTOMLEFT", 0, 0)
		dialogbg:SetPoint("BOTTOMRIGHT", 0, 0)

		local titleText = frame:CreateFontString(nil, "ARTWORK")
		titleText:SetFontObject(GameFontNormal)
		titleText:SetPoint("TOPLEFT",12,0)
		titleText:SetPoint("BOTTOMRIGHT", titlebg, "BOTTOMRIGHT", 0, 0)
		titleText:SetJustifyH("LEFT")
		titleText:SetWordWrap(false)
		titleText:SetNonSpaceWrap(false)

		local title = CreateFrame("Button", "TitleButtonFrame", frame)
		title:SetPoint("TOPLEFT", titlebg)
		title:SetPoint("BOTTOMRIGHT", titlebg)

		return title, titleText, closeButton
	end

	local function CreateLabel(self, frame)
		local label = self.content:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall")
		label:ClearAllPoints()
		label:SetPoint("TOPLEFT", 0, 0)
		label:SetPoint("BOTTOMRIGHT", 0, 0)
		label:SetJustifyH("LEFT")
		label:SetJustifyV("TOP")
		label:Show()
		label.obj = self

		return label
	end

	local function CreateButton(self, frame)
		local button = CreateFrame("Button", "ToasterWindowButton", frame)
		button:SetPoint("TOPLEFT", self.title, "BOTTOMLEFT", 0, 0)
		button:SetPoint("BOTTOMRIGHT", frame, 0, 0)
		button:SetScript("OnMouseUp", onMouseUpFrameButton)
		button.obj = self
		return button
	end

	local function CreateContainer(self, frame)
		local content = CreateFrame("Frame", "ContainerFrame", frame)
		content:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -32)
		content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 13)
		content.obj = self

		return content
	end

	local function Constructor()
		local frame = CreateFrame("Frame", "ToasterFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
		local self = {}
		self.type = "Toaster"
		self.localstatus = {}
		self.frame = frame
		frame.obj = self

		-- AceGUI functions --
		self.OnAcquire = OnAcquire
		self.ApplyStatus = ApplyStatus
		self.Hide = Hide
		self.Show = Show
		self.OnRelease = OnRelease
		self.SetStatusTable = SetStatusTable
		self.OnWidthSet = OnWidthSet
		self.OnHeightSet = OnHeightSet

		-- Public functions --
		self.SetTitle =  SetTitle
		self.SetText = SetText
		self.SetSize = SetSize
		self.SetIsMovable = SetIsMovable
		self.SetId = SetId
		self.IsMoving = IsMoving
		self.SetAlpha = SetAlpha
		self.SetFadeOutDuration = SetFadeOutDuration
		self.Trigger = Trigger
		self.SetLabelFontSettings = SetLabelFontSettings
		self.SetInstanceId = SetInstanceId

		-- Default Values
		frame:SetWidth(300)
		frame:SetHeight(60)
		frame:SetPoint("BOTTOMLEFT", UIParent, "CENTER", 0, 0)
		frame:EnableMouse()
		frame:SetFrameStrata("FULLSCREEN_DIALOG")
		frame:SetBackdrop(PaneBackdrop)
		frame:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
		frame:SetBackdropBorderColor(0, 0, 0)
		frame:SetToplevel(true)
		self.fadeInfo = {
			mode = "OUT",
			timeToFade = 1,
			startAlpha = 1,
			endAlpha = 0,
			finishedFunc = function()
				self:Hide()
				self:Fire("FadeOutComplete")
			end
		}

		-- Create Objects
		self.content = CreateContainer(self, frame)
		AceGUI:RegisterAsContainer(self)
		self:SetLayout("Fill")

		self.title, self.titletext, self.closebutton = CreateTitle(self, frame)
		self.label = CreateLabel(self, frame)
		self.button = CreateButton(self, frame)

		-- Callbacks
		frame:SetScript("OnMouseDown", onMouseDownFrame)
		frame:SetScript("OnShow", onShowFrame)
		frame:SetScript("OnHide", onHideFrame)

		return self
	end

	AceGUI:RegisterWidgetType(Type, Constructor, Version)
end
