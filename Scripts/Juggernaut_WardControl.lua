--<<Advanced healing ward contol>>
--===By Blaxpirit===--

require("libs.ScriptConfig")
require("libs.Utils")

local config = ScriptConfig.new()
config:SetParameter("MoveWard", "G", config.TYPE_HOTKEY)
config:SetParameter("FollowMyHero", "T", config.TYPE_HOTKEY)
config:Load()

local ward_move = config.MoveWard
local ward_follow = config.FollowMyHero

local reg = false
local active = false

local effect = nil

function Key(msg,code)
	if not PlayingGame() or client.chat then return end	
	
	if msg == KEY_UP then
		if code == ward_move then
			local me = entityList:GetMyHero()
			local mp = entityList:GetMyPlayer()
			local cursor = client.mousePosition
			local ward = entityList:GetEntities(function (v) return v.name == "npc_dota_juggernaut_healing_ward" and v.team == me.team and v.alive end)[1]
			local allied_hero = entityList:GetEntities(function (v) return v.hero and v.alive and v.visible and not v:IsIllusion() and v.team == me.team and GetDistance2D(v,cursor) <= 100 end)[1]
			if ward then
				active = false
				mp:Select(ward)
				if allied_hero then 
					mp:Follow(allied_hero)
				else
					mp:Move(client.mousePosition)
				end
				mp:Select(me)
			end
		end
		if code == ward_follow then
			active = not active
		end
	end
end

function Tick(tick)
	if not client.connected or client.loading or client.console then return end
	
	if PlayingGame() and SleepCheck() then
		local me = entityList:GetMyHero()
		if not me then return end
		if me.classId ~= CDOTA_Unit_Hero_Juggernaut then return end
		
		local mp = entityList:GetMyPlayer()

		local ward = entityList:GetEntities(function (v) return v.name == "npc_dota_juggernaut_healing_ward" and v.team == me.team and v.alive end)[1]
		
		if ward and not effect then
			effect = Effect(ward,"range_display")
			effect:SetVector(1,Vector(500,0,0))
		elseif not ward and effect then
			effect = nil
		end		

		if active and ward and GetDistance2D(me,ward) > 5 then
			mp:Select(ward)
			mp:Move(me.position)
			mp:Select(me)
			Sleep(50)
		end
	end
end

function Load()
	if client.connected and not (client.loading or client.console) then
		reg = true
		script:RegisterEvent(EVENT_KEY,Key)
		script:RegisterEvent(EVENT_TICK,Tick)
		script:UnregisterEvent(Load)
	end
end

function GameClose()
	active = false
	effect = nil
	collectgarbage("collect")
	if reg then
		script:UnregisterEvent(Key)
		script:UnregisterEvent(Tick)
		script:RegisterEvent(EVENT_TICK,Load)
		reg = false
	end
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,Load)
