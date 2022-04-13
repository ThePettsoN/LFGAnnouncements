local AceGUI = LibStub("AceGUI-3.0")

-- Lua APIs
local pairs, assert, type = pairs, assert, type

-- WoW APIs
local PlaySound = PlaySound
local CreateFrame, UIParent = CreateFrame, UIParent

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: GameFontNormal

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

	local function frameOnShow(this)
		this.obj:Fire("OnShow")
	end

	local function frameOnClose(this)
		this.obj:Fire("OnClose")
	end

	local function closeOnClick(this)
		PlaySound(799) -- SOUNDKIT.GS_TITLE_OPTION_EXIT
		this.obj:Hide()
	end

	local function frameOnMouseDown(this)
		AceGUI:ClearFocus()
	end

	local function titleOnMouseDown(this)
		local frame = this:GetParent()
		frame:StartMoving()
		AceGUI:ClearFocus()

		local self = frame.obj
		self:SetIsMoving(true)
		self:Fire("StartMoving")
	end

	local function frameOnMouseUp(this)
		local frame = this:GetParent()
		frame:StopMovingOrSizing()
		local self = frame.obj
		local status = self.status or self.localstatus
		status.width = frame:GetWidth()
		status.height = frame:GetHeight()
		status.top = frame:GetTop()
		status.left = frame:GetLeft()

		self:SetIsMoving(false)
		self:Fire("StopMoving", status.left, status.top - status.height)
	end

	local function IsMoving(self)
		return self._isMoving
	end

	local function SetIsMoving(self, isMoving)
		self._isMoving = isMoving
	end

	local function SetTitle(self,title)
		self.titletext:SetText(title)
	end

	local function Hide(self)
		self.frame:Hide()
	end

	local function Show(self)
		self.frame:Show()
	end

	local function SetAlpha(self, alpha)
		self.frame:SetAlpha(alpha)
	end

	local function OnAcquire(self)
		self.frame:SetParent(UIParent)
		self.frame:SetFrameStrata("FULLSCREEN_DIALOG")
		self:ApplyStatus()
		self:Show()
	end

	local function OnRelease(self)
		self.status = nil
		for k in pairs(self.localstatus) do
			self.localstatus[k] = nil
		end
	end

	-- called to set an external table to store status in
	local function SetStatusTable(self, status)
		assert(type(status) == "table")
		self.status = status
		self:ApplyStatus()
	end

	local FadeInfo = {
		mode = "OUT",
		timeToFade = 1,
		startAlpha = 1,
		endAlpha = 0,
		finishedFunc = function(frame)
			frame:Hide()
		end
	}

	local function SetFadeOutDuration(self, duration)
		FadeInfo.timeToFade = duration
	end

	local function StartFadeOut(self)
		UIFrameFade(self.frame, CopyTable(FadeInfo, true)) -- We copy to make sure the original isn't overwritten and we're able to restart the fadeOut whenever we want
	end

	local function StopFadeOut(self)
		UIFrameFadeRemoveFrame(self.frame)
	end

	local function ApplyStatus(self)
		local status = self.status or self.localstatus
		local frame = self.frame
		self:SetWidth(status.width or 300)
		self:SetHeight(status.height or 50)
		if status.top and status.left then
			frame:SetPoint("TOP",UIParent,"BOTTOM",0,status.top)
			frame:SetPoint("LEFT",UIParent,"LEFT",status.left,0)
		else
			frame:SetPoint("CENTER",UIParent,"CENTER")
		end
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

	-- TODO: Move this into a general place where UI can use it as well
	local PaneBackdrop = {
		edgeFile = "Interface\\AddOns\\LFGAnnouncements\\Media\\Textures\\White8x8",
		bgFile = "Interface\\AddOns\\LFGAnnouncements\\Media\\Textures\\White8x8",
		edgeSize = 1,
	}

	local function Constructor()
		local frame = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
		local self = {}
		self.type = "Window"

		FadeInfo.finishedArg1 = frame

		self.Hide = Hide
		self.Show = Show
		self.SetTitle =  SetTitle
		self.OnRelease = OnRelease
		self.OnAcquire = OnAcquire
		self.SetStatusTable = SetStatusTable
		self.ApplyStatus = ApplyStatus
		self.OnWidthSet = OnWidthSet
		self.OnHeightSet = OnHeightSet
		self.SetFadeOutDuration = SetFadeOutDuration
		self.SetAlpha = SetAlpha
		self.StartFadeOut = StartFadeOut
		self.StopFadeOut = StopFadeOut
		self.IsMoving = IsMoving
		self.SetIsMoving = SetIsMoving

		self.localstatus = {}

		self.frame = frame
		frame.obj = self
		frame:SetWidth(300)
		frame:SetHeight(60)
		frame:SetPoint("BOTTOMLEFT",UIParent, "CENTER", 0, 0)
		frame:EnableMouse()
		frame:SetMovable(true)
		frame:SetFrameStrata("FULLSCREEN_DIALOG")
		frame:SetScript("OnMouseDown", frameOnMouseDown)

		frame:SetScript("OnShow",frameOnShow)
		frame:SetScript("OnHide",frameOnClose)
		frame:SetToplevel(true)

		frame:SetBackdrop(PaneBackdrop)
		frame:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
		frame:SetBackdropBorderColor(0, 0, 0)

		local titlebg = frame:CreateTexture(nil, "BACKGROUND")
		titlebg:SetPoint("TOPLEFT", 0, 0)
		titlebg:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)

		local dialogbg = frame:CreateTexture(nil, "BACKGROUND")
		dialogbg:SetPoint("TOPLEFT", titlebg, "BOTTOMLEFT", 0, 0)
		dialogbg:SetPoint("BOTTOMRIGHT", 0, 0)

		local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
		close:SetPoint("TOPRIGHT", 0, 0)
		close:SetScript("OnClick", closeOnClick)
		self.closebutton = close
		close.obj = self
		titlebg:SetPoint("BOTTOMRIGHT", close, "BOTTOMRIGHT", 10, 4)

		local titletext = frame:CreateFontString(nil, "ARTWORK")
		titletext:SetFontObject(GameFontNormal)
		titletext:SetPoint("TOPLEFT",12,0)
		titletext:SetPoint("BOTTOMRIGHT", titlebg, "BOTTOMRIGHT", 0, 0)
		titletext:SetJustifyH("LEFT")
		self.titletext = titletext

		local title = CreateFrame("Button", nil, frame)
		title:SetPoint("TOPLEFT", titlebg)
		title:SetPoint("BOTTOMRIGHT", titlebg)
		title:EnableMouse()
		title:SetScript("OnMouseDown",titleOnMouseDown)
		title:SetScript("OnMouseUp", frameOnMouseUp)
		self.title = title

		--Container Support
		local content = CreateFrame("Frame",nil,frame)
		self.content = content
		content.obj = self
		content:SetPoint("TOPLEFT",frame,"TOPLEFT",12,-32)
		content:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-12,13)

		AceGUI:RegisterAsContainer(self)
		return self
	end

	AceGUI:RegisterWidgetType(Type,Constructor,Version)
end
