#include <a_samp>
#include <zcmd>
#include "../scripts/Releases/Camera Sequencer/CameraMover.inc"

#undef MAX_PLAYERS
#define MAX_PLAYERS 16


CMD:playcamera(playerid, params[])
{
	if(strlen(params)>3)PlayCameraMover(playerid, LoadCameraMover(params));
	return 1;
}

CMD:hidehud(playerid, params[])
{
	for(new i;i<2048;i++)PlayerTextDrawHide(playerid, PlayerText:i);
	return 1;
}
