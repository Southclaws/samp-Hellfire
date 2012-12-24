#include <YSI\y_hooks>

#define PRK_MAX_COURSE		(8)
#define PRK_MAX_CP			(20)
#define PRK_MAX_NAME		(32)

#define PRK_INDEX_FILE		"Parkour/index.ini"
#define PRK_DATA_FILE		"Parkour/%s.dat"
#define PRK_DATABASE		"Parkour/highscores.db"
#define PRK_ROW_PLAYER		"player"
#define PRK_ROW_TIME		"time"


enum ENUM_PARKOUR_DATA
{
		prk_Name			[PRK_MAX_NAME],
		prk_BestPlayer		[MAX_PLAYER_NAME],
		prk_BestTime,
		prk_MaxCP,
		prk_IntroCam
}
new
		prk_Data			[PRK_MAX_COURSE][ENUM_PARKOUR_DATA],
Float:	prk_CheckPointPos	[PRK_MAX_COURSE][PRK_MAX_CP][4],
DB:		prk_Highscores,
		prk_TotalCourses;

new
		prk_CurrentCourse	[MAX_PLAYERS],
		prk_CurrentCheck	[MAX_PLAYERS],
		prk_CurrentCP		[MAX_PLAYERS],
		prk_StartTick		[MAX_PLAYERS],
		prk_CountDown		[MAX_PLAYERS],
Timer:	prk_CountTimer		[MAX_PLAYERS],
		prk_Rewards			[3] = {300, 100, 50};


CMD:parkour(playerid, params[])
{
	if(gCurrentChallenge != CHALLENGE_NONE)
	{
		Msg(playerid, YELLOW, " >  You can't start a minigame while a challenge is active.");
		return 1;
	}
	if(gCurrentMinigame[playerid] == MINIGAME_PARKOUR)
	{
		prk_Leave(playerid);
	}
	else if(gCurrentMinigame[playerid] == MINIGAME_NONE)
	{
		prk_FormatCourseList(playerid);
	}
	else
	{
		Msg(playerid, YELLOW, " >  Please exit your current minigame before joining another");
	}
	return 1;
}

prk_Join(playerid, course, msg = true)
{
	gCurrentMinigame[playerid] = MINIGAME_PARKOUR;
    prk_CurrentCourse[playerid] = course;

	SetPlayerPos(playerid, prk_CheckPointPos[course][0][0], prk_CheckPointPos[course][0][1], prk_CheckPointPos[course][0][2]);
	SetPlayerVirtualWorld(playerid, MINIGAME_WORLD);

    if(bPlayerGameSettings[playerid] & prk_SkipIntro || !IsValidCameraHandle(prk_Data[course][prk_IntroCam]))
		prk_StartCount(playerid);

	else
		PlayCameraMover(playerid, prk_Data[course][prk_IntroCam]);


	if(msg)
	{
		PlayerLoop(i)if(IsPlayerInFreeRoam(i) || gCurrentMinigame[playerid] == MINIGAME_PARKOUR)
			MsgF(i, YELLOW, " >  %P"#C_YELLOW" Has gone to parkour map: "#C_BLUE"%s", playerid, prk_Data[prk_CurrentCourse[playerid]][prk_Name]);
	}
	Msg(playerid, LGREEN, " >  Type "#C_BLUE"/skip"#C_LGREEN" to skip the intro, type "#C_BLUE"/skipalways"#C_LGREEN" to never show the intro again.");
}


prk_SkipIntroCam(playerid)
{
	ExitCamera(playerid);
	prk_StartCount(playerid);
	Msg(playerid, ORANGE, "Intro Skipped!");
}


public OnCameraReachNode(playerid, camera, node)
{
	if(IsValidCameraHandle(prk_Data[prk_CurrentCourse[playerid]][prk_IntroCam]))
	{
		if(camera == prk_Data[prk_CurrentCourse[playerid]][prk_IntroCam] && node == GetCameraMaxNodes(camera) )
			prk_StartCount(playerid);
	}

	return CallLocalFunction("prk_OnCameraReachNode", "ddd", playerid, camera, node);
}
#if defined _ALS_OnCameraReachNode
    #undef OnCameraReachNode
#else
    #define _ALS_OnCameraReachNode
#endif
#define OnCameraReachNode prk_OnCameraReachNode
forward prk_OnCameraReachNode(playerid, camera, node);


prk_StartCount(playerid)
{
	new
		Float:tmpAngle = GetAngleToPoint(
			prk_CheckPointPos[prk_CurrentCourse[playerid]][0][0], prk_CheckPointPos[prk_CurrentCourse[playerid]][0][1],
			prk_CheckPointPos[prk_CurrentCourse[playerid]][1][0], prk_CheckPointPos[prk_CurrentCourse[playerid]][1][1]);

	SetPlayerPos(playerid,
		prk_CheckPointPos[prk_CurrentCourse[playerid]][0][0],
		prk_CheckPointPos[prk_CurrentCourse[playerid]][0][1],
		prk_CheckPointPos[prk_CurrentCourse[playerid]][0][2]);

	SetPlayerFacingAngle(playerid, tmpAngle);
	SetPlayerVirtualWorld(playerid, MINIGAME_WORLD);

	TogglePlayerControllable(playerid, false);
	SetCameraBehindPlayer(playerid);

	prk_CountDown[playerid] = 5;
	prk_CountTick(playerid);
}
timer prk_CountTick[1000](playerid)
{
	new str[2];
	format(str, 2, "%d", prk_CountDown[playerid]);
	GameTextForPlayer(playerid, str, 3000, 5);
	if(prk_CountDown[playerid]>0)
	{
		prk_CountDown[playerid]--;
		prk_CountTimer[playerid] = defer prk_CountTick(playerid);
	}
	else
	{
		GameTextForPlayer(playerid, "Go!", 3000, 5);
		prk_Start(playerid);
	}
}
prk_Start(playerid)
{
	new
		Float:tmpAngle = GetAngleToPoint(
			prk_CheckPointPos[prk_CurrentCourse[playerid]][0][0], prk_CheckPointPos[prk_CurrentCourse[playerid]][0][1],
			prk_CheckPointPos[prk_CurrentCourse[playerid]][1][0], prk_CheckPointPos[prk_CurrentCourse[playerid]][1][1]),
		tmpTime[20],
		ms = prk_Data[prk_CurrentCourse[playerid]][prk_BestTime];

	SetPlayerPos(playerid,
		prk_CheckPointPos[prk_CurrentCourse[playerid]][0][0],
		prk_CheckPointPos[prk_CurrentCourse[playerid]][0][1],
		prk_CheckPointPos[prk_CurrentCourse[playerid]][0][2]);

	SetPlayerFacingAngle(playerid, -tmpAngle);
	SetPlayerVirtualWorld(playerid, MINIGAME_WORLD);

	tmpTime = MsToString(ms, 1);

	TogglePlayerControllable(playerid, true);
	prk_StartTick[playerid] = tickcount();
	prk_CurrentCheck[playerid] = 1;
	SetPlayerHP(playerid, 100.0);

    prk_UpdateCheckPoint(playerid);
	prk_UpdateGUI(playerid);

	t:bPlayerGameSettings[playerid]<prk_Started>;

	if(ms == 0)
		Msg(playerid, YELLOW, " >  The Timer Is Running! There is no best time for this map.");

	else
		MsgF(playerid, YELLOW, " >  The Timer Is Running! The best time is: "#C_WHITE"%s"#C_YELLOW" by "#C_GREEN"%s"#C_YELLOW"", tmpTime, prk_Data[prk_CurrentCourse[playerid]][prk_BestPlayer]);

	Msg(playerid, YELLOW,  " >  Type "#C_BLUE"/home "#C_YELLOW"to exit parkour.");
}

hook OnPlayerSpawn(playerid)
{
	if(gCurrentMinigame[playerid] == MINIGAME_PARKOUR)
	{
		if(bPlayerGameSettings[playerid] & prk_Started)
			prk_Fall(playerid);
	}
}

prk_Finish(playerid)
{
	new
		tmpTime[20],
		tmpMs = tickcount()-prk_StartTick[playerid],
		tmpname[PRK_MAX_NAME],
		tmpQuery[128],
		tmpField[24],
		DBResult:tmpResult,
		numrows,
		place,
		failedpb;

    tmpTime = MsToString(tmpMs, 1);

	strcpy(tmpname, prk_Data[prk_CurrentCourse[playerid]][prk_Name]);
	strreplace(tmpname, " ", "_");

    format(tmpQuery, 128,
		"SELECT * FROM `%s` WHERE `"#PRK_ROW_PLAYER"` = '%p'",
		tmpname, playerid);

	tmpResult = db_query(prk_Highscores, tmpQuery);
	db_get_field(tmpResult, 1, tmpField, 11);
	
	if(db_num_rows(tmpResult) > 0)
	{
		if(tmpMs < strval(tmpField))
		{
			format(tmpQuery, 128,
				"UPDATE `%s` SET `"#PRK_ROW_TIME"` = '%d' WHERE `"#PRK_ROW_PLAYER"` = '%p'",
				tmpname, tmpMs, playerid);

			db_free_result(db_query(prk_Highscores, tmpQuery));
		}
	}
	else
	{
		format(tmpQuery, 128,
			"INSERT INTO `%s` (`"#PRK_ROW_PLAYER"`, `"#PRK_ROW_TIME"`) VALUES('%p', '%d')",
			tmpname, playerid, tmpMs);

		db_free_result(db_query(prk_Highscores, tmpQuery));
	}

	format(tmpQuery, 128,
		"SELECT * FROM `%s` ORDER BY (`"#PRK_ROW_TIME"` * 1) ASC",
		tmpname);

	tmpResult = db_query(prk_Highscores, tmpQuery);
	numrows = db_num_rows(tmpResult);

	if(numrows > 0)
	{
	    while(place < numrows)
		{
			db_get_field(tmpResult, 0, tmpField, 24);

		    if(!strcmp(tmpField, gPlayerName[playerid], true))
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
			GivePlayerScore(playerid, 1);
		    prk_Data[prk_CurrentCourse[playerid]][prk_BestPlayer] = gPlayerName[playerid];
		    prk_Data[prk_CurrentCourse[playerid]][prk_BestTime] = tmpMs;
		}
		if(place < 3)
		{
			if(numrows > 4-(place+1))
			{
				GivePlayerMoney(playerid, prk_Rewards[place]);
				GivePlayerScore(playerid, 4-(place+1));
				MsgF(playerid, YELLOW, " >  You won "#C_BLUE"$%d and %d score"#C_YELLOW"for getting in "#C_ORANGE"%d%s "#C_YELLOW"in the leaderboard!",
					prk_Rewards[place], 4-(place+1), place+1, returnOrdinal(place+1));
			}
		}
	}

	if(failedpb)
	{
		PlayerLoop(i)if(IsPlayerInFreeRoam(i) || gCurrentMinigame[i] == MINIGAME_PARKOUR)
		{
			MsgF(i, YELLOW, " >  %P"#C_YELLOW" finished parkour course "#C_BLUE"'%s' "#C_YELLOW"in "#C_ORANGE"%s"#C_YELLOW"",
				playerid, prk_Data[prk_CurrentCourse[playerid]][prk_Name], tmpTime);
		}
	}
	else
	{
		PlayerLoop(i)if(IsPlayerInFreeRoam(i) || gCurrentMinigame[i] == MINIGAME_PARKOUR)
		{
			MsgF(i, YELLOW, " >  %P"#C_YELLOW" finished parkour course "#C_BLUE"'%s' "#C_YELLOW"in "#C_ORANGE"%s"#C_YELLOW" (%d%s)",
				playerid, prk_Data[prk_CurrentCourse[playerid]][prk_Name], tmpTime, place+1, returnOrdinal(place+1));
		}
	}

	prk_Leave(playerid, false);
}



script_Parkour_Checkpoint(playerid, checkpointid)
{
	if(checkpointid==prk_CurrentCP[playerid])
	{
	    if(prk_CurrentCheck[playerid]==prk_Data[prk_CurrentCourse[playerid]][prk_MaxCP]-1)prk_Finish(playerid);
	    else
	    {
	        prk_CurrentCheck[playerid]++;
	        GivePlayerHP(playerid, 30.0);
	        prk_UpdateCheckPoint(playerid);
		    prk_UpdateGUI(playerid);
	    }
	    return 1;
	}
	return 1;
}
prk_Fall(playerid)
{
	new Float:tmpAngle = GetAngleToPoint(
		prk_CheckPointPos[prk_CurrentCourse[playerid]][prk_CurrentCheck[playerid]-1][0],
		prk_CheckPointPos[prk_CurrentCourse[playerid]][prk_CurrentCheck[playerid]-1][1],
		prk_CheckPointPos[prk_CurrentCourse[playerid]][prk_CurrentCheck[playerid]][0],
		prk_CheckPointPos[prk_CurrentCourse[playerid]][prk_CurrentCheck[playerid]][1]);

	SetPlayerPos(playerid, prk_CheckPointPos[prk_CurrentCourse[playerid]][prk_CurrentCheck[playerid]-1][0], prk_CheckPointPos[prk_CurrentCourse[playerid]][prk_CurrentCheck[playerid]-1][1], prk_CheckPointPos[prk_CurrentCourse[playerid]][prk_CurrentCheck[playerid]-1][2]);
	SetPlayerFacingAngle(playerid, -tmpAngle);
	SetPlayerVirtualWorld(playerid, MINIGAME_WORLD);
}
prk_UpdateCheckPoint(playerid)
{
	new
		prk_CpStr[48];

	format(prk_CpStr, 48, "Checkpoint %d/%d",
		prk_CurrentCheck[playerid],
		prk_Data[prk_CurrentCourse[playerid]][prk_MaxCP]-1);


	if(prk_CurrentCheck[playerid]>1)DestroyCheckPoint(prk_CurrentCP[playerid]);
	prk_CurrentCP[playerid] = CreateCheckPoint(
		prk_CheckPointPos[prk_CurrentCourse[playerid]][prk_CurrentCheck[playerid]][0],
		prk_CheckPointPos[prk_CurrentCourse[playerid]][prk_CurrentCheck[playerid]][1],
		prk_CheckPointPos[prk_CurrentCourse[playerid]][prk_CurrentCheck[playerid]][2],
		3.0, MINIGAME_WORLD, 0, playerid, 300.0, _, prk_CpStr, 0, 1, BLUE, 1, 1, BLUE, 1318, Float:{0.0, 0.0, 0.0});
}
prk_UpdateGUI(playerid)
{
    new str[128];
    format(str, 128, "Checkpoint: %d/%d", prk_CurrentCheck[playerid]-1, prk_Data[prk_CurrentCourse[playerid]][prk_MaxCP]-1);
    ShowMsgBox(playerid, str, 0, 100);
}
prk_Leave(playerid, msg = true)
{
    gCurrentMinigame[playerid] = MINIGAME_NONE;
	prk_CurrentCheck[playerid] = -1;
	f:bPlayerGameSettings[playerid]<prk_Started>;
	stop prk_CountTimer[playerid];
	if(IsValidCheckPoint(prk_CurrentCP[playerid]))DestroyCheckPoint(prk_CurrentCP[playerid]);

	SetPlayerVirtualWorld(playerid, FREEROAM_WORLD);
	SetPlayerInterior(playerid, 0);
	SetCameraBehindPlayer(playerid);
	CancelSelectTextDraw(playerid);

	ResetSpectatorTarget(playerid);
	HideMsgBox(playerid);

	if(msg)
	{
		PlayerLoop(i)if(IsPlayerInFreeRoam(i) || gCurrentMinigame[i] == MINIGAME_PARKOUR)
			MsgF(i, YELLOW, " >  %P"#C_YELLOW" has left the "#C_BLUE"Parkour "#C_YELLOW"minigame.", playerid);
	}

	return 1;
}

prk_FormatCourseList(playerid)
{
	new list[265];
	for(new i;i<prk_TotalCourses;i++)
	{
	    strcat(list, prk_Data[i][prk_Name]);
	    strcat(list, "\n");
	}
	strcat(list, "\nCancel");
	ShowPlayerDialog(playerid, d_ParkourList, DIALOG_STYLE_LIST, "Choose a parkour map", list, "Play", "Top 10");
}
prk_FormatHighScoreList(playerid, course)
{
	new
	    tmpQuery[128],
	    DBResult:tmpResult,
	    tmpname[PRK_MAX_NAME],
		numrows,
		tmpStr[64],
		title[PRK_MAX_NAME + 16],
		list[64 * 10];

	strcpy(tmpname, prk_Data[course][prk_Name]);
	strreplace(tmpname, " ", "_");

	format(tmpQuery, 128,
		"SELECT * FROM `%s` ORDER BY (`"#PRK_ROW_TIME"` * 1) ASC LIMIT 10",
		tmpname);

	tmpResult = db_query(prk_Highscores, tmpQuery);
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

	strcpy(title, prk_Data[course][prk_Name]);
	strcat(title, " - Highscores");

	ShowPlayerDialog(playerid, d_ParkourScores, DIALOG_STYLE_MSGBOX, title, list, "Close", "");

	return 1;
}
hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_ParkourList)
	{
	    if(listitem >= prk_TotalCourses)return 0;
		if(response)prk_Join(playerid, listitem);
		else prk_FormatHighScoreList(playerid, listitem);
	}
	if(dialogid == d_ParkourScores)prk_FormatCourseList(playerid);
	return 1;
}

prk_LoadCourses()
{
	print("- Loading Parkour...");
	new
		File:idxFile=fopen(PRK_INDEX_FILE, io_read),
		File:pkFile,
		line[64],
		len,
		idx,
		sub_idx,
		pkFileLine[64],
		filename[48],
		tmpname[PRK_MAX_NAME],
		pkCamDir[64],
		tmpQuery[128],
		DBResult:tmpResult;

	prk_Highscores = db_open(PRK_DATABASE);
    prk_TotalCourses = 0;

	while(fread(idxFile, line))
	{
	    len = strlen(line);
		if(line[len-2]=='\r')line[len-2]=EOS;

		format(prk_Data[idx][prk_Name], 32, line);
		format(filename, 48, PRK_DATA_FILE, prk_Data[idx][prk_Name]);

		if(!fexist(filename))
		{
			printf("Error: File '%s' Not Found", filename);
			continue;
		}

		pkFile = fopen(filename, io_read);

	    sub_idx = 0;
		while(fread(pkFile, pkFileLine))
		{
			if(!sscanf(pkFileLine, "p<,>ffff",
				prk_CheckPointPos[idx][sub_idx][0],
				prk_CheckPointPos[idx][sub_idx][1],
				prk_CheckPointPos[idx][sub_idx][2],
				prk_CheckPointPos[idx][sub_idx][3]))sub_idx++;

			else printf("ERROR: In file '%s'", filename);
		}
		fclose(pkFile);

		format(pkCamDir, 64, "pkcam.%s", prk_Data[idx][prk_Name]);
		prk_Data[idx][prk_IntroCam] = LoadCameraMover(pkCamDir);

		strcpy(tmpname, prk_Data[idx][prk_Name]);
		strreplace(tmpname, " ", "_");

		format(tmpQuery, 128,
			"CREATE TABLE IF NOT EXISTS `%s` (`"#PRK_ROW_PLAYER"`, `"#PRK_ROW_TIME"`)",
			tmpname);

		db_query(prk_Highscores, tmpQuery);

		format(tmpQuery, 128,
			"SELECT * FROM `%s` ORDER BY (`"#PRK_ROW_TIME"` * 1) ASC LIMIT 1",
			tmpname);

		tmpResult = db_query(prk_Highscores, tmpQuery);
		if(db_num_rows(tmpResult) > 0)
		{
		    new tmpField[24];

			db_get_field(tmpResult, 0, tmpField, 24);
			prk_Data[idx][prk_BestPlayer] = tmpField;

			db_get_field(tmpResult, 1, tmpField, 24);
			prk_Data[idx][prk_BestTime] = strval(tmpField);
		}
		db_free_result(tmpResult);


		prk_Data[idx][prk_MaxCP] = sub_idx;
		idx++;
	}
	prk_TotalCourses = idx;
	fclose(idxFile);
	return 1;
}
prk_UnloadCourses()
{
	for(new i;i<prk_TotalCourses;i++)
	{
	    if(IsValidCameraHandle(prk_Data[i][prk_IntroCam]))
		    ClearCameraID(prk_Data[i][prk_IntroCam]);
	}
	prk_TotalCourses = 0;
}


CMD:reloadparkour(playerid, params[])
{
    prk_UnloadCourses();
    prk_LoadCourses();
	return 1;
}

