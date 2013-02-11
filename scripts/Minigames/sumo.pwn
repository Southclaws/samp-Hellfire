#include <YSI\y_hooks>

#define SMO_INDEX_FILE		"Sumo/index.ini"
#define SMO_DATA_FILE		"Sumo/%s.dat"
#define SMO_CAM_FILE		"smocam.%s"
#define SMO_MAX_ARENA		(8)
#define SMO_MAX_NAME		(32)
#define SMO_MAX_SPAWN		(8)
#define SMO_SPAWN_ZOFFSET	(5.0)

#define SMO_SPEC_NONE       (-1)
#define SMO_SPEC_ARENA		(-2)

enum E_SMO_ARENA_DATA
{
	smo_Name[SMO_MAX_NAME],
	smo_MaxSpawns,
	smo_Camera,
	Float:smo_Base,
	Float:smo_SpawnX[SMO_MAX_SPAWN],
	Float:smo_SpawnY[SMO_MAX_SPAWN],
	Float:smo_SpawnZ[SMO_MAX_SPAWN],
	Float:smo_SpawnR[SMO_MAX_SPAWN]
}

new
	smo_Data[SMO_MAX_ARENA][E_SMO_ARENA_DATA],
	smo_CurrentArena,
	smo_TotalArenas;

new
    PlayerText:smo_TdBack,
    PlayerText:smo_TdText,
    PlayerText:smo_TdVehicle,
    PlayerText:smo_TdSpawn,

	smo_TimesFallen				[MAX_PLAYERS],
	smo_SpawnCount				[MAX_PLAYERS],
	smo_PlayerVehicleID			[MAX_PLAYERS],
	smo_PlayerVehicleModel		[MAX_PLAYERS],
	smo_Spectating				[MAX_PLAYERS],
	Timer:smo_SpawnTimer		[MAX_PLAYERS],
	Timer:smo_SpawnDelayTimer	[MAX_PLAYERS],
	Iterator:smo_SpawnedIndex<MAX_PLAYERS>;

new
	smo_Vehicles[19]=
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
		530,
		572
	};

CMD:sumo(playerid, params[])
{
	if(gCurrentChallenge != CHALLENGE_NONE)
	{
	    Msg(playerid, YELLOW, " >  You can't start a minigame while a challenge is active.");
	    return 1;
	}
	if(gCurrentMinigame[playerid] == MINIGAME_CARSUMO)
	{
		smo_Leave(playerid);
	}
	else if(gCurrentMinigame[playerid] == MINIGAME_NONE)
	{
		if(bServerGlobalSettings & smo_InProgress)smo_Join(playerid);
		else smo_FormatArenaList(playerid);
	}
	else
	{
	    Msg(playerid, YELLOW, " >  Please exit your current minigame before joining another");
	}
	return 1;
}

CMD:jsumo(playerid, params[])
{
    smo_Join(strval(params));
	return 1;
}
CMD:mspawn(playerid, params[])
{
    smo_Spawn(strval(params));
	return 1;
}

smo_Join(playerid, msg = true)
{
	gCurrentMinigame[playerid] = MINIGAME_CARSUMO;
	t:bServerGlobalSettings<smo_InProgress>;
	smo_FormatVehicleList(playerid);
	SetPlayerVirtualWorld(playerid, MINIGAME_WORLD);

	if(Iter_Contains(smo_SpawnedIndex, playerid))Iter_Remove(smo_SpawnedIndex, playerid);

	PlayerTextDrawSetString(playerid, smo_TdSpawn, "5");
	PlayerTextDrawSetSelectable(playerid, smo_TdSpawn, false);
	smo_SpawnTimer[playerid] = defer smo_UpdateSpawnButton(playerid);
	smo_SpawnCount[playerid] = 4;
	smo_Spectate(playerid);

	if(msg)
	{
		PlayerLoop(i)if(IsPlayerInFreeRoam(i) || gCurrentMinigame[playerid] == MINIGAME_CARSUMO)
		    MsgF(i, YELLOW, " >  %P"#C_YELLOW" has joined the "#C_BLUE"Sumo "#C_YELLOW"minigame on "#C_BLUE"%s"#C_YELLOW"! Type "#C_ORANGE"/sumo "#C_YELLOW"to join.", playerid, smo_Data[smo_CurrentArena][smo_Name]);
	}
}

smo_Spawn(playerid)
{
	if(smo_Spectating[playerid] == SMO_SPEC_ARENA && IsValidCameraHandle(smo_Data[smo_CurrentArena][smo_Camera]))
		ExitCamera(playerid);

	TogglePlayerSpectating(playerid, false);
	TogglePlayerControllable(playerid, true);
	SetPlayerVirtualWorld(playerid, MINIGAME_WORLD);

	new spawn = random(smo_Data[smo_CurrentArena][smo_MaxSpawns]);
	smo_PlayerVehicleID[playerid] = CreateVehicle(smo_PlayerVehicleModel[playerid],
		smo_Data[smo_CurrentArena][smo_SpawnX][spawn],
		smo_Data[smo_CurrentArena][smo_SpawnY][spawn],
		smo_Data[smo_CurrentArena][smo_SpawnZ][spawn] + SMO_SPAWN_ZOFFSET,
		smo_Data[smo_CurrentArena][smo_SpawnR][spawn], -1, -1, -1);

	SetVehicleVirtualWorld(smo_PlayerVehicleID[playerid], MINIGAME_WORLD);
	SetVehicleParamsEx(smo_PlayerVehicleID[playerid], 1, 1, 0, 0, 0, 0, 0);

	smo_SpawnDelayTimer[playerid] = defer smo_SpawnDelay(playerid);
}

timer smo_SpawnDelay[500](playerid)
{
	PutPlayerInVehicle(playerid, smo_PlayerVehicleID[playerid], 0);

	PlayerTextDrawShow(playerid, smo_TdBack);
	PlayerTextDrawShow(playerid, smo_TdText);
	smo_HideLobbyControls(playerid);
	smo_UpdateTextDraw(playerid);

    Iter_Add(smo_SpawnedIndex, playerid);
	smo_Spectating[playerid] = SMO_SPEC_NONE;
}

script_sumo_Update(playerid)
{
	if(Iter_Contains(smo_SpawnedIndex, playerid))
	{
		new
		    iVehicle = GetPlayerVehicleID(playerid),
		    Float:z;

		GetVehiclePos(iVehicle, z, z, z);
		if(z < smo_Data[smo_CurrentArena][smo_Base])smo_Out(playerid);
		
		if(!IsValidVehicle(iVehicle))
		    PutPlayerInVehicle(playerid, smo_PlayerVehicleID[playerid], 0);
	}
	return 1;
}


smo_Out(playerid)
{
	Iter_Remove(smo_SpawnedIndex, playerid);
	ResetSpectatorTarget(playerid);
    smo_TimesFallen[playerid]++;
	PlayerTextDrawHide(playerid, smo_TdBack);
	PlayerTextDrawHide(playerid, smo_TdText);
	
	for(new i;i<MAX_PLAYERS;i++)
	{
	    if(!IsPlayerConnected(i) || playerid == i || gCurrentMinigame[i] != MINIGAME_CARSUMO)continue;
	    if(smo_Spectating[i] == playerid)
	    {
	        smo_Spectate(i);
	    }
	}

	smo_Spectate(playerid);
	DestroyVehicle(smo_PlayerVehicleID[playerid]);

	PlayerTextDrawSetString(playerid, smo_TdSpawn, "5");
	PlayerTextDrawSetSelectable(playerid, smo_TdSpawn, false);
	smo_SpawnTimer[playerid] = defer smo_UpdateSpawnButton(playerid);
	smo_SpawnCount[playerid] = 4;
	return 1;
}
smo_ShowLobbyControls(playerid)
{
	PlayerTextDrawShow(playerid, smo_TdVehicle);
	PlayerTextDrawShow(playerid, smo_TdSpawn);
	SelectTextDraw(playerid, YELLOW);
}
smo_HideLobbyControls(playerid)
{
	PlayerTextDrawHide(playerid, smo_TdVehicle);
	PlayerTextDrawHide(playerid, smo_TdSpawn);
	CancelSelectTextDraw(playerid);
}
timer smo_UpdateSpawnButton[1000](playerid)
{
	if(smo_SpawnCount[playerid] <= 0)
	{
		PlayerTextDrawSetString(playerid, smo_TdSpawn, "Spawn");
		PlayerTextDrawSetSelectable(playerid, smo_TdSpawn, true);
	}
	else
	{
		new
			tmpStr[2];

		valstr(tmpStr, smo_SpawnCount[playerid]);
		PlayerTextDrawSetString(playerid, smo_TdSpawn, tmpStr);

	    smo_SpawnCount[playerid]--;
	    smo_SpawnTimer[playerid] = defer smo_UpdateSpawnButton(playerid);
	}
	smo_ShowLobbyControls(playerid);
}
hook OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(playertextid == smo_TdVehicle)
	{
	    smo_FormatVehicleList(playerid);
	}
	if(playertextid == smo_TdSpawn)
	{
	    smo_Spawn(playerid);
	}
}

smo_Spectate(playerid)
{
	if(Iter_Count(smo_SpawnedIndex) > 1)
	{
		new randomPlayer = Iter_Random(smo_SpawnedIndex);
		while(randomPlayer == playerid)randomPlayer = Iter_Random(smo_SpawnedIndex);
		
		if(IsValidVehicle(smo_PlayerVehicleID[randomPlayer]))
		{
		    MsgF(playerid, YELLOW, " >  You are now spectating: %P", randomPlayer);
		    
		    SetPlayerVirtualWorld(playerid, MINIGAME_WORLD);
			TogglePlayerSpectating(playerid, true);
			PlayerSpectateVehicle(playerid, smo_PlayerVehicleID[randomPlayer]);
			smo_Spectating[playerid] = randomPlayer;

			return 1;
		}
	}

	Msg(playerid, YELLOW, " >  You are now spectating: "#C_BLUE"Arena");
	if(!IsValidCameraHandle(smo_Data[smo_CurrentArena][smo_Camera]))
	{
		new
			spawn1,
			spawn2;

		spawn1 = random(smo_Data[smo_CurrentArena][smo_MaxSpawns]);

		switch(random(2))
		{
			case 0:spawn2=spawn1+1;
			case 1:spawn2=spawn1-1;
		}

		if(spawn2 >= smo_Data[smo_CurrentArena][smo_MaxSpawns])spawn2=0;
		if(spawn2 <= -1)spawn2=smo_Data[smo_CurrentArena][smo_MaxSpawns]-1;

		TogglePlayerSpectating(playerid, false);
		TogglePlayerControllable(playerid, false);

		SetPlayerVirtualWorld(playerid, MINIGAME_WORLD);
        SetPlayerPos(playerid,
			smo_Data[smo_CurrentArena][smo_SpawnX][spawn1],
			smo_Data[smo_CurrentArena][smo_SpawnY][spawn1],
			smo_Data[smo_CurrentArena][smo_SpawnZ][spawn1] - 4.0);

        SetPlayerCameraPos(playerid,
			smo_Data[smo_CurrentArena][smo_SpawnX][spawn1],
			smo_Data[smo_CurrentArena][smo_SpawnY][spawn1],
			smo_Data[smo_CurrentArena][smo_SpawnZ][spawn1] + SMO_SPAWN_ZOFFSET);

        SetPlayerCameraLookAt(playerid,
			smo_Data[smo_CurrentArena][smo_SpawnX][spawn2],
			smo_Data[smo_CurrentArena][smo_SpawnY][spawn2],
			smo_Data[smo_CurrentArena][smo_SpawnZ][spawn2] + SMO_SPAWN_ZOFFSET);
	}
	else PlayCameraMover(playerid, smo_Data[smo_CurrentArena][smo_Camera], .loop = true);
	smo_Spectating[playerid] = SMO_SPEC_ARENA;
	
	return 0;
}

smo_UpdateTextDraw(playerid)
{
	new str[11];
	format(str, 11, "Falls: %d", smo_TimesFallen[playerid]);
	PlayerTextDrawSetString(playerid, smo_TdText, str);

	PlayerTextDrawShow(playerid, smo_TdBack);
	PlayerTextDrawShow(playerid, smo_TdText);
}

smo_Leave(playerid, msg = true)
{
    gCurrentMinigame[playerid] = MINIGAME_NONE;
	if(smo_Spectating[playerid] != SMO_SPEC_NONE)
	{
	    if(smo_Spectating[playerid] == SMO_SPEC_ARENA)ExitCamera(playerid);
	    TogglePlayerSpectating(playerid, false);
	    SpawnPlayer(playerid);
	    
	}
	stop smo_SpawnTimer[playerid];
	stop smo_SpawnDelayTimer[playerid];
	for(new i;i<MAX_PLAYERS;i++)
	{
	    if(!IsPlayerConnected(i))continue;
	    if(gCurrentMinigame[i] == MINIGAME_CARSUMO && smo_Spectating[i] == playerid && playerid != i)
	    {
	        smo_Spectate(i);
	    }
	}
	ResetSpectatorTarget(playerid);
	Iter_Remove(smo_SpawnedIndex, playerid);
	DestroyVehicle(smo_PlayerVehicleID[playerid]);


	SetPlayerVirtualWorld(playerid, FREEROAM_WORLD);
	PlayerTextDrawHide(playerid, smo_TdBack);
	PlayerTextDrawHide(playerid, smo_TdText);
	smo_HideLobbyControls(playerid);

    if(msg)
	{
		PlayerLoop(i)if(IsPlayerInFreeRoam(i) || gCurrentMinigame[i] == MINIGAME_CARSUMO)
			MsgF(i, YELLOW, " >  %P"#C_YELLOW" has left the "#C_BLUE"/sumo "#C_YELLOW"minigame.", playerid);
	}
    
    new count;

	PlayerLoop(i)
	{
		if(gCurrentMinigame[i] == MINIGAME_CARSUMO)count++;
	}
    if(count == 0)
	{
		f:bServerGlobalSettings<smo_InProgress>;
		for(new i;i<MAX_PLAYERS;i++)smo_TimesFallen[i] = 0;
	}

	return 0;
}

smo_FormatArenaList(playerid)
{
	new
		list[SMO_MAX_ARENA * (SMO_MAX_NAME+1)];

	for(new i;i<smo_TotalArenas;i++)
	{
	    strcat(list, smo_Data[i][smo_Name]);
	    strcat(list, "\n");
	}
	ShowPlayerDialog(playerid, d_SumoArenaList, DIALOG_STYLE_LIST, "Car Sumo", list, "Start", "Cancel");
}
smo_FormatVehicleList(playerid)
{
	new
		list[sizeof(smo_Vehicles) * (32+1)];

	for(new i;i<sizeof(smo_Vehicles);i++)
	{
	    strcat(list, VehicleNames[smo_Vehicles[i]-400]);
	    strcat(list, "\n");
	}
	ShowPlayerDialog(playerid, d_SumoVehicleList, DIALOG_STYLE_LIST, "Choose a vehicle", list, "Accept", "Cancel");
}
hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_SumoArenaList && response)
	{
	    smo_CurrentArena = listitem;
		smo_Join(playerid);
	}
	if(dialogid == d_SumoVehicleList && response)
	{
	    smo_PlayerVehicleModel[playerid] = smo_Vehicles[listitem];
	}
}

smo_LoadArenas()
{
	new
	    File:idxFile,
	    File:dataFile,
	    line[128],
	    data[128],
		str[42],
		spawnIdx,
		idx;

	if(!fexist(SMO_INDEX_FILE))return print("ERROR: Car-Sumo Arena Index Not Found");
	
	idxFile = fopen(SMO_INDEX_FILE, io_read);
	
	while(fread(idxFile, line))
	{
	    if(sscanf(line, "p<=>s[32]f", smo_Data[idx][smo_Name], smo_Data[idx][smo_Base]))
	    {
	    	print("ERROR: Sumo Arena Data Corrupted");
	    	continue;
	    }

		format(str, 42, SMO_DATA_FILE, smo_Data[idx][smo_Name]);

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
		        smo_Data[idx][smo_SpawnX][spawnIdx],
		        smo_Data[idx][smo_SpawnY][spawnIdx],
		        smo_Data[idx][smo_SpawnZ][spawnIdx],
		        smo_Data[idx][smo_SpawnR][spawnIdx]);

            spawnIdx++;
		}
		format(str, 42, SMO_CAM_FILE, smo_Data[idx][smo_Name]);
		smo_Data[idx][smo_MaxSpawns] = spawnIdx;
		smo_Data[idx][smo_Camera] = LoadCameraMover(str);

		fclose(dataFile);
	    idx++;
	}
	smo_TotalArenas = idx;
	return 1;
}
smo_UnloadArenas()
{
    for(new i; i < smo_TotalArenas; i++)
    {
        if(IsValidCameraHandle(smo_Data[i][smo_Camera]))
            ClearCameraID(smo_Data[i][smo_Camera]);
    }
    smo_TotalArenas = 0;
}

CMD:reloadsumo(playerid, params[])
{
	smo_UnloadArenas();
    smo_LoadArenas();
    return 1;
}

smo_LoadPlayerTextDraws(playerid)
{
	smo_TdBack						=CreatePlayerTextDraw(playerid, 19.000000, 309.000000, "____");
	PlayerTextDrawBackgroundColor	(playerid, smo_TdBack, 255);
	PlayerTextDrawFont				(playerid, smo_TdBack, 1);
	PlayerTextDrawLetterSize		(playerid, smo_TdBack, 0.319999, 1.899999);
	PlayerTextDrawColor				(playerid, smo_TdBack, -1);
	PlayerTextDrawSetOutline		(playerid, smo_TdBack, 0);
	PlayerTextDrawSetProportional	(playerid, smo_TdBack, 1);
	PlayerTextDrawSetShadow			(playerid, smo_TdBack, 1);
	PlayerTextDrawUseBox			(playerid, smo_TdBack, 1);
	PlayerTextDrawBoxColor			(playerid, smo_TdBack, 0xFFFFFFFF);
	PlayerTextDrawTextSize			(playerid, smo_TdBack, 81.000000, 0.000000);

	smo_TdText						=CreatePlayerTextDraw(playerid, 20.000000, 310.000000, "Falls: 0");
	PlayerTextDrawBackgroundColor	(playerid, smo_TdText, 255);
	PlayerTextDrawFont				(playerid, smo_TdText, 1);
	PlayerTextDrawLetterSize		(playerid, smo_TdText, 0.300000, 1.699998);
	PlayerTextDrawColor				(playerid, smo_TdText, -1);
	PlayerTextDrawSetOutline		(playerid, smo_TdText, 0);
	PlayerTextDrawSetProportional	(playerid, smo_TdText, 1);
	PlayerTextDrawSetShadow			(playerid, smo_TdText, 1);
	PlayerTextDrawUseBox			(playerid, smo_TdText, 1);
	PlayerTextDrawBoxColor			(playerid, smo_TdText, 0x000000A0);
	PlayerTextDrawTextSize			(playerid, smo_TdText, 80.000000, 0.000000);

	smo_TdVehicle					=CreatePlayerTextDraw(playerid, 320.000000, 320.000000, "Change Vehicle");
	PlayerTextDrawAlignment			(playerid, smo_TdVehicle, 2);
	PlayerTextDrawBackgroundColor	(playerid, smo_TdVehicle, 255);
	PlayerTextDrawFont				(playerid, smo_TdVehicle, 1);
	PlayerTextDrawLetterSize		(playerid, smo_TdVehicle, 0.400000, 2.000000);
	PlayerTextDrawColor				(playerid, smo_TdVehicle, -1);
	PlayerTextDrawSetOutline		(playerid, smo_TdVehicle, 0);
	PlayerTextDrawSetProportional	(playerid, smo_TdVehicle, 1);
	PlayerTextDrawSetShadow			(playerid, smo_TdVehicle, 1);
	PlayerTextDrawUseBox			(playerid, smo_TdVehicle, 1);
	PlayerTextDrawBoxColor			(playerid, smo_TdVehicle, 100);
	PlayerTextDrawTextSize			(playerid, smo_TdVehicle, 18.000000, 110.000000);
	PlayerTextDrawSetSelectable		(playerid, smo_TdVehicle, true);

	smo_TdSpawn						=CreatePlayerTextDraw(playerid, 320.000000, 344.000000, "5");
	PlayerTextDrawAlignment			(playerid, smo_TdSpawn, 2);
	PlayerTextDrawBackgroundColor	(playerid, smo_TdSpawn, 255);
	PlayerTextDrawFont				(playerid, smo_TdSpawn, 1);
	PlayerTextDrawLetterSize		(playerid, smo_TdSpawn, 0.400000, 2.000000);
	PlayerTextDrawColor				(playerid, smo_TdSpawn, -1);
	PlayerTextDrawSetOutline		(playerid, smo_TdSpawn, 0);
	PlayerTextDrawSetProportional	(playerid, smo_TdSpawn, 1);
	PlayerTextDrawSetShadow			(playerid, smo_TdSpawn, 1);
	PlayerTextDrawUseBox			(playerid, smo_TdSpawn, 1);
	PlayerTextDrawBoxColor			(playerid, smo_TdSpawn, 100);
	PlayerTextDrawTextSize			(playerid, smo_TdSpawn, 18.000000, 110.000000);
}
smo_UnloadPlayerTextDraws(playerid)
{
	PlayerTextDrawDestroy(playerid, smo_TdBack);
	PlayerTextDrawDestroy(playerid, smo_TdText);
	PlayerTextDrawDestroy(playerid, smo_TdVehicle);
	PlayerTextDrawDestroy(playerid, smo_TdSpawn);
}

