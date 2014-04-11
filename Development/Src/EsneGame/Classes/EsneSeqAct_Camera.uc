/**
 * Kismet function that changes the camera mode to the next one
 * or to a specified one
 * */
class EsneSeqAct_Camera extends SequenceAction;

var() string CameraName;    //If a wrong name or no name is set, it will change to the next one

event Activated()
{
	EsnePlayerController(GetWorldInfo().GetALocalPlayerController()).ChangeCamera(CameraName);
}

DefaultProperties
{
	ObjName="Change Camera"
	ObjCategory="Esne"
}
