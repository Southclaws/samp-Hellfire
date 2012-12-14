#include <a_samp>
#include <formatex>
#include <zcmd>
#include <streamer>
#include <colours>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16


public OnPlayerUpdate(playerid)
{
	new
	    k, ud, lr,
		animidx = GetPlayerAnimationIndex(playerid),
		Float:x, Float:y, Float:z,
		Float:ang;

	GetPlayerKeys(playerid, k, ud, lr);
	GetPlayerFacingAngle(playerid, ang);
	GetPlayerPos(playerid, x, y, z);

	if(animidx == 1061)
	{
	    if(lr == KEY_LEFT)
	    {
	        SetPlayerVelocity(playerid, 0.5*floatsin(-ang-90.0, degrees), 0.5*floatcos(-ang-90.0, degrees), 0.0);
//	        SetPlayerPos(playerid, x + floatsin(-ang-90.0, degrees), y + floatcos(-ang-90.0, degrees), z);
	        ApplyAnimation(playerid, "PED", "CLIMB_IDLE", 4.0, 1, 0, 0, 0, 0);
	    }
	    else if(lr == KEY_RIGHT)
	    {
	        SetPlayerVelocity(playerid, 0.5*floatsin(-ang+90.0, degrees), 0.5*floatcos(-ang+90.0, degrees), 0.0);
//	        SetPlayerPos(playerid, x + floatsin(-ang+90.0, degrees), y + floatcos(-ang+90.0, degrees), z);
	        ApplyAnimation(playerid, "PED", "CLIMB_IDLE", 4.0, 1, 0, 0, 0, 0);
	    }
	}
	return 1;
}
