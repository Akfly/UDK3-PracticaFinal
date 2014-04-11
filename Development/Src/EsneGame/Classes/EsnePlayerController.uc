/**
 * The Player Controller. We can specify here what the
 * button functions are supposed to do
 * */
class EsnePlayerController extends PlayerController;

var Rotator DesiredRotation;    // The desired rotation that we want the pawn to be facing when a Side or LateralSide state is chosen
var name SavedState;            //Actual state before Evolving
var Rotator LateralRot;        //Rotation to face Y axis and be always lateral on Side views 
var int Money;                  //the amount of money I have
var int initialMoney;           //the initial money that I start with

exec function ChangeCamera ( string _Camera )
{
	self.ChangeNewState(name(_Camera));
}

exec function GBA_ACrouch()
{
	Pawn.ShouldCrouch(true);
}

exec function GBA_AStandUp ( )
{
	Pawn.ShouldCrouch(false);
}

exec function Camera_ZoomIn ( )
{
	EsneCamera(PlayerCamera).ChangeZoomDestination(-50);
}

exec function Camera_ZoomOut ( )
{
	EsneCamera(PlayerCamera).ChangeZoomDestination(50);
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	Money = initialMoney;
}

/**
 * Returns aviable ammo in JazzGun
 * @return the ammo left
 * */
function int GetAmmo()
{
	return EsneWeaponJazz(Pawn.Weapon).Ammo;
}

/**
 * Adds or removes Money
 * @param   value   Quantity of money to modify. May be positive or negative
 * */
function ModifyMoney(int value)
{
	Money += value;
}

/**
 * Starts transforming
 * */
function DigiEvolve( SkeletalMesh evolvingMesh)
{
	EsnePawn(Pawn).newMesh = evolvingMesh;
	SavedState = self.GetStateName();
	self.GotoState('Evolving');
}

/**
 * Changes into a new state
 * @param NewStateName The state name
 * */
function ChangeNewState(name NewStateName)
{
	EsnePawn(Pawn).ResetAim();
	self.GotoState(NewStateName);
}

/**
 * Function called to move on lateral only. It is called every tick
 * @param DeltaTime Time passed between the last call and this one
 * */
function LateralMovement( float DeltaTime )
{
	local Vector X, Y, Z, NewAccel, CameraLocation;
	local Rotator OldRotation, CameraRotation;
	local bool bSaveJump;

	// If we don't have a pawn to control, then we should go to the dead state
	if (Pawn == None)
	{
		GotoState('Dead');
	}
	else
	{
		// Grab the camera view point as we want to have movement aligned to the camera
		PlayerCamera.GetCameraViewPoint(CameraLocation, CameraRotation);
		// Get the individual axes of the rotation
		GetAxes(CameraRotation, X, Y, Z);

		// Update acceleration
		NewAccel = PlayerInput.aStrafe * Y;
		NewAccel.Z = 0;
		NewAccel = Pawn.AccelRate * Normal(NewAccel);

		// Set the desired rotation
		DesiredRotation = Rotator(NewAccel);

		// Update rotation
		OldRotation = Rotation;
		UpdateRotation(DeltaTime);

		// Handle jumping
		if (bPressedJump && Pawn.CannotJumpNow())
		{
			bSaveJump = true;
			bPressedJump = false;
		}
		else if(bPressedJump)
		{
			EsnePawn(Pawn).PlayJumpingSound();
		}
		else
		{
			bSaveJump = false;
		}

		// We make the pawn to aim depending on the mouse Y movement
		EsnePawn(Pawn).UpdateLateralAim(PlayerInput.aMouseY);

		// Update the movement, either replicate it or process it
		if (Role < ROLE_Authority)
		{
			ReplicateMove(DeltaTime, NewAccel, DCLICK_None, OldRotation - Rotation);
		}
		else
		{
			ProcessMove(DeltaTime, NewAccel, DCLICK_None, OldRotation - Rotation);
		}

		bPressedJump = bSaveJump;
	}
}

/**
 * Updates the player aiming to where the camera is pointing in X axis
 * and moves the gun up or down, depending on the Mouse Y movement
 * */
function UpdatePlayerAiming()
{
	EsnePawn(Pawn).UpdateAiming(EsneCamera(self.PlayerCamera).GetCameraHitLocation(), PlayerInput.aMouseY);
}
/**
 * Function called to move like a third person game.
 * Used on state Gears, FollowPawn and DiabloLike
 * @param DeltaTime Time passed between the last call and this one
 * */
function NormalMovement(float DeltaTime)
{
	local vector			X,Y,Z, NewAccel;
	local eDoubleClickDir	DoubleClickMove;
	local rotator			OldRotation;
	local bool				bSaveJump;

	if( Pawn == None )
	{
		GotoState('Dead');
	}
	else
	{
		GetAxes(Pawn.Rotation,X,Y,Z);

		// Update acceleration.
		NewAccel = PlayerInput.aForward*X + PlayerInput.aStrafe*Y;
		NewAccel.Z	= 0;
		NewAccel = Pawn.AccelRate * Normal(NewAccel);

		if (IsLocalPlayerController())
		{
			AdjustPlayerWalkingMoveAccel(NewAccel);
		}

		DoubleClickMove = PlayerInput.CheckForDoubleClickMove( DeltaTime/WorldInfo.TimeDilation );

		// Update rotation.
		OldRotation = Rotation;
		UpdateRotation( DeltaTime );
		bDoubleJump = false;

		if( bPressedJump && Pawn.CannotJumpNow() )
		{
			bSaveJump = true;
			bPressedJump = false;
		}
		else if(bPressedJump)
		{
			EsnePawn(Pawn).PlayJumpingSound();
		}
		else
		{
			bSaveJump = false;
		}


		if( Role < ROLE_Authority ) // then save this move and replicate it
		{
			ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
		}
		else
		{
			ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
		}
		bPressedJump = bSaveJump;
	}
}

/**
 * Some event and functions are just copied from Pawn (PlayerWalking state),
 * so we make sure the movement works fine, these are: 
 * NotifyPhysicsVolumeChange, ProcessMove, BeginState and EndState
 * 
 * The difference between these state is the camera and the type of movement
 * (normal or lateral)
*/

state Evolving
{
	/**
	 * We cap the move (player inmutable).
	 * This function is neccessary if we don't want to replicate the previous movement
	 * (if player enters in this state with no "PlayerMove" function while walking,
	 * the pawn will keep walking until it leaves this state, even if the player stops
	 * holding the Walking Button)
	 * */
	function PlayerMove( float DeltaTime )
	{
		local vector			NewAccel;
		local eDoubleClickDir	DoubleClickMove;

		DoubleClickMove = PlayerInput.CheckForDoubleClickMove( DeltaTime/WorldInfo.TimeDilation );
		if( Role < ROLE_Authority ) // then save this move and replicate it
		{
			ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, Rotation);
		}
		else
		{
			ProcessMove(DeltaTime, NewAccel, DoubleClickMove, Rotation);
		}
		
	}
	//This state blocks any movement while Evolving
	Begin:
		EsnePawn(Pawn).DigiEvolve();
		Sleep(3);
		GoToState(SavedState);
}
state FollowPawn
{
	ignores SeePlayer, HearNoise, Bump;

	event NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		if ( NewVolume.bWaterVolume && Pawn.bCollideWorld )
		{
			GotoState(Pawn.WaterMovementState);
		}
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		if( Pawn == None )
		{
			return;
		}

		if (Role == ROLE_Authority)
		{
			// Update ViewPitch for remote clients
			Pawn.SetRemoteViewPitch( Rotation.Pitch );
		}

		Pawn.Acceleration = NewAccel;

		CheckJumpOrDuck();
	}

	function PlayerMove( float DeltaTime )
	{
		NormalMovement(DeltaTime);
	}

	event BeginState(Name PreviousStateName)
	{
		DoubleClickDir = DCLICK_None;
		bPressedJump = false;
		GroundPitch = 0;
		if ( Pawn != None )
		{
			Pawn.ShouldCrouch(false);
			if (Pawn.Physics != PHYS_Falling && Pawn.Physics != PHYS_RigidBody)
				Pawn.SetPhysics(Pawn.WalkingPhysics);
		}
	}

	event EndState(Name NextStateName)
	{
		GroundPitch = 0;
		if ( Pawn != None )
		{
			Pawn.SetRemoteViewPitch( 0 );
			if ( bDuck == 0 )
			{
				Pawn.ShouldCrouch(false);
			}
		}
	}

	Begin:
		EsneCamera(PlayerCamera).ChangeCamera("FollowPawn");
}

state DiabloLike
{
	ignores SeePlayer, HearNoise, Bump;

	event NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		if ( NewVolume.bWaterVolume && Pawn.bCollideWorld )
		{
			GotoState(Pawn.WaterMovementState);
		}
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		if( Pawn == None )
		{
			return;
		}

		if (Role == ROLE_Authority)
		{
			// Update ViewPitch for remote clients
			Pawn.SetRemoteViewPitch( Rotation.Pitch );
		}

		Pawn.Acceleration = NewAccel;

		CheckJumpOrDuck();
	}

	function PlayerMove( float DeltaTime )
	{
		NormalMovement(DeltaTime);
	}

	event BeginState(Name PreviousStateName)
	{
		DoubleClickDir = DCLICK_None;
		bPressedJump = false;
		GroundPitch = 0;
		if ( Pawn != None )
		{
			Pawn.ShouldCrouch(false);
			if (Pawn.Physics != PHYS_Falling && Pawn.Physics != PHYS_RigidBody) // FIXME HACK!!!
				Pawn.SetPhysics(Pawn.WalkingPhysics);
		}
	}

	event EndState(Name NextStateName)
	{
		GroundPitch = 0;
		if ( Pawn != None )
		{
			Pawn.SetRemoteViewPitch( 0 );
			if ( bDuck == 0 )
			{
				Pawn.ShouldCrouch(false);
			}
		}
	}

	Begin:
		EsneCamera(PlayerCamera).ChangeCamera("DiabloLike");
}

state Side
{

	ignores SeePlayer, HearNoise, Bump;

	event NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		if ( NewVolume.bWaterVolume && Pawn.bCollideWorld )
		{
			GotoState(Pawn.WaterMovementState);
		}
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		if( Pawn == None )
		{
			return;
		}

		if (Role == ROLE_Authority)
		{
			// Update ViewPitch for remote clients
			Pawn.SetRemoteViewPitch( Rotation.Pitch );
		}

		Pawn.Acceleration = NewAccel;

		CheckJumpOrDuck();
	}
	/**
	 * Handle player moving. Called once per tick
	 * @param	DeltaTime	Time since the last tick
	 */
	function PlayerMove(float DeltaTime)
	{
		LateralMovement(DeltaTime);
	}

	function UpdateRotation(float DeltaTime)
	{
		//We cap this function, so it doesn't rotate

		// Shake the camera if necessary
		ViewShake(DeltaTime);
	}

	event BeginState(Name PreviousStateName)
	{
		DoubleClickDir = DCLICK_None;
		bPressedJump = false;
		GroundPitch = 0;
		if ( Pawn != None )
		{
			Pawn.ShouldCrouch(false);
			if (Pawn.Physics != PHYS_Falling && Pawn.Physics != PHYS_RigidBody) // FIXME HACK!!!
				Pawn.SetPhysics(Pawn.WalkingPhysics);
		}
	}

	event EndState(Name NextStateName)
	{
		GroundPitch = 0;
		if ( Pawn != None )
		{
			Pawn.SetRemoteViewPitch( 0 );
			if ( bDuck == 0 )
			{
				Pawn.ShouldCrouch(false);
			}
		}
	}

	Begin:
		EsneCamera(PlayerCamera).ChangeCamera("Side");
		Pawn.SetRotation(LateralRot);
}

state LateralSide
{

	ignores SeePlayer, HearNoise, Bump;

	event NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		if ( NewVolume.bWaterVolume && Pawn.bCollideWorld )
		{
			GotoState(Pawn.WaterMovementState);
		}
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		if( Pawn == None )
		{
			return;
		}

		if (Role == ROLE_Authority)
		{
			// Update ViewPitch for remote clients
			Pawn.SetRemoteViewPitch( Rotation.Pitch );
		}

		Pawn.Acceleration = NewAccel;

		CheckJumpOrDuck();
	}

	/**
	 * Handle player moving. Called once per tick
	 * @param	DeltaTime	Time since the last tick
	 */
	function PlayerMove(float DeltaTime)
	{
		LateralMovement(DeltaTime);
	}

	function UpdateRotation(float DeltaTime)
	{
		//We cap this function, so it doesn't rotate

		// Shake the camera if necessary
		ViewShake(DeltaTime);
	}

	event BeginState(Name PreviousStateName)
	{
		DoubleClickDir = DCLICK_None;
		bPressedJump = false;
		GroundPitch = 0;
		if ( Pawn != None )
		{
			Pawn.ShouldCrouch(false);
			if (Pawn.Physics != PHYS_Falling && Pawn.Physics != PHYS_RigidBody) // FIXME HACK!!!
				Pawn.SetPhysics(Pawn.WalkingPhysics);
		}
	}

	event EndState(Name NextStateName)
	{
		GroundPitch = 0;
		if ( Pawn != None )
		{
			Pawn.SetRemoteViewPitch( 0 );
			if ( bDuck == 0 )
			{
				Pawn.ShouldCrouch(false);
			}
		}
	}

	Begin:
		EsneCamera(PlayerCamera).ChangeCamera("LateralSide");
		Pawn.SetRotation(LateralRot);
}

state Gears
{
	ignores SeePlayer, HearNoise, Bump;

	event NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		if ( NewVolume.bWaterVolume && Pawn.bCollideWorld )
		{
			GotoState(Pawn.WaterMovementState);
		}
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		if( Pawn == None )
		{
			return;
		}

		if (Role == ROLE_Authority)
		{
			// Update ViewPitch for remote clients
			Pawn.SetRemoteViewPitch( Rotation.Pitch );
		}

		Pawn.Acceleration = NewAccel;

		CheckJumpOrDuck();
	}

	function PlayerMove( float DeltaTime )
	{
		NormalMovement(DeltaTime);
		UpdatePlayerAiming();
	}

	event BeginState(Name PreviousStateName)
	{
		DoubleClickDir = DCLICK_None;
		bPressedJump = false;
		GroundPitch = 0;
		if ( Pawn != None )
		{
			Pawn.ShouldCrouch(false);
			if (Pawn.Physics != PHYS_Falling && Pawn.Physics != PHYS_RigidBody) // FIXME HACK!!!
				Pawn.SetPhysics(Pawn.WalkingPhysics);
		}
	}

	event EndState(Name NextStateName)
	{
		GroundPitch = 0;
		if ( Pawn != None )
		{
			Pawn.SetRemoteViewPitch( 0 );
			if ( bDuck == 0 )
			{
				Pawn.ShouldCrouch(false);
			}
		}
	}

	Begin:
		EsneCamera(PlayerCamera).ChangeCamera("Gears");
}

DefaultProperties
{
	CameraClass=class'EsneCamera'
	InputClass=class'EsnePlayerInput'
	LateralRot=(Pitch=0,Roll=0,Yaw=1)
	initialMoney=200
}
