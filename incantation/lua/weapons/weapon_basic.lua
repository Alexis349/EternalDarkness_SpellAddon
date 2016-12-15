SWEP.PrintName			= "Basic";
SWEP.Author				=  "Alexis";
SWEP.Instructions		= "none!";
SWEP.Spawnable = true;
SWEP.AdminOnly = false;

SWEP.Primary.ClipSize		= -1;
SWEP.Primary.DefaultClip	= -1;
SWEP.Primary.Automatic		= false;
SWEP.Primary.Ammo			= "none";

SWEP.Secondary.ClipSize		= -1;
SWEP.Secondary.DefaultClip	= -1;
SWEP.Secondary.Automatic	= false;
SWEP.Secondary.Ammo			= "none";

SWEP.damage = 15;

SWEP.Weight				= 5;
SWEP.AutoSwitchTo		= false;
SWEP.AutoSwitchFrom		= false;
SWEP.Slot				= 1;
SWEP.SlotPos			= 2;
SWEP.DrawAmmo			= false;
SWEP.DrawCrosshair		= true;
SWEP.ViewModel			= "models/weapons/v_crowbar.mdl";
SWEP.WorldModel			= "models/weapons/w_crowbar.mdl";

local ShootSound = Sound( "Metal.SawbladeStick" );

function SWEP:Initialize()
	self:SetWeaponHoldType("melee2");
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	self.Weapon:EmitSound("weapons/knife/knife_deploy1.wav", 50, 100)
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.5 )
	self:Slash()
end

function SWEP:SecondaryAttack()
end

function SWEP:Slash()
	local tr = {};
	tr.start = self.Owner:GetShootPos();
	tr.endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 75;
	tr.filter = self.Owner;
	tr.mask = MASK_SHOT;
	local trace = util.TraceLine(tr);
	
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	
	if tr.Hit then
		bullet = {}
		bullet.Num    = 1
		bullet.Src    = self.Owner:GetShootPos()
		bullet.Dir    = self.Owner:GetAimVector()
		bullet.Spread = Vector(0, 0, 0)
		bullet.Tracer = 0
		bullet.Force  = 10
		bullet.Damage = self.damage
		self.Owner:FireBullets(bullet)
		util.Decal("ManhackCut", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal)
	else
		--nothing
	end
end