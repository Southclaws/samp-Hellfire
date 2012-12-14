#include <a_samp>
#include <YSI\y_va>
#include <formatex>
#include "../scripts/System/PlayerFunctions.pwn"
#include <zcmd>
#include <streamer>
#include <foreach>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16 // Shit I forgot to change this value in my 32 slot server...


new
	bool:gRocketCar[MAX_PLAYERS],   // Is the player using Car Rockets?
	gRocketObj[MAX_PLAYERS];        // Variable to hold the object ID

CMD:rocketcar(playerid, params[])
{
	gRocketCar[playerid] = !gRocketCar[playerid];   // Turn it on and off by assigning the opposite (Compliment) of itself to itself.
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(
		IsPlayerInAnyVehicle(playerid) &&       // Is the player in a vehicle?
		newkeys & 4 &&                          // Fire key in a vehicle
		!IsValidObject(gRocketObj[playerid]))   // Only run the code if the object doesn't already exist, otherwise more objects will take up gRocketObj and the previous ones won't be deleted
	{
	    new
	        vehicleid = GetPlayerVehicleID(playerid),   // Initialise variables
			Float:x,
			Float:y,
			Float:z,
			Float:r,
			Float:dist = 50.0,
			Float:tmpang,
			Float:tmpx,
			Float:tmpy,
			Float:tmpz,
		    Float:vx,
		    Float:vy,
		    Float:vz,
			Float:vspeed;

	    GetVehiclePos(vehicleid, x, y, z);
	    GetVehicleZAngle(vehicleid, r);
		GetVehicleVelocity(GetPlayerVehicleID(playerid), vx, vy, vz);

		vspeed = floatsqroot( (vx*vx)+(vy*vy)+(vz*vz) );

		gRocketObj[playerid] = CreateObject(18650, x, y, z, 0.0, 0.0, r);       // Create the object inside the vehicle

		for(new i;i<MAX_PLAYERS;i++)
		{
		    if(i == playerid)continue;
		    if(IsPlayerInRangeOfPoint(i, 50.0, x, y, z))
		    {
		        GetPlayerPos(i, tmpx, tmpy, tmpz); // Loop player pos

		        tmpang = (90-atan2(tmpy-y, tmpx-x)); // Get the angle from 'playerid' to 'i'
		        if(tmpang < 0)tmpang = 360.0+tmpang; // Fix the angle for negatives
		        tmpang = 360.0 - tmpang; // Fix the angle for stupid sa-mp inversion

//		        msgF(playerid, -1, "ang: %f veh: %f offset: %f",  tmpang, r, floatabs(tmpang-r)); // debug derp

				if( floatabs(tmpang-r) < 5.0) // If the absolute of the angle to the player minus the vehicle angle is lower than 5
				{
				    dist = GetPlayerDistanceFromPoint(i, x, y, z); // Distance is set
				}
		    }
		}
//	    msgF(playerid, -1, "Dist: %f", dist); // moar debug derp

  	    MoveObject(
			gRocketObj[playerid],               // Move the object just created
			x + (dist * floatsin(-r, degrees)), // Add the sine of the angle onto the X multiplied by the distance (30.0)
			y + (dist * floatcos(-r, degrees)), // Do the same for the cosine of the angle, multiply by the same distance and add it to the Y
			z,                                  // The Z doesn't change (It should but that's more complex, it involves getting all angles of the vehicle)
			(100.0 * vspeed) + 100.0);                             // Nice and fast!
	}
}


public OnObjectMoved(objectid)
{
	for(new i;i<MAX_PLAYERS;i++)               		// Loop through connected players
	{
		if(objectid == gRocketObj[i])               // If this object is one of those player objects
		{
		    new
				Float:x,
				Float:y,
				Float:z;

		    GetObjectPos(gRocketObj[i], x, y, z);   // Get the position of the object
		    CreateExplosion(x, y, z, 11, 3.0);      // Create an explosion at this position
		    DestroyObject(gRocketObj[i]);           // Destroy the object
		}
	}
}


