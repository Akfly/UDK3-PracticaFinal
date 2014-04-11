/**
 * The custom weapon with custom Mesh and effects
 */
class EsneWeaponJazz extends EsneWeapon;

var ParticleSystem MuzzleEffect;    //Shooting particle effect
var ParticleSystem HitEffect;       //Particle effect shown when the bullet hits the target
var EsneGunSpotLight GunPoint;      //The point of the gun that shows where we are aiming
var SoundCue ImpactSound;           //Sound made when the bullet hits the target
var SoundCue ShotSound;             //Shooting sound

function PostBeginPlay()
{
	super.PostBeginPlay();
	GunPoint = Spawn(class'EsneGunSpotLight', self);
	GunPoint.SetBase(self);
}

function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	//Updates the spotlight
	GunPoint.SetLocation(GetStartTraceLocation());
	GunPoint.SetRotation(GetAdjustedAim(GetStartTraceLocation()));
}

/**
 * Gets the Location vector of the weapon cannon
 * @return  Location vector of the weapon cannon
 */
function vector GetStartTraceLocation()
{
	local vector MuzzleLocation;
	local rotator MuzzleRotation;

	SkeletalMeshComponent(Mesh).GetSocketWorldLocationAndRotation('Muzzle', MuzzleLocation, MuzzleRotation);

	return MuzzleLocation;
}

/**
 * Gets the Rotator vector of the weapon cannon
 * @return  Rotator vector of the weapon cannon
 */
simulated function Rotator GetAdjustedAim(vector StartFireLoc)
{
	local vector MuzzleLocation;
	local rotator MuzzleRotation;

	SkeletalMeshComponent(Mesh).GetSocketWorldLocationAndRotation('Muzzle', MuzzleLocation, MuzzleRotation);

	return MuzzleRotation;

}

/**
 * Triggers when the weapon fires, so it can show the shooting effect
 */
simulated function InstantFire()
{
	local vector pos;
	local rotator rota;

	if(Ammo > 0)
	{
		pos = GetStartTraceLocation();
		rota = GetAdjustedAim(pos);
		super.InstantFire();
		WorldInfo.MyEmitterPool.SpawnEmitter(MuzzleEffect, pos + (vect(50,0,0)>>rota), rota,  Instigator);
		Ammo -= 1;
		PlaySound(ShotSound, false, true,,, true);
	}
}

/**
 * Triggers when the bullet hits the target, so it can paint the particle effect
 * @param FiringMode: index of firing mode being used
 * @param Impact: hit information
 * @param NumHits (opt): number of hits to apply using this impact
 * 			this is useful for handling multiple nearby impacts of multihit weapons (e.g. shotguns)
 *			without having to execute the entire damage code path for each one
 *			an omitted or <= 0 value indicates a single hit
 */
simulated event ProcessInstantHit(byte FiringMode,  ImpactInfo Impact,  optional int NumHits)
{
	super.ProcessInstantHit(FiringMode, Impact, NumHits);
	WorldInfo.MyEmitterPool.SpawnEmitter(HitEffect, Impact.HitLocation, rotator(Impact.HitNormal));
	PlaySound(ImpactSound, false, true,,, true);
}

/**
 * Reloads the ammo to full
 * */
function ReloadFullAmmo()
{
	Ammo=self.maxAmmo;
}

/**
 * Reloads the ammo to the given value
 * @param   AmmoReload  How much ammo is reloaded
 * */
function ReloadSomeAmmo(int AmmoReload)
{
	Ammo += AmmoReload;
}

/**
 * @return  The difference between the maxAmmo and actual ammo
 * */
function int GetLackAmmo()
{
	return maxAmmo - Ammo;
}

DefaultProperties
{
	Begin Object Name=MyMesh
		SkeletalMesh=SkeletalMesh'KismetGame_Assets.Anims.SK_JazzGun'
	End Object

	MuzzleEffect=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Ball_Impact'
	HitEffect=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Beam_Impact'
	ImpactSound=SoundCue'A_Character_BodyImpacts.BodyImpacts.A_Character_RobotImpact_GibMedium_Cue'
	ShotSound=SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_TurretFire'
	InstantHitDamage(0)=100.0
}