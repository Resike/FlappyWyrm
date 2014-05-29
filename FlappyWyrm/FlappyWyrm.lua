local _, ns = ...

local FlappyWyrm = { }
ns.FlappyWyrm = FlappyWyrm

local ipairs = ipairs
local math = math
local print = print
local tostring = tostring

local BNGetInfo = BNGetInfo
local CreateFrame = CreateFrame
local GetCursorPosition = GetCursorPosition
local PlaySoundFile = PlaySoundFile
local SlashCmdList = SlashCmdList

local UIParentScale = 1
local WindowScale = 1

local ScaleLocked = false

local Debug = false

local GameStarted = false
local Flying = false

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

local Player = {
	frame, model, hitbox, distance = 24.6763, yaw = 1.6912, pitch = -0.3932
}

local mainframe = CreateFrame("Frame", nil, UIParent)
mainframe:RegisterEvent("ADDON_LOADED")
mainframe:RegisterEvent("BN_SELF_ONLINE")
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
	--sky:SetModel("Environments\\Stars\\Lostislegloomyskybox.m2")
	sky:SetModel("Environments\\Stars\\TwilightsHammerSky.m2")
	sky:SetPosition(12, - 22.5, 0)
	sky:SetWidth(899)
	sky:SetHeight(699)
	sky:SetAlpha(1)
	sky:SetPoint("TopLeft", skyframe, "TopLeft", 0, 0)
end

-- Hitbox
Player.hitbox = CreateFrame("Frame", nil, mainframe)
Player.hitbox:SetFrameStrata("High")
Player.hitbox:SetPoint("Center", mainframe, "Center", 0, 5)
Player.hitbox:SetAlpha(1)
Player.hitbox:SetWidth(100)
Player.hitbox:SetHeight(105)
if Debug then
	Player.hitbox:SetBackdrop(Backdrop)
	Player.hitbox:SetBackdropColor(0.2, 0.8, 0.2, 0.5)
end
-- Frame
Player.frame = CreateFrame("Frame", nil, Player.hitbox)
Player.frame:SetFrameStrata("High")
Player.frame:SetPoint("Center", Player.hitbox, "Center", 0, 0)
Player.frame:SetAlpha(1)
Player.frame:SetWidth(700)
Player.frame:SetHeight(700)
if Debug then
	--Player.frame:SetBackdrop(Backdrop)
	--Player.frame:SetBackdropColor(0.8, 0.2, 0.2, 0.5)
end
-- Model
Player.model = CreateFrame("PlayerModel", nil, Player.frame)
Player.model:SetAllPoints(Player.frame)

function FlappyWyrm:InitModelPlayer(model)
	model:SetDisplayInfo(25750)
	model:SetWidth(700)
	model:SetHeight(700)
	model:SetAlpha(1)
	model:SetCustomCamera(1)
	model.distance = Player.distance * UIParentScale * WindowScale
	model.yaw = Player.yaw
	model.pitch = Player.pitch
	model:SetPosition(0, 0, -1.5)
	self:SetOrientation(model)
	--self:ChangeAnimation(model, 250)
end

mainframe:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" then
		local Addon = ...
		if Addon == "FlappyWyrm" then
			FlappyWyrm:AddonLoaded()
			mainframe:UnregisterEvent("ADDON_LOADED")
		end
	elseif event == "BN_SELF_ONLINE" then
		local _, battleTag = BNGetInfo()
		if battleTag == "Resike#2247" then
			Debug = true
			--print("Flappy Wyrm debugging: Enabled")
		end
		mainframe:UnregisterEvent("BN_SELF_ONLINE")
	end
end)

mainframe:SetScript("OnEnter", function(self)
	mainframe:SetScript("OnKeyUp", function(self, key)
		if key ~= "UP" and key ~= "SPACE" then
			return
		end
		GameStarted = true
		Flying = true
		FlappyWyrm:ChangeAnimation(Player.model, 250)
		local r = tostring(math.random(1, 4))
		PlaySoundFile("Sound\\Creature\\WingFlaps\\GiantWingFlap"..r..".ogg", "Master")
	end)
	mainframe:SetScript("OnKeyDown", function(self, key)
		if key ~= "ENTER" then
			return
		end
		mainframe:SetScript("OnKeyUp", nil)
		mainframe:SetScript("OnKeyDown", nil)
	end)
end)

mainframe:SetScript("OnLeave", function(self)
	mainframe:SetScript("OnKeyUp", nil)
	mainframe:SetScript("OnKeyDown", nil)
end)

UIParent:HookScript("OnSizeChanged", function(self, width, height)
	UIParentScale = UIParent:GetScale()
end)

function FlappyWyrm:AddonLoaded()
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

function FlappyWyrm:ChangeAnimation(model, anim)
	if anim and anim > - 1 and anim < 802 then
		local elapsed = 600
		model:SetScript("OnUpdate", function(self, elaps)
			elapsed = elapsed + (elaps * 700)
			self:SetSequenceTime(anim, elapsed)
		end)
	end
end

local flytime = 0
local falltime = 0
mainframe:SetScript("OnUpdate", function(self, elaps)
	if GameStarted then
		local _, _, _, x, y = Player.hitbox:GetPoint()
		--print(y)
		if not Flying then
			if y > -297 then
				falltime = falltime + (elaps * 1000)
				Player.hitbox:SetPoint("Center", self, "Center", 0, y - (falltime / 400))
			elseif y <= -297 then
				-- Dead
				--mainframe:SetScript("OnUpdate", nil)
				Player.hitbox:SetPoint("Center", self, "Center", 0, -297)
			end
		else
			falltime = 0
			flytime = flytime + (elaps * 1000)
			if flytime < 500 then
				if y < 298 then
					Player.hitbox:SetPoint("Center", self, "Center", 0, y + (150 / flytime))
				elseif y >= 298 then
					-- Dead
					--mainframe:SetScript("OnUpdate", nil)
					Player.hitbox:SetPoint("Center", self, "Center", 0, 298)
				end
			else
				Flying = false
				flytime = 0
			end
		end
	end
end)

function FlappyWyrm:ResetGame()
	GameStarted = false
end

function FlappyWyrm:SlashCommands(msg)
	if msg == "" then
		if mainframe:IsVisible() then
			mainframe:Hide()
		else
			mainframe:Show()
			self:InitModelSky()
			self:InitModelPlayer(Player.model)
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

function FlappyWyrm:GetBaseCameraTarget(model)
	if model:GetObjectType() ~= "PlayerModel" then
		if Debug then
			print("Not \"PlayerModel\" type!")
		end
		return
	end
	local modelfile = model:GetModel()
	if modelfile and modelfile ~= "" then
		local tempmodel = CreateFrame("PlayerModel", nil, UIParent)
		tempmodel:SetModel(modelfile)
		tempmodel:SetCustomCamera(1)
		local x, y, z = tempmodel:GetCameraTarget()
		tempmodel:ClearModel()
		return x, y, z
	end
end

function FlappyWyrm:SetOrientation(model, target)
	if model:GetObjectType() ~= "PlayerModel" then
		if Debug then
			print("Not \"PlayerModel\" type!")
		end
		return
	end
	if model:HasCustomCamera() and model.distance and model.yaw and model.pitch then
		local x = model.distance * math.cos(model.yaw) * math.cos(model.pitch)
		local y = model.distance * math.sin(- model.yaw) * math.cos(model.pitch)
		local z = (model.distance * math.sin(- model.pitch))
		model:SetCameraPosition(x, y, z)
		if not target then
			local x, y, z = self:GetBaseCameraTarget(model)
			if x and y and z then
				model:SetCameraTarget(0, 0, 0)
			end
		end
	else
		if Debug then
			--print("Model has no custom camera!")
		end
	end
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
		if Player.model and Player.model.distance then
			Player.model.distance = Player.distance * UIParentScale * s
		end
		FlappyWyrm:SetOrientation(Player.model, true)
		self:SetHeight(Height * s)
	end)
end