--<<ShadowFiend Combo and Raze helper>>
--===By Blaxpirit===--

require("libs.Utils")
require("libs.ScriptConfig")
require("libs.TargetFind")

--Config
config = ScriptConfig.new()
config:SetParameter("Hotkey", "F", config.TYPE_HOTKEY)
config:SetParameter("RazeKey", "D", config.TYPE_HOTKEY)
config:SetParameter("HideKey", "G", config.TYPE_HOTKEY)
config:SetParameter("SkillBuild", 1)
config:SetParameter("TextPositionX", 5)
config:SetParameter("TextPositionY", 40)
config:Load()

local Hotkey = config.Hotkey
local RazeKey  = config.RazeKey
local HideKey = config.HideKey
local skillbuild = config.SkillBuild
local play = false
local active = false
local Ractive = false
local unbinded = false

--Text on your screen
local x,y = config:GetParameter("TextPositionX"), config:GetParameter("TextPositionY")
local monitor = client.screenSize.x/1600
local F14 = drawMgr:CreateFont("F14","Tahoma",16*monitor,750*monitor) 
local F15 = drawMgr:CreateFont("F14","Tahoma",15*monitor,550*monitor) 
local statusText = drawMgr:CreateText(x*monitor,y*monitor,0xC92828FF,"ShadowFiend Script",F14) statusText.visible = false
local statusText2 = drawMgr:CreateText((x)*monitor,(y+17)*monitor,0xF5AE33FF,"HOLD: ''"..string.char(Hotkey).."'' for Ult Combo",F15) statusText2.visible = false
local statusText3 = drawMgr:CreateText((x)*monitor,(y+32)*monitor,0xF5AE33FF,"HOLD: ''"..string.char(RazeKey).."'' for Auto Raze",F15) statusText3.visible = false
local statusText4 = drawMgr:CreateText((x)*monitor,(y+47)*monitor,0xFFFFFFFFF,"Press:  ''"..string.char(HideKey).."'' to hide this message for the rest of the game.",F15) statusText4.visible = false
--local statusText5 = drawMgr:CreateText((x+90)*monitor,(y+62)*monitor,0xFFFFFFFFF,"",F15) statusText4.visible = false

--=====================<< SkillBuilds >>=======================
--1 - raze, 4 - necromastery, 5 - presence of a dark lord, 6 - ult, 7 - attribute bonus
local sb1 = {4,1,1,4,1,4,1,4,6,5,6,5,5,5,7,6,7,7,7,7,7,7,7,7,7}
local sb2 = {4,5,4,5,4,5,4,5,6,7,6,7,7,7,7,6,7,7,7,7,7,1,1,1,1}
--=========================<< END >>===========================

function Key(msg,code)
	if client.chat or client.console or client.loading then return end
	if code == Hotkey then
		active = (msg == KEY_DOWN)
	end
	if code == RazeKey then
		Ractive = (msg == KEY_DOWN)
	end
	if code == HideKey and statusText.visible == true then
	    statusText.visible = false
	    statusText2.visible = false
	    statusText4.visible = false
	end
end

function Tick(tick)
	if not SleepCheck() then return end
	
	local me = entityList:GetMyHero()
	local mp = entityList:GetMyPlayer()
	
	--Unbind standart key binds
	local sel = mp.selection[1]
	if sel and sel.name == "npc_dota_hero_nevermore" and not unbinded then
		client:ExecuteCmd("unbind q")
		client:ExecuteCmd("unbind w")
		client:ExecuteCmd("unbind e")
		unbinded = true
	elseif sel and sel.name ~= "npc_dota_hero_nevermore" and unbinded then
		client:ExecuteCmd("bind q \"dota_ability_quickcast 0\"")
		client:ExecuteCmd("bind w \"dota_ability_quickcast 1\"")
		client:ExecuteCmd("bind e \"dota_ability_quickcast 2\"")
		unbinded = false
	end
	
	--Choosing skillbuild 
	if skillbuild == 1 then
		sb = sb1
	elseif skillbuild == 2 then
		sb = sb2
	end
	
	--Auto ability learn
	local points = me.abilityPoints		
	if points > 0 then
		local prev = SelectUnit(me)
		mp:LearnAbility(me:GetAbility(sb[me.level+1-points]))
		SelectBack(prev)
		Sleep(100)
	end
	
	--Stuff we need for combo
	local eul = me:FindItem("item_cyclone")
	local blink = me:FindItem("item_blink")
	local phase = me:FindItem("item_phase_boots")
	local ult = me:GetAbility(6)
	
	--Eul combo
	if active then
        local target = targetFind:GetClosestToMouse(100)
		if target then
			local eulmodif = target:FindModifier("modifier_eul_cyclone")
			if eul and eul:CanBeCasted() and not eulmodif then
				me:CastAbility(eul,target)
				Sleep(250)
				return
			end
			if eulmodif then
				if GetDistance2D(me,target)/me.movespeed < 0.8 and SleepCheck("move") then
					mp:Move(target.position)
					Sleep(2000,"move")
				elseif blink and blink:CanBeCasted() and (eulmodif.remainingTime < 1.80) and SleepCheck("move") then
					me:CastAbility(blink,target.position)
					Sleep(100)
					return
				end
				if ult and ult:CanBeCasted() and (eulmodif.remainingTime < 1.70) and GetDistance2D(me,target) <= 50 then
					me:CastAbility(ult)
					Sleep(250)
					return
				end
			end
		end
	end
	
	--Smart razes
	if not client.chat and sel and sel.name == "npc_dota_hero_nevermore" and SleepCheck("razes") then
		local cursor = client.mousePosition
		local distance = GetDistance2D(me,cursor)
		statusText5.text = ""..me:FindRelativeAngle(cursor)
		--[[ Q hotkey - Shadowraze(near) ]]
		if IsKeyDown(81) then
			local raze = me:GetAbility(1)
			if raze:CanBeCasted() then
				--if distance <= 450 and distance >= 0 then
					if me:FindRelativeAngle(cursor) >= 0.1 or me:FindRelativeAngle(cursor) <= -0.1 then
						mp:Move((cursor - me.position) * 50 / GetDistance2D(cursor,me) + me.position)
					end
					if me:FindRelativeAngle(cursor) <= 0.1 and me:FindRelativeAngle(cursor) >= -0.1 then
						me:CastAbility(raze)
					end
					Sleep(250,"razes")
				--[[else
					mp:Move((cursor - me.position) * (GetDistance2D(me,cursor) - 425) / GetDistance2D(cursor,me) + me.position)
					me:CastAbility(raze,true)
					Sleep(200,"razes")
				end]]
			end
		end
		--[[ W hotkey - Shadowraze(medium) ]]
		if IsKeyDown(87) then
			local raze = me:GetAbility(2)
			if raze:CanBeCasted() then
				--if distance <= 700 and distance >= 200 then
					if me:FindRelativeAngle(cursor) >= 0.1 or me:FindRelativeAngle(cursor) <= -0.1 then
						mp:Move((cursor - me.position) * 50 / GetDistance2D(cursor,me) + me.position)
					end
					if me:FindRelativeAngle(cursor) <= 0.1 and me:FindRelativeAngle(cursor) >= -0.1 then
						me:CastAbility(raze)
					end
					Sleep(250,"razes")
				--[[else
					mp:Move((cursor - me.position) * (GetDistance2D(me,cursor) - 675) / GetDistance2D(cursor,me) + me.position)
					me:CastAbility(raze,true)
					Sleep(200,"razes")
				end]]
			end
		end
		--[[ E hotkey - Shadowraze(far) ]]
		if IsKeyDown(69) then
			local raze = me:GetAbility(3)
			if raze:CanBeCasted() then
				--if distance <= 950 and distance >= 450 then
					if me:FindRelativeAngle(cursor) >= 0.15 or me:FindRelativeAngle(cursor) <= -0.15 then
						mp:Move((cursor - me.position) * 50 / GetDistance2D(cursor,me) + me.position)
					end
					if me:FindRelativeAngle(cursor) < 0.15 and me:FindRelativeAngle(cursor) > -0.15 then
						me:CastAbility(raze)
					end
					Sleep(250,"razes")
				--[[else
					mp:Move((cursor - me.position) * (GetDistance2D(me,cursor) - 925) / GetDistance2D(cursor,me) + me.position)
					me:CastAbility(raze,true)
					Sleep(200,"razes")
				end]]
			end
		end
	end
	
	--Auto razes 
	if Ractive then
	    local target = targetFind:GetClosestToMouse(100)
		if target then
			local position
			local distance = GetDistance2D(me,SFrange(target,me)) --(me,SFrange(target,me)) GetDistance2D(me,target)
			if distance <= 400 and distance >= 0 then
				CastAutoRaze(1,target,me)
			end
			if distance <= 650 and distance >= 250 then
				CastAutoRaze(2,target,me)
			end
			if distance <= 900 and distance >= 500 then
				CastAutoRaze(3,target,me)
			end
		end
    end
end

function CastAutoRaze(number,target,me)
	local raze = me:GetAbility(number)
	if raze and raze:CanBeCasted() and me:CanCast() then
		me:Attack(target)
		me:CastAbility(raze)
		Sleep(200)
	end
end

function SFrange(ent,me)
	if ent.activity == LuaEntityNPC.ACTIVITY_MOVE and ent:CanMove() then
		local turn = TurnRate(ent.position,me)/1000
		return Vector(ent.position.x + ent.movespeed * (0.67+turn) * math.cos(ent.rotR), ent.position.y + ent.movespeed* (0.67+turn) * math.sin(ent.rotR), ent.position.z)
	else
		return ent.position
	end
end

function TurnRate(pos,me)
	local angel = ((((math.atan2(pos.y-me.position.y,pos.x-me.position.x) - me.rotR + math.pi) % (2 * math.pi)) - math.pi) % (2 * math.pi)) * 180 / math.pi
	if angel > 180 then 
		return ((360 - angel)/2)
	else
		return (angel/2)
	end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Nevermore then
			script:Disable()
		else
			play = true
			statusText.visible = true
			statusText2.visible = true
			statusText3.visible = true
			statusText4.visible = true
			--statusText5.visible = true
			script:RegisterEvent(EVENT_TICK,Tick)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(Load)
		end
	end
end

function GameClose()
	collectgarbage("collect")
	if play then
	    statusText.visible = false
		statusText2.visible = false
		statusText3.visible = false
		statusText4.visible = false
		--statusText5.visible = false
		script:UnregisterEvent(Main)
		script:UnregisterEvent(Key)
		play = false
	end
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,Load)
