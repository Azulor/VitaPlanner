-- Vita Planner
-- Base - UI
-- Version: 3.0.0
-- Author: Azulor - US:Caelestrasz

local MIN_CHOICES_WIDTH = 440;

function VitaPlanner:InitUI()
    self.selectionFrame = nil
    self.notificationFrame = nil

    local frame = CreateFrame("Frame","VitaPlannerBossUI",UIParent)
    frame:Hide();
    frame:SetWidth(MIN_CHOICES_WIDTH)
    frame:SetHeight(140)
    frame:SetPoint("CENTER",UIParent,"CENTER",0,0)
    frame:SetPoint("TOP",UIParent,"TOP",0,-100)
    frame:EnableMouse(true)
    frame:SetScale(VitaPlanner.db.profile.popupUIScale or 1)
    frame:SetResizable()
    frame:SetMovable(true)
    frame:SetFrameStrata("DIALOG")
    frame:SetToplevel(true)
    frame:SetBackdrop({
        --bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
        --edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 64, edgeSize = 12,
        insets = { left = 2, right = 1, top = 2, bottom = 2 }
    })
    frame:SetBackdropColor(0.4,0.4,0.4,1)
    frame:SetBackdropBorderColor(1,1,1,0.2)

    frame:SetScript("OnMouseDown", function() frame:StartMoving() end)
    frame:SetScript("OnMouseUp", function() frame:StopMovingOrSizing() end)

    local titleFrame = CreateFrame("Frame", nil, frame)
    titleFrame:SetBackdrop({
        --bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        --edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeFile = VitaPlanner.Border.Dark,
        tile = true, tileSize = 64, edgeSize = 12,
        insets = { left = 2, right = 1, top = 2, bottom = 2 }
    })
    titleFrame:SetBackdropColor(0,0,0,1)
    titleFrame:SetHeight(22)
    titleFrame:EnableMouse(true)
    titleFrame:EnableMouseWheel(true)
    titleFrame:SetResizable()
    titleFrame:SetMovable(true)
    titleFrame:SetPoint("LEFT",frame,"TOPLEFT",20,0)
    titleFrame:SetPoint("RIGHT",frame,"TOPRIGHT",-20,0)

    titleFrame:SetScript("OnMouseDown", function() frame:StartMoving() end)
    titleFrame:SetScript("OnMouseUp", function() frame:StopMovingOrSizing() end)
    titleFrame:SetScript("OnMouseWheel", function(s, delta)
        self:SetUIScale( max(min(frame:GetScale(0.8) + delta/15,5.0),0.5) );
    end)

    local titletext = titleFrame:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    titletext:SetPoint("CENTER",titleFrame,"CENTER",0,1)
    titletext:SetText ( "Vita Planner by Azulor <Vita Obscura> - Caelestrasz US-Oceanic" )
    frame.titleFrame = titleFrame

    -- Add our frame to the addon globally
    self.frame = frame;
    -- Return the new frame
    return self.frame
end

function VitaPlanner:CreateBossSelectionFrame()
    if not self.frame then self:InitUI() end;

    local frame = CreateFrame("Frame", nil, self.frame)
    frame:Show()
    frame:SetHeight(self.frame:GetHeight() - 10)
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",--"Interface\\Garrison\\GarrisonUIBackground",
        --edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeFile = VitaPlanner.Border.Dark,
        tile = true, tileSize = 64, edgeSize = 12,
        insets = { left = 2, right = 1, top = 2, bottom = 2 }
    })
    --frame:SetBackdropColor(0.7,0.7,0.7,0.8)
    frame:SetBackdropColor(0.12,0.12,0.12,0.9)
    frame:SetPoint("TOP",self.frame,"TOP",0,-15)
    frame:SetPoint("LEFT",self.frame,"LEFT",20,0)
    frame:SetPoint("RIGHT",self.frame,"RIGHT",-20,0)

    --[[
    local logo = CreateFrame("Frame", nil, self.frame)
    logo:SetWidth(128)
    logo:SetHeight(64)
    logo:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", -10, -10)
    logo:Show()
    local texture = logo:CreateTexture()
    texture:SetAllPoints()
    texture:SetAlpha(0.5)
    texture:SetTexture(0,0,0,0.7)
    texture:SetTexture("Interface\\Addons\\VitaPlanner\\Textures\\VitaLogo.tga")
    --]]
    --frame.texture = texture

    local lblName = CreateFrame("Button", nil, frame)
    lblName:SetNormalFontObject("GameFontNormalLarge")
    lblName:SetHeight(25)
    lblName:SetFrameStrata("DIALOG")
    lblName:SetPoint("TOPLEFT",frame,"TOPLEFT",5,-10)
    frame.bossName = lblName

    local lblDifficulty = frame:CreateFontString(nil,"ARTWORK","GameFontNormalLeft")
    lblDifficulty:SetText( "Difficulty:" )
    lblDifficulty:SetPoint( "TOPLEFT", lblName, "BOTTOMLEFT", 10, -10)

    local lblDiff = frame:CreateFontString(nil,"ARTWORK","GameFontNormalLeft")
    lblDiff:SetPoint("TOPRIGHT",lblDifficulty,"TOPLEFT",140,0)
    lblDiff:SetText( "BossDiff" )
    frame.lblDiff = lblDiff;

    local lblPlanner = frame:CreateFontString(nil,"ARTWORK","GameFontNormalLeft")
    lblPlanner:SetPoint("TOPLEFT",lblDifficulty,"BOTTOMLEFT",0,-10)
    lblPlanner:SetText( "Planner:" )
    frame.lblPlanner = lblPlanner

    local planner = frame:CreateFontString(nil,"ARTWORK","GameFontNormalLeft")
    planner:SetPoint("TOPLEFT",lblPlanner,"TOPLEFT",140,0)
    planner:SetText("-")
    frame.planner = planner;

    frame.buttons = {}

    self.checkTimerFrame = self:GenerateTimerFrame()
    self.checkTimerFrame:Hide()

    self.reasonFrame = self:GenerateReasonFrame()
    self.reasonFrame:Hide()

    return frame;
end

function VitaPlanner:GenerateReasonFrame()
    local f = CreateFrame("Frame", nil, UIParent)
    f:Show()
    f:SetHeight(100)
    f:SetWidth(500)
    f:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = VitaPlanner.Border.Dark,
        --edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 64, edgeSize = 12,
        insets = { left = 2, right = 1, top = 2, bottom = 2 }
    })
    f:SetBackdropColor(0.12,0.12,0.12,0.9)
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:EnableMouse(true)
    f:SetMovable(true)
    f:SetPoint("TOP",UIParent,"TOP", 0, -100)

    local reason = f:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
    reason:SetText("Please type reason for sitting out")
    reason:SetPoint("TOP", f, "TOP", 0, -10)
    f.reason = reason

    local editbox = CreateFrame("EditBox", nil, f)
    editbox:SetWidth(480);
    editbox:SetHeight(25);
    editbox:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -35)
    editbox:SetFontObject("GameFontHighlight");
    editbox:SetTextInsets(10, 2, 2, 2)
    editbox:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 64, edgeSize = 12,
        insets = { left = 2, right = 1, top = 2, bottom = 2 }
    })
    editbox:SetBackdropColor(0,0,0,1)



    local cancel = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    cancel:SetScript("OnClick", function(btn)
        f:Hide()
    end)
    cancel:SetHeight(25)
    cancel:SetText("Cancel")
    cancel:SetWidth(cancel:GetFontString():GetWidth()+20)
    cancel:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -10, 10)

    local send = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    send:SetHeight(25)
    send:SetText("Send")
    send:SetWidth(send:GetFontString():GetWidth()+20)
    send:SetPoint("BOTTOMRIGHT", cancel, "BOTTOMLEFT", -10, 0)

    f.send = send
    f.editbox = editbox
    return f
end

function VitaPlanner:CreateNotificationFrame()
    if not self.frame then
        self:InitUI()
    end;

    local frame = CreateFrame("Frame", nil, self.frame)
    frame:Show()
    frame:SetHeight(self.frame:GetHeight() - 10)
    frame:SetWidth(self.frame:GetWidth() - 20)
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 64, edgeSize = 12,
        insets = { left = 2, right = 1, top = 2, bottom = 2 }
    })
    frame:SetBackdropColor(0.12,0.12,0.12,0.9)
    frame:SetPoint("LEFT",self.frame,"LEFT",20,0)
    frame:SetPoint("RIGHT",self.frame,"RIGHT",-20,0)

    local bossName = frame:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
    bossName:SetText("BossName")
    bossName:SetPoint("TOP", frame, "TOP", 0, -20)
    frame.bossName = bossName

    local setMessage = frame:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
    setMessage:SetFont("Fonts\\FRIZQT__.TTF", 30)
    setMessage:SetPoint("CENTER", frame, "CENTER", 0, 0)
    frame.setMessage = setMessage

    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    closeBtn:SetText("Close")
    closeBtn:SetWidth(closeBtn:GetFontString():GetWidth() + 20)
    closeBtn:SetPoint("BOTTOM",frame,"BOTTOM",0,20)
    closeBtn:SetScript("OnClick", function()
        self:Hide()
    end)

    return frame

end

function VitaPlanner:GenerateTimerFrame()
    --if VitaPlannerL and VitaPlannerL.checkTimerFrame then
    --	print("Planner timer found, returning that frame:")
    --	return VitaPlannerL.checkTimerFrame
    --end
    --if not self.frame then self:InitUI() end
    -- Timer
    local timerFrame = CreateFrame("Frame", nil, UIParent)
    timerFrame:EnableMouse(true)
    timerFrame:SetMovable(true)
    timerFrame:SetHeight(30)
    timerFrame:SetWidth(150);
    timerFrame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        --edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeFile = VitaPlanner.Border.Dark,
        tile = true, tileSize = 64, edgeSize = 12,
        insets = { left = 2, right = 1, top = 2, bottom = 2 }
    })
    timerFrame:SetBackdropColor(1,0,0,0.4)
    timerFrame:SetBackdropBorderColor(1, 0.6980392, 0, 0)
    timerFrame:SetPoint("TOP",UIParent,"TOP", 0, -50);

    -- Create our title frame
    local timerTitle = CreateFrame("Frame", nil, timerFrame)
    --#region Setup main frame title
    timerTitle:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        --edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeFile = VitaPlanner.Border.Dark,
        tile = true, tileSize = 64, edgeSize = 12,
        insets = { left = 2, right = 1, top = 2, bottom = 2 }
    })
    timerTitle:SetBackdropColor(0,0,0,1)
    timerTitle:SetHeight(22)
    timerTitle:EnableMouse(true)
    timerTitle:EnableMouseWheel(true)
    timerTitle:SetResizable()
    timerTitle:SetMovable(true)
    timerTitle:SetPoint("LEFT",timerFrame,"TOPLEFT",0,10)
    timerTitle:SetPoint("RIGHT",timerFrame,"TOPRIGHT",0,10)

    timerTitle:SetScript("OnMouseDown", function() timerFrame:StartMoving() end)
    timerTitle:SetScript("OnMouseUp", function() timerFrame:StopMovingOrSizing() end)
    timerTitle:SetScript("OnMouseWheel", function(s, delta)
        self:SetUIScale( max(min(timerFrame:GetScale(0.8) + delta/15,5.0),0.5) );
    end)

    -- Create the text to go into the title frame
    local titletext = timerTitle:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    titletext:SetText ( "Vita Planner Check Timer" )
    timerFrame.timerTitle = timerTitle
    titletext:SetPoint("CENTER",timerTitle,"CENTER",0,0)

    local b=CreateFrame("STATUSBAR",nil,timerFrame,"TextStatusBar");
    local bCount = 0;
    local bElapse = 0;
    b:SetPoint("TOPLEFT",timerFrame,"TOPLEFT", 3, -3);
    b:SetPoint("BOTTOMRIGHT",timerFrame,"BOTTOMRIGHT", -2, 3);
    b:SetPoint("TOP",timerFrame,"TOP", 0, -15);
    b:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
    b:SetStatusBarColor(0.4, 0.8, 0.4, 0.8);
    b:SetMinMaxValues(0,100)
    b:SetScript("OnUpdate", function( o, elapsed )
        --print("timerUpdate")
        if not timerFrame or not self.timeoutLeft then
            --print("no timeout found")

            b:SetMinMaxValues(0,100); b:SetValue(100);
            timerFrame.lblTimeout:SetText( "No Timeout" )
            if VitaPlannerL and VitaPlannerL.cancelCheckRaid then
                --print("found VPL cancel, hiding it")
                VitaPlannerL.currentlyChecking = true
                VitaPlannerL.cancelCheckRaid:Hide()
            end
            --print("hiding this timer")
            self.checkTimerFrame:Hide()
            return;
        end
        self.timeoutLeft = self.timeoutLeft - elapsed;
        if self.timeoutLeft<0 then
            self.timeoutLeft = 0;
            b:SetValue(0);
            timerFrame.lblTimeout:SetText( "No Time Left" )
            if VitaPlannerL then
                if not VitaPlannerL.selectedBossList and VitaPlannerL.mainFrame.infoPanel then
                    VitaPlannerL.checkRaid:Disable()
                elseif VitaPlannerL.mainFrame.infoPanel then
                    VitaPlannerL.checkRaid:Enable()
                end
                if VitaPlannerL.cancelCheckRaid then
                    VitaPlannerL.cancelCheckRaid:Hide()
                end
                VitaPlannerL.currentlyChecking = false
            end

            if self:IsShown() then
                self.reasonFrame.editbox:SetText("")
                self.reasonFrame:Hide()
                self:SendBossSelection( self.selectionFrame.data.leader, self.selectionFrame.data.bossName, "NONE")
                self:RemoveSelection( self.selectionFrame.data.bossName );
                self:UpdateSelectionUI()
            end

            self.reasonFrame.editbox:SetText("")
            self.reasonFrame:Hide()
            self.checkTimerFrame:Hide()
            return;
        end


        timerFrame.lblTimeout:SetText( format("%s secs left", ceil(self.timeoutLeft)) )
        b:SetValue(self.timeoutLeft)
        if VitaPlannerL and VitaPlannerL.mainFrame then
            VitaPlannerL.currentlyChecking = true
            VitaPlannerL.checkRaid:Disable()
            VitaPlannerL.cancelCheckRaid:Show()
        end
        --self.mainFrame.bossInfo.checkRaid:Disable()
        --self.cancelCheckRaid:Show()
    end)
    timerFrame.progressBar = b;

    local timerBorderFrame = CreateFrame("Frame", nil, timerFrame)
    timerBorderFrame:SetHeight(timerFrame:GetHeight())
    timerBorderFrame:SetToplevel(true)
    timerBorderFrame:SetWidth(timerFrame:GetWidth() + 20);
    timerBorderFrame:SetBackdrop({
        --bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 64, edgeSize = 12,
        insets = { left = 2, right = 1, top = 2, bottom = 2 }
    })
    timerBorderFrame:SetBackdropColor(1, 0, 0, 0.0)
    timerBorderFrame:SetBackdropBorderColor(1, 0.6980392, 0, 1)
    timerBorderFrame:SetPoint("TOPLEFT",timerFrame,"TOPLEFT", 0, 0);
    timerBorderFrame:SetPoint("BOTTOMRIGHT",timerFrame,"BOTTOMRIGHT", 0, 0);

    local lblTimeout = timerBorderFrame:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    lblTimeout:SetPoint("CENTER",timerBorderFrame,"CENTER",0,0)
    lblTimeout:SetVertexColor( 1, 1, 1 );
    lblTimeout:SetText( "Itemname" )
    timerFrame.lblTimeout = lblTimeout;

    return timerFrame
end


function VitaPlanner:GenerateZakuunLayout()
	--print("Generating garrosh group frame")
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetWidth(512)
	frame:SetHeight(512)
	frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	frame:EnableMouse(true)
    frame:EnableMouseWheel(true)
	frame:SetMovable(true)
    frame:SetResizable()
	frame:SetScript("OnMouseDown", function() frame:StartMoving() end)
    frame:SetScript("OnMouseUp", function() frame:StopMovingOrSizing() end)
    frame:SetFrameStrata("TOOLTIP")
    frame:SetScript("OnMouseWheel", function(s, delta)
        frame:SetScale( max(min(frame:GetScale(0.8) + delta/15,5.0),0.5) );
    end)

    self.zakuunTextures = nil
    local textures = {}
    textures[1] = frame:CreateTexture()
    textures[1]:SetAllPoints()
    textures[1]:SetAlpha(1)
    textures[1]:SetTexture(0,0,0,0.7)
    textures[1]:SetTexture("Interface\\Addons\\VitaPlanner\\Textures\\ZakuunLayout1.tga")

    textures[2] = frame:CreateTexture()
    textures[2]:SetAllPoints()
    textures[2]:SetAlpha(1)
    textures[2]:SetTexture(0,0,0,0.7)
    textures[2]:SetTexture("Interface\\Addons\\VitaPlanner\\Textures\\ZakuunLayout2.tga")
    textures[2]:Hide()

    textures[3] = frame:CreateTexture()
    textures[3]:SetAllPoints()
    textures[3]:SetAlpha(1)
    textures[3]:SetTexture(0,0,0,0.7)
    textures[3]:SetTexture("Interface\\Addons\\VitaPlanner\\Textures\\ZakuunLayout3.tga")
    textures[3]:Hide()

    textures[4] = frame:CreateTexture()
    textures[4]:SetAllPoints()
    textures[4]:SetAlpha(1)
    textures[4]:SetTexture(0,0,0,0.7)
    textures[4]:SetTexture("Interface\\Addons\\VitaPlanner\\Textures\\ZakuunLayout4.tga")
    textures[4]:Hide()

    textures[5] = frame:CreateTexture()
    textures[5]:SetAllPoints()
    textures[5]:SetAlpha(1)
    textures[5]:SetTexture(0,0,0,0.7)
    textures[5]:SetTexture("Interface\\Addons\\VitaPlanner\\Textures\\ZakuunLayout5.tga")
    textures[5]:Hide()

    textures[6] = frame:CreateTexture()
    textures[6]:SetAllPoints()
    textures[6]:SetAlpha(1)
    textures[6]:SetTexture(0,0,0,0.7)
    textures[6]:SetTexture("Interface\\Addons\\VitaPlanner\\Textures\\ZakuunLayout6.tga")
    textures[6]:Hide()

    self.zakuunTextures = textures
    local TabFrame = CreateFrame("Frame", nil, frame)

    local tabBtnWidth = 68
	local tabBtn1 = CreateFrame("Button", nil, TabFrame, "UIPanelButtonTemplate")
    tabBtn1:SetText("Layout 1")
    tabBtn1:SetWidth(tabBtnWidth)
    tabBtn1:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0,-25)
    tabBtn1:SetScript("OnClick", function()
        self:HideAllZakuunTextures()
        self.zakuunTextures[1]:Show()
    end)
    frame.tabBtn1 = tabBtn1
    local tabBtn2 = CreateFrame("Button", nil, TabFrame, "UIPanelButtonTemplate")
    tabBtn2:SetText("Layout 2")
    tabBtn2:SetWidth(tabBtnWidth)
    tabBtn2:SetPoint("TOPLEFT", tabBtn1, "TOPRIGHT", 10,0)
    tabBtn2:SetScript("OnClick", function()
        self:HideAllZakuunTextures()
        self.zakuunTextures[2]:Show()
    end)
    frame.tabBtn2 = tabBtn2
    local tabBtn3 = CreateFrame("Button", nil, TabFrame, "UIPanelButtonTemplate")
    tabBtn3:SetText("Layout 3")
    tabBtn3:SetWidth(tabBtnWidth)
    tabBtn3:SetPoint("TOPLEFT", tabBtn2, "TOPRIGHT", 10,0)
    tabBtn3:SetScript("OnClick", function()
        self:HideAllZakuunTextures()
        self.zakuunTextures[3]:Show()
    end)
    frame.tabBtn3 = tabBtn3
    local tabBtn4 = CreateFrame("Button", nil, TabFrame, "UIPanelButtonTemplate")
    tabBtn4:SetText("Layout 4")
    tabBtn4:SetWidth(tabBtnWidth)
    tabBtn4:SetPoint("TOPLEFT", tabBtn3, "TOPRIGHT", 10,0)
    tabBtn4:SetScript("OnClick", function()
        self:HideAllZakuunTextures()
        self.zakuunTextures[4]:Show()
    end)
    frame.tabBtn4 = tabBtn4
    local tabBtn5 = CreateFrame("Button", nil, TabFrame, "UIPanelButtonTemplate")
    tabBtn5:SetText("Layout 5")
    tabBtn5:SetWidth(tabBtnWidth)
    tabBtn5:SetPoint("TOPLEFT", tabBtn4, "TOPRIGHT", 10,0)
    tabBtn5:SetScript("OnClick", function()
        self:HideAllZakuunTextures()
        self.zakuunTextures[5]:Show()
    end)
    frame.tabBtn5 = tabBtn5
    local tabBtn6 = CreateFrame("Button", nil, TabFrame, "UIPanelButtonTemplate")
    tabBtn6:SetText("Layout 6")
    tabBtn6:SetWidth(tabBtnWidth)
    tabBtn6:SetPoint("TOPLEFT", tabBtn5, "TOPRIGHT", 10,0)
    tabBtn6:SetScript("OnClick", function()
        self:HideAllZakuunTextures()
        self.zakuunTextures[6]:Show()
    end)
    frame.tabBtn6 = tabBtn6

	local closeBtn = CreateFrame("Button", nil, TabFrame, "UIPanelButtonTemplate")
	closeBtn:SetText("Close")
	closeBtn:SetWidth(tabBtnWidth)
	closeBtn:SetPoint("TOPLEFT", tabBtn6, "TOPRIGHT", 10,0)
	closeBtn:SetScript("OnClick", function() frame:Hide() end)
	frame.close = closeBtn
    TabFrame:SetWidth(7 * tabBtnWidth + 60)
    frame:SetWidth(7 * tabBtnWidth + 60)
    TabFrame:SetHeight(30)
    TabFrame:SetPoint("CENTER", frame, "TOP", 0, -20)

	frame:Hide()

	return frame
end

function VitaPlanner:HideAllZakuunTextures()
    for i,t in ipairs(self.zakuunTextures) do
        t:Hide()
    end
end
