class EsneSeqAct_BuyAmmo extends SequenceAction;

var Object PlayerPawn;              //Player Pawn set on Kismet
var bool bItsFree;

event Activated()
{
	local int AmmoNeeded;
	local int MoneyQuantity;

	AmmoNeeded=EsneWeaponJazz(Pawn(PlayerPawn).Weapon).GetLackAmmo();
	MoneyQuantity=EsnePlayerController(GetWorldInfo().GetALocalPlayerController()).Money;

	//if pawn exists !!!
	if(PlayerPawn != none)
	{
		//If the weapon is not already full o.O
		if(AmmoNeeded > 0)
		{
			if(bItsFree)
			{
				EsneWeaponJazz(Pawn(PlayerPawn).Weapon).ReloadFullAmmo();
			}
			else
			{
				if(AmmoNeeded * 10 <= MoneyQuantity)
				{
					EsnePlayerController(GetWorldInfo().GetALocalPlayerController()).ModifyMoney(AmmoNeeded * -10);
					EsneWeaponJazz(Pawn(PlayerPawn).Weapon).ReloadFullAmmo();
				}
				else if(MoneyQuantity >= 10)
				{
					EsnePlayerController(GetWorldInfo().GetALocalPlayerController()).ModifyMoney(((AmmoNeeded * 10) - MoneyQuantity)*-1);
					EsneWeaponJazz(Pawn(PlayerPawn).Weapon).ReloadSomeAmmo(AmmoNeeded - MoneyQuantity);
				}
			}
		}
	}
}

DefaultProperties
{
	ObjName="Buy Ammo"
	ObjCategory="Esne"

	VariableLinks(0)=(ExpectedType=class'SeqVar_Bool',LinkDesc="GetFree",PropertyName=bItsFree)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Player",PropertyName=PlayerPawn)
}
