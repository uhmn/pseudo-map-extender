
perlin = {}
perlin.p = {}

-- Hash lookup table as defined by Ken Perlin
-- This is a randomly arranged array of all numbers from 0-255 inclusive
local permutation = {151,160,137,91,90,15,
  131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
  190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
  88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
  77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
  102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
  135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
  5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
  223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
  129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
  251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
  49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
  138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
}

-- p is used to hash unit cube coordinates to [0, 255]
for i=0,255 do
    -- Convert to 0 based index table
    perlin.p[i] = permutation[i+1]
    -- Repeat the array to avoid buffer overflow in hash function
    perlin.p[i+256] = permutation[i+1]
end

-- Return range: [-1, 1]
function perlin:noise(x, y, z)
    y = y or 0
    z = z or 0

    -- Calculate the "unit cube" that the point asked will be located in
    local xi = bit.band(math.floor(x),255)
    local yi = bit.band(math.floor(y),255)
    local zi = bit.band(math.floor(z),255)

    -- Next we calculate the location (from 0 to 1) in that cube
    x = x - math.floor(x)
    y = y - math.floor(y)
    z = z - math.floor(z)

    -- We also fade the location to smooth the result
    local u = self.fade(x)
    local v = self.fade(y)
    local w = self.fade(z)

    -- Hash all 8 unit cube coordinates surrounding input coordinate
    local p = self.p
    local A, AA, AB, AAA, ABA, AAB, ABB, B, BA, BB, BAA, BBA, BAB, BBB
    A   = p[xi  ] + yi
    AA  = p[A   ] + zi
    AB  = p[A+1 ] + zi
    AAA = p[ AA ]
    ABA = p[ AB ]
    AAB = p[ AA+1 ]
    ABB = p[ AB+1 ]

    B   = p[xi+1] + yi
    BA  = p[B   ] + zi
    BB  = p[B+1 ] + zi
    BAA = p[ BA ]
    BBA = p[ BB ]
    BAB = p[ BA+1 ]
    BBB = p[ BB+1 ]

    -- Take the weighted average between all 8 unit cube coordinates
    return self.lerp(w,
        self.lerp(v,
            self.lerp(u,
                self:grad(AAA,x,y,z),
                self:grad(BAA,x-1,y,z)
            ),
            self.lerp(u,
                self:grad(ABA,x,y-1,z),
                self:grad(BBA,x-1,y-1,z)
            )
        ),
        self.lerp(v,
            self.lerp(u,
                self:grad(AAB,x,y,z-1), self:grad(BAB,x-1,y,z-1)
            ),
            self.lerp(u,
                self:grad(ABB,x,y-1,z-1), self:grad(BBB,x-1,y-1,z-1)
            )
        )
    )
end

-- Gradient function finds dot product between pseudorandom gradient vector
-- and the vector from input coordinate to a unit cube vertex
perlin.dot_product = {
    [0x0]=function(x,y,z) return  x + y end,
    [0x1]=function(x,y,z) return -x + y end,
    [0x2]=function(x,y,z) return  x - y end,
    [0x3]=function(x,y,z) return -x - y end,
    [0x4]=function(x,y,z) return  x + z end,
    [0x5]=function(x,y,z) return -x + z end,
    [0x6]=function(x,y,z) return  x - z end,
    [0x7]=function(x,y,z) return -x - z end,
    [0x8]=function(x,y,z) return  y + z end,
    [0x9]=function(x,y,z) return -y + z end,
    [0xA]=function(x,y,z) return  y - z end,
    [0xB]=function(x,y,z) return -y - z end,
    [0xC]=function(x,y,z) return  y + x end,
    [0xD]=function(x,y,z) return -y + z end,
    [0xE]=function(x,y,z) return  y - x end,
    [0xF]=function(x,y,z) return -y - z end
}
function perlin:grad(hash, x, y, z)
    return self.dot_product[bit.band(hash,0xF)](x,y,z)
end

-- Fade function is used to smooth final output
function perlin.fade(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

function perlin.lerp(t, a, b)
    return a + t * (b - a)
end

function pperlin (xg, yg, octaves)
	if octaves == 4 then return ((perlin:noise(xg/7500, yg/7500, 0) * 1000) + (perlin:noise(xg/15000, yg/15000, 0) * 2000) + (perlin:noise(xg/60000, yg/60000, 0) * 2000) + (perlin:noise(xg/120000, yg/120000, 0) * 4000)) end
	if octaves == 2 then return ((perlin:noise(xg/(60000), yg/(60000), 0) * 2000) + (perlin:noise(xg/(120000), yg/(120000), 0) * 4000)) end
end

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
		--if ( tEntities[ i ].pim_filled == false ) then
		--	iSdcs = iSdcs + 1
		--	tSdcs[ iSdcs ] = tEntities[ i ]
		--end
		iSdcs = iSdcs + 1
		tSdcs[ iSdcs ] = tEntities[ i ]
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

