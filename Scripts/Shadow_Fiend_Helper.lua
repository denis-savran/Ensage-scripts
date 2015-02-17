--<<ShadowFiend Combo and Raze helper>>
--===By Blaxpirit and Nova===--
--Auto coil prediction by D.L.

require("libs.Utils")
require("libs.ScriptConfig")
require("libs.TargetFind")

--Config
config = ScriptConfig.new()
config:SetParameter("Hotkey", "F", config.TYPE_HOTKEY)
config:SetParameter("RazeKey", "D", config.TYPE_HOTKEY)
config:SetParameter("UseEthereal", "G", config.TYPE_HOTKEY)
config:SetParameter("ShowText", true)
config:SetParameter("SkillBuild", 1)
config:SetParameter("TextPositionX", 5)
config:SetParameter("TextPositionY", 40)
config:Load()

local Hotkey = config.Hotkey
local RazeKey = config.RazeKey
local UseEthereal = config.UseEthereal
local ShowText = config.ShowText
local skillbuild = config.SkillBuild

--Text on your screen
local x,y = config:GetParameter("TextPositionX"), config:GetParameter("TextPositionY")
local monitor = client.screenSize.x/1600
local F14 = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor)
local F15 = drawMgr:CreateFont("F15","Tahoma",15*monitor,550*monitor)
local statusText = drawMgr:CreateText(x*monitor,y*monitor,0xC92828FF,"ShadowFiend Script",F14) statusText.visible = false
local statusText2 = drawMgr:CreateText((x)*monitor,(y+17)*monitor,0xF5AE33FF,"HOLD: ''"..string.char(Hotkey).."'' for Ult Combo",F15) statusText2.visible = false
local statusText3 = drawMgr:CreateText((x)*monitor,(y+32)*monitor,0xF5AE33FF,"HOLD: ''"..string.char(RazeKey).."'' for Auto Raze",F15) statusText3.visible = false
local etherealText = drawMgr:CreateText((x)*monitor,(y+70)*monitor,0xFFFFFFFFF,"Ethereal: On",F15) etherealText.visible = false

local play = false
local active = false
local Ractive = false
local disableAutoAttack = false
local shotgunned = false
local etherealactive = true
local hero = {}

local wavedamage = {80,120,160}

--=====================<< SkillBuilds >>=======================
--1 - raze, 4 - necromastery, 5 - presence of a dark lord, 6 - ult, 7 - attribute bonus
local sb1 = {4,1,1,4,1,4,1,4,6,5,6,5,5,5,7,6,7,7,7,7,7,7,7,7,7}
local sb2 = {4,5,4,5,4,5,4,5,6,7,6,7,7,7,7,6,7,7,7,7,7,1,1,1,1} -- no coils build 
--=========================<< END >>===========================

function Key(msg,code)
	if client.chat or client.console or client.loading then return end
	if code == Hotkey then
		active = (msg == KEY_DOWN)
	end
	if code == RazeKey then
		Ractive = (msg == KEY_DOWN)
	end
	if code == UseEthereal and msg == KEY_UP then
	    etherealactive = not etherealactive
		if etherealactive then
			etherealText.text = "Ethereal: On"
		else
			etherealText.text = "Ethereal: Off"
		end
	end
end

function Tick(tick)
	if not SleepCheck() then return end
	
	--Auto attack toggle
	if not SleepCheck("auto_attack") and disableAutoAttack then -- disabling 
		client:ExecuteCmd("dota_player_units_auto_attack_after_spell 0")
		disableAutoAttack = false
	elseif SleepCheck("auto_attack") and not disableAutoAttack then -- enabling 
		client:ExecuteCmd("dota_player_units_auto_attack_after_spell 1")
		disableAutoAttack = true
	end
	
	local me = entityList:GetMyHero()
	local mp = entityList:GetMyPlayer()
	
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
	local ethereal = me:FindItem("item_ethereal_blade")
	local ult = me:GetAbility(6)
	
	if ethereal then
		etherealText.visible = true
	else
		etherealText.visible = false
	end
	
	--Eul combo
	if active then
        local target = targetFind:GetClosestToMouse(100)
		if target then
			local eulmodif = target:FindModifier("modifier_eul_cyclone")
			local etherealmodif = target:FindModifier("modifier_item_ethereal_blade_slow")
			if eul and eul:CanBeCasted() and not eulmodif then
				if etherealactive and ethereal and ethereal:CanBeCasted() then
					me:CastAbility(ethereal,target)
					shotgunned = true
					Sleep(10,"ethereal")
				end
				if SleepCheck("ethereal") then
					if etherealmodif and shotgunned then
						me:CastAbility(eul,target)
						shotgunned = false
					elseif not shotgunned then
						me:CastAbility(eul,target)
					end
				end
				Sleep(2500,"auto_attack")
				Sleep(100)
				return
			end
			if eulmodif then
				if GetDistance2D(me,target)/me.movespeed < 0.8 and SleepCheck("move") and SleepCheck("blink") then
					me:SafeCastItem("item_phase_boots")
					mp:Move(target.position)
					Sleep(2000,"move")
				elseif blink and blink:CanBeCasted() and (eulmodif.remainingTime < 1.85) and SleepCheck("move") then
					me:CastAbility(blink,target.position)
					Sleep(2000,"blink")
					Sleep(100)
					return
				end
				if ult and ult:CanBeCasted() and (eulmodif.remainingTime < 1.70) and GetDistance2D(me,target) <= 50 then
					me:CastAbility(ult)
					Sleep(100)
					return
				end
			end
		end
	end
	
	--Auto razes 
	if Ractive then
	    local target = targetFind:GetClosestToMouse(100)
		if target then
			local position
			local distance = GetDistance2D(me,SFrange(target,me)) 
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
	
	--Damage calculator
	if ult.level > 0 then
		local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,illusion=false,team=me:GetEnemyTeam()})
		local stacks = me:FindModifier("modifier_nevermore_necromastery")
		local numberofstacks = 0
		if stacks then
			numberofstacks = me:FindModifier("modifier_nevermore_necromastery").stacks
		end
		for i,v in ipairs(enemies) do
			local OnScreen = client:ScreenPosition(v.position)
			if OnScreen then
				if v.healthbarOffset ~= -1 then
					local hand = v.handle
					if hand ~= me.handle then
						if not hero[hand] then
							hero[hand] = drawMgr:CreateText(25*monitor,-55*monitor, 0x00FFFFAA, "",F14) 
							hero[hand].visible = false 
							hero[hand].entity = v 
							hero[hand].entityPosition = Vector(0,0,v.healthbarOffset)
						end
						if v.alive and v.visible  then
							local totaldamage = wavedamage[ult.level]*numberofstacks/2 + 50
							local magicdmgreduction = (1 - v.magicDmgResist)
							if ethereal and not v:DoesHaveModifier("modifier_item_ethereal_blade_slow") then
								totaldamage = totaldamage + 2*me.agilityTotal + 75
								magicdmgreduction = (1 + 0.4)*magicdmgreduction
							end
							local damage = totaldamage*magicdmgreduction
							hero[hand].visible = true
							if v.health - damage < 0 then
								hero[hand].text = "Killable"
							else
								hero[hand].text = "HP left:"..v.health - damage
							end
						elseif hero[hand].visible then
							hero[hand].visible = false
						end
					end
				end
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
			active = false
			Ractive = false
			disableAutoAttack = false
			shotgunned = false
			etherealactive = true
			hero = {}
			if ShowText then
				statusText.visible = true
				statusText2.visible = true
				statusText3.visible = true
			end
			etherealText.visible = false
			script:RegisterEvent(EVENT_TICK,Tick)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(Load)
		end
	end
end

function GameClose()
	collectgarbage("collect")
	if play then
		active = false
		Ractive = false
		disableAutoAttack = false
		shotgunned = false
		etherealactive = true
		hero = {}
	    statusText.visible = false
		statusText2.visible = false
		statusText3.visible = false
		etherealText.visible = false
		script:UnregisterEvent(Tick)
		script:UnregisterEvent(Key)
		play = false
	end
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,Load)
