#define FILTERSCRIPT

#include <a_samp>
#include <ZCMD>


CMD:fps(playerid, params[])
{
	new id = CreateObject(19300, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
	AttachObjectToPlayer(id, playerid, 0.0, 0.0, 0.75, 0.0, 0.0, 0.0);
	AttachCameraToObject(playerid, id);

	return 1;
}

CMD:recam(playerid, params[])
{
	SetCameraBehindPlayer(playerid);
	return 1;
}