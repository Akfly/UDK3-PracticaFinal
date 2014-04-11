/**
 * This class is the spotlight of the gun, so we know where we are aiming
 * */
class EsneGunSpotLight extends SpotLightMovable;

function PostBeginPlay()
{
	super.PostBeginPlay();
	self.LightComponent.SetEnabled(true);
}

DefaultProperties
{
	Begin Object Name=SpotLightComponent0
		LightColor=(R=255,G=0,B=0)
		InnerConeAngle=0.3
		OuterConeAngle=0.3
		Radius=4096
		Brightness=10
	End Object
	bNoDelete=false
	bStatic = false
}
