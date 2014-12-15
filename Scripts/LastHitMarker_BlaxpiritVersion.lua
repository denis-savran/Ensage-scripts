--<<If the icon has become a color that mean that creep dies from your attack>>
--===Modified D.L.'s script By Blaxpirit===--

require("libs.Utils")

local rect = {}
local sleep = 0
local play = false
local ex = client.screenSize.x/1600

function Tick( tick )

	if client.console or sleep > tick then return end	
	
	sleep = tick + 50
	
	local mydamage = me.dmgMin + me.dmgBonus
	local damage = Damage()
	local dmgtobuildings = 0.5*(mydamage)
	
	--========================<< ENTITIES >>======================================
	local entities1 = {}
	local creeps = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Lane})
	local neutrals = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Neutral})
	
	local venowards = entityList:GetEntities({classId=CDOTA_BaseNPC_Venomancer_PlagueWard})
	local rastawards = entityList:FindEntities({classId=CDOTA_BaseNPC_ShadowShaman_SerpentWard})
	local forge = entityList:GetEntities({classId=CDOTA_BaseNPC_Invoker_Forged_Spirit})	
	local golem = entityList:GetEntities({classId=CDOTA_BaseNPC_Warlock_Golem})
	------------------------------------------------------------------------------
	for k,v in pairs(creeps) do if v.spawned then entities1[#entities1 + 1] = v end end
	for k,v in pairs(neutrals) do if v.spawned then entities1[#entities1 + 1] = v end end
	
	for k,v in pairs(venowards) do entities1[#entities1 + 1] = v end
	for k,v in pairs(rastawards) do entities1[#entities1 + 1] = v end
	for k,v in pairs(forge) do entities1[#entities1 + 1] = v end
	for k,v in pairs(golem) do entities1[#entities1 + 1] = v end
	--============================(\/)*_*(\/)======================================
	local entities2 = {}
	
	local siege = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Siege})
	
	local towers = entityList:GetEntities({classId=CDOTA_BaseNPC_Tower})
	local barracks = entityList:GetEntities({classId=CDOTA_BaseNPC_Barracks})
	local buildings = entityList:GetEntities({classId=CDOTA_BaseNPC_Building})
	------------------------------------------------------------------------------
	for k,v in pairs(siege) do if v.spawned then entities2[#entities2 + 1] = v end end
	
	for k,v in pairs(towers) do entities2[#entities2 + 1] = v end
	for k,v in pairs(barracks) do entities2[#entities2 + 1] = v end
	for k,v in pairs(buildings) do entities2[#entities2 + 1] = v end
	--============================================================================
	
	for i, v in ipairs(entities1) do
		LastHitMarker(v,mydamage,damage)
	end

	for i, v in ipairs(entities2) do
		mydamage = dmgtobuildings
		damage = dmgtobuildings
		LastHitMarker(v,mydamage,damage)
	end		
end

function LastHitMarker(v,mydamage,damage)
	local OnScreen = client:ScreenPosition(v.position)	
	if OnScreen then
		local offset = v.healthbarOffset
		if offset == -1 then return end			
				
		if not rect[v.handle] then 
			rect[v.handle] = drawMgr:CreateRect(-4*ex,-32*ex,0,0,0xFF8AB160) rect[v.handle].entity = v rect[v.handle].entityPosition = Vector(0,0,offset) rect[v.handle].visible = false 					
		end

		if v.visible and v.alive and v.team ~= me.team then					
			if v.health > (damage*(1-v.dmgResist)) and v.health < (2*damage*(1-v.dmgResist)) then
				rect[v.handle].w = 15*ex
				rect[v.handle].h = 15*ex
				rect[v.handle].textureId = drawMgr:GetTextureId("NyanUI/other/Passive_Coin")
			elseif v.health > 0 and v.health < (damage*(1-v.dmgResist)+1) then
				rect[v.handle].w = 15*ex
				rect[v.handle].h = 15*ex
				rect[v.handle].textureId = drawMgr:GetTextureId("NyanUI/other/Active_Coin")
			end
			rect[v.handle].visible = true
		elseif v.visible and v.alive and v.team == me.team then	
			if v.health > (mydamage*(1-v.dmgResist)) and v.health < (2*mydamage*(1-v.dmgResist)+1) then
				rect[v.handle].w = 20*ex
				rect[v.handle].h = 20*ex
				rect[v.handle].textureId = drawMgr:GetTextureId("NyanUI/other/Passive_Deny")
			elseif v.health > 0 and v.health < (mydamage*(1-v.dmgResist)+1) then
				rect[v.handle].w = 20*ex
				rect[v.handle].h = 20*ex
				rect[v.handle].textureId = drawMgr:GetTextureId("NyanUI/other/Active_Deny")
			end
			rect[v.handle].visible = true
		elseif rect[v.handle].visible then
			rect[v.handle].visible = false
		end
	end	
end

function Damage()
	local dmg =  me.dmgMin + me.dmgBonus
	local items = me.items
	for i,item in ipairs(items) do
		if item and item.name == "item_quelling_blade" then
			if me.ATTACK_MELEE then
				return dmg*1.32
			else
				return dmg*1.12
			end
		end
	end
	return dmg
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
