
AddCSLuaFile()

if (!SERVER) then
	print("SpaceTest Client Started")
	net.Receive( "net_pim_holotable", function( len, ply )
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
		table.insert( pim_dimensiontable, net.ReadEntity() )
	end )
	
	local function terrainupdate (plypos, vert, location, center, gridsize)
		local pl_x = plypos[1]
		local pl_z = plypos[2]
		local pl_y = plypos[3]
		local x = pim_DimToPos(vert[1].pos, center, location)[1]
		local z = pim_DimToPos(vert[1].pos, center, location)[2]
		local xd = x%gridsize
		local zd = z%gridsize
		for i = 1, #vert, 1 do
			local xa = vert[i].pos[1]
			local za = vert[i].pos[2]
			xa = (xa - xd)
			za = (za - zd)
			vert[i].pos = Vector(xa, za, ((pperlin(location[1] + (xa-center[1]), location[2] + (za-center[2]), 4)-location[3])+center[3]) )
		end
		return (vert)
	end
	
	local function skyterrainupdate (plypos, vert, mu, location, center, gridsize, skypos)
		local pl_x = plypos[1]
		local pl_z = plypos[2]
		local pl_y = plypos[3]
		local x = pim_DimToPos(vert[1].pos, center, location)[1]
		local z = pim_DimToPos(vert[1].pos, center, location)[2]
		local xd = x%gridsize
		local zd = z%gridsize
		for i = 1, #vert, 1 do
			local xa = vert[i].pos[1]
			local za = vert[i].pos[2]
			xa = (xa - xd)*mu
			za = (za - zd)*mu
			vert[i].pos = pim_dimtosky(Vector(xa, za, ((pperlin(location[1] + (xa-center[1]), location[2] + (za-center[2]), 4)-location[3])+center[3]) ), center, skypos, 64)
		end
		return (vert)
	end
	
	local function fillvert (power, vert1, vert2)
		local vert = {}
		local x1 = vert1[1]
		local z1 = vert1[2]
		local x2 = vert2[1]
		local z2 = vert2[2]
		local x2b = ( ( x2 - x1 ) / power ) + x1
		local z2b = ( ( z2 - z1 ) / power ) + z1
		local xb = math.abs(x1 - x2b)
		local zb = math.abs(z1 - z2b)
		local count = 1
		for i = 1, power, 1
		do
			for e = 1, power, 1
			do
				local xb1 = x1 + (xb*(e))
				local zb1 = z1 + (zb*(i))
				local xb2 = x2b + (xb*(e))
				local zb2 = z2b + (zb*(i))
				vert[count*6-5] = { pos = Vector( xb2 , zb2 , 0) , u = 1, v = 1 }
				vert[count*6-4] = { pos = Vector( xb2 , zb1 , 0) , u = 1, v = 0 }
				vert[count*6-3] = { pos = Vector( xb1 , zb1 , 0) , u = 0, v = 0 }
				vert[count*6-2] = { pos = Vector( xb1 , zb2 , 0) , u = 0, v = 1 }
				vert[count*6-1] = { pos = Vector( xb2 , zb2 , 0) , u = 1, v = 1 }
				vert[count*6  ] = { pos = Vector( xb1 , zb1 , 0) , u = 0, v = 0 }
				count = count + 1
			end
		end
		return (vert)
	end
	

	pim_size = Vector( 7616, 7616, 7616 )
	local mat1 = Material("grass")
	local mat2 = Material("grass4")
	local mat3 = Material("grass8")
	local obj = Mesh()
	local skyobj1 = Mesh()
	local skyobj2 = Mesh()
	obj:BuildFromTriangles( verts )
	hook.Add( "PreDrawOpaqueRenderables", "FAKK_Land1", function()
		render.SetLightingMode(2)
		render.SetMaterial( mat1 )
		obj:Draw()
		render.SetLightingMode(0)
	end )
	hook.Add( "PostDraw2DSkyBox", "FAKK_Land2", function()
		render.SetLightingMode(2)
		render.SetMaterial( mat3 )
		skyobj1:Draw()
		render.SetLightingMode(0)
	end )
	
	local skyTerrainGenerated = false
	function pim_holograms()
		local entCenter = LocalPlayer()
		if (entCenter:InVehicle()) then entCenter = entCenter:GetVehicle() end
		if (entCenter:GetParent():IsValid()) then entCenter = entCenter:GetParent() end
		pim_currentdim = pim_GetCurrentDim(entCenter)
		local pim_center = pim_currentdim:GetPos()
		local pim_location = pim_currentdim.pim_location
		i = 0
		while i < #pim_propholograms do
				i = i + 1
				v = pim_propholograms[i]
				if pim_proptable[i] == nil then
					v:Remove()
					table.remove( pim_propholograms, i )
					i = i - 1
				else
					v:SetPos( pim_dimtosky(pim_PosToDim(pim_proptable[i][1], pim_center, pim_location), pim_center, skyCamPos, 64))
					v:SetAngles( pim_proptable[i][3] )
					v:SetModel( pim_proptable[i][4] )
					if pim_proptable[i][5] then
						v:SetModelScale( 1/64 , 0 )
					else
						v:SetModelScale( 0 , 0 )
					end
				end
		end
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
		skyverts1 = fillvert(12, pim_center-pim_size, pim_center+pim_size)
		skyverts1 = skyterrainupdate(entCenter:GetPos(), skyverts1, 8, pim_location, pim_center, (pim_size[1]*2)/8, skyCamPos)
		skyobj1:Destroy()
		skyobj1 = Mesh()
		skyobj1:BuildFromTriangles( skyverts1 )	
		verts = fillvert(8, pim_center-pim_size, pim_center+pim_size)
		verts = terrainupdate(entCenter:GetPos(), verts, pim_location, pim_center, (pim_size[1]*2)/8)
		obj:Destroy()
		obj = Mesh()
		obj:BuildFromTriangles( verts )	
	end
	local entity
	
	concommand.Add( "test_pim_ent", function( ply )
	
		pim_holograms()
		
	end )
end

