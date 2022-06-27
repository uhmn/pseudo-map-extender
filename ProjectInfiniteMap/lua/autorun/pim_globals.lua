
pim_enabled = false
pim_size = Vector( 3808, 3808, 3808 )
pim_dimensiontable = {}
pim_proptable = {}
pim_propholograms = {}

function ents.IsSpecEntityInBox( vCorner1, vCorner2, ent )
	local tEntities = ents.FindInBox( vCorner1, vCorner2 )
	
	for i = 1, #tEntities do
		if ( tEntities[ i ] == ent ) then
			return true
		end
	end
	
	return false
end

function ents.FindPlayersInBox( vCorner1, vCorner2 )
	local tEntities = ents.FindInBox( vCorner1, vCorner2 )
	local tPlayers = {}
	local iPlayers = 0
	
	for i = 1, #tEntities do
		if ( tEntities[ i ]:IsPlayer() ) then
			iPlayers = iPlayers + 1
			tPlayers[ iPlayers ] = tEntities[ i ]
		end
	end
	
	return tPlayers, iPlayers
end

function ents.FindEmptySDC()
	local tEntities = ents.FindByClass( "pim_sdc" )
	local tSdcs = {}
	local iSdcs = 0
	
	for i = 1, #tEntities do
		if ( tEntities[ i ].pim_filled == false ) then
			iSdcs = iSdcs + 1
			tSdcs[ iSdcs ] = tEntities[ i ]
		end
	end
	
	return tSdcs
end

function pim_skytodim(vec1, skyPos, MU)
return (vec1-skyPos)*MU
end

function pim_dimtosky(vec1, dimPos, skyPos, MU)
return ((vec1-dimPos) / MU) + (skyPos + (dimPos/MU))
end

function pim_PosToDim(vec1, dimCenter, dimPos) --Converts a virtual position into a local position
return (vec1-dimPos)+dimCenter
end

function pim_DimToPos(vec1, dimCenter, dimPos) --Converts a local position into a virtual position
return (vec1-dimCenter)+dimPos
end

function pim_GetCurrentDim(ent)
	for k, v in pairs(pim_dimensiontable) do
		local dimPos = v:GetPos()
		if (ents.IsSpecEntityInBox(dimPos - pim_size, dimPos + pim_size, ent)) then
			return v
		end
	end
	return nil
end

function pim_unload(entity, dimension, tele_offset, skyCamPos)
	local class = entity:GetClass()
	local angles = entity:GetAngles()
	local model = entity:GetModel()
	local dimPos = dimension:GetPos()
	local pos = pim_DimToPos(tele_offset, dimPos, dimension.pim_location)
	entity:Remove()
	--table.insert( pim_proptable, { pos, class, angles, model, true } )
	--net.Start( "net_pim_proptable" )
	--	net.WriteTable( { pos, class, angles, model, true } )
	--net.Broadcast()
	pimUpdateHolo( pim_proptable, { pos, class, angles, model, true })
end

function pim_reload(poffset, dimension, pim_center)
	local pos = poffset[1]
	local class = poffset[2]
	local angles = poffset[3]
	local model = poffset[4]
	local ent = ents.Create( "prop_physics" )
	if ( not ent:IsValid() ) then return end
	ent:SetModel( model )
	ent:SetPos(pim_PosToDim(pos, pim_center, dimension.pim_location))
	ent:SetAngles( angles )
	ent:SetModelScale( 1 , 0 )
	ent:Spawn()
	poffset[5] = false
	local phys = ent:GetPhysicsObject()
	if ( not phys:IsValid() ) then return end
	phys:EnableMotion( false )
end

function pim_CREATEDIMENSION( activator, caller )
	pim_dim = ents.FindEmptySDC()[1]
	if pim_dim:GetClass() ~= "pim_sdc" then
		print("ERROR: Ran out of space!")
	else
		activator:SetPos(pim_dim:GetPos())
		pim_dim.pim_filled = true
		pim_dim.pim_pair = activator
		pimUpdateDimTable( pim_dimensiontable, pim_dim )
		pim_enabled = true
	end
end