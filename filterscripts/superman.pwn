#include <a_samp>
#include <zcmd>
#include <streamer>

#define MAX_VELOCITY	(3.0)
#define MIN_VELOCITY	(1.0)
#define VELOCITY_STEP   (0.1)
#define HEIGHT_GAIN		(100.0)

new
	fly[MAX_PLAYERS],
	Float:jVel[MAX_PLAYERS] = MIN_VELOCITY,
	Float:velMult[MAX_PLAYERS];

public OnFilterScriptInit()
{
	for(new i;i<MAX_PLAYERS;i++)jVel[i] = MIN_VELOCITY;
	return 1;
}
public OnFilterScriptExit()
{
	return 1;
}
CMD:jv(playerid, params[])
{
	jVel[playerid] = floatstr(params);
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_JUMP && newkeys & 16)
	{
	    if(fly[playerid])
		{
		    ApplyAnimation(playerid, "PARACHUTE", "FALL_SKYDIVE", 4.0, 0, 0, 0, 0, 0, 1);
		    fly[playerid] = false;
		    RemovePlayerAttachedObject(playerid, 0);

		}
		else
		{
		    new Float:x, Float:y, Float:z;
		    GetPlayerVelocity(playerid, x, y, z);
		    ApplyAnimation(playerid, "PARACHUTE", "FALL_SKYDIVE_ACCEL", 1.0, 1, 0, 0, 0, 0, 1);
		    fly[playerid] = true;
		    velMult[playerid] = 0.0;
		    SetPlayerAttachedObject(playerid, 0, 18694, 1, -0.210587, 0.000000, -1.547866, 0.000000, 0.000000, 180.000000, 1.000000, 1.000000, 1.000000);
			SetPlayerVelocity(playerid, x, y, z+1.5);
		}
	}
}

public OnPlayerUpdate(playerid)
{
	if(!fly[playerid])return 1;

	SetPlayerHealth(playerid, 1000.0);

	new k, ud, lr;
	GetPlayerKeys(playerid, k, ud, lr);
	if(k & KEY_JUMP)
	{
	    new
	        Float:hMult = 0.0085,
			Float:ang,
			Float:x,
			Float:y,
			Float:z;

		GetPlayerFacingAngle(playerid, ang);
		GetPlayerVelocity(playerid, x, y, z);
		
		if(velMult[playerid]<MIN_VELOCITY)velMult[playerid]+=VELOCITY_STEP;
		if(ud & KEY_UP && velMult[playerid]<MAX_VELOCITY)velMult[playerid]+=VELOCITY_STEP;
		else if(velMult[playerid]>MIN_VELOCITY)velMult[playerid]-=VELOCITY_STEP;

		if(k & KEY_SPRINT)hMult = HEIGHT_GAIN;

		SetPlayerVelocity(playerid, (jVel[playerid]*velMult[playerid])*floatsin(-ang, degrees), (jVel[playerid]*velMult[playerid])*floatcos(-ang, degrees), z+hMult);
	}

	if(lr == KEY_LEFT)
	{
	    new
			Float:ang;
		GetPlayerFacingAngle(playerid, ang);
		SetPlayerFacingAngle(playerid, ang+5);
	}
	else if(lr == KEY_RIGHT)
	{
	    new
			Float:ang;
		GetPlayerFacingAngle(playerid, ang);
		SetPlayerFacingAngle(playerid, ang-5);
	}

	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    fly[playerid] = false;
}


