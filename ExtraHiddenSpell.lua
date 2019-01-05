local ExtraHiddenSpell = {}

ExtraHiddenSpell.OptionEnable = Menu.AddOption({"mlambers", "ExtraHiddenSpell"}, "1. Enable", "Enable this script.")

local ParticlesTable = {}
local EffectRender = {}
local TempOnParticleUpdate = nil
local TabValueOnUpdate = nil

local ControlPoint = {
	HaveControlPointZero = {
		ancient_apparition_ice_blast_final = true
	},
	HaveControlPointOne = {
		ancient_apparition_ice_blast_final = true,
		gyro_calldown_first = true
	},
	HaveControlPointFive = {
		ancient_apparition_ice_blast_final = true
	}
}

local ParticlesList = {
	gyro_calldown_first = {
		"particles/units/heroes/hero_gyrocopter/gyro_calldown_marker.vpcf",
		2
	},
	ancient_apparition_ice_blast_final = {
		"particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_marker.vpcf",
		2
	}
}

local ModClass = {
	modifier_tusk_snowball_target = {
		"particles/units/heroes/hero_tusk/tusk_snowball_target.vpcf",
		7
	},
	modifier_leshrac_split_earth_thinker = {
		"particles/units/heroes/hero_leshrac/leshrac_split_earth.vpcf",
		3
	}
}

function ExtraHiddenSpell.OnScriptLoad()
	for i = #ParticlesTable, 1, -1 do
		ParticlesTable[i] = nil
	end
	
	ParticlesTable = {}
	
	for k, v in pairs(EffectRender) do
		if v ~= nil and v[1] ~= 0 then
			Particle.Destroy(v[1])
			EffectRender[k] = nil
		end
	end
	
	EffectRender = {}
	
	TempOnParticleUpdate = nil
	TabValueOnUpdate = nil
	
	Console.Print("\n==================================================\n")
	Console.Print("Script: ExtraHiddenSpell | Callback: OnScriptLoad\n")
	Console.Print("Date & Time: " .. (os.date("%Y-%m-%d %I:%M %p")))
	Console.Print("==================================================\n\n")
end

function ExtraHiddenSpell.OnGameStart()
	for i = #ParticlesTable, 1, -1 do
		ParticlesTable[i] = nil
	end
	
	ParticlesTable = {}
	
	for k, v in pairs(EffectRender) do
		if v ~= nil and v[1] ~= 0 then
			Particle.Destroy(v[1])
			EffectRender[k] = nil
		end
	end
	
	EffectRender = {}
	
	TempOnParticleUpdate = nil
	TabValueOnUpdate = nil
	
	Console.Print("ExtraHiddenSpell.OnGameStart()")
end

function ExtraHiddenSpell.OnGameEnd()
	for i = #ParticlesTable, 1, -1 do
		ParticlesTable[i] = nil
	end
	
	ParticlesTable = {}
	
	for k, v in pairs(EffectRender) do
		if v ~= nil and v[1] ~= 0 then
			Particle.Destroy(v[1])
			EffectRender[k] = nil
		end
	end
	
	EffectRender = {}
	
	TempOnParticleUpdate = nil
	TabValueOnUpdate = nil
	
	collectgarbage("collect")
	
	Console.Print("ExtraHiddenSpell.OnGameEnd()")
end

function ExtraHiddenSpell.CreateAoeParticle(index, name, entity, position, radius)
	EffectRender[index] = {
		Particle.Create(
			ParticlesList[name][1],
			ParticlesList[name][2],
			entity
		)
	}
		
	Particle.SetControlPoint(EffectRender[index][1], 0, position)
	Particle.SetControlPoint(EffectRender[index][1], 1, Vector(radius, 1, 1))
end


function ExtraHiddenSpell.CreateOverheadParticle(modifier)
	EffectRender[Modifier.GetIndex(modifier)] = {
		Particle.Create(
			ModClass[Modifier.GetClass(modifier)][1],
			ModClass[Modifier.GetClass(modifier)][2],
			Modifier.GetParent(modifier)
		)
	}
end

function ExtraHiddenSpell.CreateModAoeParticle(modifier)
	EffectRender[Modifier.GetIndex(modifier)] = {
		Particle.Create(
			ModClass[Modifier.GetClass(modifier)][1],
			ModClass[Modifier.GetClass(modifier)][2],
			Modifier.GetParent(modifier)
		)
	}
		
	Particle.SetControlPoint(EffectRender[Modifier.GetIndex(modifier)][1], 0, Entity.GetAbsOrigin(Modifier.GetParent(modifier)))
	Particle.SetControlPoint(EffectRender[Modifier.GetIndex(modifier)][1], 1, Vector(Ability.GetLevelSpecialValueFor(Modifier.GetAbility(modifier), "radius"), 1, 1))
end

function ExtraHiddenSpell.OnModifierGained(npc, modifier)
	if Menu.IsEnabled(ExtraHiddenSpell.OptionEnable) == false then return end
	if Heroes.GetLocal() == nil then return end

	if Modifier.GetTeam(modifier) ~= Entity.GetTeamNum(Heroes.GetLocal())
	and ModClass[Modifier.GetClass(modifier)] ~= nil
	then
		if ModClass[Modifier.GetClass(modifier)][2] == 7 then
			ExtraHiddenSpell.CreateOverheadParticle(modifier)
		elseif ModClass[Modifier.GetClass(modifier)][2] == 3 then
			ExtraHiddenSpell.CreateModAoeParticle(modifier)
		end
	end
end

function ExtraHiddenSpell.OnModifierLost(npc, modifier)
	if Menu.IsEnabled(ExtraHiddenSpell.OptionEnable) == false then return end
	if Heroes.GetLocal() == nil then return end

	if Modifier.GetTeam(modifier) ~= Entity.GetTeamNum(Heroes.GetLocal())
	and ModClass[Modifier.GetClass(modifier)] ~= nil
	then
		if EffectRender[Modifier.GetIndex(modifier)] then
			Particle.Destroy(EffectRender[Modifier.GetIndex(modifier)][1])
			EffectRender[Modifier.GetIndex(modifier)] = nil
		end
	end
end

function ExtraHiddenSpell.OnParticleCreate(particle)
	if Menu.IsEnabled(ExtraHiddenSpell.OptionEnable) == false then return end
	if Heroes.GetLocal() == nil then return end

	if ParticlesList[particle.name] 
	and Entity.GetTeamNum(particle.entityForModifiers) ~= Entity.GetTeamNum(Heroes.GetLocal()) 
	then
		table.insert(
			ParticlesTable, 
			{
				Index = particle.index,
				Name = particle.name,
				Entity = particle.entityForModifiers or nil,
				WhenToDelete = nil,
				cp0 = nil,
				cp1 = nil,
				cp5 = nil
			}
		)
	end
end

function ExtraHiddenSpell.OnParticleUpdate(particle)
	if Menu.IsEnabled(ExtraHiddenSpell.OptionEnable) == false then return end
	if Heroes.GetLocal() == nil then return end

	for i = 1, #ParticlesTable do
		TempOnParticleUpdate = ParticlesTable[i]
		
		if TempOnParticleUpdate ~= nil and particle.index == TempOnParticleUpdate.Index then
			if particle.controlPoint == 0 then
				if ControlPoint.HaveControlPointZero[TempOnParticleUpdate.Name] then
					if TempOnParticleUpdate.cp0 == nil then
						ParticlesTable[i].cp0 = particle.position
					end
				end
			elseif particle.controlPoint == 1 then
				if ControlPoint.HaveControlPointOne[TempOnParticleUpdate.Name] then
					if TempOnParticleUpdate.cp1 == nil then
						ParticlesTable[i].cp1 = particle.position
						if TempOnParticleUpdate.Name == "gyro_calldown_first" then
							ParticlesTable[i].WhenToDelete = GameRules.GetGameTime() + 4.0
							
							ExtraHiddenSpell.CreateAoeParticle(particle.index, TempOnParticleUpdate.Name, TempOnParticleUpdate.Entity, ParticlesTable[i].cp1, 600)
						end
					end
				end
			elseif particle.controlPoint == 5 then
				if ControlPoint.HaveControlPointFive[TempOnParticleUpdate.Name] then
					if TempOnParticleUpdate.cp5 == nil then
						
						if TempOnParticleUpdate.Name == "ancient_apparition_ice_blast_final" then
							local MultiplyPosition = Vector(TempOnParticleUpdate.cp1:GetX() * particle.position:GetX(), TempOnParticleUpdate.cp1:GetY() * particle.position:GetX(), TempOnParticleUpdate.cp1:GetZ() * particle.position:GetX())
							local EndPosition = TempOnParticleUpdate.cp0:__add(MultiplyPosition)
							local DistanceTravel = (TempOnParticleUpdate.cp0 - EndPosition):Length()
							local RadiusBlast = 275 + (50 * (DistanceTravel/1500))
							local TimeTravel = DistanceTravel/750
							
							if RadiusBlast > 1000 then
								RadiusBlast = 1000
							end
							
							if TimeTravel > 2 then
								TimeTravel = 2
							end
							
							ParticlesTable[i].cp5 = EndPosition
							
							ExtraHiddenSpell.CreateAoeParticle(particle.index, TempOnParticleUpdate.Name, TempOnParticleUpdate.Entity, ParticlesTable[i].cp5, RadiusBlast)
							
							ParticlesTable[i].WhenToDelete = GameRules.GetGameTime() + TimeTravel
						end
					end
				end
			end
		end
	end
end

function ExtraHiddenSpell.OnUpdate()
	if Menu.IsEnabled(ExtraHiddenSpell.OptionEnable) == false then return end
	if Heroes.GetLocal() == nil then return end

	for i = 1, #ParticlesTable do
		TabValueOnUpdate = ParticlesTable[i]
		
		if TabValueOnUpdate ~= nil then
			if TabValueOnUpdate.WhenToDelete ~= nil and TabValueOnUpdate.WhenToDelete < GameRules.GetGameTime() then
				Particle.Destroy(EffectRender[TabValueOnUpdate.Index][1])
				EffectRender[TabValueOnUpdate.Index] = nil
				ParticlesTable[i] = nil
			end
		end
	end
end

return ExtraHiddenSpell