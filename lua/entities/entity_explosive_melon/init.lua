AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    print("Initializing entity!")
    -- Setting the model
    self:SetModel("models/props_junk/watermelon01.mdl")

    -- Setting color to red
    self:SetColor(Color(200, 50, 50))

    -- Definining physics
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    self:PhysicsInit(SOLID_VPHYSICS)

    -- Makes prop spawn
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then phys:Wake() end

    timer.Simple(4, function() self:Remove() end)
end


-- Taken from https://wiki.facepunch.com/gmod/ENTITY:OnRemove
function ENT:OnRemove()
    local explosion = ents.Create( "env_explosion" ) -- The explosion entity
	explosion:SetPos( self:GetPos() ) -- Put the position of the explosion at the position of the entity
	explosion:Spawn() -- Spawn the explosion
	explosion:SetKeyValue( "iMagnitude", "50" ) -- the magnitude of the explosion
	explosion:Fire( "Explode", 0, 0 ) -- explode
end