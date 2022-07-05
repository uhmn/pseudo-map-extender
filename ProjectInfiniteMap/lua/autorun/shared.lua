if (!CLIENT) then
	
	util.AddNetworkString( "net_pim_holotable" )
	util.AddNetworkString( "net_pim_update" )
	util.AddNetworkString( "net_pim_remove" )
	util.AddNetworkString( "net_pim_dimensiontable" )
	
	function pimRemove(dest, i, tableid)
		table.remove(dest, i)
		net.Start( "net_pim_remove" )
			net.WriteUInt(tableid, 8)
			net.WriteUInt(i, 32)
		net.Broadcast()
	end
	
	function pimUpdate(data)
		net.Start( "net_pim_update" )
			net.WriteDouble(data[2][1])
			net.WriteDouble(data[2][2])
			net.WriteDouble(data[2][3])
			net.WriteEntity(data[1])
			--net.WriteVector(data[2])
	
		net.Broadcast()
	end
	
	function pimUpdateHolo(dest, data)
		table.insert(dest, data)
		net.Start( "net_pim_holotable" )
			--net.WriteVector(data[1])
			net.WriteDouble(data[1][1])
			net.WriteDouble(data[1][2])
			net.WriteDouble(data[1][3])
			net.WriteString(data[2])
			net.WriteAngle(data[3])
			net.WriteString(data[4])
			net.WriteBool(data[5])
		net.Broadcast()
	end
	
	function pimUpdateDimTable(dest, data)
		table.insert(pim_dimensiontable, data)
		net.Start( "net_pim_dimensiontable" )
			net.WriteEntity(data)
		net.Broadcast()
	end
	
	
	function netReplace(dest, offset, data)
		dest[offset] = data
	end
end

if (game.GetMap() == "gm_spacebox") then
	
	hook.Add( "Think", "Space_Test_Think", function()
		if pim_enabled == true then
			for kdm, dim in pairs(pim_dimensiontable) do 
				local pim_center = dim:GetPos()
				local ply = dim.pim_pair
				
				if (ply:InVehicle()) then ply = ply:GetVehicle() end
				if (ply:GetParent():IsValid()) then ply = ply:GetParent() end
				
				local pim_ents1 = ents.IsSpecEntityInBox( pim_center - pim_size, pim_center + pim_size, ply )
				local pim_ents2 = ents.IsSpecEntityInBox( pim_center - pim_size*0.25, pim_center + pim_size*0.25, ply )
				
				if (pim_ents1 == true and pim_ents2 == false ) then
					local PosOffset = 0
					local VelOffset = 0
					PosOffset = ply:GetPos() - pim_center
					VelOffset = ply:GetVelocity()
					dim.pim_location = dim.pim_location + PosOffset
					dim.pim_velocity = dim.pim_velocity + VelOffset
					local vel = ply:GetVelocity()
					local phys = ply:GetPhysicsObject()
					ply:SetPos(pim_center)
					if ply:IsPlayer() == false then
						phys:SetVelocity(vel)
					end
					local pim_ents3 = ents.FindInBox( pim_center - pim_size, pim_center + pim_size )
					for k, v in pairs(pim_ents3) do
						if v ~= ply and v:IsPlayer() == false and v:GetClass() ~= "pim_sdc" and v:GetParent():IsValid() == false then
							local phys = v:GetPhysicsObject()
							if ( IsValid( phys ) ) then
								local tele_offset = v:GetPos() - PosOffset
								if ( tele_offset:WithinAABox( (pim_center - pim_size*0.9), (pim_center + pim_size*0.9) ) ) then
									local vel = v:GetVelocity()
									local phys = v:GetPhysicsObject()
									--if phys:IsValid() then
									--	phys:SetPos(tele_offset)
									--end
									v:SetPos(tele_offset)
									phys:SetVelocity(vel)
								else
									pim_unload( v, dim, tele_offset, skyCamPos )
								end
							end
						end
					end
					--pim_ents3 = ents.FindInBox( skyCamPos - pim_size, skyCamPos + pim_size )
					--for k, v in pairs(pim_ents3) do
					--	if v:GetClass() == "prop_dynamic" then
					--		local tele_offset = ((pim_proptable[v.pim_off][1] - dim.pim_location) / 64) + skyCamPos + (pim_center/64)
					--		if ( tele_offset:WithinAABox( (skyCamPos - pim_size*0.9), (skyCamPos + pim_size*0.9) ) ) then
					--			v:SetPos(tele_offset)
					--		else
					--			v:Remove()
					--			print("Sky Entity Unloaded")
					--		end
					--		local teleconverted = tele_offset
					--		if teleconverted:WithinAABox( pim_dimtosky((pim_center - pim_size*0.75), dim.pim_location, skyCamPos, 64), pim_dimtosky((pim_center + pim_size*0.75), dim.pim_location, skyCamPos, 64) ) then
					--			print("Entity Reloaded")
					--			pim_reload( v, dim, pim_center)
					--		end
					--	end
					--end
					local i = 1
					while #pim_proptable >= i do
						v = pim_proptable[i]
						local tele_offset = ((v[1] - dim.pim_location) / 64) + skyCamPos + (pim_center/64)
						--if ( tele_offset:WithinAABox( (skyCamPos - pim_size*0.9), (skyCamPos + pim_size*0.9) ) ) then
						--	v:SetPos(tele_offset)
						--else
						--	v:Remove()
						--	print("Sky Entity Unloaded")
						--end
						local tele_offset2 = v[1]
						if tele_offset2:WithinAABox( pim_DimToPos(pim_center - pim_size*0.75, pim_center, dim.pim_location), pim_DimToPos(pim_center + pim_size*0.75, pim_center, dim.pim_location) ) then
							pim_reload( v, dim, pim_center)
							pimRemove( pim_proptable, i, 1 )
							i = i - 1
						end
						i = i + 1
					end
					for k, v in pairs(pim_dimensiontable) do
						if v ~= dim and pim.pim_location:WithinAABox( v.pim_location - pim_size*0.5, v.pim_location + pim_size*0.5 ) then
							for key, ent in pairs(pim_ents3) do
								if ent:GetClass() ~= "pim_sdc" and v:GetParent():IsValid() == false then
									local phys = ent:GetPhysicsObject()
									if ( IsValid( phys ) ) then
										local tele_offset = (ent:GetPos() - dim:GetPos()) + v:GetPos()
										local vel = ent:GetVelocity()
										local phys = ent:GetPhysicsObject()
										ent:SetPos(tele_offset)
										phys:SetVelocity(vel)
									end
								end
							end
						end
					end
					local pim_ents1 ents.FindInBox( pim_center - pim_size, pim_center + pim_size )
					local pim_ents2 ents.FindInBox( pim_center - pim_size*0.75, pim_center + pim_size*0.75 )
					--for k, v in pairs(pim_ents1) do
					--	if not v in pim_ents2 then
					--		if v:IsPlayer() or v:GetClass() = "pim_persistent" then
					--			print("Forked")
					--			pim_CREATEDIMENSION( v, nil, (v:GetPos-pim_center) + dim.pim_location, Vector(0, 0, 0) )
					--			local persists = ents.FindPlayersInBox( pim_center - pim_size, pim_center + pim_size )
					--			if persists == nil then
					--				dim.pim_pair = nil
					--			else
					--				dim.pim_pair = persists[1]
					--				if #persists > 1 then
					--					for key, ent in pairs(persists) do
					--						pim_CREATEDIMENSION( ent, nil, (ent:GetPos-pim_center) + dim.pim_location, Vector(0, 0, 0) )
					--					end
					--				end
					--			end
					--		end
					--	end
					--end
					pimUpdate({dim, dim.pim_location})
				end
			end
		end
	end )
	
	hook.Add( "InitPostEntity", "Space_Test_Init", function()
		skyCamPos = ents.FindByClass("pim_skycam")[1]:GetPos()
	end )
end
