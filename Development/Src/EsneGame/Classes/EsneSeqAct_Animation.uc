/**
 * Kismet function that plays a custom animation on the player
 * */
class EsneSeqAct_Animation extends SequenceAction;

var Object PlayerPawn;          //The player, referenced on Kismet
var() name AnimationName;       //The animation name that can be set on Kismet

event Activated()
{
	if(EsnePawn(PlayerPawn) != none)
	{
		
		if(AnimationName != '')
		{
			EsnePawn(PlayerPawn).AnimNodeSlot.PlayCustomAnim(AnimationName, 1.0);
		}
		else
		{
			EsnePawn(PlayerPawn).AnimNodeSlot.PlayCustomAnim('Taunt_FB_BringItOn', 1.0);
		}
	}
}

DefaultProperties
{
	ObjName="Play Player Animation"
	ObjCategory="Esne"

	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Player",PropertyName=PlayerPawn)
}
