

if (!SERVER) then
	print("SpaceTest Client Started")
	net.Receive( "net_pim_holotable", function( len, ply )
		--local n1 = net.ReadVector()
		local n1a = net.ReadDouble()
		local n1b = net.ReadDouble()
		local n1c = net.ReadDouble()
		local n1 = Vector(n1a, n1b, n1c)
		local n2 = net.ReadString()
		local n3 = net.ReadAngle()
		local n4 = net.ReadString()
		local n5 = net.ReadBool()
		table.insert( pim_proptable, {n1, n2, n3, n4, n5} )
	end )
	net.Receive( "net_pim_update", function( len, ply )
		local n1a = net.ReadDouble()
		local n1b = net.ReadDouble()
		local n1c = net.ReadDouble()
		local n1 = Vector(n1a, n1b, n1c)
		net.ReadEntity().pim_location = n1
		pim_holograms()
	end )
	net.Receive( "net_pim_remove", function( len, ply )
		local netTable = net.ReadUInt(8)
		local tabl = {}
		if netTable == 1 then tabl = pim_proptable
		end
		table.remove( tabl, net.ReadUInt(32) )
	end )
	net.Receive( "net_pim_dimensiontable", function( len, ply )
		--print("pim_dimensiontable recieved: " .. tostring(net.ReadEntity()))
		table.insert( pim_dimensiontable, net.ReadEntity() )
	end )

	function pim_holograms()
		print(#pim_dimensiontable)
		print(pim_dimensiontable[1])
		local entCenter = LocalPlayer()
		if (entCenter:InVehicle()) then entCenter = entCenter:GetVehicle() end
		if (entCenter:GetParent():IsValid()) then entCenter = entCenter:GetParent() end
		print("entity: " .. tostring(entCenter))
		pim_currentdim = pim_GetCurrentDim(entCenter)
		print(pim_currentdim)
		local pim_center = pim_currentdim:GetPos()
		local pim_location = pim_currentdim.pim_location
		for k, v in pairs(pim_propholograms) do
			--v:Remove()
			v:SetPos( pim_dimtosky(pim_PosToDim(pim_proptable[k][1], pim_center, pim_location), pim_center, skyCamPos, 64))
			v:SetAngles( pim_proptable[k][3] )
			v:SetModel( pim_proptable[k][4] )
			if pim_proptable[k][5] then
				v:SetModelScale( 1/64 , 0 )
			else
				v:SetModelScale( 0 , 0 )
				if k > #pim_proptable then
					--v:Remove()
					--table.remove( pim_propholograms, k )
				end
			end
		end
		print(pim_center)
		print(pim_location)
		print("proptable" .. tostring(#pim_proptable))
		print("propholograms" .. tostring(#pim_propholograms))
		if #pim_proptable > #pim_propholograms then
			i = #pim_propholograms
			while #pim_proptable > #pim_propholograms do
				i = i + 1
				local ent = ClientsideModel( pim_proptable[i][4] )
				if ( not ent:IsValid() ) then return end
				ent:SetModelScale( 1/64 , 0 )
				ent:SetPos( pim_dimtosky(pim_PosToDim(pim_proptable[i][1], pim_center, pim_location), pim_center, skyCamPos, 64))
				ent:SetAngles( pim_proptable[i][3] )
				ent:Spawn()
				table.insert( pim_propholograms, ent )
			end
		end
		print("proptable" .. tostring(#pim_proptable))
		print("propholograms" .. tostring(#pim_propholograms))
	end
	local entity
	
	concommand.Add( "test_pim_ent", function( ply )
	
		pim_holograms()
		
	end )
end

