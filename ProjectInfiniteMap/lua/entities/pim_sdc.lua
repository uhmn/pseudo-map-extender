
AddCSLuaFile()

ENT.Type = "anim"
DEFINE_BASECLASS( "base_anim" )

ENT.PrintName = "SubDimension Center"
ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 
ENT.Category                         =  "Fun + Games"
ENT.Model                            =  "models/Items/AR2_Grenade.mdl"            
ENT.Effect                           =  ""                  
ENT.EffectAir                        =  ""                   
ENT.EffectWater                      =  "water_huge"
ENT.RenderGroup						 =  RENDERGROUP_OTHER

ENT.pim_filled							 =  false
ENT.pim_pair							 =  nil
ENT.pim_location						 =  Vector( 0, 0, 0 )
ENT.pim_velocity						 =  Vector( 0, 0, 0 )

if (!CLIENT) then
	function ENT:Initialize()
		self:SetModel( "models/vehicles/pilot_seat.mdl" )
	end
end

