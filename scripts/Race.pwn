#include <YSI\y_hooks>

#define MAX_RACES			(48)
#define MAX_RACE_NAME		(32)
#define MAX_RACE_FILENAME	(MAX_RACE_NAME+12)
#define MAX_RACE_PLAYERS	(4)
#define MAX_RACE_COUNTDOWN	(20)

#define RC_INDEX_FILE		"Races/index.ini"
#define RC_DATA_FILE    	"Races/%s.ini"
#define RC_DATABASE			"Races/highscores.db"
#define RC_ROW_PLAYER		"player"
#define RC_ROW_TIME			"time"

enum E_RACE_DATA
{
			rc_Name				[MAX_RACE_NAME],
			rc_FinishLocationID,
			rc_MaxPlayers,
	Float:	rc_Distance,
	Float:	rc_Pos				[3],
			rc_BestPlayer		[MAX_PLAYER_NAME],
			rc_BestTime
}

enum E_RACE_PLAYER_DATA
{
			rc_PlayerID,
	Float:	rc_DistanceToFinish
}

new
			rc_Data				[MAX_RACES][E_RACE_DATA],
DB:			rc_Highscores,
			rc_TotalTracks,
			rc_JoinCP			[MAX_RACES],
Text3D:		rc_JoinLabel		[MAX_RACES],
			rc_JoinIcon			[MAX_RACES];

new
			rc_playerData		[MAX_PLAYERS][E_RACE_PLAYER_DATA],
			rc_playerPosition	[MAX_PLAYERS],
			rc_playerSortedData	[MAX_PLAYERS],
			rc_StartTick		[MAX_PLAYERS],
Float:		rc_StartSlot		[MAX_RACE_PLAYERS][4],
			rc_PlayerSlotIndex	[MAX_RACE_PLAYERS],
			rc_Vehicle			[MAX_PLAYERS];

new
Text:		rc_RaceCountText,
PlayerText:	rc_LobbyInfo,
PlayerText:	rc_LobbyCamera,
PlayerText:	rc_DistCount,
PlayerText:	rc_CurPlace,

			rc_CurrentRaceMarker,
			rc_CurrentRace		= -1,
			rc_RaceCount		= -1,

			rc_FinishLine,
			rc_FinishIcon,
			rc_FinishPlace,
			rc_FirstTime;
			

new const
Float:		rc_FinishLocPos		[10][3]=
			{
				{-2504.4670, 2420.8837, 16.2494},
				{-221.3159, 2634.8383, 62.5168},
				{2048.7209, 1545.6011, 10.5035},
				{-2853.8020, 465.3240, 4.1021},
				{225.9746, 970.9934, 27.9082},
				{2340.5681, 320.0366, 32.3746},
				{-1762.7983, -580.2061, 16.0580},
				{-2144.6472, -2411.3054, 30.1848},
				{51.6131, -1531.5061, 5.2908},
				{2866.3154, -1658.8486, 10.5915}
			},
			rc_FinishLocName[10][33]=
			{
				"Bayside",
				"Las Payasdas",
				"Las Venturas Strip",
				"San Fierro Westside",
				"Fort Carson Cluckin Bell",
				"Palomino Creek Freeway Junction",
				"Easter Bay Airport Entrance",
				"Angel Pine Crossroads",
				"Los Santos West Bridge",
				"Los Santos Stadium"
			},
			rc_Rewards[3] = {300, 100, 50};

hook OnPlayerUpdate(playerid)
{
	if(!(bPlayerGameSettings[playerid] & InRace))
		return 1;

	new
		str[32],
		Float:pos[3];

	GetVehiclePos(rc_Vehicle[playerid], pos[0], pos[1], pos[2]);
	rc_playerData[playerid][rc_DistanceToFinish] = Distance(pos[0], pos[1], pos[2], rc_FinishLocPos[rc_Data[rc_CurrentRace][rc_FinishLocationID]][0], rc_FinishLocPos[rc_Data[rc_CurrentRace][rc_FinishLocationID]][1], rc_FinishLocPos[rc_Data[rc_CurrentRace][rc_FinishLocationID]][2]);

	format(str, 32, "Distance~n~%.0fm", rc_playerData[playerid][rc_DistanceToFinish]);
	PlayerTextDrawSetString(playerid, rc_DistCount, str);
	PlayerTextDrawShow(playerid, rc_DistCount);

	if(bServerGlobalSettings & rc_Started)
	{
		PlayerTextDrawSetString(playerid, TimerText, MsToString(tickcount()-rc_StartTick[playerid], 1));
		PlayerTextDrawShow(playerid, TimerText);
		if((tickcount()-rc_StartTick[playerid]) > rc_Data[rc_CurrentRace][rc_BestTime] && rc_Data[rc_CurrentRace][rc_BestTime] > 1000)PlayerTextDrawColor(playerid, TimerText, 0xff0000ff);

		valstr(str, rc_playerPosition[playerid]+1);

		PlayerTextDrawSetString(playerid, rc_CurPlace, str);
		PlayerTextDrawShow(playerid, rc_CurPlace);
	}

	return 1;
}

task rc_Update[1000]()
{
	if(bServerGlobalSettings & rc_Started)
	{
		PlayerLoop(i)
		    if(!(bPlayerGameSettings[i] & InRace)) rc_playerData[i][rc_DistanceToFinish] = 99999.0;

		SortArrayUsingComparator(rc_playerData, CompareDistanceToFinish) => rc_playerSortedData;

		for(new i; i < sizeof(rc_playerSortedData); i++)
		{
		    new playerid = rc_playerSortedData[i];

			rc_playerPosition[playerid] = i;
		}
	}
	else
	{
		if(rc_RaceCount >= 0)
			rc_CountTick();
	}
}
Comparator:CompareDistanceToFinish(left[E_RACE_PLAYER_DATA], right[E_RACE_PLAYER_DATA])
{
    return floatcmp(left[rc_DistanceToFinish], right[rc_DistanceToFinish]);
}

script_race_EnterDynamicRaceCP(playerid, checkpointid)
{
	for(new i;i<rc_TotalTracks;i++)
	{
	    if(checkpointid == rc_JoinCP[i] && !(bPlayerGameSettings[playerid] & InRace))
	    {
	        new vehicleType = GetVehicleType(GetVehicleModel(GetPlayerVehicleID(playerid)));

			if(IsPlayerInAnyVehicle(playerid) && (vehicleType != VTYPE_HELI && vehicleType != VTYPE_PLANE && vehicleType != VTYPE_SEA && vehicleType != VTYPE_TRAILER && vehicleType != VTYPE_TRAIN))
			{
				if(!IsPlayerInFreeRoam(playerid))
					return Msg(playerid, YELLOW, " >  You can only join a race in freeroam mode.");

				if(rc_CurrentRace != -1)
				{
					if(rc_GetPlayersInRace() >= rc_Data[rc_CurrentRace][rc_MaxPlayers])
						return Msg(playerid, RED, " >  The race is full.");

					else if(bServerGlobalSettings & rc_Started)
						return Msg(playerid, RED, " >  The race has already started.");
				}
				else rc_CurrentRace=i;

				ShowPlayerDialog(playerid, d_RaceJoin, DIALOG_STYLE_MSGBOX, "Join Race", "Do you want to join this race?", "Join", "Cancel");
	        }
	        else Msg(playerid, YELLOW, " >  You must be in a car or bike to race.");

			break;
	    }
	}
	if(checkpointid==rc_FinishLine && bPlayerGameSettings[playerid] & InRace)
	{
	    if(GetPlayerVehicleID(playerid) != rc_Vehicle[playerid])
	    {
	        MsgAllF(ORANGE, " >  %P"#C_ORANGE" has been disqualified from the race for finishing in a different vehicle.", playerid);
			rc_Leave(playerid);
	        return 1;
	    }

		rc_Finish(playerid);

		return 1;
	}
	return 0;
}
rc_Finish(playerid)
{
	new
	    tmpMs,
		tmpTime[20],
	    tmpRaceName[MAX_RACE_NAME],
		tmpQuery[256],
		tmpField[24],
		DBResult:tmpResult,
		numrows,
		place,
		failedpb;

	tmpMs=tickcount()-rc_StartTick[playerid];
	tmpTime = MsToString(tmpMs, 1);

	strcpy(tmpRaceName, rc_Data[rc_CurrentRace][rc_Name]);
	strreplace(tmpRaceName, " ", "_");

    format(tmpQuery, 256,
		"SELECT * FROM `%s` WHERE `"#RC_ROW_PLAYER"` = '%p'",
		tmpRaceName, playerid);

	tmpResult = db_query(rc_Highscores, tmpQuery);
	numrows = db_num_rows(tmpResult);

	if(numrows == 1)
	{
		db_get_field(tmpResult, 1, tmpField, 11);

		if(tmpMs < strval(tmpField))
		{
			format(tmpQuery, 256,
				"UPDATE `%s` SET `"#RC_ROW_TIME"` = '%d' WHERE `"#RC_ROW_PLAYER"` = '%p'",
				tmpRaceName, tmpMs, playerid);

			db_free_result(db_query(rc_Highscores, tmpQuery));
		}
	}
	else
	{
		format(tmpQuery, 256,
			"INSERT INTO `%s` (`"#RC_ROW_PLAYER"`, `"#RC_ROW_TIME"`) VALUES('%p', '%d')",
			tmpRaceName, playerid, tmpMs);

		db_free_result(db_query(rc_Highscores, tmpQuery));
	}

	format(tmpQuery, 256,
		"SELECT * FROM `%s` ORDER BY (`"#RC_ROW_TIME"` * 1) ASC",
		tmpRaceName);

	tmpResult = db_query(rc_Highscores, tmpQuery);
	numrows = db_num_rows(tmpResult);

	if(numrows > 0)
	{
	    while(place < numrows)
		{
			db_get_field(tmpResult, 0, tmpField, 24);
			if(!strcmp(tmpField, gPlayerName[playerid]))
			{
			    new leaderboardtime;

				db_get_field(tmpResult, 1, tmpField, 24);
				leaderboardtime = strval(tmpField);

				if(tmpMs > leaderboardtime)failedpb = true;

				break;
			}

		    db_next_row(tmpResult);
		    place++;
		}

		if(place == 0)
		{
			new str[128];

			rc_Data[rc_CurrentRace][rc_BestPlayer] = gPlayerName[playerid];
			rc_Data[rc_CurrentRace][rc_BestTime] = tmpMs;

			format(str, 128, "%s\n%s - %s\n\n"#C_GREEN"Finish: %s\n"#C_BLUE"Max Players: %d",
				rc_Data[rc_CurrentRace][rc_Name], rc_Data[rc_CurrentRace][rc_BestPlayer], MsToString(rc_Data[rc_CurrentRace][rc_BestTime], 1),
				rc_FinishLocName[rc_Data[rc_CurrentRace][rc_FinishLocationID]], rc_Data[rc_CurrentRace][rc_MaxPlayers]);

			UpdateDynamic3DTextLabelText(rc_JoinLabel[rc_CurrentRace], YELLOW, str);
		}
		if(place < 3)
		{
			if(numrows > 4-(place+1))
			{
				GivePlayerMoney(playerid, rc_Rewards[place]);
				GivePlayerScore(playerid, 4-(place+1));
				MsgF(playerid, YELLOW, " >  You won "#C_BLUE"$%d and %d score"#C_YELLOW"for getting in "#C_ORANGE"%d%s "#C_YELLOW"in the leaderboard!",
					rc_Rewards[place], 4-(place+1), place+1, returnOrdinal(place+1));
			}
		}
	}

	if(rc_FinishPlace == 0)
	{
		rc_FirstTime = tmpMs;
		if(failedpb)
		{
			MsgAllF(YELLOW, " >  %P"#C_YELLOW" finished race "#C_BLUE"%d%s"#C_YELLOW", time: "#C_ORANGE"%s"#C_YELLOW"",
				playerid, rc_FinishPlace+1, returnOrdinal(rc_FinishPlace+1), tmpTime);
		}
		else
		{
			MsgAllF(YELLOW, " >  %P"#C_YELLOW" finished race "#C_BLUE"%d%s"#C_YELLOW", time: "#C_ORANGE"%s"#C_YELLOW", "#C_YELLOW"leaderboard: "#C_GOLD"%d%s",
				playerid, rc_FinishPlace+1, returnOrdinal(rc_FinishPlace+1), tmpTime, place+1, returnOrdinal(place+1));
		}
	}
	else
	{
		if(failedpb)
		{
			MsgAllF(YELLOW, " >  %P"#C_YELLOW" finished race "#C_BLUE"%d%s"#C_YELLOW", time: "#C_ORANGE"%s "#C_RED"(-%s)",
				playerid, rc_FinishPlace+1, returnOrdinal(rc_FinishPlace+1), tmpTime, MsToString(tmpMs - rc_FirstTime, 1));
		}
		else
		{
			MsgAllF(YELLOW, " >  %P"#C_YELLOW" finished race "#C_BLUE"%d%s"#C_YELLOW", time: "#C_ORANGE"%s "#C_RED"(-%s), "#C_YELLOW"leaderboard: "#C_GOLD"%d%s",
				playerid, rc_FinishPlace+1, returnOrdinal(rc_FinishPlace+1), tmpTime, MsToString(tmpMs - rc_FirstTime, 1), place+1, returnOrdinal(place+1));
		}
	}

	rc_FinishPlace++;
	rc_Leave(playerid);
}
rc_FormatInfo(playerid, race)
{
	new str[256];

	if(strlen(rc_Data[race][rc_BestPlayer]) > 0 && rc_Data[race][rc_BestTime] > 0)
	{
		format(str, 256, "\
			"#C_YELLOW"Race Name:\t\t"#C_GREEN"%s\n\n\
			"#C_YELLOW"Best Player:\t\t"#C_GREEN"%s\n\
			"#C_YELLOW"Best Time:\t\t"#C_GREEN"%s\n\n\
			"#C_YELLOW"Finish:\t\t\t"#C_BLUE"%s\n\
			"#C_YELLOW"Max Players:\t\t"#C_BLUE"%d\n\
			"#C_YELLOW"Distance:\t\t"#C_BLUE"%.2fKm",

			rc_Data[race][rc_Name], rc_Data[race][rc_BestPlayer], MsToString(rc_Data[race][rc_BestTime]),
			rc_FinishLocName[rc_Data[race][rc_FinishLocationID]], rc_Data[race][rc_MaxPlayers], (rc_Data[race][rc_Distance]/1000));
	}
	else
	{
		format(str, 256, "\
			"#C_YELLOW"Race Name:\t\t"#C_GREEN"%s\n\n\
			"#C_YELLOW"Best Player:\t\t"#C_GREY"None\n\
			"#C_YELLOW"Best Time:\t\t"#C_GREY"None\n\n\
			"#C_YELLOW"Finish:\t\t\t"#C_BLUE"%s\n\
			"#C_YELLOW"Max Players:\t\t"#C_BLUE"%d\n\
			"#C_YELLOW"Distance:\t\t"#C_BLUE"%.2fKm",

			rc_Data[race][rc_Name], rc_FinishLocName[rc_Data[race][rc_FinishLocationID]],
			rc_Data[race][rc_MaxPlayers], (rc_Data[race][rc_Distance]/1000));
	}

	ShowPlayerDialog(playerid, d_RaceInfo, DIALOG_STYLE_MSGBOX, "Race Info", str, "Close", "Top 10");
}
rc_FormatHighScoreList(playerid, track)
{
	new
	    tmpRaceName[MAX_RACE_NAME],
		tmpQuery[128],
		DBResult:tmpResult,
		numrows,
		tmpStr[64],
		title[MAX_RACE_NAME + 16],
		list[64 * 10];


	strcpy(tmpRaceName, rc_Data[rc_CurrentRace][rc_Name]);
	strreplace(tmpRaceName, " ", "_");

	format(tmpQuery, 128,
		"SELECT * FROM `%s` ORDER BY (`"#RC_ROW_TIME"` * 1) ASC LIMIT 10",
		tmpRaceName);

	tmpResult = db_query(rc_Highscores, tmpQuery);
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

	strcpy(title, rc_Data[track][rc_Name]);
	strcat(title, " - Highscores");

	ShowPlayerDialog(playerid, d_RaceScores, DIALOG_STYLE_MSGBOX, title, list, "Close", "");

	return 1;
}
hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_RaceJoin)
	{
		if(!response)
		{
			rc_CurrentRace=-1;
			return 1;
		}
		if(rc_GetPlayersInRace()>0)
		{
			if(rc_GetPlayersInRace() == rc_Data[rc_CurrentRace][rc_MaxPlayers]) Msg(playerid, ORANGE, " >  Race Is Full");
			else
			{
				rc_RaceCount=MAX_RACE_COUNTDOWN;
				TextDrawShowForAll(rc_RaceCountText);
				rc_Join(playerid);
			}
		}
		else
		{
			if(rc_Load())
			{
				rc_RaceCount=-1;
				TextDrawSetString(rc_RaceCountText, "Race Waiting...");
				TextDrawShowForAll(rc_RaceCountText);
				rc_Join(playerid);
			}
			else Msg(playerid, YELLOW, " >  Error while loading race data. Please report which race failed to load using /bug or tell an admin.");
		}
	}
	if(dialogid == d_RaceInfo && !response)rc_FormatHighScoreList(playerid, rc_CurrentRace);
	if(dialogid == d_RaceScores)rc_FormatInfo(playerid, rc_CurrentRace);
	return 0;
}

CMD:exitrace(playerid, params[])
{
	if(bPlayerGameSettings[playerid]&InRace)
	{
		rc_Leave(playerid);
		SetCameraBehindPlayer(playerid);
		CancelSelectTextDraw(playerid);
		MsgAllF(YELLOW, " >  %P"#C_YELLOW" Has left the current race.", playerid);
	}
	return 1;
}
CMD:timetrial(playerid, params[])
{
    rc_RaceCount=MAX_RACE_COUNTDOWN;
    return 1;
}
CMD:startrace(playerid, params[])
{
	if(rc_CurrentRace!=-1)
	{
		CancelSelectTextDraw(playerid);
		PlayerTextDrawHide(playerid, rc_LobbyInfo);
		PlayerTextDrawHide(playerid, rc_LobbyCamera);
		HideMapForPlayer(playerid);
		PlayerPlaySound(playerid, 1056, rc_Data[rc_CurrentRace][rc_Pos][0], rc_Data[rc_CurrentRace][rc_Pos][1], rc_Data[rc_CurrentRace][rc_Pos][2]);
		GameTextForPlayer(playerid, "GO!", 1100, 5);

		rc_Start();
	}
	else Msg(playerid, RED, " >  There are no races in progress.");
	return 1;
}
CMD:reloadraces(playerid, params[])
{
	for(new i;i<rc_TotalTracks;i++)
	{
		DestroyDynamicRaceCP(rc_JoinCP[i]);
		DestroyDynamic3DTextLabel(rc_JoinLabel[i]);
	}
	LoadRaces();
	MsgF(playerid, -1, " >  %d Races loaded!", rc_TotalTracks);
	return 1;
}
CMD:races(playerid, params[])
{
	if(bPlayerGameSettings[playerid] & ViewingRaceIcons)
	{
	    Msg(playerid, YELLOW, " >  Race icons turned "#C_BLUE"off.");
		for(new i;i<rc_TotalTracks;i++)Streamer_RemoveArrayData(STREAMER_TYPE_MAP_ICON, rc_JoinIcon[i], E_STREAMER_PLAYER_ID, playerid);
		Streamer_Update(playerid);
		f:bPlayerGameSettings[playerid]<ViewingRaceIcons>;
	}
	else
	{
	    Msg(playerid, YELLOW, " >  Races are now marked on your "#C_BLUE"minimap.");
		for(new i;i<rc_TotalTracks;i++)Streamer_AppendArrayData(STREAMER_TYPE_MAP_ICON, rc_JoinIcon[i], E_STREAMER_PLAYER_ID, playerid);
		Streamer_Update(playerid);
		t:bPlayerGameSettings[playerid]<ViewingRaceIcons>;
	}
	return 1;
}

rc_Load()
{
	new
		slotstr[MAX_KEY_LENGTH],
		slotdata[128],
		tmpRaceFile[MAX_RACE_FILENAME];

	format(tmpRaceFile, MAX_RACE_FILENAME, RC_DATA_FILE, rc_Data[rc_CurrentRace][rc_Name]);

	if(!fexist(tmpRaceFile))
	{
		printf("File Not Found: %s", tmpRaceFile);
		return 0;
	}

	file_Open(tmpRaceFile);
	{
		for(new i;i<rc_Data[rc_CurrentRace][rc_MaxPlayers];i++)
		{
		    format(slotstr, 6, "Slot%d", i);
		    file_GetStr(slotstr, slotdata);
			sscanf(slotdata, "p<,>ffff", rc_StartSlot[i][0], rc_StartSlot[i][1], rc_StartSlot[i][2], rc_StartSlot[i][3]);
			rc_PlayerSlotIndex[i] = -1;
		}
	}
	file_Close();
	return 1;
}
rc_Join(playerid)
{
	new slot;
	while(slot < MAX_RACE_PLAYERS && rc_PlayerSlotIndex[slot] != -1)slot++;

    rc_PlayerSlotIndex[slot] = playerid;
	rc_Vehicle[playerid] = GetPlayerVehicleID(playerid);

	SetVehicleVirtualWorld(GetPlayerVehicleID(playerid), RACE_WORLD);
	SetPlayerVirtualWorld(playerid, RACE_WORLD);
	SetVehiclePos(GetPlayerVehicleID(playerid), rc_StartSlot[slot][0], rc_StartSlot[slot][1], rc_StartSlot[slot][2]);
	SetVehicleZAngle(GetPlayerVehicleID(playerid), rc_StartSlot[slot][3]);

	TogglePlayerControllable(playerid, false);
	SetCameraBehindPlayer(playerid);
	bitTrue(bPlayerGameSettings[playerid], InRace);
	PlayerTextDrawShow(playerid, rc_LobbyInfo);
	PlayerTextDrawShow(playerid, rc_LobbyCamera);
	SelectTextDraw(playerid, WHITE);

	Msg(playerid, YELLOW, " >  Type "#C_BLUE"'/exitrace'"#C_YELLOW" to leave, or type "#C_BLUE"'/timetrial'"#C_YELLOW" to try set the best time on your own");
	MsgAllF(YELLOW, " >  %P"#C_YELLOW" has joined a "#C_ORANGE"%d "#C_YELLOW"player race: "#C_BLUE"%s "#C_YELLOW"with a "#C_ORANGE"%s",
		playerid, rc_Data[rc_CurrentRace][rc_MaxPlayers], rc_Data[rc_CurrentRace][rc_Name], VehicleNames[GetVehicleModel(GetPlayerVehicleID(playerid))-400]);

	if(!IsValidDynamicMapIcon(rc_CurrentRaceMarker))
		rc_CurrentRaceMarker = CreateDynamicMapIconEx(rc_Data[rc_CurrentRace][rc_Pos][0], rc_Data[rc_CurrentRace][rc_Pos][1], rc_Data[rc_CurrentRace][rc_Pos][2], 33, 0, MAPICON_GLOBAL, FLOAT_INFINITY, {FREEROAM_WORLD}, {0});
}
rc_CountTick()
{
	new str[120];
	format(str, 120, "Race Starting In %d", rc_RaceCount);
	TextDrawSetString(rc_RaceCountText, str);
	TextDrawShowForAll(rc_RaceCountText);
	if(1 <= rc_RaceCount <= 5)
	{
	    valstr(str, rc_RaceCount);
		PlayerLoop(i)
		{
		    if(bPlayerGameSettings[i] & InRace)
		    {
			    CancelSelectTextDraw(i);
				PlayerTextDrawHide(i, rc_LobbyInfo);
				PlayerTextDrawHide(i, rc_LobbyCamera);
				HideMapForPlayer(i);
		    	PlayerPlaySound(i, 1056, rc_Data[rc_CurrentRace][rc_Pos][0], rc_Data[rc_CurrentRace][rc_Pos][1], rc_Data[rc_CurrentRace][rc_Pos][2]);
				GameTextForPlayer(i, str, 1100, 5);
			}
		}
		rc_RaceCount--;
	}
	else if(rc_RaceCount == 0)
	{
		rc_Start();
	}
	else rc_RaceCount--;
}
hook OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(playertextid == rc_LobbyInfo)
		rc_FormatInfo(playerid, rc_CurrentRace);

	if(playertextid == rc_LobbyCamera)
	{
	    if(bPlayerGameSettings[playerid] & ViewingMap)
			HideMapForPlayer(playerid);

	    else
			ShowMapForPlayer(playerid, "~<~ Finish", rc_FinishLocPos[rc_Data[rc_CurrentRace][rc_FinishLocationID]][0], rc_FinishLocPos[rc_Data[rc_CurrentRace][rc_FinishLocationID]][1]);
	}
}

rc_Start()
{
    new
		tmpPlayerIndex[MAX_PLAYERS],
		idx;

	rc_RaceCount = -1;
	t:bServerGlobalSettings<rc_Started>;
	TextDrawHideForAll(rc_RaceCountText);
	if(IsValidDynamicMapIcon(rc_CurrentRaceMarker))DestroyDynamicMapIcon(rc_CurrentRaceMarker);

	PlayerLoop(i)if(bPlayerGameSettings[i] & InRace)
	{
		rc_StartTick[i]=tickcount();
        PlayerTextDrawColor(i, TimerText, 0xFFFFFFFF);
		PlayerTextDrawShow(i, rc_DistCount);

	    TogglePlayerControllable(i, true);
		PlayerPlaySound(i, 1057, rc_Data[rc_CurrentRace][rc_Pos][0], rc_Data[rc_CurrentRace][rc_Pos][1], rc_Data[rc_CurrentRace][rc_Pos][2]);
	    GameTextForPlayer(i, "~r~GO!!", 3000, 5);
	    
		RepairVehicle(rc_Vehicle[i]);
		AddVehicleComponent(rc_Vehicle[i], 1008);
		
		tmpPlayerIndex[idx++] = i;
	}
	tmpPlayerIndex[idx] = -1;

	rc_FinishLine=CreateDynamicRaceCPEx(1,
		rc_FinishLocPos[rc_Data[rc_CurrentRace][rc_FinishLocationID]][0],
		rc_FinishLocPos[rc_Data[rc_CurrentRace][rc_FinishLocationID]][1],
		rc_FinishLocPos[rc_Data[rc_CurrentRace][rc_FinishLocationID]][2],
		0, 0, 0, 8.0, FLOAT_INFINITY, {RACE_WORLD}, {0}, tmpPlayerIndex);

	rc_FinishIcon=CreateDynamicMapIconEx(
		rc_FinishLocPos[rc_Data[rc_CurrentRace][rc_FinishLocationID]][0],
		rc_FinishLocPos[rc_Data[rc_CurrentRace][rc_FinishLocationID]][1],
		rc_FinishLocPos[rc_Data[rc_CurrentRace][rc_FinishLocationID]][2],
		53, -1, MAPICON_GLOBAL, FLOAT_INFINITY, {RACE_WORLD}, {0}, tmpPlayerIndex);
}
rc_End()
{
	if(IsValidDynamicRaceCP(rc_FinishLine))DestroyDynamicRaceCP(rc_FinishLine);
	if(IsValidDynamicMapIcon(rc_FinishIcon))DestroyDynamicMapIcon(rc_FinishIcon);

	rc_CurrentRace	= -1;
	rc_FinishPlace	= 0;
	rc_RaceCount    = -1;
	f:bServerGlobalSettings<rc_Started>;
	TextDrawHideForAll(rc_RaceCountText);
	for(new i;i<MAX_RACE_PLAYERS;i++)rc_PlayerSlotIndex[i] = -1;
}
rc_Leave(playerid)
{
	if(IsValidDynamicRaceCP(rc_FinishLine))
		if(Streamer_IsInArrayData(STREAMER_TYPE_RACE_CP, rc_FinishLine, E_STREAMER_PLAYER_ID, playerid))
		    Streamer_RemoveArrayData(STREAMER_TYPE_RACE_CP, rc_FinishLine, E_STREAMER_PLAYER_ID, playerid);

	if(IsValidDynamicMapIcon(rc_FinishIcon))
		if(Streamer_IsInArrayData(STREAMER_TYPE_MAP_ICON , rc_FinishIcon, E_STREAMER_PLAYER_ID, playerid))
		    Streamer_RemoveArrayData(STREAMER_TYPE_MAP_ICON , rc_FinishIcon, E_STREAMER_PLAYER_ID, playerid);

	rc_playerData[playerid][rc_DistanceToFinish] = 99999.9;

	SetPlayerVirtualWorld(playerid, FREEROAM_WORLD);
	SetVehicleVirtualWorld(GetPlayerVehicleID(playerid), FREEROAM_WORLD);
	bitFalse(bPlayerGameSettings[playerid], InRace);
	TogglePlayerControllable(playerid, true);
    ResetSpectatorTarget(playerid);

	TextDrawHideForPlayer(playerid, rc_RaceCountText);
	PlayerTextDrawHide(playerid, rc_LobbyInfo);
	PlayerTextDrawHide(playerid, rc_LobbyCamera);
	PlayerTextDrawHide(playerid, rc_DistCount);
	PlayerTextDrawHide(playerid, TimerText);
	PlayerTextDrawHide(playerid, rc_CurPlace);

	if(rc_GetPlayersInRace() == 0)
	{
		rc_End();
		if(IsValidDynamicMapIcon(rc_CurrentRaceMarker))DestroyDynamicMapIcon(rc_CurrentRaceMarker);
	}
	for(new i;i<MAX_RACE_PLAYERS;i++)
	{
		if(rc_PlayerSlotIndex[i] == playerid)
		{
			rc_PlayerSlotIndex[i] = -1;
			break;
		}
	}
}

rc_GetPlayersInRace()
{
	new r;
	PlayerLoop(i)if(bPlayerGameSettings[i]&InRace)r++;
	return r;
}
script_Race_OnVehicleDeath(vehicleid)
{
	PlayerLoop(i)
	{
		if(vehicleid == rc_Vehicle[i])
		{
			rc_Leave(i);
			return 1;
		}
	}
	return 1;
}
script_race_OnPlayerDeath(playerid)
{
	rc_Leave(playerid);
}


ToggleRaceStarts(playerid, toggle)
{
	if(toggle)
	{
		for(new i;i<rc_TotalTracks;i++)
		{
			Streamer_AppendArrayData(STREAMER_TYPE_RACE_CP, rc_JoinCP[i], E_STREAMER_PLAYER_ID, playerid);
			Streamer_AppendArrayData(STREAMER_TYPE_3D_TEXT_LABEL, rc_JoinLabel[i], E_STREAMER_PLAYER_ID, playerid);
		}
	}
	else
	{
		for(new i;i<rc_TotalTracks;i++)
		{
			Streamer_RemoveArrayData(STREAMER_TYPE_RACE_CP, rc_JoinCP[i], E_STREAMER_PLAYER_ID, playerid);
			Streamer_RemoveArrayData(STREAMER_TYPE_3D_TEXT_LABEL, rc_JoinLabel[i], E_STREAMER_PLAYER_ID, playerid);
		}
	}
}


LoadRaces()
{
	print("- Loading Races...");
	new
		File:idxFile=fopen(RC_INDEX_FILE, io_read),
		line[128],
		filename[11 + MAX_RACE_NAME],
		idx = 0,
		tag[148],
		tmpRaceName[MAX_RACE_NAME],
		tmpQuery[128],
		DBResult:tmpResult;

	rc_Highscores = db_open(RC_DATABASE);

	while(fread(idxFile, line))
	{
		if(sscanf(line, "p<,>s[32]fff", rc_Data[idx][rc_Name], rc_Data[idx][rc_Pos][0], rc_Data[idx][rc_Pos][1], rc_Data[idx][rc_Pos][2]))
		{
			print("Error: Race file index corrupted");
			continue;
		}


		format(filename, sizeof(filename), RC_DATA_FILE, rc_Data[idx][rc_Name]);

		file_Open(filename);
		rc_Data[idx][rc_FinishLocationID]	= file_GetVal("FinishPos");
		rc_Data[idx][rc_MaxPlayers]			= file_GetVal("MaxPlayers");
		file_Close();

		rc_Data[idx][rc_Distance] = Distance2D(
			rc_Data[idx][rc_Pos][0], rc_Data[idx][rc_Pos][1],
			rc_FinishLocPos[rc_Data[idx][rc_FinishLocationID]][0], rc_FinishLocPos[rc_Data[idx][rc_FinishLocationID]][1]);


		strcpy(tmpRaceName, rc_Data[idx][rc_Name]);
        strreplace(tmpRaceName, " ", "_");

		format(tmpQuery, 128,
			"CREATE TABLE IF NOT EXISTS `%s` (`"#RC_ROW_PLAYER"`, `"#RC_ROW_TIME"`)",
			tmpRaceName);

		db_free_result(db_query(rc_Highscores, tmpQuery));

		format(tmpQuery, 128,
			"SELECT * FROM `%s` ORDER BY (`"#RC_ROW_TIME"` * 1) ASC LIMIT 1",
			tmpRaceName);

		tmpResult = db_query(rc_Highscores, tmpQuery);
		if(db_num_rows(tmpResult) > 0)
		{
		    new tmpField[24];

		    db_get_field(tmpResult, 0, tmpField, 24);
		    rc_Data[idx][rc_BestPlayer] = tmpField;

		    db_get_field(tmpResult, 1, tmpField, 24);
		    rc_Data[idx][rc_BestTime] = strval(tmpField);
		}
		db_free_result(tmpResult);
		
		
		if(!isempty(rc_Data[idx][rc_BestPlayer]) && rc_Data[idx][rc_BestTime] > 1000)
		{
			format(tag, 148, "%s\n%s - %s\n\n"#C_GREEN"Finish: %s\n"#C_BLUE"Max Players: %d\n"#C_ORANGE"Distance: %.1fkm",
				rc_Data[idx][rc_Name], rc_Data[idx][rc_BestPlayer], MsToString(rc_Data[idx][rc_BestTime]),
				rc_FinishLocName[rc_Data[idx][rc_FinishLocationID]], rc_Data[idx][rc_MaxPlayers], (rc_Data[idx][rc_Distance]/1000));
		}
		else
		{
			format(tag, 148, "%s\n\n"#C_GREEN"Finish: %s\n"#C_BLUE"Max Players: %d\n"#C_ORANGE"Distance: %.2f",
				rc_Data[idx][rc_Name], rc_FinishLocName[rc_Data[idx][rc_FinishLocationID]],
				rc_Data[idx][rc_MaxPlayers], (rc_Data[idx][rc_Distance]/1000));
		}


		rc_JoinLabel[idx] 	=CreateDynamic3DTextLabel(tag, YELLOW,
			rc_Data[idx][rc_Pos][0], rc_Data[idx][rc_Pos][1], rc_Data[idx][rc_Pos][2],
			100.0, .worldid = FREEROAM_WORLD);

		rc_JoinCP[idx]		=CreateDynamicRaceCP(2,
			rc_Data[idx][rc_Pos][0], rc_Data[idx][rc_Pos][1], rc_Data[idx][rc_Pos][2],
			0, 0, 0, 5.0, FREEROAM_WORLD);

	    rc_JoinIcon[idx] = CreateDynamicMapIconEx(
			rc_Data[idx][rc_Pos][0], rc_Data[idx][rc_Pos][1], rc_Data[idx][rc_Pos][2],
			0, BLUE, MAPICON_GLOBAL, 10000.0, {FREEROAM_WORLD}, {0}, {INVALID_PLAYER_ID});


		idx++;
	}
	rc_TotalTracks = idx;
	fclose(idxFile);
}


#endinput


	rc_StartBackGround1		=TextDrawCreate(297.000000, 139.000000, "~n~~n~~n~");
	TextDrawBackgroundColor	(rc_StartBackGround1, 255);
	TextDrawFont			(rc_StartBackGround1, 1);
	TextDrawLetterSize		(rc_StartBackGround1, 1.000000, 6.900000);
	TextDrawColor			(rc_StartBackGround1, -1);
	TextDrawSetOutline		(rc_StartBackGround1, 0);
	TextDrawSetProportional	(rc_StartBackGround1, 1);
	TextDrawSetShadow		(rc_StartBackGround1, 1);
	TextDrawUseBox			(rc_StartBackGround1, 1);
	TextDrawBoxColor		(rc_StartBackGround1, 1684300928);
	TextDrawTextSize		(rc_StartBackGround1, 339.000000, 0.000000);

	rc_StartBackGround2		=TextDrawCreate(298.000000, 140.000000, "~n~~n~~n~");
	TextDrawBackgroundColor	(rc_StartBackGround2, 255);
	TextDrawFont			(rc_StartBackGround2, 1);
	TextDrawLetterSize		(rc_StartBackGround2, 1.000000, 6.800000);
	TextDrawColor			(rc_StartBackGround2, -1);
	TextDrawSetOutline		(rc_StartBackGround2, 0);
	TextDrawSetProportional	(rc_StartBackGround2, 1);
	TextDrawSetShadow		(rc_StartBackGround2, 1);
	TextDrawUseBox			(rc_StartBackGround2, 1);
	TextDrawBoxColor		(rc_StartBackGround2, 255);
	TextDrawTextSize		(rc_StartBackGround2, 338.000000, 0.000000);

	rc_StartLight1			=TextDrawCreate(297.000000, 140.000000, "LD_DUAL:light");
	TextDrawBackgroundColor	(rc_StartLight1, 255);
	TextDrawFont			(rc_StartLight1, 4);
	TextDrawLetterSize		(rc_StartLight1, 1.000000, 5.000000);
	TextDrawColor			(rc_StartLight1, -1);
	TextDrawSetOutline		(rc_StartLight1, 0);
	TextDrawSetProportional	(rc_StartLight1, 1);
	TextDrawSetShadow		(rc_StartLight1, 1);
	TextDrawUseBox			(rc_StartLight1, 1);
	TextDrawBoxColor		(rc_StartLight1, 255);
	TextDrawTextSize		(rc_StartLight1, 42.000000, 50.000000);

	rc_StartLight2			=TextDrawCreate(297.000000, 200.000000, "LD_DUAL:light");
	TextDrawBackgroundColor	(rc_StartLight2, 255);
	TextDrawFont			(rc_StartLight2, 4);
	TextDrawLetterSize		(rc_StartLight2, 1.000000, 5.000000);
	TextDrawColor			(rc_StartLight2, -16776961);
	TextDrawSetOutline		(rc_StartLight2, 0);
	TextDrawSetProportional	(rc_StartLight2, 1);
	TextDrawSetShadow		(rc_StartLight2, 1);
	TextDrawUseBox			(rc_StartLight2, 1);
	TextDrawBoxColor		(rc_StartLight2, 255);
	TextDrawTextSize		(rc_StartLight2, 42.000000, 50.000000);

	rc_StartLight3			=TextDrawCreate(297.000000, 260.000000, "LD_DUAL:light");
	TextDrawBackgroundColor	(rc_StartLight3, 255);
	TextDrawFont			(rc_StartLight3, 4);
	TextDrawLetterSize		(rc_StartLight3, 1.000000, 5.000000);
	TextDrawColor			(rc_StartLight3, 16711935);
	TextDrawSetOutline		(rc_StartLight3, 0);
	TextDrawSetProportional	(rc_StartLight3, 1);
	TextDrawSetShadow		(rc_StartLight3, 1);
	TextDrawUseBox			(rc_StartLight3, 1);
	TextDrawBoxColor		(rc_StartLight3, 255);
	TextDrawTextSize		(rc_StartLight3, 42.000000, 50.000000);


