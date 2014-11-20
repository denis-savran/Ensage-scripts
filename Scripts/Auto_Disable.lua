--<<Auto disable of blinkers and initiators>>

require("libs.Utils")
require("libs.ScriptConfig")
require("libs.Stuff")

local config = ScriptConfig.new()
config:SetParameter("Active", "U", config.TYPE_HOTKEY)
config:Load()

local toggleKey   = config.Active
local activ       = false
local reg         = false
local monitor     = client.screenSize.x/1600
local F14         = drawMgr:CreateFont("F14","Tahoma",11*monitor,550*monitor) 
local statusText  = drawMgr:CreateText(3*monitor,75*monitor,-1,"(" .. string.char(toggleKey) .. ") Auto Disable: Blink",F14) statusText.visible = true
local activated   = 0
 
sleepTick = nil

local hotkeyText
if string.byte("A") <= toggleKey and toggleKey <= string.byte("Z") then
	hotkeyText = string.char(toggleKey)
else
	hotkeyText = ""..toggleKey
end  
 
function Key(msg,code)
	if client.chat or client.console or client.loading then return end
	if IsKeyDown(toggleKey) then
		activ = not activ
		if activ then
			statusText.text = "(" .. hotkeyText .. ") Auto Disable: All"
		else
			statusText.text = "(" .. hotkeyText .. ") Auto Disable: Blink"
		end
	end
end
 
function Tick( tick )
	if not client.connected or client.loading or client.console or not entityList:GetMyHero() then return end
	if sleepTick and sleepTick > tick then return end	
	me = entityList:GetMyHero() if not me then return end
	
	local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,team = 5-me.team,alive=true,visible=true,illusion=false})
		for i,v in ipairs(enemies) do
			target = v
			local IV  = v:IsInvul()
			local MI  = v:IsMagicImmune()
			local ST  = v:IsStunned()
			local HEX = v:IsHexed()
			local SI  = v:IsSilenced()
			local DA  = v:IsDisarmed()
			local invis = me:IsInvisible()
			local blink = v:FindItem("item_blink")

			if not (IV or MI or ST or HEX or SI or DA or invis) then
				if blink and blink.cd > 11 then
					UseHex()
					UseSheepStickTarget()
					UseAbyssaltarget()
					UseOrchidtarget()
					UseSilence()
					UseEulScepterTarget()
					UseHalberdtarget()
					UseEtherealtarget()
					break
				elseif activ then
					UseHex()
					UseSheepStickTarget()
					UseAbyssaltarget()
					UseOrchidtarget()
					UseSilence()
					UseEulScepterTarget()
					break
				elseif Initiation[v.name] then
					local iSpell =  v:FindSpell(Initiation[v.name].Spell)
					local iLevel = iSpell.level 
					if iSpell.level > 0 and iSpell.cd > iSpell:GetCooldown(iLevel) - 1 then
						UseHex()
						UseSheepStickTarget()
						UseAbyssaltarget()
						UseOrchidtarget()
						UseSilence()
						UseEulScepterTarget()
						UseHalberdtarget()
						UseEtherealtarget()
						break
					end
				end
			end
		end
	activated = 0
end
 
function Load()
	if PlayingGame() then
		local me    = entityList:GetMyHero()
		if not me then
			script:Disable()
		else
			reg = true
			script:RegisterEvent(EVENT_TICK,Tick)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(Load)
		end
	end
end

function GameClose()
	collectgarbage("collect")
	if reg then
		script:UnregisterEvent(Tick)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,Load)
		reg = false
		statusText.visible = false
	end
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,Load)
    
--use item or skill---------------------------------------------------------------------------------------------------
    
function UseEulScepterTarget()
	local euls = me:FindItem("item_cyclone")
	if activated == 0 then
		if euls and euls.cd == 0 then
			if target and GetDistance2D(me,target) < 700 then
				me:CastAbility(euls,target)
				activated = 1
				sleepTick = GetTick() + 500
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
				sleepTick = GetTick() + 500
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
				sleepTick = GetTick() + 500
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
				sleepTick = GetTick() + 500
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
				sleepTick = GetTick() + 500
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
				sleepTick = GetTick() + 500
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
		elseif hex_rast then
			hex = hex_rasta
		end
		if hex and hex.level > 0 and hex:CanBeCasted() and me:CanCast() then
			if target and GetDistance2D(me,target) < 500 then
				me:SafeCastAbility(hex,target)
				activated = 1
				sleepTick = GetTick() + 500
				return
			end
		end
	end
end

function UseSilence()
	if activated == 0 then
		local silence_sky = me:FindSpell("skywrath_mage_ancient_seal")
		local silence_ns  = me:FindSpell("night_stalker_crippling_fear")
		if silence_sky then
			silence = silence_sky
		elseif silence_ns then
			silence = silence_ns
		end
		if silence and silence.level > 0 and silence:CanBeCasted() and me:CanCast() then
			if target and GetDistance2D(me,target) < silence.castRange  then
				me:SafeCastAbility(silence,target)
				activated = 1
				sleepTick = GetTick() + 500
				return
			end
		end
	end
end
