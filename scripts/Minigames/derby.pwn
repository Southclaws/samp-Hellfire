#include <YSI\y_hooks>

#define DBY_INDEX_FILE		"Derby/index.ini"
#define DBY_DATA_FILE		"Derby/%s.dat"
#define DBY_CAM_FILE		"dbycam.%s"
#define DBY_MAX_ARENA		(8)
#define DBY_MAX_NAME		(32)
#define DBY_MAX_SPAWN		(8)
#define DBY_SPAWN_ZOFFSET	(5.0)
#define DBY_MAX_LIVES       (5)
#define DBY_SPEC_NONE       (-1)
#define DBY_SPEC_ARENA		(-2)
#define DBY_SPEC_SELF		(-3)


enum E_DBY_ARENA_DATA
{
	dby_Name[DBY_MAX_NAME],
	dby_MaxSpawns,
	dby_Camera,
	Float:dby_SpawnX[DBY_MAX_SPAWN],
	Float:dby_SpawnY[DBY_MAX_SPAWN],
	Float:dby_SpawnZ[DBY_MAX_SPAWN],
	Float:dby_SpawnR[DBY_MAX_SPAWN]
}

new
	dby_Data[DBY_MAX_ARENA][E_DBY_ARENA_DATA],
	dby_CurrentArena,
	dby_TotalArenas;

new
    PlayerText:dby_TdBack,
    PlayerText:dby_TdText,
    PlayerText:dby_TdVehicle,
    PlayerText:dby_TdSpawn,

	dby_Lives[MAX_PLAYERS],
	dby_SpawnCount[MAX_PLAYERS],
	dby_PlayerVehicleID[MAX_PLAYERS],
	dby_PlayerVehicleModel[MAX_PLAYERS],
	dby_Spectating[MAX_PLAYERS],
	Timer:dby_SpawnTimer[MAX_PLAYERS],
	Timer:dby_SpawnDelayTimer[MAX_PLAYERS],
	Timer:dby_SpectateTimer[MAX_PLAYERS],
	Timer:dby_VehicleDeathTimer[MAX_PLAYERS],
	Iterator:dby_SpawnedIndex<MAX_PLAYERS>;

new
	dby_Vehicles[19]=
	{
		504,
		498,
		502,
		503,
		475,
		470,
		478,
		571,
		471,
		479,
		482,
		483,
		489,
		494,
		495,
		496,
		542,
		556,
		572
	};

CMD:derby(playerid, params[])
{
	if(gCurrentChallenge != CHALLENGE_NONE)
	{
	    Msg(playerid, YELLOW, " >  You can't start a minigame while a challenge is active.");
	    return 1;
	}
	if(gCurrentMinigame[playerid] == MINIGAME_DESDRBY)
	{
	    dby_Leave(playerid);
	}
	else if(gCurrentMinigame[playerid] == MINIGAME_NONE)
	{
	    if(bServerGlobalSettings & dby_InProgress)dby_Join(playerid);
		else dby_FormatArenaList(playerid);
	}
	else
	{
	    Msg(playerid, YELLOW, " >  Please exit your current minigame before joining another");
	}
	return 1;
}

dby_Join(playerid, msg = true)
{
    gCurrentMinigame[playerid] = MINIGAME_DESDRBY;
    t:bServerGlobalSettings<dby_InProgress>;
	t:bPlayerGameSettings[playerid]<Invis>;
	dby_Lives[playerid] = DBY_MAX_LIVES;
	dby_FormatVehicleList(playerid);
	SetPlayerVirtualWorld(playerid, MINIGAME_WORLD);

    if(Iter_Contains(dby_SpawnedIndex, playerid))Iter_Remove(dby_SpawnedIndex, playerid);

	PlayerTextDrawSetString(playerid, dby_TdSpawn, "5");
	PlayerTextDrawSetSelectable(playerid, dby_TdSpawn, false);
	dby_SpawnTimer[playerid] = defer dby_UpdateSpawnButton(playerid);
	dby_SpawnCount[playerid] = 4;
	dby_Spectate(playerid);

	if(msg)
	{
		PlayerLoop(i)if(IsPlayerInFreeRoam(i) || gCurrentMinigame[playerid] == MINIGAME_FALLOUT)
			MsgF(i, YELLOW, " >  %P"#C_YELLOW" has joined the "#C_BLUE"Destruction Derby "#C_YELLOW"minigame on "#C_BLUE"%s"#C_YELLOW"! Type "#C_ORANGE"/derby "#C_YELLOW"to join.", playerid, dby_Data[dby_CurrentArena][dby_Name]);
	}
}

dby_Spawn(playerid)
{
	if(dby_Spectating[playerid] == DBY_SPEC_ARENA && IsValidCameraSequencer(dby_Data[dby_CurrentArena][dby_Camera]))
		ExitPlayerCameraSequencer(playerid);

	TogglePlayerSpectating(playerid, false);
	TogglePlayerControllable(playerid, true);
	SetPlayerVirtualWorld(playerid, MINIGAME_WORLD);

	new spawn = random(dby_Data[dby_CurrentArena][dby_MaxSpawns]);
	dby_PlayerVehicleID[playerid] = CreateVehicle(dby_PlayerVehicleModel[playerid],
		dby_Data[dby_CurrentArena][dby_SpawnX][spawn],
		dby_Data[dby_CurrentArena][dby_SpawnY][spawn],
		dby_Data[dby_CurrentArena][dby_SpawnZ][spawn] + DBY_SPAWN_ZOFFSET,
		dby_Data[dby_CurrentArena][dby_SpawnR][spawn], -1, -1, -1);

	SetVehicleVirtualWorld(dby_PlayerVehicleID[playerid], MINIGAME_WORLD);
	SetVehicleParamsEx(dby_PlayerVehicleID[playerid], 1, 1, 0, 0, 0, 0, 0);

	dby_SpawnDelayTimer[playerid] = defer dby_SpawnDelay(playerid);
}
timer dby_SpawnDelay[1000](playerid)
{
	PutPlayerInVehicle(playerid, dby_PlayerVehicleID[playerid], 0);

	PlayerTextDrawShow(playerid, dby_TdBack);
	PlayerTextDrawShow(playerid, dby_TdText);
	dby_HideLobbyControls(playerid);
	dby_UpdateTextDraw(playerid);

    Iter_Add(dby_SpawnedIndex, playerid);
	dby_Spectating[playerid] = DBY_SPEC_NONE;
}
timer dby_OnPlayerVehicleDeath[6000](playerid)
{
	if(IsValidVehicle(dby_PlayerVehicleID[playerid]))DestroyVehicle(dby_PlayerVehicleID[playerid]);
	dby_Spectate(playerid);
	dby_ShowLobbyControls(playerid);

	PlayerTextDrawSetString(playerid, dby_TdSpawn, "5");
	PlayerTextDrawSetSelectable(playerid, dby_TdSpawn, false);
	dby_SpawnTimer[playerid] = defer dby_UpdateSpawnButton(playerid);
	dby_SpawnCount[playerid] = 4;
}

dby_ShowLobbyControls(playerid)
{
	PlayerTextDrawShow(playerid, dby_TdVehicle);
	PlayerTextDrawShow(playerid, dby_TdSpawn);
	SelectTextDraw(playerid, YELLOW);
}
dby_HideLobbyControls(playerid)
{
	PlayerTextDrawHide(playerid, dby_TdVehicle);
	PlayerTextDrawHide(playerid, dby_TdSpawn);
	CancelSelectTextDraw(playerid);
}

timer dby_UpdateSpawnButton[1000](playerid)
{
	if(dby_SpawnCount[playerid] <= 0)
	{
		PlayerTextDrawSetString(playerid, dby_TdSpawn, "Spawn");
		PlayerTextDrawSetSelectable(playerid, dby_TdSpawn, true);
	}
	else
	{
		new
			tmpStr[2];

		valstr(tmpStr, dby_SpawnCount[playerid]);
		PlayerTextDrawSetString(playerid, dby_TdSpawn, tmpStr);

	    dby_SpawnCount[playerid]--;
	    dby_SpawnTimer[playerid] = defer dby_UpdateSpawnButton(playerid);
	}
	dby_ShowLobbyControls(playerid);
}

hook OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(playertextid == dby_TdVehicle)
	{
	    dby_FormatVehicleList(playerid);
	}
	if(playertextid == dby_TdSpawn)
	{
	    dby_Spawn(playerid);
	}
}


script_derby_Update(playerid)
{
	if(Iter_Contains(dby_SpawnedIndex, playerid))
	{
		new
		    iVehicle = GetPlayerVehicleID(playerid),
			Float:vhealth;

		GetVehicleHealth(dby_PlayerVehicleID[playerid], vhealth);
		
		if(vhealth < 250)dby_Out(playerid);

		if(!IsValidVehicle(iVehicle))
			PutPlayerInVehicle(playerid, dby_PlayerVehicleID[playerid], 0);

	}
	return 1;
}


dby_Out(playerid)
{
	new
		winner,
		count;

	Iter_Remove(dby_SpawnedIndex, playerid);
	ResetSpectatorTarget(playerid);
	
	PlayerTextDrawHide(playerid, dby_TdBack);
	PlayerTextDrawHide(playerid, dby_TdText);

	for(new i;i<MAX_PLAYERS;i++)
	{
	    if(!IsPlayerConnected(i) || playerid == i || gCurrentMinigame[i] != MINIGAME_DESDRBY)continue;
	    if(dby_Spectating[i] == playerid)
	    {
	        dby_Spectate(i);
	    }
	}

	if(IsValidVehicle(dby_PlayerVehicleID[playerid]))
	{
	    dby_Spectating[playerid] = DBY_SPEC_SELF;
	    TogglePlayerSpectating(playerid, true);
	    PlayerSpectateVehicle(playerid, dby_PlayerVehicleID[playerid]);
		dby_VehicleDeathTimer[playerid] = defer dby_OnPlayerVehicleDeath(playerid);
	}
	else
	{
		dby_Spectate(playerid);
	}

	if(dby_Lives[playerid] > 0)
	{
	    dby_Lives[playerid]--;
	}
	else
	{
		for(new i;i<MAX_PLAYERS;i++)
		{
		    if(dby_Lives[i] > 0 && IsPlayerConnected(i) && gCurrentMinigame[i] == MINIGAME_DESDRBY)
		    {
		        winner = i;
		        count++;
		    }
		    if(i == MAX_PLAYERS-1)
		    {
		        if(count == 1)dby_EndRound(winner);
		        if(count == 0)dby_EndRound();
		    }
		}
	}
	return 1;
}

timer dby_Spectate[3000](playerid)
{
	if(dby_Spectating[playerid] != DBY_SPEC_NONE && dby_Spectating[playerid] != DBY_SPEC_SELF)return 0;

	if(Iter_Count(dby_SpawnedIndex) > 0)
	{
		new randomPlayer = Iter_Random(dby_SpawnedIndex);
		while(randomPlayer == playerid)randomPlayer = Iter_Random(dby_SpawnedIndex);

		if(IsValidVehicle(dby_PlayerVehicleID[randomPlayer]))
		{
		    MsgF(playerid, YELLOW, " >  You are now spectating: %P", randomPlayer);

		    SetPlayerVirtualWorld(playerid, MINIGAME_WORLD);
			TogglePlayerSpectating(playerid, true);
			PlayerSpectateVehicle(playerid, dby_PlayerVehicleID[randomPlayer]);
			dby_Spectating[playerid] = randomPlayer;

			return 1;
		}
	}

    Msg(playerid, YELLOW, " >  You are now spectating: "#C_BLUE"Arena");
    if(!IsValidCameraSequencer(dby_Data[dby_CurrentArena][dby_Camera]))
    {
		TogglePlayerSpectating(playerid, false);
		TogglePlayerControllable(playerid, false);
		dby_SpectateTimer[playerid] = defer SetBackupSpectateCamera(playerid);
    }
	else PlayCameraSequenceForPlayer(playerid, dby_Data[dby_CurrentArena][dby_Camera], .loop = true);
    dby_Spectating[playerid] = DBY_SPEC_ARENA;

	return 0;
}
timer SetBackupSpectateCamera[500](playerid)
{
	new
		spawn1,
		spawn2;

	spawn1 = random(dby_Data[dby_CurrentArena][dby_MaxSpawns]);

	switch(random(2))
	{
		case 0:spawn2=spawn1+1;
		case 1:spawn2=spawn1-1;
	}

	if(spawn2 >= dby_Data[dby_CurrentArena][dby_MaxSpawns])spawn2=0;
	if(spawn2 <= -1)spawn2=dby_Data[dby_CurrentArena][dby_MaxSpawns]-1;

	SetPlayerPos(playerid,
		dby_Data[dby_CurrentArena][dby_SpawnX][spawn1],
		dby_Data[dby_CurrentArena][dby_SpawnY][spawn1],
		dby_Data[dby_CurrentArena][dby_SpawnZ][spawn1] - 4.0);

	SetPlayerCameraPos(playerid,
		dby_Data[dby_CurrentArena][dby_SpawnX][spawn1],
		dby_Data[dby_CurrentArena][dby_SpawnY][spawn1],
		dby_Data[dby_CurrentArena][dby_SpawnZ][spawn1] + DBY_SPAWN_ZOFFSET);

	SetPlayerCameraLookAt(playerid,
		dby_Data[dby_CurrentArena][dby_SpawnX][spawn2],
		dby_Data[dby_CurrentArena][dby_SpawnY][spawn2],
		dby_Data[dby_CurrentArena][dby_SpawnZ][spawn2] + DBY_SPAWN_ZOFFSET);
}

dby_UpdateTextDraw(playerid)
{
	new str[11];
	format(str, 11, "Lives: %d", dby_Lives[playerid]);
	PlayerTextDrawSetString(playerid, dby_TdText, str);

	PlayerTextDrawShow(playerid, dby_TdBack);
	PlayerTextDrawShow(playerid, dby_TdText);
}

dby_Leave(playerid, msg = true)
{
	gCurrentMinigame[playerid] = MINIGAME_NONE;
	t:bPlayerGameSettings[playerid]<Invis>;
	if(dby_Spectating[playerid] != DBY_SPEC_NONE)
	{
	    if(dby_Spectating[playerid] == DBY_SPEC_ARENA)
	    	ExitPlayerCameraSequencer(playerid);

	    TogglePlayerSpectating(playerid, false);
	    SpawnPlayer(playerid);
	}
	stop dby_SpawnTimer[playerid];
	stop dby_SpawnDelayTimer[playerid];
	stop dby_SpectateTimer[playerid];
	stop dby_VehicleDeathTimer[playerid];
	for(new i;i<MAX_PLAYERS;i++)
	{
	    if(!IsPlayerConnected(i))continue;
	    if(gCurrentMinigame[i] == MINIGAME_DESDRBY && dby_Spectating[i] == playerid && playerid != i)
	    {
	        dby_Spectate(i);
	    }
	}
	ResetSpectatorTarget(playerid);
	Iter_Remove(dby_SpawnedIndex, playerid);
	DestroyVehicle(dby_PlayerVehicleID[playerid]);

	SetPlayerVirtualWorld(playerid, FREEROAM_WORLD);
	PlayerTextDrawHide(playerid, dby_TdBack);
	PlayerTextDrawHide(playerid, dby_TdText);
	dby_HideLobbyControls(playerid);

    new count;
	PlayerLoop(i)
    {
		if(gCurrentMinigame[i] == MINIGAME_DESDRBY)count++;
    }
    if(count == 0)
	{
		f:bServerGlobalSettings<dby_InProgress>;
		for(new i;i<MAX_PLAYERS;i++)dby_Lives[i] = DBY_MAX_LIVES;
	}

	if(msg)
		MsgAllF(YELLOW, " >  %P"#C_YELLOW" has left the "#C_BLUE"Destruction Derby "#C_YELLOW"minigame.", playerid);

	return 0;
}

dby_EndRound(winner = INVALID_PLAYER_ID)
{
	if(winner == INVALID_PLAYER_ID)MsgAll(YELLOW, " >  "#C_ORANGE"Nobody "#C_YELLOW"won the "#C_BLUE"Destruction Derby "#C_YELLOW"minigame.");
	else
	{
	    Iter_Remove(dby_SpawnedIndex, winner);
		MsgAllF(YELLOW, " >  %P "#C_YELLOW"won the "#C_BLUE"Destruction Derby "#C_YELLOW"minigame.", winner);
		dby_SpectateTimer[winner] = defer dby_Spectate(winner);
	}
	foreach(new i : Player)
	{
	    if(gCurrentMinigame[i] == MINIGAME_DESDRBY)
	    {
	    	dby_ShowLobbyControls(i);
			PlayerTextDrawSetString(i, dby_TdSpawn, "10");
			PlayerTextDrawSetSelectable(i, dby_TdSpawn, false);
			dby_SpawnTimer[i] = defer dby_UpdateSpawnButton(i);
			dby_SpawnCount[i] = 9;
		}
	}
}
timer dby_NextRound[10000]()
{
	foreach(new i : Player)
	{
	    if(gCurrentMinigame[i] == MINIGAME_DESDRBY)
	    {
	    	dby_Lives[i] = DBY_MAX_LIVES;
	    	if(IsValidVehicle(dby_PlayerVehicleID[i]))DestroyVehicle(dby_PlayerVehicleID[i]);
	    }
	}
}

dby_FormatArenaList(playerid)
{
	new
		list[DBY_MAX_ARENA * (DBY_MAX_NAME+1)];

	for(new i;i<dby_TotalArenas;i++)
	{
	    strcat(list, dby_Data[i][dby_Name]);
	    strcat(list, "\n");
	}
	ShowPlayerDialog(playerid, d_DerbyArenaList, DIALOG_STYLE_LIST, "Destruction Derby", list, "Start", "Cancel");
}
dby_FormatVehicleList(playerid)
{
	new
		list[256];

	for(new i;i<sizeof(dby_Vehicles);i++)
	{
	    strcat(list, VehicleNames[dby_Vehicles[i]-400]);
	    strcat(list, "\n");
	}
	ShowPlayerDialog(playerid, d_DerbyVehicleList, DIALOG_STYLE_LIST, "Choose a vehicle", list, "Accept", "Cancel");
}
hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_DerbyArenaList && response)
	{
	    dby_CurrentArena = listitem;
		dby_Join(playerid);
	}
	if(dialogid == d_DerbyVehicleList && response)
	{
	    dby_PlayerVehicleModel[playerid] = dby_Vehicles[listitem];
	}
}

dby_LoadArenas()
{
	new
	    File:idxFile,
	    File:dataFile,
	    line[DBY_MAX_NAME],
	    data[128],
		str[42],
		spawnIdx,
		idx;

	if(!fexist(DBY_INDEX_FILE))return print("ERROR: Destruction Derby Arena Index Not Found");
	
	idxFile = fopen(DBY_INDEX_FILE, io_read);

	while(fread(idxFile, line))
	{
	    strtrim(line, "\r\n");

		dby_Data[idx][dby_Name][0] = EOS;
		strcat(dby_Data[idx][dby_Name], line);
		format(str, 42, DBY_DATA_FILE, line);

		if(!fexist(str))
		{
		    printf("ERROR: Arena data file '%s' not found", str);
		    continue;
		}

		dataFile = fopen(str, io_read);
		
		spawnIdx = 0;
		while(fread(dataFile, data))
		{
		    sscanf(data, "p<,>ffff",
		        dby_Data[idx][dby_SpawnX][spawnIdx],
		        dby_Data[idx][dby_SpawnY][spawnIdx],
		        dby_Data[idx][dby_SpawnZ][spawnIdx],
		        dby_Data[idx][dby_SpawnR][spawnIdx]);

            spawnIdx++;
		}
		format(str, 42, DBY_CAM_FILE, line);
		dby_Data[idx][dby_MaxSpawns] = spawnIdx;
		dby_Data[idx][dby_Camera] = LoadCameraSequencer(str);
		
		fclose(dataFile);
	    idx++;
	}
	dby_TotalArenas = idx;
	fclose(idxFile);
	return 1;
}
dby_UnloadArenas()
{
    for(new i; i < dby_TotalArenas; i++)
    {
        if(IsValidCameraSequencer(dby_Data[i][dby_Camera]))
            DestroyCameraSequencer(dby_Data[i][dby_Camera]);
    }
    dby_TotalArenas = 0;
}

CMD:reloadderby(playerid, params[])
{
    dby_UnloadArenas();
    dby_LoadArenas();
}

dby_LoadPlayerTextDraws(playerid)
{
	dby_TdBack						=CreatePlayerTextDraw(playerid, 19.000000, 309.000000, "____");
	PlayerTextDrawBackgroundColor	(playerid, dby_TdBack, 255);
	PlayerTextDrawFont				(playerid, dby_TdBack, 1);
	PlayerTextDrawLetterSize		(playerid, dby_TdBack, 0.319999, 1.899999);
	PlayerTextDrawColor				(playerid, dby_TdBack, -1);
	PlayerTextDrawSetOutline		(playerid, dby_TdBack, 0);
	PlayerTextDrawSetProportional	(playerid, dby_TdBack, 1);
	PlayerTextDrawSetShadow			(playerid, dby_TdBack, 1);
	PlayerTextDrawUseBox			(playerid, dby_TdBack, 1);
	PlayerTextDrawBoxColor			(playerid, dby_TdBack, 0xFFFFFFFF);
	PlayerTextDrawTextSize			(playerid, dby_TdBack, 81.000000, 0.000000);

	dby_TdText						=CreatePlayerTextDraw(playerid, 20.000000, 310.000000, "Lives: 0");
	PlayerTextDrawBackgroundColor	(playerid, dby_TdText, 255);
	PlayerTextDrawFont				(playerid, dby_TdText, 1);
	PlayerTextDrawLetterSize		(playerid, dby_TdText, 0.300000, 1.699998);
	PlayerTextDrawColor				(playerid, dby_TdText, -1);
	PlayerTextDrawSetOutline		(playerid, dby_TdText, 0);
	PlayerTextDrawSetProportional	(playerid, dby_TdText, 1);
	PlayerTextDrawSetShadow			(playerid, dby_TdText, 1);
	PlayerTextDrawUseBox			(playerid, dby_TdText, 1);
	PlayerTextDrawBoxColor			(playerid, dby_TdText, 0x000000A0);
	PlayerTextDrawTextSize			(playerid, dby_TdText, 80.000000, 0.000000);

	dby_TdVehicle					=CreatePlayerTextDraw(playerid, 320.000000, 320.000000, "Change Vehicle");
	PlayerTextDrawAlignment			(playerid, dby_TdVehicle, 2);
	PlayerTextDrawBackgroundColor	(playerid, dby_TdVehicle, 255);
	PlayerTextDrawFont				(playerid, dby_TdVehicle, 1);
	PlayerTextDrawLetterSize		(playerid, dby_TdVehicle, 0.400000, 2.000000);
	PlayerTextDrawColor				(playerid, dby_TdVehicle, -1);
	PlayerTextDrawSetOutline		(playerid, dby_TdVehicle, 0);
	PlayerTextDrawSetProportional	(playerid, dby_TdVehicle, 1);
	PlayerTextDrawSetShadow			(playerid, dby_TdVehicle, 1);
	PlayerTextDrawUseBox			(playerid, dby_TdVehicle, 1);
	PlayerTextDrawBoxColor			(playerid, dby_TdVehicle, 100);
	PlayerTextDrawTextSize			(playerid, dby_TdVehicle, 18.000000, 110.000000);
	PlayerTextDrawSetSelectable		(playerid, dby_TdVehicle, true);

	dby_TdSpawn						=CreatePlayerTextDraw(playerid, 320.000000, 344.000000, "5");
	PlayerTextDrawAlignment			(playerid, dby_TdSpawn, 2);
	PlayerTextDrawBackgroundColor	(playerid, dby_TdSpawn, 255);
	PlayerTextDrawFont				(playerid, dby_TdSpawn, 1);
	PlayerTextDrawLetterSize		(playerid, dby_TdSpawn, 0.400000, 2.000000);
	PlayerTextDrawColor				(playerid, dby_TdSpawn, -1);
	PlayerTextDrawSetOutline		(playerid, dby_TdSpawn, 0);
	PlayerTextDrawSetProportional	(playerid, dby_TdSpawn, 1);
	PlayerTextDrawSetShadow			(playerid, dby_TdSpawn, 1);
	PlayerTextDrawUseBox			(playerid, dby_TdSpawn, 1);
	PlayerTextDrawBoxColor			(playerid, dby_TdSpawn, 100);
	PlayerTextDrawTextSize			(playerid, dby_TdSpawn, 18.000000, 110.000000);
}
dby_UnloadPlayerTextDraws(playerid)
{
	PlayerTextDrawDestroy(playerid, dby_TdBack);
	PlayerTextDrawDestroy(playerid, dby_TdText);
	PlayerTextDrawDestroy(playerid, dby_TdVehicle);
	PlayerTextDrawDestroy(playerid, dby_TdSpawn);
}
