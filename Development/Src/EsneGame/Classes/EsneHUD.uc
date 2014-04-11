class EsneHUD extends HUD;

var Vector2D HealthTileSize;                        //Size of the Health Texture
var Material HealthMaterial;                        //The Health Material
var Vector2D HalfHealthSize;                        //Half of the size of the Health Texture, used to improve calcs
var MaterialInstanceConstant HealthOpacedMaterial; //Used to modify Health opacity

var float PlayerHealth;                             //Actual Health of the player
var float PlayerMaxHealth;                          //Player maximum health. If = to PlayerHealth, we don't calculate the health drawing

var Texture2D CoinTexture;                          //Texture of the coin
var Texture2D JazzGunTexture;                       //Texture of the gun
var Texture2D BulletTexture;                        //Texture of a bullet

var const int CoinOffset;                           //Margin between the screen edge and the printed texture
var const float CoinScale;                          //Scale of the printed coin texture. Usually cause texture is bigger
var const float CoinTextScale;                      //Scale of the numbers that indicate the money we have
var float CoinScaleSize;                            //Size of the Texture with applied scale

var const int GunOffset;                            //Margin between the screen edge and the printed texture
var const float GunScale;                           //Scale of the printed gun texture. Usually cause texture is bigger
var float GunScaleSize;                             //Size of the Texture with applied scale

var float BulletScaleSize;                          //The space between bullets
var const int BulletOffset;                         //Moves the bullet to fit the screen

var const Vector2D GunBackgroundSize;               //Size of the Background painted behind the ammo
var const Vector2D GunBackgroundOffset;             //Margin between the Background border and the gun texture
var const Color GunBackgroundColor;                 //Color of the Background painted behind the ammo (alpha included)

var string SubtitleText;                            //Text that will be printed on subtitles
var bool bPrintSubtitles;                           //If we are printing subtitles NOW or not
var const Vector2D SubtitleOffset;                  //Height that the text will appear from the bottom of the screen

var const Rotator MaterialMirrorY;  //Used to rotate materials
var const Rotator MaterialMirrorX;  //Used to rotate materials
var Color HUDColor;
var Color SubtitlesColor;

/**
 * Initializes needed vars
 * */
function PostBeginPlay()
{
	super.PostBeginPlay();

	HalfHealthSize.X = HealthTileSize.X/2;
	HalfHealthSize.Y = HealthTileSize.Y/2;
	PlayerMaxHealth = self.GetALocalPlayerController().Pawn.HealthMax;

	CoinScaleSize = CoinTexture.OriginalSizeX * CoinScale;
	GunScaleSize = JazzGunTexture.OriginalSizeX * GunScale;
	BulletScaleSize = (BulletTexture.OriginalSizeX * GunScale) /2;

	HealthOpacedMaterial = new class'MaterialInstanceConstant';
	HealthOpacedMaterial.SetParent(HealthMaterial);
}

/**
 * HUD update
 * */
function DrawHUD()
{
	super.DrawHUD();

	Canvas.Font = class'Engine'.static.GetLargeFont();
	Canvas.DrawColor = HUDColor;

	DrawSubtitles();
	DrawDamage();
	DrawCoinsHUD();
	DrawAmmo();
}

/**
 * Draws the damage done to the player
 * */
function DrawDamage()
{
	PlayerHealth = self.GetALocalPlayerController().Pawn.Health;

	//If tha player is full health we don't need to calculate and draw this
	if(PlayerHealth < PlayerMaxHealth)
	{
		//Sets the material value
		HealthOpacedMaterial.SetScalarParameterValue('HealthHUDOpacity', 1-(PlayerHealth/PlayerMaxHealth));

		Canvas.SetPos(0, self.CenterY - HalfHealthSize.Y);
		Canvas.DrawMaterialTile(HealthOpacedMaterial,HealthTileSize.X,HealthTileSize.Y);
		Canvas.SetPos(SizeX - HealthTileSize.X, self.CenterY - HalfHealthSize.Y);
		Canvas.DrawRotatedMaterialTile(HealthOpacedMaterial,MaterialMirrorY,HealthTileSize.X,HealthTileSize.Y);
		Canvas.SetPos(CenterX - HalfHealthSize.X, 0 - HalfHealthSize.X);
		Canvas.DrawRotatedMaterialTile(HealthOpacedMaterial, MaterialMirrorX, HealthTileSize.X, HealthTileSize.Y);
		Canvas.SetPos(CenterX- HalfHealthSize.X, SizeY - HealthTileSize.X - HalfHealthSize.X);
		Canvas.DrawRotatedMaterialTile(HealthOpacedMaterial, MaterialMirrorX + MaterialMirrorY, HealthTileSize.X, HealthTileSize.Y);
	}
}

/**
 * Draws the quantity of coins the player has
 * */
function DrawCoinsHUD()
{
	Canvas.SetPos(CoinOffset, CoinOffset);
	Canvas.DrawTexture(CoinTexture, CoinScale);
	Canvas.SetPos(CoinOffset + CoinScaleSize, CoinOffset);
	Canvas.DrawText(string(EsnePlayerController(self.GetALocalPlayerController()).Money), , CoinTextScale , CoinTextScale );
}

/**
 * Draws the ammo left on the gun
 * */
function DrawAmmo()
{
	local int i;
	//We draw a rectangle so the HUD is more visible
	Canvas.DrawColor = GunBackgroundColor;
	Canvas.SetPos(SizeX - GunOffset - GunScaleSize - GunBackgroundOffset.X, SizeY - GunOffset - GunScaleSize - GunBackgroundOffset.Y);
	Canvas.DrawRect( GunBackgroundSize.X, GunOffset + GunBackgroundSize.Y);

	//Draws the gun picture
	Canvas.DrawColor = HUDColor;
	Canvas.SetPos(SizeX - GunOffset - GunScaleSize, SizeY - GunOffset - GunScaleSize);
	Canvas.DrawTexture(JazzGunTexture, GunScale);

	//Draws the bullets left
	for(i = 0; i<EsnePlayerController(self.GetALocalPlayerController()).GetAmmo(); i++)
	{
		Canvas.SetPos(SizeX - GunOffset - BulletOffset - GunScaleSize + (BulletScaleSize * (i+1)), SizeY - GunOffset );
		Canvas.DrawTexture(BulletTexture, GunScale);
	}
}

/**
 * Draws the subtitles on the screen
 * */
function DrawSubtitles()
{
	if(bPrintSubtitles)
	{
		Canvas.Font = class'Engine'.static.GetSubtitleFont();
		Canvas.DrawColor = SubtitlesColor;
		Canvas.SetPos(SubtitleOffset.X, SizeY - SubtitleOffset.Y);
		Canvas.DrawText(SubtitleText, false);
		Canvas.Font = class'Engine'.static.GetLargeFont();
		Canvas.DrawColor = HUDColor;
	}
}

/**
 * Prints the given subtitles
 * @param   text    The text that will appear on the subtitles
 * */
function PlaySubtitles(string text)
{
	SubtitleText=text;
	bPrintSubtitles=true;
}

/**
 * Removes the subtitles from the screen
 * */
function RemoveSubtitles()
{
	bPrintSubtitles=false;
}

DefaultProperties
{
	bShowOverlays=true

	HealthTileSize=(X=256, Y=512);
	HealthMaterial=Material'EsnePackage.HUD.HealthMaterial'
	CoinTexture=Texture2D'EsnePackage.HUD.coin'
	JazzGunTexture=Texture2D'EsnePackage.HUD.Gun'
	BulletTexture=Texture2D'EsnePackage.HUD.Bullet'

	MaterialMirrorY=(Pitch=0,Roll=0,Yaw=32768)
	MaterialMirrorX=(Pitch=0,Roll=0,Yaw=16384)
	HUDColor=(R=127,G=127,B=127,A=255)

	CoinOffset=10
	CoinScale=0.3
	CoinTextScale=2

	GunOffset=30
	GunScale=0.2
	BulletOffset=30

	GunBackgroundSize=(X=500,Y=500)
	GunBackgroundOffset=(X=50,Y=0)
	GunBackgroundColor=(R=0,G=0,B=0,A=200)

	SubtitleOffset=(X=30,Y=200)
	SubtitlesColor=(R=255,G=0,B=0,A=255)

	bPrintSubtitles=false
}
