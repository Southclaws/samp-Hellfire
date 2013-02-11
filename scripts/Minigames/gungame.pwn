#include <YSI\y_hooks>

#define GUN_INDEX_FILE			"Gungame/index.ini"
#define GUN_DATA_FILE			"Gungame/%s.dat"
#define GUN_MAX_ARENA			(8)
#define GUN_MAX_ARENA_NAME		(24)
#define GUN_MAX_ARENA_FILENAME	(8+GUN_MAX_ARENA_NAME+4)
#define GUN_MAX_SPAWNS			(16)

#define GUN_MAX_WEAPON_LEVEL	14


enum E_GUN_ARENA_DATA
{
Float:		gun_posX,
Float:		gun_posY,
Float:		gun_posZ,
Float:		gun_rotZ
}
enum e_gun_leaderboard_data
{
			gun_playerId,
			gun_playerScore
}


new
			gun_ArenaData[GUN_MAX_ARENA][GUN_MAX_SPAWNS][E_GUN_ARENA_DATA],
			gun_ArenaName[GUN_MAX_ARENA][GUN_MAX_ARENA_NAME],
			gun_TotalSpawns[GUN_MAX_ARENA],
			gun_TotalArenas,
			gun_CurrentArena = -1,
			gun_Active,
			gun_Leaderboard[MAX_PLAYERS][e_gun_leaderboard_data];

new
			gun_PlayerLbPosition[MAX_PLAYERS],
			gun_WeaponLevel[MAX_PLAYERS],
			gun_WeaponTable[GUN_MAX_WEAPON_LEVEL] =
			{
				22,
				23,
				24,
				25,
				26,
				27,
				28,
				29,
				33,
				30,
				31,
				34,
				37,
				4
			};

new
PlayerText:	gun_PlayerPosTextBackground,
PlayerText:	gun_PlayerPosTextForground,
PlayerText:	gun_PlayerPosTextPlace,
PlayerText: gun_PlayerPosTextLevel,
Text:		gun_LbColumn1[MAX_PLAYERS],
Text:		gun_LbColumn2[MAX_PLAYERS],
Text:		gun_LbColumn3[MAX_PLAYERS];


CMD:gungame(playerid, params[])
{
	if(gCurrentChallenge != CHALLENGE_NONE)
	{
		Msg(playerid, YELLOW, " >  You can't start a minigame while a challenge is active.");
		return 1;
	}
	if(gCurrentMinigame[playerid] == MINIGAME_GUNGAME)
	{
		gun_Leave(playerid);
	}
	else if(gCurrentMinigame[playerid] == MINIGAME_NONE)
	{
		if(gun_Active == DGW_STATE_INACTIVE)
			gun_FormatArenaList(playerid);

		else
			gun_Join(playerid);
	}
	else
	{
		Msg(playerid, YELLOW, " >  Please exit your current minigame before joining another");
	}
	return 1;
}

gun_Start(arena)
{
	gun_CurrentArena = arena;
	gun_Active = true;
}

gun_Join(playerid, msg = true)
{
	gCurrentMinigame[playerid] = MINIGAME_GUNGAME;
	SetPlayerVirtualWorld(playerid, MINIGAME_WORLD);

	gun_UpdateLeaderboard();
	gun_Spawn(playerid);

	if(msg)
	{
		PlayerLoop(i)if(IsPlayerInFreeRoam(i) || gCurrentMinigame[playerid] == MINIGAME_GUNGAME)
			MsgF(i, YELLOW, " >  %P"#C_YELLOW" has joined the "#C_BLUE"Gun-Game "#C_YELLOW"minigame on the map: "#C_BLUE"%s"#C_YELLOW"! Type "#C_ORANGE"/gungame "#C_YELLOW"to join.",
				playerid, gun_ArenaName[gun_CurrentArena]);
	}
}

gun_Spawn(playerid)
{
	new spawn = random(gun_TotalSpawns[gun_CurrentArena]);

	SetPlayerPos(playerid,
		gun_ArenaData[gun_CurrentArena][spawn][gun_posX],
		gun_ArenaData[gun_CurrentArena][spawn][gun_posY],
		gun_ArenaData[gun_CurrentArena][spawn][gun_posZ]+1.0);

	FreezePlayer(playerid, 1000);

	SetPlayerFacingAngle(playerid, gun_ArenaData[gun_CurrentArena][spawn][gun_rotZ]);
	SetPlayerVirtualWorld(playerid, MINIGAME_WORLD);
	
	SetPlayerHP(playerid, 100.0);

	ResetPlayerWeapons(playerid);
	GivePlayerWeapon(playerid,
		gun_WeaponTable[gun_WeaponLevel[playerid]],
		WepData[gun_WeaponTable[gun_WeaponLevel[playerid]]][MagSize] * 4);
	
	SetCameraBehindPlayer(playerid);
	gun_ShowHud(playerid);
}

script_GunGame_OnPlayerDeath(playerid, killerid, reason)
{
	if(gCurrentMinigame[playerid] == MINIGAME_GUNGAME)
	{
		if(killerid != INVALID_PLAYER_ID)
		{
		    if(gCurrentMinigame[killerid] == MINIGAME_GUNGAME)
		    {
			    if(reason == 0)
			    {
			        if(gun_WeaponLevel[playerid] > 0)
						gun_WeaponLevel[playerid]--;

					gun_UpdateLeaderboard();
			    }
			    if(gun_WeaponLevel[killerid] < GUN_MAX_WEAPON_LEVEL)
				{
					gun_WeaponLevel[killerid]++;
					gun_UpdateWeaponLevelUI(killerid);
					gun_UpdateLeaderboard();

					if(gun_WeaponLevel[killerid] == GUN_MAX_WEAPON_LEVEL)
					{
						gun_EndRound();
					}
					else
					{
						ResetPlayerWeapons(killerid);
						GivePlayerWeapon(killerid,
							gun_WeaponTable[gun_WeaponLevel[killerid]],
							WepData[gun_WeaponTable[gun_WeaponLevel[killerid]]][MagSize] * 4);
					}
				}
			}
		}
		else
		{
	        if(gun_WeaponLevel[playerid] > 0)
				gun_WeaponLevel[playerid]--;

			gun_UpdateLeaderboard();
		}
		gun_HideHud(playerid);
	}
}
hook OnPlayerSpawn(playerid)
{
	if(gCurrentMinigame[playerid] == MINIGAME_GUNGAME)
		defer gun_Respawn(playerid);

	return 1;
}
timer gun_Respawn[500](playerid)
{
	gun_Spawn(playerid);
}

gun_EndRound()
{
	gun_UpdateLeaderboard();
	PlayerLoop(i)
	{
		if(gCurrentMinigame[i] == MINIGAME_GUNGAME)
		{
			gun_ShowLeaderboard(i);
			gun_HideHud(i);
			ResetPlayerWeapons(i);
		}
	}
	defer gun_NewRound();
}

timer gun_NewRound[10000]()
{
	PlayerLoop(i)
	{
		if(gCurrentMinigame[i] == MINIGAME_GUNGAME)
		{
			gun_WeaponLevel[i] = 0;
			gun_UpdateWeaponLevelUI(i);
			gun_Spawn(i);
			gun_HideLeaderboard(i);
		}
	}
	gun_UpdateLeaderboard();
}

gun_UpdateLeaderboard()
{
	for(new i; i < MAX_PLAYERS; i++)
	{
	    if(gCurrentMinigame[i] == MINIGAME_GUNGAME)
	    {
			gun_Leaderboard[i][gun_playerId] = i;
			gun_Leaderboard[i][gun_playerScore] = gun_WeaponLevel[i];
		}
		else
		{
			gun_Leaderboard[i][gun_playerId] = -1;
			gun_Leaderboard[i][gun_playerScore] = -1;
		}
	}

	SortDeepArray(gun_Leaderboard, gun_playerScore, .order = SORT_DESC);

	for(new i; i < MAX_PLAYERS; i++)
	{
	    if(0 <= gun_Leaderboard[i][gun_playerId] < MAX_PLAYERS)
	    {
			gun_PlayerLbPosition[gun_Leaderboard[i][gun_playerId]] = i;
			gun_UpdateLbPositionUI(gun_Leaderboard[i][gun_playerId]);
		}
	}
}

gun_UpdateWeaponLevelUI(playerid)
{
	new str[13];

	format(str, 13, "Level: %d/%d", gun_WeaponLevel[playerid] + 1, GUN_MAX_WEAPON_LEVEL);
	PlayerTextDrawSetString(playerid, gun_PlayerPosTextLevel, str);
}

gun_UpdateLbPositionUI(playerid)
{
	new str[4];

	valstr(str, gun_PlayerLbPosition[playerid] + 1);
	strcat(str, returnOrdinal(gun_PlayerLbPosition[playerid] + 1));

	PlayerTextDrawSetString(playerid, gun_PlayerPosTextPlace, str);
}

gun_ShowHud(playerid)
{
	PlayerTextDrawShow(playerid, gun_PlayerPosTextBackground);
	PlayerTextDrawShow(playerid, gun_PlayerPosTextForground);
	PlayerTextDrawShow(playerid, gun_PlayerPosTextPlace);
	PlayerTextDrawShow(playerid, gun_PlayerPosTextLevel);
}
gun_HideHud(playerid)
{
	PlayerTextDrawHide(playerid, gun_PlayerPosTextBackground);
	PlayerTextDrawHide(playerid, gun_PlayerPosTextForground);
	PlayerTextDrawHide(playerid, gun_PlayerPosTextPlace);
	PlayerTextDrawHide(playerid, gun_PlayerPosTextLevel);
}

gun_ShowLeaderboard(playerid)
{
	new str[24];

	SortDeepArray(gun_Leaderboard, gun_playerScore, .order = SORT_DESC);

	for(new i; i < MAX_PLAYERS; i++)
	{
		if(0 <= gun_Leaderboard[i][gun_playerId] < MAX_PLAYERS)
		{
		    valstr(str, i+1);
			TextDrawSetString(gun_LbColumn1[i], str);

			GetPlayerName(gun_Leaderboard[i][gun_playerId], str, 24);
			TextDrawSetString(gun_LbColumn2[i], str);

		    valstr(str, gun_WeaponLevel[gun_Leaderboard[i][gun_playerId]]);
			TextDrawSetString(gun_LbColumn3[i], str);

			TextDrawShowForPlayer(playerid, gun_LbColumn1[i]);
			TextDrawShowForPlayer(playerid, gun_LbColumn2[i]);
			TextDrawShowForPlayer(playerid, gun_LbColumn3[i]);
		}
		else break;
	}
}
gun_HideLeaderboard(playerid)
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		TextDrawHideForPlayer(playerid, gun_LbColumn1[i]);
		TextDrawHideForPlayer(playerid, gun_LbColumn2[i]);
		TextDrawHideForPlayer(playerid, gun_LbColumn3[i]);
	}
}

gun_Leave(playerid, msg = true)
{
	gCurrentMinigame[playerid] = MINIGAME_NONE;
	SetPlayerVirtualWorld(playerid, FREEROAM_WORLD);

	ResetPlayerWeapons(playerid);
	gun_HideHud(playerid);

	if(gun_PlayersInGame() == 0)
	{
	    gun_End();
	}
    if(msg)
	{
		PlayerLoop(i)if(IsPlayerInFreeRoam(i) || gCurrentMinigame[i] == MINIGAME_GUNGAME)
			MsgF(i, YELLOW, " >  %P"#C_YELLOW" has left the "#C_BLUE"/gungame "#C_YELLOW"minigame.", playerid);
	}
}

gun_End()
{
	PlayerLoop(i)
	{
		if(gCurrentMinigame[i] == MINIGAME_GUNGAME)
		{
		    ResetPlayerWeapons(i);
		}
	}
	gun_Active = false;
}

gun_PlayersInGame()
{
	new count;
	PlayerLoop(i)
	{
		if(gCurrentMinigame[i] == MINIGAME_GUNGAME)count++;
	}
	return count;
}

gun_FormatArenaList(playerid)
{
	new
	    list[GUN_MAX_ARENA * (GUN_MAX_ARENA_NAME + 1)];

	for(new i; i < gun_TotalArenas; i++)
	{
	    strcat(list, gun_ArenaName[i]);
	    strcat(list, "\n");
	}
	
	ShowPlayerDialog(playerid, d_GungameList, DIALOG_STYLE_LIST, "Gun Game", list, "Start", "Cancel");
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_GungameList && response)
	{
	    gun_Start(listitem);
	    gun_Join(playerid);
	}
	return 1;
}

gun_LoadArenas()
{
	new
		File:idxFile,
		File:datFile,
		line[128],
		filename[GUN_MAX_ARENA_FILENAME],
		arenaidx,
		spawnidx;

	if(!fexist(GUN_INDEX_FILE))
	{
		print("ERROR: Gungame index file not found");
		return 0;
	}

	idxFile = fopen(GUN_INDEX_FILE, io_read);
	
	gun_TotalArenas = 0;

	while(fread(idxFile, line))
	{
		strtrim(line, "\r\n");

        gun_ArenaName[arenaidx][0] = EOS;
		strcat(gun_ArenaName[arenaidx], line);
	    format(filename, sizeof(filename), GUN_DATA_FILE, line);
	    
	    if(!fexist(filename))
	    {
	    	printf("ERROR: Gungame arena '%s' file not found", filename);
	    	return 0;
	    }
	    
		datFile = fopen(filename, io_read);

		while(fread(datFile, line))
		{
			if(!sscanf(line, "e<p<,>ffff>", gun_ArenaData[arenaidx][spawnidx]))
			    spawnidx++;
		}
		gun_TotalSpawns[arenaidx] = spawnidx;
		arenaidx++;
	}

	fclose(idxFile);
	
	gun_TotalArenas = arenaidx;

	return 1;
}

gun_LoadPlayerTextDraws(playerid)
{
	gun_PlayerPosTextBackground		=CreatePlayerTextDraw(playerid, 550.000000, 350.000000, "LD_DRV:nawtxt");
	PlayerTextDrawBackgroundColor	(playerid, gun_PlayerPosTextBackground, 255);
	PlayerTextDrawFont				(playerid, gun_PlayerPosTextBackground, 4);
	PlayerTextDrawLetterSize		(playerid, gun_PlayerPosTextBackground, 0.500000, 1.000000);
	PlayerTextDrawColor				(playerid, gun_PlayerPosTextBackground, -1);
	PlayerTextDrawSetOutline		(playerid, gun_PlayerPosTextBackground, 0);
	PlayerTextDrawSetProportional	(playerid, gun_PlayerPosTextBackground, 1);
	PlayerTextDrawSetShadow			(playerid, gun_PlayerPosTextBackground, 1);
	PlayerTextDrawUseBox			(playerid, gun_PlayerPosTextBackground, 1);
	PlayerTextDrawBoxColor			(playerid, gun_PlayerPosTextBackground, 255);
	PlayerTextDrawTextSize			(playerid, gun_PlayerPosTextBackground, 70.000000, 70.000000);

	gun_PlayerPosTextForground		=CreatePlayerTextDraw(playerid, 556.000000, 341.000000, "O");
	PlayerTextDrawBackgroundColor	(playerid, gun_PlayerPosTextForground, 255);
	PlayerTextDrawFont				(playerid, gun_PlayerPosTextForground, 1);
	PlayerTextDrawLetterSize		(playerid, gun_PlayerPosTextForground, 2.170000, 9.000000);
	PlayerTextDrawColor				(playerid, gun_PlayerPosTextForground, -1);
	PlayerTextDrawSetOutline		(playerid, gun_PlayerPosTextForground, 0);
	PlayerTextDrawSetProportional	(playerid, gun_PlayerPosTextForground, 1);
	PlayerTextDrawSetShadow			(playerid, gun_PlayerPosTextForground, 0);

	gun_PlayerPosTextPlace			=CreatePlayerTextDraw(playerid, 584.000000, 364.000000, "2nd");
	PlayerTextDrawAlignment			(playerid, gun_PlayerPosTextPlace, 2);
	PlayerTextDrawBackgroundColor	(playerid, gun_PlayerPosTextPlace, 255);
	PlayerTextDrawFont				(playerid, gun_PlayerPosTextPlace, 1);
	PlayerTextDrawLetterSize		(playerid, gun_PlayerPosTextPlace, 0.769999, 4.000000);
	PlayerTextDrawColor				(playerid, gun_PlayerPosTextPlace, 255);
	PlayerTextDrawSetOutline		(playerid, gun_PlayerPosTextPlace, 0);
	PlayerTextDrawSetProportional	(playerid, gun_PlayerPosTextPlace, 1);
	PlayerTextDrawSetShadow			(playerid, gun_PlayerPosTextPlace, 0);

	gun_PlayerPosTextLevel			=CreatePlayerTextDraw(playerid, 585.000000, 330.000000, "Level: 1/"#GUN_MAX_WEAPON_LEVEL"");
	PlayerTextDrawAlignment			(playerid, gun_PlayerPosTextLevel, 2);
	PlayerTextDrawBackgroundColor	(playerid, gun_PlayerPosTextLevel, 255);
	PlayerTextDrawFont				(playerid, gun_PlayerPosTextLevel, 1);
	PlayerTextDrawLetterSize		(playerid, gun_PlayerPosTextLevel, 0.300000, 1.499999);
	PlayerTextDrawColor				(playerid, gun_PlayerPosTextLevel, -1);
	PlayerTextDrawSetOutline		(playerid, gun_PlayerPosTextLevel, 1);
	PlayerTextDrawSetProportional	(playerid, gun_PlayerPosTextLevel, 1);
}
gun_UnloadPlayerTextDraws(playerid)
{
	PlayerTextDrawDestroy(playerid, gun_PlayerPosTextBackground);
	PlayerTextDrawDestroy(playerid, gun_PlayerPosTextForground);
	PlayerTextDrawDestroy(playerid, gun_PlayerPosTextPlace);
}


gun_LoadTextDraws()
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		gun_LbColumn1[i]			=TextDrawCreate(209.000000, 140.000000 + (15 * i), "1");
		TextDrawBackgroundColor		(gun_LbColumn1[i], 255);
		TextDrawFont				(gun_LbColumn1[i], 1);
		TextDrawLetterSize			(gun_LbColumn1[i], 0.250000, 1.000000);
		TextDrawColor				(gun_LbColumn1[i], -1);
		TextDrawSetOutline			(gun_LbColumn1[i], 0);
		TextDrawSetProportional		(gun_LbColumn1[i], 1);
		TextDrawSetShadow			(gun_LbColumn1[i], 1);
		TextDrawUseBox				(gun_LbColumn1[i], 1);
		TextDrawBoxColor			(gun_LbColumn1[i], 100);
		TextDrawTextSize			(gun_LbColumn1[i], 215.000000, 0.000000);

		gun_LbColumn2[i]			=TextDrawCreate(320.0, 140.0 + (15 * i), "[HLF]Southclaw");
		TextDrawAlignment			(gun_LbColumn2[i], 2);
		TextDrawBackgroundColor		(gun_LbColumn2[i], 255);
		TextDrawFont				(gun_LbColumn2[i], 1);
		TextDrawLetterSize			(gun_LbColumn2[i], 0.250000, 1.000000);
		TextDrawColor				(gun_LbColumn2[i], -1);
		TextDrawSetOutline			(gun_LbColumn2[i], 0);
		TextDrawSetProportional		(gun_LbColumn2[i], 1);
		TextDrawSetShadow			(gun_LbColumn2[i], 1);
		TextDrawUseBox				(gun_LbColumn2[i], 1);
		TextDrawBoxColor			(gun_LbColumn2[i], 100);
		TextDrawTextSize			(gun_LbColumn2[i], 10.000000, 200.000000);

		gun_LbColumn3[i]			=TextDrawCreate(425.0, 140.0 + (15 * i), "1");
		TextDrawBackgroundColor		(gun_LbColumn3[i], 255);
		TextDrawFont				(gun_LbColumn3[i], 1);
		TextDrawLetterSize			(gun_LbColumn3[i], 0.250000, 1.000000);
		TextDrawColor				(gun_LbColumn3[i], -1);
		TextDrawSetOutline			(gun_LbColumn3[i], 0);
		TextDrawSetProportional		(gun_LbColumn3[i], 1);
		TextDrawSetShadow			(gun_LbColumn3[i], 1);
		TextDrawUseBox				(gun_LbColumn3[i], 1);
		TextDrawBoxColor			(gun_LbColumn3[i], 100);
		TextDrawTextSize			(gun_LbColumn3[i], 431.000000, 0.000000);
	}
}

