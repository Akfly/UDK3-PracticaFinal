/**
 * This pawn has a capped Sight, so it won't see the player easily.
 * It likes to explode (read EsneSuicideController for its behavior)
 */
class EsneSuicidePawn extends EsneEnemyPawn;

DefaultProperties
{
	ControllerClass=class'EsneSuicideController'
	SightRadius=1000
	GroundSpeed=500
}
