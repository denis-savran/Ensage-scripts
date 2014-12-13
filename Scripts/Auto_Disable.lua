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
		local invis  = me:IsInvisible()
		local chanel = me:IsChanneling()
		local items  = me:CanUseItems()
		local blink  = v:FindItem("item_blink")
		
		if me.alive and v.alive and v.visible then
			if items and not (IV or MI or invis or chanel) then
				if blink and blink.cd > 11 then
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
			if items and not (IV or MI or LS or ST or HEX or SI or DA or invis or chanel) then
				if blink and blink.cd > 11 then
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
	local euls = me:FindItem("item_cyclone")
	if activated == 0 then
		if euls and euls.cd == 0 then
			if target and GetDistance2D(me,target) < 700 then
				me:CastAbility(euls,target)
				activated = 1
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end
   
function UseSheepStickTarget()
	local sheep = me:FindItem("item_sheepstick")
	if activated == 0 then
		if sheep and sheep.cd == 0 then
			if target and GetDistance2D(me,target) < 800 then
				me:CastAbility(sheep,target)
				activated = 1
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end
    
function UseOrchidtarget()
	local orchid = me:FindItem("item_orchid")
	if activated == 0 then
		if orchid and orchid.cd == 0 then
			if target and GetDistance2D(me,target) < 900 then
				me:CastAbility(orchid,target)
				activated = 1
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end
    
function UseAbyssaltarget()
	local abyssal_blade = me:FindItem("item_abyssal_blade")
	if activated == 0 then
		if abyssal_blade and abyssal_blade.cd == 0 then
			if target and GetDistance2D(me,target) < 140 then
				me:CastAbility(abyssal_blade,target)
				activated = 1 
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end
	
function UseHalberdtarget()
	local heavens_halberd = me:FindItem("item_heavens_halberd")
	if activated == 0 then
		if heavens_halberd and heavens_halberd.cd == 0 then
			if target and GetDistance2D(me,target) < 600 then
				me:CastAbility(heavens_halberd,target)
				activated = 1
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end
	
function UseEtherealtarget()
	local ethereal_blade = me:FindItem("item_ethereal_blade")
	if activated == 0 then
		if ethereal_blade and ethereal_blade.cd == 0 then
			if target and GetDistance2D(me,target) < 800 then
				me:CastAbility(ethereal_blade,target)
				activated = 1
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end

function UseRodtarget()
	local rod_of_atos = me:FindItem("item_rod_of_atos")
	if rod_of_atos and rod_of_atos.cd == 0 then
		if target and GetDistance2D(me,target) < 1200 then
			me:CastAbility(rod_of_atos,target)
			sleepTick = GetTick() + 100
			return
		end
	end
end

function UseMedalliontarget()
	local medallion = me:FindItem("item_medallion_of_courage")
	if me.health/me.maxHealth > 0.1 then
		if medallion and medallion.cd == 0 then
			if target and GetDistance2D(me,target) < 1000 then
				me:CastAbility(medallion,target)
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
			hex = hex_lion
		elseif hex_rasta then
			hex = hex_rasta
		end
		if hex and hex.level > 0 and hex:CanBeCasted() and me:CanCast() then
			if target and GetDistance2D(me,target) < 500 then
				me:SafeCastAbility(hex,target)
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
			local alstral = alstral_destr
		elseif astral_sd then
			local astral = astral_sd
		end
		if astral and astral.level > 0 and astral:CanBeCasted() and me:CanCast() then
			if target and GetDistance2D(me,target) < astral.castRange  then
				me:SafeCastAbility(astral,target)
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
			local stun = tlknz
		elseif dtail then
			local stun = dtail
		end
		if stun and stun.level > 0 and stun:CanBeCasted() and me:CanCast() then
			if target and GetDistance2D(me,target) < stun.castRange then
				me:SafeCastAbility(stun,target)
				activated = 1
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end

function UseSkysSeal()
	if activated == 0 then
		local silence = me:FindSpell("skywrath_mage_ancient_seal")
		if silence and silence.level > 0 and silence:CanBeCasted() and me:CanCast() then
			if target and GetDistance2D(me,target) < silence.castRange then
				me:SafeCastAbility(silence,target)
				activated = 1
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end

function UsePucksRift()
	if activated == 0 then
		local silence = me:FindSpell("puck_waning_rift")
		if silence and silence.level > 0 and silence:CanBeCasted() and me:CanCast() then
			if target and GetDistance2D(me,target) < 400 then
				me:SafeCastAbility(silence)
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
				local dSpell = me:FindSpell(DisableSpell[me.name].Spell)
				if dSpell and dSpell.level > 0 and dSpell:CanBeCasted() and me:CanCast() then
					if target and GetDistance2D(me,target) < dSpell.castRange then
						me:SafeCastAbility(dSpell,target)
						activated = 1
						sleepTick = GetTick() + 100
						return
					end
				end
			end
		end
	end
end
