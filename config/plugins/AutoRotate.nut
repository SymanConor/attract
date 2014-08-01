///////////////////////////////////////////////////
//
// Attract-Mode Frontend - AutoRotate plugin
//
///////////////////////////////////////////////////
//
// Define the user-configurable options:
//
class UserConfig </ help="This plugin can automatically rotate the frontend display to match the last game played, and can also change the default rotation" /> {

	</ label="Default Rotation", help="Set the default rotation for the frontend", options="0,90,180,270" order=1 />
	default_rot="0";

	</ label="Automatic Rotation", help="Set the additional rotation to apply when automatic rotation is needed (set this to None to disable automatic rotation)", options="None,90,180,270", order=2 />
	auto_rot="270";
}

local config=fe.get_config();

local width = ScreenWidth;
local height = ScreenHeight;
local adjust_base = RotateScreen.None;

switch ( config["default_rot"] )
{
	case "90":
		width = ScreenHeight;
		height = ScreenWidth;
		adjust_base = RotateScreen.Right;
		break;

	case "180":
		adjust_base = RotateScreen.Flip;
		break;

	case "270":
		width = ScreenHeight;
		height = ScreenWidth;
		adjust_base = RotateScreen.Left;
		break;

	case "0":
	default:
		break;
};

local is_vert=false;
if ( width < height )
	is_vert=true;

if ( adjust_base != RotateScreen.None )
{
	fe.layout.base_rotation =
		( fe.layout.base_rotation + adjust_base ) % 4;
}

local auto_rot = RotateScreen.None;
switch ( config["auto_rot"] )
{
	case "90": auto_rot = RotateScreen.Right; break;
	case "180": auto_rot = RotateScreen.Flip; break;
	case "270": auto_rot = RotateScreen.Left; break;
	case "None":
	default:
		break;
}

if (( auto_rot != RotateScreen.None ) && ( !ScreenSaverActive ))
{
	//
	// We only register the callback function if we will be doing
	// autorotations (the user might enable the plugin just to change
	// the default rotations)
	//
	fe.add_transition_callback( "autorotate_plugin_transition" );
}

function do_auto_rotate( r )
{
	return (
		(( is_vert ) && (( r == "0" ) || ( r == "180" )))
		|| (( !is_vert ) && (( r == "90" ) || ( r == "270" )))
		);
}

function autorotate_plugin_transition( ttype, var, ttime )
{
	switch ( ttype )
	{
	case Transition.FromGame:
		if ( do_auto_rotate( fe.game_info( Info.Rotation ) ) )
			fe.layout.toggle_rotation = auto_rot;
		else
			fe.layout.toggle_rotation = RotateScreen.None;
		break;
	}

	return false; // must return false
}
