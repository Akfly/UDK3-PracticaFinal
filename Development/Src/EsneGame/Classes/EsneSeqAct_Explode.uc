/**
 * Kismet function that makes the enemy to Explode
 * */
class EsneSeqAct_Explode extends SequenceAction;

var Object Enemy;

event Activated()
{
	if(EsneEnemyPawn(Enemy) != none)
	{
		EsneEnemyPawn(Enemy).Explode();
	}
}

DefaultProperties
{
	ObjName="Explode Enemy"
	ObjCategory="Esne"

	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Enemy",PropertyName=Enemy)
}