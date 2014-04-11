/**
 * A NPC pawn
 * */
class EsneEnemyPawn extends EsnePawn;

var ParticleSystem MyExplosion;             //Particle played when I explode
var SoundCue ExplosionSound;                //This sound plays when I explode
var const float DamageDistance;             //Distance that this pawn must be at least to damage the player
var const float BaseExplosionDamage;        //Quantity of damage done when exploding and the player is near the explosion

simulated event PostRenderFor(PlayerController PC, Canvas Canvas, vector CameraPosition, vector CameraDir)
{
	local vector Pos;
	
	Pos = Canvas.Project( Location + vect(0,0,90) );
	Canvas.Font = class'Engine'.Static.GetMediumFont();
	Canvas.SetDrawColor(255,0,0,255);
	Canvas.SetPos( Pos.X, Pos.Y );
	Canvas.DrawText( Controller.GetStateName() );
}

/**
 * This function makes me explode and die after it
 * */
function Explode()
{
	//if Player is in range, he takes some damage
	if(VSizeSq(self.GetALocalPlayerController().Pawn.Location - self.Location) < DamageDistance*DamageDistance)
	{
		self.GetALocalPlayerController().Pawn.TakeRadiusDamage(self.Controller, BaseExplosionDamage, DamageDistance, class'DmgType_Crushed', DamageDistance, self.Location, false, self);
	}
	WorldInfo.MyEmitterPool.SpawnEmitter(MyExplosion, Location);
	PlaySound(ExplosionSound);
	Destroy();
}

function bool Died(Controller Killer,  class<DamageType> DamageType,  vector HitLocation)
{
	super.Died( Killer, DamageType, HitLocation);

	//When I die, this sequence activate the RigidBody
	Mesh.SetRBChannel(RBCC_Pawn);
	Mesh.SetRBCollidesWithChannel(RBCC_Default,TRUE);
	Mesh.SetRBCollidesWithChannel(RBCC_Pawn,TRUE);
	Mesh.SetRBCollidesWithChannel(RBCC_Vehicle,TRUE);
	Mesh.SetRBCollidesWithChannel(RBCC_Untitled3,FALSE);
	Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume,TRUE);
	InitRagdoll();

	return true;
}

DefaultProperties
{
	ControllerClass=class'EsneAIController'
	MyExplosion=ParticleSystem'FX_VehicleExplosions.Effects.P_FX_VehicleDeathExplosion'
	ExplosionSound=SoundCue'A_Character_BodyImpacts.BodyImpacts.A_Character_RobotImpact_BodyExplosion_Cue'
	DamageDistance=100
	BaseExplosionDamage=50
}
