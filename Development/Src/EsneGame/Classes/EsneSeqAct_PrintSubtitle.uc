class EsneSeqAct_PrintSubtitle extends SequenceAction;

var() string Message;   //The message that will be printed

event Activated()
{
	EsneHUD(GetWorldInfo().GetALocalPlayerController().myHUD).PlaySubtitles(Message);
}

DefaultProperties
{
	ObjName="Print Subtitle"
	ObjCategory="Esne"
}
