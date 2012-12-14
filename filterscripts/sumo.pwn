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


#define SMO_INDEX_FILE		"Sumo/index.ini"
#define SMO_DATA_FILE		"Sumo/%s.dat"
#define SMO_CAM_FILE		"smocam.%s"
#define SMO_MAX_ARENA		(16)
#define SMO_MAX_NAME		(32)
#define SMO_MAX_SPAWN		(8)
#define SMO_SPAWN_ZOFFSET	(5.0)


/*
-1806.6021, 524.8585, 234.5228, 358.9887
-1838.4102, 577.2176, 234.5191, 239.4176
-1775.0050, 576.7027, 234.5227, 117.7486
*/

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
	smo_CurrentArena;

new
    PlayerText:smo_TdBack,
    PlayerText:smo_TdText,
	smo_TimesFallen[MAX_PLAYERS],
	smo_PlayerVehicleID[MAX_PLAYERS],
	smo_PlayerVehicleModel[MAX_PLAYERS],
	smo_Spectating[MAX_PLAYERS],
	Iterator:smo_InGameIndex<MAX_PLAYERS>,
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
		556,
		572
	};

public OnFilterScriptInit()
{
	smo_LoadArenas();
	for(new i;i<MAX_PLAYERS;i++)smo_TimesFallen[i] = 0;
}
public OnFilterScriptExit()
{
	for(new i;i<MAX_PLAYERS;i++)
	{
		UnloadTD(i);
		if(IsValidVehicle(smo_PlayerVehicleID[i]))DestroyVehicle(smo_PlayerVehicleID[i]);
	}
}

CMD:sumo(playerid, params[])
{
	if(Iter_Contains(smo_InGameIndex, playerid))
	{
	    smo_Quit(playerid);
	}
	else
	{
		smo_Join(playerid);
	}
	return 1;
}

smo_Join(playerid)
{
    LoadTD(playerid);
	smo_FormatVehicleList(playerid);

    if(Iter_Contains(smo_SpawnedIndex, playerid))Iter_Remove(smo_SpawnedIndex, playerid);
	Iter_Add(smo_InGameIndex, playerid);

	smo_Spectate(playerid);
    msgaF(YELLOW, " >  %P"#C_YELLOW" has gone to the "#C_BLUE"Sumo "#C_YELLOW"minigame! Type "#C_ORANGE"/sumo "#C_YELLOW"to join.", playerid);
}

timer smo_Spawn[5000](playerid)
{
	new spawn = random(3);
	
    Iter_Add(smo_SpawnedIndex, playerid);
	smo_Spectating[playerid] = -1;
	ExitCamera(playerid);

	TogglePlayerSpectating(playerid, false);
	TogglePlayerControllable(playerid, true);

	smo_PlayerVehicleID[playerid] = CreateVehicle(smo_PlayerVehicleModel[playerid],
		smo_Data[smo_CurrentArena][smo_SpawnX][spawn],
		smo_Data[smo_CurrentArena][smo_SpawnY][spawn],
		smo_Data[smo_CurrentArena][smo_SpawnZ][spawn] + SMO_SPAWN_ZOFFSET,
		smo_Data[smo_CurrentArena][smo_SpawnR][spawn], -1, -1, -1);

	SetVehicleParamsEx(smo_PlayerVehicleID[playerid], 1, 1, 0, 0, 0, 0, 0);
	PutPlayerInVehicle(playerid, smo_PlayerVehicleID[playerid], 0);

	PlayerTextDrawShow(playerid, smo_TdBack);
	PlayerTextDrawShow(playerid, smo_TdText);
}
new
    Float:smo_PlayerVehicleHP[MAX_PLAYERS];

public OnPlayerUpdate(playerid)
{
	if(Iter_Contains(smo_SpawnedIndex, playerid) && Iter_Contains(smo_InGameIndex, playerid))
	{
		new
		    Float:z,
			iVehicle = GetPlayerVehicleID(playerid),
			Float:vhealth;

		GetPlayerPos(playerid, z, z, z);
		GetVehicleHealth(smo_PlayerVehicleID[playerid], vhealth);
		if(z < smo_Data[smo_CurrentArena][smo_Base])smo_Out(playerid);

		if(!IsValidVehicle(iVehicle))PutPlayerInVehicle(playerid, smo_PlayerVehicleID[playerid], 0);
		if(vhealth != smo_PlayerVehicleHP[playerid])
		{
		    smo_PlayerVehicleHP[playerid] = vhealth;
			smo_OnPlayerVehicleHealthChange(playerid);
		}
	}
	return 1;
}
smo_OnPlayerVehicleHealthChange(playerid)
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
		Float:speed,
		Float:direction,
		id;


	GetVehiclePos(smo_PlayerVehicleID[playerid], x, y, z);
	GetVehicleZAngle(smo_PlayerVehicleID[playerid], ang);
	GetVehicleVelocity(smo_PlayerVehicleID[playerid], vx, vy, vz);

	direction = 90-atan2(vy, vx);
    speed = (floatpower(((vx * vx) + (vy * vy) + (vz * vz)), 0.5) * (50.0 * 3.6));

	for(id = 0; id<MAX_PLAYERS; id++)
	{
	    if(id == playerid || !IsPlayerConnected(id))continue;

	    if(IsPlayerInRangeOfPoint(id, 10.0, x, y, z))
		{
		    new
		        Float:px, Float:py, Float:pz, Float:dirToPlayer, Float:offset;

			GetVehiclePos(smo_PlayerVehicleID[id], px, py, pz);
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


smo_Out(playerid)
{
	Iter_Remove(smo_SpawnedIndex, playerid);
    smo_TimesFallen[playerid]++;
	smo_UpdateTextDraw(playerid);
	
	for(new i;i<MAX_PLAYERS;i++)
	{
	    if(!IsPlayerConnected(i))continue;
	    if(smo_Spectating[i] == playerid && playerid != i)
	    {
	        smo_Spectate(i);
	    }
	}

	smo_Spectate(playerid);
	DestroyVehicle(smo_PlayerVehicleID[playerid]);
	defer smo_Spawn(playerid);
	return 1;
}

smo_Spectate(playerid)
{
	if(Iter_Count(smo_SpawnedIndex) == 0)
	{
	    PlayCameraMover(playerid, smo_Data[smo_CurrentArena][smo_Camera], .loop = true);
	    smo_Spectating[playerid] = -2;
	}
	else
	{
		new randomPlayer = Iter_Random(smo_SpawnedIndex);
		while(randomPlayer == playerid)randomPlayer = Iter_Random(smo_InGameIndex);

		TogglePlayerSpectating(playerid, true);
		PlayerSpectateVehicle(playerid, GetPlayerVehicleID(randomPlayer));
		smo_Spectating[playerid] = randomPlayer;
	}
}

smo_UpdateTextDraw(playerid)
{
	new str[11];
	format(str, 11, "Falls: %d", smo_TimesFallen[playerid]);
	PlayerTextDrawSetString(playerid, smo_TdText, str);

	PlayerTextDrawShow(playerid, smo_TdBack);
	PlayerTextDrawShow(playerid, smo_TdText);
}

smo_Quit(playerid)
{
	if(smo_Spectating[playerid] != -1)
	{
	    TogglePlayerSpectating(playerid, false);
	    SpawnPlayer(playerid);
	}
	for(new i;i<MAX_PLAYERS;i++)
	{
	    if(!IsPlayerConnected(i))continue;
	    if(smo_Spectating[i] == playerid && playerid != i)
	    {
	        smo_Spectate(i);
	    }
	}
    UnloadTD(playerid);
	Iter_Remove(smo_InGameIndex, playerid);
	Iter_Remove(smo_SpawnedIndex, playerid);
	DestroyVehicle(smo_PlayerVehicleID[playerid]);


	PlayerTextDrawHide(playerid, smo_TdBack);
	PlayerTextDrawHide(playerid, smo_TdText);

    msgaF(YELLOW, " >  %P"#C_YELLOW" has left the "#C_BLUE"/sumo "#C_YELLOW"minigame.", playerid);
    
    if(Iter_Count(smo_InGameIndex)==0)
    {
        for(new i;i<MAX_PLAYERS;i++)smo_TimesFallen[i] = 0;
    }
    
	return 0;
}

smo_FormatVehicleList(playerid)
{
	new
		list[256];

	for(new i;i<sizeof(smo_Vehicles);i++)
	{
	    strcat(list, VehicleNames[smo_Vehicles[i]-400]);
	    strcat(list, "\n");
	}
	ShowPlayerDialog(playerid, 4090, DIALOG_STYLE_LIST, "Choose a vehicle", list, "Accept", "Cancel");
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == 4090 && response)
	{
	    smo_PlayerVehicleModel[playerid] = smo_Vehicles[listitem];
		smo_Spawn(playerid);
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
	    line[strlen(line)-2] = EOS;

	    if(sscanf(line, "p<=>s[32]f", smo_Data[idx][smo_Name], smo_Data[idx][smo_Base]))print("ERROR: Arena Data Corrupted");

		format(str, 42, SMO_DATA_FILE, smo_Data[idx][smo_Name]);

		if(!fexist(str))
		{
		    printf("ERROR: Arena data file '%s' not found", str);
		    continue;
		}

		dataFile = fopen(str, io_read);

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
		smo_Data[idx][smo_MaxSpawns] = spawnIdx+1;
		smo_Data[idx][smo_Camera] = LoadCameraMover(str);

		fclose(dataFile);
	    idx++;
	}
	return 1;
}

LoadTD(playerid)
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
}
UnloadTD(playerid)
{
    PlayerTextDrawDestroy(playerid, smo_TdBack);
    PlayerTextDrawDestroy(playerid, smo_TdText);
}
