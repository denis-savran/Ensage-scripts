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

 
sleepTick = nil
  
function Tick( tick )
    if not SleepCheck() then return end Sleep(30)
	local me = entityList:GetMyHero() 
	if not me then return end
	
	local ID = me.classId
	if ID == CDOTA_Unit_Hero_Lion then
		UseHex(me,2,"lion_voodoo")
	elseif ID == CDOTA_Unit_Hero_ShadowShaman then
		UseHex(me,2,"shadow_shaman_voodoo")
	else
		UseHex(me,nil,nil)
	end

	actived = 0

	local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,team = 5-me.team,alive=true,visible=true,illusion=false})
		for i,v in ipairs(enemies) do
			local IV = v:IsInvul()
			local MI = v:IsMagicImmune()
			local ST = v:IsStunned()
			local HEX = v:IsHexed()
			local SI = v:IsSilenced()
			local invis = me:IsInvisible()
			local blink = v:FindItem("item_blink")

			if not (IV or MI or ST or HEX or SI or invis) then
				if blink and blink.cd > 11 then
					UseSheepStickTarget()
					UseHex()
					UseAbyssaltarget()
					UseOrchidtarget()
					UseEulScepterTarget()
					UseHalberdtarget()
					UseEtherealtarget()
					break
				elseif activ then
					UseSheepStickTarget()
					UseHex()
					UseAbyssaltarget()
					UseOrchidtarget()
					UseEulScepterTarget()
					break
				elseif Initiation[v.name] then
					local iSpell =  v:FindSpell(Initiation[v.name].Spell)
					local iLevel = iSpell.level 
					if iSpell.level > 0 and iSpell.cd > iSpell:GetCooldown(iLevel) - 1 then
						UseSheepStickTarget()
						UseHex()
						UseOrchidtarget()
						UseAbyssaltarget()
						UseEulScepterTarget()
						UseHalberdtarget()
						UseEtherealtarget()
						break
					end
				end
			end
		end
			
	actived = 0
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
     
--useitem--------------------------------------------------------------------------------------------------------------------------------------
        
    function UseEulScepterTarget()--target
            for t = 1, 6 do
                    if me:HasItem(t) and me:GetItem(t).name == "item_cyclone" then
                            DisableItem = me:GetItem(t)
                    end
            end
            if actived == 0 then
                    if DisableItem and DisableItem.state==-1 then
                            if target and GetDistance2D(me,target) < 700 then
     
                                    me:CastAbility(DisableItem,target)
                                    actived=1
                                    sleepTick= GetTick() +500
                                    return
                            end
                    end
            end
    end
         
    function UseSheepStickTarget()--target
            for t = 1, 6 do
                    if me:HasItem(t) and me:GetItem(t).name == "item_sheepstick" then
                            DisableItem = me:GetItem(t)
                    end
            end
            if actived == 0 then
                    if DisableItem and DisableItem.state==-1 then
                            if target and GetDistance2D(me,target) < 800 then
     
                                    me:CastAbility(DisableItem,target)
                                    actived=1
                                    sleepTick= GetTick() +500
                                    return
                            end
                    end
            end
    end
     
    function UseOrchidtarget()--target
            for t = 1, 6 do
                    if me:HasItem(t) and me:GetItem(t).name == "item_orchid" then
                            DisableItem = me:GetItem(t)
                    end
            end
            if actived == 0 then
                    if DisableItem and DisableItem.state==-1 then
                            if target and GetDistance2D(me,target) < 900 then
     
                                    me:CastAbility(DisableItem,target)
                                    actived=1
                                    sleepTick= GetTick() +500
                                    return
                            end
                    end
            end
    end
     
    function UseAbyssaltarget()--target
            for t = 1, 6 do
                    if me:HasItem(t) and me:GetItem(t).name == "item_abyssal_blade" then
                            DisableItem = me:GetItem(t)
                    end
            end
            if actived == 0 then
                    if DisableItem and DisableItem.state==-1 then
                            if target and GetDistance2D(me,target) < 140 then
     
                                    me:CastAbility(DisableItem,target)
                                    actived=1
                                    sleepTick= GetTick() +500
                                    return
                            end
                    end
            end
    end
    function UseHalberdtarget()--target
            for t = 1, 6 do
                    if me:HasItem(t) and me:GetItem(t).name == "item_heavens_halberd" then
                            DisableItem = me:GetItem(t)
                    end
            end
            if actived == 0 then
                    if DisableItem and DisableItem.state==-1 then
                            if target and GetDistance2D(me,target) < 600 then
     
                                    me:CastAbility(DisableItem,target)
                                    actived=1
                                    sleepTick= GetTick() +500
                                    return
                            end
                    end
            end
    end
    function UseEtherealtarget()--target
            for t = 1, 6 do
                    if me:HasItem(t) and me:GetItem(t).name == "item_ethereal_blade" then
                            DisableItem = me:GetItem(t)
                    end
            end
            if actived == 0 then
                    if DisableItem and DisableItem.state==-1 then
                            if target and GetDistance2D(me,target) < 800 then
     
                                    me:CastAbility(DisableItem,target)
                                    actived=1
                                    sleepTick= GetTick() +500
                                    return
                            end
                    end
            end
    end
	
	function UseHex(me,abilityHex,abilityHexName)--target
			if abilityHex and abilityHexName then
				local hex = me:GetAbility(abilityHex)
				local skill  = me:FindAbility(abilityHexName)
				if actived == 0 then
                    if skill and skill.state==-1 then
                            if target and GetDistance2D(me,target) < 500 then
							
                                    me:SafeCastAbility(hex,target)
                                    actived=1
                                    sleepTick= GetTick() +500
                                    return
                            end
                    end
				end
			end
	end
