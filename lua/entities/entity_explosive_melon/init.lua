AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")


function ENT:Initialize()
    -- Setting the model
    self:SetModel("models/props_junk/watermelon01.mdl")

    -- Setting color to red
    self:SetColor(Color(200, 50, 50))
    self:SetMaterial("phoenix_storms/wire/pcb_red")

    -- Definining physics
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    self:PhysicsInit(SOLID_VPHYSICS)

    -- Makes prop spawn
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then phys:Wake() end

    timer.Simple(2 + math.random(0, 1) + math.random(), function() self:Remove() end)
end


-- Taken from https://wiki.facepunch.com/gmod/ENTITY:OnRemove
function ENT:OnRemove()
    local explosion = ents.Create( "env_explosion" ) -- The explosion entity
	explosion:SetPos( self:GetPos() ) -- Put the position of the explosion at the position of the entity
	explosion:Spawn() -- Spawn the explosion
	explosion:SetKeyValue( "iMagnitude", "100" ) -- the magnitude of the explosion
	explosion:Fire( "Explode", 0, 0 ) -- explode
end


-- Plays sounds on collision with the world
function ENT:PhysicsCollide(col_data, phys)
    if col_data.Speed > 150 then self:EmitSound(Sound("Canister.ImpactHard")) end
end