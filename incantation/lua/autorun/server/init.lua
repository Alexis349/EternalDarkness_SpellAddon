util.AddNetworkString("sendMana");
util.AddNetworkString("sendRune");
util.AddNetworkString("sendCast");
util.AddNetworkString("sendRuneMenu");

local p = FindMetaTable("Player");

spells = {
	["Enchant"] = {"project", "item", function(ply, alignment) --gonna need to revise this asap!
		if ply.mana < ply.spellPower*10 then
			return print("Not Enough Mana")
		end
		local wep = ply:GetActiveWeapon()
		ply:createEffect();
		ply.casting = true;
		timer.Simple(3, function() --start buff
			ply.casting = false;
			if ply:Alive() then
				wep.damage = wep.damage*1.5;
			end
			timer.Simple(15, function() --take away buff
				if ply:Alive() then
					wep.damage = wep.damage/1.5;
				end
			end)
		end)
		ply:setMana(-ply.spellPower*10)
	end, "Enchant"},
	["Recover"] = {"absorb", "self", function(ply, alignment)
		if ply.mana < ply.spellPower*10 then
			return print("Not Enough Mana")
		end
		ply:createEffect()
		ply.casting = true;
		timer.Simple(3, function()
			ply.casting = false;
			ply:SetHealth(math.Clamp(ply:Health()+ply.spellPower*10, 0, 100))
		end)
		ply:setMana(-ply.spellPower*10)
	end, "Recover"},
	["Shield"] = {"protect", "self", function(ply, alignment)
		if ply.mana < 10*ply.spellPower+5 then
			return print("Not Enough Mana")
		end
		ply:createEffect()
		ply.casting = true;
		timer.Simple(3, function()
			ply.casting = false;
			ply.shield = 100;
			timer.Simple(15, function()
				ply.shield = 0;
			end)
		end)
		ply:setMana(-(ply.spellPower*10+5))
	end, "Shield"},
	["Zombie"] = {"summon", "creature", function(ply, alignment)
		if ply.mana < 50 then
			return print("Not Enough Mana")
		end
		ply:createEffect()
		ply.casting = true;
		timer.Simple(3, function()
			ply.casting = false;
			local zombie = ents.Create("npc_zombie");
			zombie:SetPos(ply:GetPos() + Vector(-200, 0, 0))
			zombie:Spawn()
			zombie:AddEntityRelationship(ply, D_LI, 99)
			zombie:SetOwner(ply)
		end)
		ply:setMana(-50)
	end, "Zombie"},
	["Attack"] = {"project", "area", function(ply, alignment)
		if ply.mana < (10*ply.spellPower+10) then
			return print("Not Enough Mana")
		end
		ply:createEffect()
		ply.casting = true;
		timer.Simple(3, function()
			ply.casting = false;
			for k, v in pairs(ents.FindInSphere(ply:GetPos(), 300)) do
				if v:IsNPC() or v:IsPlayer() then
					if v != ply then
						v:TakeDamage(ply.spellPower*10)
					end
				end
			end
		end)
		ply:setMana(-(10*(ply.spellPower)+10))
	end, "Attack"},
};

hook.Add("PlayerInitialSpawn", "initSpawn", function(ply)
	ply.mana = ply.mana or 100;
	ply.spellPower = 3;
	ply.shield = 0;
	ply.casting = false;
	ply:setMana(0)
	ply.runes = {};
	timer.Create("updateMana", 1, 0, function()
		if IsValid(ply) then
			if ply:Alive() then
				ply:setMana(1)
			end
		end
	end)
end)

hook.Add("PlayerSpawn", "initRespawn", function(ply)
	ply.mana = 100;
	ply.shield = 0;
	ply.casting = false;
	ply:setMana(0)
	ply.runes = {};
end)

hook.Add("PlayerShouldTakeDamage", "shieldApply", function(ply, attacker)
	if ply.shield > 0 then
		return false
	end
	return true
end)

hook.Add("EntityTakeDamage", "shieldApply", function(target, dmginfo)
	if target:IsPlayer() and target.shield > 0 then
		target.shield = math.Clamp(target.shield - dmginfo:GetDamage(), 0, 100)
	end
end)

function p:setMana(int)
	self.mana = math.Clamp(self.mana + int, 0, 100);
	net.Start("sendMana")
		net.WriteInt(self.mana, 32)
	net.Send(self)
end

function p:setRunes(index, val)
	self.runes = self.runes or {};
	self.runes[index] = val;
end

function p:getRunes()
	self.runes = self.runes or {};
	return self.runes;
end

function p:clearRunes()
	table.Empty(self.runes)
end

function p:setPower(int)
	--reminder:Don't go above 9; Starts at 2(for the two base runes)
	self.spellPower = int;
end

function p:createEffect()
	self:SetWalkSpeed(self:GetWalkSpeed()/2)
	self:SetRunSpeed(self:GetRunSpeed()/2)
	timer.Simple(3, function()
		self:SetWalkSpeed(self:GetWalkSpeed()*2)
		self:SetRunSpeed(self:GetRunSpeed()*2)
	end)
end

concommand.Add("castIncantation", function(ply, cmd, args)
	if !spells[args[1]] then return print("Not valid spell") end
	if ply:getRunes()[1] == spells[args[1]][1] and ply:getRunes()[2] == spells[args[1]][2] and ply:getRunes()[3] != nil then --made a small change here
		if ply.casting == false then
			ply:clearRunes()
			return spells[args[1]][3](ply, ply:getRunes()[3])
		end
	elseif ply:getRunes()[1] == spells[args[1]][1] and ply:getRunes()[2] != spells[args[1]][2] then
		print("Missing runes: "..spells[args[1]][2])
	elseif ply:getRunes()[1] != spells[args[1]][1] and ply:getRunes()[2] == spells[args[1]][2] then
		print("Missing runes: "..spells[args[1]][1])
	else
		print("Missing all runes!")
	end
end)

function IsVar(var)
	local alignments = {"ulyaoth", "chatturgha", "xellotath"};
	for _, v in pairs(alignments) do
		if var == v then
			return var
		end
	end
end

net.Receive("sendRune", function(len, ply)
	local rune = net.ReadString();
	for k, v in pairs(spells) do
		if rune == spells[k][1] then
			ply:setRunes(1, rune)
		elseif rune == spells[k][2] then
			ply:setRunes(2, rune)
		elseif IsVar(rune) then
			ply:setRunes(3, rune) --for alignments
		end
	end
end)

net.Receive("sendCast", function(len, ply)
	RunConsoleCommand("castIncantation", FindSpell(ply:getRunes()))
end)

function FindSpell(args) --find a spell by it's name(fourth index within spell's table) for the cast function
	for k, v in pairs(spells) do
		if args[1] == v[1] and args[2] == v[2] then
			return v[4]
		end
	end
end

hook.Add("PlayerButtonDown", "detectButton", function(ply, button)
	if button == KEY_X then
		net.Start("sendRuneMenu")
		net.Send(ply)
	end
end)
hook.Add("PlayerButtonUp", "detectButton", function(ply, button)
	if button == KEY_X then
		net.Start("sendRuneMenu")
		net.Send(ply)
	end
end)