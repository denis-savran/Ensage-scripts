--<<Auto disable of blinkers and initiators>>
--===By Blaxpirit===--

require("libs.Utils")
require("libs.ScriptConfig")
require("libs.Initiators")
require("libs.DisableSpells")

local config = ScriptConfig.new()
config:SetParameter("Active", "U", config.TYPE_HOTKEY)
config:SetParameter("RightSide", false)
config:Load()

local toggleKey   = config.Active
local RightSide   = config.RightSide
local active      = false
local reg         = false
local monitor     = client.screenSize.x/1600
local indent 	  = 255
local F11         = drawMgr:CreateFont("F11","Tahoma",11*monitor,550*monitor) 
local statusText  = drawMgr:CreateText(3*monitor,74*monitor,-1,"(" .. string.char(toggleKey) .. ") Auto Disable: Blink",F11) statusText.visible = false
local activated   = 0

local hero = {} local icon = {}
 
sleepTick = nil
 
function Key(msg,code)
	if not PlayingGame() or client.chat then return end
	
	if IsKeyDown(toggleKey) then
		active = not active
		if active then
			statusText.text = "(" .. string.char(toggleKey) .. ") Auto Disable: All"
		else
			statusText.text = "(" .. string.char(toggleKey) .. ") Auto Disable: Blink"
		end
	end
	
	for i = 1,5 do
		if IsMouseOnButton(indent*monitor-3+i*27,11*monitor-1,20,20) then
			if msg == LBUTTON_DOWN and hero[i] == nil then
				hero[i] = i
			elseif msg == LBUTTON_DOWN and hero[i] ~= nil then
				hero[i] = nil
			end
		end
	end
end
 
function IsMouseOnButton(x,y,h,w)
	local mx = client.mouseScreenPosition.x
	local my = client.mouseScreenPosition.y
	return mx > x and mx <= x + w and my > y and my <= y + h
end
 
function Tick( tick )
	if not PlayingGame() then return end
	if sleepTick and sleepTick > tick then return end	
	me = entityList:GetMyHero() if not me then return end
	
	if RightSide then 
		indent = 1330
	end
	
	local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,team = 5-me.team,illusion=false})
	table.sort( enemies, function (a,b) return a.playerId < b.playerId end )
	
	for i =1,#enemies do
		local v = enemies[i]
		target = enemies[i]
		local IV  = v:IsInvul()
		local MI  = v:IsMagicImmune()
		local LS  = v:IsLinkensProtected()
		local ST  = v:IsStunned()
		local HEX = v:IsHexed()
		local SI  = v:IsSilenced()
		local DA  = v:IsDisarmed()
		local invis = me:IsInvisible()
		local chanel = me:IsChanneling()
		local items = me:CanUseItems()
		local blink = v:FindItem("item_blink")
		local forcestaff = v:FindItem("item_force_staff")
		local DP_activated = v:FindModifier("modifier_slark_dark_pact")
		local DP_pulses = v:FindModifier("modifier_slark_dark_pact_pulses")
	
		if me.alive and v.alive and v.visible then
			if items and not (IV or MI or invis or chanel or DP_activated or DP_pulses) then
				if (blink and blink.cd > 11) or (forcestaff and forcestaff.cd > 18.6) then
					UseMedalliontarget()
					UseRodtarget()
				elseif active then
					UseMedalliontarget()
					UseRodtarget()
				elseif Initiation[v.name] then
					if v:FindSpell(Initiation[v.name].Spell) and v:FindSpell(Initiation[v.name].Spell).level > 0 then
						local iSpell = v:FindSpell(Initiation[v.name].Spell)
						local iLevel = iSpell.level 
						if iSpell and iSpell.cd > iSpell:GetCooldown(iLevel) - 1.6 then
							UseMedalliontarget()
							UseRodtarget()
						end
					end
				end
			end
		end

		if me.alive and v.alive and v.visible and not hero[i] then
			if items and not (IV or MI or LS or ST or HEX or SI or DA or invis or chanel or DP_activated or DP_pulses) then
				if (blink and blink.cd > 11) or (forcestaff and forcestaff.cd > 18.6) then
					UseHex()
					UseSheepStickTarget()
					UseImmediateStun()
					UseAbyssaltarget()
					UseOrchidtarget()
					UseSkysSeal()
					UsePucksRift()
					UseHeroSpell()
					UseEulScepterTarget()
					UseAstral()
					UseHalberdtarget()
					UseEtherealtarget()
				elseif active then
					UseHex()
					UseSheepStickTarget()
					UseImmediateStun()
					UseAbyssaltarget()
					UseOrchidtarget()
					UseSkysSeal()
					UsePucksRift()
					UseEulScepterTarget()
					UseAstral()
				elseif Initiation[v.name] then
					if v:FindSpell(Initiation[v.name].Spell) and v:FindSpell(Initiation[v.name].Spell).level > 0 then
						local iSpell = v:FindSpell(Initiation[v.name].Spell)
						local iLevel = iSpell.level 
						if iSpell and iSpell.cd > iSpell:GetCooldown(iLevel) - 1.6 then
							UseHex()
							UseSheepStickTarget()
							UseImmediateStun()
							UseAbyssaltarget()
							UseOrchidtarget()
							UseSkysSeal()
							UsePucksRift()
							UseHeroSpell()
							UseEulScepterTarget()
							UseAstral()
							UseHalberdtarget()
							UseEtherealtarget()
						end
					end
				end
			end
		end
		activated = 0

		if not icon[i] then icon[i] = {}
			icon[i].board = drawMgr:CreateRect(indent*monitor-3+i*27,11*monitor-1,20,20,0x8B008BFF)
			icon[i].back = drawMgr:CreateRect(indent*monitor-2+i*27,11*monitor,18,18,0x000000FF)
			icon[i].mini = drawMgr:CreateRect(indent*monitor-2+i*27,11*monitor,18,18,0x000000FF)
		end
		
		if not hero[i] then
			icon[i].back.textureId = drawMgr:GetTextureId("NyanUI/spellicons/doom_bringer_empty1")
			icon[i].mini.textureId = drawMgr:GetTextureId("NyanUI/miniheroes/"..v.name:gsub("npc_dota_hero_",""))
		else
			icon[i].mini.textureId = drawMgr:GetTextureId("NyanUI/spellicons/doom_bringer_empty1")
		end	
	end
end
 
function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me then
			script:Disable()
		else
			reg = true
			statusText.visible = true
			script:RegisterEvent(EVENT_TICK,Tick)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(Load)
		end
	end
end

function GameClose()
	statusText.visible = false
	hero = {} icon = {}
	collectgarbage("collect")
	if reg then
		script:UnregisterEvent(Tick)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,Load)
		reg = false
	end
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,Load)
    
--functions for item or skill usage------------------------------------------------------------
    
function UseEulScepterTarget()
	local disable = me:FindItem("item_cyclone")
	if activated == 0 then
		if disable and disable.cd == 0 and disable:CanBeCasted() then
			if target and GetDistance2D(me,target) < disable.castRange then
				me:CastAbility(disable,target)
				activated = 1
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end
   
function UseSheepStickTarget()
	local disable = me:FindItem("item_sheepstick")
	if activated == 0 then
		if disable and disable.cd == 0 and disable:CanBeCasted() then
			if target and GetDistance2D(me,target) < disable.castRange then
				me:CastAbility(disable,target)
				activated = 1
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end
    
function UseOrchidtarget()
	local disable = me:FindItem("item_orchid")
	if activated == 0 then
		if disable and disable.cd == 0 and disable:CanBeCasted() then
			if target and GetDistance2D(me,target) < disable.castRange then
				me:CastAbility(disable,target)
				activated = 1
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end
    
function UseAbyssaltarget()
	local disable = me:FindItem("item_abyssal_blade")
	if activated == 0 then
		if disable and disable.cd == 0 and disable:CanBeCasted() then
			if target and GetDistance2D(me,target) < disable.castRange then
				me:CastAbility(disable,target)
				activated = 1 
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end
	
function UseHalberdtarget()
	local disable = me:FindItem("item_heavens_halberd")
	if activated == 0 then
		if disable and disable.cd == 0 and disable:CanBeCasted() then
			if target and GetDistance2D(me,target) < disable.castRange then
				me:CastAbility(disable,target)
				activated = 1
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end
	
function UseEtherealtarget()
	local disable = me:FindItem("item_ethereal_blade")
	if activated == 0 then
		if disable and disable.cd == 0 and disable:CanBeCasted() then
			if target and GetDistance2D(me,target) < disable.castRange then
				me:CastAbility(disable,target)
				activated = 1
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end

function UseRodtarget()
	local disable = me:FindItem("item_rod_of_atos")
	if disable and disable.cd == 0 and disable:CanBeCasted() then
		if target and GetDistance2D(me,target) < disable.castRange then
			me:CastAbility(disable,target)
			sleepTick = GetTick() + 100
			return
		end
	end
end

function UseMedalliontarget()
	local disable = me:FindItem("item_medallion_of_courage")
	if me.health/me.maxHealth > 0.1 then
		if disable and disable.cd == 0 and disable:CanBeCasted() then
			if target and GetDistance2D(me,target) < disable.castRange then
				me:CastAbility(disable,target)
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end

function UseHex()
	if activated == 0 then
		local hex_lion  = me:FindSpell("lion_voodoo")
		local hex_rasta = me:FindSpell("shadow_shaman_voodoo")
		if hex_lion then
			local disable = hex_lion
		elseif hex_rasta then
			local disable = hex_rasta
		end
		if disable and disable.level > 0 and me:CanCast() and disable:CanBeCasted() then
			if target and GetDistance2D(me,target) < disable.castRange then
				me:SafeCastAbility(disable,target)
				activated = 1
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end

function UseAstral()
	if activated == 0 then
		local astral_od = me:FindSpell("obsidian_destroyer_astral_imprisonment")
		local astral_sd = me:FindSpell("shadow_demon_disruption")
		if alstral_destr then
			local disable = alstral_destr
		elseif astral_sd then
			local disable = astral_sd
		end
		if disable and disable.level > 0 and me:CanCast() and disable:CanBeCasted() then
			if target and GetDistance2D(me,target) < disable.castRange  then
				me:SafeCastAbility(disable,target)
				activated = 1
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end

function UseImmediateStun()
	if activated == 0 then
		local tlknz = me:FindSpell("rubick_telekinesis")
		local dtail = me:FindSpell("dragon_knight_dragon_tail")
		if tlknz then
			local disable = tlknz
		elseif dtail then
			local disable = dtail
		end
		if disable and disable.level > 0 and me:CanCast() and disable:CanBeCasted() then
			if target and GetDistance2D(me,target) < disable.castRange then
				me:SafeCastAbility(disable,target)
				activated = 1
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end

function UseSkysSeal()
	if activated == 0 then
		local disable = me:FindSpell("skywrath_mage_ancient_seal")
		if disable and disable.level > 0 and me:CanCast() and disable:CanBeCasted() then
			if target and GetDistance2D(me,target) < disable.castRange then
				me:SafeCastAbility(disable,target)
				activated = 1
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end

function UsePucksRift()
	if activated == 0 then
		local disable = me:FindSpell("puck_waning_rift")
		if disable and disable.level > 0 and me:CanCast() and disable:CanBeCasted() then
			if target and GetDistance2D(me,target) < 400 then
				me:SafeCastAbility(disable)
				activated = 1
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end

function UseHeroSpell()
	if activated == 0 then
		if DisableSpell[me.name] then
			if me:FindSpell(DisableSpell[me.name].Spell) and me:FindSpell(DisableSpell[me.name].Spell).level > 0 then
				local disable = me:FindSpell(DisableSpell[me.name].Spell)
				if disable and disable.level > 0 and me:CanCast() and disable:CanBeCasted() then
					if target and GetDistance2D(me,target) < disable.castRange then
						me:SafeCastAbility(disable,target)
						activated = 1
						sleepTick = GetTick() + 100
						return
					end
				end
			end
		end
	end
end
