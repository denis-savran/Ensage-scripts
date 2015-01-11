--<<Charge away to the farthest creep>>
--===By Blaxpirit===--

require("libs.Utils")
require("libs.ScriptConfig")

config = ScriptConfig.new()
config:SetParameter("ChargeAway", "D", config.TYPE_HOTKEY)
config:Load()

local hotkey = config.ChargeAway

local reg = false

function Key(msg,code)
	if not PlayingGame() or client.chat then return end
	
	if msg == KEY_UP and code == hotkey then
		local me = entityList:GetMyHero()
		local charge = me:GetAbility(1)
		if me.alive and charge:CanBeCasted() then
			local creeps = entityList:FindEntities(function (v) return (v.classId==CDOTA_BaseNPC_Creep_Lane or v.classId==CDOTA_BaseNPC_Creep_Neutral) and v.alive and v.visible and v.spawned and v.team ~= me.team and v.health >= 250 and v:GetDistance2D(me) > 1500 end)
			table.sort( creeps, function (a,b) return a:GetDistance2D(me) > b:GetDistance2D(me) end )
			me:CastAbility(charge,creeps[1])
		end
	end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me.classId ~= CDOTA_Unit_Hero_SpiritBreaker then 
			script:Disable()
		else
			reg = true
			script:RegisterEvent(EVENT_KEY,Key)
			script:RegisterEvent(EVENT_TICK,Tick)
			script:UnregisterEvent(Load)
		end
	end
end

function GameClose()
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
