-- Vita Planner
-- Leader - Core
-- Version: 4.0.0
-- Author: Azulorr - US:Caelestrasz
local _, VitaPlannerL = ...

local MSG_Prefix    		= '[Vita Planner] '

VitaPlannerL 		= LibStub("AceAddon-3.0"):NewAddon(VitaPlannerL, "VitaPlannerL", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceTimer-3.0")
local VitaPlanner 	= LibStub("AceAddon-3.0"):GetAddon("VitaPlanner")

local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")
--local LGIST = LibStub("LibGroupInSpecT-1.1")

_G.VitaPlannerL = VitaPlannerL

local _G = _G

local realmName = gsub(gsub(GetRealmName(), ' ', ''), '-', '')

local lastMsgID = nil
local lastMsgFiltered = false

local chatCommands = {
    --'^%s*![iI][nN]%s+(%a+)%s*(.*)',
    '^%s*#([iI][nN])%s*(.*)',
    '^%s*#([oO][uU][tT])%s*(.*)',
    '^%s*#([cC][aA][nN][cC][eE][lL])%s*(.*)',
	'^%s*#([nN][eE][uU][tT][rR][aA][lL])%s*(.*)',
	'^%s*([%[%]]Vita(%s?)Planner[%[%]])%s*(.*)'
}
local numChatCommands = #chatCommands

local maxSetNum = 6

local defaultSoundKitID = 43521

function VitaPlannerL:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("VitaPL_DB")
	self.Raiders = {}
	
	RegisterAddonMessagePrefix("VitaPlannerL")
	RegisterAddonMessagePrefix("VPLGInfoResponse")
	
	self:RegisterComm("VitaPlannerL",	"CommandReceived")
    self:RegisterComm("VPLGInfoResponse",	"GuildInfoResponse")
	
	self:RegisterEvent("PLAYER_REGEN_DISABLED",     "EnterCombat");
    self:RegisterEvent("PLAYER_REGEN_ENABLED",      "LeaveCombat");
	
	self:RegisterEvent("GROUP_ROSTER_UPDATE",			"RAID_GROUP_UPDATE");
	--self:RegisterEvent("RAID_ROSTER_UPDATE",            "RAID_GROUP_UPDATE");
    --self:RegisterEvent("PARTY_LOOT_METHOD_CHANGED",     "RAID_GROUP_UPDATE");
    --self:RegisterEvent("PARTY_MEMBERS_CHANGED",         "RAID_GROUP_UPDATE");
    --self:RegisterEvent("PLAYER_ENTERING_WORLD",         "RAID_GROUP_UPDATE");
	
	--LGIST.RegisterCallback(VitaPlannerL, "GroupInSpecT_Update", "InspectUpdateHandler")
	--LGIST.RegisterCallback(VitaPlannerL, "GroupInSpecT_Remove", "InspectRemoveHandler")
	
	--self:SetupOptions()
	
	self.RESPONSE = {
        { ["CODE"]	= "IN",   		["SORT"] =  100,  	["COLOR"] = "00FF00",	["TEXT"] = "In", 		["REASON"] = false	},
        { ["CODE"]  = "OUT",    	["SORT"] =  200,  	["COLOR"] = "FF0000",	["TEXT"] = "Out", 		["REASON"] = true	},
		{ ["CODE"]	= "NEUTRAL",	["SORT"] =	300,	["COLOR"] = "FFFF00",	["TEXT"] = "Neutral", 	["REASON"] = false	},	
	}
	self.RESPONSES = {}
	for i,r in ipairs(self.RESPONSE) do
		self.RESPONSES[r.CODE] = {
			["SORT"] = r.SORT,
			["COLOR"] = r.COLOR,
			["TEXT"] = r.TEXT,
			["REASON"] = r.REASON
		}
	end

	--[[
	946 Antorus, the Burning Throne
	Garothi Worldbreaker 1992
	Felhounds of Sargeras 1987
	Antoran High Command 1997
	Portal Keeper Hasabel 1985
	Eonar the Life-Binder 2025
	Imonar the Soulhunter 2009
	Kin'garoth 2004
	Varimathras 1983
	The Covern of Shivarra 1986
	Aggramar 1984
	Argus the Unmaker 2031
	]]--
	
	self.BOSSES = {
		{	["INSTANCEID"] = 946, ["ABBR"] = "ABT", ["NAME"] = "Antorus, the Burning Throne", ["TIER"] = "T21",
			["BOSS"] = {
				{	["ENCOUNTERID"] =	1992,	["NAME"] = "Garothi Worldbreaker"						},
				{	["ENCOUNTERID"] =	1987,	["NAME"] = "Felhounds of Sargeras"					},
				{	["ENCOUNTERID"] =	1997,	["NAME"] = "Antoran High Command"			},
				{	["ENCOUNTERID"] =	1985,	["NAME"] = "Portal Keeper Hasabel"		},
				{	["ENCOUNTERID"] =	2025,	["NAME"] = "Eonar the Life-Binder"		},
				{	["ENCOUNTERID"] =	2009,	["NAME"] = "Imonar the Soulhunter"			},
				{	["ENCOUNTERID"] =	2004,	["NAME"] = "Kin'garoth"			},
				{	["ENCOUNTERID"] =	1983,	["NAME"] = "Varimathras"		},
				{	["ENCOUNTERID"] =	1986,	["NAME"] = "The Covern of Shivarra"			},
				{	["ENCOUNTERID"] =	1984,	["NAME"] = "Aggramar"			},
				{	["ENCOUNTERID"] =	2031,	["NAME"] = "Argus the Unmaker"			}
			}
		}
		--[[,
		{	["INSTANCEID"] = 786, ["ABBR"] = "TNH", ["NAME"] = "The Nighthold", ["TIER"] = "T19",
			["BOSS"] = {
				{	["ENCOUNTERID"] =	1706,	["NAME"] = "Skorpyron"						},
				{	["ENCOUNTERID"] =	1725,	["NAME"] = "Chronomatic Anomaly"					},
				{	["ENCOUNTERID"] =	1731,	["NAME"] = "Trilliax"			},
				{	["ENCOUNTERID"] =	1751,	["NAME"] = "Spellblade Aluriel"		},
				{	["ENCOUNTERID"] =	1762,	["NAME"] = "Tichondrius"		},
				{	["ENCOUNTERID"] =	1713,	["NAME"] = "Krosus"			},
				{	["ENCOUNTERID"] =	1761,	["NAME"] = "High Botanist Tel'arn"			},
				{	["ENCOUNTERID"] =	1732,	["NAME"] = "Star Augur Etraeus"		},
				{	["ENCOUNTERID"] =	1743,	["NAME"] = "Grand Magistrix Elisandre"			},
				{	["ENCOUNTERID"] =	1737,	["NAME"] = "Gul'dan"			}
			}
		},
		{	["INSTANCEID"] = 768, ["ABBR"] = "TEN", ["NAME"] = "The Emerald Nightmare", ["TIER"] = "T19",
			["BOSS"] = {
				{	["ENCOUNTERID"] =	1703,	["NAME"] = "Nythendra"						},
				{	["ENCOUNTERID"] =	1738,	["NAME"] = "Il'gynoth, Heart of Corruption"					},
				{	["ENCOUNTERID"] =	1744,	["NAME"] = "Elerethe Renferal"			},
				{	["ENCOUNTERID"] =	1667,	["NAME"] = "Ursoc"		},
				{	["ENCOUNTERID"] =	1704,	["NAME"] = "Dragons of Nightmare"		},
				{	["ENCOUNTERID"] =	1750,	["NAME"] = "Cenarius"			},
				{	["ENCOUNTERID"] =	1726,	["NAME"] = "Xavius"			}
			}
		},		
		{	["INSTANCEID"] = 669, ["ABBR"] = "HFC", ["NAME"] = "Hellfire Citadel", ["TIER"] = "T18",
			["BOSS"] = {
				{	["ENCOUNTERID"] =	1426,	["NAME"] = "Hellfire Assault"						},
				{	["ENCOUNTERID"] =	1425,	["NAME"] = "Iron Reaver"					},
				{	["ENCOUNTERID"] =	1392,	["NAME"] = "Kormrok"			},
				{	["ENCOUNTERID"] =	1432,	["NAME"] = "Hellfire High Council"		},
				{	["ENCOUNTERID"] =	1396,	["NAME"] = "Kilrogg Deadeye"		},
				{	["ENCOUNTERID"] =	1372,	["NAME"] = "Gorefiend"			},
				{	["ENCOUNTERID"] =	1433,	["NAME"] = "Shadow-Lord Iskar"			},
				{	["ENCOUNTERID"] =	1427,	["NAME"] = "Socrethar the Eternal"						},
				{	["ENCOUNTERID"] =	1391,	["NAME"] = "Fel Lord Zakuun"			},
				{	["ENCOUNTERID"] =	1447,	["NAME"] = "Xhul'horac"					},
				{	["ENCOUNTERID"] =	1394,	["NAME"] = "Tyrant Velhari"					},
				{	["ENCOUNTERID"] =	1395,	["NAME"] = "Mannoroth"					},
				{	["ENCOUNTERID"] =	1438,	["NAME"] = "Archimonde"					},
			}
		},
		{	["INSTANCEID"] = 457, ["ABBR"] = "BRF", ["NAME"] = "Blackrock Foundry", ["TIER"] = "T17",
			["BOSS"] = {
				{	["ENCOUNTERID"] =	1161,	["NAME"] = "Gruul"						},
				{	["ENCOUNTERID"] =	1202,	["NAME"] = "Oregorger"					},
				{	["ENCOUNTERID"] =	1122,	["NAME"] = "Beastlord Darmac"			},
				{	["ENCOUNTERID"] =	1123,	["NAME"] = "Flamebender Ka'graz"		},
				{	["ENCOUNTERID"] =	1155,	["NAME"] = "Hans'gar and Franzok"		},
				{	["ENCOUNTERID"] =	1147,	["NAME"] = "Operator Thogar"			},
				{	["ENCOUNTERID"] =	1154,	["NAME"] = "The Blast Furnace"			},
				{	["ENCOUNTERID"] =	1162,	["NAME"] = "Kromog"						},
				{	["ENCOUNTERID"] =	1203,	["NAME"] = "The Iron Maidens"			},
				{	["ENCOUNTERID"] =	959,	["NAME"] = "Blackhand"					},
			}
		},
		{	["INSTANCEID"] = 477, ["ABBR"] = "HM", ["NAME"] = "Highmaul", ["TIER"] = "T17",
			["BOSS"] = {
				{	["ENCOUNTERID"] =	1128,	["NAME"] = "Kargath Bladefist"			},
				{	["ENCOUNTERID"] =	971,	["NAME"] = "The Butcher"				},
				{	["ENCOUNTERID"] =	1195,	["NAME"] = "Tectus"						},
				{	["ENCOUNTERID"] =	1196,	["NAME"] = "Brackenspore"				},
				{	["ENCOUNTERID"] =	1148,	["NAME"] = "Twin Ogron"					},
				{	["ENCOUNTERID"] =	1153,	["NAME"] = "Ko'ragh"					},
				{	["ENCOUNTERID"] =	1197,	["NAME"] = "Imperator Mar'gok"			}
			}
		}
		--]]
		--[[{	["INSTANCEID"] = 369, ["ABBR"] = "SoO", ["NAME"] = "Siege of Orgrimmar", ["TIER"] = "T16",
			["BOSS"] = {
				{	["ENCOUNTERID"] =	852,	["NAME"] = "Immerseus"					},
				{	["ENCOUNTERID"] =	849,	["NAME"] = "The Fallen Protectors"		},
				{	["ENCOUNTERID"] =	866,	["NAME"] = "Norushen"					},
				{	["ENCOUNTERID"] =	867,	["NAME"] = "Sha of Pride"				},
				{	["ENCOUNTERID"] =	868,	["NAME"] = "Galakras"					},
				{	["ENCOUNTERID"] =	864,	["NAME"] = "Iron Juggernaut"			},
				{	["ENCOUNTERID"] =	856,	["NAME"] = "Kor'kron Dark Shaman"		},
				{	["ENCOUNTERID"] =	850,	["NAME"] = "General Nazgrim"			},
				{	["ENCOUNTERID"] =	846,	["NAME"] = "Malkorok"					},
				{	["ENCOUNTERID"] =	870,	["NAME"] = "Spoils of Pandaria"			},
				{	["ENCOUNTERID"] =	851,	["NAME"] = "Thok the Bloodthirsty"		},
				{	["ENCOUNTERID"] =	865,	["NAME"] = "Siegecrafter Blackfuse"		},
				{	["ENCOUNTERID"] =	853,	["NAME"] = "Paragons of the Klaxxi"		},
				{	["ENCOUNTERID"] =	869,	["NAME"] = "Garrosh Hellscream"			}
			}
		},
		{	["INSTANCEID"] = 362, ["ABBR"] = "ToT", ["NAME"] = "Throne of Thunder", ["TIER"] = "T15",
			["BOSS"] = {
				{	["ENCOUNTERID"] =	827,	["NAME"] = "Jin'rokh the Breaker"	},
				{	["ENCOUNTERID"] =	819,	["NAME"] = "Horridon"				},
				{	["ENCOUNTERID"] =	816,	["NAME"] = "Council of Elders"		},
				{	["ENCOUNTERID"] =	825,	["NAME"] = "Tortos"					},
				{	["ENCOUNTERID"] =	821,	["NAME"] = "Megaera"				},
				{	["ENCOUNTERID"] =	828,	["NAME"] = "Ji-Kun"					},
				{	["ENCOUNTERID"] =	818,	["NAME"] = "Durumu the Forgotten"	},
				{	["ENCOUNTERID"] =	820,	["NAME"] = "Primordius"				},
				{	["ENCOUNTERID"] =	824,	["NAME"] = "Dark Animus"			},
				{	["ENCOUNTERID"] =	817,	["NAME"] = "Iron Qon"				},
				{	["ENCOUNTERID"] =	829,	["NAME"] = "Twin Consorts"			},
				{	["ENCOUNTERID"] =	832,	["NAME"] = "Lei Shen"				}
			}
		}--]]
	}
	self.BOSSOPTIONS = {}
	self.BOSSBYABBR = {}
	for i,t in ipairs(self.BOSSES) do
		self.BOSSOPTIONS[t.ABBR] = t.NAME
		self.BOSSBYABBR[t.ABBR] = {
			["NAME"] = t.NAME,
			["ID"] = t.INSTANCEID,
			["LIST"] = t.BOSS
		}
	end
	
	VitaPlannerL.BOSSOPTIONS = self.BOSSOPTIONS
	VitaPlannerL.BOSSESS = self.BOSSES
	--[[
		{	["NAME"] = "Flexible",		["VALUE"] = 14 },
		{	["NAME"] = "10 Normal",		["VALUE"] = 3 },
		{	["NAME"] = "25 Normal",		["VALUE"] = 4 },
		{	["NAME"] = "10 Heroic",		["VALUE"] = 5 },
		{	["NAME"] = "25 Heroic",		["VALUE"] = 6 }--]]
	-- Difficulties for Selection, Passing to Raid Member, and for Dungeon Journal
	self.DIFFICULTIES = {
		{	["NAME"] = "Normal",	["VALUE"] = 14 },
		{	["NAME"] = "Heroic",	["VALUE"] = 15 },
		{	["NAME"] = "Mythic",	["VALUE"] = 16 }		
	}
	self.DIFFOPTIONS = {}
	for i,d in ipairs(self.DIFFICULTIES) do
		self.DIFFOPTIONS[d.VALUE] = d.NAME
	end
	VitaPlannerL.DIFFOPTIONS = self.DIFFOPTIONS
	
	self.SPECIALISATIONS = {
		{ ["CLASS"] = "DEATHKNIGHT", 	["SPEC"] = { 	{ ["ID"] = 250, 	["NAME"] = "Blood", 		["ROLE"] = "TANK" 	},
														{ ["ID"] = 251,		["NAME"] = "Frost",			["ROLE"] = "MELEE"	},
														{ ["ID"] = 252,		["NAME"] = "Unholy",		["ROLE"] = "MELEE"	} } },
		{ ["CLASS"] = "DEMONHUNTER", 	["SPEC"] = { 	{ ["ID"] = 577, 	["NAME"] = "Havoc", 		["ROLE"] = "MELEE" 	},
														{ ["ID"] = 581,		["NAME"] = "Vengeance",		["ROLE"] = "TANK"	} } },
		{ ["CLASS"] = "DRUID", 			["SPEC"] = { 	{ ["ID"] = 102, 	["NAME"] = "Balance", 		["ROLE"] = "RANGED" 	},
														{ ["ID"] = 103,		["NAME"] = "Feral Combat",	["ROLE"] = "MELEE"	},
														{ ["ID"] = 104,		["NAME"] = "Guardian",		["ROLE"] = "TANK"	},
														{ ["ID"] = 105,		["NAME"] = "Restoration",	["ROLE"] = "HEALER"	} } },
		{ ["CLASS"] = "HUNTER", 		["SPEC"] = { 	{ ["ID"] = 253, 	["NAME"] = "Beast Mastery", ["ROLE"] = "RANGED" 	},
														{ ["ID"] = 254,		["NAME"] = "Marksmanship",	["ROLE"] = "RANGED"	},
														{ ["ID"] = 255,		["NAME"] = "Survival",		["ROLE"] = "RANGED"	} } },
		{ ["CLASS"] = "MAGE", 			["SPEC"] = { 	{ ["ID"] = 62, 		["NAME"] = "Arcane", 		["ROLE"] = "RANGED" 	},
														{ ["ID"] = 63,		["NAME"] = "Fire",			["ROLE"] = "RANGED"	},
														{ ["ID"] = 64,		["NAME"] = "Frost",			["ROLE"] = "RANGED"	} } },
		{ ["CLASS"] = "MONK", 			["SPEC"] = { 	{ ["ID"] = 268, 	["NAME"] = "Brewmaster", 	["ROLE"] = "TANK" 	},
														{ ["ID"] = 269,		["NAME"] = "Windwalker",	["ROLE"] = "MELEE"	},
														{ ["ID"] = 270,		["NAME"] = "Mistweaver",	["ROLE"] = "HEALER"	} } },
		{ ["CLASS"] = "PALADIN", 		["SPEC"] = { 	{ ["ID"] = 65, 		["NAME"] = "Holy", 			["ROLE"] = "HEALER" 	},
														{ ["ID"] = 66,		["NAME"] = "Protection",	["ROLE"] = "TANK"	},
														{ ["ID"] = 70,		["NAME"] = "Retribution",	["ROLE"] = "MELEE"	} } },
		{ ["CLASS"] = "PRIEST",			["SPEC"] = { 	{ ["ID"] = 256, 	["NAME"] = "Discipline", 	["ROLE"] = "HEALER" 	},
														{ ["ID"] = 257,		["NAME"] = "Holy",			["ROLE"] = "HEALER"	},
														{ ["ID"] = 258,		["NAME"] = "Shadow",		["ROLE"] = "RANGED"	} } },
		{ ["CLASS"] = "ROGUE",			["SPEC"] = { 	{ ["ID"] = 259, 	["NAME"] = "Assassination", ["ROLE"] = "MELEE" 	},
														{ ["ID"] = 260,		["NAME"] = "Outlaw",		["ROLE"] = "MELEE"	},
														{ ["ID"] = 261,		["NAME"] = "Subtlety",		["ROLE"] = "MELEE"	} } },
		{ ["CLASS"] = "SHAMAN", 		["SPEC"] = { 	{ ["ID"] = 262, 	["NAME"] = "Elemental", 	["ROLE"] = "RANGED" 	},
														{ ["ID"] = 263,		["NAME"] = "Enhancement",	["ROLE"] = "MELEE"	},
														{ ["ID"] = 264,		["NAME"] = "Restoration",	["ROLE"] = "HEALER"	} } },
		{ ["CLASS"] = "WARLOCK", 		["SPEC"] = { 	{ ["ID"] = 265, 	["NAME"] = "Affliction", 	["ROLE"] = "RANGED" 	},
														{ ["ID"] = 266,		["NAME"] = "Demonology",	["ROLE"] = "RANGED"	},
														{ ["ID"] = 267,		["NAME"] = "Destruction",	["ROLE"] = "RANGED"	} } },
		{ ["CLASS"] = "WARRIOR", 		["SPEC"] = { 	{ ["ID"] = 71, 		["NAME"] = "Arms", 			["ROLE"] = "MELEE" 	},
														{ ["ID"] = 72,		["NAME"] = "Fury",			["ROLE"] = "MELEE"	},
														{ ["ID"] = 73,		["NAME"] = "Protection",	["ROLE"] = "TANK"	} } }
	}
	self.CLASSES = {}
	for i,s in ipairs(self.SPECIALISATIONS) do
		local spec = {}
		for j,t in ipairs(s.SPEC) do
			--[[tinsert(spec, t.ID = {
				["NAME"] = t.NAME,
				["ROLE"] = t.ROLE })--]]
			spec[t.ID] = {
				["NAME"] = t.NAME,
				["ROLE"] = t.ROLE }
		end
		self.CLASSES[s.CLASS] = spec
	end
	
	--print (self.BOSSES.T16_LIST[1].NAME)
	
	self.db:RegisterDefaults({
		profile = {					
			selection_timeout = 60,
			selected_raid = "ATB",
			selected_difficulty = 16,
			button_in = "IN",
			button_out = "OUT",
			button_neutral = "NEUTRAL",
			hideLOnCombat = true,
            selection_sound = 43521
		}
    })
	
	VitaPlannerL:SetupOptions()
	
	self:ScheduleTimer("SetupVariables", 10)
	self:ScheduleTimer("PostEnable", 10)
	
	if IsInGuild() and IsInRaid() then
		self:SendCommMessage("VPGInfoRequest", "GUILD_INFO", "RAID")
	end
end

function VitaPlannerL.PrintBossList()
	local index = 1;
    local name, description, bossID, _, link = EJ_GetEncounterInfoByIndex(index);
	
	while bossID do
		print (name, bossID)
		index = index + 1;
		name, description, bossID, _, link = EJ_GetEncounterInfoByIndex(index);
	end	
end

function VitaPlannerL.PrintTestList()
	local wantRaids = true -- set false to get 5-man list
    for i=1,1000 do
        instanceID,name,description,bgImage,buttonImage,loreImage, dungeonAreaMapID, link = EJ_GetInstanceByIndex(i,wantRaids)
        if not instanceID then break end
        DEFAULT_CHAT_FRAME:AddMessage(
            instanceID.." "..name ,
    1,0.7,0.5)
    end
end

function VitaPlannerL:OnEnable()

end

function VitaPlannerL:OnDisable()
	
end

function VitaPlannerL:PostEnable()
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER",			VitaPlannerL.ChatFilter)
	--ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID",    		VitaPlannerL.ChatFilter)
	--ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER",		VitaPlannerL.ChatFilter)
	--ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL",			VitaPlannerL.ChatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", 	VitaPlannerL.ChatFilter)
	
end

function VitaPlannerL:SetupVariables()
	self.difficulty = self.db.profile.selected_difficulty
	self.diffName = self.DIFFOPTIONS[self.difficulty]
	if self.db.profile.selected_raid ~= "ATB" then
		self.db.profile.selected_raid = "ATB"
	end
	self.selectedRaid = self.db.profile.selected_raid
	--print(self.db.profile.selected_raid)
	self.selectedBossList = self.BOSSBYABBR[self.selectedRaid].LIST	
	self.zoneName = self.BOSSBYABBR[self.selectedRaid].NAME
	self.zone = self.BOSSBYABBR[self.selectedRaid].ID
	self.selectedBoss = nil
	self.selectedBossID = nil
    self.selection_sound = self.db.profile.selection_sound or defaultSoundKitID
	
	self.inList = {}
	self.outList = {}
	self.neutralList = {}
	self.reasonList = {}
	
	self.timeout = 0
	self.timeoutLeft = 0
	
	self.currentlyChecking = false
	
	self.currentDraggedUnitFrame = nil
	
	self.RESPONSES.IN.TEXT = self.db.profile.button_in
	self.RESPONSES.OUT.TEXT = self.db.profile.button_out
	self.RESPONSES.NEUTRAL.TEXT = self.db.profile.button_neutral
	
	-- PlayerInformation
	local guildName, guildRank, guildRankID = GetGuildInfo("player")
	self.myGuildName = guildName
	self.myRank = guildRank
	self.myRankID = guildRankID
	--print("<"..self.myGuildName.."> - "..self.myRank)
end

local function GetOptions()
	VitaPlannerL.RPOptions = {
		name = "VitaPlannerL",
		handler = VitaPlannerL,
		type = 'group',
		get = function(i) return VitaPlannerL.db.profile[i[#i]] end,
		set = function(i, v) VitaPlannerL.db.profile[i[#i]] = v end,
		plugins = {},
		args = {
			global = {
				order = 1,
				type = "group",
				hidden = function(info) return not VitaPlannerL end,
				name = "General Config",
				args = {
					selection_timeout = {
						order = 1,
						type = "select",
						width = "double",
						name = "Boss Selection Timeout",
						desc = "Sets the amount of time a raid member has to select a boss.",
						values = {
							[0] = 'No timeout',
							[10] = '10 secs',
							[15] = '15 secs',
							[20] = '20 secs',
							[30] = '30 secs',
							[40] = '40 secs',
							[50] = '50 secs',
							[60] = '1 minute',
							[90] = '1 min 30 sec',
							[150] = '2 min 30 sec',
							[300] = '5 min',
						}
					},
					selected_raid = {
						order = 2,
						type = "select",
						width = "double",
						name = "Default Selected Raid",
						desc = "Sets the default raid for the planner",
						values = VitaPlannerL.BOSSOPTIONS--[[{
							["SoO"] = "Siege of Orgrimmar"
						}--]]
					},
					selected_difficulty = {
						order = 3,
						type = "select",
						width = "double",
						name = "Default Selected Difficulty",
						desc = "Sets the default difficulty level for the raid",
						values = VitaPlannerL.DIFFOPTIONS --[[{
							[14] = "Flexible",
							[3] = "10 Normal",
							[4] = "25 Normal",					
							[5] = "10 Heroic",
							[6] = "25 Heroic",
						}--]]
					},
					button_in = {
						order = 4,
						type = "input",
						width = "double",
						name = "\"IN\" Button Text",
						desc = "What people will see for the \"IN\" option"
						--get = function() VitaPlannerL.db.profile.button_in end,
						--set
					},
					button_out = {
						order = 5,
						type = "input",
						width = "double",
						name = "\"OUT\" Button Text",
						desc = "What people will see for the \"OUT\" option"
						--get = function() VitaPlannerL.db.profile.button_in end,
						--set
					},
					button_neutral = {
						order = 6,
						type = "input",
						width = "double",
						name = "\"Neutral\" Button Text",
						desc = "What people will see for the \"Neutral\" option"
					},
                    selection_sound = {
                        order = 7,
                        type = "input",
                        width = "double",
                        name = "Selection Sound",
                        desc = "Input a selection sound to be played when you send a request; Must be a SoundKit ID"
                    }
				}
			},
		},
	}
	VitaPlannerL.RPOptions.plugins.profiles = { profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(VitaPlannerL.db) }
	
	return VitaPlannerL.RPOptions
end

function VitaPlannerL:EnterCombat()	
	-- On entering combat, we need to hide the Leader frame and set a variable true if in the middle of a check
	self.inCombat = true
	if self:IsShown() then
		-- Hide the frame
		--self.currentlyChecking = true
		--self:Hide()
		-- If in check, set variable to true
		
	end
end

function VitaPlannerL:LeaveCombat()
	-- On leaving combat, do the reverse of entering
    self.inCombat = false;
	-- If was not in middle of check then don't reopen
	if self.currentlyChecking == false then return end	
	-- Reopen frame
	--print(self.currentlyChecking)
	--self.isChecking = false
	if IsInRaid() and (UnitIsGroupAssistant("player") or UnitIsGroupLeader("player")) then	
		--if VitaPlanner.timeoutLeft > 0 then
			self:Show()
	end
end

function VitaPlannerL:IsShown()
	-- Find out if our addon is shown
	-- If the base frame doesn't exist, then our addon isn't showing
    if not self.frame then return false end;
	-- If we're in combat, and we've told the addon to hide in combat then return true
    if self.inCombat and self.setHiddenOnCombat then return true end
	-- Return the visibility status of the inner frame
    return self.frame:IsShown();
end

function VitaPlannerL:Show()
	-- If we don't have an inner frame then we can't show anything
    if not self.frame then return false end;

	-- If we're not in combat
	--if not self.inCombat then
		-- If we're by ourselves, or if we're in a raid and have proper status
		if not IsInRaid() or (IsInRaid() and (UnitIsGroupAssistant("player") or UnitIsGroupLeader("player"))) then	
			-- Show the inner frames
            self:UpdateRaidInfoGroups()
            self:UpdateLists()
			return self.frame:Show()
		end
	--end
	return
end

function VitaPlannerL:Hide()
	-- If we don't have an inner frames then we don't need to hide anything
    if not self.frame then return end;
	-- Hide the inner frames
    local ret = self.frame:Hide();
	-- Return the result
    return ret;
end

function VitaPlannerL:ShowGuildVersionInfo()
    print("|cff00ffff[VitaPlanner]|r : Guild Version Info")
    for i,r in pairs(self.Raiders) do
        print ("|cff00ffff[VP]|r - "..i.." : Version - "..r.VERSION)
    end
end

function VitaPlannerL:Command(input)
	if input == "list" then
		self:PrintBossList()
	elseif input == "tlist" then
		self:PrintTestList()
	elseif input == "options" then
		-- Open the options menu
		LibStub("AceConfigDialog-3.0"):Open("VitaPlannerL")
    elseif input == "gversion" then
        self:SendCommMessage("VPGInfoRequest", "GUILD_INFO", "GUILD")
        self:ScheduleTimer("ShowGuildVersionInfo", 10)
	elseif not IsInRaid() or (IsInRaid() and (UnitIsGroupAssistant("player") or UnitIsGroupLeader("player"))) then
		if IsInGuild() and IsInRaid() then
			self:SendCommMessage("VPGInfoRequest", "GUILD_INFO", "RAID")
		end	
		-- If we're by ourselves, or if we're in a raid and have proper status, set out frames and variables
		-- If we had the main frame before, then continue on, else make a new one
		local pFrame = self.mainFrame
        if not pFrame then
            pFrame = self:CreatePlannerLeaderFrame()			
            self.mainFrame = pFrame
        end
		
		-- If we've never selected a boss, then disable the check raid button
		
		self:UpdateMaxGroupSet()
		-- Update our preference lists
		self:UpdateLists()
		
		-- Show the inner frames
		if self:IsShown() then
			self:Hide()
		else 
			pFrame:Show()
			-- Show the outer frame
			self:Show()
		end
	else
		-- If you don't have permissions, you can't view the planner
		print("You are not allowed to view this")
	end
end

function VitaPlannerL:RegisterOptions(key, table)
	if not self.RPOptions then
		error("Options table has not been created yet, respond to the callback!", 2)
	end
	self.RPOptions.plugins[key] = { [key] = table }
end

function VitaPlannerL:SetupOptions()
	LibStub("AceConfig-3.0"):RegisterOptionsTable("VitaPlannerL", GetOptions)
	AceConfigDialog:SetDefaultSize("VitaPlannerL", 880,525)
	VitaPlannerL:RegisterChatCommand("vpl", "Command")
end

--[[function VitaPlannerL:InspectUpdateHandler(event, guid, unit, info)
	if info.class and info.spec_role_detailed then
		local unitID = LGIST:GuidToUnit(guid)
		--if VitaPlanner.UnitIsUnit(unit, "player")
		self.Raiders[UnitName(unit)].Class = strupper(info.class)
		self.Raiders[UnitName(unit)].SpecRole = strupper(info.spec_role_detailed)
		--print (self.Raiders[unitID].Name .. " - " .. self.Raiders[unitID].SpecRole)
	end
end

function VitaPlannerL:InspectRemoveHandler(event, guid)
	local unitID = LGIST:GuidToUnit(guid)
	--print(unitID .. " removed")
	--self.Raiders[UnitName(unitID)] = nil
end--]]

function VitaPlannerL:CreateGroupSetMessage()
	local MAX_NUM_RAIDERS = 40
	local numRaidMembers = GetNumGroupMembers();
	
	--[[ DIFFICULTY IDS
		{	["NAME"] = "Flexible",		["VALUE"] = 14 },
		{	["NAME"] = "10 Normal",		["VALUE"] = 3 },
		{	["NAME"] = "25 Normal",		["VALUE"] = 4 },
		{	["NAME"] = "10 Heroic",		["VALUE"] = 5 },
		{	["NAME"] = "25 Heroic",		["VALUE"] = 6 }
	--]]
	self:UpdateMaxGroupSet()
	
	local message = self.selectedBoss .. "^" .. maxSetNum .. "^"
	local raiderList = {}
	for i = 1, MAX_NUM_RAIDERS do
		if IsInRaid() and i <= numRaidMembers then
			local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, loot = GetRaidRosterInfo(i);
			local person = format("%s;%d", name, subgroup)
			tinsert(raiderList, person)
		end			
	end
	
	message = message .. strjoin('*', unpack(raiderList))
	--print(message)
	return message, maxSetNum
end

function VitaPlannerL:UpdateRaidInfoGroups()
	if not self.frame then return end

	local MAX_NUM_RAIDERS = 40
	local numRaidMembers = GetNumGroupMembers();
	local groups = { [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}, [6] = {}, [7] = {}, [8] = {} }
	
	for i = 1, MAX_NUM_RAIDERS do
		if IsInRaid() and i <= numRaidMembers then
			--local name = _G["RaidGroupButton"..i.."Name"];
			local unit = "raid"..i
			local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, loot = GetRaidRosterInfo(i);
			--print(unit .. " - " .. name .. " : " .. subgroup)
			-- Check party members
			local specrole = ""
			--[[if VitaPlanner.UnitIsUnit(unit,"player") then
				unit = "player"
			end--]]
			--print("Name: "..VitaPlanner.UnAmbiguate(name))
			local rName = VitaPlanner.UnAmbiguate(name)
			if self.Raiders[rName] then
				local active = tonumber(self.Raiders[rName].ACTIVESPEC)
				if active == 1 then
					--print("Active: 1 - "..self.Raiders[rName].SPEC1.ROLE)
					specrole = self.Raiders[rName].SPEC1.ROLE
				elseif active == 2 then
					--print("Active: 2 - "..self.Raiders[rName].SPEC2.ROLE)
					specrole = self.Raiders[rName].SPEC2.ROLE
				end
				name = "|c"..self.Raiders[rName].COLOR..name.."|r"
			else
				name = "|c"..RAID_CLASS_COLORS[fileName].colorStr..name.."|r"
			end
			local info = { ["NAME"] = name, ["ID"] = i, ["GROUP"] = subgroup, ["SPECROLE"] = specrole, ["CLASS"] = class, ["ONLINE"] = online, ["RNAME"] = rName }
			tinsert(groups[subgroup], info)
        elseif not IsInRaid() and IsInGroup() then
            --print ("is in group")
            if i <= 5 then
                local unit
                if i == 1 then
                     unit = "player"
                else
                    unit = "party"..i-1
                end

                local name = UnitName(unit)

                local rName = name
                local class = UnitClass(unit)
                local subgroup = 1
                local specrole = ""
                local online = UnitIsConnected(unit)
                local info = { ["NAME"] = name, ["ID"] = i, ["GROUP"] = subgroup, ["SPECROLE"] = specrole, ["CLASS"] = class, ["ONLINE"] = online, ["RNAME"] = rName }
                tinsert(groups[subgroup], info)
            end
		end
	end

    if not IsInRaid() and not IsInGroup() then
        local unit = "player"
        local name = UnitName(unit)
        local rName = name
        local class = UnitClass(unit)
        local subgroup = 1
        local specrole = ""
        local online = UnitIsConnected(unit)
        local info = { ["NAME"] = name, ["ID"] = 1, ["GROUP"] = subgroup, ["SPECROLE"] = specrole, ["CLASS"] = class, ["ONLINE"] = online, ["RNAME"] = rName }
        tinsert(groups[subgroup], info)
    end

	-- Set the text of all raid unit infos
	--local totalCounter = 1
	for i = 1, 8 do
		local maxGUnits = 5
		for count = 1, maxGUnits do
			local newText = ""
			local raidIndex = count + ((tonumber(i)-1) * 5)
			--Default the backdrop
			_G["VitaRaidUnit_"..raidIndex]:SetBackdropColor(0.1,0.1,0.1,0.0)
			--Default the icon
			_G["VitaRaidUnit_"..raidIndex].icon:SetTexture(0,0,0,0)
            --Default the selection
            _G["VitaRaidUnit_"..raidIndex].selection:SetText("")
            --Default the role
            _G["VitaRaidUnit_"..raidIndex].role:SetText("")
			if groups[i][count] then
				if not groups[i][count].ONLINE then
					_G["VitaRaidUnit_"..raidIndex]:SetBackdropColor(0.4,0.4,0.4,0.8)
				else
					_G["VitaRaidUnit_"..raidIndex]:SetBackdropColor(0.1,0.1,0.1,0.8)
				end
				-- Get the name of the raider and assign some special globals for identification
				newText = groups[i][count].NAME
                _G["VitaRaidUnit_"..raidIndex.."-NAME"] = groups[i][count].RNAME
				_G["VitaRaidUnit_"..raidIndex.."-NUMBER"] = groups[i][count].ID
				_G["VitaRaidUnit_"..raidIndex.."-SPECROLE"] = groups[i][count].SPECROLE
				_G["VitaRaidUnit_"..raidIndex.."-CLASS"] = groups[i][count].CLASS
				_G["VitaRaidUnit_"..raidIndex.."-ONLINE"] = groups[i][count].ONLINE
				_G["VitaRaidSpecialIndex_"..groups[i][count].ID] = _G["VitaRaidUnit_"..raidIndex]
				_G["VitaRaidSpecialIndex_"..groups[i][count].ID].icon:SetAlpha(0.5)
				--totalCounter = totalCounter + 1
				--print(groups[i][count].SPECROLE)
				if groups[i][count].SPECROLE then
					if groups[i][count].SPECROLE ~= "" then
						--print (raidIndex .. " - ID: " .. groups[i][count].ID .. " - Name: " .. groups[i][count].NAME .. " - Role: " .. groups[i][count].SPECROLE)
						_G["VitaRaidSpecialIndex_"..groups[i][count].ID].icon:SetTexture("Interface\\Addons\\VitaPlanner_Leader\\icons\\"..strlower(groups[i][count].SPECROLE)..".tga")
                        local niceRole = groups[i][count].SPECROLE
                        niceRole = strlower(niceRole)
                        niceRole = niceRole:gsub("^%l", string.upper)
                        _G["VitaRaidSpecialIndex_"..groups[i][count].ID].role:SetText(niceRole)
					end
				end
			end
			-- Assign the proper group position to this name
			_G["VitaGroup_"..i.."_Unit_"..count].name:SetText(newText)			
		end
	end	
end


function VitaPlannerL:OpenModifyMenu(frame, button)
    self.currentModifyUnitFrame = frame
    if (button == "RightButton") then
        local modifyMenu = self.modifyMenu
        if not modifyMenu then
            modifyMenu = self:CreateModifyMenuFrame(frame)
            self.modifyMenu = modifyMenu
        end
        local uiScale, cursorX, cursorY = UIParent:GetEffectiveScale(), GetCursorPosition()
        --print (cursorX .. " , " .. cursorY)
        modifyMenu:SetPoint("TOPLEFT", nil, "BOTTOMLEFT",cursorX / uiScale,cursorY / uiScale)
        modifyMenu:Show()
        --modifyMenu:SetPoint("TOPLEFT", )
    elseif (button == "LeftButton") then
        if self.modifyMenu then
            self.modifyMenu:Hide()
        end
    end
end


function VitaPlannerL:BeginMovingRaidMember(frame, button)
	--print ("Drag started on: "..frame:GetName())
	self.currentDraggedUnitFrame = frame
	local draggedFrame = self.draggedFrameVisual
	if not draggedFrame then
		--print("generating dragged frame")
		draggedFrame = self:CopyRaidUnitFrame(self.currentDraggedUnitFrame:GetName())
		self.draggedFrameVisual = draggedFrame
	end
	
	draggedFrame.frame.name:SetText(_G[frame:GetName().."_NAME"]:GetText())
	draggedFrame.frame.spec.tex:SetTexture(_G[frame:GetName()].icon:GetTexture())
	draggedFrame:Show()
	--print (self.currentDraggedUnitFrame:GetName())
end

function VitaPlannerL:TryInitiateSwap(frame)
	if (string.match(GetMouseFocus():GetName(),"VitaRaidUnit")) then
		local _, initID = strsplit("_", self.currentDraggedUnitFrame:GetName())
		local actualInitID = _G["VitaRaidUnit_"..initID.."-NUMBER"]
		--print("initID "..initID.." - actualID "..actualInitID)
		local _, targetID = strsplit("_", GetMouseFocus():GetName())
		
		if UnitAffectingCombat("player") or UnitAffectingCombat("raid"..actualInitID) then self.draggedFrameVisual:Hide() return end
		--print(_G["VitaRaidUnit_"..targetID.."_NAME"]:GetText())
		if _G["VitaRaidUnit_"..targetID.."_NAME"]:GetText() then
			local actualTargetID = _G["VitaRaidUnit_"..targetID.."-NUMBER"]
			if UnitAffectingCombat("raid"..actualTargetID) then self.draggedFrameVisual:Hide() return end
			--print("targetID "..targetID.." - actualID "..actualTargetID)
			SwapRaidSubgroup(tonumber(actualInitID), tonumber(actualTargetID))
		else
			local _, targetGroup = strsplit("_", GetMouseFocus():GetParent():GetName())
			--print("Target Group: "..targetGroup)
			SetRaidSubgroup(tonumber(actualInitID), tonumber(targetGroup))
		end
	end
	self.draggedFrameVisual:Hide()
end

function VitaPlannerL:UpdateMaxGroupSet()
	if self.difficulty == 14 or self.difficulty == 15 then
		maxSetNum = 6		
	elseif self.difficulty == 16 then
		maxSetNum = 4
	else
		maxSetNum = 6
	end
end

function VitaPlannerL:UpdateLists()
	self:UpdateInList()
	self:UpdateOutList()
	self:UpdateNeutralList()
end

function VitaPlannerL:ResetLists()
	self.inList = {}
	self.outList = {}
	self.neutralList = {}
	self.reasonList = {}
	
	self:UpdateRaidInfoGroups()
	self:UpdateLists()
end

function VitaPlannerL:SetReason(sender, reason)
	self.reasonList[sender] = reason
end

function VitaPlannerL:SetList(sender, isIn, isOut, isNeutral)
    --print(sender)
	self.inList[sender] = isIn
	self.outList[sender] = isOut
	self.neutralList[sender] = isNeutral
end

function VitaPlannerL:UpdateInList()
    local realmName = "-"..GetRealmName();
    local ret = ""
    
    if self.inList == nil then return ret end
    
    for key,value in pairs(self.inList) do 
        
        local player = string.gsub(key, realmName, "");
        
        local groupNumber = 40;
        local raidIndex = UnitInRaid(player);
        
        if (raidIndex ~= nil) then
            _,_, groupNumber = GetRaidRosterInfo(raidIndex);
        else
			return
		end        
		
		if groupNumber <= maxSetNum then
			-- Colour this unit green
			--print(player .. " - " .. raidIndex)
			_G["VitaRaidSpecialIndex_"..raidIndex]:SetBackdropColor(0,0.5,0,0.4)
		end
		if groupNumber >= maxSetNum+1 then
			-- Colour this unit red
			_G["VitaRaidSpecialIndex_"..raidIndex]:SetBackdropColor(0.5,0,0,0.4)
        end

        _G["VitaRaidSpecialIndex_"..raidIndex].selection:SetText("In")
    end

end

function VitaPlannerL:UpdateOutList()
    local realmName = "-"..GetRealmName();
    local ret = ""
    
    if self.outList == nil then return ret end
    
    for key,value in pairs(self.outList) do 
        
        local player = string.gsub(key, realmName, "");
        
        local groupNumber = 40;
        local raidIndex = UnitInRaid(player);
        
        if (raidIndex ~= nil) then
            _,_, groupNumber = GetRaidRosterInfo(raidIndex);
        else
			return
		end        
		
		if groupNumber <= maxSetNum then
			-- Colour this unit red
			_G["VitaRaidSpecialIndex_"..raidIndex]:SetBackdropColor(0.5,0,0,0.4)
		end
		if groupNumber >= maxSetNum+1 then
			-- Colour this unit green
			_G["VitaRaidSpecialIndex_"..raidIndex]:SetBackdropColor(0,0.5,0,0.4)
		end

        _G["VitaRaidSpecialIndex_"..raidIndex].selection:SetText("Out")
    end

end

function VitaPlannerL:UpdateNeutralList()
    local realmName = "-"..GetRealmName();
    local ret = ""
    
    if self.neutralList == nil then return ret end
    
    for key,value in pairs(self.neutralList) do 
        
        local player = string.gsub(key, realmName, "");
        
        local groupNumber = 40;
        local raidIndex = UnitInRaid(player);
        
        if (raidIndex ~= nil) then
            _,_, groupNumber = GetRaidRosterInfo(raidIndex);
        else
			return
		end
		
		-- Colour this unit yellow
		_G["VitaRaidSpecialIndex_"..raidIndex]:SetBackdropColor(0.5,0.5,0,0.4)
        _G["VitaRaidSpecialIndex_"..raidIndex].selection:SetText("Neutral")
    end
    
end

function VitaPlannerL:Debug( message, verbose )
    if not self.debug then return end;
    if verbose and not self.verbose then return end;
    self:Print("debug: " .. message)
end

function VitaPlannerL:SendClientCommand(command, message, target)
	if not target then
		return self:Print(L["Could not send command, no target specified"])
	end;
    if target=='RAID' then
        self:SendCommMessage("VitaPlannerC", format("%s:%s", tostring(command), tostring(message)), "RAID", nil, "ALERT")
    elseif target=='PARTY' then
        self:SendCommMessage("VitaPlannerC", format("%s:%s", tostring(command), tostring(message)), "PARTY", nil, "ALERT")
    elseif target=='GUILD' then
        self:SendCommMessage("VitaPlannerC", format("%s:%s", tostring(command), tostring(message)), "GUILD", nil, "ALERT")
    else
        -- Don't use AceComm for messages to self, call function directly
        if VitaPlanner.UnitIsUnit(target, 'player') then
			--print("Target is me")
            VitaPlanner.CommandReceived(VitaPlanner, "VitaPlannerC", format("%s:%s", tostring(command), tostring(message)), 'WHISPER', target)
        else
            self:SendCommMessage("VitaPlannerC", format("%s:%s", tostring(command), tostring(message)), "WHISPER", target, "ALERT")
        end
    end
end

function VitaPlannerL:SendLeaderCommand(command, message, target)
	if not target then
		return self:Print(L["Could not send command, no target specified"])
	end;
    if target=='RAID' then
        self:SendCommMessage("VitaPlannerL", format("%s:%s", tostring(command), tostring(message)), "RAID", nil, "ALERT")
    elseif target=='PARTY' then
        self:SendCommMessage("VitaPlannerL", format("%s:%s", tostring(command), tostring(message)), "PARTY", nil, "ALERT")
    elseif target=='GUILD' then
        self:SendCommMessage("VitaPlannerL", format("%s:%s", tostring(command), tostring(message)), "GUILD", nil, "ALERT")
    else
        -- Don't use AceComm for messages to self, call function directly
        if VitaPlanner.UnitIsUnit(target, 'player') then
			--print("Target is me")
            VitaPlanner.CommandReceived(VitaPlanner, "VitaPlannerL", format("%s:%s", tostring(command), tostring(message)), 'WHISPER', target)
        else
            self:SendCommMessage("VitaPlannerL", format("%s:%s", tostring(command), tostring(message)), "WHISPER", target, "ALERT")
        end
    end
end

function VitaPlannerL:CommandReceived(prefix, message, distribution, sender)
	local _,_,command, message = string.find(message, "^([%a_]-):(.*)$")
	command = strupper(command or '');
	message = message or '';

	sender = VitaPlanner.UnAmbiguate(sender)
	
	--print (message)
	
	if command == "SELECTION" then
		local pFrame = self.mainFrame
        if not pFrame then
            pFrame = self:CreatePlannerLeaderFrame()			
            self.mainFrame = pFrame
        end

        self:UpdateRaidInfoGroups()

		-- Get the selection response from the sender
		local bossName, value = strsplit("^", message)
		--print(sender .. " - " .. strupper(value))
		local value, reason = strsplit("|", value)
		value = strupper(value)
		if value == "IN" then
			self:SetList(sender, "true", nil, nil)
		end
		
		if value == "OUT" then
			self:SetList(sender, nil, "true", nil)
			if not reason then
				reason = "N/A"
			end
			self:SetReason(sender, reason)
		end
		
		if value == "NEUTRAL" then
			self:SetList(sender, nil, nil, "true")
		end
		
		if value == "NONE" then
			self:SetList(sender, nil, nil, nil)
		end
		
		-- Update the selection list visuals
		self:UpdateMaxGroupSet()
		self:UpdateLists()
		
		-- TODO: Share the in/out lists to other raid members with assist or leader
		--self:ShareLists()
		if IsInRaid() and (UnitIsGroupAssistant("player") or UnitIsGroupLeader("player")) and VitaPlanner.UnitIsUnit(sender, "player") then
			-- Show the inner frames
			pFrame:Show()
			-- Show the outer frames
			self:Show()
		end
	elseif command == "RESET_LISTS" then
		if VitaPlanner.UnitIsUnit(sender, "player") then return end
		if IsInRaid() and (UnitIsGroupAssistant(sender) or UnitIsGroupLeader(sender)) then
			self:ResetLists()
		end
	elseif command == "COPY_WHISPER" then
		if VitaPlanner.UnitIsUnit(sender, "player") then return end
		local sender, selection = strsplit("^",message)
		if selection == "IN" then
			self:SetList(sender, "true", nil, nil)
		end		
		if selection == "OUT" then
			self:SetList(sender, nil, "true", nil)
		end		
		if selection == "NEUTRAL" then
			self:SetList(sender, nil, nil, "true")
		end
		if selection == "CANCEL" then
			self:SetList(sender, nil, nil, nil)
		end				
	elseif command == "TALENTS_CHANGED" then
		local index = tonumber(message)
		--print(index)
		if not self.Raiders[sender] then
			--print("no raider found, asking")
			self:SendCommMessage("VPGInfoRequest", "GUILD_INFO", "WHISPER", sender)
		else
			--print("setting active spec "..message)
			self.Raiders[sender].ACTIVESPEC = index
			--self:UpdateRaidInfoGroups()
			--self:UpdateLists()
		end
	end
end

function VitaPlannerL:AskRaidForSelections()
	-- Ask the raid for their desired selection
	local inText = self.db.profile.button_in
	local outText = self.db.profile.button_out
	local neutralText = self.db.profile.button_neutral
	if inText == "" then
		inText = "IN"
	end
	if outText == "" then
		outText = "OUT"
	end
	if neutralText == "" then
		neutralText = "NEUTRAL"
	end
	-- Create our buttons
	local numButtons = 3
	--[[local buttons = {
		  {response = "IN",           text = inText,		colour = 'ffffff'},
		  {response = "OUT",          text = outText,		colour = 'ffffff'}
		}
	--]]
	
	self.RESPONSES.IN.TEXT = inText
	self.RESPONSES.OUT.TEXT = outText
	self.RESPONSES.NEUTRAL.TEXT = neutralText
	
	local buttonString = {}
	for i,b in pairs(self.RESPONSES) do
		--print (i .. ": " .. b.TEXT)
		tinsert(buttonString,
			format("%s;%s;%s;%s",
				i, b.TEXT, b.COLOR or "FFFFFF", tostring(b.REASON)))
	end
	buttonString = strjoin('*', unpack(buttonString))
	--print (buttonString)
	
	-- Get the stored timeout value from our options
	local timeout = VitaPlannerL.db.profile.selection_timeout --10
	
	-- Get the raid, boss and difficulty information from our boss info panel
	local bossName = self.selectedBoss
	local bossID = self.selectedBossID
	local diffName = self.diffName
	local diffID = self.difficulty
	local raidID = self.zone
    local soundID = self.db.profile.selection_sound
	--print(diffID)
	
	-- Format our message
	local message = format('%d^%s^%d^%s^%d^%d^%s^%d^%d',
							raidID,
							bossName,
							bossID,
							diffName,
							diffID,
							numButtons,
							buttonString,
							timeout,
                            soundID)
	
	-- Reset the selection lists as we don't want old entries to taint the new selections
	self:ResetLists()
	self:SendLeaderCommand("RESET_LISTS", "IGNORE_MESSAGE", "RAID")
	
	-- Start our local timer (corresponds to the timeout given to the raid)
	-- TODO, make this work properly when hidden
	self.timeout = timeout
	self.timeoutLeft = self.timeout
	if self.timeout and self.timeout>0 then
		--self.checkTimerFrame.progressBar:SetMinMaxValues(0,self.timeout)
		--self.checkTimerFrame.progressBar:SetValue(self.timeoutLeft)
		--self.checkTimerFrame.lblTimeout:SetText('')
		--self.checkTimerFrame:Show()
		_G["AskForSelections"]:Disable()
		self.currentlyChecking = true
	else
		--self.checkTimerFrame:Hide()
		_G["AskForSelections"]:Enable()
		self.currentlyChecking = false
	end
	
	-- If we're in a raid, send the check to the raid
	if IsInRaid() then
		self:SendClientCommand("CHECK_BOSS", message, "RAID")
	else
		-- If we're by ourself, ask ourself
		--VitaPlanner.CommandReceived(VitaPlannerC, 
		self:SendClientCommand("CHECK_BOSS", message, UnitName("player"))
	end
	
	if EPGP then
		for i=1,EPGP:GetNumMembers() do
			local name = EPGP:GetMember(i)
			if EPGP:IsMemberInExtrasList(name) then
				print ("Send Extra: "..name)
				--self:SendClientCommand("CHECK_BOSS", message, name)
			end
		end
	end
	
	local journalLink = "|cff66bbff|Hjournal:1:" .. bossID .. ":" .. diffID .. "|h["..bossName.."]|h|r"
	local raidMessage = "Planning started for "..journalLink.." - Please whisper me with : #IN , #OUT or #NEUTRAL : within the next "..timeout.." seconds!"
	local raidMessage2 = "If you have the Vita Planner add-on installed, please use the buttons in the pop-up."
	SendChatMessage( MSG_Prefix .. raidMessage, "RAID_WARNING")
	SendChatMessage( MSG_Prefix .. raidMessage2, "RAID_WARNING")
end

function VitaPlannerL:RAID_GROUP_UPDATE(...)
	--print(select(2,...))
	--print("Group updated")
	if not self.frame then return end
	if not self.frame:IsShown() then return end
	
	if IsInGuild() and IsInRaid() then
		self:SendCommMessage("VPGInfoRequest", "GUILD_INFO", "RAID")
		self:UpdateRaidInfoGroups()
		self:UpdateLists()
	end	
	--LGIST:Rescan()
	--self:UpdateMaxGroupSet()
end

function VitaPlannerL:HandleMSGCommand(command, message, sender, event)
	local senderUA = VitaPlanner.UnAmbiguate(sender)
	
	if self.currentlyChecking == false then
		self:SendWhisperResponse(UnitName("player") .. " is not currently accepting preferences.", senderUA)
		return true
	end
	--print(command .. " | " .. message .. " | " .. sender .. " | " .. event)
	if command == "IN" or command == "OUT" or command == "CANCEL" or command == "NEUTRAL" then
		local niceCommand = ""
		if command == "IN" then
			self:SetList(sender, "true", nil, nil)	
			niceCommand = "In"
		elseif command == "OUT" then
			self:SetList(sender, nil, "true", nil)
			niceCommand = "Out"
		elseif command == "NEUTRAL" then
			self:SetList(sender, nil, nil, "true")
			niceCommand = "Neutral"
		elseif command == "CANCEL" then
			self:SetList(sender, nil, nil, nil)
			niceCommand = "Cancel"
		end
	
		self:UpdateMaxGroupSet()
		-- Update the selection list visuals
		self:UpdateRaidInfoGroups()
		self:UpdateLists()
		self:SendLeaderCommand("COPY_WHISPER", format("%s^%s",sender,command), "RAID")
		
		local resMsg = niceCommand .. " received for " .. sender
		
		self:SendWhisperResponse(resMsg, senderUA)
		self:SendClientCommand("CLOSE_FRAME", "BLANK", senderUA)
		
		return true
	end
	return false
end

function VitaPlannerL:SendWhisperResponse(message, target)
    SendChatMessage( MSG_Prefix .. ( message or ''), 'WHISPER', nil, target );
    return false;
end

function VitaPlannerL:ChatFilter(...)
	local event = select(1, ...)
    local sender = VitaPlanner.UnAmbiguate(select(3, ...))
    local msg = select(2, ...)
    local msgID = select(12, ...)
	
	-- Do not process WIM History
    if not msgID or msgID<1 then return end
	
	if lastMsgID == msgID then
        return lastMsgFiltered
    end
	
	lastMsgID         = msgID
    lastMsgFiltered   = false
	
	local command, params = nil
	for i=1, numChatCommands do
		command = strmatch(msg, chatCommands[i])
		--print (command)
		--print ("===")
		if command == "[Vita Planner]" or command == "[VitaPlanner]" then return true end
		if command then break end
	end
	
	if command then
		local OK, ret = pcall(VitaPlannerL.HandleMSGCommand, VitaPlannerL, strupper(command or ''), strtrim(params or ''), sender, event)
		
		if not OK then
			print(format("Error parsing msg '%s' from %s: %s", tostring(params), tostring(sender), tostring(ret)))
		elseif OK and ret then
			--print("OK and ret true")
			lastMsgFiltered = true
		end

		return lastMsgFiltered
	end
end

function VitaPlannerL:SetCurrentBoss(frame, bossID, bossName, zoneID)
	local p = frame:GetParent()
	local pChildren = { p:GetChildren() }
	tremove(pChildren, 1)
	
	for i, c in ipairs(pChildren) do
		c:UnlockHighlight()
		--print("unlocking "..c.text:GetText())
		if c.text:GetText() == frame.text:GetText() then
			c:LockHighlight()
		else
			c:SetChecked(false)
		end
	end

	self.selectedBoss = bossName
	self.selectedBossID = bossID
	self.zone = zoneID
	
	_G["AskForSelections"]:Enable()
	_G["AnnounceGroupsSet"]:Enable()
	
	
	
	self:UpdateInfoPanel()
end

function VitaPlannerL:GuildInfoResponse(prefix, message, distribution, sender)
	local _,_,command, message = string.find(message, "^([%a_]-):(.*)$")
	
	sender = VitaPlanner.UnAmbiguate(sender)

	if (command == "GUILD_INFO_RES") then
		-- Our version is outdated
		self:AddToRaidersList(sender, message)
        --self:ShowUpdateFrame( sender, iVersion, senderVersionString )
	end
end

function VitaPlannerL:AddToRaidersList(sender, unitInfo)
	-- GuildName, GuildRank, Class, Spec, SpecRole
	--print (unitInfo)
	local gName, gRank, class, spec1, spec2, active, classF, vString = strsplit("^", unitInfo)
	-- Just for compatibility, only for US language though
	if not classF then
		class = string.upper(class)		
		if class == "DEATH KNIGHT" then
			class = "DEATHKNIGHT"
		end
		classF = class
	end
	-- Again for compatibility, the raider version string
	if not vString or vString == "" then
		vString = "Unknown"
	end
	spec1 = tonumber(spec1)
	spec2 = tonumber(spec2)
	local spec1Name, spec1Role, spec2Name, spec2Role = ""
	if spec1 == 0 then
		spec1Name = "None"
		spec1Role = "None"
	else
		spec1Name = self.CLASSES[classF][spec1].NAME
		spec1Role = self.CLASSES[classF][spec1].ROLE
	end
	if spec2 == 0 then
		spec2Name = "None"
		spec2Role = "None"
	else
		spec2Name = self.CLASSES[classF][spec2].NAME
		spec2Role = self.CLASSES[classF][spec2].ROLE
	end

	self.Raiders[sender] = {
		["GNAME"] = gName,
		["GRANK"] = gRank,
		["CLASS"] = classF,
		["SPEC1"] = { 
			["NAME"]	= spec1Name,
			["ROLE"] 	= spec1Role,
			["ID"]		= spec1},
		["SPEC2"] = { 
			["NAME"] 	= spec2Name,
			["ROLE"] 	= spec2Role,
			["ID"]		= spec2},
		["ACTIVESPEC"]	= active,
		["COLOR"]		= RAID_CLASS_COLORS[classF].colorStr,
		["VERSION"]		= vString
	}

end

function VitaPlannerL:SetCustomTooltip(frame, sType)
	if (sType == "UnitHover") then
		local unit = frame.frame.name:GetText()
		if not unit then return end
		
		local _, unitID = strsplit("_", frame:GetName())
        local actualUnitID
        if IsInRaid() then
		    actualUnitID = "raid".._G["VitaRaidUnit_"..unitID.."-NUMBER"]
        elseif not IsInRaid() and IsInGroup() then
            if _G["VitaRaidUnit_"..unitID.."-NUMBER"] == 1 then
            actualUnitID = "player"
            else
                local id = _G["VitaRaidUnit_"..unitID.."-NUMBER"] - 1
                actualUnitID = "party"..id
            end
        else
            actualUnitID = "player"
        end

		if VitaPlanner.UnitIsUnit(actualUnitID, "player") then
			actualUnitID = "player"
		end
		local name, realm = UnitName(actualUnitID)
		if realm == nil or realm == "" then realm = realmName end
		local unitName = name .. "-" .. realm
		--print(unitName)
		local gName, gRank, gRankID, class, classF = ""
		local info, spec1, spec2 = {}
		local version = nil
		if not self.Raiders[unitName] then
			--Lets try to get some info
			gName, gRank, gRankID = GetGuildInfo(actualUnitID)
			class, classF = UnitClass(actualUnitID)
			local id = GetInspectSpecialization(actualUnitID)
			id = tonumber(id)
			if id ~= 0 then
				spec1 = { ["NAME"] = self.CLASSES[classF][id].NAME, ["ROLE"] = self.CLASSES[classF][id].ROLE, ["ID"] = id }
			end
			specActive = 1
			version = "No Client"
		else
			info = self.Raiders[unitName]
			gName = info.GNAME
			gRank = info.GRANK
			spec1 = self.Raiders[unitName].SPEC1
			spec2 = self.Raiders[unitName].SPEC2
			specActive = tonumber(self.Raiders[unitName].ACTIVESPEC)
			version = self.Raiders[unitName].VERSION
		end
		
		if gName ~= nil then
			gName = "<"..gName..">"
		end
		--local gRank = 
		local unitNameCopy = unitName
		-- Color code unitname
		if self.Raiders[unitName] then
			unitName = "|c"..self.Raiders[unitName].COLOR..unitName.."|r"
		else
			unitName = "|c"..RAID_CLASS_COLORS[classF].colorStr..unitName.."|r"
		end
		
		local reason = nil
		--local realmName = "-"..GetRealmName();
		if self.reasonList then
			if self.reasonList[unitNameCopy] then
				reason = self.reasonList[unitNameCopy]
			end
		end
		
		GameTooltip:SetOwner(frame, "ANCHOR_RIGHT" )
		GameTooltip:SetText(unitName)  -- This sets the top line of text, in gold.
		if UnitIsConnected(actualUnitID) then
			GameTooltip:AddDoubleLine(gName, gRank, 1, 1, 1, 1, 1, 1)
			if reason then
				GameTooltip:AddLine(" ", 1, 1, 1)
				GameTooltip:AddLine("Reason For Out", 1, 0, 0)
				GameTooltip:AddLine(reason, 1, 1, 1)
				GameTooltip:AddTexture("")
			end
			if spec1 then
				GameTooltip:AddLine(" ", 1, 1, 1)
				GameTooltip:AddLine("Specialization 1", 1, 1, 1)
				GameTooltip:AddDoubleLine(spec1.NAME, spec1.ROLE, 1,1,1,1,1,1)
				GameTooltip:AddTexture(select(4,GetSpecializationInfoByID(spec1.ID)))								
				if specActive == 1 then
					GameTooltip:AddLine("Active Specialization", 1, 1, 0)
					GameTooltip:AddTexture("")
				end
			end
			if spec2 then
				GameTooltip:AddLine(" ", 1, 1, 1)
				GameTooltip:AddLine("Specialization 2", 1, 1, 1)
				GameTooltip:AddDoubleLine(spec2.NAME, spec2.ROLE, 1,1,1,1,1,1)
				GameTooltip:AddTexture(select(4,GetSpecializationInfoByID(spec2.ID)))
				if specActive == 2 then
					GameTooltip:AddLine("Active Specialization", 1, 1, 0)
					GameTooltip:AddTexture("")
				end
			end
			
			if EPGP then
				GameTooltip:AddLine(" ", 1, 1, 1)
				--print (unitNameCopy)
				--local ep, gp, name = EPGP:GetEPGP(VitaPlanner.Ambiguate(unitNameCopy,"none"))
				local ep, gp, name = EPGP:GetEPGP(unitNameCopy)				
				if ep ~= nil or gp ~= nil then
					local pr = VitaPlanner.round(tonumber(ep)/tonumber(gp),3)
					GameTooltip:AddLine("EPGP", 0, 1, 1)
					if tonumber(pr) >= 1 then
						GameTooltip:AddDoubleLine("PR", tostring(pr), 1,1,1, 0,1,0)
					else
						GameTooltip:AddDoubleLine("PR", tostring(pr), 1,1,1, 1,0,0)
					end
					GameTooltip:AddTexture("")
				end
			end
			GameTooltip:AddLine(" ", 1, 1, 1)
			GameTooltip:AddDoubleLine("Client Version", version, 0,1,1, 1,1,1)
		else
			GameTooltip:AddLine(" ", 1, 1, 1)
			GameTooltip:AddLine("OFFLINE", 1, 1, 1)
        end
            GameTooltip:AddLine(" ", 1, 1, 1)
            GameTooltip:AddDoubleLine("Left-Click + Drag", "Move/Swap Unit", 0,1,0, 1,1,1)
            GameTooltip:AddDoubleLine("Right-Click", "Manual Selection", 0,1,0, 1,1,1)
			--GameTooltip:SetUnit(actualUnitID)
		GameTooltip:Show()
	end
end

function VitaPlanner.round(number, decimals)
    return (("%%.%df"):format(decimals)):format(number)
end