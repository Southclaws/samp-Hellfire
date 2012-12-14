#include <a_samp>
#include <YSI\y_va>
#include <formatex>
#include "../scripts/System/PlayerFunctions.pwn"
#include <zcmd>
#include <streamer>
#include <colours>
#include <cuffs>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16


CMD:cuff(playerid, params[])
{
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED)
	{
		SetPlayerCuffed(playerid, 0);
	}
	else
	{
		SetPlayerCuffed(playerid, 1);
	}
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_JUMP && !(oldkeys & KEY_JUMP) && GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED)ApplyAnimation(playerid, "GYMNASIUM", "gym_jog_falloff",4.1,0,1,1,0,0);
}
