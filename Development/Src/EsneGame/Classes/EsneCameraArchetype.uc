/**
 * This class is the Archetype for the player camera,
 * so every value here can be edited in the editor
 * */
class EsneCameraArchetype extends Object HideCategories(Object);

var(MainCamera) const string StartingCamera<DisplayName=Starting Camera Name|ToolTip="The name of the camera which is shown at the start of the game. Leave blank for default.">;

var(FollowPawn) const Vector FollowPawnPos<DisplayName=Camera Position|ToolTip="Position of the camera on this camera mode">;
var(FollowPawn) const float FollowPawnMaxZoom<DisplayName=Maximum Zoom|ToolTip="Maximum Zoom distance allowed">;
var(FollowPawn) const float FollowPawnMinZoom<DisplayName=Minimum Zoom|ToolTip="Minimum Zoom distance allowed">;

var(DiabloLike) const Vector DiabloLikePos<DisplayName=Camera Position|ToolTip="Position of the camera on this camera mode">;
var(DiabloLike) const float DiabloLikeMaxZoom<DisplayName=Maximum Zoom|ToolTip="Maximum Zoom distance allowed">;
var(DiabloLike) const float DiabloLikeMinZoom<DisplayName=Minimum Zoom|ToolTip="Minimum Zoom distance allowed">;

var(Side) const Vector SidePos<DisplayName=Camera Position|ToolTip="Position of the camera on this camera mode">;
var(Side) const Rotator SideRot<DisplayName=Camera Rotation|ToolTip="Rotation of the camera on this camera mode">;

var(Gears) const Vector GearsPos<DisplayName=Camera Position|ToolTip="Position of the camera on this camera mode">;

var(LateralSide) const Vector LateralSidePos<DisplayName=Camera Position|ToolTip="Position of the camera on this camera mode">;
var(LateralSide) const Rotator LateralSideRot<DisplayName=Camera Rotation|ToolTip="Rotation of the camera on this camera mode">;

DefaultProperties
{
}
