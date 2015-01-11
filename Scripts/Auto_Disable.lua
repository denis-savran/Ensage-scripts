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
local x_ratio     = client.screenSize.x/1600
local indent 	  = 255
local F11         = drawMgr:CreateFont("F11","Tahoma",11*x_ratio,550*x_ratio) 
local statusText  = drawMgr:CreateText(3*x_ratio,74*x_ratio,-1,"(" .. string.char(toggleKey) .. ") Auto Disable: Blink",F11) statusText.visible = false
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
		if IsMouseOnButton(indent*x_ratio-3+i*27,11*x_ratio-1,20,20) then
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
					UseMedalliontarget(v)
					UseRodtarget(v)
				elseif active then
					UseMedalliontarget(v)
					UseRodtarget(v)
				elseif Initiation[v.name] then
					local iSpell = v:FindSpell(Initiation[v.name].Spell)
					if iSpell and iSpell.level ~= 0 and iSpell.cd > iSpell:GetCooldown(iSpell.level) - 1.6 then
						UseMedalliontarget(v)
						UseRodtarget(v)
					end
				end
			end
		end

		if me.alive and v.alive and v.visible and not hero[i] then
			if items and not (IV or MI or LS or ST or HEX or SI or DA or invis or chanel or DP_activated or DP_pulses) then
				if (blink and blink.cd > 11) or (forcestaff and forcestaff.cd > 18.6) then
					UseHex(v)
					UseSheepStickTarget(v)
					UseImmediateStun(v)
					UseAbyssaltarget(v)
					UseBatriderLasso(v)
					UseLegionDuel(v)
					UseOrchidtarget(v)
					UseSkysSeal(v)
					UsePucksRift(v)
					UseHeroSpell(v)
					UseEulScepterTarget(v)
					UseAstral(v)
					UseHalberdtarget(v)
					UseEtherealtarget(v)
				elseif active then
					UseHex(v)
					UseSheepStickTarget(v)
					UseImmediateStun(v)
					UseAbyssaltarget(v)
					UseBatriderLasso(v)
					UseLegionDuel(v)
					UseOrchidtarget(v)
					UseSkysSeal(v)
					UsePucksRift(v)
					UseEulScepterTarget(v)
					UseAstral(v)
				elseif Initiation[v.name] then
					local iSpell = v:FindSpell(Initiation[v.name].Spell)
					if iSpell and iSpell.level ~= 0 and iSpell.cd > iSpell:GetCooldown(iSpell.level) - 1.6 then
						UseHex(v)
						UseSheepStickTarget(v)
						UseImmediateStun(v)
						UseAbyssaltarget(v)
						UseBatriderLasso(v)
						UseOrchidtarget(v)
						UseSkysSeal(v)
						UsePucksRift(v)
						UseHeroSpell(v)
						UseEulScepterTarget(v)
						UseAstral(v)
						UseHalberdtarget(v)
						UseEtherealtarget(v)
					end
				end
			end
		end
		activated = 0

		if not icon[i] then icon[i] = {}
			icon[i].board = drawMgr:CreateRect(indent*x_ratio-3+i*27,11*x_ratio-1,20,20,0x8B008BFF)
			icon[i].back = drawMgr:CreateRect(indent*x_ratio-2+i*27,11*x_ratio,18,18,0x000000FF)
			icon[i].mini = drawMgr:CreateRect(indent*x_ratio-2+i*27,11*x_ratio,18,18,0x000000FF)
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
    
function UseEulScepterTarget(target)
	if activated == 0 then
		local disable = me:FindItem("item_cyclone")
		if disable and disable:CanBeCasted() then
			if target and GetDistance2D(me,target) < disable.castRange then
				me:CastAbility(disable,target)
				activated = 1
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end
   
function UseSheepStickTarget(target)
	if activated == 0 then
		local disable = me:FindItem("item_sheepstick")
		if disable and disable:CanBeCasted() then
			if target and GetDistance2D(me,target) < disable.castRange then
				me:CastAbility(disable,target)
				activated = 1
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end
    
function UseOrchidtarget(target)
	if activated == 0 then
		local disable = me:FindItem("item_orchid")
		if disable and disable:CanBeCasted() then
			if target and GetDistance2D(me,target) < disable.castRange then
				me:CastAbility(disable,target)
				activated = 1
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end
    
function UseAbyssaltarget(target)
	if activated == 0 then
		local disable = me:FindItem("item_abyssal_blade")
		if disable and disable:CanBeCasted() then
			if target and GetDistance2D(me,target) < disable.castRange then
				me:CastAbility(disable,target)
				activated = 1 
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end
	
function UseHalberdtarget(target)
	if activated == 0 then
		local disable = me:FindItem("item_heavens_halberd")
		if disable and disable:CanBeCasted() then
			if target and GetDistance2D(me,target) < disable.castRange then
				me:CastAbility(disable,target)
				activated = 1
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end
	
function UseEtherealtarget(target)
	if activated == 0 then
		local disable = me:FindItem("item_ethereal_blade")
		if disable and disable:CanBeCasted() then
			if target and GetDistance2D(me,target) < disable.castRange then
				me:CastAbility(disable,target)
				activated = 1
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end

function UseRodtarget(target)
	local disable = me:FindItem("item_rod_of_atos")
	if disable and disable:CanBeCasted() then	
		if target and GetDistance2D(me,target) < disable.castRange then
			me:CastAbility(disable,target)
			sleepTick = GetTick() + 100
			return
		end
	end
end

function UseMedalliontarget(target)
	if me.health/me.maxHealth > 0.1 then
		local disable = me:FindItem("item_medallion_of_courage")
		if disable and disable:CanBeCasted() then
			if target and GetDistance2D(me,target) < disable.castRange then
				me:CastAbility(disable,target)
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end

function UseHex(target)
	if activated == 0 then
		local disable = nil
		local hex_lion  = me:FindSpell("lion_voodoo")
		local hex_rasta = me:FindSpell("shadow_shaman_voodoo")
		if hex_lion then
			disable = hex_lion
		elseif hex_rasta then
			disable = hex_rasta
		end
		if disable and disable:CanBeCasted() and me:CanCast() then
			if target and GetDistance2D(me,target) < disable.castRange then
				me:SafeCastAbility(disable,target)
				activated = 1
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end

function UseAstral(target)
	if activated == 0 then
		local disable = nil
		local astral_od = me:FindSpell("obsidian_destroyer_astral_imprisonment")
		local astral_sd = me:FindSpell("shadow_demon_disruption")
		if alstral_destr then
			disable = alstral_destr
		elseif astral_sd then
			disable = astral_sd
		end
		if disable and disable:CanBeCasted() and me:CanCast() then
			if target and GetDistance2D(me,target) < disable.castRange  then
				me:SafeCastAbility(disable,target)
				activated = 1
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end

function UseImmediateStun(target)
	if activated == 0 then
		local disable = nil
		local tlknz = me:FindSpell("rubick_telekinesis")
		local dtail = me:FindSpell("dragon_knight_dragon_tail")
		if tlknz then
			disable = tlknz
		elseif dtail then
			disable = dtail
		end
		if disable and disable:CanBeCasted() and me:CanCast() then
			if target and GetDistance2D(me,target) < disable.castRange then
				me:SafeCastAbility(disable,target)
				activated = 1
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end

function UseBatriderLasso(target)
	if activated == 0 then
		local disable = me:FindSpell("batrider_flaming_lasso")
		if disable and disable:CanBeCasted() and me:CanCast() then
			if target and GetDistance2D(me,target) < 150 then
				me:SafeCastAbility(disable,target)
				activated = 1
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end

function UseLegionDuel(target)
	if activated == 0 then
		local disable = me:FindSpell("legion_commander_duel")
		if disable and disable:CanBeCasted() and me:CanCast() then
			if target and GetDistance2D(me,target) < 150 then
				me:SafeCastAbility(disable,target)
				activated = 1
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end

function UseSkysSeal(target)
	if activated == 0 then
		local disable = me:FindSpell("skywrath_mage_ancient_seal")
		if disable and disable:CanBeCasted() and me:CanCast() then
			if target and GetDistance2D(me,target) < disable.castRange then
				me:SafeCastAbility(disable,target)
				activated = 1
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end

function UsePucksRift(target)
	if activated == 0 then
		local disable = me:FindSpell("puck_waning_rift")
		if disable and disable:CanBeCasted() and me:CanCast() then
			if target and GetDistance2D(me,target) < 400 then
				me:SafeCastAbility(disable)
				activated = 1
				sleepTick = GetTick() + 100
				return
			end
		end
	end
end

function UseHeroSpell(target)
	if activated == 0 then
		if DisableSpell[me.name] then
			local disable = me:FindSpell(DisableSpell[me.name].Spell)
			if disable and disable:CanBeCasted() and me:CanCast() then
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
