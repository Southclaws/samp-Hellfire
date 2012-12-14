#include <a_samp>
#include <YSI\y_va>
#include <formatex>
#include "../scripts/System/PlayerFunctions.pwn"
#include <zcmd>
#include <streamer>
#include <colours>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16

new trippymode[MAX_PLAYERS];

CMD:trippy(playerid, params[])
{
    trippymode[playerid] =! trippymode[playerid];
    return 1;
}

public OnPlayerUpdate(playerid)
{
	if(trippymode[playerid])
	{
	    SetPlayerWeather(playerid, random(10000));
	}
	return 1;
}
