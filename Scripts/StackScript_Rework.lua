-- Stackscript rework by blaxpirit123

--[[		Config			]]
-- config can be found in Scripts\config\StackScript_Rework.txt

--[[		Code			]]
require("libs.ScriptConfig")
require("libs.SideMessage")

config = ScriptConfig.new()
config:SetParameter("Hotkey", "O", config.TYPE_HOTKEY)
config:SetParameter("SetQuantityToZero", "C",config.TYPE_HOTKEY )
config:SetParameter("IncreaseNumber", "V",config.TYPE_HOTKEY )
config:Load()

hotkey = config.Hotkey
settozero = config.SetQuantityToZero
increasenumber = config.IncreaseNumber
x,y = 5, 50

local monitor = client.screenSize.x/1600
local F15 = drawMgr:CreateFont("F15","Tahoma",15*monitor,550*monitor)

r_startTime = 48.5  -- game time seconds when start to stack (from wait point)
r_satyr_startTime = 48
d_startTime = 48.6 
d_satyr_startTime = 48.7                  
stackQuantity = 1  -- number of stacks

stack_route_radiant = {Vector(-3025,47,256), Vector(-7258,-6756,270), Vector(-2144,-480,256)}  -- triangle route for radiant ( 1:pull point, 2: fountain, 3: wait point )
stack_route_radiant_satyr = {Vector(-3025,47,256), Vector(-6769,-6088,261), Vector(-2144,-480,256)}  -- triangle route for radiant ( 1:pull point, 2: fountain, 3: wait point )

stack_route_dire = {Vector(4562,-1960,127), Vector(6930,6300,256), Vector(5083,-1433,127)}  -- triangle route for dire ( 1:pull point, 2: fountain, 3: wait point )
stack_route_dire_satyr = {Vector(4562,-1960,127), Vector(6620,5518,255), Vector(5083,-1433,127)}  -- triangle route for dire ( 1:pull point, 2: fountain, 3: wait point )


 
activated = true -- toggle by hotkey if activated
creepHandle = nil -- current creep
font = drawMgr:CreateFont("stackfont","Arial",14,500) -- font for drawing
if string.byte("A") <= hotkey and hotkey <= string.byte("Z") then
	defaultText = "StackScript: select your creep and press \""..string.char(hotkey).."\"." -- default text to display
else
	defaultText = "StackScript: select your creep and press keycode \""..hotkey.."\"." -- default text to display
end
text = drawMgr:CreateText(x,y,-1,defaultText,font) -- text object to draw
route = nil -- currently active route
ordered = false -- only order once
registered = false -- only register our callbacks once


function Key(msg,code)
	if msg ~= KEY_UP or client.chat or not client.connected or client.loading then
		return
	end

	if code == hotkey then
		activated = not activated
		if activated then

			-- check if we're ingame and already have a valid team
			local player = entityList:GetMyPlayer()
			if not player or player.team == LuaEntity.TEAM_NONE then
				activated = false
				return
			end

			-- check if the player has currently selected a controllable creep
			local selection = player.selection
			if #selection ~= 1 or (selection[1].type ~= LuaEntity.TYPE_CREEP and selection[1].type ~= LuaEntity.TYPE_NPC) or not selection[1].controllable then
				activated = false
				return
			end
			
			creepHandle = selection[1].handle
			local creep = entityList:GetEntity(creepHandle)
			
			if player.team == LuaEntity.TEAM_DIRE then
				if creep.name == "npc_dota_neutral_satyr_hellcaller" then
					route = stack_route_dire_satyr
					startTime = d_satyr_startTime
				else
					route = stack_route_dire
					startTime = d_startTime
				end
			elseif player.team == LuaEntity.TEAM_RADIANT then
				if creep.name == "npc_dota_neutral_satyr_hellcaller" then
					route = stack_route_radiant_satyr
					startTime = r_satyr_startTime
				else
					route = stack_route_radiant
					startTime = r_startTime
				end
			end

			-- maybe we're an observer only, so there's no valid route
			if not route then 
				activated = false
				return
			end

			player:Move(route[3])
			text.text = "StackScript: moving creep to pull location. ".."q: "..stackQuantity
		else
			text.text = defaultText
		end
	end
	if code == settozero then
		stackQuantity = 0
		text.text = "StackScript: you have changed the number of stacks to 0."
	elseif code == increasenumber then
		stackQuantity = stackQuantity + 1
		if stackQuantity > 4 then 
			stackQuantity = 4
		end
		text.text = "StackScript: you have changed the number of stacks to "..stackQuantity
	end
end

sleeptick = 0
function Tick(tick)
	if sleeptick > tick or not activated or not creepHandle then
		return
	end
	sleeptick = tick + 250

	local player = entityList:GetMyPlayer()
	if not player then
		return
	end

	-- check if our creep is still existing and alive
	local creep = entityList:GetEntity(creepHandle)
	if not creep or not creep.alive then
		text.text = "StackScript: creep dead. ".."q: "..stackQuantity
		activated = false
		creepHandle = nil
		return
	end
	-- do the stacking if not paused, correct timing and creep is already @waiting position
	if not ordered and (client.gameTime % 60 >= startTime and client.gameTime % 60 <= startTime + 1) and not client.paused and isPosEqual(creep.position,route[3],2) then
		text.text = "StackScript: stack ordered. ".."q: "..stackQuantity
		ordered = true

		local selection = player.selection
		-- select our pull creep
		player:Select(creep)
		-- move the triangle route
		player:Move(route[1],false)
		player:Move(route[2],true)
		player:Move(route[3],true)
		-- reselect our former selection
		player:Select(selection[1])
		for i = 2, #selection, 1 do
			player:SelectAdd(selection[i])
		end
		-- increase stack number
		stackQuantity = stackQuantity + 1
	elseif ordered and (client.gameTime % 60 < startTime) then
		ordered = false
		-- stack quantity check
		if stackQuantity == 4 then 
			text.text = "StackScript: farm your stacks and press hotkey. ".."q: "..stackQuantity
			GenerateSideMessage(entityList:GetMyHero().name,"  Time to make some Real Money!")
			stackQuantity = 0
			activated = false
			creepHandle = nil
		else 
			text.text = "StackScript: waiting. ".."q: "..stackQuantity
		end
	end
end

-- check if creep is already @ wait position
function isPosEqual(v1, v2, d)
	return (v1-v2).length <= d
end

-- reset all stuff after leaving a game
function Close()
	text.text = defaultText
	text.visible = false
	creepHandle = nil
	route = nil
	activated = false
	ordered = false

	script:UnregisterEvent(EVENT_TICK)
	script:UnregisterEvent(EVENT_KEY)
	registered = false
end

-- register our callbacks
function Load()
	if registered then return end

	script:RegisterEvent(EVENT_TICK,Tick)
	script:RegisterEvent(EVENT_KEY,Key)
	text.visible = true
	registered = true
end

function GenerateSideMessage(heroname,msg)
	local sidemsg = sideMessage:CreateMessage(300*monitor,60*monitor,0x111111C0,0x444444FF,200,1500)
	sidemsg:AddElement(drawMgr:CreateRect(10*monitor,10*monitor,72*monitor,40*monitor,0xFFFFFFFF,drawMgr:GetTextureId("NyanUI/heroes_horizontal/"..heroname:gsub("npc_dota_hero_",""))))
	sidemsg:AddElement(drawMgr:CreateText(85*monitor,20*monitor,-1,"" .. msg,F15))
end

-- Callbacks are only needed while ingame...
script:RegisterEvent(EVENT_CLOSE,Close)
script:RegisterEvent(EVENT_LOAD,Load)

-- load if already ingame
if client.connected and not client.loading then
	Load()
end
