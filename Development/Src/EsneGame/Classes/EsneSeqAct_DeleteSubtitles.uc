class EsneSeqAct_DeleteSubtitles extends SequenceAction;

event Activated()
{
	EsneHUD(GetWorldInfo().GetALocalPlayerController().myHUD).RemoveSubtitles();
}


DefaultProperties
{
	ObjName="Delete Subtitles"
	ObjCategory="Esne"
}
