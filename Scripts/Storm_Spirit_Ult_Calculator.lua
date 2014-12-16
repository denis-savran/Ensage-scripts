--<<Shows mana left and dmg dealt if use ult on mouse position>>
--===By Blaxpirit===--

require("libs.Utils")
require("libs.ScriptConfig")

local config = ScriptConfig.new()
config:SetParameter("Active", "U", config.TYPE_HOTKEY)
config:SetParameter("ShowDmg", true)
config:Load()

local toggleKey   = config.Active
local ShowDmg     = config.ShowDmg

local active      = true
local myhero 	  = nil
local reg         = false
local monitor     = client.screenSize.x/1600
local F11         = drawMgr:CreateFont("F11","Tahoma",11*monitor,550*monitor) 
local F15         = drawMgr:CreateFont("F15","Tahoma",15*monitor,550*monitor) 
local statusText  = drawMgr:CreateText(3*monitor,107*monitor,-1,"(" .. string.char(toggleKey) .. ") Storm Spirit: On",F11) statusText.visible = false

sleepTick = nil
speed  = {1250,1875,2500}
ultdmg = {8,12,16}

function Key(msg,code)
	if not PlayingGame() or client.chat then return end
	
	if IsKeyDown(toggleKey) then
		active = not active
		if active then
			statusText.text = "(" .. string.char(toggleKey) .. ") Storm Spirit: On"
		else
			statusText.text = "(" .. string.char(toggleKey) .. ") Storm Spirit: Off"
		end
	end	
end
 
function Tick( tick )
	
	if not PlayingGame() then return end
	if sleepTick and sleepTick > tick then return end	
	local me = entityList:GetMyHero()	
	if not me then return end
	local ID = me.classId
	if ID ~= myhero then GameClose() end
		
	if active then
		collectgarbage("collect")
		local cursor = client.mousePosition
		local distance = GetDistance2D(me,cursor)
		local ult = me:GetAbility(4)
	
		if me.alive and ult.level > 0 then
			local mx = client.mouseScreenPosition.x
			local my = client.mouseScreenPosition.y
			local cursorText = drawMgr:CreateText(mx-10,my-32, 0x33CCFFAA, "",F15) cursorText.visible = true
			local mananeeded = math.floor((me.maxMana*0.07 + 15) + (distance/100)*(me.maxMana*0.0075 + 12) - me.manaRegen*(distance/speed[ult.level]+1))
			local manaleft = math.floor(me.mana - mananeeded)
			if manaleft > 0 then
				cursorText.text = "mp:"..manaleft
				sleepTick = GetTick()
			else
				cursorText = drawMgr:CreateText(mx-10,my-32, 0x8B008BFF, "",F15)
				cursorText.text = "not enough"
				sleepTick = GetTick()
			end
			if ShowDmg then 
				local cursorText2 = drawMgr:CreateText(mx-10,my-18, 0xFF0000AA, "",F15) cursorText2.visible = true
				local dmg = math.floor((distance/100)*ultdmg[ult.level]*0.75)
				if manaleft > 0 then
					cursorText2.text = "dmg:"..dmg
					sleepTick = GetTick()
				end				
			end	
		end
	end
end
 
function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me.classId ~= CDOTA_Unit_Hero_StormSpirit then 
			script:Disable()
		else
			reg = true
			statusText.visible = true
			myhero = me.classId
			script:RegisterEvent(EVENT_TICK,Tick)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(Load)
		end
	end
end

function GameClose()
	statusText.visible = false
	collectgarbage("collect")
	if reg then
		myhero = nil
		script:UnregisterEvent(Tick)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,Load)
		reg = false
	end
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,Load)
