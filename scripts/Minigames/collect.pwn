#include <YSI\y_hooks>

#define CLT_MAX_COURSE		(8)
#define CLT_MAX_ITEM		(20)
#define CLT_MAX_NAME		(32)

#define CLT_INDEX_FILE		"Collect/index.ini"
#define CLT_DATA_FILE		"Collect/%s.dat"
#define CLT_DATABASE		"Collect/highscores.db"
#define CLT_ROW_PLAYER		"player"
#define CLT_ROW_TIME		"time"


enum ENUM_COLLECT_DATA
{
		clt_Name			[CLT_MAX_NAME],
		clt_Model,
		clt_BestPlayer		[MAX_PLAYER_NAME],
		clt_BestTime,
		clt_MaxItem,
		clt_IntroCam
}
new
		clt_Data			[CLT_MAX_COURSE][ENUM_COLLECT_DATA],
Float:	clt_CheckPointPos	[CLT_MAX_COURSE][CLT_MAX_ITEM][4],
		clt_Items			[CLT_MAX_ITEM],
DB:		clt_Highscores,
		clt_TotalCourses;

new
		clt_CurrentCourse	[MAX_PLAYERS],
		clt_ItemCount		[MAX_PLAYERS],
		clt_StartTick		[MAX_PLAYERS],
		clt_CountDown		[MAX_PLAYERS],
Timer:	clt_CountTimer		[MAX_PLAYERS],
		clt_Rewards			[3] = {300, 100, 50};


CMD:collect(playerid, params[])
{
	if(gCurrentChallenge != CHALLENGE_NONE)
	{
		Msg(playerid, YELLOW, " >  You can't start a minigame while a challenge is active.");
		return 1;
	}
	if(gCurrentMinigame[playerid] == MINIGAME_COLLECT)
	{
		clt_Leave(playerid);
	}
	else if(gCurrentMinigame[playerid] == MINIGAME_NONE)
	{
		clt_FormatCourseList(playerid);
	}
	else
	{
		Msg(playerid, YELLOW, " >  Please exit your current minigame before joining another");
	}
	return 1;
}

clt_Join(playerid, course, msg = true)
{
	gCurrentMinigame[playerid] = MINIGAME_COLLECT;
    clt_CurrentCourse[playerid] = course;

	SetPlayerPos(playerid, clt_CheckPointPos[course][0][0], clt_CheckPointPos[course][0][1], clt_CheckPointPos[course][0][2]);
	SetPlayerVirtualWorld(playerid, MINIGAME_WORLD);

    if(bPlayerGameSettings[playerid] & clt_SkipIntro || !IsValidCameraHandle(clt_Data[course][clt_IntroCam]))
		clt_StartCount(playerid);

	else
		PlayCameraMover(playerid, clt_Data[course][clt_IntroCam]);


	if(msg)
	{
		PlayerLoop(i)if(IsPlayerInFreeRoam(i) || gCurrentMinigame[playerid] == MINIGAME_COLLECT)
			MsgF(i, YELLOW, " >  %P"#C_YELLOW" Has gone to Item Collection map: "#C_BLUE"%s", playerid, clt_Data[clt_CurrentCourse[playerid]][clt_Name]);
	}
	Msg(playerid, LGREEN, " >  Type "#C_BLUE"/skip"#C_LGREEN" to skip the intro, type "#C_BLUE"/skipalways"#C_LGREEN" to never show the intro again.");
}


clt_SkipIntroCam(playerid)
{
	ExitCamera(playerid);
	clt_StartCount(playerid);
	Msg(playerid, ORANGE, "Intro Skipped!");
}


public OnCameraReachNode(playerid, camera, node)
{
	if(IsValidCameraHandle(clt_Data[clt_CurrentCourse[playerid]][clt_IntroCam]))
	{
		if(camera == clt_Data[clt_CurrentCourse[playerid]][clt_IntroCam] && node == GetCameraMaxNodes(camera) )
			clt_StartCount(playerid);
	}

	return CallLocalFunction("clt_OnCameraReachNode", "ddd", playerid, camera, node);
}
#if defined _ALS_OnCameraReachNode
    #undef OnCameraReachNode
#else
    #define _ALS_OnCameraReachNode
#endif
#define OnCameraReachNode clt_OnCameraReachNode
forward clt_OnCameraReachNode(playerid, pickupid);


clt_StartCount(playerid)
{
	new
		Float:tmpAngle = GetAngleToPoint(
			clt_CheckPointPos[clt_CurrentCourse[playerid]][0][0], clt_CheckPointPos[clt_CurrentCourse[playerid]][0][1],
			clt_CheckPointPos[clt_CurrentCourse[playerid]][1][0], clt_CheckPointPos[clt_CurrentCourse[playerid]][1][1]);

	SetPlayerPos(playerid,
		clt_CheckPointPos[clt_CurrentCourse[playerid]][0][0],
		clt_CheckPointPos[clt_CurrentCourse[playerid]][0][1],
		clt_CheckPointPos[clt_CurrentCourse[playerid]][0][2]);

	SetPlayerFacingAngle(playerid, tmpAngle);
	SetPlayerVirtualWorld(playerid, MINIGAME_WORLD);

	TogglePlayerControllable(playerid, false);
	SetCameraBehindPlayer(playerid);

	clt_CountDown[playerid] = 5;
	clt_CountTick(playerid);
}
timer clt_CountTick[1000](playerid)
{
	new str[2];
	format(str, 2, "%d", clt_CountDown[playerid]);
	GameTextForPlayer(playerid, str, 3000, 5);
	if(clt_CountDown[playerid]>0)
	{
		clt_CountDown[playerid]--;
		clt_CountTimer[playerid] = defer clt_CountTick(playerid);
	}
	else
	{
		GameTextForPlayer(playerid, "Go!", 3000, 5);
		clt_Start(playerid);
	}
}
clt_Start(playerid)
{
	new
		tmpTime[20],
		ms = clt_Data[clt_CurrentCourse[playerid]][clt_BestTime];

	clt_Spawn(playerid);

	for (new i = 1; i < clt_Data[clt_CurrentCourse[playerid]][clt_MaxItem]; ++i)
	{
		clt_Items[i-1] = CreateDynamicPickup(clt_Data[clt_CurrentCourse[playerid]][clt_Model], 1,
			clt_CheckPointPos[clt_CurrentCourse[playerid]][i][0],
			clt_CheckPointPos[clt_CurrentCourse[playerid]][i][1],
			clt_CheckPointPos[clt_CurrentCourse[playerid]][i][2], MINIGAME_WORLD, 0);

	}

	clt_ItemCount[playerid] = 0;

	tmpTime = MsToString(ms, 1);

	TogglePlayerControllable(playerid, true);
	clt_StartTick[playerid] = GetTickCount();
	SetPlayerHP(playerid, 100.0);


	clt_UpdateGUI(playerid);

	t:bPlayerGameSettings[playerid]<clt_Started>;

	if(ms == 0)
		Msg(playerid, YELLOW, " >  The Timer Is Running! There is no best time for this map.");

	else
		MsgF(playerid, YELLOW, " >  The Timer Is Running! The best time is: "#C_WHITE"%s"#C_YELLOW" by "#C_GREEN"%s"#C_YELLOW"", tmpTime, clt_Data[clt_CurrentCourse[playerid]][clt_BestPlayer]);

	Msg(playerid, YELLOW,  " >  Type "#C_BLUE"/home "#C_YELLOW"to exit Item Collection.");
}

timer clt_Spawn[100](playerid)
{
	new
		Float:tmpAngle = GetAngleToPoint(
			clt_CheckPointPos[clt_CurrentCourse[playerid]][0][0], clt_CheckPointPos[clt_CurrentCourse[playerid]][0][1],
			clt_CheckPointPos[clt_CurrentCourse[playerid]][1][0], clt_CheckPointPos[clt_CurrentCourse[playerid]][1][1]);

	SetPlayerPos(playerid,
		clt_CheckPointPos[clt_CurrentCourse[playerid]][0][0],
		clt_CheckPointPos[clt_CurrentCourse[playerid]][0][1],
		clt_CheckPointPos[clt_CurrentCourse[playerid]][0][2]);

	SetPlayerFacingAngle(playerid, -tmpAngle);
	SetPlayerVirtualWorld(playerid, MINIGAME_WORLD);
}

hook OnPlayerSpawn(playerid)
{
	if(gCurrentMinigame[playerid] == MINIGAME_COLLECT)
	{
		defer clt_Spawn(playerid);
	}
}

clt_Finish(playerid)
{
	new
		tmpTime[20],
		tmpMs = GetTickCount()-clt_StartTick[playerid],
		tmpname[CLT_MAX_NAME],
		tmpQuery[128],
		tmpField[24],
		DBResult:tmpResult,
		numrows,
		place,
		failedpb;

    tmpTime = MsToString(tmpMs, 1);

	strcpy(tmpname, clt_Data[clt_CurrentCourse[playerid]][clt_Name]);
	strreplace(tmpname, " ", "_");

    format(tmpQuery, 128,
		"SELECT * FROM `%s` WHERE `"#CLT_ROW_PLAYER"` = '%p'",
		tmpname, playerid);

	tmpResult = db_query(clt_Highscores, tmpQuery);
	db_get_field(tmpResult, 1, tmpField, 11);
	
	if(db_num_rows(tmpResult) > 0)
	{
		if(tmpMs < strval(tmpField))
		{
			format(tmpQuery, 128,
				"UPDATE `%s` SET `"#CLT_ROW_TIME"` = '%d' WHERE `"#CLT_ROW_PLAYER"` = '%p'",
				tmpname, tmpMs, playerid);

			db_free_result(db_query(clt_Highscores, tmpQuery));
		}
	}
	else
	{
		format(tmpQuery, 128,
			"INSERT INTO `%s` (`"#CLT_ROW_PLAYER"`, `"#CLT_ROW_TIME"`) VALUES('%p', '%d')",
			tmpname, playerid, tmpMs);

		db_free_result(db_query(clt_Highscores, tmpQuery));
	}

	format(tmpQuery, 128,
		"SELECT * FROM `%s` ORDER BY (`"#CLT_ROW_TIME"` * 1) ASC",
		tmpname);

	tmpResult = db_query(clt_Highscores, tmpQuery);
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
		    clt_Data[clt_CurrentCourse[playerid]][clt_BestPlayer] = gPlayerName[playerid];
		    clt_Data[clt_CurrentCourse[playerid]][clt_BestTime] = tmpMs;
		}
		if(place < 3)
		{
			if(numrows > 4-(place+1))
			{
				GivePlayerMoney(playerid, clt_Rewards[place]);
				GivePlayerScore(playerid, 4-(place+1));
				MsgF(playerid, YELLOW, " >  You won "#C_BLUE"$%d and %d score"#C_YELLOW"for getting in "#C_ORANGE"%d%s "#C_YELLOW"in the leaderboard!",
					clt_Rewards[place], 4-(place+1), place+1, returnOrdinal(place+1));
			}
		}
	}

	if(failedpb)
	{
		PlayerLoop(i)if(IsPlayerInFreeRoam(i) || gCurrentMinigame[i] == MINIGAME_COLLECT)
		{
			MsgF(i, YELLOW, " >  %P"#C_YELLOW" finished Item Collection course "#C_BLUE"'%s' "#C_YELLOW"in "#C_ORANGE"%s"#C_YELLOW"",
				playerid, clt_Data[clt_CurrentCourse[playerid]][clt_Name], tmpTime);
		}
	}
	else
	{
		PlayerLoop(i)if(IsPlayerInFreeRoam(i) || gCurrentMinigame[i] == MINIGAME_COLLECT)
		{
			MsgF(i, YELLOW, " >  %P"#C_YELLOW" finished Item Collection course "#C_BLUE"'%s' "#C_YELLOW"in "#C_ORANGE"%s"#C_YELLOW" (%d%s)",
				playerid, clt_Data[clt_CurrentCourse[playerid]][clt_Name], tmpTime, place+1, returnOrdinal(place+1));
		}
	}

	clt_Leave(playerid, false);
}


public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{

	for (new i; i < clt_Data[clt_CurrentCourse[playerid]][clt_MaxItem]; i++)
	{
		if(pickupid == clt_Items[i])
		{
			clt_ItemCount[playerid]++;
			DestroyDynamicPickup(clt_Items[i]);
			clt_UpdateGUI(playerid);

			if(clt_ItemCount[playerid] >= clt_Data[clt_CurrentCourse[playerid]][clt_MaxItem] - 1)
			{
				clt_Finish(playerid);
			}
		}
	}

    return CallLocalFunction("clt_OnPlayerPickUpDynPickup", "dd", playerid, pickupid);
}
#if defined _ALS_OnPlayerPickUpDynPickup
    #undef OnPlayerPickUpDynamicPickup
#else
    #define _ALS_OnPlayerPickUpDynPickup
#endif
#define OnPlayerPickUpDynamicPickup clt_OnPlayerPickUpDynPickup
forward clt_OnPlayerPickUpDynPickup(playerid, pickupid);


clt_UpdateGUI(playerid)
{
    new str[128];
    format(str, 128, "Items: %d/%d", clt_ItemCount[playerid], clt_Data[clt_CurrentCourse[playerid]][clt_MaxItem] - 1);
    ShowActionText(playerid, str, 0, 100);
}
clt_Leave(playerid, msg = true)
{
    gCurrentMinigame[playerid] = MINIGAME_NONE;
	clt_ItemCount[playerid] = 0;
	f:bPlayerGameSettings[playerid]<clt_Started>;
	stop clt_CountTimer[playerid];

	for (new i; i < clt_Data[clt_CurrentCourse[playerid]][clt_MaxItem]; i++)
	{
		if(IsValidDynamicPickup(clt_Items[i]))
			DestroyDynamicPickup(clt_Items[i]);
	}

	SetPlayerVirtualWorld(playerid, FREEROAM_WORLD);
	SetPlayerInterior(playerid, 0);
	SetCameraBehindPlayer(playerid);
	CancelSelectTextDraw(playerid);

	ResetSpectatorTarget(playerid);
	HideActionText(playerid);

	if(msg)
	{
		PlayerLoop(i)if(IsPlayerInFreeRoam(i) || gCurrentMinigame[i] == MINIGAME_COLLECT)
			MsgF(i, YELLOW, " >  %P"#C_YELLOW" has left the "#C_BLUE"Item Collection "#C_YELLOW"minigame.", playerid);
	}

	return 1;
}

clt_FormatCourseList(playerid)
{
	new list[265];
	for(new i;i<clt_TotalCourses;i++)
	{
	    strcat(list, clt_Data[i][clt_Name]);
	    strcat(list, "\n");
	}
	strcat(list, "\nCancel");
	ShowPlayerDialog(playerid, d_CollectList, DIALOG_STYLE_LIST, "Choose an Item Collection map", list, "Play", "Top 10");
}
clt_FormatHighScoreList(playerid, course)
{
	new
	    tmpQuery[128],
	    DBResult:tmpResult,
	    tmpname[CLT_MAX_NAME],
		numrows,
		tmpStr[64],
		title[CLT_MAX_NAME + 16],
		list[64 * 10];

	strcpy(tmpname, clt_Data[course][clt_Name]);
	strreplace(tmpname, " ", "_");

	format(tmpQuery, 128,
		"SELECT * FROM `%s` ORDER BY (`"#CLT_ROW_TIME"` * 1) ASC LIMIT 10",
		tmpname);

	tmpResult = db_query(clt_Highscores, tmpQuery);
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

	strcpy(title, clt_Data[course][clt_Name]);
	strcat(title, " - Highscores");

	ShowPlayerDialog(playerid, d_CollectScores, DIALOG_STYLE_MSGBOX, title, list, "Close", "");

	return 1;
}
hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_CollectList)
	{
	    if(listitem >= clt_TotalCourses)return 0;
		if(response)clt_Join(playerid, listitem);
		else clt_FormatHighScoreList(playerid, listitem);
	}
	if(dialogid == d_CollectScores)clt_FormatCourseList(playerid);
	return 1;
}

clt_LoadCourses()
{
	print("- Loading Item Collection...");
	new
		File:idxFile=fopen(CLT_INDEX_FILE, io_read),
		File:datFile,
		line[64],
		idx,
		sub_idx,
		dataline[64],
		filename[48],
		tmpname[CLT_MAX_NAME],
		camfile[64],
		tmpQuery[128],
		DBResult:tmpResult;

	clt_Highscores = db_open(CLT_DATABASE);
    clt_TotalCourses = 0;

	while(fread(idxFile, line))
	{
		sscanf(line, "p<,>s[32]d", clt_Data[idx][clt_Name], clt_Data[idx][clt_Model]);
		format(filename, 48, CLT_DATA_FILE, clt_Data[idx][clt_Name]);

		if(!fexist(filename))
		{
			printf("Error: File '%s' Not Found", filename);
			continue;
		}

		datFile = fopen(filename, io_read);

	    sub_idx = 0;
		while(fread(datFile, dataline))
		{
			if(!sscanf(dataline, "p<,>fff",
				clt_CheckPointPos[idx][sub_idx][0],
				clt_CheckPointPos[idx][sub_idx][1],
				clt_CheckPointPos[idx][sub_idx][2]))sub_idx++;

			else printf("ERROR: In file '%s'", filename);
		}
		fclose(datFile);

		format(camfile, 64, "clt.%s", clt_Data[idx][clt_Name]);
		clt_Data[idx][clt_IntroCam] = LoadCameraMover(camfile);

		strcpy(tmpname, clt_Data[idx][clt_Name]);
		strreplace(tmpname, " ", "_");

		format(tmpQuery, 128,
			"CREATE TABLE IF NOT EXISTS `%s` (`"#CLT_ROW_PLAYER"`, `"#CLT_ROW_TIME"`)",
			tmpname);

		db_query(clt_Highscores, tmpQuery);

		format(tmpQuery, 128,
			"SELECT * FROM `%s` ORDER BY (`"#CLT_ROW_TIME"` * 1) ASC LIMIT 1",
			tmpname);

		tmpResult = db_query(clt_Highscores, tmpQuery);
		if(db_num_rows(tmpResult) > 0)
		{
		    new tmpField[24];

			db_get_field(tmpResult, 0, tmpField, 24);
			clt_Data[idx][clt_BestPlayer] = tmpField;

			db_get_field(tmpResult, 1, tmpField, 24);
			clt_Data[idx][clt_BestTime] = strval(tmpField);
		}
		db_free_result(tmpResult);


		clt_Data[idx][clt_MaxItem] = sub_idx;
		idx++;
	}
	clt_TotalCourses = idx;
	fclose(idxFile);
	return 1;
}
clt_UnloadCourses()
{
	for(new i;i<clt_TotalCourses;i++)
	{
	    if(IsValidCameraHandle(clt_Data[i][clt_IntroCam]))
		    ClearCameraID(clt_Data[i][clt_IntroCam]);
	}
	clt_TotalCourses = 0;
}


CMD:reloadcollect(playerid, params[])
{
    clt_UnloadCourses();
    clt_LoadCourses();
	return 1;
}

