#include <a_samp>
#include <zcmd>
#include <streamer>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16

#define MODEL_ID 8171
#define MAX_ROAD_OBJ 19

#define ROAD_START_X -10000.0
#define ROAD_START_Y 0.0
#define ROAD_START_Z 500.0

#define ROAD_OFFSET 138.306

new
    roadMode[MAX_PLAYERS],
    Float:pRoadX[MAX_PLAYERS],
	pRoadObj[MAX_PLAYERS][MAX_ROAD_OBJ];

forward roadUpdate();

public OnFilterScriptInit()
{
	return 1;
}
public OnFilterScriptExit()
{
	return 1;
}

CMD:road(playerid, params[])
{
	SetPlayerPos(playerid, ROAD_START_X, ROAD_START_Y, ROAD_START_Z+1.0);
	SetPlayerFacingAngle(playerid, 270.0);
	SetPlayerVirtualWorld(playerid, 5);
	SetPlayerInterior(playerid, 0);
	if(IsPlayerInAnyVehicle(playerid))
	{
		new tmpVeh = GetPlayerVehicleID(playerid);
		SetVehiclePos(tmpVeh, ROAD_START_X, ROAD_START_Y, ROAD_START_Z+1.0);
		SetVehicleZAngle(tmpVeh, 270.0);
		SetVehicleVirtualWorld(tmpVeh, 5);
		PutPlayerInVehicle(playerid, tmpVeh, 0);
	}
	BuildPlayerRoad(playerid);

	roadMode[playerid] = true;
	pRoadX[playerid] = ROAD_START_X;

	SetTimer("roadUpdate", 1000, true);

	return 1;
}

BuildPlayerRoad(playerid)
{
	for(new i;i<MAX_ROAD_OBJ;i++)
	{
	    for(new p;p<MAX_PLAYERS;p++)if(IsValidDynamicObject(pRoadObj[p][i]))continue;
		pRoadObj[playerid][i] = CreateDynamicObject(MODEL_ID, ROAD_START_X+(ROAD_OFFSET*(i-(MAX_ROAD_OBJ/2))), ROAD_START_Y, ROAD_START_Z, 0.0, 0.0, 90.0, 5);
	}
}
ExitRoadMode(playerid)
{
    roadMode[playerid] = false;
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerInterior(playerid, 0);
	if(IsPlayerInAnyVehicle(playerid))
	{
		new tmpVeh = GetPlayerVehicleID(playerid);
		SetVehicleVirtualWorld(tmpVeh, 0);
		PutPlayerInVehicle(playerid, tmpVeh, 0);
	}
	for(new i;i<MAX_ROAD_OBJ;i++)
	{
	    if(IsValidDynamicObject(pRoadObj[playerid][i]))DestroyDynamicObject(pRoadObj[playerid][i]);
	}
}

UpdatePlayerRoad(playerid, Float:x)
{
	new tmpOffset = floatround((x - ROAD_START_X) / ROAD_OFFSET) ;
	for(new i;i<MAX_ROAD_OBJ;i++)
	{
		SetDynamicObjectPos(pRoadObj[playerid][i],

			ROAD_START_X + (ROAD_OFFSET * ((i+tmpOffset) - (MAX_ROAD_OBJ/2)) ),

			ROAD_START_Y, ROAD_START_Z);
	}
}



public roadUpdate()
{
	for(new i;i<MAX_PLAYERS;i++)
	if(roadMode[i])
	{
		new
			Float:x,
			Float:y,
			Float:z;

		if(IsPlayerInAnyVehicle(i))GetVehiclePos(GetPlayerVehicleID(i), x, y, z);
		else GetPlayerPos(i, x, y, z);

		if(floatround((x - pRoadX[i]) / ROAD_OFFSET) != 0.0)UpdatePlayerRoad(i, x);
		if(floatabs(y - ROAD_START_Y) > 50.0 || z<100.0)ExitRoadMode(i);

	}
}
