-- Vita Planner
-- Base - Core
-- Version: 4.0.0
-- Author: Azulor - US:Caelestrasz
local _, VitaPlanner = ...

local MIN_CHOICES_WIDTH = 440;

VitaPlanner = LibStub("AceAddon-3.0"):NewAddon(VitaPlanner, "VitaPlanner", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceTimer-3.0")

local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")
local SharedMedia = LibStub( "LibSharedMedia-3.0" )
VitaPlanner.SharedMedia = SharedMedia

_G.VitaPlanner = VitaPlanner

local _G = _G

local realmName = gsub(gsub(GetRealmName(), ' ', ''), '-', '')

local audioPlayed = false

-- Release 14
local sVersion = "4.0.0"
local iVersion = 17

function VitaPlanner:OnInitialize()
	self.sVersion = sVersion
	self.iVersion = iVersion

	self.db = LibStub("AceDB-3.0"):New("VitaP_DB")
	--self.db = VitaPlanner.db
	
	RegisterAddonMessagePrefix("VitaPlannerC")
	RegisterAddonMessagePrefix("VPVerRequest")
	RegisterAddonMessagePrefix("VPVerResponse")
	RegisterAddonMessagePrefix("VPGInfoRequest")
	
	self:RegisterComm("VitaPlannerC",	"CommandReceived")
	
	self:RegisterEvent("PLAYER_REGEN_DISABLED",     "EnterCombat");
    self:RegisterEvent("PLAYER_REGEN_ENABLED",      "LeaveCombat");
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "ChangedTalents");
	
	self:RegisterComm("VPVerRequest",	"VersionRequest")
    self:RegisterComm("VPVerResponse",	"VersionResponse")
	self:RegisterComm("VPGInfoRequest", "GuildInfoRequest")
	
	
	
	self.bossList   = {}
	self.bossLCache = {}
	self.frame 		= nil
	
	self.my_set_group = nil
	
	self.timeout = 0
	self.timeoutLeft = 0
	
	self.RESPONSE = {
        { ["CODE"]      = "IN",   	["SORT"] =  100,  ["COLOR"] = {1,1,1},        ["TEXT"] = "In" },
        { ["CODE"]      = "OUT",    ["SORT"] =  200,  ["COLOR"] = {1,0,0},        ["TEXT"] = "Out" }
    }

    self.specs = {}
    self.specID = { [1] = "SPEC1", [2] = "SPEC2" }
    for i=1, GetNumSpecGroups() do
        local specID = GetSpecialization(false, false, i)
        local id, name, desc, icon, bg, class = GetSpecializationInfo(specID)
        self.specID[i] = id
        self.specs[i] = {
            id, name, class
        }
    end
	
	self.db:RegisterDefaults({
		profile = {					
			hideInCombat = false,
			minimap = { ["hide"] = false }
		},
		global = {
			hideInCombat = false,
			minimap = { ["hide"] = false }
		}
    })
	
	self:SetupOptions()
	
	if IsInGuild() and IsInRaid() then
		self:SendCommMessage("VPVerRequest",      iVersion .. "_" .. sVersion, "GUILD")
	end
	
	self:ScheduleTimer("SetupVariables", 5)
	
	VitaPlanner.Border = {
		["Normal"] = "Interface\\AddOns\\VitaPlanner\\Textures\\BorderWood.tga",
		["Dark"] = "Interface\\AddOns\\VitaPlanner\\Textures\\BorderWoodDark.tga"
	}
	
	VitaPlanner.SharedMedia:Register( VitaPlanner.SharedMedia.MediaType.BORDER, "Vita Wood Border", [[Interface\AddOns\VitaPlanner\Textures\BorderWood.tga]] )
	VitaPlanner.SharedMedia:Register( VitaPlanner.SharedMedia.MediaType.BORDER, "Vita Wood Dark Border", [[Interface\AddOns\VitaPlanner\Textures\BorderWoodDark.tga]] )
end

function VitaPlanner:SetupVariables()
	local guildName, guildRank, guildRankID, _ = GetGuildInfo("player")
	self.myGuildName = guildName
	self.myRank = guildRank
	self.myRankID = guildRankID
	
	local class, classFileName = UnitClass("player")
	self.myClass = class
	self.myClassFileName = classFileName

end

function VitaPlanner:OnEnable()

end

function VitaPlanner:OnDisable()
	
end

function VitaPlanner:EnterCombat()
    -- Should we hide when entering combat?
    --if not VitaPlanner.db.profile.hideSelectionOnCombat then return end;

    self.inCombat = true;
    if self.frame and self.frame:IsShown() then
        self.hiddenOnCombat = true;
		if self.db.profile.hideInCombat then
			return self.frame:Hide();
		end
        --self:Hide();
    end
end

function VitaPlanner:LeaveCombat()
    self.inCombat = nil;
    self:UpdateSelectionUI();
	if self.hasUpdate then
		self:ShowUpdateFrame(self.updateSender, self.updateIVersion, self.updateSVersion )
	end
end

function VitaPlanner:IsShown()
    if not self.frame then return false end;

    if self.inCombat and self.hiddenOnCombat then
        return true;
    end;

    return self.frame:IsShown();
end

function VitaPlanner:Show()
    if not self.frame then return false end;

	if VitaPlannerL and VitaPlannerL.IsShown then
        if not self.rplshown then
            self.rplshown = VitaPlannerL.IsShown(VitaPlannerL)
        end
        --VitaPlannerL.Hide(VitaPlannerL)
    end
	
    if self.inCombat then
        self.hiddenOnCombat = true;
		if self.db.profile.hideInCombat then
			return self.frame:Hide();
		end
    end
	
    return self.frame:Show();
end

function VitaPlanner:Hide()
    if not self.frame then return end;
	
    local ret = self.frame:Hide();
		
    if not self.inCombat and self.rplshown and VitaPlannerL and VitaPlannerL.Show then
        VitaPlannerL.Show(VitaPlannerL)
        self.rplshown = false;
    end
	
    return ret;
end

local function GetOptions()
	VitaPlanner.RPOptions = {
		name = "VitaPlanner",
		handler = VitaPlanner,
		type = 'group',
		get = function(i) return VitaPlanner.db.profile[i[#i]] end,
		set = function(i, v) VitaPlanner.db.profile[i[#i]] = v end,
		plugins = {},
		args = {
			global = {
				order = 1,
				type = "group",
				hidden = function(info) return not VitaPlanner end,
				name = "General Config",
				args = {
					hideInCombat = {
						order = 1,
						type = "toggle",
						name = "Hide In Combat",
						desc = "Enables / Disables the ability to show popups when in combat",
						set = function(info, val) VitaPlanner.db.profile.hideInCombat = val end,
						get = function(info) return VitaPlanner.db.profile.hideInCombat end
					},
					--[[showMinimapIcon = {
						order = 2,
						type = "toggle",
						name = "Show Minimap Button",
						desc = "Enables / Disables the minimap button",
						set = function(info, val) VitaPlanner.db.profile.showMinimapIcon = val end,
						get = function(info) return VitaPlanner.db.profile.showMinimapIcon end
					},]]--
					minimap = {
						type = "toggle",
						order = 3,
						name = "Show Minimap Icon",
						desc = "Turns on a minimap icon for Vita Planner. Use this if you don't have a data broker addon.",
						get = function() return not VitaPlanner.db.profile.minimap.hide end,
						set = function(info, val)
							VitaPlanner.db.profile.minimap.hide = not val
							if val == true then LDBIcon:Show("VitaPlanner") else LDBIcon:Hide("VitaPlanner") end
							--self:Update("OPTIONS")
						end,
					}, -- minimap
				},
			},			
		},
	}
	VitaPlanner.RPOptions.plugins.profiles = { profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(VitaPlanner.db) }
	
	return VitaPlanner.RPOptions
end


function VitaPlanner:Command(input)
    local _,_,command, args = string.find( input, "^(%a-) (.*)$" )
    command = command or input
	--print(input)
    -- HFC Zakuun Maps Display
	if command == "play" then
        local soundID = strtrim(args or '');
        if not args or not soundID or soundID=='' then
            print("|cff00ffff[VitaPlanner]|r : Usage: /vp play [soundID]")
            print("|cff00ffff[VitaPlanner]|r : Only enabled for Raid Leaders or Assistants")
        else
            if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
                local sentCommand = "PLAY_SOUND"
                if IsInRaid() then
                    self:SendCommMessage("VitaPlannerC", format("%s:%s", tostring(sentCommand), tostring(soundID)), "RAID", nil, "ALERT")
                else
                    self:CommandReceived("VitaPlannerC", format("%s:%s", tostring(sentCommand), tostring(soundID)), 'WHISPER', UnitName("player"))
                end
            end
        end
    elseif command == "gplay" then
        local soundID = strtrim(args or '');
        if not args or not soundID or soundID=='' then
            print("|cff00ffff[VitaPlanner]|r : Usage: /vp play [soundID]")
            print("|cff00ffff[VitaPlanner]|r : Only enabled for Raid Leaders or Assistants")
        else
            --if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
            if (self.myRankID <= 1 and IsInGuild()) then
                local sentCommand = "PLAY_SOUND"
            --    if IsInRaid() then
                    self:SendCommMessage("VitaPlannerC", format("%s:%s", tostring(sentCommand), tostring(soundID)), "GUILD", nil, "ALERT")
            --    else
            --        self:CommandReceived("VitaPlannerC", format("%s:%s", tostring(sentCommand), tostring(soundID)), 'WHISPER', UnitName("player"))
            --    end
            end
        end
    elseif command == "combat" then
		self.db.profile.hideInCombat = not self.db.profile.hideInCombat
		if self.db.profile.hideInCombat == true then
			print("|cff00ffff[VitaPlanner]|r : Panels are set to |cffff0000not show|r in combat")
		else
			print("|cff00ffff[VitaPlanner]|r : Panels are set to |cff00ff00show|r in combat")
		end
	else
		LibStub("AceConfigDialog-3.0"):Open("VitaPlanner")
	end
end

--[[function RaidPlannner:RegisterOptions(key, table)
	if not self.RPOptions then
		error("Options table has not been created yet, respond to the callback!", 2)
	end
	self.RPOptions.plugins[key] = { [key] = table }
end--]]

function VitaPlanner:SetupOptions()
	LibStub("AceConfig-3.0"):RegisterOptionsTable("VitaPlanner", GetOptions)
	AceConfigDialog:SetDefaultSize("VitaPlanner", 500,400)
	VitaPlanner:RegisterChatCommand("vp", "Command")
	
	if LDB then
		local VPLauncher = LDB:NewDataObject("VitaPlanner", {
			type = "launcher",
			--icon = "Interface\\Icons\\Achievement_Reputation_08",
			icon = "Interface\\Addons\\VitaPlanner\\Textures\\VitaLogo2.tga",
			OnClick = function(f, btn)
				if btn == "RightButton" then
					if IsShiftKeyDown() then
						if VitaPlannerL then
							LibStub("AceConfigDialog-3.0"):Open("VitaPlannerL") 
						end					
					else
						LibStub("AceConfigDialog-3.0"):Open("VitaPlanner") 
					end
				end
				if btn == "LeftButton" then
					if IsShiftKeyDown() then
						if VitaPlannerL then
							if not IsInRaid() or IsInRaid() and (UnitIsGroupAssistant("player") or UnitIsGroupLeader("player")) then
								VitaPlannerL:Command("")
							end
						end
					else
						self:Command("combat")
					end
				end
				if btn == "MiddleButton" then self:Command("zakuun") end
			end,
			OnTooltipShow = function(tt)
				tt:AddLine("|cff00ffffVita Planner|r")
				tt:AddLine("|cff00ff00<Left Click>|r to toggle in-combat popups")	
				if VitaPlannerL then
					tt:AddLine("|cff00ff00<[Shift] Left Click>|r to open the Planner Panel")
				end
				tt:AddLine("|cff00ff00<Right Click>|r to open the options menu")	
				if VitaPlannerL then
					tt:AddLine("|cff00ff00<[Shift] Right Click>|r to open the planner options menu")
                end
                tt:AddLine("|cff00ff00<Middle Mouse Click>|r to open the Zakuun fissure diagrams")
			end,
		})
		if LDBIcon then
			LDBIcon:Register("VitaPlanner", VPLauncher, self.db.profile.minimap)--, VitaPlanner.db)
		end
	end
end

function VitaPlanner:VersionRequest(prefix, message, distribution, sender)
	local _,_,senderVersion, senderVersionString = string.find(message, "^(%d+)_(.*)$")
	senderVersion = tonumber(senderVersion) or 0
	sender = VitaPlanner.UnAmbiguate(sender)
	
	if (senderVersion<iVersion) then
		-- Senders version has been outdated
		self:SendCommMessage("VPVerResponse", iVersion .. "_" .. sVersion, "WHISPER", sender)
	end
	if (senderVersion>iVersion) then
		-- Our version is outdated
        self:ShowUpdateFrame( sender, iVersion, senderVersionString )
	end
end

function VitaPlanner:VersionResponse(prefix, message, distribution, sender)
	local _,_,senderVersion, senderVersionString = string.find(message, "^(%d+)_(.*)$")
	senderVersion = tonumber(senderVersion) or 0
	sender = VitaPlanner.UnAmbiguate(sender)
	--print(sender .. ": " .. senderVersion .. " - " .. iVersion)
	--[[if (senderVersion<iVersion) then
		-- Senders version has been outdated
		self:SendCommMessage("VPVerResponse", iVersion .. "_" .. sVersion, "WHISPER", sender)
	end--]]
	if (senderVersion>iVersion) then
		-- Our version is outdated
        self:ShowUpdateFrame( sender, iVersion, senderVersionString )
	end
end

function VitaPlanner:GuildInfoRequest(prefix, message, distribution, sender)	
	sender = VitaPlanner.UnAmbiguate(sender)
    --print(sender)

	local guildName, guildRank, guildRankID, _ = GetGuildInfo("player")
	--[[self.myGuildName, 
			self.myRank, --]]
	if (message == "GUILD_INFO") then
        for i=1, GetNumSpecGroups() do
            local specID = GetSpecialization(false, false, i)
            local id, name, desc, icon, bg, class = GetSpecializationInfo(specID)
            self.specID[i] = id
            self.specs[i] = {
                id, name, class
            }
        end

		local info = format("%s^%s^%s^%d^%d^%d^%s^%s",			
			guildName, 
			guildRank, 
			self.myClass,			
			self.specID[1] or 0, 
			self.specID[2] or 0,
			GetActiveSpecGroup() or 0,
			self.myClassFileName or "",
			sVersion or "")
		
		self:SendCommMessage("VPLGInfoResponse", format("%s:%s", "GUILD_INFO_RES", info), "WHISPER", sender)
	end
end

function VitaPlanner:ChangedTalents(event, index)
	if IsInRaid() then
		self:SendCommMessage("VitaPlannerL", format("%s:%s", "TALENTS_CHANGED", index), "RAID")
	end
end

function VitaPlanner:ShowUpdateFrame( sender, iVersion, sVersion )	
	self.updateSender = sender
	self.updateSVersion = sVersion
	self.updateIVersion = iVersion
    if self.hasUpdate == false and self.iLastVersionResponse and self.iLastVersionResponse>=iVersion then
        -- Only show the update message once, unless there is a newer version found.
        return;
    end;
	self.hasUpdate = false
    self.iLastVersionResponse = iVersion;
	if self.inCombat then
		self.hasUpdate = true
	else
		print ( "|cff00ffff[Vita Planner]|r "..
				string.format("Auto notice from %s.", sender))
		print ( "|cff00ffff[Vita Planner]|r Please update the addon at Curse.com." )
	end	
end

function VitaPlanner:Debug( message, verbose )
    if not self.debug then return end;
    if verbose and not self.verbose then return end;
    self:Print("debug: " .. message)
end

function VitaPlanner:SendLeaderCommand(command, message, target)
	if not target then
		return self:Print(L["Could not send command, no target specified"])
	end
	
	local formatted = format("%s:%s", tostring(command), tostring(message));
    local broadcasted = false
	
	if IsInRaid() and (VitaPlanner.UnitInRaid(target) or target == "RAID") then
        self:SendCommMessage("VitaPlannerL", formatted, "RAID", nil, "ALERT")
        self:Debug('SendCommand(RAID): '..formatted, true)
		broadcasted = true
	elseif VitaPlanner.UnitInParty(target) and GetNumSubgroupMembers()>0 then
        self:SendCommMessage("VitaPlannerL", formatted, "PARTY", nil, "ALERT")
        self:Debug('SendCommand(PARTY): '..formatted, true)
        broadcasted = true;
    elseif not IsInRaid() and target == "RAID" then
		self:SendCommMessage("VitaPlannerL", formatted, "WHISPER", UnitName("player"), "ALERT")
        self:Debug('SendCommand(WHISPER->'..UnitName("player")..'): '..formatted, true)
	else
		target = VitaPlanner.Ambiguate(target, "none")
        self:SendCommMessage("VitaPlannerL", formatted, "WHISPER", target, "ALERT")
        self:Debug('SendCommand(WHISPER->'..target..'): '..formatted, true)
    end
end

function VitaPlanner:UpdateSelectionUI()
	local hasSelections = false
    local totalSelections = 0
    local soundID = 26852

    --if self.inCombat then
    --    self.hiddenOnCombat = true
     --   self:Hide()
    --    return true;
    --end

    if not self.frame then
        self:InitUI()
    end;

    totalSelections = #self.bossList;
    hasSelections = totalSelections>0

    for i, data in ipairs(self.bossList) do repeat
        -- If the item is empty try the next item.
        if not data then break end

        local selectionFrame = self.selectionFrame
        if not selectionFrame then			
			selectionFrame = self:CreateBossSelectionFrame()
			self.selectionFrame = selectionFrame
		end
		
		local reasonFrame = self.reasonFrame
		if not reasonFrame then
			reasonFrame = self:GenerateReasonFrame()
			self.reasonFrame = reasonFrame
		end
        --end

        selectionFrame.data = data;

		local journalLink = "|cff66bbff|Hjournal:1:" .. data.bossID .. ":" .. data.diffID .. "|h["..data.bossName.."]|h|r"        
		
		selectionFrame.lblDiff:SetText(format('%s',data.diffName))
		local diffLabel = selectionFrame.lblDiff
		
		selectionFrame.bossName:SetText(format('%s',journalLink))
		selectionFrame.bossName:SetWidth(selectionFrame.bossName:GetFontString():GetStringWidth() + 20)
		selectionFrame.bossName:SetScript("OnClick", function()
				--HandleModifiedItemClick( journalLink )
				if ( not EncounterJournal ) then
					EncounterJournal_LoadUI();
				end
				if EncounterJournal:IsShown() then
					EncounterJournal_ListInstances()
					EncounterJournal_DisplayInstance(data.raidID)
					EncounterJournal_DisplayEncounter(data.bossID)
					EJ_SetDifficulty(data.diffID)
				else
					ToggleEncounterJournal()
					EncounterJournal_ListInstances()
					EncounterJournal_DisplayInstance(data.raidID)
					EncounterJournal_DisplayEncounter(data.bossID)
					EJ_SetDifficulty(data.diffID)
				end
		end)

        -- Create a starting anchor for the buttons
        local lastButton = nil
		local totalButtonWidth = 0

		-- Create / Display the buttons
        for i=1, data.numButtons do
			local buttonData = data.buttons[i]
			local button = selectionFrame.buttons[i]

			if not button then
				-- Create the button
				button = CreateFrame("Button", nil, selectionFrame, "UIPanelButtonTemplate")
				button:SetScript("OnClick", function(btn)
					if buttonData.reason == 'true' then						
						self.reasonFrame.send:SetScript("OnClick", function(btn)
							self:SendBossSelection("RAID", selectionFrame.data.bossName, buttonData.response, self.reasonFrame.editbox:GetText())
							--print("Removing "..selectionFrame.data.bossName)
							self:RemoveSelection(selectionFrame.data.bossName)
							self:UpdateSelectionUI()
							self.reasonFrame.editbox:SetText("");
							self.reasonFrame:Hide()
						end)
						self.reasonFrame:Show()
					else
						--print("Clicked "..buttonData.text)
						--print("Sending to "..selectionFrame.data.leader..": "..selectionFrame.data.bossName.." - "..buttonData.text)
						--self:SendBossSelection(selectionFrame.data.leader, selectionFrame.data.bossName, buttonData.response)
						self:SendBossSelection("RAID", selectionFrame.data.bossName, buttonData.response, nil)
						--print("Removing "..selectionFrame.data.bossName)
						self:RemoveSelection(selectionFrame.data.bossName)
						self:UpdateSelectionUI()
					end
				end)
				button:SetHeight(25)
				selectionFrame.buttons[i] = button
			end

			button:Show()
			button.response = buttonData.response
			button:ClearAllPoints()			
			if not lastButton then
				button:SetPoint("BOTTOMLEFT", selectionFrame, "BOTTOMLEFT", 10, 10)
			else
				button:SetPoint("BOTTOMLEFT", lastButton, "BOTTOMRIGHT", 10, 0)
			end

			button:SetText(buttonData.text)
			local width = button:GetFontString():GetStringWidth()
			width = width + width/20 + 30
			button:SetWidth(width)
			totalButtonWidth = totalButtonWidth + width + 5
			
			lastButton = button
        end
		
		if totalButtonWidth > MIN_CHOICES_WIDTH then
			self.frame:SetWidth(totalButtonWidth + 80)
		end
        -- Position the pass button
        --selectionFrame.btnPass:ClearAllPoints()
        --selectionFrame.btnPass:SetPoint("BOTTOMLEFT", lastButton, "BOTTOMRIGHT", 10, 0)

        -- Hide unused buttons
        for i=data.numButtons + 1, #(selectionFrame.buttons) do
			local button = selectionFrame.buttons[i]
			button:Hide()
        end
        
        selectionFrame.planner:SetText(format("%s", data.leader or "Unknown"))
		selectionFrame.planner:SetPoint("TOPLEFT",diffLabel,"BOTTOMLEFT",0,-10)
		
		if self.timeoutLeft and self.timeoutLeft <= 0 then
			self.timeout = data.timeout
			self.timeoutLeft = data.timeoutLeft
			if data.timeout and data.timeout>0 then
				self.checkTimerFrame.progressBar:SetMinMaxValues(0,self.timeout)
				self.checkTimerFrame.progressBar:SetValue(self.timeoutLeft)
				self.checkTimerFrame.lblTimeout:SetText('')
				self.checkTimerFrame:Show()
			else
				self.checkTimerFrame:Hide()
			end
		end
        
		if not self.notificationFrame then
			self.notificationFrame = self:CreateNotificationFrame()
		end
		self.notificationFrame:Hide()
		selectionFrame:Show()

        soundID = tonumber(data.soundID) or 43521

    until true end

    if hasSelections then
        self:Show()
        if (not audioPlayed) then --and VitaPlanner.db.profile.audioWarningOnSelection then
            --PlaySoundFile("Sound\\Creature\\BabyMurloc\\BabyMurlocA.wav")
            --print (soundID)
			PlaySound(tonumber(soundID))
            audioPlayed = true
        end
    else
        audioPlayed = false
        self:Hide();
    end

end

function VitaPlanner:NotifySetGroup()
	if not self.frame then
        self:InitUI()
    end;
	
	local notificationFrame = self.notificationFrame
	if not notificationFrame then
		notificationFrame = self:CreateNotificationFrame()
		self.notificationFrame = notificationFrame
	end
	
	notificationFrame.bossName:SetText(self.set_boss_name)
	
	local isIn = nil
	if tonumber(self.my_set_group) <= tonumber(self.max_set_group) then
		isIn = true
		notificationFrame.setMessage:SetText("YOU ARE IN 1-"..self.max_set_group)
		notificationFrame:SetBackdropColor(0,0.5,0,0.6)
	else
		notificationFrame.setMessage:SetText("YOU ARE OUT")
		notificationFrame:SetBackdropColor(0.5,0,0,0.6)
	end
	
	if self.selectionFrame then
		self.selectionFrame:Hide()
	end
	notificationFrame:Show()
	self:Show()
	
	if isIn then
		PlaySoundFile("Sound\\Interface\\iquestcomplete.ogg")
	else
		PlaySoundFile("Sound\\Interface\\igquestfailed.ogg")
	end
end

function VitaPlanner:RemoveSelection( bossName )
    local index = self:HasBossMessage(bossName)
    if not index then return false end
    tremove(self.bossList, index)
    return true
end

function VitaPlanner:CommandReceived(prefix, message, distribution, sender)
	local _,_,command, message = string.find(message, "^([%a_]-):(.*)$")
	command = strupper(command or '');
	message = message or '';

	sender = VitaPlanner.UnAmbiguate(sender)
	
	if command == "CHECK_BOSS" then
		self.my_set_group = nil
		-- Split message into individual variables
        --print (message)
		local raidID, bossName, bossID, diffName, diffID, numButtons, buttons, timeout, soundID = strsplit("^", message)
		
		-- Get buttons and number of buttons from message
		numButtons = tonumber(numButtons or 0)
		local buttonsOK = false
		if numButtons >= 1 and buttons and buttons~='' then
			buttons = {strsplit("*", buttons)}
			if #buttons == numButtons then
				for i=1,numButtons do
					local bResponse, bText, bColour, bReason = strsplit(';', buttons[i])
					buttons[i] = {
						response                = bResponse or 'NONE',
						text                    = bText or '[empty]',
						colour                   = bColour or 'ffffff',
						reason					= bReason or 'false'
					}
				end
				buttonsOK = true
			end
		end	

		if not buttonsOK then
			-- Create the default buttons
			numButtons = 3
			buttons = {
				{response = "IN",           text = "In",		colour = 'ffffff', reason = 'false'},
				{response = "OUT",          text = "Out",		colour = 'ffffff', reason = 'false'},
				{response = "NEUTRAL",		text = "Neutral", 	colour = 'ffffff', reason = 'false'}
			}
		end	
		
		if not self:HasBossMessage(bossName) then
			-- add the loot to the bosslist and redraw the ui
			tinsert( self.bossList, {
				["leader"]      	= sender,
				["raidID"]			= raidID,
				["bossName"]        = bossName,
				["bossID"]			= bossID,
				["diffName"]   		= diffName,
				["diffID"]			= diffID,
				["timeout"]         = tonumber(timeout),
				["timeoutLeft"]     = tonumber(timeout),
				["buttons"]         = buttons,
				["numButtons"]      = numButtons,
                ["soundID"]         = soundID
			})

			self:UpdateSelectionUI();
		end		
	elseif command == "SET_GROUPS" then
		local setBoss, maxInGroup, raidersList = strsplit("^",message)
		local raiderList = { strsplit("*",raidersList) }
		for index,raider in ipairs(raiderList) do
			local name, group = strsplit(";", raider)
			if VitaPlanner.UnAmbiguate(name) == VitaPlanner.UnAmbiguate(UnitName("player")) then
				self.my_set_group = group
				self.set_boss_name = setBoss
				self.max_set_group = maxInGroup
				self:NotifySetGroup()
			end
        end
    elseif command == "PLAY_SOUND" then
        local soundID = tonumber(message)
        --if UnitIsGroupLeader(sender) or UnitIsGroupAssistant(sender) then
            PlaySound(soundID)
        --end
	elseif command == "CLOSE_FRAME" then
		self:Hide()
	end		
end

function VitaPlanner:HasBossMessage( bossName )
    for i, data in ipairs(self.bossList) do repeat
        if not data then break end
        if data.bossName == bossName then
            return i
        end
    until true end
    return nil
end

function VitaPlanner:SendBossSelection( target, bossID, response, text )
    -- Just whisper the response back to the leader.
	--if not response then
	--	response = '0'
	--end
	--print(target .. " - " .. bossID .. " - " .. response)
	if response == "" then
		response = "NONE"
	end
	if text then
		response = format("%s|%s", response, text)
	end
	--print (format("%s^%s", bossID or 0, response))
    self:SendLeaderCommand("SELECTION", format("%s^%s", bossID or 0, response), target)
end


-- Ambiguate and Unit in X functions copied from EPGP Lootmaster
function VitaPlanner.UnAmbiguate(name)
	-- Don't postfix these default values
	if name == '' or name == nil or name == 'RAID' or name == 'PARTY' or name == 'BATTLEGROUND' or name == 'GUILD' then
		return name
	end

	-- Let the wow client try to add the realmname
	-- This function is really buggy by the way... If realm name has space in it,
	-- it expects you to deliver it to this function without the spaces. /facepalm
	-- So Mackatack-Lightning's Hammer just returns the same, Mackatack-Lightning'sHammer
	-- does only return Mackatack, as is expected. The quote is preserved, just the space is
	-- removed.
	-- Other functions, such as SendAddonMessage and SendChatMessage do work with the space removed
	-- or with the spaces intact. UnitIsUnit etc still only work without the server names. Now quite
	-- Sure how to properly use these functions cross-realm
	local res = VitaPlanner.Ambiguate(name, "none")

	-- No realmname on the playerName? add it
	if strfind(res, "-", nil, true) == nil then
		-- add the realmname to the player name
		res = res .. "-" .. realmName
	end

	return res
end

-- Just a local cache of the Ambiguate function
-- This function currently is broken if there are spaces in the
-- player/realmName. It's easily detected when the blizz devs have fixed this
-- So leave a message to the player when they have so they can report back
local ambiguateSpacesBroken = true
if strfind(GetRealmName(), ' ', nil, true) ~= nil then
	-- We're on a server with a space in the realmName, see if blizzard has fixed the error
	if Ambiguate(UnitName("player").."-"..GetRealmName(), "none") == UnitName("player") then
		VitaPlanner:Print("NOTICE! Ambiguate spaces error has been fixed by Blizzard, please report back to VitaPlanner developer!")
		-- Auto unpatch
		ambiguateSpacesBroken = false
		realmName = GetRealmName()
		-- Else, still broken
	end
end

function VitaPlanner.Ambiguate(name, aType, ...)
	-- It seems this function totally bugs out when there are spaces in the player name
	-- So, remove the spaces
	-- Edit: it's even more broken, it doesn't work when the realmName has spaces AND dashes, () or any other UTF char works,
	-- just not spaces and dashes...
	if ambiguateSpacesBroken and name ~= nil and strfind(name, "-", nil, true) ~= nil then
		-- first, just remove the spaces
		-- Then split at the first dash, remove any dashes from the
		-- realmName and concat back together, afterwards, feed this into Ambiguate.
		-- Sweet... bunch of awesome developers they have at Blizz </sarcasm>
		name = gsub(name, ' ', '')
		local n, s = strsplit('-', name, 2)
		name = n .. '-' .. gsub(s, '-', '')
	end
	return Ambiguate(name, aType, ...)
end

-- Don't trust blizzard functions to remove the realmname, just split on dash and return the first value
function VitaPlanner.StripServerName(name)
	local n, s = strsplit('-', name, 2)
	return n
end

function VitaPlanner.UnitInRaid(unit)
	-- Dont do anything special if there's no - in the unit name
	if strfind(unit, "-", nil, true) ~= nil then
		unit = VitaPlanner.Ambiguate(unit, "none")
	end
	return UnitInRaid(unit)
end

-- These built-in wow functions dont work properly with UnAmbiguated names...
function VitaPlanner.UnitInParty(unit)
	-- Dont do anything special if there's no - in the unit name
	if strfind(unit, "-", nil, true) ~= nil then
		unit = VitaPlanner.Ambiguate(unit, "none")
	end
	return UnitInParty(unit)
end

-- These built-in wow functions dont work properly with UnAmbiguated names...
-- for example UnitIsUnit("Bushmaster", "player") return true, UnitIsUnit("Bushmaster-Darksorrow", "player") returns false...
function VitaPlanner.UnitIsUnit(unit1, unit2)
	-- Dont do anything special if there's no - in the unit name
	if strfind(unit1, "-", nil, true) ~= nil then
		unit1 = VitaPlanner.Ambiguate(unit1, "none")
	end
	if strfind(unit2, "-", nil, true) ~= nil then
		unit2 = VitaPlanner.Ambiguate(unit2, "none")
	end
	return UnitIsUnit(unit1, unit2)
end

-- UnitName receives a 2nd return value containing the realm name
function VitaPlanner.UnitName(unit)
	local name, realm = UnitName(unit)
	if name == nil then
		return nil, nil
	end
	if realm ~= nil then
		return name .. "-" .. realm
	end
	return name .. '-' .. realmName
end