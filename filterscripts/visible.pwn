#define FILTERSCRIPT

#include <a_samp>
#include <ZCMD>

#define RUN_VELOCITY		(20)
#define CROUCH_VELOCITY		(20)

#define MAX_RUN_ALPHA		(255)
#define MIN_RUN_ALPHA		(100)
#define MAX_CROUCH_ALPHA	(35)
#define MIN_CROUCH_ALPHA	(0)


public OnPlayerUpdate(playerid)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)return 1;

	new
		Float:x,
		Float:y,
		Float:z,
		velocity,
		colour[1 char],
		bool:tag;

	GetPlayerVelocity(playerid, x, y, z);
	velocity = floatround(((x*x)+(y*y)+(z*z)) * 10000);

	colour[0] = GetPlayerColor(playerid);

	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_DUCK && velocity < 60)
	{
	    tag = false;
		if(velocity > CROUCH_VELOCITY)
			colour{3} = MAX_CROUCH_ALPHA;

		else
			colour{3} = MIN_CROUCH_ALPHA;
	}
	else
	{
	    tag = true;
		if(velocity > RUN_VELOCITY)
			colour{3} = MAX_RUN_ALPHA;

		else
			colour{3} = MIN_RUN_ALPHA;
	}


	for(new i; i < MAX_PLAYERS; i++)
	{
		ShowPlayerNameTagForPlayer(i, playerid, tag);
		SetPlayerMarkerForPlayer(i, playerid, colour[0]);
	}


	return 1;
}

