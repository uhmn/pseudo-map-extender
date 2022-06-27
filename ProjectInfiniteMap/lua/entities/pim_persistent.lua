
AddCSLuaFile()

ENT.Type = "anim"
DEFINE_BASECLASS( "base_anim" )

ENT.PrintName = "Make Persistent"
ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 
ENT.Category                         =  "Fun + Games"
ENT.Model                            =  "models/Items/AR2_Grenade.mdl"            
ENT.Effect                           =  ""                  
ENT.EffectAir                        =  ""                   
ENT.EffectWater                      =  "water_huge"

if (!CLIENT) then
	function ENT:Initialize()
		self:SetModel( "models/props_lab/reciever01b.mdl" )
		self:SetMoveType(MOVETYPE_VPHYSICS);
		self:PhysicsInit(SOLID_VPHYSICS);
		self:SetUseType(SIMPLE_USE);
		self:SetSolid(SOLID_VPHYSICS);
	end
end

