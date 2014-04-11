/**
 * The controller of EsneSuicidePawn
 * This pawn starts waiting some seconds, then it waits until
 * it sees the player. When it does, it start following him.
 * If the pawn has reached the player in five seconds or less,
 * it explodes; if not, it explodes (but doesn't hit the player :S).
 * */
class EsneSuicideController extends GameAIController;

var float TimeToDie;        //Seconds to die before reaching the player
var bool bTimerStart;       //Indicates if the Timer that will doom me has already started or not
var bool bWannaExplode;     //If true, it means that the Doom Time has run out or that I have reached the player. Anyway, I Explode this frame
var bool bPlayerSeen;       //I have the player in sight, I will start now to run towards the player

/** epic
* Handles attaching this controller to the specified
* pawn.
*/
event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess( inPawn, bVehicleTransition );
	Pawn.SetMovementPhysics();
}

function bool FindNavMeshPath( Actor _Target )
{
	NavigationHandle.PathConstraintList = none;
	NavigationHandle.PathGoalList = none;

	class'NavMeshPath_Toward'.static.TowardGoal( NavigationHandle, _Target );
	class'NavMeshGoal_At'.static.AtActor( NavigationHandle, _Target );
	return NavigationHandle.FindPath();
}

function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	//If I have sought the player I start running
	if(self.IsInState('Idle'))
	{
		if(bPlayerSeen)
		{
			GoToState('Moving');
		}
	}
	else
	{
		//Handles the explosion
		if(bTimerStart && !IsTimerActive('DieTimer'))
		{
			bWannaExplode=true;
		}

		if(bWannaExplode)
		{
			EsneSuicidePawn(Pawn).Explode();
		}
	}
}

//Initial state, I wait 3 seconds before awekening Zzzz....
auto state Initial
{
	Begin:
		Sleep(3);
		GoToState('Idle');
}

//When I enter in this state I start running, but I can run only for a few seconds before I die :(
state Moving
{
	Begin:
		SetTimer(TimeToDie,false,'DieTimer');   //Sets the Time before I die
		bTimerStart=true;

		//I start following the player. I use MoveToward instead of MoveTo because the
		//player may move, so he could easily avoid me :S
		MoveToward(GetALocalPlayerController().Pawn,,30);

		//I can only reach this code if I have already reached the player, so I will just explode ^^
		bWannaExplode=true;
		
		GoToState('Idle');
}

state Idle
{
	event SeePlayer(Pawn SeenPlayer)
	{
		bPlayerSeen=true;
	}

	Begin:

}

DefaultProperties
{
	TimeToDie=5
	bTimerStart=false
	bWannaExplode=false
	bPlayerSeen=false
}
