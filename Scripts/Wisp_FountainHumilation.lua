--<<Teleports pudge to enemy base to kill enemy hero just after his respawn>>
--===By Blaxpirit===--

require("libs.Utils")
require("libs.ScriptConfig")
require("libs.SideMessage")

local config = ScriptConfig.new()
config:SetParameter("Key", "T", config.TYPE_HOTKEY)
config:SetParameter("Auto", false)
config:Load()

local toggleKey = config.Key
local auto = config.Auto

local reg = false
local active = false
local x_ratio = client.screenSize.x/1600 
local F11 = drawMgr:CreateFont("F11","Tahoma",11*x_ratio,550*x_ratio)
local F15 = drawMgr:CreateFont("F15","Tahoma",15*x_ratio,550*x_ratio)
local statusText = drawMgr:CreateText(3*x_ratio,118*x_ratio,-1,"(" .. string.char(toggleKey) .. ") Pudge's humiliation: off",F11) statusText.visible = false

local add_effects = true
local waitspot_effect = nil
local relocatespot_effect = nil

function Key(msg,code)
	if not PlayingGame() or client.chat then return end
	
	if not auto and IsKeyDown(toggleKey) then
		active = not active
	end
end
 
function Tick( tick )
	if not PlayingGame() then return end
	
	local me = entityList:GetMyHero()
	if not me then return end
	if me.classId ~= CDOTA_Unit_Hero_Wisp then return end
	
	if auto or active then
		statusText.text = "(" .. string.char(toggleKey) .. ") Wisp's humiliation: On"
	else
		statusText.text = "(" .. string.char(toggleKey) .. ") Wisp's humiliation: Off"
	end
	
	local mp = entityList:GetMyPlayer()
	
	local wait_position, relocate_position
	if mp.team == LuaEntity.TEAM_DIRE then
		wait_position = Vector(-5908,-7003,261)
		relocate_position = Vector(-5899.43,-7124.89,261)
	elseif mp.team == LuaEntity.TEAM_RADIANT then	
		wait_position = Vector(5939,6947,256)
		relocate_position = Vector(5926.07,7161.16,256)
	end

	if add_effects then
		waitspot_effect = Effect(wait_position,"blueTorch_flame")
		waitspot_effect:SetVector(0,wait_position)
		relocatespot_effect = Effect(relocate_position,"fire_camp_01")
		relocatespot_effect:SetVector(0,relocate_position)
		add_effects = false
	end
	
	local pudge = entityList:GetEntities({classId=CDOTA_Unit_Hero_Pudge,team=me.team})[1]
	local tether = me:FindAbility("wisp_tether")
	local spirits = me:FindAbility("wisp_spirits")
	--local spirits_in = me:FindAbility("wisp_spirits_in")
	local relocate = me:FindAbility("wisp_relocate")
	local tether_buff = me:FindModifier("modifier_wisp_tether_haste")
	--local relocate_buff = me:FindModifier("modifier_wisp_relocate_thinker")
	
	local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,team = 5-me.team,alive=false})
	table.sort( enemies, function (a,b) return a.respawnTime < b.respawnTime end )
	for i,v in ipairs(enemies) do
		if v.respawnTime <= 15 and v.respawnTime > 14.9 and pudge and SleepCheck("message") then
			GenerateSideMessage(me.name,"  Get ready for Humilation!")
			Sleep(1000,"message")
		end
	end
	
	if me.alive and pudge and pudge.alive and not me:IsChanneling() and GetDistance2D(me,pudge) < tether.castRange then
		for i,v in ipairs(enemies) do
			if v.respawnTime > 3 and v.respawnTime <= 10 then
				if (active or auto) and relocate:CanBeCasted() and SleepCheck("relocate") then
					me:CastAbility(relocate,relocate_position)
					active = false
					Sleep(1000,"relocate")
				end
				if not tether_buff and tether:CanBeCasted() and relocate.cd > relocate:GetCooldown(relocate.level) - 1 and SleepCheck("tether") then
					me:CastAbility(tether,pudge)
					Sleep(1000,"tether")
				end
				if not isPosEqual(me.position,wait_position,10) and GetDistance2D(me,wait_position) < 300 and SleepCheck("move") then
					mp:Move(wait_position)
					Sleep(1000,"move")
				end 
				if isPosEqual(me.position,wait_position,10) and spirits:CanBeCasted() and SleepCheck("spirits") then
					me:CastAbility(spirits)
					--me:CastAbility(spirits_in)
					Sleep(1000,"spirits")
				end
			end
		end
	end
end

function isPosEqual(v1, v2, d)
	return (v1-v2).length <= d
end

function GenerateSideMessage(heroname,msg)
	local sidemsg = sideMessage:CreateMessage(300*x_ratio,60*x_ratio,0x111111C0,0x444444FF,200,1500)
	sidemsg:AddElement(drawMgr:CreateRect(10*x_ratio,10*x_ratio,72*x_ratio,40*x_ratio,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/heroes_horizontal/"..heroname:gsub("npc_dota_hero_",""))))
	sidemsg:AddElement(drawMgr:CreateText(85*x_ratio,20*x_ratio,-1,"" .. msg,F15))
end
 
function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me.classId ~= CDOTA_Unit_Hero_Wisp then 
			script:Disable()
		else
			reg = true
			statusText.visible = true
			script:RegisterEvent(EVENT_TICK,Tick)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(Load)
		end
	end
end

function GameClose()
	statusText.visible = false
	waitspot_effect = nil
	relocatespot_effect = nil
	collectgarbage("collect")
	if reg then
		script:UnregisterEvent(Tick)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,Load)
		reg = false
	end
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,Load)
