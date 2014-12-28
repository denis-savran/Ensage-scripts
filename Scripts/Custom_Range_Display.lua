require("libs.ScriptConfig")

config = ScriptConfig.new()
config:SetParameter("Hotkey", "B", config.TYPE_HOTKEY)
config:SetParameter("Range", 700)
config:SetParameter("Extend", "H", config.TYPE_HOTKEY)
config:SetParameter("Decrease", "J", config.TYPE_HOTKEY)
config:Load()

hotkey = config.Hotkey
range = config.Range
extend = config.Extend
decrease = config.Decrease

local monitor = client.screenSize.x/1600
local F11 = drawMgr:CreateFont("F11","Tahoma",11*monitor,550*monitor) 
local statusText = drawMgr:CreateText(4*monitor,51*monitor,-1,"Custom range: off",F11) statusText.visible = false

local reg = false
local activated = false
local effect = nil

function Key(msg,code)
	if not PlayingGame() or client.chat then return end
	--turning on and off
	if msg == KEY_UP and code == hotkey then
		activated = not activated 
		if activated then
			-- add effect
			effect = Effect(me,"range_display")
			effect:SetVector(1,Vector(range,0,0))
			statusText.text = "Current range: "..range
		else
			RemoveEffect()
			statusText.text = "Custom range: off"
		end
	end
	if activated then
		collectgarbage("collect")
		if msg == KEY_UP then
			 -- Editing range 
			if code == extend then
				range = range+25
				effect = Effect(me,"range_display")
				effect:SetVector(1,Vector(range,0,0))
				statusText.text = "Current range: "..range
			end	
			if code == decrease then
				range = range-25
				effect = Effect(me,"range_display")
				effect:SetVector(1,Vector(range,0,0))
				statusText.text = "Current range: "..tostring(range)
			end
		end
	end
	
end
 
function RemoveEffect()
	effect = nil
	collectgarbage("collect")
end
 
function Load()
	if PlayingGame() then
		me = entityList:GetMyHero()
		if not me then 
			script:Disable()
		else
			reg = true
			statusText.visible = true
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(Load)
		end
	end
end

function GameClose()
	statusText.visible = false
	effect = nil
	collectgarbage("collect")
	if reg then
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,Load)
		reg = false
	end
end 
 
script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,Load)
