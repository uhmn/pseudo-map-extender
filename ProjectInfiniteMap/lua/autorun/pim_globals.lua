
pim_enabled = false
pim_size = Vector( 3808, 3808, 3808 )
pim_dimensiontable = {}
pim_proptable = {}

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

function pim_unload(entity, dimension, tele_offset)
	local pos = entity:GetPos()
	local class = entity:GetClass()
	local angles = entity:GetAngles()
	local model = entity:GetModel()
	local dimPos = dimension:GetPos()
	entity:Remove()
	--if ( SERVER ) then return end
	local ent = ents.Create( "prop_dynamic" )
	if ( not ent:IsValid() ) then return end
	table.insert( pim_proptable, { pos, class, angles, model, true } )
	ent.pim_off = #pim_proptable
	ent:SetModel( model )
	--ent:SetPos( ( (pos-dimPos) / 16 ) + (skyCamPos + (dimPos/16)) )
	ent:SetPos(pim_dimtosky(pos, dimPos, skyCamPos, 16))
	ent:SetAngles( angles )
	ent:SetModelScale( 1/16 , 0 )
	ent:Spawn()

end

function pim_reload(entity, dimension, pim_center)
	local stoffset = entity.pim_off
	local pos = pim_proptable[stoffset][1]
	local class = pim_proptable[stoffset][2]
	local angles = pim_proptable[stoffset][3]
	local model = pim_proptable[stoffset][4]
	local ent = ents.Create( "prop_physics" )
	if ( not ent:IsValid() ) then return end
	ent:SetModel( model )
	--ent:SetPos( ((entity:GetPos() - (skyCamPos + pim_center / 16))*16) + pim_center )
	ent:SetPos(pim_skytodim(entity:GetPos(), skyCamPos, 16))
	ent:SetAngles( angles )
	ent:SetModelScale( 1 , 0 )
	ent:Spawn()
	pim_proptable[stoffset][5] = false
	entity:Remove()
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
		pim_dim.pim_filled = activator
		table.insert( pim_dimensiontable, pim_dim )
	end
end
