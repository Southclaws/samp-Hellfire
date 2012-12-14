#define FILTERSCRIPT

#include <a_samp>
#include <ZCMD>
#include <YSI\y_timers>


new
	gPlayerFps[MAX_PLAYERS];

public OnFilterScriptInit()
{
	for(new i;i<MAX_PLAYERS;i++)
	{
		if(IsPlayerConnected(i))
		{
		    repeat UpdateFps(i);
		}
	}
}

timer UpdateFps[5000](playerid)
{
	gPlayerFps[playerid] = GetPlayerDrunkLevel(playerid);
	SetPlayerDrunkLevel(playerid, 1000);
	
	new str[128];
	format(str, 128, "~n~~n~~n~%d", gPlayerFps[playerid]);
	GameTextForPlayer(playerid, str, 5500, 5);
}



