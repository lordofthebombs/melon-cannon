-- Building ENT struct
ENT.Type                    = "anim"
ENT.Base                    = "base_gmodentity"

ENT.Author                  = "lordofthebombs"
ENT.Category                = "Lord's Wacky Entities"
ENT.PrintName               = "Explosive Melon"
ENT.Spawnable               = false
ENT.RenderGroup             = RENDERGROUP_BOTH

-- Taken from https://wiki.facepunch.com/gmod/ENTITY:OnRemove
function ENT:OnRemove()
    local explosion = ents.Create( "env_explosion" ) -- The explosion entity
	explosion:SetPos( self:GetPos() ) -- Put the position of the explosion at the position of the entity
	explosion:Spawn() -- Spawn the explosion
	explosion:SetKeyValue( "iMagnitude", "50" ) -- the magnitude of the explosion
	explosion:Fire( "Explode", 0, 0 ) -- explode
end