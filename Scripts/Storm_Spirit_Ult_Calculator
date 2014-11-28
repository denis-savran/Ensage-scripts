--<<Shows mana that you will have after using ult on mouse position>>
--===By Blaxpirit===--

require("libs.Utils")
require("libs.ScriptConfig")

local config = ScriptConfig.new()
config:SetParameter("Active", "U", config.TYPE_HOTKEY)
config:Load()

local toggleKey   = config.Active
local active       = true
local myhero 	  = nil
local reg         = false
local monitor     = client.screenSize.x/1600
local F11         = drawMgr:CreateFont("F11","Tahoma",11*monitor,550*monitor) 
local F15         = drawMgr:CreateFont("F15","Tahoma",15*monitor,550*monitor) 
local statusText  = drawMgr:CreateText(3*monitor,85*monitor,-1,"(" .. string.char(toggleKey) .. ") Storm Spirit: On",F11) statusText.visible = false

sleepTick = nil
speed = {1250,1875,2500}

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
	
	if ID == myhero then
		statusText.visible = true
	else
		statusText.visible = false
	end
	
	if active then
		local cursor = client.mousePosition
		local distance = GetDistance2D(me,cursor)
		local ult = me:GetAbility(4)
	
		if cursor and me.alive and ult.level > 0 then
			local mx = client.mouseScreenPosition.x
			local my = client.mouseScreenPosition.y
			local cursorText = drawMgr:CreateText(mx-10,my-20, 0xFFFFFF99, "",F15) cursorText.visible = true
			local mananeeded = math.floor((me.maxMana*0.07 + 15) + (distance/100)*(me.maxMana*0.0075 + 12) - me.manaRegen*(distance/speed[ult.level]+1.9))
			local manaleft = math.floor(me.mana - mananeeded)
			if manaleft > 0 then
				cursorText.text = "ml:"..manaleft
				sleepTick = GetTick() + 100
			else
				cursorText.text = "not enough!"
				sleepTick = GetTick() + 100
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
			myhero = me.classId
			script:RegisterEvent(EVENT_TICK,Tick)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(Load)
		end
	end
end

function GameClose()
	collectgarbage("collect")
	if reg then
		myhero = nil
		script:UnregisterEvent(Tick)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,Load)
		reg = false
		statusText.visible = false
	end
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,Load)
