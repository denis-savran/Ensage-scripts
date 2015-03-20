--<<Advanced healing ward contol>>
--===By Blaxpirit===--

require("libs.Utils")
require("libs.ScriptConfig")

local config = ScriptConfig.new()
config:SetParameter("MoveWard", "G", config.TYPE_HOTKEY)
config:SetParameter("FollowMyHero", "T", config.TYPE_HOTKEY)
config:Load()

local ward_move = config.MoveWard
local ward_follow = config.FollowMyHero

local play = false
local active = false

local effect = nil

function Key(msg,code)

	if client.chat or msg ~= KEY_UP then return end

	local me = entityList:GetMyHero()
	local ward = entityList:GetEntities({classId = CDOTA_BaseNPC_Additive, controllable = true, alive = true, team = me.team})[1]
	
	if code == ward_move then
		if ward then		
			local cursor = client.mousePosition
			local allied_hero = entityList:GetEntities(function (v) return v.hero and v.alive and v.visible and v.team == me.team and not v:IsIllusion() and GetDistance2D(v,cursor) <= 100 end)[1]
			if allied_hero then
				ward:Follow(allied_hero)
			else
				ward:Move(cursor)
			end
			active = false
		end
	elseif code == ward_follow then
		active = not active
	end

end

function Tick(tick)

	if not (client.console or SleepCheck()) then return end

	local me = entityList:GetMyHero()
	local ward = entityList:GetEntities({classId = CDOTA_BaseNPC_Additive, controllable = true, alive = true, team = me.team})[1]
	
	if ward then
		if not effect then
			effect = Effect(ward,"range_display")
			effect:SetVector(1,Vector(500,0,0))
		end
		if active and GetDistance2D(me,ward) > 5 then
			ward:Move(me.position)
		end
	elseif effect then
		effect = nil
		collectgarbage("collect")
	end		
	
	Sleep(100)
	
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me.classId == CDOTA_Unit_Hero_Juggernaut then		
			play = true
			script:RegisterEvent(EVENT_KEY,Key)
			script:RegisterEvent(EVENT_TICK,Tick)
			script:UnregisterEvent(Load)
		else
			script:Disable()
		end
	end
end

function GameClose()
	if play then
		script:UnregisterEvent(Key)
		script:UnregisterEvent(Tick)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
end

script:RegisterEvent(EVENT_TICK,Load)
script:RegisterEvent(EVENT_CLOSE,GameClose)
