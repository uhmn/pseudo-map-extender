
if (game.GetMap() == "gm_spacebox") then
	print("SpaceTest Enabled!")
	
	hook.Add( "Think", "Space_Test_Think", function()
		if pim_enabled == true then
			for k in pairs(pim_dimensiontable) do 
				local pim_center = pim_dimensiontable[k]:GetPos()
				local attachment = pim_dimensiontable[k].pim_pair
				local pim_ents1 = ents.FindPlayersInBox( pim_center - pim_size, pim_center + pim_size )
				local pim_ents2 = ents.FindPlayersInBox( pim_center - pim_size*0.25, pim_center + pim_size*0.25 )
				
				if (pim_ents1[1] ~= nil and pim_ents2[1] == nil ) then
					local PosOffset = 0
					local VelOffset = 0
					if (pim_ents1[1]:InVehicle()) then
						pim_ents1[1] = pim_ents1[1]:GetVehicle()
					end
					PosOffset = pim_ents1[1]:GetPos() - pim_center
					VelOffset = pim_ents1[1]:GetVelocity()
					local pim_ents3 = ents.FindInBox( pim_center - pim_size, pim_center + pim_size )
					pim_dimensiontable[k].pim_location = pim_dimensiontable[k].pim_location + PosOffset
					pim_dimensiontable[k].pim_velocity = pim_dimensiontable[k].pim_velocity + VelOffset
					pim_ents1[1]:SetPos(pim_center)
					for i in pairs(pim_ents3) do
						if pim_ents3[i] ~= attachment and pim_ents3[i] ~= pim_ents1[1] and pim_ents3[i]:IsPlayer() == false and pim_ents3[i]:GetClass() ~= "pim_sdc" then
							local phys = pim_ents3[i]:GetPhysicsObject()
							if ( IsValid( phys ) ) then
								local tele_offset = pim_ents3[i]:GetPos() - PosOffset
								if ( tele_offset:WithinAABox( (pim_center - pim_size*0.9), (pim_center + pim_size*0.9) ) ) then
									pim_ents3[i]:SetPos(tele_offset)
								else
									pim_unload( pim_ents3[i], pim_dimensiontable[k], tele_offset )
									print("Entity Unloaded")
								end
							end
						end
					end
					local pim_ents3 = ents.FindInBox( skyCamPos - pim_size, skyCamPos + pim_size )
					for i in pairs(pim_ents3) do
						if pim_ents3[i]:GetClass() == "prop_dynamic" then
							local tele_offset = pim_ents3[i]:GetPos() - (PosOffset/16)
							if ( tele_offset:WithinAABox( (skyCamPos - pim_size*0.9), (skyCamPos + pim_size*0.9) ) ) then
								pim_ents3[i]:SetPos(tele_offset)
							else
								pim_ents3[i]:Remove()
								print("Sky Entity Unloaded")
							end
							local teleconverted = tele_offset
							--print(tostring(teleconverted) .. " | " .. tostring(pim_dimtosky((pim_center - pim_size*0.75), pim_dimensiontable[k].pim_location, skyCamPos, 16)) .. " | " .. tostring(pim_dimtosky((pim_center + pim_size*0.75), pim_dimensiontable[k].pim_location, skyCamPos, 16)))
							if teleconverted:WithinAABox( pim_dimtosky((pim_center - pim_size*0.75), pim_dimensiontable[k].pim_location, skyCamPos, 16), pim_dimtosky((pim_center + pim_size*0.75), pim_dimensiontable[k].pim_location, skyCamPos, 16) ) then
								print("Entity Reloaded")
								pim_reload( pim_ents3[i], pim_dimensiontable[k], pim_center)
								--print("Entity Reloaded!!")
							end
						end
					end
				end
			end
		end
	end )
	
	hook.Add( "InitPostEntity", "Space_Test_Init", function()
		skyCamPos = ents.FindByClass("pim_skycam")[1]:GetPos()
		pim_enabled = true
		print("Space Test " .. tostring(pim_enabled))
	end )
end

