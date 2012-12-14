#include <a_samp>
#include <zcmd>
#include "../scripts/Releases/CameraMover.pwn"

#undef MAX_PLAYERS
#define MAX_PLAYERS 16

new
	gCam;

public OnFilterScriptInit()
{
	gCam = LoadCameraMover("test");
}

CMD:camtest(playerid, params[])
{
	PlayCameraMover(playerid, gCam, .loop = true);
	return 1;
}
CMD:exitcam(playerid, params[])
{
	ExitCamera(playerid);
	return 1;
}
