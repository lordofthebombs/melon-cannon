-- SWEP Data
SWEP.PrintName = "Melon Cannon"
SWEP.Author = "lordofthebombs"
SWEP.Contact = "https://steamcommunity.com/id/lordofthebombs/"
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

SWEP.CSMuzzleFlashes = true

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.UseHands = true

SWEP.ShootSound = Sound("sound/Grenade_launcher_shoot.wav")

function SWEP:PrimaryAttack()
    local fire_rate = 0.2
    self:SetNextPrimaryFire(CurTime() + fire_rate)    -- Fire rate
    -- Shooting the melon
    self:shoot_melon()
end

function SWEP:SecondaryAttack()
    local fire_rate = 1.0
    self:SetNextSecondaryFire(CurTime() + fire_rate)
    self:shoot_cluster()
end

-- Function to shoot the single melon
function SWEP:shoot_melon()
    local owner = self:GetOwner()
    if not owner:IsValid() then return end

    if CLIENT then return end   -- Ending all client related activities here

    local ent = ents.Create("prop_physics")

    -- Check to see if entity is created
    if not ent:IsValid() then return end

    -- Setting melon as the prop
    ent:SetModel("models/props_junk/watermelon01.mdl")
    
    -- Getting aim vector so I can place the melon at the correct place when firing
    local aimvec = owner:GetAimVector()
    local pos = aimvec * 16
    pos:Add(owner:EyePos())     -- Translates vector to world coordinates

    -- Setting position 16 units in front of eyes
    ent:SetPos(pos)
    ent:SetAngles(owner:EyeAngles())

    print("Spawning melon")
    ent:Spawn()

    -- Getting physics of entity
    local phys = ent:GetPhysicsObject()
    if not phys:IsValid() then ent:Remove() return end      -- Ends script if physics is invalid
    aimvec:Mul(1000000)
	phys:ApplyForceCenter( aimvec )
 
	-- Assuming we're playing in Sandbox mode we want to add this
	-- entity to the cleanup and undo lists. This is done like so.
	cleanup.Add( owner, "props", ent )
end

function SWEP:shoot_cluster()
    
end