local me, ns = ...
ns.Configure()
local addon=addon --#addon
local over=over --#over
local _G=_G
local GSF=GSF
local G=C_Garrison
local pairs=pairs
local format=format
local strsplit=strsplit
local generated
local GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY=GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY
local GARRISON_CURRENCY=GARRISON_CURRENCY
local GARRISON_SHIP_OIL_CURRENCY=GARRISON_SHIP_OIL_CURRENCY
local GARRISON_FOLLOWER_MAX_LEVEL=GARRISON_FOLLOWER_MAX_LEVEL
local LE_FOLLOWER_TYPE_GARRISON_6_0=LE_FOLLOWER_TYPE_GARRISON_6_0
local LE_FOLLOWER_TYPE_SHIPYARD_6_2=LE_FOLLOWER_TYPE_SHIPYARD_6_2
local module=addon:NewSubClass('ShipYard') --#Module
local GameTooltip=GameTooltip
local GarrisonShipyardMapMissionTooltip=GarrisonShipyardMapMissionTooltip

function sprint(nome,this,...)

--@debug@
print(nome,this:GetName(),...)
--@end-debug@
end
function module:Test()

--@debug@
print("test")
--@end-debug@
end
function module:OnInitialize()
	self:SafeSecureHook("GarrisonFollowerButton_UpdateCounters")
	self:SafeSecureHook(GSF,"OnClickMission","HookedGSF_OnClickMission")
	self:SafeSecureHook("GarrisonShipyardMapMission_OnEnter")
	self:SafeSecureHook("GarrisonShipyardMapMission_OnLeave")
	local ref=GSFMissions.CompleteDialog.BorderFrame.ViewButton

--@debug@
print(ref)
--@end-debug@
	local bt = CreateFrame('BUTTON','GCQuickShipMissionCompletionButton', ref, 'UIPanelButtonTemplate')
	bt.missionType=LE_FOLLOWER_TYPE_SHIPYARD_6_2
	bt:SetWidth(300)
	bt:SetText(L["Garrison Comander Quick Mission Completion"])
	bt:SetPoint("CENTER",0,-50)
	addon:ActivateButton(bt,"MissionComplete",L["Complete all missions without confirmation"])
	if IsAddOnLoaded("MasterPlanA") then
		self:SafeSecureHook("GarrisonShipyardMap_UpdateMissions") -- low efficiency, but survives MasterPlan
	end
	self:SafeSecureHook("GarrisonShipyardMap_SetupBonus")
	self:SafeHookScript(GSF,"OnShow","Setup",true)
	self:SafeHookScript(GSF.MissionTab.MissionList.CompleteDialog,"OnShow",true)
	self:SafeHookScript(GSF.MissionTab,"OnShow",true)
	self:SafeHookScript(GSF.FollowerTab,"OnShow",true)
	--GarrisonShipyardFrameFollowersListScrollFrameButton1
	--GarrisonShipyardMapMission1
--@end-debug@
end
---
--Invoked on every mission display, only for available missions
--
local i=0

function module:HookedGarrisonShipyardMap_SetupBonus(missionList,frame,mission)
	if not GSF:IsShown() then return end
	addon:AddExtraData(mission)
	local perc=addon:MatchMaker(mission)
	local addendum=frame.GcAddendum
	if not addendum then
		if mission.inProgress then return end
		i=i+1
		addendum=CreateFrame("Frame",nil,frame)
		addendum:SetPoint("TOPLEFT",frame,"TOPRIGHT",-15,0)
		addendum:SetFrameStrata("MEDIUM")
		addendum:SetFrameLevel(GSF:GetFrameLevel()+5)
		AddBackdrop(addendum)
		addendum:SetBackdropColor(0,0,0,0.5)
		addendum:SetWidth(50)
		addendum:SetHeight(25)
		addendum.chance=addendum:CreateFontString(nil,"TOOLTIP","GameFontHighlightMedium")
		addendum.chance:SetAllPoints()
		addendum.chance:SetJustifyH("CENTER")
		addendum.chance:SetJustifyV("CENTER")
		frame.GcAddendum=addendum
	end
	if mission.inProgress then addendum:Hide() return end
	addendum:Show()
	addendum.chance:SetFormattedText("%d%%",perc)
	addendum.chance:SetTextColor(self:GetDifficultyColors(perc))
	local cost=mission.cost
	local currency=mission.costCurrencyTypesID
	if cost and currency then
		local _,available=GetCurrencyInfo(currency)
		if cost>available then
			addendum:SetBackdropBorderColor(1,0,0)
		else
			addendum:SetBackdropBorderColor(0,1,0)
		end
	else
		addendum:SetBackdropBorderColor(1,1,1)

	end
	--addendum.expire:SetText(mission.class)
	--addendum.duration:SetText(mission.duration)
end
function module:HookedGarrisonShipyardMap_UpdateMissions()
	local list = GSF.MissionTab.MissionList
	for i=1,#list.missions do
		local frame = list.missionFrames[i]
		if not self:IsHooked(frame,"PostClick") then
			self:SafeHookScript(frame,"PostClick","ScriptMapButtonOnClick",true)
		end
	end

end
function module:ScriptMapButtonOnClick(this)
	self:FillMissionPage(this.info)
end
function module:HookedGSF_OnClickMission(this,missionInfo)
	self:FillMissionPage(missionInfo)
end
function module:HookedGarrisonFollowerButton_UpdateCounters(gsf,frame,follower,showcounter,lastupdate)
	if follower.followerTypeID~=LE_FOLLOWER_TYPE_SHIPYARD_6_2 then return end
	if not frame.GCXp then
		frame.GCXp=frame:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
	end
	if follower.isCollected and follower.quality < GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY  then
		frame.GCXp:SetPoint("TOPRIGHT",frame,"TOPRIGHT",0,-5)
		frame.GCXp:SetFormattedText("Xp to go: %d",follower.levelXP-follower.xp)
		frame.GCXp:Show()
	else
		frame.GCXp:Hide()
	end
--@debug@
	--print(follower)
--@end-debug@
end


function module:Setup(this,...)

--@debug@
print("Doing one time initialization for",this:GetName(),...)
--@end-debug@
	self:SafeSecureHookScript("GarrisonShipyardFrame","OnShow")
	GSF:EnableMouse(true)
	GSF:SetMovable(true)
	GSF:RegisterForDrag("LeftButton")
	GSF:SetScript("OnDragStart",function(frame)if (self:GetBoolean("MOVEPANEL")) then frame:StartMoving() end end)
	GSF:SetScript("OnDragStop",function(frame) frame:StopMovingOrSizing() end)
end
function module:ScriptGarrisonShipyardFrame_OnShow()

--@debug@
print("Doing all time initialization")
--@end-debug@
end
function module:HookedGarrisonShipyardMapMission_OnLeave()

--@debug@
print("OnLeave")
--@end-debug@
	GameTooltip:Hide()
end
function module:HookedGarrisonShipyardMapMission_OnEnter(frame)
	local g=GameTooltip
	g:SetOwner(GarrisonShipyardMapMissionTooltip, "ANCHOR_NONE")
	g:SetPoint("TOPLEFT",GarrisonShipyardMapMissionTooltip,"BOTTOMLEFT")
	local mission=frame.info
	local missionID=mission.missionID
	addon:AddFollowersToTooltip(missionID,LE_FOLLOWER_TYPE_SHIPYARD_6_2)
--@debug@
	g:AddDoubleLine("MissionID:",missionID)
--@end-debug@
	g:Show()
	if g:GetWidth() < GarrisonShipyardMapMissionTooltip:GetWidth() then
		g:SetWidth(GarrisonShipyardMapMissionTooltip:GetWidth())
	end
end
function module:OpenLastTab()
--@debug@
print("Should restore tab")
--@end-debug@
end
--[[ Follower
displayHeight = 0.25
followerTypeID = 2
iLevel = 600
isCollected = true
classAtlas = Ships_TroopTransport-List
garrFollowerID = 0x00000000000001E2
displayScale = 95
level = 100
quality = 3
portraitIconID = 0
isFavorite = false
xp = 1500
texPrefix = Ships_TroopTransport
className = Transport
classSpec = 53
name = Chen's Favorite Brew
followerID = 0x00000000011E4D8F
height = 0.30000001192093
displayID = 63894
scale = 110
levelXP = 40000
--]]
--[[ Mission
followerTypeID = 2
description = Hellscream has posted a sub near the Horde's main base on Ashran. Take that sub out. Alliance, that means you, too. Factional hatreds have no place here.
cost = 150
adjustedPosX = 798
duration = 8 hr
adjustedPosY = -246
durationSeconds = 28800
state = -2
inProgress=false
typePrefix = ShipMissionIcon-Treasure
typeAtlas = ShipMissionIcon-Treasure-Mission
offerTimeRemaining = 19 days 1 hr
level = 100
offeredGarrMissionTextureID = 0
offerEndTime = 1681052.25
mapPosY = -246
type = Ship-Treasure
name = Warspear Fishing
iLevel = 0
numRewards = 1
rewards = [table: 000000004D079210]
hasBonusEffect = false
numFollowers = 2
costCurrencyTypesID = 1101
followers = [table: 000000004D0791C0]
missionID = 563
canStart = false
location = [ph]
isRare = false
mapPosX = 798
locPrefix = GarrMissionLocation-TannanSea
--]]
--view mission button GSF.MissionTab.MissionList.CompleteDialog.BorderFrame.ViewButton