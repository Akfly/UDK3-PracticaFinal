/**
 * Kismet function that changes the pawn mesh
 * */
class EsneSeqAct_SkeletalMesh extends SequenceAction;

var Object PlayerPawn;              //Player Pawn set on Kismet
var() SkeletalMesh NewMesh;         //The new Mesh to Transform. It is set on Kismet
var SkeletalMesh DefaultNewMesh;    //If no Mesh was selected on Kismet, it will transform into this mesh

event Activated()
{
	if(EsnePawn(PlayerPawn) != none)
	{
		if(NewMesh != none)
		{
			EsnePlayerController(EsnePawn(PlayerPawn).Controller).DigiEvolve(NewMesh);
		}
		else
		{
			EsnePlayerController(EsnePawn(PlayerPawn).Controller).DigiEvolve(DefaultNewMesh);
		}
	}
}

DefaultProperties
{
	ObjName="Change SkelMesh"
	ObjCategory="Esne"

	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Player",PropertyName=PlayerPawn)
	DefaultNewMesh=SkeletalMesh'CH_LIAM_Cathode.Mesh.SK_CH_LIAM_Cathode'
}
