function EFFECT:Init( data )
	self.data = data;
	self.particles = 1;
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
	local pos = self.data:GetOrigin()
	local angles = self.data:GetAngles()
	local pemit = ParticleEmitter( pos, false )
	local smoke = pemit:Add( Material("materials/action/Antorbok_Project.png"), pos )
	
	for i = 0, self.particles do
		if smoke then
			smoke:SetAngles( angles )
			smoke:SetVelocity( Vector( 0, 0, 15 ) )
			smoke:SetColor( 255, 102, 0 )
			smoke:SetLifeTime( 0 )
			smoke:SetDieTime( 3 )
			smoke:SetStartAlpha( 255 )
			smoke:SetEndAlpha( 0 )
			smoke:SetStartSize( 10 )
			smoke:SetEndSize( 15 )
		end
	end
	pemit:Finish()
end