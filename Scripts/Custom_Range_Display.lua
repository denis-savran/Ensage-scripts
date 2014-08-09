require("libs.ScriptConfig")

config = ScriptConfig.new()
config:SetParameter("Hotkey", "B", config.TYPE_HOTKEY)
config:SetParameter("Range", 400)
config:SetParameter("Extend", "H", config.TYPE_HOTKEY)
config:SetParameter("Decrease", "J", config.TYPE_HOTKEY)
config:Load()

hotkey = config.Hotkey
range = 400
extend = config.Extend
decrease = config.Decrease

local xx,yy = 10,client.screenSize.y/25.714
local F14 = drawMgr:CreateFont("f14","Tahoma",14,550)
local statusText = drawMgr:CreateText(xx-5,yy+28,-1,"Custom range: off",F14)

activated = false
effect = nil

function Key(msg,code)
	-- check if ingame
    if not client.connected or client.loading or client.console then
    	return
    end
	
    -- check if we already picked a hero
    local me = entityList:GetMyHero()
    if not me then
    	return
    end
	
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
 
script:RegisterEvent(EVENT_CLOSE,RemoveEffect) -- remove effect on game close
script:RegisterEvent(EVENT_KEY,Key)
