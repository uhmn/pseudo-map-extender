
pim_enabled = false
pim_size = Vector( 7616, 7616, 7616 )
pim_dimensiontable = {}
pim_proptable = {}
pim_propholograms = {}
pim_terrainStarted = false

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
	
		net.Broadcast()
	end
	
	function pimUpdateHolo(dest, data)
		table.insert(dest, data)
		net.Start( "net_pim_holotable" )
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
	
	function terrainupdate (plypos, vert, mu, location, center, gridsize)
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
			xa = xa - xd
			za = za - zd
			vert[i].pos = Vector(xa, za, ((pperlin(location[1] + (xa-center[1]), location[2] + (za-center[2]), 4)-location[3])+center[3]) )
		end
		return (vert)
	end
	
	function fillvert (power, vert1, vert2)
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
end

local function createScatterProp(location)
	local ent = ents.Create("prop_physics")
	ent:SetModel("models/props_foliage/tree_springers_01a.mdl")
	ent:SetPos(location)
	ent:Spawn()
	pim_terrainphys = ent:GetPhysicsObject()
	ent:SetName("TerrainScatter")
	ent:SetSolid(SOLID_VPHYSICS)
	pim_terrainphys:EnableMotion(false)
end

local function terrainScatter(amount, center, location)
	vert1 = center - pim_size
	vert2 = center + pim_size
	local i = 0
	while i < amount do
		local x = math.random(vert1[1], vert2[1])
		local z = math.random(vert1[2], vert2[2])
		local y = ((pperlin(location[1] + (x-center[1]), location[2] + (z-center[2]), 4)-location[3])+center[3]) - 40
		createScatterProp(Vector(x,z,y))
		i = i + 1
	end
end

if (game.GetMap() == "gm_spaceboxsp") then
	if (!CLIENT) then
		hook.Add( "InitPostEntity", "FAKK", function ()
			pim_terrainent = ents.Create("prop_physics")
			pim_terrainent:SetModel("models/props_lab/cactus.mdl")
			pim_terrainent:SetPos(Vector( 0 , 0 , 0 ), 1)
			pim_terrainent:Spawn()
			pim_terrainphys = pim_terrainent:GetPhysicsObject()
			pim_terrainphys:EnableMotion(false)
			pim_terrainent:SetName("TerrainCollision")
			pim_terrainent:SetMaterial("grass")
			pim_terrainent:DrawShadow( false )
			pim_terrainent:SetSolid(SOLID_VPHYSICS)
			pim_terrainent:EnableCustomCollisions( true )
			pim_terrainent:PhysicsFromMesh( pim_verts )
			pim_terrainphys = pim_terrainent:GetPhysicsObject()
			pim_terrainphys:EnableMotion(false)
		end )
	end
	hook.Add( "Think", "Space_Test_Think", function()
		if pim_enabled == true then
			for kdm, dim in pairs(pim_dimensiontable) do 
				local pim_center = dim:GetPos()
				local ply = dim.pim_pair
				
				if (ply:InVehicle()) then ply = ply:GetVehicle() end
				if (ply:GetParent():IsValid()) then ply = ply:GetParent() end
				
				local pim_ents1 = ents.IsSpecEntityInBox( pim_center - pim_size, pim_center + pim_size, ply )
				local pim_ents2 = ents.IsSpecEntityInBox( pim_center - pim_size*0.25, pim_center + pim_size*0.25, ply )
				
				if pim_terrainStarted == false then
					pim_terrainStarted = true
					pimUpdate({dim, dim.pim_location})
				end
				
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
						if v ~= ply and v:IsPlayer() == false and v:GetClass() ~= "pim_sdc" and v:GetParent():IsValid() == false and v:GetName() ~= "TerrainCollision" then
							local phys = v:GetPhysicsObject()
							if ( IsValid( phys ) ) then
								local tele_offset = v:GetPos() - PosOffset
								if ( tele_offset:WithinAABox( (pim_center - pim_size*0.9), (pim_center + pim_size*0.9) ) ) then
									local vel = v:GetVelocity()
									local phys = v:GetPhysicsObject()
									v:SetPos(tele_offset)
									phys:SetVelocity(vel)
								else
									if v:GetName() ~= "TerrainScatter" then
										pim_unload( v, dim, tele_offset, skyCamPos )
									else
										v:Remove()
									end
								end
							end
						end
					end
					local i = 1
					while #pim_proptable >= i do
						v = pim_proptable[i]
						local tele_offset = ((v[1] - dim.pim_location) / 64) + skyCamPos + (pim_center/64)
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
					pimUpdate({dim, dim.pim_location})
					local i = 0
					for k, v in pairs(pim_ents3) do
						if v:GetName() == "TerrainScatter" then
							i = i + 1
						end
					end
					i = 4 - i
					if i > 0 then terrainScatter(i, pim_center, dim.pim_location) end
					pim_verts = fillvert(8, pim_center-pim_size, pim_center+pim_size)
					pim_verts = terrainupdate(ply:GetPos(), pim_verts, 1, dim.pim_location, pim_center, (pim_size[1]*2)/8)
					pim_terrainent:PhysicsFromMesh( pim_verts )
					pim_terrainphys = pim_terrainent:GetPhysicsObject()
					pim_terrainphys:EnableMotion(false)
				end
			end
		end
	end )
	
	hook.Add( "InitPostEntity", "Space_Test_Init", function()
		skyCamPos = ents.FindByClass("pim_skycam")[1]:GetPos()
	end )
end
