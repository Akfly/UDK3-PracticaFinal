/**
 * The player camera. This class manage every camera type
 * and the transition between them
 * */
class EsneCamera extends Camera;

var string CurrentCamera;   //String that defines the current camera

var const archetype EsneCameraArchetype CameraProperties;   //the archetype for the camera

var vector ZoomedCameraPosition;    //Position of the camera when the zoom is applied
var float ZoomOffset;               //The Zoom variable. It changes every frame to update camera position (only when the zoom is moving)
var float ZoomSpeed;                //Used to make the zoom smoother
var float ZoomDestination;          //the final position of the zoom
var float iniZoomPos;               //the initial position before zooming in (used to calculate the smoothing)
var float TotalTimeZoom;            //the total time that last the zoom to complete
var vector CameraHitLocation;       //Where the Camera is aiming

/**
 * Set the starting camera given by the archetype
 * */
function InitializeGameType()
{
	EsnePlayerController(self.GetALocalPlayerController()).ChangeCamera(CameraProperties.StartingCamera);
}

function ChangeCamera(string _Camera )
{
	//Change to the given camera, if the name is wrong, changes to the next one
	if( _Camera == "FollowPawn" ||
		_Camera == "DiabloLike" ||
		_Camera == "Side" ||
		_Camera == "LateralSide" ||
		_Camera == "Gears" )
	{
		CurrentCamera = _Camera;
	}
	else if (CurrentCamera == "FollowPawn")
	{
		CurrentCamera = "DiabloLike";
	}
	else if (CurrentCamera == "DiabloLike")
	{
		CurrentCamera = "Side";
	}
	else if (CurrentCamera == "Side")
	{
		CurrentCamera = "LateralSide";
	}
	else if (CurrentCamera == "LateralSide")
	{
		CurrentCamera = "Gears";
	}
	else if (CurrentCamera == "Gears")
	{
		CurrentCamera = "FollowPawn";
	}

	if(CurrentCamera=="FollowPawn")
	{
		ZoomDestination=CameraProperties.FollowPawnPos.Z;
		iniZoomPos = ZoomDestination;
	}
	else if(CurrentCamera=="DiabloLike")
	{
		ZoomDestination=CameraProperties.DiabloLikePos.Z;
		iniZoomPos = ZoomDestination;
	}
}

/**
 * This function returns where the center of the camera is aiming.
 * In Gears mode, the pawn will be aiming to this point, so it will call this function.
 * 
 * */
function SetCameraHitLocation(vector CamLoc, rotator CamRot)
{
	local vector HitNormal, EndPoint;

	EndPoint = CamLoc + Normal(vector(CamRot))*32767; //far away. Used max bit16
	Trace(CameraHitLocation, HitNormal, EndPoint, CamLoc, FALSE);
}

/**
 *  @return  The hit location where the camera is aiming.
 * */
function vector GetCameraHitLocation()
{
	return CameraHitLocation;
}

function UpdateLocationRotation(out vector _CameraLocation, out rotator _CameraRotation)
{
	switch (CurrentCamera)
	{
		
		case "FollowPawn":
			UpdateZoom();
		  	_CameraLocation = PCOwner.Pawn.Location + (ZoomedCameraPosition >> PCOwner.Pawn.Rotation);
			_CameraRotation = rotator( PCOwner.Pawn.Location - _CameraLocation );
			CheckCamCollision(self.GetALocalPlayerController().Pawn, _CameraLocation);
		  	break;

		case "DiabloLike":
			UpdateZoom();
			_CameraLocation = PCOwner.Pawn.Location + ZoomedCameraPosition;
			_CameraRotation = rotator( PCOwner.Pawn.Location - _CameraLocation );
			CheckCamCollision(self.GetALocalPlayerController().Pawn, _CameraLocation);
			break;

		case "Side":
			_CameraLocation = PCOwner.Pawn.Location + (CameraProperties.SidePos >> PCOwner.Pawn.Rotation);
			_CameraRotation = rotator( PCOwner.Pawn.Location - _CameraLocation );
			CheckCamCollision(self.GetALocalPlayerController().Pawn, _CameraLocation);
		  	break;

		case "LateralSide":
			_CameraLocation = PCOwner.Pawn.Location + (CameraProperties.LateralSidePos >> PCOwner.Pawn.Rotation);
			_CameraRotation = PCOwner.Pawn.Rotation + CameraProperties.LateralSideRot;
			CheckCamCollision(self.GetALocalPlayerController().Pawn, _CameraLocation);
		  	break;

		case "Gears":
			default:
			_CameraLocation = PCOwner.Pawn.Location + (CameraProperties.GearsPos >> PCOwner.Pawn.Rotation);
			_CameraRotation = PCOwner.Pawn.Rotation;

			CheckCamCollision(self.GetALocalPlayerController().Pawn, _CameraLocation);
			SetCameraHitLocation(_CameraLocation, _CameraRotation);
		  	break;
	    
	}
	
}


function UpdateViewTarget(out TViewTarget OutVT, float DeltaTime)
{
	super.UpdateViewTarget(OutVT, DeltaTime);
	UpdateLocationRotation(OutVT.POV.Location, OutVT.POV.Rotation);
}

/**
* Calculates the actual Zoom so it would be smooth. It tries to reach a destination
* but every frame goes slower (smoother)
*/
function UpdateZoom()
{
	local float advance;
	local float distance;

	distance = ZoomDestination - ZoomedCameraPosition.Z;

	if(!(distance < 0.01 && distance > -0.01))
	{
		advance = distance / 10;
		ZoomedCameraPosition.Z += advance;
	}
}

/**
* Changes the destination of the camera for zooming. It checks the max
* and min zoom given on the Camera Archetype
* @param    OffsetZoomPosition  The value of zoom in or zoom out
*/
function ChangeZoomDestination(float OffsetZoomPosition)
{
	iniZoomPos = ZoomedCameraPosition.Z;
	if(CurrentCamera=="FollowPawn")
	{
		if(ZoomDestination+OffsetZoomPosition >= CameraProperties.FollowPawnMaxZoom)
		{
			ZoomDestination=CameraProperties.FollowPawnMaxZoom;
		}
		else if (ZoomDestination+OffsetZoomPosition <= CameraProperties.FollowPawnMinZoom)
		{
			ZoomDestination=CameraProperties.FollowPawnMinZoom;
		}
		else
		{
			ZoomDestination+=OffsetZoomPosition;
		}
	}
	else if(CurrentCamera=="DiabloLike")
	{
		if(ZoomDestination+OffsetZoomPosition >= CameraProperties.DiabloLikeMaxZoom)
		{
			ZoomDestination=CameraProperties.DiabloLikeMaxZoom;
		}
		else if (ZoomDestination+OffsetZoomPosition <= CameraProperties.DiabloLikeMinZoom)
		{
			ZoomDestination=CameraProperties.DiabloLikeMinZoom;
		}
		else
		{
			ZoomDestination+=OffsetZoomPosition;
		}
	}
}

/**
 * Checks if there is an actor between the camera and the playerpawn,
 * if there is one, zooms in the camera so there is no actor between them
 * @param   P   The player Pawn
 * @param   _CameraLocation The location of the camera, it changes if there is an actor on the way
 * */
function CheckCamCollision(Pawn P, out vector _CameraLocation)
{
	local vector HitLocation, HitNormal;
    local Actor HitActor;

	HitActor = Trace(HitLocation, HitNormal, _CameraLocation, P.Location, FALSE, vect(20,20,20));
	if ( HitActor != none )
	{
   		_CameraLocation = HitLocation;
	}
	
}

DefaultProperties
{
	CurrentCamera=""
	CameraProperties=EsneCameraArchetype'EsnePackage.Camera.EsneCameraArch'

	ZoomOffset=0
	ZoomSpeed=0
	ZoomDestination=0
	TotalTimeZoom=3
}
