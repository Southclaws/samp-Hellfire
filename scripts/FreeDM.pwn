#include <YSI\y_hooks>


#define FDM_MAX_AREA		(10)
#define FDM_MAX_AREA_NAME	(32)
#define FDM_MAX_FILE_NAME	(FDM_MAX_AREA_NAME+13)
#define FDM_MAX_SPAWN		(300)

#define FDM_INDEX_FILE		"FreeDM/index.ini"
#define FDM_DATA_FILE		"FreeDM/%s.dat"


enum E_SPAWN_DATA
{
		fdm_pickup,
		fdm_type,
Float:	fdm_posX,
Float:	fdm_posY,
Float:	fdm_posZ,
Float:	fdm_rot
}


new
		fdm_AreaNames			[FDM_MAX_AREA][FDM_MAX_AREA_NAME],
		fdm_SpawnData			[FDM_MAX_SPAWN][E_SPAWN_DATA],
Timer:	fdm_PickupRespawnTimer	[FDM_MAX_SPAWN],
		fdm_Zone,
		fdm_Area,
		fdm_TotalSpawns,
		fdm_TotalAreas;

new
		fdm_LeaveZoneCount		[MAX_PLAYERS],
Timer:	fdm_LeaveZoneTimer		[MAX_PLAYERS],
        fdm_PlayerWeaponDrop	[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	if(bServerGlobalSettings & FreeDM)
	{
	    GangZoneShowForPlayer(playerid, fdm_Zone, 0xFF000050);
	}
    fdm_PlayerWeaponDrop[playerid] = INVALID_ITEM_ID;
}

fdm_Start(area)
{
	new
		filename[FDM_MAX_FILE_NAME],
		File:file,
		line[128],
		idx,
		Float:minx = 6000,
		Float:miny = 6000,
		Float:maxx = -6000,
		Float:maxy = -6000,
		Float:x,
		Float:y,
		Float:z,
		ammo,
		itemname[32];

	format(filename, 40, FDM_DATA_FILE, fdm_AreaNames[area]);
	if(!fexist(filename))
	{
		printf("ERROR: FILE '%s' NOT FOUND", filename);
		return 0;
	}

	file=fopen(filename, io_read);

	fdm_TotalSpawns = 0;
	while(fread(file, line))
	{
		sscanf(line, "p<,>fffF(0)",
			fdm_SpawnData[idx][fdm_posX],
			fdm_SpawnData[idx][fdm_posY],
			fdm_SpawnData[idx][fdm_posZ],
			fdm_SpawnData[idx][fdm_rot]);

		if(fdm_SpawnData[idx][fdm_posY] > maxy)maxy = fdm_SpawnData[idx][fdm_posY];
		if(fdm_SpawnData[idx][fdm_posY] < miny)miny = fdm_SpawnData[idx][fdm_posY];
		if(fdm_SpawnData[idx][fdm_posX] > maxx)maxx = fdm_SpawnData[idx][fdm_posX];
		if(fdm_SpawnData[idx][fdm_posX] < minx)minx = fdm_SpawnData[idx][fdm_posX];

		fdm_SpawnData[idx][fdm_type]	= (22 + random(13));

		fdm_SpawnData[idx][fdm_pickup]	= CreateItem(ItemType:fdm_SpawnData[idx][fdm_type],
			fdm_SpawnData[idx][fdm_posX],
			fdm_SpawnData[idx][fdm_posY],
			fdm_SpawnData[idx][fdm_posZ]-0.8,
			90.0, 0.0, 0.0,
			0.8, FREEROAM_WORLD);

		ammo = WepData[fdm_SpawnData[idx][fdm_type]][MagSize] * (2 + random(5));
		SetItemExtraData(fdm_SpawnData[idx][fdm_pickup], ammo);

		format(itemname, 32, "%s\nAmmo: %d", WepData[fdm_SpawnData[idx][fdm_type]][WepName], ammo);
		SetItemLabel(fdm_SpawnData[idx][fdm_pickup], itemname);

		idx++;
	}
	fdm_TotalSpawns = idx;
	fclose(file);
	
	minx -= 300.0;
	miny -= 300.0;
	maxx += 300.0;
	maxy += 300.0;

	fdm_Zone = GangZoneCreate(minx, miny, maxx, maxy);
	fdm_Area = CreateDynamicRectangle(minx, miny, maxx, maxy, FREEROAM_WORLD, 0);

    t:bServerGlobalSettings<FreeDM>;
    PlayerLoop(i)
	{
		GangZoneShowForPlayer(i, fdm_Zone, 0xFF000050);
		GetPlayerPos(i, x, y, z);
	    if(minx < x < maxx && miny < y < maxy)
	    {
			ResetPlayerWeapons(i);
			t:bPlayerGameSettings[i]<InFreeDM>;
			f:bPlayerGameSettings[i]<GodMode>;
			f:bPlayerGameSettings[i]<WepLock>;
			SetPlayerArmour(i, 0.0);
			GivePlayerWeapon(i, 29, 60);
			GivePlayerWeapon(i, 22, 17 * 3);
	    	ToggleRaceStarts(i, false);
		}
	}
	SetGameModeText("Freeroam Deathmatch");
	SetMapName(fdm_AreaNames[area]);

	MsgAllF(YELLOW,
		" >  Free For All Deathmatch mode "#C_ORANGE"activated"#C_YELLOW", area: "#C_BLUE"%s"#C_YELLOW"! Fight for yourself or team up, but watch out for traitors!",
		fdm_AreaNames[area]);
	return 1;
}
fdm_End()
{
	for(new i;i<fdm_TotalSpawns;i++)
		if(IsValidItem(fdm_SpawnData[i][fdm_pickup]))
			DestroyItem(fdm_SpawnData[i][fdm_pickup]);

	GangZoneDestroy(fdm_Zone);
	DestroyDynamicArea(fdm_Area);

    PlayerLoop(i)
	{
	    f:bPlayerGameSettings[i]<InFreeDM>;
	    ToggleRaceStarts(i, true);
		ResetPlayerWeapons(i);
	}
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(IsValidItem(fdm_PlayerWeaponDrop[i]))
		    DestroyItem(fdm_PlayerWeaponDrop[i]);
	}

	fdm_TotalSpawns = 0;
    f:bServerGlobalSettings<FreeDM>;
	SetGameModeText("Freeroam[NoDM]");

	MsgAll(YELLOW, " >  Free For All Deathmatch mode is "#C_BLUE"deactivated");
	return 1;
}


public OnPlayerEnterDynamicArea(playerid, areaid)
{
	if(areaid == fdm_Area && !(bPlayerGameSettings[playerid] & InFreeDM))
	{
		GameTextForPlayer(playerid, "~n~~n~~r~warning:~n~entering deathmatch area", 5000, 5);
		ResetPlayerWeapons(playerid);
		t:bPlayerGameSettings[playerid]<InFreeDM>;
		f:bPlayerGameSettings[playerid]<GodMode>;
		f:bPlayerGameSettings[playerid]<WepLock>;
		GivePlayerWeapon(playerid, 29, 60);
		GivePlayerWeapon(playerid, 22, 17 * 3);
	    ToggleRaceStarts(playerid, false);
	}
	stop fdm_LeaveZoneTimer[playerid];
	return CallLocalFunction("fdm_OnPlayerEnterDynamicArea", "dd", playerid, areaid);
}
#if defined _ALS_OnPlayerEnterDynamicArea
    #undef OnPlayerEnterDynamicArea
#else
    #define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea fdm_OnPlayerEnterDynamicArea
forward fdm_OnPlayerEnterDynamicArea(playerid, areaid);

public OnPlayerLeaveDynamicArea(playerid, areaid)
{
	if(areaid == fdm_Area && bPlayerGameSettings[playerid] & InFreeDM)
	{
		GameTextForPlayer(playerid, "~n~~n~~r~warning:~n~leaving deathmatch area~n~10", 5000, 5);
		fdm_LeaveZoneCount[playerid] = 10;
		fdm_LeaveZoneCheck(playerid);
	}
	return CallLocalFunction("fdm_OnPlayerLeaveDynamicArea", "dd", playerid, areaid);
}
#if defined _ALS_OnPlayerLeaveDynamicArea
    #undef OnPlayerLeaveDynamicArea
#else
    #define _ALS_OnPlayerLeaveDynamicArea
#endif
#define OnPlayerLeaveDynamicArea fdm_OnPlayerLeaveDynamicArea
forward fdm_OnPlayerLeaveDynamicArea(playerid, areaid);

timer fdm_LeaveZoneCheck[1000](playerid)
{
	new str[51];

	if(fdm_LeaveZoneCount[playerid] == 0)
	{
	    f:bPlayerGameSettings[playerid]<InFreeDM>;
	    ToggleRaceStarts(playerid, true);
		ResetPlayerWeapons(playerid);
		stop fdm_LeaveZoneTimer[playerid];
		return 1;
	}

	format(str, 51, "~n~~n~~r~warning:~n~leaving deathmatch area~n~%d", fdm_LeaveZoneCount[playerid]);
	GameTextForPlayer(playerid, str, 5000, 5);

	fdm_LeaveZoneTimer[playerid] = defer fdm_LeaveZoneCheck(playerid);
	fdm_LeaveZoneCount[playerid]--;
	return 1;
}

public OnPlayerPickedUpItem(playerid, itemid)
{
	for(new i; i < fdm_TotalSpawns; i++)
	{
		if(itemid == fdm_SpawnData[i][fdm_pickup])
		{
			stop fdm_PickupRespawnTimer[i];
			fdm_PickupRespawnTimer[i] = defer fdm_RespawnPickup(i);
		}
	}

	PlayerLoop(i)
	{
		if(itemid == fdm_PlayerWeaponDrop[i])
		{
			fdm_PlayerWeaponDrop[i] = INVALID_ITEM_ID;
			break;
		}
	}
    return CallLocalFunction("fdm_OnPlayerPickedUpItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerPickedUpItem
    #undef OnPlayerPickedUpItem
#else
    #define _ALS_OnPlayerPickedUpItem
#endif
#define OnPlayerPickedUpItem fdm_OnPlayerPickedUpItem
forward fdm_OnPlayerPickedUpItem(playerid, itemid);


timer fdm_RespawnPickup[60000](id)
{
	new
		ammo,
		itemname[32];

	fdm_SpawnData[id][fdm_type]		= 22 + random(13);

	fdm_SpawnData[id][fdm_pickup]	= CreateItem(ItemType:fdm_SpawnData[id][fdm_type],
		fdm_SpawnData[id][fdm_posX],
		fdm_SpawnData[id][fdm_posY],
		fdm_SpawnData[id][fdm_posZ]-0.8,
		90.0, 0.0, 0.0,
		0.8, FREEROAM_WORLD);

	ammo = WepData[fdm_SpawnData[id][fdm_type]][MagSize] * (2 + random(5));

	SetItemExtraData(fdm_SpawnData[id][fdm_pickup], ammo);

	format(itemname, 32, "%s\nAmmo: %d", WepData[fdm_SpawnData[id][fdm_type]][WepName], ammo);
	SetItemLabel(fdm_SpawnData[id][fdm_pickup], itemname);
}
script_FreeDM_OnPlayerDeath(playerid, killerid)
{
	GivePlayerMoney(killerid, 50);
	GivePlayerMoney(playerid, -20);
	GivePlayerScore(killerid, 1);
	
	if(IsValidItem(fdm_PlayerWeaponDrop[playerid]))
	    DestroyItem(fdm_PlayerWeaponDrop[playerid]);

	// fdm_PlayerWeaponDrop[playerid] = PlayerDropWeapon(playerid);

	return 1;
}

timer fdm_Spawn[500](playerid)
{
	new id = random(fdm_TotalSpawns);

	SetPlayerPos(playerid,
		fdm_SpawnData[id][fdm_posX],
		fdm_SpawnData[id][fdm_posY],
		fdm_SpawnData[id][fdm_posZ]);

	SetPlayerFacingAngle(playerid, fdm_SpawnData[id][fdm_rot]);

	GivePlayerWeapon(playerid, 22, 17*4);
	GivePlayerWeapon(playerid, 29, 30*4);
}


hook OnDialogResponse(playerid, dialogid, response, listitem)
{
#pragma unused playerid
	if(dialogid == d_FreeDmAreaList && response)
	{
		fdm_Start(listitem);
	}
}
fdm_FormatAreaList(playerid)
{
	new list[FDM_MAX_AREA * (FDM_MAX_AREA_NAME+1)];
	for(new i;i<fdm_TotalAreas;i++)
	{
	    strcat(list, fdm_AreaNames[i]);
	    strcat(list, "\n");
	}
	ShowPlayerDialog(playerid, d_FreeDmAreaList, DIALOG_STYLE_LIST, "Deathmatch Area", list, "Start", "Cancel");
}


ACMD:ffa[1](playerid, params[])
{
	if(bServerGlobalSettings & FreeDM)fdm_End();
	else fdm_FormatAreaList(playerid);
    return 1;
}
