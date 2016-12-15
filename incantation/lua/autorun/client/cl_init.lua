local smoothHealth = 100;
local smoothMana = 100;

runes = {
	[1] = {name = "chatturgha", mat = "materials/alignment/Chattur'gha.png", Display = "Chattur'gha - Alignment",},
	[2] = {name = "ulyaoth", mat = "materials/alignment/Ulyaoth.png", Display = "Ulyaoth - Alignment",},
	[3] = {name = "xellotath", mat = "materials/alignment/Xel'lotath.png", Display = "Xel'lotath - Alignment",},
	[4] = {name = "project", mat = "materials/action/Antorbok_Project.png", Display = "Antorbok - Project",},
	[5] = {name = "protect", mat = "materials/action/Bankorok_Protect.png", Display = "Bankorok - Protect",},
	[6] = {name = "absorb", mat = "materials/action/Narokath_Absorb.png", Display = "Narokath - Absorb",},
	[7] = {name = "dispell", mat = "materials/action/Nethlek_Dispell.png", Display = "Nethlek - Dispell",},
	[8] = {name = "summon", mat = "materials/action/Tier_Summon.png", Display = "Tier - Summon",},
	[9] = {name = "creature", mat = "materials/target/Aretak_Creature.png", Display = "Aretak - Creature",},
	[10] = {name = "area", mat = "materials/target/Redgormor_Area.png", Display = "Redgormor - Area",},
	[11] = {name = "self", mat = "materials/target/Santak_Self.png", Display = "Santak - Self",},
	[12] = {name = "item", mat = "materials/target/Magormor_Item.png", Display = "Magormor - Item",},
};
buttons = {};

function FindButtons()
	for k, v in pairs(buttons) do
		if gui.MouseX() > v.MinX and gui.MouseX() < v.MaxX and gui.MouseY() > v.MinY and gui.MouseY() < v.MaxY then
			return k
		end
	end
	return nil
end

function PointOnCircle(ang, radius, offX, offY) --from wiki
	ang = math.rad(ang)
	local x = math.cos(ang)*radius+offX
	local y = math.sin(ang)*radius+offY
	return x, y
end

net.Receive("sendMana", function(len)
	mana = net.ReadInt(32)
end)

hook.Add("HUDPaint", "painthud", function()
	local ply = LocalPlayer();
	smoothHealth = Lerp(2*FrameTime(), smoothHealth, ply:Health())
	smoothMana = Lerp(2*FrameTime(), smoothMana, mana)
	
	if mana > 0 then
		draw.RoundedBox(4, ScrW()/2.4, ScrH()-(ScrH()*0.037), 300*smoothMana/100, ScrH()*0.027, Color(0,0,180))
	end
	
	if ply:Health() > 0 then
		draw.RoundedBox(4, ScrW()/2.4, ScrH()-(ScrH()*0.083), 300*smoothHealth/ply:GetMaxHealth(), ScrH()*0.027, Color(180,0,0))
	end
	
	local interval = 360/#runes;
	if menu == true then
		for degrees = 1, 360, interval do
			local x, y = PointOnCircle(degrees, 120, ScrW()/2, ScrH()/2)
			local index = (degrees-1)/30;
			draw.RoundedBox(4, x, y, 40, 40, Color(50,50,50,240))
			surface.SetDrawColor(255,255,255,255)
			if degrees == 1 then
				buttons[index] = buttons[index] or {};
				buttons[index].Mat = runes[12].mat;
				buttons[index].Name = runes[12].name;
				buttons[index].Display = runes[12].Display;
				buttons[index].MinX = x;
				buttons[index].MaxX = (x)+40;
				buttons[index].MinY = y;
				buttons[index].MaxY = y+40;
				surface.SetMaterial(Material(runes[12].mat))
			elseif degrees > 1 then
				buttons[index] = buttons[index] or {};
				buttons[index].Mat = runes[index].mat;
				buttons[index].Name = runes[index].name;
				buttons[index].Display = runes[index].Display;
				buttons[index].MinX = x;
				buttons[index].MaxX = (x)+40;
				buttons[index].MinY = y;
				buttons[index].MaxY = y+40;
				surface.SetMaterial(Material(runes[(degrees-1)/30].mat))
			end
			surface.DrawTexturedRect( x, y, 40, 40 )
		end
		if FindButtons() then
			draw.SimpleText(buttons[FindButtons()].Display, "DermaDefault", gui.MouseX(), gui.MouseY(), Color(255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
		end
	end
end)

hook.Add("GUIMousePressed", "detectClick", function(mc)
	if FindButtons() and buttons[FindButtons()] and menu == true then
		if mc == MOUSE_LEFT then
			print("Clicked on "..buttons[FindButtons()].Name)
			surface.PlaySound("buttons/blip1.wav")
			net.Start("sendRune")
				net.WriteString(buttons[FindButtons()].Name)
			net.SendToServer()
		end
	end
	if mc == MOUSE_RIGHT then
		print("Spell is beginning to cast.")
		surface.PlaySound("buttons/lever4.wav")
		net.Start("sendCast")
		net.SendToServer()
	end
end)

menu = false;
net.Receive("sendRuneMenu", function(len)
	if menu == false then
		menu = true;
		gui.EnableScreenClicker(menu)
	elseif menu == true then
		menu = false;
		gui.EnableScreenClicker(menu)
	end
end)