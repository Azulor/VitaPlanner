-- Vita Planner
-- Leader - UI
-- Version: 4.0.0
-- Author: Azulor - US:Caelestrasz

local RAID_UNIT_HEIGHT 		= 30
local RAID_UNIT_WIDTH 		= 105
local RAID_UNIT_HEIGHTN 	= 18
local RAID_UNIT_WIDTHN 		= 265
local RAID_UNIT_VERT_GAP 	= 2
local RAID_GROUP_HORZ_GAP 	= 2
local RAID_GROUP_VERT_GAP 	= 25

local V2_FRAME_WIDTH		= 800

local FRAME_PANEL_HEIGHT	= 565--475

local MSG_Prefix    		= '[Vita Planner] '

function VitaPlannerL:InitUI()
	-- Create our main frame for the planner
	-- This is done only once per session or until the UI is reloaded
    self.mainFrame = nil;
	self.timerFrame = nil

	-- Create our large frame (it acts as a background)
    local frame = CreateFrame("Frame","VitaPlannerLeaderBossUI",UIParent)
    --#region Setup main masterlooter frame
    frame:Hide();
	frame:SetWidth(V2_FRAME_WIDTH)
    frame:SetHeight(610) --560
    frame:SetPoint("CENTER",UIParent,"CENTER",0,0)
    --frame:SetPoint("TOP",UIParent,"CENTER",0,RP_BOSSFRAME_MAXNUM*(RP_BOSSFRAME_PADDING+RP_BOSSFRAME_HEIGHT)/2)
  	frame:EnableMouse(true)
    frame:SetScale(VitaPlanner.db.profile.popupUIScale or 1)
    frame:SetResizable()
    frame:SetMovable(true)
    frame:SetFrameStrata("HIGH")
    frame:SetToplevel(true)
    frame:SetBackdrop({
      --bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
      --edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
      tile = true, tileSize = 64, edgeSize = 12,
      insets = { left = 2, right = 1, top = 2, bottom = 2 }
    })
    --frame:SetBackdropColor(0.4,0.4,0.4,1)
    --frame:SetBackdropBorderColor(1,1,1,0.2)

    --frame:SetScript("OnMouseDown", function() frame:StartMoving() end)
    --frame:SetScript("OnMouseUp", function() frame:StopMovingOrSizing() end)
    --frame:SetScript("OnHide",frameOnClose)
    --#endregion

	
	-- Create our title frame
    local titleFrame = CreateFrame("Frame", nil, frame)
    --#region Setup main frame title
    titleFrame:SetBackdrop({
      bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
      edgeFile = VitaPlanner.Border.Dark, --"Interface\\Tooltips\\UI-Tooltip-Border",
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
	
	-- Create the text to go into the title frame
    local titletext = titleFrame:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    titletext:SetPoint("CENTER",titleFrame,"CENTER",0,1)
	titletext:SetText ( "Vita Planner by Azulor <Vita Obscura> - Caelestrasz US-Oceanic" )
    frame.titleFrame = titleFrame

	-- Add our planner frame to the addon globally
    self.frame = frame;
	-- Return the new frame
	return self.frame
end

function VitaPlannerL:CreatePlannerLeaderFrame()
	-- If we don't have our enclosing frame, then make one
	if not self.frame then self:InitUI() end;
	
	-- Create our surrounding frame to hold all of out details 
	local plannerFrame = CreateFrame("Frame", nil, self.frame)
    plannerFrame:Show()
	-- Take a slightly thinner width for effect
	plannerFrame:SetWidth(self.frame:GetWidth() - 20)
	-- Take the same height of the parent frame
    plannerFrame:SetHeight(self.frame:GetHeight() - 10)
    --[[plannerFrame:SetBackdrop({
      bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
      edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
      tile = true, tileSize = 64, edgeSize = 12,
      insets = { left = 2, right = 1, top = 2, bottom = 2 }
    })
    plannerFrame:SetBackdropColor(0.1,0.1,0.1,0.8)--]]
    plannerFrame:SetPoint("LEFT",self.frame,"LEFT",20,0)
    plannerFrame:SetPoint("RIGHT",self.frame,"RIGHT",-20,0)
	
	local zonePanelScroll = CreateFrame("ScrollFrame", "ZonePanelFrame", plannerFrame, "UIPanelScrollFrameTemplate")
	zonePanelScroll:SetWidth(178)
	--zonePanelScroll:SetHeight(490)
	zonePanelScroll:SetHeight(FRAME_PANEL_HEIGHT - 10)
	zonePanelScroll:SetPoint("TOPLEFT",plannerFrame,"TOPLEFT",0,-15)
	
	local zonePanelScrollBG = CreateFrame("Frame", nil, plannerFrame)
	zonePanelScrollBG:SetWidth(205)
	--zonePanelScrollBG:SetHeight(500)
	zonePanelScrollBG:SetHeight(FRAME_PANEL_HEIGHT)
	zonePanelScrollBG:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = VitaPlanner.Border.Dark, --"Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 64, edgeSize = 12,
		insets = { left = 2, right = 1, top = 2, bottom = 2 }
	})
	zonePanelScrollBG:SetBackdropColor(0.12,0.12,0.12,0.9)
	zonePanelScrollBG:SetPoint("TOPLEFT",plannerFrame,"TOPLEFT",0,-10)
	
	local scrollBar = _G["ZonePanelFrameScrollBar"]
	--scrollBar:SetPoint("RIGHT",zonePanelScrollBG,"RIGHT",-18,-3)
	local tex = zonePanelScroll:CreateTexture(nil,"BORDER",nil,-6)
	tex:SetPoint("TOP",zonePanelScroll,0,2)
	tex:SetPoint("RIGHT",scrollBar,3.7,0)
	tex:SetPoint("BOTTOM",zonePanelScroll,0,-2)
	tex:SetWidth(scrollBar:GetWidth()+10)
	tex:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
	tex:SetTexCoord(0,0.45,0.1640625,1)
	--print(scrollBar:GetWidth())
	
	local zonePanel = CreateFrame("Frame", nil, plannerFrame)
	zonePanel:SetWidth(205)
	--zonePanel:SetHeight(495)
	zonePanel:SetHeight(FRAME_PANEL_HEIGHT - 5)
	zonePanel:SetPoint("TOPLEFT",plannerFrame,"TOPLEFT",0,-10)
	zonePanel:SetBackdrop({
		--bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		--edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 64, edgeSize = 12,
		insets = { left = 2, right = 1, top = 2, bottom = 2 }
	})
	zonePanel:SetBackdropColor(0.12,0.12,0.12,0.9)
	plannerFrame.zonePanel = zonePanel
	
	self:PopulateZonePanel(zonePanel)
	
	zonePanelScroll:SetScrollChild(zonePanel)
	
	local infoPanel = CreateFrame("Frame", nil, plannerFrame)
	infoPanel:SetWidth(550)
	--infoPanel:SetHeight(500)
	infoPanel:SetHeight(FRAME_PANEL_HEIGHT)
	infoPanel:SetPoint("TOPRIGHT",plannerFrame,"TOPRIGHT", 0, -10)
	infoPanel:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",--"Interface\\Garrison\\GarrisonUIBackground",
		edgeFile = VitaPlanner.Border.Dark,
		tile = true, tileSize = 64, edgeSize = 12,
		insets = { left = 2, right = 1, top = 2, bottom = 2 }
	})
	--infoPanel:SetBackdropColor(0.7,0.7,0.7,0.8)
	--[[infoPanel:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 64, edgeSize = 12,
		insets = { left = 2, right = 1, top = 2, bottom = 2 }
	})--]]
	--[[local texture = infoPanel:CreateTexture()
	texture:SetAllPoints()
	texture:SetAlpha(1)
	texture:SetTexture(0,0,0,0.7)
	texture:SetAtlas("Garr_InfoBox-BackgroundTile")
	--]]
	infoPanel:SetBackdropColor(0.12,0.12,0.12,0.9)
	
	self:PopulateInfoPanel(infoPanel)
	--infoPanel:Hide()
	
	if not self.selectedBoss or	self.selectedBossID then
		infoPanel:Hide()
		local infoPanelNoBoss = CreateFrame("Frame", "VPLNoBossSelected", plannerFrame)
		infoPanelNoBoss:SetWidth(550)
		--infoPanelNoBoss:SetHeight(500)
		infoPanelNoBoss:SetHeight(FRAME_PANEL_HEIGHT)
		infoPanelNoBoss:SetPoint("TOPRIGHT",plannerFrame,"TOPRIGHT", 0, -10)
		infoPanelNoBoss:SetBackdrop({
			bgFile = "Interface\\ChatFrame\\ChatFrameBackground",--"Interface\\Garrison\\GarrisonUIBackground",--
			edgeFile = VitaPlanner.Border.Dark, --"Interface\\Tooltips\\UI-Tooltip-Border",
			tile = false, tileSize = 0, edgeSize = 12,
			insets = { left = 2, right = 1, top = 2, bottom = 2 }
		})
		--infoPanelNoBoss:SetTexCoord(0,8,0,8)
		--infoPanelNoBoss:SetBackdropColor(0.7,0.7,0.7,0.8)
		infoPanelNoBoss:SetBackdropColor(0.12,0.12,0.12,0.9)
		
		local closeBtn = CreateFrame("Button", nil, infoPanelNoBoss, "UIPanelButtonTemplate")
		closeBtn:Show()	
		--closeBtn:SetHeight(20)
		closeBtn:SetText("Close")
		closeBtn:SetWidth(closeBtn:GetFontString():GetWidth() + 20)
		closeBtn:SetPoint("TOPRIGHT", infoPanelNoBoss, "TOPRIGHT", -10, -10)
		closeBtn:SetScript("OnClick", function()
											self:Hide()
										end)
		infoPanelNoBoss.closeBtn = closeBtn
		
		--[[local backdrop = infoPanelNoBoss:CreateTexture(nil, "ARTWORK")
		--backdrop:SetAllPoints()
		backdrop:SetTexture("Interface\\Garrison\\GarrisonUIBackground", true)
		backdrop:SetVertexColor(0.8,0.8,0.8,0.8)
		backdrop:SetHorizTile(true)
		backdrop:SetVertTile(true)
		backdrop:SetTexCoord(0,4,0,4)
		backdrop:SetWidth(infoPanelNoBoss:GetWidth() - 3)
		backdrop:SetPoint("LEFT",-2)
		backdrop:SetPoint("RIGHT",-1)
		backdrop:SetPoint("TOP",-2)
		backdrop:SetPoint("BOTTOM",2)
		backdrop:SetHeight(16)
		--]]
		
		local noBossText = infoPanelNoBoss:CreateFontString("VPLNoBossSelectedText", "OVERLAY", "GameFontNormalLarge")
		noBossText:SetText("Please select a boss from the list\non the side before proceeding")
		noBossText:ClearAllPoints()
		noBossText:SetPoint("CENTER",infoPanelNoBoss)
	end
	

	-- Old Groups Layout
	infoPanel.group = {}
    infoPanel.groupNew = {}
	local raidGroupsFrame = CreateFrame("Frame", nil, infoPanel)
	local groupFramesHeight = (RAID_GROUP_VERT_GAP - 20) + ((RAID_UNIT_HEIGHT * 5) - (RAID_UNIT_VERT_GAP * 4)) + RAID_GROUP_VERT_GAP + ((RAID_UNIT_HEIGHT * 5) - (RAID_UNIT_VERT_GAP * 4))
	--print(groupFramesHeight)
	raidGroupsFrame:SetHeight(groupFramesHeight)
	local groupFramesWidth = (RAID_UNIT_WIDTH * 5) + (RAID_GROUP_HORZ_GAP * 4)
	raidGroupsFrame:SetWidth(groupFramesWidth)
	raidGroupsFrame:ClearAllPoints()
	raidGroupsFrame:SetPoint("TOP", infoPanel.plannerFrame, "BOTTOM", 0, -20)
	
	local lastGroupFrame = nil
	for i=1, 8 do
		local groupFrame = self:CreateGroupFrameNew(raidGroupsFrame, lastGroupFrame, i)
		infoPanel.group[i] = groupFrame
		lastGroupFrame = groupFrame
    end
    --[[
    local IS_GROUP_TESTING = false
    -- New Groups Layout
    if IS_GROUP_TESTING then
        local groupFrameTwo = CreateFrame("Frame", nil, infoPanel)
        groupFrameTwo:SetWidth(600)
        groupFrameTwo:SetHeight(600)
        groupFrameTwo:ClearAllPoints()
        groupFrameTwo:SetPoint("TOP", infoPanel.plannerFrame, "BOTTOM", 0, -20)
        groupFrameTwo:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = VitaPlanner.Border.Dark,
            --edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 64, edgeSize = 12,
            insets = { left = 0, right = 0, top = 0, bottom = 0}
        })
        groupFrameTwo:SetBackdropColor(0.0,0.0,0.1,1)
        groupFrameTwo:SetFrameStrata("TOOLTIP")

        local newLastGroupFrame = nil
        for i = 1, 8 do
            local newGroupFrame = self:CreateGroupFrameNew(groupFrameTwo, newLastGroupFrame, i)
            infoPanel.groupNew[i] = newGroupFrame
            newLastGroupFrame = newGroupFrame
        end
    end
    --]]

    self:UpdateRaidInfoGroups()
	
	infoPanel.raid = raidGroupsFrame
	
	plannerFrame.infoPanel = infoPanel

    --[[
	local groupLegend = CreateFrame("Frame", nil, raidGroupsFrame)
	groupLegend:SetPoint("TOPLEFT", lastGroupFrame, "TOPRIGHT", RAID_GROUP_HORZ_GAP, 0)
	groupLegend:SetPoint("BOTTOMRIGHT", raidGroupsFrame, "BOTTOMRIGHT", 0, 0)
	groupLegend:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = VitaPlanner.Border.Dark,--edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 64, edgeSize = 12,
		insets = { left = 2, right = 1, top = 2, bottom = 2 }
	})
	groupLegend:SetBackdropColor(0,0,0,0.3)
	
	local legendName = groupLegend:CreateFontString(nil,"OVERLAY","GameFontNormal")
	legendName:SetText("Legend")
	legendName:SetPoint("BOTTOM", groupLegend, "TOP", 0, 5)
	legendName:Show()
	
	local legendText = groupLegend:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
	legendText:SetText("|cff00ffffBackgrounds|r|n"..
		"    |cff00ff00Green|r for \'Correct\' placement|n"..
		"    |cffff0000Red|r for \'Incorrect\' placement|n"..
		"    |cffffff00Yellow|r for \'Neutral\' placement|n|n"..
		"    |cff999999Gray|r if player is offline|n|n"..
		"|cff00ffffIcons|r|n"..
		"    |TInterface\\Addons\\VitaPlanner_Leader\\icons\\melee.tga:16:16|t = Melee|n"..
		"    |TInterface\\Addons\\VitaPlanner_Leader\\icons\\ranged.tga:16:16|t = Ranged|n"..
		"    |TInterface\\Addons\\VitaPlanner_Leader\\icons\\healer.tga:16:16|t = Healer|n"..
		"    |TInterface\\Addons\\VitaPlanner_Leader\\icons\\tank.tga:16:16|t = Tank")
	legendText:SetPoint("TOPLEFT", groupLegend, "TOPLEFT", 8, -8)
	legendText:Show()
	legendText:SetJustifyH("LEFT")
    --]]
	-- Return the base frame
    return plannerFrame
end

function VitaPlannerL:PopulateZonePanel(frame)
	local BOSS_LIST_HEIGHT = 25
	local ZONE_TEXT_AREA_HEIGHT = 30
	
	local lastFrame = nil
	for i, raid in ipairs(self.BOSSES) do
		local zoneFrame = CreateFrame("Frame", "ZoneFrame_"..i, frame)
		
		local zoneID = raid.INSTANCEID
		local bossCount = #raid.BOSS	
		if self.selectedRaid == raid.ABBR then
			zoneFrame:SetHeight( ZONE_TEXT_AREA_HEIGHT + (BOSS_LIST_HEIGHT * bossCount) )
		else
			zoneFrame:SetHeight( ZONE_TEXT_AREA_HEIGHT )
		end
		if lastFrame then		
			zoneFrame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -2)
			zoneFrame:SetPoint("RIGHT", frame, "RIGHT", -2, 0)
		else
			zoneFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
			zoneFrame:SetPoint("RIGHT", frame, "RIGHT", -2, 0)
		end
		--local zoneTex = zoneFrame:CreateTexture()
		--zoneTex:SetAllPoints()
		--zoneTex:SetTexture(0.3,0.3,0.3,0.9)
		
		local zoneTextFrame = CreateFrame("CheckButton", "ZoneTextFrame_"..raid.ABBR, zoneFrame)
		zoneTextFrame:SetHeight(ZONE_TEXT_AREA_HEIGHT)
		zoneTextFrame:SetWidth(zoneFrame:GetWidth()-20)
		zoneTextFrame:SetPoint("TOPLEFT", zoneFrame, "TOPLEFT", 0, 0)
		zoneTextFrame:EnableMouse(true)
		zoneTextFrame:SetScript("PostClick", function(f)	
			--print("clicked");
			local p = f:GetParent()
			local pChildren = { p:GetChildren() }
			tremove(pChildren, 1)
			--print(tostring(f:GetChecked()))
			if f:GetChecked() then
				p:SetHeight(ZONE_TEXT_AREA_HEIGHT + (BOSS_LIST_HEIGHT * bossCount))
				for i, c in ipairs(pChildren) do
					c:Show()
				end
			else
				p:SetHeight(ZONE_TEXT_AREA_HEIGHT)
				for i, c in ipairs(pChildren) do
					c:Hide()
				end
			end
			--[[
			if (floor(p:GetHeight()) == ZONE_TEXT_AREA_HEIGHT) then
				p:SetHeight(ZONE_TEXT_AREA_HEIGHT + (BOSS_LIST_HEIGHT * bossCount))
				for i, c in ipairs(pChildren) do
					c:Show()
				end
			else
				p:SetHeight(ZONE_TEXT_AREA_HEIGHT)
				for i, c in ipairs(pChildren) do
					c:Hide()
				end
			end
			--]]
		end)
		
		local titleTex = zoneTextFrame:CreateTexture()
		titleTex:SetAllPoints()
		--titleTex:SetTexture(0.2,0.2,0.2,0.9)
		zoneTextFrame.text = titleTex
		
		local zoneText = zoneTextFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		zoneText:SetText(raid.NAME)
		zoneText:SetWordWrap(false)
		zoneText:SetWidth(zoneTextFrame:GetWidth() - 15)
		zoneText:SetHeight(ZONE_TEXT_AREA_HEIGHT)
		zoneText:SetJustifyH("LEFT")
		zoneText:SetJustifyV("MIDDLE")
		zoneText:SetPoint("TOPLEFT", zoneTextFrame, "TOPLEFT", 10, 0)
		
		local lastBossFrame = nil
		for i = 1, bossCount do
			local bossID = raid.BOSS[i].ENCOUNTERID
			local bossName = raid.BOSS[i].NAME
			
			local bossFrame = CreateFrame("CheckButton", raid.ABBR.."_BossID_"..bossID, zoneFrame)
			bossFrame:SetHeight(BOSS_LIST_HEIGHT)
			if lastBossFrame then
				bossFrame:SetPoint("TOPLEFT", lastBossFrame, "BOTTOMLEFT", 0, 0)
				bossFrame:SetPoint("RIGHT", zoneFrame, "RIGHT", 0, 0)
			else
				bossFrame:SetPoint("TOPLEFT", zoneTextFrame, "BOTTOMLEFT", 0, 0)
				bossFrame:SetPoint("RIGHT", zoneFrame, "RIGHT", 0, 0)
			end
			bossFrame:SetBackdrop({
				bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
				--edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
				tile = true, tileSize = 64, edgeSize = 6,
				insets = { left = 15, right = 5, top = 2, bottom = 2 }
			})
			bossFrame:SetBackdropColor(0.3,0.1,0.1,0)
			bossFrame:EnableMouse(true)
			bossFrame:SetScript("PostClick", function(f)
				--f:LockHighlight()
				--print (bossName.." clicked")
				self:SetCurrentBoss(f, bossID, bossName, zoneID)
				--print(bossName .. ":"..bossID .. " pressed") 
			end)
			
			local htex = bossFrame:CreateTexture()
			--htex:SetTexture("Interface/Buttons/UI-Panel-Button-Highlight")
			htex:SetTexture("Interface/Buttons/UI-Listbox-Highlight2")
			--htex:SetTexCoord(0, 0.625, 0, 0.6875)
			htex:SetAllPoints()
			htex:SetPoint("LEFT",bossFrame,"LEFT",5,0)
			htex:SetPoint("RIGHT",bossFrame,"RIGHT",3,0)
			htex:SetVertexColor(0.2,0.2,0.2,0.6)
			bossFrame:SetHighlightTexture(htex)
			--[[local bossBG = bossFrame:CreateTexture()
			bossBG:SetAllPoints()
			local num = "0."..i
			num = tonumber(num)
			bossBG:SetTexture(num,num,num,0.4)
			--]]
						
			local bossFrameText = bossFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
			bossFrameText:SetWidth(bossFrame:GetWidth()-30)
			bossFrameText:SetHeight(bossFrame:GetHeight()-4)
			bossFrameText:SetText(bossName)
			bossFrameText:SetWordWrap(false)
			bossFrameText:SetJustifyH("LEFT")
			bossFrameText:SetJustifyV("MIDDLE")
			bossFrameText:SetPoint("CENTER", bossFrame, "CENTER", 0, -2)
			bossFrameText:SetPoint("LEFT", bossFrame, "LEFT", 20, 0)
			
			bossFrame.text = bossFrameText
			
			if self.selectedRaid ~= raid.ABBR then				
				bossFrame:Hide()
			end
			
			lastBossFrame = bossFrame
		end
		
		local sep = frame:CreateTexture()
		sep:SetSize(zoneFrame:GetWidth()-5,1)
		sep:SetTexture(0.6,0.6,0.6,0.2)
		sep:SetPoint("CENTER",zoneFrame,"BOTTOM",0,-1)
		
		lastFrame = zoneFrame -- _G["ZoneFrame_"..i]
	end
end

function VitaPlannerL:PopulateInfoPanel(frame)
	local closeBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	closeBtn:Show()	
	--closeBtn:SetHeight(20)
	closeBtn:SetText("Close")
	closeBtn:SetWidth(closeBtn:GetFontString():GetWidth() + 20)
	closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -10)
	closeBtn:SetScript("OnClick", function()
										self:Hide()
									end)
	frame.closeBtn = closeBtn

	local lblName = CreateFrame("Button", "VPLBossLink", frame)
	--lblName:SetNormalFontObject("GameFontNormalLarge")
	lblName:SetHeight(25)
	lblName:SetFrameStrata("DIALOG")
	lblName:SetPoint("TOPLEFT",frame,"TOPLEFT",10,-10)
	lblName:EnableMouse(true)
	local bossName = lblName:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	bossName:SetHeight(lblName:GetHeight())
	bossName:SetText("Default Boss Link")
	lblName:SetWidth(bossName:GetWidth()+20)
	bossName:SetJustifyH("LEFT")
	bossName:SetJustifyV("MIDDLE")
	bossName:SetPoint("CENTER", lblName, "CENTER", 0, -2)
	bossName:SetPoint("LEFT", lblName, "LEFT", 0, 0)
	lblName.name = bossName
	--lblName:SetText("Default Boss Name")
	frame.boss = lblName
	
	-- SIZE SECTION
	local sizeFrame = self:CreateSizeSection(frame)
	frame.sizeFrame = sizeFrame
	-- Planner Section
	local plannerFrame = self:CreatePlannerSection(frame)
	frame.plannerFrame = plannerFrame
end

function VitaPlannerL:CreateSizeSection(frame)
	local sizeFrame = CreateFrame("Frame", nil, frame)
	sizeFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -35)
	sizeFrame:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
		-- Size Header
		local sizeMarker = CreateFrame("Frame", nil, sizeFrame)
		sizeMarker:SetWidth(sizeFrame:GetWidth()-20)
		sizeMarker:SetHeight(20)
		local sizeLine = sizeMarker:CreateTexture()
		sizeLine:SetSize(sizeMarker:GetWidth(), 1)
		sizeLine:SetTexture(0.6,0.6,0.6,0.6)
		sizeLine:SetPoint("CENTER", sizeMarker)
		sizeMarker:SetPoint("TOP", sizeFrame, "TOP", 0, 0)		
		local sizeLbl = sizeMarker:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		sizeLbl:SetText("Size")
		sizeLbl:SetHeight(sizeMarker:GetHeight())
		sizeLbl:SetPoint("CENTER", sizeMarker)
		
		-- Buttons
		local sizeButtons = CreateFrame("Frame", nil, sizeFrame)
			--[[
				{ ["NAME"] = "Flexible",		["ID"] = "Flexible",	["TOP"] = 1,	["Y"] = 0, ["DIFFID"] = 14 },
				{ ["NAME"] = "10 Heroic",		["ID"] = "H10",			["TOP"] = 1,	["Y"] = 0, ["DIFFID"] = 5 },
				{ ["NAME"] = "25 Heroic",		["ID"] = "H25",			["TOP"] = 0,	["Y"] = 1, ["DIFFID"] = 6 },
				{ ["NAME"] = "10 Normal",		["ID"] = "N10",			["TOP"] = 1,	["Y"] = 0, ["DIFFID"] = 3 },
				{ ["NAME"] = "25 Normal",		["ID"] = "N25",			["TOP"] = 0,	["Y"] = 1, ["DIFFID"] = 4 },--]]
			local buttonList = {
				{ ["NAME"] = "Normal",		["ID"] = "Normal",	["TOP"] = 1,	["Y"] = 0, ["DIFFID"] = 14 },
				{ ["NAME"] = "Heroic",		["ID"] = "Heroic",	["TOP"] = 1,	["Y"] = 0, ["DIFFID"] = 15 },
				{ ["NAME"] = "Mythic",		["ID"] = "Mythic",	["TOP"] = 1,	["Y"] = 0, ["DIFFID"] = 16 }
			}
			
			local lastButton = nil
			local topButton = nil
			local frameWidth = 0
			local frameHeight = 0
			local maxYVal = 0
			for i,b in ipairs(buttonList) do
				local button = CreateFrame("Button", b.ID.."CheckButton", sizeButtons, "UIPanelButtonTemplate")
				_G[b.ID.."CheckButton"]:SetText(b.NAME)
				button:SetWidth(100)
				button:SetScript("OnClick", function(s,btn,down) self:SizeButtonClick(s, btn, down, b) end)
				local height = button:GetHeight()
				if lastButton then
					if topButton and tonumber(b.TOP) ~= 1 then -- Put this button down one
						button:SetPoint("TOPLEFT", topButton, "BOTTOMLEFT", 0, -(tonumber(height) / 2))
						if maxYVal < b.Y then
							frameHeight = frameHeight + (height + (height/2))
							maxYVal = b.Y
						end
					else -- Put the button to the right
						button:SetPoint("TOPLEFT", lastButton, "TOPRIGHT", 30, 0)
						frameWidth = frameWidth + (30 + button:GetWidth())
						lastButton = button
					end
				else -- First button
					button:SetPoint("TOPLEFT", sizeButtons, "TOPLEFT", 0, 0)
					frameWidth = frameWidth + button:GetWidth()
					frameHeight = frameHeight + height
					lastButton = button
				end
				if (tonumber(b.TOP) == 1) then topButton = button else topButton = nil end
				-- Default selection
				if tonumber(self.difficulty) == tonumber(b.DIFFID) then
					button:Click("LeftButton")
				end
			end
		sizeButtons:ClearAllPoints()
		--print(frameWidth)
		--print(frameHeight)
		sizeFrame:SetHeight(20 + frameHeight)
		
		sizeButtons:SetWidth(frameWidth)
		sizeButtons:SetHeight(frameHeight)
		sizeButtons:SetPoint("TOP", sizeFrame, "TOP", 0, -20)
	
	return sizeFrame
end

function VitaPlannerL:CreatePlannerSection(frame)
	local plannerFrame = CreateFrame("Frame", nil, frame)
	plannerFrame:SetPoint("TOPLEFT", frame.sizeFrame, "BOTTOMLEFT", 0, 0)
	plannerFrame:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
	plannerFrame:SetHeight(50)
	
		local plannerMarker = CreateFrame("Frame", nil, plannerFrame)
		plannerMarker:SetWidth(frame:GetWidth()-20)
		plannerMarker:SetHeight(20)
		local plannerLine = plannerMarker:CreateTexture()
		plannerLine:SetSize(plannerMarker:GetWidth(), 1)
		plannerLine:SetTexture(0.6,0.6,0.6,0.6)
		plannerLine:SetPoint("CENTER", plannerMarker)
		plannerMarker:SetPoint("TOP", plannerFrame, "TOP", 0, -5)

		local plannerLbl = plannerMarker:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		plannerLbl:SetText("Planner")
		plannerLbl:SetHeight(plannerMarker:GetHeight())
		plannerLbl:SetPoint("CENTER", plannerMarker)

		local checkRaid = CreateFrame("Button", "AskForSelections", plannerFrame, "UIPanelButtonTemplate")
		checkRaid:Show()	
		checkRaid:SetText("Ask For Selections")
		checkRaid:SetWidth(checkRaid:GetFontString():GetWidth() + 20)
		checkRaid:SetPoint("TOPLEFT", plannerMarker, "TOPLEFT", 0, -20)
		checkRaid:SetScript("OnClick", function()
			self:AskRaidForSelections()
		end)
		frame.checkRaid = checkRaid
		self.checkRaid = checkRaid
		checkRaid:Disable()

		-- Cancel Check Button
		local cancelCheckRaid = CreateFrame("Button", nil, plannerFrame, "UIPanelButtonTemplate")
		cancelCheckRaid:Hide()
		cancelCheckRaid:SetText("Cancel")
		cancelCheckRaid:SetWidth(cancelCheckRaid:GetFontString():GetWidth() + 20)
		cancelCheckRaid:SetPoint("LEFT", checkRaid, "RIGHT", 10, 0)
		cancelCheckRaid:SetScript("OnClick", function()
			VitaPlanner.timeout = 0
			VitaPlanner.timeoutLeft = 0
			self.checkRaid:Enable()
			--[[self.inList = {}
			self.outList = {}
			self.ignoreList = {}
			self:UpdateMaxGroupSet()
			self:UpdateRaidInfoGroups()
			self:UpdateLists()
			--]]
			self.cancelCheckRaid:Hide()
		end)
		self.cancelCheckRaid = cancelCheckRaid

		local finaliseBtn = CreateFrame("Button","AnnounceGroupsSet",plannerFrame,"UIPanelButtonTemplate")
		finaliseBtn:Show()
		finaliseBtn:Disable()
		finaliseBtn:SetText ("Announce Groups Set")
		finaliseBtn:SetWidth(finaliseBtn:GetFontString():GetWidth() + 20)
		--finaliseBtn:SetTextFontObject("GameFontNormal")
		finaliseBtn:SetPoint("TOPRIGHT", plannerMarker, "TOPRIGHT", 0, -20)
		finaliseBtn:SetScript("OnClick", function()
			--print("Sending Groups Set")
			local message, maxGroupNum = self:CreateGroupSetMessage()
			if IsInRaid() then
				self:SendClientCommand("SET_GROUPS", message, "RAID")
			else
				self:SendClientCommand("SET_GROUPS", message, UnitName("player"))
			end
			
			SendChatMessage( MSG_Prefix .. "Groups have been set! Please check 1 to "..maxGroupNum, "RAID_WARNING")
		end)
		self.announce = finaliseBtn
		frame.announce = finaliseBtn

		local resetListButton = CreateFrame("Button", nil, plannerFrame, "UIPanelButtonTemplate")
		resetListButton:SetText("Reset Selections")
		resetListButton:SetWidth(resetListButton:GetFontString():GetWidth() + 20)
		resetListButton:SetPoint("RIGHT", finaliseBtn, "LEFT", -10, 0)
		resetListButton:SetScript("OnClick", function()
			--[[self.inList = {}
			self.outList = {}
			self.ignoreList = {}
			self.reasonList = {}--]]
			self:UpdateMaxGroupSet()
            self:ResetLists()
			--self:UpdateRaidInfoGroups()
			--self:UpdateLists()
		end)
		self.resetListButton = resetListButton
		
	return plannerFrame
end

function VitaPlannerL:SizeButtonClick(widget, button, down, buttonArray)
	local sizeButtons = widget:GetParent()
	local buttons = { sizeButtons:GetChildren() }
	
	for i, c in ipairs(buttons) do
		c:UnlockHighlight()
		if c == widget then
			c:LockHighlight()
			self.difficulty = buttonArray.DIFFID
			self.diffName = buttonArray.NAME
			self:UpdateInfoPanel()
		end
	end
end

function VitaPlannerL:CreateGroupFrame(raidInfoFrame, groupFrame, index)

	local frame = CreateFrame("Frame", "VitaGroup_"..index, raidInfoFrame)
	if not groupFrame then
		frame:SetPoint("TOPLEFT", raidInfoFrame, "TOPLEFT", 0, -(RAID_GROUP_VERT_GAP-20))
	elseif index == 6 then
		frame:SetPoint("TOPLEFT", _G["VitaGroup_1"], "BOTTOMLEFT", 0, -RAID_GROUP_VERT_GAP)
	else
		frame:SetPoint("TOPLEFT", groupFrame, "TOPRIGHT", RAID_GROUP_HORZ_GAP, 0)
	end
	frame:SetWidth(RAID_UNIT_WIDTH)
	frame:SetHeight(RAID_UNIT_HEIGHT * 5 - RAID_UNIT_VERT_GAP * 4)
	frame:Show()
	frame:SetBackdrop({
      bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
      edgeFile = VitaPlanner.Border.Dark,
	  --edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
      tile = true, tileSize = 64, edgeSize = 12,
      insets = { left = 0, right = 0, top = 0, bottom = 0}
    })
	frame:SetBackdropColor(0.1,0.1,0.1,0.5)
	
	local frameName = frame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	frameName:SetText("Group "..index)
	frameName:SetPoint("BOTTOM", frame, "TOP", 0, 5)
	frameName:Show()
	
	frame.units = {}
	
	for i=1, 5 do
		local raidIndex = i + ((tonumber(index)-1) * 5)
		local unitPosition = CreateFrame("Frame", "VitaRaidUnit_"..raidIndex, frame)
		unitPosition:SetHeight(RAID_UNIT_HEIGHT)
		if i == 1 then
			unitPosition:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
		else
			unitPosition:SetPoint("TOPLEFT", frame.units[i-1], "BOTTOMLEFT", 0, RAID_UNIT_VERT_GAP)
		end
		unitPosition:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
		unitPosition:SetBackdrop({
			bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
			--edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			tile = true, tileSize = 64, edgeSize = 12,
			insets = { left = 3, right = 2, top = 2, bottom = 2 }
		})
		unitPosition:EnableMouse(true)
		unitPosition:RegisterForDrag("LeftButton")
		unitPosition:SetScript("OnDragStart", function(frame, button) self:BeginMovingRaidMember(frame,button) end)
		unitPosition:SetScript("OnDragStop", function(frame) self:TryInitiateSwap(frame) end)
		unitPosition:SetScript("OnEnter", function(f) self:SetCustomTooltip(f, "UnitHover") end)
		unitPosition:SetScript("OnLeave", function(f) GameTooltip:Hide() end)
		unitPosition:SetBackdropColor(0.1,0.1,0.1,0)
		
		local unitFrame = CreateFrame("Frame", "VitaGroup_"..index.."_Unit_"..i, unitPosition)
		unitFrame:SetHeight(RAID_UNIT_HEIGHT)
		unitFrame:SetPoint("TOPLEFT", unitPosition, "TOPLEFT", 0, 0)
		unitFrame:SetPoint("BOTTOMRIGHT", unitPosition, "BOTTOMRIGHT", 0, 0)
		
		local unitName = unitFrame:CreateFontString("VitaGroup_"..index.."_Unit_"..i.."_NAME", "OVERLAY", "GameFontHighlightSmallOutline")
		unitName:SetText("")
		unitName:SetWidth(RAID_UNIT_WIDTH-RAID_UNIT_HEIGHT-5)
		unitName:SetWordWrap(false)
		unitName:SetJustifyH("LEFT")
		unitName:SetPoint("LEFT", unitFrame, "LEFT", 5, 0)
		local fontFile, fontHeight, flags = unitName:GetFont()
		unitName:SetFont(fontFile, fontHeight+1, "OUTLINE")
		unitFrame.name = unitName
		
		local unitSpec = CreateFrame("Frame",nil,unitFrame)
		unitSpec:SetWidth(RAID_UNIT_HEIGHT-10)
		unitSpec:SetHeight(RAID_UNIT_HEIGHT-10)
		unitSpec:SetPoint("CENTER",unitFrame,"CENTER",0,0)
		unitSpec:SetPoint("RIGHT",unitFrame,"RIGHT",-5,0)
		local unitSpecTex = unitSpec:CreateTexture()
		unitSpecTex:SetAllPoints()
		
		unitSpec.tex = unitSpecTex
		unitFrame.spec = unitSpec

		if i < 5 then
			local sizeLine = frame:CreateTexture()
			sizeLine:SetSize(frame:GetWidth()-3, 1)
			sizeLine:SetTexture(0.6,0.6,0.6,0.6)
			sizeLine:SetPoint("BOTTOM", unitPosition)
		end
		--sizeMarker:SetPoint("TOP", sizeFrame, "TOP", 0, 0)		
		
		_G["VitaRaidUnit_"..raidIndex.."_NAME"] = unitName
		unitPosition.frame = unitFrame
		unitPosition.icon = unitFrame.spec.tex
		frame.units[i] = unitPosition
	end
	
	return frame
end

function VitaPlannerL:CreateGroupFrameNew(raidInfoFrame, groupFrame, index)

    local frame = CreateFrame("Frame", "VitaGroup_"..index, raidInfoFrame)
    if not groupFrame then
        frame:SetPoint("TOPLEFT", raidInfoFrame, "TOPLEFT", 0, -(RAID_GROUP_VERT_GAP-20))
    --[[elseif index == 6 then
        frame:SetPoint("TOPLEFT", _G["VitaGroupN_1"], "BOTTOMLEFT", 0, -RAID_GROUP_VERT_GAP)
    else
        frame:SetPoint("TOPLEFT", groupFrame, "TOPRIGHT", RAID_GROUP_HORZ_GAP, 0)
    end--]]

    elseif index % 2 ~= 0 and index ~= 1 then
        frame:SetPoint("TOPLEFT", _G["VitaGroup_".. index-2], "BOTTOMLEFT", 0, -RAID_GROUP_VERT_GAP)
    else
        frame:SetPoint("TOPLEFT", groupFrame, "TOPRIGHT", RAID_GROUP_HORZ_GAP, 0)
    end
    frame:SetWidth(RAID_UNIT_WIDTHN)
    frame:SetHeight(RAID_UNIT_HEIGHTN * 5 - RAID_UNIT_VERT_GAP * 4)
    frame:Show()
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = VitaPlanner.Border.Dark,
        --edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 64, edgeSize = 12,
        insets = { left = 0, right = 0, top = 0, bottom = 0}
    })
    frame:SetBackdropColor(0.1,0.1,0.1,0.5)

    local frameName = frame:CreateFontString(nil,"OVERLAY","GameFontNormal")
    frameName:SetText("Group "..index)
    frameName:SetPoint("BOTTOM", frame, "TOP", 0, 5)
    frameName:Show()

    frame.units = {}

    for i=1, 5 do
        local raidIndex = i + ((tonumber(index)-1) * 5)
        local unitPosition = CreateFrame("Frame", "VitaRaidUnit_"..raidIndex, frame)
        unitPosition:SetHeight(RAID_UNIT_HEIGHTN)
        if i == 1 then
            unitPosition:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        else
            unitPosition:SetPoint("TOPLEFT", frame.units[i-1], "BOTTOMLEFT", 0, RAID_UNIT_VERT_GAP)
        end
        unitPosition:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
        unitPosition:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            --edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 64, edgeSize = 12,
            insets = { left = 3, right = 2, top = 2, bottom = 2 }
        })
        unitPosition:EnableMouse(true)
        unitPosition:RegisterForDrag("LeftButton")
        unitPosition:SetScript("OnDragStart", function(frame, button) self:BeginMovingRaidMember(frame,button) end)
        unitPosition:SetScript("OnDragStop", function(frame) self:TryInitiateSwap(frame) end)
        unitPosition:SetScript("OnEnter", function(f) self:SetCustomTooltip(f, "UnitHover") end)
        unitPosition:SetScript("OnLeave", function(f) GameTooltip:Hide() end)
        unitPosition:SetBackdropColor(0.1,0.1,0.1,0)

        unitPosition:SetScript("OnMouseDown", function(frame, button) self:OpenModifyMenu(frame, button) end)

        local unitFrame = CreateFrame("Frame", "VitaGroup_"..index.."_Unit_"..i, unitPosition)
        unitFrame:SetHeight(RAID_UNIT_HEIGHTN)
        unitFrame:SetPoint("TOPLEFT", unitPosition, "TOPLEFT", 0, 0)
        unitFrame:SetPoint("BOTTOMRIGHT", unitPosition, "BOTTOMRIGHT", 0, 0)

        local unitName = unitFrame:CreateFontString("VitaGroup_"..index.."_Unit_"..i.."_NAME", "OVERLAY", "GameFontHighlightSmallOutline")
        unitName:SetText("")
        unitName:SetWidth(RAID_UNIT_WIDTHN-RAID_UNIT_HEIGHTN-5)
        unitName:SetWordWrap(false)
        unitName:SetJustifyH("LEFT")
        unitName:SetPoint("LEFT", unitFrame, "LEFT", 5, 0)
        local fontFile, fontHeight, flags = unitName:GetFont()
        unitName:SetFont(fontFile, fontHeight+1, "OUTLINE")
        unitFrame.name = unitName

        local unitSpec = CreateFrame("Frame",nil,unitFrame)
        unitSpec:SetWidth(RAID_UNIT_HEIGHTN-10)
        unitSpec:SetHeight(RAID_UNIT_HEIGHTN-10)
        unitSpec:SetPoint("CENTER",unitFrame,"CENTER",0,0)
        unitSpec:SetPoint("RIGHT",unitFrame,"RIGHT",-5,0)
        local unitSpecTex = unitSpec:CreateTexture()
        unitSpecTex:SetAllPoints()
        unitSpec:Hide()

        local unitSelection = unitFrame:CreateFontString("VitaGroup_"..index.."_Unit_"..i.."_SELECTION", "OVERLAY", "GameFontHighlightSmallOutline")
        unitSelection:SetText("")
        unitSelection:SetWidth(55)
        unitSelection:SetHeight(RAID_UNIT_HEIGHTN-10)
        unitSelection:SetJustifyH("CENTER")
        unitSelection:SetPoint("RIGHT", unitFrame, "RIGHT", 0, 0)
        local fontFileS, fontHeightS, flagsS = unitSelection:GetFont()
        unitSelection:SetFont(fontFileS, fontHeightS+1, "OUTLINE")
        unitFrame.selection = unitSelection

        local dividerSel = frame:CreateTexture()
        dividerSel:SetSize(1, unitPosition:GetHeight()-3)
        dividerSel:SetTexture(0.6,0.6,0.6,0.6)
        dividerSel:SetPoint("LEFT", unitSelection)

        local unitRole = unitFrame:CreateFontString("VitaGroup_"..index.."_Unit_"..i.."_ROLE", "OVERLAY", "GameFontHighlightSmallOutline")
        unitRole:SetText("")
        unitRole:SetWidth(55)
        unitRole:SetHeight(RAID_UNIT_HEIGHTN-10)
        unitRole:SetJustifyH("CENTER")
        unitRole:SetPoint("RIGHT", dividerSel, "LEFT", 5, 0)
        local fontFileR, fontHeightR, flagsR = unitRole:GetFont()
        unitRole:SetFont(fontFileR, fontHeightR+1, "OUTLINE")
        unitFrame.role = unitRole

        local dividerRole = frame:CreateTexture()
        dividerRole:SetSize(1, unitPosition:GetHeight()-3)
        dividerRole:SetTexture(0.6,0.6,0.6,0.6)
        dividerRole:SetPoint("LEFT", unitRole)

        unitSpec.tex = unitSpecTex
        unitFrame.spec = unitSpec

        if i < 5 then
            local sizeLine = frame:CreateTexture()
            sizeLine:SetSize(frame:GetWidth()-3, 1)
            sizeLine:SetTexture(0.6,0.6,0.6,0.6)
            sizeLine:SetPoint("BOTTOM", unitPosition)
        end
        --sizeMarker:SetPoint("TOP", sizeFrame, "TOP", 0, 0)

        _G["VitaRaidUnit_"..raidIndex.."_NAME"] = unitName
        unitPosition.frame = unitFrame
        unitPosition.icon = unitFrame.spec.tex
        unitPosition.role = unitFrame.role
        unitPosition.selection = unitFrame.selection
        frame.units[i] = unitPosition
    end

    return frame
end

function VitaPlannerL:CreateModifyMenuFrame(frame)
    local menu = CreateFrame("Frame", nil, self.mainFrame)
    menu:Hide()
    menu:SetWidth(165)
    menu:SetHeight(50)
    menu:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        --edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeFile = VitaPlanner.Border.Dark,
        tile = true, tileSize = 64, edgeSize = 6,
        insets = { left = 2, right = 1, top = 2, bottom = 2 }
    })
    menu:SetBackdropColor(0.1,0.1,0.1,0.8)
    menu:SetFrameStrata("DIALOG")
    menu:EnableMouse(true)
    menu:SetHitRectInsets(0, 0, 0, 0)

    local heading = menu:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    heading:SetText("Manually Select Response")
    heading:SetWordWrap(false)
    heading:SetHeight(16)
    heading:SetPoint("TOPLEFT", menu, "TOPLEFT", 5, -2)
    heading:SetPoint("TOPRIGHT", menu, "TOPRIGHT", -5, -2)
    --[[
    local inFrame = CreateFrame("Button", nil, menu)
    --lblName:SetNormalFontObject("GameFontNormalLarge")
    inFrame:SetHeight(25)
    inFrame:SetFrameStrata("TOOLTIP")
    inFrame:SetPoint("TOPLEFT",menu,"TOPLEFT",10,-20)
    inFrame:EnableMouse(true)
    local inBtn = inFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    inBtn:SetHeight(inFrame:GetHeight())
    inBtn:SetText("In")
    inFrame:SetWidth(inBtn:GetWidth()+20)
    inBtn:SetJustifyH("LEFT")
    inBtn:SetJustifyV("MIDDLE")
    inBtn:SetPoint("CENTER", inFrame, "CENTER", 0, -2)
    inBtn:SetPoint("LEFT", inFrame, "LEFT", 0, 0)
    inBtn.name = inBtn--]]

    local inFrame = CreateFrame("Button", nil, menu, "UIPanelButtonTemplate")
    inFrame:SetText("In")
    inFrame:SetWidth(inFrame:GetFontString():GetWidth() + 20)
    inFrame:SetPoint("TOPLEFT", menu, "TOPLEFT", 5, -20)
    inFrame:SetScript("OnClick", function(f, btn)
        local _, initID = strsplit("_", self.currentModifyUnitFrame:GetName())
        --local actualInitID = _G["VitaRaidUnit_"..initID.."-NUMBER"]
        local name = _G["VitaRaidUnit_"..initID.."-NAME"]
        name = VitaPlanner.UnAmbiguate(name)
        --print (initID, name)
        self:SetList(name, "true", nil, nil)
        --self:UpdateRaidInfoGroups()
        self:UpdateLists()
        self.modifyMenu:Hide()
        self:SendLeaderCommand("COPY_WHISPER", format("%s^%s",name,"IN"), "RAID")
    end)
    inFrame:Show()

    local outFrame = CreateFrame("Button", nil, menu, "UIPanelButtonTemplate")
    outFrame:SetText("Out")
    outFrame:SetWidth(outFrame:GetFontString():GetWidth() + 20)
    outFrame:SetPoint("LEFT", inFrame, "RIGHT", 5, 0)
    outFrame:SetScript("OnClick", function(f, btn)
        local _, initID = strsplit("_", self.currentModifyUnitFrame:GetName())
        --local actualInitID = _G["VitaRaidUnit_"..initID.."-NUMBER"]
        local name = _G["VitaRaidUnit_"..initID.."-NAME"]
        name = VitaPlanner.UnAmbiguate(name)
        --print (initID, name)
        self:SetList(name, nil, "true", nil)
        --self:UpdateRaidInfoGroups()
        self:UpdateLists()
        self.modifyMenu:Hide()
        self:SendLeaderCommand("COPY_WHISPER", format("%s^%s",name,"OUT"), "RAID")
    end)
    outFrame:Show()

    local neuFrame = CreateFrame("Button", nil, menu, "UIPanelButtonTemplate")
    neuFrame:SetText("Neutral")
    neuFrame:SetWidth(neuFrame:GetFontString():GetWidth() + 20)
    neuFrame:SetPoint("LEFT", outFrame, "RIGHT", 5, 0)
    neuFrame:SetScript("OnClick", function(f, btn)
        local _, initID = strsplit("_", self.currentModifyUnitFrame:GetName())
        --local actualInitID = _G["VitaRaidUnit_"..initID.."-NUMBER"]
        local name = _G["VitaRaidUnit_"..initID.."-NAME"]
        name = VitaPlanner.UnAmbiguate(name)
        --print (initID, name)
        self:SetList(name, nil, nil, "true")
        --self:UpdateRaidInfoGroups()
        self:UpdateLists()
        self.modifyMenu:Hide()
        self:SendLeaderCommand("COPY_WHISPER", format("%s^%s",name,"NEUTRAL"), "RAID")
    end)
    neuFrame:Show()

    return menu
end

function VitaPlannerL:CopyRaidUnitFrame(frame)
	--local raidIndex = i + ((tonumber(index)-1) * 5)
	local unitPosition = CreateFrame("Frame", nil, UIParent) 		-- A.K.A: "VitaRaidUnit_"..raidIndex
	unitPosition:Hide()
	unitPosition:SetHeight(RAID_UNIT_HEIGHTN)
	unitPosition:SetWidth(RAID_UNIT_WIDTHN)
	--unitPosition:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
	unitPosition:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		--edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeFile = VitaPlanner.Border.Dark,
		tile = true, tileSize = 64, edgeSize = 6,
		insets = { left = 2, right = 1, top = 2, bottom = 2 }
	})
	--unitPosition:EnableMouse()
	--unitPosition:RegisterForDrag("LeftButton")
	--unitPosition:SetScript("OnDragStart", function(frame, button) self:BeginMovingRaidMember(frame,button) end)
	--unitPosition:SetScript("OnDragStop", function(frame) self:TryInitiateSwap(frame) end)	
	unitPosition:SetBackdropColor(0.1,0.1,0.1,0.8)
	unitPosition:SetScript("OnUpdate", function(s, elapsed)
		local uiScale, cursorX, cursorY = UIParent:GetEffectiveScale(), GetCursorPosition()
		--print (cursorX .. " , " .. cursorY)
		s:SetPoint("CENTER", nil, "BOTTOMLEFT",cursorX / uiScale,cursorY / uiScale)
	end)
	unitPosition:SetFrameStrata("TOOLTIP")
	unitPosition:SetAlpha(0.75)
	
	local unitFrame = CreateFrame("Frame", nil, unitPosition)		-- A.K.A: "VitaGroup_"..index.."_Unit_"..i
	unitFrame:SetHeight(RAID_UNIT_HEIGHTN)
	unitFrame:SetPoint("TOPLEFT", unitPosition, "TOPLEFT", 0, 0)
	unitFrame:SetPoint("BOTTOMRIGHT", unitPosition, "BOTTOMRIGHT", 0, 0)
	
	local unitName = unitFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")		-- A.K.A: "VitaGroup_"..index.."_Unit_"..i.."_NAME"
	unitName:SetText("")
	unitName:SetWidth(RAID_UNIT_WIDTHN-RAID_UNIT_HEIGHTN-5)
	unitName:SetWordWrap(false)
	unitName:SetJustifyH("LEFT")
	unitName:SetPoint("LEFT", unitFrame, "LEFT", 5, 0)
	unitFrame.name = unitName
	
	local unitSpec = CreateFrame("Frame",nil,unitFrame)
	unitSpec:SetWidth(RAID_UNIT_HEIGHTN-5)
	unitSpec:SetHeight(RAID_UNIT_HEIGHTN-5)
	unitSpec:SetPoint("CENTER",unitFrame,"CENTER",0,0)
	unitSpec:SetPoint("RIGHT",unitFrame,"RIGHT",-5,0)
	local unitSpecTex = unitSpec:CreateTexture()
	unitSpecTex:SetAllPoints()
	unitSpecTex:SetAlpha(0.5)
	
	unitSpec.tex = unitSpecTex
	unitFrame.spec = unitSpec
	unitPosition.frame = unitFrame	
	
	return unitPosition
end

--[[
function VitaPlannerL:PopulateBossInfoPanel(bossInfo)
	-- Raid Zone Select
	local height = 0
	
	local zoneText = bossInfo:CreateFontString(nil,"OVERLAY","GameFontNormal")
	zoneText:SetText("Raid")
	
	local zoneSelect = CreateFrame("Frame", "ZoneSelectDropDown", bossInfo, "UIDropDownMenuTemplate")
		
	zoneSelect:SetPoint("LEFT", zoneText, "LEFT", 200, -5)
	UIDropDownMenu_Initialize(zoneSelect, function(...) VitaPlannerL.ZoneSelectDropDownInitialize(VitaPlannerL, ...) end);	
	UIDropDownMenu_SetWidth(zoneSelect, 150)
	UIDropDownMenu_SetButtonWidth(zoneSelect, 174)
	UIDropDownMenu_SetText(zoneSelect, self.zoneName)
	self.ZoneSelect = zoneSelect
	zoneSelect:Show()
	ToggleDropDownMenu(nil, nil, zoneSelect)
	
	height = height + zoneText:GetHeight()
	
	-- Raid Difficulty Select
	local difficultyText = bossInfo:CreateFontString(nil,"OVERLAY","GameFontNormal")
	difficultyText:SetPoint("TOPLEFT", zoneText, "BOTTOMLEFT", 0, -20)
	difficultyText:SetText("Raid Difficulty")
	
	height = height + 20
	
	local difficultySelect = CreateFrame("Frame", "DifficultySelectDropDown", bossInfo, "UIDropDownMenuTemplate")
		
	difficultySelect:SetPoint("LEFT", difficultyText, "LEFT", 200, -5)
	UIDropDownMenu_Initialize(difficultySelect, function(...) VitaPlannerL.DifficultySelectDropDownInitialize(VitaPlannerL, ...) end);	
	UIDropDownMenu_SetWidth(difficultySelect, 150)
	UIDropDownMenu_SetButtonWidth(difficultySelect, 174)
	UIDropDownMenu_SetText(difficultySelect, self.diffName)	
	self.DifficultySelect = difficultySelect
	difficultySelect:Show()
	ToggleDropDownMenu(nil, nil, difficultySelect)
	
	height = height + difficultyText:GetHeight()
	
	-- Raid Boss Select
	local bossText = bossInfo:CreateFontString(nil,"OVERLAY","GameFontNormal")
	bossText:SetPoint("TOPLEFT", difficultyText, "BOTTOMLEFT", 0, -20)
	bossText:SetText("Boss")
	
	height = height + 20
	
	local bossSelect = CreateFrame("Frame", "BossSelectDropDown", bossInfo, "UIDropDownMenuTemplate")
		
	bossSelect:SetPoint("LEFT", bossText, "LEFT", 200, -5)
	UIDropDownMenu_Initialize(bossSelect, function(...) VitaPlannerL.BossSelectDropDownInitialize(VitaPlannerL, ...) end);	
	UIDropDownMenu_SetWidth(bossSelect, 150)
	UIDropDownMenu_SetButtonWidth(bossSelect, 174)
	UIDropDownMenu_SetText(bossSelect, "Select Boss")
	ToggleDropDownMenu(nil, nil, bossSelect)
	self.BossSelect = bossSelect
	
	height = height + bossText:GetHeight()
	height = height / 2
	zoneText:SetPoint("CENTER", bossInfo, "CENTER", 0, 0)
	zoneText:SetPoint("LEFT", bossInfo, "LEFT", 15, height)
	
	-- Check Raid Button
	local checkRaid = CreateFrame("Button", nil, bossInfo, "UIPanelButtonTemplate")
	checkRaid:Show()	
	checkRaid:SetText("Check Raid")
	checkRaid:SetWidth(checkRaid:GetFontString():GetWidth() + 20)
	checkRaid:SetPoint("TOPRIGHT", bossInfo, "TOPRIGHT", -10, -10)
	checkRaid:SetScript("OnClick", function()
		self:AskRaidForSelections()
	end)
	bossInfo.checkRaid = checkRaid
	checkRaid:Disable()

	-- Create our close button
	local closeBtn = CreateFrame("Button", nil, bossInfo, "UIPanelButtonTemplate")
	closeBtn:Show()	
	--closeBtn:SetHeight(20)
	closeBtn:SetText("Close")
	closeBtn:SetWidth(closeBtn:GetFontString():GetWidth() + 20)
	closeBtn:SetPoint("BOTTOMRIGHT", bossInfo, "BOTTOMRIGHT", -10, 10)
	closeBtn:SetScript("OnClick", function()
										self:Hide()
									end)
	bossInfo.closeBtn = closeBtn
	
	-- Cancel Check Button
	local cancelCheckRaid = CreateFrame("Button", nil, bossInfo, "UIPanelButtonTemplate")
	cancelCheckRaid:Hide()
	cancelCheckRaid:SetText("Reset")
	cancelCheckRaid:SetWidth(cancelCheckRaid:GetFontString():GetWidth() + 20)
	cancelCheckRaid:SetPoint("BOTTOMRIGHT", closeBtn, "TOPRIGHT", 0, 10)
	cancelCheckRaid:SetScript("OnClick", function()
		self.timeout = 0
		self.timeoutLeft = 0
		self.mainFrame.bossInfo.checkRaid:Enable()
		self.inList = {}
		self.outList = {}
		self.ignoreList = {}
		self:UpdateMaxGroupSet()
		self:UpdateRaidInfoGroups()
		self:UpdateLists()
		self.cancelCheckRaid:Hide()
	end)
	self.cancelCheckRaid = cancelCheckRaid
	
	--self.checkTimerFrame = VitaPlanner:GenerateTimerFrame()
	--self.checkTimerFrame:Hide()
	--timerFrame:Hide()	
end

function VitaPlannerL:DifficultySelectDropDownInitialize( frame, level, menuList )
	if not VitaPlannerL.DifficultySelect then return end
	
	local info = UIDropDownMenu_CreateInfo()
	
	info.text = "Raid Difficulty"
	info.disabled = true
	info.isTitle = true;
	info.notClickable = 1
	info.notCheckable = 1
	info.tooltipTitle = nil
	info.tooltipText = nil
	UIDropDownMenu_AddButton(info,UIDROPDOWNMENU_MENU_LEVEL)
	
	for i, d in ipairs(self.DIFFICULTIES) do
		info = UIDropDownMenu_CreateInfo()
		info.text = d.NAME
		info.value = d.VALUE
		info.func = function()
			self.difficulty = d.VALUE
			self.diffName = d.NAME
			UIDropDownMenu_SetSelectedID(frame, i+1)
			UIDropDownMenu_SetText(frame, d.NAME)
			--VitaPlannerL.ModifyRaidInfoLayout() =NYI=
			self:UpdateMaxGroupSet()
			self:UpdateLists()
		end		
		info.checked = function() if self.difficulty == d.VALUE then return true end end
		UIDropDownMenu_AddButton(info, level)
	end
end

function VitaPlannerL:ZoneSelectDropDownInitialize( frame, level, menuList )
	if not VitaPlannerL.ZoneSelect then return end
	
	local info = UIDropDownMenu_CreateInfo()
	
	info.text = "Raid"
	info.disabled = true
	info.isTitle = true;
	info.notClickable = 1
	info.notCheckable = 1
	info.tooltipTitle = nil
	info.tooltipText = nil
	UIDropDownMenu_AddButton(info,UIDROPDOWNMENU_MENU_LEVEL)
		
	for i,raid in ipairs(self.BOSSES) do
		info = UIDropDownMenu_CreateInfo()
		info.text = raid.NAME
		info.value = raid.ABBR
		info.func = function() 
			self.zone = raid.INSTANCEID 
			self.zoneName = raid.NAME
			self.selectedRaid = raid.ABBR
			self.selectedBossList = raid.BOSS
			UIDropDownMenu_SetSelectedID(frame, i+1)
			UIDropDownMenu_SetText(frame, raid.NAME)
		end
		info.checked = function() if self.selectedRaid == raid.ABBR then return true end end
		UIDropDownMenu_AddButton(info, level)
	end
	
end

function VitaPlannerL:BossSelectDropDownInitialize( frame, level, menuList )
	if not VitaPlannerL.BossSelect then return end
	
	local info = UIDropDownMenu_CreateInfo()
	
	info.text = "Boss"
	info.disabled = true
	info.isTitle = true;
	info.notClickable = 1
	info.notCheckable = 1
	info.tooltipTitle = nil
	info.tooltipText = nil
	UIDropDownMenu_AddButton(info,UIDROPDOWNMENU_MENU_LEVEL)
	
	if not self.selectedBossList then return end
	
	for i,boss in ipairs(self.selectedBossList) do	
		info = UIDropDownMenu_CreateInfo()
		info.text = boss.NAME
		info.value = boss.ENCOUNTERID
		info.func = function() 
			self.selectedBossID = boss.ENCOUNTERID
			self.selectedBoss = boss.NAME
			self.checkRaid:Enable()
			self.announce:Enable()
			UIDropDownMenu_SetSelectedID(frame, i+1)
			UIDropDownMenu_SetText(frame, boss.NAME)
			end
		UIDropDownMenu_AddButton(info, level)
	end
end
--]]

function VitaPlannerL:UpdateInfoPanel()
	--if not self.frame then self:InitUI() return end
	--self.mainFrame.
	local bossID = self.selectedBossID
	local diffID = self.difficulty
	local bossName = self.selectedBoss
	local zoneID = self.zone
	
	if not bossName then return end
	
	self.journalLink = "|cff66bbff|Hjournal:1:" .. bossID .. ":" .. diffID .. "|h["..bossName.."]|h|r"
	_G["VPLBossLink"].name:SetText(self.journalLink)
	
	_G["VPLBossLink"]:SetWidth(_G["VPLBossLink"].name:GetStringWidth() + 20)
	_G["VPLBossLink"]:SetScript("OnClick", function()
		--HandleModifiedItemClick( journalLink )
		if ( not EncounterJournal ) then
			EncounterJournal_LoadUI();
		end
		if EncounterJournal:IsShown() then
			EncounterJournal_ListInstances()
			EncounterJournal_DisplayInstance(zoneID)
			EncounterJournal_DisplayEncounter(bossID)
			EJ_SetDifficulty(diffID)
		else
			ToggleEncounterJournal()
			EncounterJournal_ListInstances()
			EncounterJournal_DisplayInstance(zoneID)
			EncounterJournal_DisplayEncounter(bossID)
			EJ_SetDifficulty(diffID)
		end
	end)
	
	_G["VPLNoBossSelected"]:Hide()
	self.mainFrame.infoPanel:Show()
end