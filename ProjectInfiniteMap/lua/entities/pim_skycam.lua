
AddCSLuaFile()

ENT.Type = "anim"
DEFINE_BASECLASS( "base_anim" )

ENT.PrintName = "st1 skycam"
ENT.Spawnable		            	 =  false         
ENT.AdminSpawnable		             =  false 
ENT.Category                         =  "Fun + Games"
ENT.Model                            =  "models/Items/AR2_Grenade.mdl"            
ENT.Effect                           =  ""                  
ENT.EffectAir                        =  ""                   
ENT.EffectWater                      =  "water_huge"
ENT.RenderGroup						 =  RENDERGROUP_OTHER

--if (!CLIENT) then
--	function ENT:Initialize()
--		self:SetModel( "models/vehicles/pilot_seat.mdl" )
--	end
--end

