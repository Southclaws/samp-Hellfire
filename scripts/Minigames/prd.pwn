#include <YSI\y_hooks>

#define PRD_MAX_NAME				(32)
#define PRD_MAX_TRACK				(8)

#define PRD_INDEX_FILE				"Precision Driving/index.ini"
#define PRD_DATA_FILE				"Precision Driving/%s.dat"
#define PRD_DATABASE				"Precision Driving/highscores.db"
#define PRD_ROW_PLAYER				"player"
#define PRD_ROW_TIME				"time"


#define PRD_STATE_NONE				(0)
#define PRD_STATE_COUNTING			(1)
#define PRD_STATE_STARTED			(2)

#define PRD_SPECTATE_MODE_NONE		(0)
#define PRD_SPECTATE_MODE_TRACK		(1)
#define PRD_SPECTATE_MODE_PLAYER	(2)



enum E_PRD_TRACK_DATA
{
		prd_Name		[PRD_MAX_NAME],
		prd_BestPlayer	[MAX_PLAYER_NAME],
		prd_BestTime,
		prd_Vehicle,
Float:	prd_SpawnPos	[4],
Float:	prd_EndPos		[3]
}

static
		prd_Data[PRD_MAX_TRACK][E_PRD_TRACK_DATA],
DB:		prd_Highscores,
		prd_TotalTracks,
		prd_CurrentTrack,
		prd_State,
		prd_StartTick,
		prd_FinishLine,
		prd_CurrentPlayer = -1,
		prd_VehicleID,
		prd_CountValue,
Timer:	prd_CountTimer,
		prd_DamageCount,
		prd_Queue[MAX_PLAYERS],
		prd_Spectating[MAX_PLAYERS];


CMD:prd(playerid, params[])
{
	if(gCurrentChallenge != CHALLENGE_NONE)
	{
		Msg(playerid, YELLOW, " >  You can't start a minigame while a challenge is active.");
		return 1;
	}
	if(gCurrentMinigame[playerid] == MINIGAME_PRDRIVE)
	{
		prd_Leave(playerid);
	}
	else if(gCurrentMinigame[playerid] == MINIGAME_NONE)
	{
		if(prd_CurrentPlayer == -1)prd_FormatTrackList(playerid);
		else prd_Join(playerid);
	}
	else
	{
		Msg(playerid, YELLOW, " >  Please exit your current minigame before joining another");
	}
	return 1;
}

prd_Join(playerid, msg = true)
{
	gCurrentMinigame[playerid] = MINIGAME_PRDRIVE;
	if(prd_CurrentPlayer == -1)
	{
		prd_CurrentPlayer = playerid;
		TogglePlayerSpectating(prd_CurrentPlayer, false);
		SetPlayerVirtualWorld(prd_CurrentPlayer, MINIGAME_WORLD);
		prd_Spawn();
	}
	else
	{
		prd_Queue[prd_NextQueueSlot()] = playerid;
		prd_Spectate(playerid);
	}
	if(msg)
	{
		PlayerLoop(i)if(IsPlayerInFreeRoam(i) || gCurrentMinigame[playerid] == MINIGAME_PRDRIVE)
			MsgF(i, YELLOW, " >  %P"#C_YELLOW" Has gone to "#C_BLUE"Precision Driving: %s"#C_YELLOW" minigame. Type "#C_ORANGE"/prd "#C_YELLOW"to join.", playerid, prd_Data[prd_CurrentTrack][prd_Name]);
	}
}
prd_Leave(playerid, msg = true)
{
	gCurrentMinigame[playerid] = MINIGAME_NONE;

	if(prd_State == PRD_STATE_COUNTING && prd_Spectating[playerid] == PRD_SPECTATE_MODE_NONE)
		stop prd_CountTimer;

	prd_RemoveFromQueue(playerid);

	if(GetPlayersInPrd()==0 && IsValidVehicle(prd_VehicleID))
	{
		prd_CurrentPlayer = -1;
		DestroyVehicle(prd_VehicleID);
		prd_State = PRD_STATE_NONE;
	}
	TogglePlayerSpectating(playerid, false);
	SpawnPlayer(playerid);

	if(msg)
	{
		PlayerLoop(i)if(IsPlayerInFreeRoam(i) || gCurrentMinigame[i] == MINIGAME_PRDRIVE)
			MsgF(i, YELLOW, " >  %P"#C_YELLOW" has left the "#C_BLUE"Precision Driving"#C_YELLOW" minigame.", playerid);
	}
}
prd_NextQueueSlot()
{
	new i;
	while(i < MAX_PLAYERS && prd_Queue[i] != -1)i++;
	return i;
}
prd_RemoveFromQueue(playerid)
{
	new
		i,
		slot = MAX_PLAYERS;

	while(i < MAX_PLAYERS)
	{
		if(prd_Queue[i] == playerid)
			slot = i;

		if(i > slot)
			prd_Queue[i-1] = prd_Queue[i];

		i++;
	}
	return i;
}
prd_Spectate(playerid)
{
	SetPlayerVirtualWorld(playerid, MINIGAME_WORLD);
	if(prd_State == PRD_STATE_NONE)
	{
		prd_Spectating[playerid] = PRD_SPECTATE_MODE_TRACK;

		TogglePlayerSpectating(playerid, false);
		TogglePlayerControllable(playerid, false);
		SetPlayerVirtualWorld(playerid, MINIGAME_WORLD);

		SetPlayerPos(playerid,
			prd_Data[prd_CurrentTrack][prd_SpawnPos][0],
			prd_Data[prd_CurrentTrack][prd_SpawnPos][1],
			prd_Data[prd_CurrentTrack][prd_SpawnPos][2]+5.0+(playerid*2.0));

		SetPlayerCameraPos(playerid,
			prd_Data[prd_CurrentTrack][prd_SpawnPos][0],
			prd_Data[prd_CurrentTrack][prd_SpawnPos][1],
			prd_Data[prd_CurrentTrack][prd_SpawnPos][2]+3.0);

		SetPlayerCameraLookAt(playerid,
			prd_Data[prd_CurrentTrack][prd_EndPos][0],
			prd_Data[prd_CurrentTrack][prd_EndPos][1],
			prd_Data[prd_CurrentTrack][prd_EndPos][2]);
	}
	else
	{
		prd_Spectating[playerid] = PRD_SPECTATE_MODE_PLAYER;
		RemovePlayerFromVehicle(playerid);
		TogglePlayerControllable(playerid, true);
		TogglePlayerSpectating(playerid, true);
		PlayerSpectateVehicle(playerid, prd_VehicleID);
	}
}
timer prd_Spawn[1000]()
{
	prd_RemoveFromQueue(prd_CurrentPlayer);

	TogglePlayerSpectating(prd_CurrentPlayer, false);
	SetPlayerVirtualWorld(prd_CurrentPlayer, MINIGAME_WORLD);
	TogglePlayerControllable(prd_CurrentPlayer, false);

	prd_VehicleID = CreateVehicle(
		prd_Data[prd_CurrentTrack][prd_Vehicle],
		prd_Data[prd_CurrentTrack][prd_SpawnPos][0],
		prd_Data[prd_CurrentTrack][prd_SpawnPos][1],
		prd_Data[prd_CurrentTrack][prd_SpawnPos][2],
		prd_Data[prd_CurrentTrack][prd_SpawnPos][3],
		-1, -1, -1);

	SetVehicleVirtualWorld(prd_VehicleID, MINIGAME_WORLD);
	SetVehicleParamsEx(prd_VehicleID, 1, 1, 0, 0, 0, 0, 0);
	SetPlayerVirtualWorld(prd_CurrentPlayer, MINIGAME_WORLD);
	PutPlayerInVehicle(prd_CurrentPlayer, prd_VehicleID, 0);
	
	prd_CountValue = 5;
	prd_State = PRD_STATE_COUNTING;
	prd_Spectating[prd_CurrentPlayer] = PRD_SPECTATE_MODE_NONE;
	prd_CountTimer = defer prd_Countdown();

	for(new i;i<MAX_PLAYERS;i++)
	{
		if(gCurrentMinigame[i] == MINIGAME_PRDRIVE)
		{
			Streamer_Update(i);
			if(i != prd_CurrentPlayer)prd_Spectate(i);
		}
	}
}

timer prd_Countdown[1000]()
{
	new
		str[4];

	SetPlayerVirtualWorld(prd_CurrentPlayer, MINIGAME_WORLD);
	PutPlayerInVehicle(prd_CurrentPlayer, prd_VehicleID, 0);

	if(prd_CountValue > 0)
	{
		valstr(str, prd_CountValue);
		GameTextForPlayer(prd_CurrentPlayer, str, 1000, 5);
		prd_CountValue--;
		prd_CountTimer = defer prd_Countdown();
	}
	else
	{
		GameTextForPlayer(prd_CurrentPlayer, "~r~Go!", 1000, 5);
		prd_Start();
	}
}

prd_Start()
{
	SetPlayerVirtualWorld(prd_CurrentPlayer, MINIGAME_WORLD);
	prd_State = PRD_STATE_STARTED;
	prd_StartTick = tickcount();
	prd_DamageCount = 0;

	prd_FinishLine = CreateDynamicRaceCP(2,
		prd_Data[prd_CurrentTrack][prd_EndPos][0],
		prd_Data[prd_CurrentTrack][prd_EndPos][1],
		prd_Data[prd_CurrentTrack][prd_EndPos][2],
		prd_Data[prd_CurrentTrack][prd_EndPos][0],
		prd_Data[prd_CurrentTrack][prd_EndPos][1],
		prd_Data[prd_CurrentTrack][prd_EndPos][2],
		4.0, MINIGAME_WORLD, 0, prd_CurrentPlayer);

	TogglePlayerControllable(prd_CurrentPlayer, true);
}
script_prd_VehicleDamageUpdate(vehicleid)
{
	if(vehicleid == prd_VehicleID)
	{
		prd_DamageCount++;
		prd_StartTick-=1000;
		GameTextForPlayer(prd_CurrentPlayer, "~r~+00:01.000", 1000, 5);
	}
}
script_prd_EnterDynamicRaceCP(playerid, checkpointid)
{
	if(checkpointid == prd_FinishLine)
	{
		if(prd_State == PRD_STATE_STARTED)
		{
			prd_Finish(playerid);
		}
	}
}
prd_Finish(playerid)
{
	new
		tmpTime[20],
		tmpMs = GetTickCount() - prd_StartTick,
		tmpname[PRD_MAX_NAME],
		tmpQuery[128],
		DBResult:tmpResult,
		numrows,
		place;

	tmpTime = MsToString(tmpMs, 1);

	strcpy(tmpname, prd_Data[prd_CurrentTrack][prd_Name]);
	strreplace(tmpname, " ", "_");

	format(tmpQuery, 128,
		"SELECT * FROM `%s` WHERE `"#PRD_ROW_PLAYER"` = '%p'",
		tmpname, playerid);

	tmpResult = db_query(prd_Highscores, tmpQuery);

	if(db_num_rows(tmpResult) == 0)
	{
		format(tmpQuery, 128,
			"INSERT INTO `%s` (`"#PRD_ROW_PLAYER"`, `"#PRD_ROW_TIME"`) VALUES('%p', '%d')",
			tmpname, playerid, tmpMs);

		db_free_result(db_query(prd_Highscores, tmpQuery));
	}
	else
	{
		format(tmpQuery, 128,
			"UPDATE `%s` SET `"#PRD_ROW_TIME"` = '%d' WHERE `"#PRD_ROW_PLAYER"` = '%p'",
			tmpname, tmpMs, playerid);

		db_free_result(db_query(prd_Highscores, tmpQuery));
	}

	format(tmpQuery, 128,
		"SELECT * FROM `%s` ORDER BY (`"#PRD_ROW_TIME"` * 1) ASC",
		tmpname);

	tmpResult = db_query(prd_Highscores, tmpQuery);
	numrows = db_num_rows(tmpResult);

	if(numrows > 0)
	{
		new tmpField[24];
		while(place < numrows)
		{
			db_get_field(tmpResult, 0, tmpField, 24);

			if(!strcmp(tmpField, gPlayerName[playerid], true))break;

			db_next_row(tmpResult);
			place++;
		}

		if(place == 0)
		{
			prd_Data[prd_CurrentTrack][prd_BestPlayer] = gPlayerName[playerid];
			prd_Data[prd_CurrentTrack][prd_BestTime] = tmpMs;
		}
	}

	if(prd_DamageCount == 0)
	{
		PlayerLoop(i)if(IsPlayerInFreeRoam(i) || gCurrentMinigame[i] == MINIGAME_PRDRIVE)
		{
			MsgF(i, YELLOW, " >  %P"#C_YELLOW" finished the "#C_BLUE"Precision Driving "#C_YELLOW"track in "#C_ORANGE"%s!",
				playerid, tmpTime);
		}
	}
	else
	{
		PlayerLoop(i)if(IsPlayerInFreeRoam(i) || gCurrentMinigame[i] == MINIGAME_PRDRIVE)
		{
			MsgF(i, YELLOW, " >  %P"#C_YELLOW" finished the "#C_BLUE"Precision Driving "#C_YELLOW"track in "#C_ORANGE"%s! "#C_RED"Damage: %d",
				playerid, tmpTime, prd_DamageCount);
		}
	}

	prd_State = PRD_STATE_NONE;
	prd_DamageCount = 0;
	DestroyVehicle(prd_VehicleID);
	DestroyDynamicRaceCP(prd_FinishLine);

	if(GetPlayersInPrd() > 1 || IsPlayerConnected(prd_Queue[0]))
	{
		prd_Spectate(playerid);
		prd_CurrentPlayer = prd_Queue[0];
		prd_Queue[prd_NextQueueSlot()] = playerid;
	}
	else prd_Join(playerid, false);

	defer prd_Spawn();
}

GetPlayersInPrd()
{
	new count;

	PlayerLoop(i)
		if(gCurrentMinigame[i] == MINIGAME_PRDRIVE)count++;

	return count;
}


prd_FormatTrackList(playerid)
{
	new list[PRD_MAX_TRACK * (PRD_MAX_NAME+1)];
	for(new i;i<prd_TotalTracks;i++)
	{
		strcat(list, prd_Data[i][prd_Name]);
		strcat(list, "\n");
	}
	strcat(list, "Cancel");
	ShowPlayerDialog(playerid, d_PrdList, DIALOG_STYLE_LIST, "Precision Driving", list, "Start", "Top 10");
}

prd_FormatHighScoreList(playerid, track)
{
	new
		tmpQuery[128],
		DBResult:tmpResult,
		tmpname[PRD_MAX_NAME],
		numrows,
		tmpStr[64],
		title[PRD_MAX_NAME + 16],
		list[64 * 10];

	strcpy(tmpname, prd_Data[track][prd_Name]);
	strreplace(tmpname, " ", "_");

	format(tmpQuery, 128,
		"SELECT * FROM `%s` ORDER BY (`"#PRD_ROW_TIME"` * 1) ASC LIMIT 10",
		tmpname);

	tmpResult = db_query(prd_Highscores, tmpQuery);
	numrows = db_num_rows(tmpResult);

	if(numrows == 0)return 0;

	new
		i,
		name[24],
		time[11];

	while(i < numrows)
	{
		db_get_field(tmpResult, 0, name, 24);
		db_get_field(tmpResult, 1, time, 24);

		format(tmpStr, 64, ""#C_BLUE"%s - "#C_YELLOW"%s\n", MsToString(strval(time), 1), name);

		strcat(list, tmpStr);

		db_next_row(tmpResult);
		i++;
	}

	strcpy(title, prd_Data[track][prd_Name]);
	strcat(title, " - Highscores");

	ShowPlayerDialog(playerid, d_PrdScores, DIALOG_STYLE_MSGBOX, title, list, "Close", "");

	return 1;
}
hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_PrdList)
	{
		if(listitem >= prd_TotalTracks)return 0;
		if(response)
		{
			prd_CurrentTrack = listitem;
			prd_Join(playerid);
		}
		else prd_FormatHighScoreList(playerid, listitem);
	}
	if(dialogid == d_PrdScores)prd_FormatTrackList(playerid);
	return 1;
}


prd_LoadTracks()
{
	new
		File:idxFile,
		File:dataFile,
		line[128],
		data[128],
		filename[56],
		tmpname[PRD_MAX_NAME],
		idx,
		tmpQuery[128],
		DBResult:tmpResult;

	prd_Highscores = db_open(PRD_DATABASE);
	if(!fexist(PRD_INDEX_FILE))return print("ERROR: Precision Driving Track Index Not Found");

	idxFile = fopen(PRD_INDEX_FILE, io_read);

	while(fread(idxFile, line))
	{
		strtrim(line, "\r\n");

		prd_Data[idx][prd_Name][0] = EOS;
		strcat(prd_Data[idx][prd_Name], line, PRD_MAX_NAME);
		format(filename, 56, PRD_DATA_FILE, line);

		if(!fexist(filename))
		{
			printf("ERROR: Track data file '%s' not found", filename);
			continue;
		}

		dataFile = fopen(filename, io_read);

		// Vehicle Type ID
		fread(dataFile, data);
		sscanf(data, "d", prd_Data[idx][prd_Vehicle]);
		// Start pos
		fread(dataFile, data);
		sscanf(data, "p<,>a<f>[4]", prd_Data[idx][prd_SpawnPos]);
		// End pos
		fread(dataFile, data);
		sscanf(data, "p<,>a<f>[3]", prd_Data[idx][prd_EndPos]);
		
		fclose(dataFile);


		strcpy(tmpname, prd_Data[idx][prd_Name]);
		strreplace(tmpname, " ", "_");

		format(tmpQuery, 128,
			"CREATE TABLE IF NOT EXISTS `%s` (`"#PRD_ROW_PLAYER"`, `"#PRD_ROW_TIME"`)",
			tmpname);

		db_query(prd_Highscores, tmpQuery);

		format(tmpQuery, 128,
			"SELECT * FROM `%s` ORDER BY (`"#PRD_ROW_TIME"` * 1) ASC LIMIT 1",
			tmpname);

		tmpResult = db_query(prd_Highscores, tmpQuery);
		if(db_num_rows(tmpResult) > 0)
		{
			new tmpField[24];

			db_get_field(tmpResult, 0, tmpField, 24);
			prd_Data[idx][prd_BestPlayer] = tmpField;

			db_get_field(tmpResult, 1, tmpField, 24);
			prd_Data[idx][prd_BestTime] = strval(tmpField);
		}
		db_free_result(tmpResult);


		idx++;
	}
	prd_TotalTracks = idx;
	fclose(idxFile);

	for(new i;i<MAX_PLAYERS;i++)
	{
		prd_Queue[i]		= -1;
		prd_Spectating[i]	= -1;
	}

	return 1;
}

