#define FILTERSCRIPT

#include <a_samp>
#include <YSI\y_timers>


/*
 *  SwimFix by Southclaw (2012)
 *
 *		While underwater, a player has an idle Z velocity of 0.01715
 *		I found this gets annoying when trying to swim through underwater
 *		passages as the player gets stuck on the ceiling a lot.
 *
 *		This short FS just simply keeps the player at a Z velocity of 0
 *		while idle or swimming forward, this is detected using camera
 *		vectors and the checks are done on a 1 second timer instead of
 *		OnPlayerUpdate.
 *
 *
 *  Do what you want with it, but keep my name on it :)
 *
 */

new
	bool:gSwimmingDown[MAX_PLAYERS];


ptask SwimCameraCheck[1000](playerid)
{
	new
		Float:vx,
		Float:vy,
		Float:vz,
		Float:vecz;

	GetPlayerVelocity(playerid, vx, vy, vz);
	GetPlayerCameraFrontVector(playerid, vecz, vecz, vecz);

/*
 *  Here, the camera vector is checked, if it's below 0.1
 *  the player is looking downwards. I chose 0.1 because it
 *  it gives a bit of looking space for swimming forwards.
 */

	if(vecz < 0.1)
		gSwimmingDown[playerid] = true;

	else
		gSwimmingDown[playerid] = false;
}

public OnPlayerUpdate(playerid)
{
	new animidx = GetPlayerAnimationIndex(playerid);
	
	switch(animidx)
	{
/*
 *	If the player is using animations for swimming down,
 *	forward or just idle, they will get pushed down a bit.
 */
	    case 1541, 1544:
	    {
			if(gSwimmingDown[playerid])
			{
				new
					Float:vx,
					Float:vy,
					Float:vz;

				GetPlayerVelocity(playerid, vx, vy, vz);
				SetPlayerVelocity(playerid, vx, vy, -0.0026);
			}
	    }
	}
	return 1;
}
