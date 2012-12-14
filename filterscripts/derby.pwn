#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16

#include <colours>
#include <YSI\y_timers>
#include <YSI\y_va>
#include <foreach>
#include <formatex>
#include <sscanf2>
#include <zcmd>
#include <streamer>
#undef YELLOW
#include "../scripts/Releases/CameraMover.pwn"
#include "../scripts/Resources/VehicleResources.pwn"
#include "../scripts/System/PlayerFunctions.pwn"
#include "../scripts/System/Functions.pwn"


#define DBY_INDEX_FILE		"Derby/index.ini"
#define DBY_DATA_FILE		"Derby/%s.dat"
#define DBY_CAM_FILE		"dbycam.%s"
#define DBY_MAX_ARENA		(16)
#define DBY_MAX_NAME		(32)
#define DBY_MAX_SPAWN		(8)
#define DBY_SPAWN_ZOFFSET	(5.0)
#define DBY_MAX_LIVES       (2)
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
	dby_CurrentArena;

new
    PlayerText:dby_TdBack,
    PlayerText:dby_TdText,
	dby_Lives[MAX_PLAYERS],
	dby_PlayerVehicleID[MAX_PLAYERS],
	dby_PlayerVehicleModel[MAX_PLAYERS],
	dby_Spectating[MAX_PLAYERS],
	Iterator:dby_InGameIndex<MAX_PLAYERS>,
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

public OnFilterScriptInit()
{
	dby_LoadArenas();
	for(new i;i<MAX_PLAYERS;i++)
	{
		dby_Lives[i] = DBY_MAX_LIVES;
		dby_Spectating[i] = DBY_SPEC_NONE;
	}
}
public OnFilterScriptExit()
{
	for(new i;i<MAX_PLAYERS;i++)
	{
		UnloadTD(i);
		if(IsValidVehicle(dby_PlayerVehicleID[i]))DestroyVehicle(dby_PlayerVehicleID[i]);
	}
}

CMD:derby(playerid, params[])
{
	if(Iter_Contains(dby_InGameIndex, playerid))
	{
	    dby_Quit(playerid);
	}
	else
	{
		dby_Join(playerid);
	}
	return 1;
}

dby_Join(playerid)
{
    LoadTD(playerid);
	dby_FormatVehicleList(playerid);

    if(Iter_Contains(dby_SpawnedIndex, playerid))Iter_Remove(dby_SpawnedIndex, playerid);
	Iter_Add(dby_InGameIndex, playerid);
	
	dby_Lives[playerid] = DBY_MAX_LIVES;

	dby_Spectate(playerid);
    msgaF(YELLOW, " >  %P"#C_YELLOW" has gone to the "#C_BLUE"Destruction Derby "#C_YELLOW"minigame! Type "#C_ORANGE"/derby "#C_YELLOW"to join.", playerid);
}

timer dby_Spawn[5000](playerid)
{
	new spawn = random(dby_Data[dby_CurrentArena][dby_MaxSpawns]);

    Iter_Add(dby_SpawnedIndex, playerid);
	dby_Spectating[playerid] = DBY_SPEC_NONE;
	ExitCamera(playerid);

	TogglePlayerSpectating(playerid, false);
	TogglePlayerControllable(playerid, true);

	dby_PlayerVehicleID[playerid] = CreateVehicle(dby_PlayerVehicleModel[playerid],
		dby_Data[dby_CurrentArena][dby_SpawnX][spawn],
		dby_Data[dby_CurrentArena][dby_SpawnY][spawn],
		dby_Data[dby_CurrentArena][dby_SpawnZ][spawn] + DBY_SPAWN_ZOFFSET,
		dby_Data[dby_CurrentArena][dby_SpawnR][spawn], -1, -1, -1);

	SetVehicleParamsEx(dby_PlayerVehicleID[playerid], 1, 1, 0, 0, 0, 0, 0);
	PutPlayerInVehicle(playerid, dby_PlayerVehicleID[playerid], 0);

	PlayerTextDrawShow(playerid, dby_TdBack);
	PlayerTextDrawShow(playerid, dby_TdText);
	dby_UpdateTextDraw(playerid);
}
timer dby_OnPlayerVehicleDeath[6000](playerid)
{
	if(IsValidVehicle(dby_PlayerVehicleID[playerid]))DestroyVehicle(dby_PlayerVehicleID[playerid]);
	dby_Spectate(playerid);
	if(dby_Lives[playerid] > 0)defer dby_Spawn(playerid);
}


new
    Float:dby_PlayerVehicleHP[MAX_PLAYERS],
	curspec[MAX_PLAYERS];
CMD:setvhp(playerid, params[])
{
	SetVehicleHealth(GetPlayerVehicleID(playerid), floatstr(params));
	return 1;
}
public OnPlayerUpdate(playerid)
{
	if(dby_Spectating[playerid] != curspec[playerid])
	{
	    printf("SpecMode Change: OLD: %d NEW: %d", curspec[playerid], dby_Spectating[playerid]);
	    curspec[playerid] = dby_Spectating[playerid];
	}
	if(Iter_Contains(dby_SpawnedIndex, playerid) && Iter_Contains(dby_InGameIndex, playerid))
	{
		new
			iVehicle = GetPlayerVehicleID(playerid),
			Float:vhealth;

		GetVehicleHealth(dby_PlayerVehicleID[playerid], vhealth);
		
		if(vhealth < 250)dby_Out(playerid);

		if(!IsValidVehicle(iVehicle))
			PutPlayerInVehicle(playerid, dby_PlayerVehicleID[playerid], 0);

		if(vhealth != dby_PlayerVehicleHP[playerid])
		{
		    dby_PlayerVehicleHP[playerid] = vhealth;
			dby_OnPlayerVehicleHealthChange(playerid);
		}
	}
	return 1;
}
dby_OnPlayerVehicleHealthChange(playerid)
{
	new
	    str[64],
	    Float:x,
	    Float:y,
		Float:z,
		Float:ang,
		Float:vx,
		Float:vy,
		Float:vz,
		Float:direction,
		id;


	GetVehiclePos(dby_PlayerVehicleID[playerid], x, y, z);
	GetVehicleZAngle(dby_PlayerVehicleID[playerid], ang);
	GetVehicleVelocity(dby_PlayerVehicleID[playerid], vx, vy, vz);

	direction = 90-atan2(vy, vx);

	for(id = 0; id<MAX_PLAYERS; id++)
	{
	    if(id == playerid || !IsPlayerConnected(id))continue;

	    if(IsPlayerInRangeOfPoint(id, 10.0, x, y, z))
		{
		    new
		        Float:px, Float:py, Float:pz, Float:dirToPlayer, Float:offset;

			GetVehiclePos(dby_PlayerVehicleID[id], px, py, pz);
			dirToPlayer = GetAngleToPoint(x, y, px, py);
			offset = direction - dirToPlayer;
			if(offset < 0)offset = 360.0+offset;
			if(offset < 90 || offset > 270)
			{
				format(str, 64, "~n~~n~Damaged: %p~n~ang: %f", id, offset);
				GameTextForPlayer(playerid, str, 1000, 5);
				break;
			}
		}
	}

//	CallRemoteFunction("sffa_msgbox", "dsdd", playerid, str, 0, 150);
}


dby_Out(playerid)
{
	new
		winner,
		count;

	Iter_Remove(dby_SpawnedIndex, playerid);
	
	for(new i;i<MAX_PLAYERS;i++)
	{
	    if(!IsPlayerConnected(i) || playerid == i)continue;
	    if(dby_Spectating[i] == playerid)
	    {
		    print("SPEC RESET");
	        dby_Spectate(i);
	    }
	}

	if(IsValidVehicle(dby_PlayerVehicleID[playerid]))
	{
	    dby_Spectating[playerid] = DBY_SPEC_SELF;
	    TogglePlayerSpectating(playerid, true);
	    PlayerSpectateVehicle(playerid, dby_PlayerVehicleID[playerid]);
	    defer dby_OnPlayerVehicleDeath(playerid);
	}
	else
	{
	    print("SPEC BECAUSE OF NO VEHICLE");
		dby_Spectate(playerid);
	}

	if(dby_Lives[playerid] > 0)
	{
	    dby_Lives[playerid]--;
		dby_UpdateTextDraw(playerid);
	}

	for(new i;i<MAX_PLAYERS;i++)
	{
	    if(dby_Lives[i] > 0 && IsPlayerConnected(i) && Iter_Contains(dby_InGameIndex, i))
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
	return 1;
}

timer dby_Spectate[3000](playerid)
{
	if(dby_Spectating[playerid] != DBY_SPEC_NONE && dby_Spectating[playerid] != DBY_SPEC_SELF)return 0;

	if(Iter_Count(dby_SpawnedIndex) == 0)
	{
	    PlayCameraMover(playerid, dby_Data[dby_CurrentArena][dby_Camera], .loop = true);
	    dby_Spectating[playerid] = DBY_SPEC_ARENA;
	}
	else
	{
		new randomPlayer = Iter_Random(dby_SpawnedIndex);
		while(randomPlayer == playerid)randomPlayer = Iter_Random(dby_InGameIndex);

		TogglePlayerSpectating(playerid, true);
		PlayerSpectateVehicle(playerid, GetPlayerVehicleID(randomPlayer));
		dby_Spectating[playerid] = randomPlayer;
	}
	return 1;
}

dby_UpdateTextDraw(playerid)
{
	new str[11];
	format(str, 11, "Lives: %d", dby_Lives[playerid]);
	PlayerTextDrawSetString(playerid, dby_TdText, str);

	CallRemoteFunction("sffa_msgbox", "dsdd", playerid, str, 0, 100);

	PlayerTextDrawShow(playerid, dby_TdBack);
	PlayerTextDrawShow(playerid, dby_TdText);
}

dby_Quit(playerid)
{
	if(dby_Spectating[playerid] != DBY_SPEC_NONE)
	{
	    if(dby_Spectating[playerid] == DBY_SPEC_ARENA)ExitCamera(playerid);
	    TogglePlayerSpectating(playerid, false);
	    SpawnPlayer(playerid);
	}
	for(new i;i<MAX_PLAYERS;i++)
	{
	    if(!IsPlayerConnected(i))continue;
	    if(dby_Spectating[i] == playerid && playerid != i)
	    {
	        dby_Spectate(i);
	    }
	}
    UnloadTD(playerid);
	Iter_Remove(dby_InGameIndex, playerid);
	Iter_Remove(dby_SpawnedIndex, playerid);
	DestroyVehicle(dby_PlayerVehicleID[playerid]);

	PlayerTextDrawHide(playerid, dby_TdBack);
	PlayerTextDrawHide(playerid, dby_TdText);

    msgaF(YELLOW, " >  %P"#C_YELLOW" has left the "#C_BLUE"Destruction Derby "#C_YELLOW"minigame.", playerid);
    
    if(Iter_Count(dby_InGameIndex)==0)
		for(new i;i<MAX_PLAYERS;i++)dby_Lives[i] = DBY_MAX_LIVES;
    
	return 0;
}

dby_EndRound(winner = INVALID_PLAYER_ID)
{
	if(winner == INVALID_PLAYER_ID)msga(YELLOW, " >  "#C_ORANGE"Nobody "#C_YELLOW"won the "#C_BLUE"Destruction Derby "#C_YELLOW"minigame.");
	else
	{
	    Iter_Remove(dby_SpawnedIndex, winner);
		msgaF(YELLOW, " >  %P "#C_YELLOW"won the "#C_BLUE"Destruction Derby "#C_YELLOW"minigame.", winner);
		defer dby_Spectate(winner);
	}
	defer dby_NextRound();
}
timer dby_NextRound[10000]()
{
	foreach(new i : dby_InGameIndex)
	{
	    dby_Lives[i] = DBY_MAX_LIVES;
	    if(IsValidVehicle(dby_PlayerVehicleID[i]))DestroyVehicle(dby_PlayerVehicleID[i]);
	    dby_Spawn(i);
	}
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
	ShowPlayerDialog(playerid, 4090, DIALOG_STYLE_LIST, "Choose a vehicle", list, "Accept", "Cancel");
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == 4090 && response)
	{
	    dby_PlayerVehicleModel[playerid] = dby_Vehicles[listitem];
		dby_Spawn(playerid);
	}
}

dby_LoadArenas()
{
	new
	    File:idxFile,
	    File:dataFile,
	    line[128],
	    data[128],
		str[42],
		spawnIdx,
		idx;

	if(!fexist(DBY_INDEX_FILE))return print("ERROR: Destruction Derby Arena Index Not Found");
	
	idxFile = fopen(DBY_INDEX_FILE, io_read);

	while(fread(idxFile, line))
	{

	    line[strlen(line)-2] = EOS;
		strcat(dby_Data[idx][dby_Name], line);

		format(str, 42, DBY_DATA_FILE, line);

		if(!fexist(str))
		{
		    printf("ERROR: Arena data file '%s' not found", str);
		    continue;
		}

		dataFile = fopen(str, io_read);

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
		dby_Data[idx][dby_Camera] = LoadCameraMover(str);

		fclose(dataFile);
	    idx++;
	}
	fclose(idxFile);
	return 1;
}

LoadTD(playerid)
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
}
UnloadTD(playerid)
{
    PlayerTextDrawDestroy(playerid, dby_TdBack);
    PlayerTextDrawDestroy(playerid, dby_TdText);
}
