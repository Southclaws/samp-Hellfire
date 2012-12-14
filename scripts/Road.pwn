#define MODEL_ID 8171
#define MAX_ROAD_OBJ 50

#define ROAD_START_X -10000.0
#define ROAD_START_Y 0.0
#define ROAD_START_Z 500.0

#define ROAD_OFFSET 138.306


new
Bit1:	rd_IsPlayerAtRoad	<MAX_PLAYERS>,
Float:	rd_PlayerRoadX		[MAX_PLAYERS],
		rd_PlayerRoadObj	[MAX_PLAYERS][MAX_ROAD_OBJ],
Timer:	rd_Timer[MAX_PLAYERS];


CMD:road(playerid, params[])
{
	if(!IsPlayerInFreeRoam(playerid))return 2;

	MsgAllF(YELLOW, " >  %P"#C_YELLOW" has gone to the "#C_BLUE"Never Ending Road"#C_YELLOW". Type "#C_ORANGE"/road "#C_YELLOW" to go there.", playerid);

    rd_Enter(playerid);

	return 1;
}

rd_Enter(playerid)
{
	SetPlayerPos(playerid, ROAD_START_X, ROAD_START_Y, ROAD_START_Z+4.0);
	SetPlayerFacingAngle(playerid, 270.0);
	SetPlayerInterior(playerid, 0);

	if(IsPlayerInAnyVehicle(playerid))
	{
		new vehicleid = GetPlayerVehicleID(playerid);

		SetVehiclePos(vehicleid, ROAD_START_X, ROAD_START_Y, ROAD_START_Z+1.0);
		SetVehicleZAngle(vehicleid, 270.0);
		PutPlayerInVehicle(playerid, vehicleid, 0);
	}

	FreezePlayer(2000, playerid);
	rd_Timer[playerid] = repeat rd_Update(playerid);
	rd_PlayerRoadX[playerid] = ROAD_START_X;
	rd_BuildForPlayer(playerid);

	Bit1_Set(rd_IsPlayerAtRoad, playerid, true);
}

rd_Exit(playerid)
{
	stop rd_Timer[playerid];
	Bit1_Set(rd_IsPlayerAtRoad, playerid, false);

	for(new i;i<MAX_ROAD_OBJ;i++)
	{
		if(IsValidDynamicObject(rd_PlayerRoadObj[playerid][i]))
			DestroyDynamicObject(rd_PlayerRoadObj[playerid][i]);
	}
}

rd_BuildForPlayer(playerid)
{
	for(new i;i<MAX_ROAD_OBJ;i++)
	{
		PlayerLoop(j)
			if(IsValidDynamicObject(rd_PlayerRoadObj[j][i]))
				continue;

		rd_PlayerRoadObj[playerid][i] = CreateDynamicObject(MODEL_ID,
			ROAD_START_X+(ROAD_OFFSET*(i-(MAX_ROAD_OBJ/2))),
			ROAD_START_Y, ROAD_START_Z, 0.0, 0.0, 90.0, FREEROAM_WORLD);
	}
}

timer rd_Update[1000](playerid)
{
	new
		Float:x,
		Float:y,
		Float:z;

	if(IsPlayerInAnyVehicle(playerid))GetVehiclePos(GetPlayerVehicleID(playerid), x, y, z);
	else GetPlayerPos(playerid, x, y, z);

	if(floatround((x - rd_PlayerRoadX[playerid]) / ROAD_OFFSET) != 0.0)
	{
		new tmpOffset = floatround((x - ROAD_START_X) / ROAD_OFFSET) ;
		for(new i;i<MAX_ROAD_OBJ;i++)
		{
			SetDynamicObjectPos(rd_PlayerRoadObj[playerid][i],
				ROAD_START_X + (ROAD_OFFSET * ((i+tmpOffset) - (MAX_ROAD_OBJ/2)) ),
				ROAD_START_Y, ROAD_START_Z);
		}
	}

	if(floatabs(y - ROAD_START_Y) > 50.0 || z < (ROAD_START_Z-100.0))
		rd_Exit(playerid);
}

