--<<Hooks enemy hero just after his respawn>>
--===By Blaxpirit===--

require("libs.Utils")
require("libs.ScriptConfig")
require("libs.SideMessage")

local config = ScriptConfig.new()
config:SetParameter("Key", "T", config.TYPE_HOTKEY)
config:SetParameter("Auto", true)
config:Load()

local toggleKey = config.Key
local auto = config.Auto

local reg = false
local active = false
local x_ratio = client.screenSize.x/1600 
local F11 = drawMgr:CreateFont("F11","Tahoma",11*x_ratio,550*x_ratio)
local F15 = drawMgr:CreateFont("F15","Tahoma",15*x_ratio,550*x_ratio)
local statusText = drawMgr:CreateText(3*x_ratio,107*x_ratio,-1,"(" .. string.char(toggleKey) .. ") Pudge's humiliation: off",F11) statusText.visible = false

local add_effects = true
local waitspot_effect = nil
local hookspot_effect = nil

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
	if me.classId ~= CDOTA_Unit_Hero_Pudge then return end
	
	if auto or active then
		statusText.text = "(" .. string.char(toggleKey) .. ") Pudge's humiliation: On"
	else
		statusText.text = "(" .. string.char(toggleKey) .. ") Pudge's humiliation: Off"
	end
	
	local mp = entityList:GetMyPlayer()
	
	local wait_position, hook_position, delay 
	if mp.team == LuaEntity.TEAM_DIRE then
		wait_position = Vector(-5984,-6880,261)
		hook_position = Vector(-7190,-6698,398)
		delay = 1
	elseif mp.team == LuaEntity.TEAM_RADIANT then	
		wait_position = Vector(6048,7008,256)
		hook_position = Vector(6919.72,6388.1,384)
		delay = 0.92
	end

	if add_effects then
		waitspot_effect = Effect(wait_position,"blueTorch_flame")
		waitspot_effect:SetVector(0,wait_position)
		hookspot_effect = Effect(hook_position,"fire_camp_01")
		hookspot_effect:SetVector(0,hook_position)
		add_effects = false
	end
	
	local wisp = entityList:GetEntities({classId=CDOTA_Unit_Hero_Wisp,team=me.team})[1]
	
	if active or auto then
		local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,team = 5-me.team,alive=false})
		table.sort( enemies, function (a,b) return a.respawnTime < b.respawnTime end )
		for i,v in ipairs(enemies) do
			if v.respawnTime <= 15 and v.respawnTime > 14.9 and wisp and SleepCheck("message") then
				GenerateSideMessage(me.name,"  Get ready for Humilation!")
				Sleep(1000,"message")
			end
			
			local hook = me:GetAbility(1)
			if me.alive and not me:IsChanneling() and hook:CanBeCasted() and GetDistance2D(me,wait_position) < 300 then
				if v.respawnTime <= 9 and v.respawnTime > 2 and not isPosEqual(me.position,wait_position,10) and SleepCheck("move") then
					mp:Move(wait_position)
					Sleep(1000,"move")
				end
				if v.respawnTime <= 9 and v.respawnTime > 2 and isPosEqual(me.position,wait_position,10) and me:GetTurnTime(hook_position) ~= 0 and SleepCheck("changeangle") then 
					me:CastAbility(hook,hook_position)
					mp:Stop()
					Sleep(1000,"changeangle")
				end
				if v.respawnTime > 0 and v.respawnTime < delay and SleepCheck("hook") then
					me:CastAbility(hook,hook_position)
					active = false
					Sleep(1000,"hook")
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
		if me.classId ~= CDOTA_Unit_Hero_Pudge then 
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
	hookspot_effect = nil
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
