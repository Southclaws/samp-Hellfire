#define MAX_TELEPORTER			(16)
#define INVALID_TELEPORTER_ID	(-1)


enum E_TELEPORTER_DATA
{
			tpt_areaId,
			tpt_objectId,
Float:		tpt_posX,
Float:		tpt_posY,
Float:		tpt_posZ,
			tpt_world1,
			tpt_world2
}


new
			tpt_Data[MAX_TELEPORTER][E_TELEPORTER_DATA],
Iterator:	tpt_Index<MAX_TELEPORTER>,
			tpt_AnimationObjects[MAX_TELEPORTER][5],
			tpt_AnimationObjState[MAX_TELEPORTER][5];

new
Timer:			tpt_TeleportTimer[MAX_PLAYERS];


stock CreateTeleporter(Float:x, Float:y, Float:z, world1, world2)
{
	new id = Iter_Free(tpt_Index);
	if(id == -1)return INVALID_TELEPORTER_ID;

	new worlds[2];

	worlds[0] = world1;
	worlds[1] = world2;

	tpt_Data[id][tpt_areaId] = CreateDynamicSphereEx(x, y, z, 3.0, worlds, {0});
	tpt_Data[id][tpt_objectId] = CreateDynamicObjectEx(18658, x, y, z + 8.0, -90.0, 0.0, 0.0, 0.0, 200.0, worlds, {0});

	tpt_Data[id][tpt_posX] = x;
	tpt_Data[id][tpt_posY] = y;
	tpt_Data[id][tpt_posZ] = z;

	tpt_Data[id][tpt_world1] = world1;
	tpt_Data[id][tpt_world2] = world2;

	Iter_Add(tpt_Index, id);

	return id;
}

public OnPlayerEnterDynamicArea(playerid, areaid)
{
	foreach(new i : tpt_Index)
	{
		if(areaid == tpt_Data[i][tpt_areaId])
		{
			new world = GetPlayerVirtualWorld(playerid);

			if(world == tpt_Data[i][tpt_world1])
			{
				tpt_TeleportTimer[playerid] = defer tpt_Teleport(playerid, tpt_Data[i][tpt_world2]);
				tpt_Animate(i);
			}
			if(world == tpt_Data[i][tpt_world2])
			{
				tpt_TeleportTimer[playerid] = defer tpt_Teleport(playerid, tpt_Data[i][tpt_world1]);
				tpt_Animate(i);
			}
		}
	}

    return CallLocalFunction("tpt_OnPlayerEnterDynamicArea", "dd", playerid, areaid);
}
#if defined _ALS_OnPlayerEnterDynamicArea
    #undef OnPlayerEnterDynamicArea
#else
    #define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea tpt_OnPlayerEnterDynamicArea
forward tpt_OnPlayerEnterDynamicArea(playerid, areaid);


public OnPlayerLeaveDynamicArea(playerid, areaid)
{
	foreach(new i : tpt_Index)
	{
		if(areaid == tpt_Data[i][tpt_areaId])
		{
			stop tpt_TeleportTimer[playerid];

			DestroyDynamicObject(tpt_AnimationObjects[i][0]);
			DestroyDynamicObject(tpt_AnimationObjects[i][1]);
			DestroyDynamicObject(tpt_AnimationObjects[i][2]);
			DestroyDynamicObject(tpt_AnimationObjects[i][3]);
			DestroyDynamicObject(tpt_AnimationObjects[i][4]);
		}
	}

    return CallLocalFunction("tpt_OnPlayerLeaveDynamicArea", "dd", playerid, areaid);
}
#if defined _ALS_OnPlayerLeaveDynamicArea
    #undef OnPlayerLeaveDynamicArea
#else
    #define _ALS_OnPlayerLeaveDynamicArea
#endif
#define OnPlayerLeaveDynamicArea tpt_OnPlayerLeaveDynamicArea
forward tpt_OnPlayerLeaveDynamicArea(playerid, areaid);


timer tpt_Teleport[3000](playerid, world)
{
	if(IsPlayerInAnyVehicle(playerid))
	{
		new vehicleid = GetPlayerVehicleID(playerid);
		SetVehicleVirtualWorld(vehicleid, world);
		SetPlayerVirtualWorld(playerid, world);
		PutPlayerInVehicle(playerid, vehicleid, 0);
	}
	else 
	{
		SetPlayerVirtualWorld(playerid, world);
	}
	GameTextForPlayer(playerid, "~b~Teleported!", 3000, 5);
}

tpt_Animate(id)
{
	new worlds[2];

	worlds[0] = tpt_Data[id][tpt_world1];
	worlds[1] = tpt_Data[id][tpt_world2];

	tpt_AnimationObjects[id][0] = CreateDynamicObjectEx(18657, tpt_Data[id][tpt_posX], tpt_Data[id][tpt_posY], tpt_Data[id][tpt_posZ] + 7.0, -90.0, 0.0, 0.0, 0.0, 200.0, worlds, {0});
	tpt_AnimationObjects[id][1] = CreateDynamicObjectEx(18656, tpt_Data[id][tpt_posX], tpt_Data[id][tpt_posY], tpt_Data[id][tpt_posZ] + 7.0, -90.0, 0.0, 0.0, 0.0, 200.0, worlds, {0});
	tpt_AnimationObjects[id][2] = CreateDynamicObjectEx(18657, tpt_Data[id][tpt_posX], tpt_Data[id][tpt_posY], tpt_Data[id][tpt_posZ] + 7.0, -90.0, 0.0, 0.0, 0.0, 200.0, worlds, {0});
	tpt_AnimationObjects[id][3] = CreateDynamicObjectEx(18658, tpt_Data[id][tpt_posX], tpt_Data[id][tpt_posY], tpt_Data[id][tpt_posZ] + 7.0, -90.0, 0.0, 0.0, 0.0, 200.0, worlds, {0});
	tpt_AnimationObjects[id][4] = CreateDynamicObjectEx(18657, tpt_Data[id][tpt_posX], tpt_Data[id][tpt_posY], tpt_Data[id][tpt_posZ] + 7.0, -90.0, 0.0, 0.0, 0.0, 200.0, worlds, {0});


	MoveDynamicObject(tpt_AnimationObjects[id][0], tpt_Data[id][tpt_posX], tpt_Data[id][tpt_posY]+1.5, tpt_Data[id][tpt_posZ] + 20.0, 16.0, -90.0, 180.0, 0.0);
	MoveDynamicObject(tpt_AnimationObjects[id][1], tpt_Data[id][tpt_posX], tpt_Data[id][tpt_posY]+1.5, tpt_Data[id][tpt_posZ] + 21.0, 14.0, -90.0, 180.0, 0.0);
	MoveDynamicObject(tpt_AnimationObjects[id][2], tpt_Data[id][tpt_posX], tpt_Data[id][tpt_posY]+1.5, tpt_Data[id][tpt_posZ] + 22.0, 12.0, -90.0, 180.0, 0.0);
	MoveDynamicObject(tpt_AnimationObjects[id][3], tpt_Data[id][tpt_posX], tpt_Data[id][tpt_posY]+1.5, tpt_Data[id][tpt_posZ] + 23.0, 10.0, -90.0, 180.0, 0.0);
	MoveDynamicObject(tpt_AnimationObjects[id][4], tpt_Data[id][tpt_posX], tpt_Data[id][tpt_posY]+1.5, tpt_Data[id][tpt_posZ] + 24.0, 8.0, -90.0, 180.0, 0.0);

	tpt_AnimationObjState[id][0] = 0;
	tpt_AnimationObjState[id][1] = 0;
	tpt_AnimationObjState[id][2] = 0;
	tpt_AnimationObjState[id][3] = 0;
	tpt_AnimationObjState[id][4] = 0;
}

public OnDynamicObjectMoved(objectid)
{
	foreach(new i : tpt_Index)
	{
		if(objectid == tpt_AnimationObjects[i][0])
		{
			if(tpt_AnimationObjState[i][0] == 0)
			{
				MoveDynamicObject(tpt_AnimationObjects[i][0], tpt_Data[i][tpt_posX], tpt_Data[i][tpt_posY], tpt_Data[i][tpt_posZ] + 6.0, 20.0, -90.0, 0.0, 0.0);
				tpt_AnimationObjState[i][0] = 1;
			}
			else
			{
				DestroyDynamicObject(tpt_AnimationObjects[i][0]);
				tpt_AnimationObjState[i][0] = 0;
			}
		}
		if(objectid == tpt_AnimationObjects[i][1])
		{
			if(tpt_AnimationObjState[i][1] == 0)
			{
				MoveDynamicObject(tpt_AnimationObjects[i][1], tpt_Data[i][tpt_posX], tpt_Data[i][tpt_posY], tpt_Data[i][tpt_posZ] + 6.0, 20.0, -90.0, 0.0, 0.0);
				tpt_AnimationObjState[i][1] = 1;
			}
			else
			{
				DestroyDynamicObject(tpt_AnimationObjects[i][1]);
				tpt_AnimationObjState[i][1] = 0;
			}
		}


		if(objectid == tpt_AnimationObjects[i][2])
		{
			if(tpt_AnimationObjState[i][2] == 0)
			{
				MoveDynamicObject(tpt_AnimationObjects[i][2], tpt_Data[i][tpt_posX], tpt_Data[i][tpt_posY], tpt_Data[i][tpt_posZ] + 6.0, 20.0, -90.0, 0.0, 0.0);
				tpt_AnimationObjState[i][2] = 1;
			}
			else
			{
				DestroyDynamicObject(tpt_AnimationObjects[i][2]);
				tpt_AnimationObjState[i][2] = 0;
			}
		}
		if(objectid == tpt_AnimationObjects[i][3])
		{
			if(tpt_AnimationObjState[i][3] == 0)
			{
				MoveDynamicObject(tpt_AnimationObjects[i][3], tpt_Data[i][tpt_posX], tpt_Data[i][tpt_posY], tpt_Data[i][tpt_posZ] + 6.0, 20.0, -90.0, 0.0, 0.0);
				tpt_AnimationObjState[i][3] = 1;
			}
			else
			{
				DestroyDynamicObject(tpt_AnimationObjects[i][3]);
				tpt_AnimationObjState[i][3] = 0;
			}
		}
		if(objectid == tpt_AnimationObjects[i][4])
		{
			if(tpt_AnimationObjState[i][4] == 0)
			{
				MoveDynamicObject(tpt_AnimationObjects[i][4], tpt_Data[i][tpt_posX], tpt_Data[i][tpt_posY], tpt_Data[i][tpt_posZ] + 6.0, 20.0, -90.0, 0.0, 0.0);
				tpt_AnimationObjState[i][4] = 1;
			}
			else
			{
				DestroyDynamicObject(tpt_AnimationObjects[i][4]);
				tpt_AnimationObjState[i][4] = 0;
			}
		}
	}
    return CallLocalFunction("tpt_OnDynamicObjectMoved", "d", objectid);
}
#if defined _ALS_OnDynamicObjectMoved
    #undef OnDynamicObjectMoved
#else
    #define _ALS_OnDynamicObjectMoved
#endif
#define OnDynamicObjectMoved tpt_OnDynamicObjectMoved
forward tpt_OnDynamicObjectMoved(objectid);
