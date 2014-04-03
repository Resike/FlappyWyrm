local _, ns = ...

local FlappyWyrm = { }
ns.FlappyWyrm = FlappyWyrm

local ipairs = ipairs
local print = print

local BNGetInfo = BNGetInfo
local CreateFrame = CreateFrame
local GetCursorPosition = GetCursorPosition
local SlashCmdList = SlashCmdList

local UIParentScale = 1
local WindowScale = 1

local ScaleLocked = false

local Debug = false

local Backdrop = {
	bgFile = "Interface\\Buttons\\White8x8.blp",
	--[[edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
	edgeSize = 0,
	insets = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0
	}]]
}

local mainframe = CreateFrame("Frame", nil, UIParent)
mainframe:RegisterEvent("ADDON_LOADED")
mainframe:SetFrameStrata("High")
mainframe:SetPoint("Center", 0, 0)
mainframe:SetWidth(900)
mainframe:SetHeight(700)
mainframe:SetAlpha(1)
mainframe:SetMovable(true)
mainframe:Hide()

local skyframe = CreateFrame("Frame", nil, mainframe)
skyframe:SetFrameStrata("Medium")
skyframe:SetWidth(900)
skyframe:SetHeight(700)
skyframe:SetAlpha(1)
skyframe:SetPoint("Center", mainframe, "Center", 0, 0)

local sky = CreateFrame("PlayerModel", nil, skyframe)

function FlappyWyrm:InitModelSky()
	--sky:SetModel("Environments\\Stars\\Maelstrom_Sky03_Stormbreak.m2")
	sky:SetModel("Environments\\Stars\\Lostislegloomyskybox.m2")
	sky:SetWidth(899)
	sky:SetHeight(699)
	sky:SetAlpha(1)
	sky:SetPoint("TopLeft", skyframe, "TopLeft", 0, 0)
end

--Version:4.25.3; mcd:8.6763; mcy:1.6912; x:102; modelpath:25750; texture:491; mcp:-0.3932; model:true; y:56

mainframe:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" then
		local Addon = ...
		if Addon == "FlappyWyrm" then
			FlappyWyrm:AddonLoaded()
			mainframe:UnregisterEvent("ADDON_LOADED")
		end
	end
end)

UIParent:HookScript("OnSizeChanged", function(self, width, height)
	UIParentScale = UIParent:GetScale()
end)

function FlappyWyrm:AddonLoaded()
	local _, battleTag = BNGetInfo()
	if battleTag == "Resike#2247" then
		Debug = true
		print("FlappyWyrm debugging: Enabled")
	end
	SlashCmdList["FlappyWyrm"] = function(msg)
		self:SlashCommands(msg)
	end
	SLASH_FlappyWyrm1 = "/fw"
	SLASH_FlappyWyrm2 = "/flappywyrm"
	mainframe:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			FlappyWyrm:FrameStartMoving(self, button)
		end
	end)
	mainframe:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" then
			FlappyWyrm:FrameStopMoving(self, button)
		end
	end)
	self:ResizeFrame(mainframe)
end

function FlappyWyrm:SlashCommands(msg)
	if msg == "" then
		if mainframe:IsVisible() then
			mainframe:Hide()
		else
			self:InitModelSky()
			mainframe:Show()
		end
	elseif msg == "ui" then
		print(UIParent:GetScale(), UIParentScale, WindowScale)
	end
end

function FlappyWyrm:FrameStartMoving(frame, button)
	if button == "LeftButton" then
		frame:StartMoving()
	end
end

function FlappyWyrm:FrameStopMoving(frame, button)
	frame:StopMovingOrSizing()
end

function FlappyWyrm:ResizeFrame(frame)
	local Width = frame:GetWidth()
	local Height = frame:GetHeight()
	frame.resizeframeleft = CreateFrame("Frame", nil, frame)
	frame.resizeframeleft:SetFrameStrata("Fullscreen_Dialog")
	frame.resizeframeleft:SetPoint("BottomRight", frame, "BottomRight", 0, 0)
	frame.resizeframeleft:SetWidth(16)
	frame.resizeframeleft:SetHeight(16)
	frame.resizeframeleft:SetFrameLevel(frame:GetFrameLevel() + 7)
	frame.resizeframeleft:EnableMouse(true)
	if ScaleLocked then
		frame.resizeframeleft:Hide()
	else
		frame.resizeframeleft:Show()
	end
	frame.resizetextureleft = frame.resizeframeleft:CreateTexture(nil, "Artwork")
	frame.resizetextureleft:SetPoint("TopLeft", frame.resizeframeleft, "TopLeft", 0, 0)
	frame.resizetextureleft:SetWidth(16)
	frame.resizetextureleft:SetHeight(16)
	frame.resizetextureleft:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
	frame:SetMaxResize(Width * 1.3, Height * 1.3)
	frame:SetMinResize(Width / 1.2, Height / 1.2)
	frame:SetResizable(true)
	frame.resizeframeleft:SetScript("OnEnter", function(self)
		frame.resizetextureleft:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
	end)
	frame.resizeframeleft:SetScript("OnLeave", function(self)
		frame.resizetextureleft:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
	end)
	frame.resizeframeleft:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			frame:StartSizing("Right")
		end
		frame.resizetextureleft:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
	end)
	frame.resizeframeleft:SetScript("OnMouseUp", function(self, button)
		if button == "RightButton" then
			frame:SetWidth(Width)
			frame:SetHeight(Height)
		end
		if button == "MiddleButton" then
			frame.resizeframeleft:Hide()
			frame.resizeframeright:Hide()
			ScaleLocked = true
			frame.resizetextureleft:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
		else
			local x, y = GetCursorPosition()
			local fx = self:GetLeft() * self:GetEffectiveScale()
			local fy = self:GetBottom() * self:GetEffectiveScale()
			if x >= fx and x <= (fx + self:GetWidth()) and y >= fy and y <= (fy + self:GetHeight()) then
				frame.resizetextureleft:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
			else
				frame.resizetextureleft:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
			end
			frame:StopMovingOrSizing()
		end
	end)
	frame.resizeframeright = CreateFrame("Frame", nil, frame)
	frame.resizeframeright:SetFrameStrata("Fullscreen_Dialog")
	frame.resizeframeright:SetPoint("BottomLeft", frame, "BottomLeft", 0, 0)
	frame.resizeframeright:SetWidth(16)
	frame.resizeframeright:SetHeight(16)
	frame.resizeframeright:SetFrameLevel(frame:GetFrameLevel() + 7)
	frame.resizeframeright:EnableMouse(true)
	if ScaleLocked then
		frame.resizeframeright:Hide()
	else
		frame.resizeframeright:Show()
	end
	frame.resizetextureright = frame.resizeframeright:CreateTexture(nil, "Artwork")
	frame.resizetextureright:SetPoint("TopLeft", frame.resizeframeright, "TopLeft", 0, 0)
	frame.resizetextureright:SetWidth(16)
	frame.resizetextureright:SetHeight(16)
	frame.resizetextureright:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
	local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy = frame.resizetextureright:GetTexCoord()
	frame.resizetextureright:SetTexCoord(URx, URy, LRx, LRy, ULx, ULy, LLx, LLy)
	frame.resizeframeright:SetScript("OnEnter", function(self)
		frame.resizetextureright:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
	end)
	frame.resizeframeright:SetScript("OnLeave", function(self)
		frame.resizetextureright:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
	end)
	frame.resizeframeright:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			frame:StartSizing("Left")
		end
		frame.resizetextureright:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
	end)
	frame.resizeframeright:SetScript("OnMouseUp", function(self, button)
		if button == "RightButton" then
			frame:SetWidth(Width)
			frame:SetHeight(Height)
		end
		if button == "MiddleButton" then
			frame.resizeframeleft:Hide()
			frame.resizeframeright:Hide()
			ScaleLocked = true
			frame.resizetextureright:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
		else
			local x, y = GetCursorPosition()
			local fx = self:GetLeft() * self:GetEffectiveScale()
			local fy = self:GetBottom() * self:GetEffectiveScale()
			if x >= fx and x <= (fx + self:GetWidth()) and y >= fy and y <= (fy + self:GetHeight()) then
				frame.resizetextureright:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
			else
				frame.resizetextureright:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
			end
			frame:StopMovingOrSizing()
		end
	end)
	frame.scrollframe = CreateFrame("ScrollFrame", nil, frame)
	frame.scrollframe:SetWidth(Width)
	frame.scrollframe:SetHeight(Height)
	frame.scrollframe:SetPoint("Topleft", frame, "Topleft", 0, 0)
	frame:SetScript("OnSizeChanged", function(self)
		local s = self:GetWidth() / Width
		WindowScale = s
		frame.scrollframe:SetScale(s)
		local childrens = {self:GetChildren()}
		for _, child in ipairs(childrens) do
			if child ~= frame.resizeframeleft and child ~= frame.resizeframeright then
				child:SetScale(s)
			end
		end
		self:SetHeight(Height * s)
	end)
end