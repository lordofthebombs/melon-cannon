include("sh_melon_cannon.lua")

-- Function to shoot single melon
function SWEP:shoot_melon()
    local owner = self:GetOwner()

    -- Check if weapon is actually being help first
    if not owner:IsValid() then return end
end

-- Function that will shoot explosive melon cluster
function SWEP:shoot_melon_cluster()
    local owner = self:GetOwner()

    -- Check if weapon is actually being help first
    if not owner:IsValid() then return end
end