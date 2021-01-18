-- SWEP Metainfo
SWEP.PrintName = "Melon Cannon"
SWEP.Author = "lordofthebombs"
SWEP.Instructions = "Left click to fire a melon.\nRight click to fire a cluster of melons."
SWEP.Spawnable = true
SWEP.AdminOnly = false

-- Ammo info
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.ShootSound = Sound("Metal.SawbladeStick")

function SWEP:PrimaryAttack()
    local fire_rate = 0.5
    self:SetNextPrimaryFire(CurTime() + fire_rate)    -- Fire rate
    
    -- Shooting the melon
    self:shoot_melon()
end

-- Function to shoot the single melon
function SWEP:shoot_melon()
    local ent = ents.Create("prop_physics")
    
    -- Check to see if entity is created
    if not ent.IsValid() then return end

    ent:SetModel("models/props_junk/watermelon01.mdl")
    ent:Spawn()
end