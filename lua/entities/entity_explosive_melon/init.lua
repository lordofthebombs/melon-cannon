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

    timer.Simple(2 + math.random(0.0, 1.0) + math.random(), function() self:Remove() end)
end