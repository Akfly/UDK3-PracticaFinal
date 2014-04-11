/**
 * This class manages the EnemyPawn.
 * It's an NPC that walks from one point to another
 * and plays an animation every time that reaches a point
 * (or collides with an obstacle)
 * */
class EsneAIController extends GameAIController;

var array<PathNode> PathNodeList;   //List of every node

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

/**
 * Gets a random position between 2000 and -2000 that will become a destination
 * @return  The final position
 * */
function vector GetRandomPos()
{
	local vector pos;

	pos.x=RandRange(-2000,2000);
	pos.y=RandRange(-2000,2000);
	self.FindRandomDest();

	return pos;
}

/**
 * The initial state. I will remain freeze in this state for a random seconds, then I'll start to move
 * */
auto state Initial
{
	Begin:
		Sleep(10+Rand(5));
		GetALocalPlayerController().myHUD.AddPostRenderedActor(Pawn);
		GoToState('Moving');
}

/**
 * I get a random position and then move to that Location
 * */
state Moving
{
	Begin:
		ScriptedMoveTarget = self.FindRandomDest();
		// while we have a valid pawn and move target, and
		// we haven't reached the target yet
		while (Pawn != None &&
			   ScriptedMoveTarget != None &&
			   !Pawn.ReachedDestination(ScriptedMoveTarget))
		{
			// check to see if it is directly reachable
			if (ActorReachable(ScriptedMoveTarget))
			{
				// then move directly to the actor
				MoveToward(ScriptedMoveTarget, ScriptedFocus);
			}
			else
			{
			   // attempt to find a path to the target
			   MoveTarget = FindPathToward(ScriptedMoveTarget);
			   if (MoveTarget != None)
			   {
				   // move to the first node on the path
				   MoveToward(MoveTarget, ScriptedFocus);
			   }
			   else
			   {
				   // abort the move                
				   ScriptedMoveTarget = None;
			   }
			}
		}

		GoToState('Idle');
}

/**
 * I play an animation, wait untill it's finished and then move to a new position again
 * */
state Idle
{
	Begin:
		EsnePawn(Pawn).AnimNodeSlot.PlayCustomAnim('Taunt_UB_BulletToTheHead', 1.0);
		FinishAnim(EsnePawn(Pawn).AnimNodeSlot.GetCustomAnimNodeSeq());

		GoToState('Moving');
}

DefaultProperties
{
}
