#include <a_samp>
#include <zcmd>
#include <streamer>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16 //Change it to the ammount of players you got in your server


new gRocketObj[MAX_PLAYERS],       // Variable to hold the object ID
    FireShot[MAX_PLAYERS],        	// Variable to detect if already shot (for Timer)
    detecttimer[MAX_PLAYERS];	// detects bomb


public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerInAnyVehicle(playerid) && FireShot[playerid] == 0 && newkeys & 4 && !IsValidObject(gRocketObj[playerid]))   // Only run the code if the object doesn't already exist, otherwise more objects will take up gRocketObj and the previous ones won't be deleted
	{
	    new
	        vehicleid = GetPlayerVehicleID(playerid),   // Initialise variables
		Float:x,
		Float:y,
		Float:z,
		Float:r;

		SetPlayerTime(playerid, 0, 0);
		FireShot[playerid] = 1;
 		SetTimerEx("ShotFire", 1000, 0, "i", playerid);
		detecttimer[playerid] = SetTimerEx("detectbomb", 100, 0, "i", playerid);
 		GetVehiclePos(vehicleid, x, y, z);
  		GetVehicleZAngle(vehicleid, r);
  		new rand = random(5);
  		switch(rand)
  		{
			case 0: gRocketObj[playerid] = CreateObject(18647, x, y, z, 0, 0, r);
			case 1: gRocketObj[playerid] = CreateObject(18648, x, y, z, 0, 0, r);
			case 2: gRocketObj[playerid] = CreateObject(18649, x, y, z, 0, 0, r);
			case 3: gRocketObj[playerid] = CreateObject(18650, x, y, z, 0, 0, r);
			case 4: gRocketObj[playerid] = CreateObject(18651, x, y, z, 0, 0, r);
			case 5: gRocketObj[playerid] = CreateObject(18651, x, y, z, 0, 0, r);
		}
  		MoveObject(gRocketObj[playerid],x + (50.0 * floatsin(-r, degrees)),y + (50.0 * floatcos(-r, degrees)), z, 100);                    // Nice and fast!
	}
	return 1;
}

forward detectbomb(playerid);
public detectbomb(playerid)
{
	new
		Float:tx,
		Float:ty,
		Float:tz,
		Float:x,
		Float:y,
		Float:z;

	for(new targetid = 0; targetid < MAX_PLAYERS; targetid++)
	{
		if(!IsPlayerConnected(targetid) || targetid == playerid || !IsPlayerInAnyVehicle(targetid)) continue;
		GetPlayerPos(targetid, tx, ty, tz);
		GetObjectPos(gRocketObj[playerid], x, y, z);
		if(IsPlayerInRangeOfPoint(targetid, 5, x, y, z))
		{
 			CreateExplosion(x, y, z, 11, 5.0);
   			DestroyObject(gRocketObj[playerid]);
			KillTimer(detecttimer[playerid]);
		}
		else if(!IsPlayerInRangeOfPoint(targetid,3.0, x, y, z))
		{

		}
	}
	return 1;
}

forward ShotFire(playerid);
public ShotFire(playerid)
{
	FireShot[playerid] = 0;
	return 1;
}

public OnObjectMoved(objectid)
{
	for(new i;i<MAX_PLAYERS;i++)                    		// Loop through players
	{
		if(!IsPlayerConnected(i)) continue;
		if(objectid == gRocketObj[i])               		// If this object is one of those player objects
		{
		new
			Float:x,
			Float:y,
			Float:z;

		GetObjectPos(gRocketObj[i], x, y, z);
		CreateExplosion(x, y, z, 11, 2.50);      	// Create an explosion at this position
		DestroyObject(gRocketObj[i]); 			// Destroy the object
		KillTimer(detecttimer[i]);
		return 1;
		}
	}
	return 1;
}
