--<<If the icon has become colored that means that creep will die from your attack>>
--===Modified D.L.'s script By Blaxpirit===--

require("libs.Utils")

local rect = {}
local play = false
local ex = client.screenSize.x/1600

function Tick( tick )
	if client.console then return end	
	

	local mydamage = me.dmgMin + me.dmgBonus 
	local dmgtobuildings = 0.5*(mydamage)
	
	local damage = mydamage
	local quellingblade = me:FindItem("item_quelling_blade")
	if quellingblade then
		if me.ATTACK_MELEE then
			damage = mydamage*1.32
		else 
			damage = mydamage*1.12
		end
	end

	local size = 1
	
	--========================<< ENTITIES >>======================================
	local entities1 = {}
	
	local creeps = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep})
	local lanecreeps = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Lane})
	local neutrals = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Neutral})
	
	local venowards = entityList:GetEntities({classId=CDOTA_BaseNPC_Venomancer_PlagueWard})
	local rastawards = entityList:FindEntities({classId=CDOTA_BaseNPC_ShadowShaman_SerpentWard})
	local forge = entityList:GetEntities({classId=CDOTA_BaseNPC_Invoker_Forged_Spirit})	
	local golem = entityList:GetEntities({classId=CDOTA_BaseNPC_Warlock_Golem})
	------------------------------------------------------------------------------
	for k,v in pairs(creeps) do if v.spawned then entities1[#entities1 + 1] = v end end
	for k,v in pairs(lanecreeps) do if v.spawned then entities1[#entities1 + 1] = v end end
	for k,v in pairs(neutrals) do if v.spawned then entities1[#entities1 + 1] = v end end
	
	for k,v in pairs(venowards) do entities1[#entities1 + 1] = v end
	for k,v in pairs(rastawards) do entities1[#entities1 + 1] = v end
	for k,v in pairs(forge) do entities1[#entities1 + 1] = v end
	for k,v in pairs(golem) do entities1[#entities1 + 1] = v end
	--============================(\/)*_*(\/)======================================
	local entities2 = {}
	
	local siege = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Siege})
	
	local ancient = entityList:GetEntities({classId=CDOTA_BaseNPC_Fort})
	local towers = entityList:GetEntities({classId=CDOTA_BaseNPC_Tower})
	local barracks = entityList:GetEntities({classId=CDOTA_BaseNPC_Barracks})
	local buildings = entityList:GetEntities({classId=CDOTA_BaseNPC_Building})
	------------------------------------------------------------------------------
	for k,v in pairs(siege) do if v.spawned then entities2[#entities2 + 1] = v end end
	
	for k,v in pairs(ancient) do entities2[#entities2 + 1] = v end
	for k,v in pairs(towers) do entities2[#entities2 + 1] = v end
	for k,v in pairs(barracks) do entities2[#entities2 + 1] = v end
	for k,v in pairs(buildings) do entities2[#entities2 + 1] = v end
	--============================================================================
	
	for i, v in ipairs(entities1) do
		LastHitMarker(v,mydamage,damage,size)
	end

	for i, v in ipairs(entities2) do
		mydamage = dmgtobuildings
		damage = dmgtobuildings
		size = 1.4
		LastHitMarker(v,mydamage,damage,size)
	end		
end

function LastHitMarker(v,mydamage,damage,size)
	local OnScreen = client:ScreenPosition(v.position)	
	if OnScreen then
		local offset = v.healthbarOffset
		if offset == -1 then return end			
		
		if not rect[v.handle] then 
			rect[v.handle] = drawMgr:CreateRect(-10*ex,-33*ex*size,0,0,0xFF8AB160) rect[v.handle].entity = v rect[v.handle].entityPosition = Vector(0,0,offset) rect[v.handle].visible = false 					
		end

		local resistance = v.dmgResist
		local desolator = me:FindItem("item_desolator")
		local desoldebuff = v:FindModifier("modifier_desolator_buff")
		if desolator and not desoldebuff then
			local armor = v.armor + v.bonusArmor - 7
			if armor > 0 then
				resistance = (0.06*(armor))/(1 + 0.06*(armor))
			else 
				resistance = -(1 - 0.94^(-armor))
			end	
		end
		
		if v.visible and v.alive and v.team ~= me.team then
			if v.health > (2*damage*(1-resistance)) then
				rect[v.handle].visible = false
			elseif v.health > (damage*(1-resistance)) and v.health < (2*damage*(1-resistance)) then
				rect[v.handle].w = 15*ex*size
				rect[v.handle].h = 15*ex*size
				rect[v.handle].textureId = drawMgr:GetTextureId("NyanUI/other/Passive_Coin")
				rect[v.handle].visible = true
			elseif v.health > 0 and v.health < (damage*(1-resistance)) then
				rect[v.handle].w = 15*ex*size
				rect[v.handle].h = 15*ex*size
				rect[v.handle].textureId = drawMgr:GetTextureId("NyanUI/other/Active_Coin")
				rect[v.handle].visible = true
			end
		elseif v.visible and v.alive and v.team == me.team then	
			if v.health > (2*mydamage*(1-resistance)) then
				rect[v.handle].visible = false
			elseif v.health > (mydamage*(1-resistance)) and v.health < (2*mydamage*(1-resistance)) then
				rect[v.handle].w = 17*ex*size
				rect[v.handle].h = 17*ex*size
				rect[v.handle].textureId = drawMgr:GetTextureId("NyanUI/other/Passive_Deny")
				rect[v.handle].visible = true
			elseif v.health > 0 and v.health < (mydamage*(1-resistance)) then
				rect[v.handle].w = 17*ex*size
				rect[v.handle].h = 17*ex*size
				rect[v.handle].textureId = drawMgr:GetTextureId("NyanUI/other/Active_Deny")
				rect[v.handle].visible = true
			end
		elseif rect[v.handle].visible then
			rect[v.handle].visible = false
		end
	end	
end

function Load()
	if PlayingGame() then
		me = entityList:GetMyHero()
		if not me then 
			script:Disable()
		else
			play = true
			script:RegisterEvent(EVENT_TICK,Tick)
			script:UnregisterEvent(Load)
		end
	end
end

function GameClose()
	rect = {}
	collectgarbage("collect")
	if play then
		script:UnregisterEvent(Tick)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
end

script:RegisterEvent(EVENT_TICK,Load)
script:RegisterEvent(EVENT_CLOSE,GameClose)
