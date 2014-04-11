/**
 * The player pawn
 * */
class EsnePawn extends Pawn
	placeable
	ClassGroup(Esne);

var AnimNodeSlot AnimNodeSlot;

var bool bEvolved;                  //Indicates if I have already change the mesh
var ParticleSystem EvolveEffect;    //A particle effect that plays when I evolve
var float MouseLookAim;             //Variable needed to update the Lateral Aiming
var float MouseLookAimX;             //Variable needed to update the Lateral Aiming
var	AnimNodeAimOffset AimNode;      //To make our pawn to aim
var float AimMovement;              //Aim speed movement
var bool bInitState;                //Used to Initialize Camera
var SkeletalMesh newMesh;           //Mesh which I will evolve to
var bool bHealing;                  //If I'm are healing or not ;P
var float HealDelayTime;            //Time in seconds to wait before healing
var float TimeHealing;              //The time needed to recover the mahimum health
var float HealingValue;             //If we are healing, and this values is greater than 1, we heal 1 point (and this var decreeses 1 point)
var SoundCue FootStep;              //Sound of the footsteps
var SoundCue JumpSound;             //Sound made when jumping
var SoundCue LandSound;             //Sound made when landing (by a fall, or jumping)
var SoundCue EvolvingSound;         //Sound played when evolving

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    if (SkelComp == Mesh)
    {
        AnimNodeSlot = AnimNodeSlot(SkelComp.FindAnimNode('MySlot'));
		AimNode = AnimNodeAimOffset(Mesh.FindAnimNode('AimNode'));
    }
}

function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	//We check to initialize the camera at the beginning of the game
	if(self.Controller != none && !bInitState)
	{
		EsneCamera(EsnePlayerController(self.Controller).PlayerCamera).InitializeGameType();
		bInitState=true;
	}

	if(self.Health < self.HealthMax)
	{
		HealUpdate(DeltaTime);
	}
}

/**
 * If I can, I should recover some Health asap!!
 * @param   DeltaTime   Time elapsed between the last frame and this one. Used to heal on the same intervals of time
 * */
function HealUpdate(float DeltaTime)
{
	if(bHealing)
		{
			HealingValue +=DeltaTime*self.HealthMax/ TimeHealing ;

			//Heal damage only accepts int, so to Heal the same value on the same intervals of time
			//we check if it we should Heal 1 point or more and remove the healed val from HealingValue
			if(HealingValue>1)
			{
				self.HealDamage(int(HealingValue), self.Controller, class'DmgType_Crushed');
				HealingValue -= int(HealingValue);
			}
			if(Health >= HealthMax)
			{
				bHealing=false;
			}
		}
		else if(!self.IsTimerActive('HealDelay'))
		{
			//If I have waited enough, I can start to heal now
			bHealing=true;
		}
}

/**
 * When I recieve damage, I stop Healing and the timer to begin healing starts.
 * */
simulated function TakeRadiusDamage(Controller InstigatedBy, float BaseDamage, float DamageRadius, class<DamageType> DamageType, float Momentum, Vector HurtOrigin, bool bFullDamage, Actor DamageCauser, optional float DamageFalloffExponent)
{
	super.TakeRadiusDamage(InstigatedBy, BaseDamage, DamageRadius, DamageType, Momentum, HurtOrigin, bFullDamage, DamageCauser, DamageFalloffExponent);

	SetTimer(HealDelayTime, false, 'HealDelay');
	bHealing = false;
}

function AddDefaultInventory()
{
    super.AddDefaultInventory();
    CreateInventory(class'EsneWeaponJazz');
    
}

simulated event Vector GetWeaponStartTraceLocation(optional Weapon CurrentWeapon)
{
    return EsneWeapon(Weapon).GetStartTraceLocation();
}

/**
 * Changes the SkelMesh to the next Level!! (Changes the mesh to a new one)
 */
function DigiEvolve()
{
	local vector particleLoc;

	particleLoc.X = self.Location.X;
	particleLoc.Y = self.Location.Y;
	particleLoc.Z = self.Location.Z - self.GetCollisionHeight();
	WorldInfo.MyEmitterPool.SpawnEmitter(EvolveEffect, particleLoc, Rotation);
	PlaySound(EvolvingSound);
	self.Mesh.SetSkeletalMesh(newMesh);
}

/**
 * This function sets the Aim Profile of the AimNode
 * */
simulated function SetWeapAnimType(EWeapAnimType AnimType)
{
	if (AimNode!=none)
	{
		AimNode.SetActiveProfileByName('EsneRifle');
	}
}

/**
 * This function updates the aiming only in Y axis,
 * so it will aim on the lateral views
 * @param   MouseYInput The Mouse movement on Y axis
 * */
function UpdateLateralAim(float MouseYInput)
{
	//We check that the Pawn won't try to aim more than 90º or less than -90º
	if ((MouseLookAim < 16000 && MouseLookAim > -16000) || 
		(MouseLookAim >= 16000 && MouseYInput <0) ||
		(MouseLookAim <=-16000 && MouseYInput >0))
	{
		MouseLookAim+=MouseYInput;
		AimNode.AngleOffset.Y -= (MouseYInput/16000);
	}
}

/**
 * This function is called only in "Gears" mode.
 * I will recieve where the camera is aiming and
 * I will aim there too.
 * @param   TargetLocation  The position where the gun should be aiming
 * */
function UpdateAiming(vector TargetLocation, float MouseYInput)
{

	local vector CharLocation, lateral, WeaponLoc; // HitNormal, EndPoint, WeaponLoc,
	local rotator WeaponRot;

	SkeletalMeshComponent(self.Weapon.Mesh).GetSocketWorldLocationAndRotation('Muzzle', WeaponLoc, WeaponRot);
	CharLocation = self.GetAimingPos();

	//Transform this vector to know if the points are on our left or right
	lateral=vector(Rotation);
	lateral=lateral cross vect(0,0,1);
 
	//We now check if we are aiming to the left or right where we should. If we don't need to move it, then we don't update
	if (lateral dot Normal(CharLocation - Location) > lateral dot Normal(TargetLocation - Location))
	{
		AimNode.AngleOffset.X -= AimMovement;
	}
	else if(lateral dot Normal(CharLocation - Location) < lateral dot Normal(TargetLocation - Location))
	{
		AimNode.AngleOffset.X += AimMovement;
	}

	UpdateLateralAim(MouseYInput);
}

/**
 * Returns where the gun is aiming
 * @return  The Location vector of the point the gun is aiming
 * */
function vector GetAimingPos()
{
	local vector CharLocation, WeaponLoc, EndPoint, HitNormal;
	local rotator WeaponRot;
	SkeletalMeshComponent(self.Weapon.Mesh).GetSocketWorldLocationAndRotation('Muzzle', WeaponLoc, WeaponRot);
	EndPoint = WeaponLoc + Normal(vector(WeaponRot))*32767; //far away. Used max bit16
	Trace(CharLocation, HitNormal, EndPoint, WeaponLoc, FALSE);
	return CharLocation;

}

/**
 * Reset the aiming to Center-Center.
 * Used on every Change of State
 * */
function ResetAim()
{
	AimNode.AngleOffset.X = 0;
	AimNode.AngleOffset.Y = 0;
}

/**
 * Handles actual playing of sound.  Separated from PlayFootstepSound so we can
 * ignore footstep sound notifies in first person.
 */
simulated event PlayFootStepSound(int FootDown)
{
	PlaySound(FootStep, false, true,,, true);
}

function PlayJumpingSound()
{
	PlaySound(JumpSound);
}

/**
 * Plays landing sound
 * */
event Landed(Vector HitNormal, Actor FloorActor)
{
	super.Landed(HitNormal, FloorActor);
	PlaySound(LandSound);
}


DefaultProperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
        ModShadowFadeoutTime=0.25
        MinTimeBetweenFullUpdates=0.2
        AmbientGlow=(R=.01,G=.01,B=.01,A=1)
        AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
        bSynthesizeSHLight=true
    End Object
    Components.Add(MyLightEnvironment)

	CollisionType=COLLIDE_BlockAll
    Begin Object Name=CollisionCylinder
        CollisionHeight=55
        CollisionRadius=22
    End Object

    Begin Object class=SkeletalMeshComponent Name=PawnMeshComponent
        SkeletalMesh=SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'
        Animsets(0)=AnimSet'EsnePackage.Anims.K_AnimHuman_BaseMale'
		Animsets(1)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_AimOffset'
        AnimTreeTemplate=AnimTree'EsnePackage.Anims.IronGuardAnim'
        bHasPhysicsAssetInstance=true
        BlockRigidBody=true
        PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
    End Object
    Components.Add(PawnMeshComponent)
    Mesh=PawnMeshComponent

	bCanCrouch=true
	bEvolved=false
	MouseLookAim=0
	AimMovement=0.003
	bInitState=false
	Health=100
	HealthMax=100
	bHealing=false
	HealDelayTime=5
	TimeHealing=30

	InventoryManagerClass=class'EsneInventoryManager'
	EvolveEffect=ParticleSystem'WP_Translocator.Particles.P_WP_Translocator_Teleport'
	FootStep=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_DefaultCue'
	JumpSound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_StoneJumpCue'
	LandSound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_StoneLandCue'
	EvolvingSound=SoundCue'A_Gameplay.CTF.Cue.A_Gameplay_CTF_TeamFlagGrab01Cue'
}
