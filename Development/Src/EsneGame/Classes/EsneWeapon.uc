class EsneWeapon extends Weapon;

var int Ammo;               //The quantity of bullets the weapon has
var const int maxAmmo;      //Maximum bullets that this weapon can carry

function PostBeginPlay()
{
	super.PostBeginPlay();
	Ammo = maxAmmo;
}

simulated state WeaponEquipping
{
	simulated event BeginState(Name PreviousStateName)
	{
		super.BeginState( PreviousStateName );
		Instigator.Mesh.AttachComponentToSocket(Mesh, 'WeaponPoint');
	}
}

simulated state WeaponPuttingDown
{
	simulated function EndState( Name NextStateName )
	{
		super.EndState( NextStateName );
		Instigator.Mesh.DetachComponent(Mesh);
	}
}

simulated state WeaponFiring
{
	simulated event BeginState( Name PreviousStateName )
	{
		super.BeginState( PreviousStateName );
	}

	simulated function EndState( Name NextStateName )
	{
		super.EndState( NextStateName );
	}
}

function vector GetStartTraceLocation()
{
	return Location;
}

DefaultProperties
{
	Begin Object Class=SkeletalMeshComponent Name=MyMesh
		SkeletalMesh=SkeletalMesh'WP_RocketLauncher.Mesh.SK_WP_RocketLauncher_3P'
	End Object
	Mesh=MyMesh

	FiringStatesArray(0)=WeaponFiring
	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponProjectiles(0)=none
	FireInterval(0)=1.0
	Spread(0)=0.0
	InstantHitDamage(0)=0.0
	InstantHitMomentum(0)=0.0
	InstantHitDamageTypes(0)=class'DamageType'
	maxAmmo=10
}
