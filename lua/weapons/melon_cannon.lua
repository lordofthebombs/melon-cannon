-- SWEP Data
SWEP.PrintName 							= "Weaponized Melon Device"
SWEP.Purpose                            = "To administer melon justice."
SWEP.Author 							= "lordofthebombs"
SWEP.Instructions 						= "Left click to fire a melon.\nRight click to fire a cluster of explosive melons."
SWEP.Category 							= "Lord's Wacky Weapons"
SWEP.IconOverride 						= "materials/weapons/melon_cannon.png"
SWEP.Spawnable 							= true
SWEP.AdminOnly 							= false
SWEP.BounceWeaponIcon 					= false
if CLIENT then SWEP.WepSelectIcon       = Material("weapons/melon_cannon.png") end

-- Ammo info
SWEP.Primary.ClipSize 					= 20
SWEP.Primary.DefaultClip 				= 80
SWEP.Primary.Automatic 					= true
SWEP.Primary.Ammo 						= "AR2"
SWEP.Primary.Recoil						= 10
SWEP.Primary.FireRate                   = 0.7

SWEP.Secondary.ClipSize 				= -1
SWEP.Secondary.DefaultClip 				= -1
SWEP.Secondary.Automatic 				= false
SWEP.Secondary.Ammo 					= "none"
SWEP.Secondary.FireRate                 = 2

SWEP.ClusterThreshold                   = 10

SWEP.Weight 							= 5
SWEP.AutoSwitchTo 						= false
SWEP.AutoSwitchFrom 					= false

SWEP.Slot 								= 1
SWEP.SlotPos 							= 2
SWEP.DrawAmmo 							= true
SWEP.DrawCrosshair 						= true

SWEP.ReloadingTime						= 0.25

-- Weapon view settings
SWEP.ViewModelFOV 						= 54
SWEP.ViewModel 							= "models/weapons/c_rpg.mdl"
SWEP.WorldModel 						= "models/weapons/w_rocket_launcher.mdl"
SWEP.UseHands 							= true
SWEP.VElements = {
    ["melon"] = { type = "Model", model = "models/props_junk/watermelon01.mdl", bone = "base", rel = "", pos = Vector(0, -0.218, 32.59), angle = Angle(0, 0, 101.375), size = Vector(0.714, 0.714, 0.714), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
    ["melon"] = { type = "Model", model = "models/props_junk/watermelon01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(19.6, 1.662, -9.867), angle = Angle(7.737, -87.154, -20.934), size = Vector(0.397, 0.397, 0.397), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-- Sounds
SWEP.ShootSound 						= Sound("grenade_launcher_shoot.ogg")
SWEP.ReloadSound 					    = Sound("sniper_railgun_world_reload.ogg")
SWEP.EmptyClipSound 					= Sound("weapons/ar2/ar2_empty.wav")
SWEP.EmptySecondary 					= Sound("DoSpark")

-- Set up for muzzle flash
game.AddParticles("particles/devtest.pcf")
PrecacheParticleSystem("weapon_muzzle_flash_assaultrifle")

-- Set up for secondary failure
game.AddParticles("particles/hunter_projectile.pcf")
PrecacheParticleSystem("hunter_muzzle_flash_b")


function SWEP:PrimaryAttack()

    self:SetNextPrimaryFire(CurTime() + self.Primary.FireRate)    -- Fire rate
    -- Shooting the melon
    if self:Clip1() > 0 then 		-- Added in a check to stop melons from shooting using reserve ammo
        self:shoot_melon()
        self:TakePrimaryAmmo(1)
        self:ShootEffects()
    else
        self:EmitSound(self.EmptyClipSound)
    end
end


function SWEP:SecondaryAttack()
    local owner = self:GetOwner()
	
    if not owner:IsValid() then return end		-- Added a check for the owner
	
    local aimvec = owner:GetAimVector()
    pos = aimvec * 16
    pos:Add(owner:EyePos())

    self:SetNextSecondaryFire(CurTime() + self.Secondary.FireRate)

    if self:Clip1() >= 10 and self:Clip1() <= 20 then 		-- Only Shoots cluster if there is enough ammo to deduct
            -- Sound
        self:EmitSound(self.ShootSound)
        self:TakePrimaryAmmo(10)
        self:ShootEffects()
        for i = 1, 10 do
            self:cluster_shot()
        end
    else
        self:EmitSound(self.EmptySecondary)
        ParticleEffect("hunter_muzzle_flash_b", pos, owner:EyeAngles(), nil)
    end
end

-- Took reload function based from https://maurits.tv/data/garrysmod/wiki/wiki.garrysmod.com/index1bed.html
function SWEP:Reload()
    local owner = self:GetOwner()
    if self.ReloadingTime and CurTime() <= self.ReloadingTime then return end
 
    if ( self:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 ) then
        self:EmitSound(self.ReloadSound)
        self:DefaultReload(ACT_VM_RELOAD)
        local AnimationTime = owner:GetViewModel():SequenceDuration()
        self.ReloadingTime = CurTime() + AnimationTime
        self:SetNextPrimaryFire(CurTime() + AnimationTime)
        self:SetNextSecondaryFire(CurTime() + AnimationTime)
    end
 
end


-- Function to shoot the single melon
function SWEP:shoot_melon()
    local owner = self:GetOwner()

    local punch_angle = Angle(math.random(-10, -8) + math.random(), math.random(-2, 2) + math.random(), math.random(-2, 2) + math.random())
    owner:ViewPunch(punch_angle)			-- Simulates recoil

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
    local offset = Angle(0, -90, 0)
    ent:SetAngles(owner:EyeAngles() + offset)
    ent:Spawn()

    -- Getting physics of entity
    local phys = ent:GetPhysicsObject()
    if not phys:IsValid() then ent:Remove() return end      -- Ends script if physics is invalid
    aimvec:Mul(25000)
    phys:ApplyForceCenter(aimvec)
    local angle_velocity = Vector(0, 1000, 0)
    phys:AddAngleVelocity(angle_velocity)

    self:EmitSound(self.ShootSound)

    -- Muzzle flash
    ParticleEffect("weapon_muzzle_flash_assaultrifle", pos, owner:EyeAngles(), nil)

    ent:SetPhysicsAttacker(owner, 10)		-- Sets the player as the attacker
 
    -- Assuming we're playing in Sandbox mode we want to add this
    -- entity to the cleanup and undo lists. This is done like so.
    cleanup.Add(owner, "props", ent)
end


-- Cluster shot implementation
function SWEP:cluster_shot()	
    local owner = self:GetOwner()

    local punch_angle = Angle(math.random(-5, 0) + math.random(), math.random(-4, 4) + math.random(), math.random(-4, 4) + math.random())
    owner:ViewPunch(punch_angle)			-- Simulates recoil

    if not owner:IsValid() then return end		-- Checks if owner is valid

    if CLIENT then return end

    local ent = ents.Create("entity_explosive_melon")

    -- Check to see if entity is created
    if not ent:IsValid() then return end
    
    -- Getting aim vector so I can place the melon at the correct place when firing
    local aimvec = owner:GetAimVector()
    local pos = aimvec * 16
    pos:Add(owner:EyePos())     -- Translates vector to world coordinates

    local muzzle_flash_pos = Vector(pos.x, pos.y, pos.z)

    pos:Add(VectorRand(-20, 20))		-- Adding a random vector to give a shotgun effect

    -- Setting position 16 units in front of eyes
    ent:SetPos(pos)
    local offset = Angle(0, -90, 0)
    ent:SetAngles(owner:EyeAngles() + offset)

    ent:SetOwner(owner)
    ent:Spawn()

    -- Getting physics of entity
    local phys = ent:GetPhysicsObject()
    if not phys:IsValid() then ent:Remove() return end      -- Ends script if physics is invalid
    aimvec:Mul(8000)
    phys:ApplyForceCenter(aimvec)
    local angle_velocity = Vector(0, 1000, 0)
    phys:AddAngleVelocity(angle_velocity)
    
    ent:SetPhysicsAttacker(owner, 10)		-- Sets the player as the attacker

    -- Setting attacker as explosion owner
    local damage_info = DamageInfo()
    damage_info:SetAttacker(ent)

    -- Muzzle flash
    ParticleEffect("weapon_muzzle_flash_assaultrifle", muzzle_flash_pos, owner:EyeAngles(), nil)

    -- Assuming we're playing in Sandbox mode we want to add this
    -- entity to the cleanup and undo lists. This is done like so.
    cleanup.Add(owner, "props", ent)
    
end


-- Draws wepselecticon
function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )

	-- Set us up the texture
	surface.SetDrawColor( 255, 255, 255, alpha )
	surface.SetMaterial( self.WepSelectIcon )

	-- Lets get a sin wave to make it bounce
	local fsin = 0

	if ( self.BounceWeaponIcon == true ) then
		fsin = math.sin( CurTime() * 10 ) * 5
	end

	-- Borders
	y = y - 30
	x = x + 10
	wide = wide - 20

	-- Draw that mother
	surface.DrawTexturedRect( x + fsin, y - fsin,  wide - fsin * 2 , wide - fsin)

	-- Draw weapon info box
	self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )

end



/********************************************************
    SWEP Construction Kit base code
        Created by Clavus
    Available for public use, thread at:
       facepunch.com/threads/1032378
       
       
    DESCRIPTION:
        This script is meant for experienced scripters 
        that KNOW WHAT THEY ARE DOING. Don't come to me 
        with basic Lua questions.
        
        Just copy into your SWEP or SWEP base of choice
        and merge with your own code.
        
        The SWEP.VElements, SWEP.WElements and
        SWEP.ViewModelBoneMods tables are all optional
        and only have to be visible to the client.
********************************************************/

function SWEP:Initialize()

    // other initialize code goes here
    self:SetWeaponHoldType("rpg")			-- Setting character to hold weapon on the shoulder

    if CLIENT then
    
        // Create a new table for every weapon instance
        self.VElements = table.FullCopy( self.VElements )
        self.WElements = table.FullCopy( self.WElements )
        self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

        self:CreateModels(self.VElements) // create viewmodels
        self:CreateModels(self.WElements) // create worldmodels
        
        // init view model bone build function
        if IsValid(self.Owner) then
            local vm = self.Owner:GetViewModel()
            if IsValid(vm) then
                self:ResetBonePositions(vm)
                
                // Init viewmodel visibility
                if (self.ShowViewModel == nil or self.ShowViewModel) then
                    vm:SetColor(Color(255,255,255,255))
                else
                    // we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
                    vm:SetColor(Color(255,255,255,1))
                    // ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
                    // however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
                    vm:SetMaterial("Debug/hsv")			
                end
            end
        end
        
    end

end

function SWEP:Holster()
    
    if CLIENT and IsValid(self.Owner) then
        local vm = self.Owner:GetViewModel()
        if IsValid(vm) then
            self:ResetBonePositions(vm)
        end
    end
    
    return true
end

function SWEP:OnRemove()
    self:Holster()
end

if CLIENT then

    SWEP.vRenderOrder = nil
    function SWEP:ViewModelDrawn()
        
        local vm = self.Owner:GetViewModel()
        if !IsValid(vm) then return end
        
        if (!self.VElements) then return end
        
        self:UpdateBonePositions(vm)

        if (!self.vRenderOrder) then
            
            // we build a render order because sprites need to be drawn after models
            self.vRenderOrder = {}

            for k, v in pairs( self.VElements ) do
                if (v.type == "Model") then
                    table.insert(self.vRenderOrder, 1, k)
                elseif (v.type == "Sprite" or v.type == "Quad") then
                    table.insert(self.vRenderOrder, k)
                end
            end
            
        end

        for k, name in ipairs( self.vRenderOrder ) do
        
            local v = self.VElements[name]
            if (!v) then self.vRenderOrder = nil break end
            if (v.hide) then continue end
            
            local model = v.modelEnt
            local sprite = v.spriteMaterial
            
            if (!v.bone) then continue end
            
            local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
            
            if (!pos) then continue end
            
            if (v.type == "Model" and IsValid(model)) then

                model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
                ang:RotateAroundAxis(ang:Up(), v.angle.y)
                ang:RotateAroundAxis(ang:Right(), v.angle.p)
                ang:RotateAroundAxis(ang:Forward(), v.angle.r)

                model:SetAngles(ang)
                //model:SetModelScale(v.size)
                local matrix = Matrix()
                matrix:Scale(v.size)
                model:EnableMatrix( "RenderMultiply", matrix )
                
                if (v.material == "") then
                    model:SetMaterial("")
                elseif (model:GetMaterial() != v.material) then
                    model:SetMaterial( v.material )
                end
                
                if (v.skin and v.skin != model:GetSkin()) then
                    model:SetSkin(v.skin)
                end
                
                if (v.bodygroup) then
                    for k, v in pairs( v.bodygroup ) do
                        if (model:GetBodygroup(k) != v) then
                            model:SetBodygroup(k, v)
                        end
                    end
                end
                
                if (v.surpresslightning) then
                    render.SuppressEngineLighting(true)
                end
                
                render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
                render.SetBlend(v.color.a/255)
                model:DrawModel()
                render.SetBlend(1)
                render.SetColorModulation(1, 1, 1)
                
                if (v.surpresslightning) then
                    render.SuppressEngineLighting(false)
                end
                
            elseif (v.type == "Sprite" and sprite) then
                
                local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
                render.SetMaterial(sprite)
                render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
                
            elseif (v.type == "Quad" and v.draw_func) then
                
                local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
                ang:RotateAroundAxis(ang:Up(), v.angle.y)
                ang:RotateAroundAxis(ang:Right(), v.angle.p)
                ang:RotateAroundAxis(ang:Forward(), v.angle.r)
                
                cam.Start3D2D(drawpos, ang, v.size)
                    v.draw_func( self )
                cam.End3D2D()

            end
            
        end
        
    end

    SWEP.wRenderOrder = nil
    function SWEP:DrawWorldModel()
        
        if (self.ShowWorldModel == nil or self.ShowWorldModel) then
            self:DrawModel()
        end
        
        if (!self.WElements) then return end
        
        if (!self.wRenderOrder) then

            self.wRenderOrder = {}

            for k, v in pairs( self.WElements ) do
                if (v.type == "Model") then
                    table.insert(self.wRenderOrder, 1, k)
                elseif (v.type == "Sprite" or v.type == "Quad") then
                    table.insert(self.wRenderOrder, k)
                end
            end

        end
        
        if (IsValid(self.Owner)) then
            bone_ent = self.Owner
        else
            // when the weapon is dropped
            bone_ent = self
        end
        
        for k, name in pairs( self.wRenderOrder ) do
        
            local v = self.WElements[name]
            if (!v) then self.wRenderOrder = nil break end
            if (v.hide) then continue end
            
            local pos, ang
            
            if (v.bone) then
                pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
            else
                pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
            end
            
            if (!pos) then continue end
            
            local model = v.modelEnt
            local sprite = v.spriteMaterial
            
            if (v.type == "Model" and IsValid(model)) then

                model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
                ang:RotateAroundAxis(ang:Up(), v.angle.y)
                ang:RotateAroundAxis(ang:Right(), v.angle.p)
                ang:RotateAroundAxis(ang:Forward(), v.angle.r)

                model:SetAngles(ang)
                //model:SetModelScale(v.size)
                local matrix = Matrix()
                matrix:Scale(v.size)
                model:EnableMatrix( "RenderMultiply", matrix )
                
                if (v.material == "") then
                    model:SetMaterial("")
                elseif (model:GetMaterial() != v.material) then
                    model:SetMaterial( v.material )
                end
                
                if (v.skin and v.skin != model:GetSkin()) then
                    model:SetSkin(v.skin)
                end
                
                if (v.bodygroup) then
                    for k, v in pairs( v.bodygroup ) do
                        if (model:GetBodygroup(k) != v) then
                            model:SetBodygroup(k, v)
                        end
                    end
                end
                
                if (v.surpresslightning) then
                    render.SuppressEngineLighting(true)
                end
                
                render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
                render.SetBlend(v.color.a/255)
                model:DrawModel()
                render.SetBlend(1)
                render.SetColorModulation(1, 1, 1)
                
                if (v.surpresslightning) then
                    render.SuppressEngineLighting(false)
                end
                
            elseif (v.type == "Sprite" and sprite) then
                
                local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
                render.SetMaterial(sprite)
                render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
                
            elseif (v.type == "Quad" and v.draw_func) then
                
                local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
                ang:RotateAroundAxis(ang:Up(), v.angle.y)
                ang:RotateAroundAxis(ang:Right(), v.angle.p)
                ang:RotateAroundAxis(ang:Forward(), v.angle.r)
                
                cam.Start3D2D(drawpos, ang, v.size)
                    v.draw_func( self )
                cam.End3D2D()

            end
            
        end
        
    end

    function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
        
        local bone, pos, ang
        if (tab.rel and tab.rel != "") then
            
            local v = basetab[tab.rel]
            
            if (!v) then return end
            
            // Technically, if there exists an element with the same name as a bone
            // you can get in an infinite loop. Let's just hope nobody's that stupid.
            pos, ang = self:GetBoneOrientation( basetab, v, ent )
            
            if (!pos) then return end
            
            pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
            ang:RotateAroundAxis(ang:Up(), v.angle.y)
            ang:RotateAroundAxis(ang:Right(), v.angle.p)
            ang:RotateAroundAxis(ang:Forward(), v.angle.r)
                
        else
        
            bone = ent:LookupBone(bone_override or tab.bone)

            if (!bone) then return end
            
            pos, ang = Vector(0,0,0), Angle(0,0,0)
            local m = ent:GetBoneMatrix(bone)
            if (m) then
                pos, ang = m:GetTranslation(), m:GetAngles()
            end
            
            if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
                ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
                ang.r = -ang.r // Fixes mirrored models
            end
        
        end
        
        return pos, ang
    end

    function SWEP:CreateModels( tab )

        if (!tab) then return end

        // Create the clientside models here because Garry says we can't do it in the render hook
        for k, v in pairs( tab ) do
            if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
                    string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
                
                v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
                if (IsValid(v.modelEnt)) then
                    v.modelEnt:SetPos(self:GetPos())
                    v.modelEnt:SetAngles(self:GetAngles())
                    v.modelEnt:SetParent(self)
                    v.modelEnt:SetNoDraw(true)
                    v.createdModel = v.model
                else
                    v.modelEnt = nil
                end
                
            elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
                and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
                
                local name = v.sprite.."-"
                local params = { ["$basetexture"] = v.sprite }
                // make sure we create a unique name based on the selected options
                local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
                for i, j in pairs( tocheck ) do
                    if (v[j]) then
                        params["$"..j] = 1
                        name = name.."1"
                    else
                        name = name.."0"
                    end
                end

                v.createdSprite = v.sprite
                v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
                
            end
        end
        
    end
    
    local allbones
    local hasGarryFixedBoneScalingYet = false

    function SWEP:UpdateBonePositions(vm)
        
        if self.ViewModelBoneMods then
            
            if (!vm:GetBoneCount()) then return end
            
            // !! WORKAROUND !! //
            // We need to check all model names :/
            local loopthrough = self.ViewModelBoneMods
            if (!hasGarryFixedBoneScalingYet) then
                allbones = {}
                for i=0, vm:GetBoneCount() do
                    local bonename = vm:GetBoneName(i)
                    if (self.ViewModelBoneMods[bonename]) then 
                        allbones[bonename] = self.ViewModelBoneMods[bonename]
                    else
                        allbones[bonename] = { 
                            scale = Vector(1,1,1),
                            pos = Vector(0,0,0),
                            angle = Angle(0,0,0)
                        }
                    end
                end
                
                loopthrough = allbones
            end
            // !! ----------- !! //
            
            for k, v in pairs( loopthrough ) do
                local bone = vm:LookupBone(k)
                if (!bone) then continue end
                
                // !! WORKAROUND !! //
                local s = Vector(v.scale.x,v.scale.y,v.scale.z)
                local p = Vector(v.pos.x,v.pos.y,v.pos.z)
                local ms = Vector(1,1,1)
                if (!hasGarryFixedBoneScalingYet) then
                    local cur = vm:GetBoneParent(bone)
                    while(cur >= 0) do
                        local pscale = loopthrough[vm:GetBoneName(cur)].scale
                        ms = ms * pscale
                        cur = vm:GetBoneParent(cur)
                    end
                end
                
                s = s * ms
                // !! ----------- !! //
                
                if vm:GetManipulateBoneScale(bone) != s then
                    vm:ManipulateBoneScale( bone, s )
                end
                if vm:GetManipulateBoneAngles(bone) != v.angle then
                    vm:ManipulateBoneAngles( bone, v.angle )
                end
                if vm:GetManipulateBonePosition(bone) != p then
                    vm:ManipulateBonePosition( bone, p )
                end
            end
        else
            self:ResetBonePositions(vm)
        end
           
    end
     
    function SWEP:ResetBonePositions(vm)
        
        if (!vm:GetBoneCount()) then return end
        for i=0, vm:GetBoneCount() do
            vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
            vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
            vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
        end
        
    end

    /**************************
        Global utility code
    **************************/

    // Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
    // Does not copy entities of course, only copies their reference.
    // WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
    function table.FullCopy( tab )

        if (!tab) then return nil end
        
        local res = {}
        for k, v in pairs( tab ) do
            if (type(v) == "table") then
                res[k] = table.FullCopy(v) // recursion ho!
            elseif (type(v) == "Vector") then
                res[k] = Vector(v.x, v.y, v.z)
            elseif (type(v) == "Angle") then
                res[k] = Angle(v.p, v.y, v.r)
            else
                res[k] = v
            end
        end
        
        return res
        
    end
    
end

