#include <a_samp>
#include <YSI\y_va>
#include <formatex>
#include "../scripts/System/PlayerFunctions.pwn"
#include <zcmd>
#include <streamer>
#include <colours>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16


#define MAGIC_NUMBER_FOR_METERS_PER_SECOND 57.0 * 3.6


public OnPlayerUpdate(playerid)
{
	new
	    Float:vx,
	    Float:vy,
	    Float:vz,
		Float:s,
		str[64];
	    
	if(IsPlayerInAnyVehicle(playerid))GetVehicleVelocity(GetPlayerVehicleID(playerid), vx, vy, vz);
	else GetPlayerVelocity(playerid, vx, vy, vz);
	
	s = floatsqroot( (vx*vx)+(vy*vy)+(vz*vz) ) * MAGIC_NUMBER_FOR_METERS_PER_SECOND;
	
	format(str, 64, "Velocity: %f", vz);
	CallRemoteFunction("sffa_msgbox", "dsdd", playerid, str, 0, 130);

	return 1;
}

