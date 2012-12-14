#include <a_samp>
#include <foreach>
#include <formatex>
#include <zcmd>
#include <streamer>
#include <colours>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16

#define MAX_DGW_SIZE		(8)
#define MODEL_ID			(3374)
#define DGW_DEFAULTSIZE		(8)
#define DGW_START_DELAY     (10000)
#define DGW_UPDATE_INTERVAL (1000)
#define DGW_COUNTDOWN       (5)

#define DGW_ORIGIN_X		(500.0)
#define DGW_ORIGIN_Y		(-2600.0)
#define DGW_ORIGIN_Z		(10.0)

#define DGW_OFFSET_X		(4.0)
#define DGW_OFFSET_Y		(4.0)
#define DGW_CAM_OFFSET		(10.0)
#define DGW_CAM_TIME		(20000)

//	CallRemoteFunction("sffa_msgbox", "dsdd", 0, "update", 1000, 100);


new
	dgw_gridObj[MAX_DGW_SIZE][MAX_DGW_SIZE],
	dgw_gridSize,
	dgw_arenaArea,
	dgw_quitArea,
//	Iterator:dgw_PlayerTable<MAX_PLAYERS>,
	bool:dgw_InGame[MAX_PLAYERS],
	bool:dgw_Alive[MAX_PLAYERS],
	bool:dgw_Spectating[MAX_PLAYERS],
	dgw_State,
	dgw_spawnCounter,
	dgw_CountDownStarted,
	dgw_SpectateTimer[MAX_PLAYERS],
	dgw_SpawnTimer,
	dgw_UpdateTimer,
	dgw_spawnTick[MAX_PLAYERS];

forward dgw_SpawnCount();
forward dgw_Spectate(playerid, corner);
forward dgw_Update();

public OnFilterScriptInit()
{
	return 1;
}
public OnFilterScriptExit()
{
	return 1;
}

CMD:npcdgw(playerid, params[])
{
	cmd_dgw(1, "");
	return 1;
}

CMD:dgw(playerid, params[])
{
	if(dgw_InGame[playerid])dgw_Quit(playerid);
	else
	{
	    new str[128];
		format(str, 128, " >  %P"#C_YELLOW" has joined the "#C_BLUE"Don't Get Wet"#C_YELLOW" minigame! Type "#C_ORANGE"/dgw"#C_YELLOW" to join.", playerid);
		SendClientMessageToAll(ORANGE, str);
        dgw_Spectating[playerid] = false;
		dgw_Join(playerid);
	}
	return 1;
}


dgw_Join(playerid)
{
	new iCount;

	dgw_InGame[playerid] = true;
	dgw_Alive[playerid] = false;

	for(new i;i<MAX_PLAYERS;i++)if(dgw_InGame[i])iCount++;

	if(dgw_State == 0 || iCount == 1)
	{
		dgw_BuildArena(DGW_DEFAULTSIZE);
		if(!dgw_Spectating[playerid])dgw_Spectate(playerid, 0);
	}
	else if(dgw_State == 1 && !dgw_Spectating[playerid])dgw_Spectate(playerid, 0);
	else if(dgw_State == 2)
	{
		if(dgw_Spawn(playerid))return 1;
	}

	if(iCount > 1 && !dgw_CountDownStarted)
	{
	    dgw_spawnCounter = DGW_COUNTDOWN;
		dgw_SpawnTimer = SetTimer("dgw_SpawnCount", 1000, true);
		dgw_CountDownStarted = true;
	}
	return 0;
}
dgw_Quit(playerid, respawn = true)
{
	new str[128];
	format(str, 128, " >  %P"#C_ORANGE" has left the "#C_BLUE"/dgw"#C_ORANGE" minigame!", playerid);
	SendClientMessageToAll(ORANGE, str);

	dgw_InGame[playerid] = false;
	if(respawn)SpawnPlayer(playerid);
	SetCameraBehindPlayer(playerid);
	TogglePlayerControllable(playerid, true);
    KillTimer(dgw_SpectateTimer[playerid]);
    dgw_Spectating[playerid] = false;

	if(dgw_GetPlayersInGame()<2 && dgw_State != 0)dgw_StopGame();
}
public dgw_SpawnCount()
{
	if(dgw_State!=1)KillTimer(dgw_SpawnTimer);
    for(new x;x<dgw_gridSize;x++)for(new y;y<dgw_gridSize;y++)if(IsDynamicObjectMoving(dgw_gridObj[x][y]))return 1;

	if(dgw_spawnCounter == 0)
	{
		dgw_State = 2;
		KillTimer(dgw_SpawnTimer);
		dgw_UpdateTimer = SetTimer("dgw_Update", DGW_START_DELAY, false);
		for(new i;i<MAX_PLAYERS;i++)
		{
			if(dgw_InGame[i])
			{
			    GameTextForPlayer(i, "GO!", 1000, 5);
			    dgw_Spawn(i);
			}
		}
		return 1;
	}
	else
	{
		new
			tmpStr[3];

		valstr(tmpStr, dgw_spawnCounter);
		for(new i;i<MAX_PLAYERS;i++)if(dgw_InGame[i])GameTextForPlayer(i, tmpStr, 1000, 5);
	}

	dgw_spawnCounter--;
	return 0;
}
public dgw_Spectate(playerid, corner)
{
	if(dgw_Alive[playerid] || !dgw_State)return 0;
	SetPlayerPos(playerid, DGW_ORIGIN_X-10, DGW_ORIGIN_Y-10, 0.0);
	TogglePlayerControllable(playerid, false);
	if(corner == -1)
	{
	    new
			Float:cam_pX, Float:cam_pY, Float:cam_pZ,
			Float:cam_lX, Float:cam_lY, Float:cam_lZ;

		GetPlayerCameraPos(playerid, cam_pX, cam_pY, cam_pZ);
		GetPlayerPos(playerid, cam_lX, cam_lY, cam_lZ);

		InterpolateCameraPos(playerid,
			cam_pX, cam_pY, cam_pZ,
			DGW_ORIGIN_X-DGW_CAM_OFFSET, DGW_ORIGIN_Y-DGW_CAM_OFFSET, DGW_ORIGIN_Z+(DGW_CAM_OFFSET/2),
			DGW_CAM_TIME, CAMERA_MOVE);

		InterpolateCameraLookAt(playerid,
			cam_lX, cam_lY, cam_lZ,
			DGW_ORIGIN_X+(DGW_OFFSET_X), DGW_ORIGIN_Y+(DGW_OFFSET_Y), DGW_ORIGIN_Z,
			DGW_CAM_TIME, CAMERA_MOVE);

		dgw_SpectateTimer[playerid] = SetTimerEx("dgw_Spectate", 500, false, "dd", playerid, 0);
	}
	if(corner == 0) // Moving along the X +
	{
		InterpolateCameraPos(playerid,
			DGW_ORIGIN_X-DGW_CAM_OFFSET, DGW_ORIGIN_Y-DGW_CAM_OFFSET, DGW_ORIGIN_Z+(DGW_CAM_OFFSET/2),
			DGW_ORIGIN_X+((dgw_gridSize-1)*DGW_OFFSET_X)+DGW_CAM_OFFSET, DGW_ORIGIN_Y-DGW_CAM_OFFSET, DGW_ORIGIN_Z+(DGW_CAM_OFFSET/2),
			DGW_CAM_TIME, CAMERA_MOVE);

		InterpolateCameraLookAt(playerid,
			DGW_ORIGIN_X+(DGW_OFFSET_X), DGW_ORIGIN_Y+(DGW_OFFSET_Y), DGW_ORIGIN_Z,
			DGW_ORIGIN_X+((dgw_gridSize-2)*DGW_OFFSET_X), DGW_ORIGIN_Y+(DGW_OFFSET_Y), DGW_ORIGIN_Z,
			DGW_CAM_TIME, CAMERA_MOVE);

		dgw_SpectateTimer[playerid] = SetTimerEx("dgw_Spectate", DGW_CAM_TIME, false, "dd", playerid, corner+1);
	}
	if(corner == 1) // Moving along the Y +
	{
		InterpolateCameraPos(playerid,
			DGW_ORIGIN_X+((dgw_gridSize-1)*DGW_OFFSET_X)+DGW_CAM_OFFSET, DGW_ORIGIN_Y-DGW_CAM_OFFSET, DGW_ORIGIN_Z+(DGW_CAM_OFFSET/2),
			DGW_ORIGIN_X+((dgw_gridSize-1)*DGW_OFFSET_X)+DGW_CAM_OFFSET, DGW_ORIGIN_Y+((dgw_gridSize-1)*DGW_OFFSET_Y)+DGW_CAM_OFFSET, DGW_ORIGIN_Z+(DGW_CAM_OFFSET/2),
			DGW_CAM_TIME, CAMERA_MOVE);

		InterpolateCameraLookAt(playerid,
			DGW_ORIGIN_X+((dgw_gridSize-2)*DGW_OFFSET_X), DGW_ORIGIN_Y+(DGW_OFFSET_Y), DGW_ORIGIN_Z,
			DGW_ORIGIN_X+((dgw_gridSize-2)*DGW_OFFSET_X), DGW_ORIGIN_Y+((dgw_gridSize-2)*DGW_OFFSET_Y), DGW_ORIGIN_Z,
			DGW_CAM_TIME, CAMERA_MOVE);

		dgw_SpectateTimer[playerid] = SetTimerEx("dgw_Spectate", DGW_CAM_TIME, false, "dd", playerid, corner+1);
	}
	if(corner == 2) // Moving along the X -
	{
		InterpolateCameraPos(playerid,
			DGW_ORIGIN_X+((dgw_gridSize-1)*DGW_OFFSET_X)+DGW_CAM_OFFSET, DGW_ORIGIN_Y+((dgw_gridSize-1)*DGW_OFFSET_Y)+DGW_CAM_OFFSET, DGW_ORIGIN_Z+(DGW_CAM_OFFSET/2),
			DGW_ORIGIN_X-DGW_OFFSET_X, DGW_ORIGIN_Y+((dgw_gridSize-1)*DGW_OFFSET_Y)+DGW_CAM_OFFSET, DGW_ORIGIN_Z+(DGW_CAM_OFFSET/2),
			DGW_CAM_TIME, CAMERA_MOVE);

		InterpolateCameraLookAt(playerid,
			DGW_ORIGIN_X+((dgw_gridSize-2)*DGW_OFFSET_X), DGW_ORIGIN_Y+((dgw_gridSize-2)*DGW_OFFSET_Y), DGW_ORIGIN_Z,
			DGW_ORIGIN_X+DGW_OFFSET_X, DGW_ORIGIN_Y+((dgw_gridSize-1)*DGW_OFFSET_Y)-DGW_OFFSET_Y, DGW_ORIGIN_Z,
			DGW_CAM_TIME, CAMERA_MOVE);

		dgw_SpectateTimer[playerid] = SetTimerEx("dgw_Spectate", DGW_CAM_TIME, false, "dd", playerid, corner+1);
	}
	if(corner == 3) // Moving along the Y -
	{
		InterpolateCameraPos(playerid,
			DGW_ORIGIN_X-DGW_OFFSET_X, DGW_ORIGIN_Y+((dgw_gridSize-1)*DGW_OFFSET_Y)+DGW_CAM_OFFSET, DGW_ORIGIN_Z+(DGW_CAM_OFFSET/2),
			DGW_ORIGIN_X-DGW_CAM_OFFSET, DGW_ORIGIN_Y-DGW_CAM_OFFSET, DGW_ORIGIN_Z+(DGW_CAM_OFFSET/2),
			DGW_CAM_TIME, CAMERA_MOVE);

		InterpolateCameraLookAt(playerid,
			DGW_ORIGIN_X+DGW_OFFSET_X, DGW_ORIGIN_Y+((dgw_gridSize-1)*DGW_OFFSET_Y)-DGW_OFFSET_Y, DGW_ORIGIN_Z,
			DGW_ORIGIN_X+(DGW_OFFSET_X), DGW_ORIGIN_Y+(DGW_OFFSET_Y), DGW_ORIGIN_Z,
			DGW_CAM_TIME, CAMERA_MOVE);

		dgw_SpectateTimer[playerid] = SetTimerEx("dgw_Spectate", DGW_CAM_TIME, false, "dd", playerid, 0);
	}
	return 1;
}

public OnPlayerUpdate(playerid)
{
	if(dgw_State == 2 && dgw_InGame[playerid] && dgw_Alive[playerid] && GetTickCount()-dgw_spawnTick[playerid] > 1000)
	{
		new Float:z;
		GetPlayerPos(playerid, z, z, z);
		if(z < 1.0 || z > 13.4)dgw_Out(playerid);
	}
	return 1;
}
public OnPlayerLeaveDynamicArea(playerid, areaid)
{
	if(areaid == dgw_arenaArea && dgw_InGame[playerid])
	{
		if(dgw_State==1)dgw_Quit(playerid, false);
		if(dgw_State==2)
		{
		    if(IsPlayerInDynamicArea(playerid, dgw_quitArea))dgw_Out(playerid);
		    else dgw_Quit(playerid, false);
		}
	}
}
public OnPlayerDisconnect(playerid, reason)
{
	dgw_Quit(playerid, false);
	return 1;
}
public OnPlayerDeath(playerid, killerid, reason)
{
	dgw_Quit(playerid, false);
	return 1;
}

dgw_BuildArena(size)
{
    new
		bStyle_XY = random(5),
		bStyle_Z = random(5),
		bStyle_rotXYZ = random(5),
        Float:tmpX,
        Float:tmpY,
        Float:tmpZ,
		Float:tmp_rotX,
        Float:tmp_rotY,
		Float:tmp_rotZ;

    dgw_State = 1;
    dgw_gridSize = size;
    
	dgw_arenaArea = CreateDynamicRectangle(
		DGW_ORIGIN_X-(DGW_OFFSET_X/2), DGW_ORIGIN_Y-(DGW_OFFSET_Y/2),
		DGW_ORIGIN_X+((dgw_gridSize-1)*DGW_OFFSET_X)+(DGW_OFFSET_X/2), DGW_ORIGIN_Y+((dgw_gridSize-1)*DGW_OFFSET_Y)+(DGW_OFFSET_Y/2) );

    dgw_quitArea = CreateDynamicRectangle(
		DGW_ORIGIN_X-(DGW_OFFSET_X*2), DGW_ORIGIN_Y-(DGW_OFFSET_Y*2),
		DGW_ORIGIN_X+((dgw_gridSize-1)*DGW_OFFSET_X)+(DGW_OFFSET_X*2), DGW_ORIGIN_Y+((dgw_gridSize-1)*DGW_OFFSET_Y)+(DGW_OFFSET_Y*2) );

	for(new x;x<size;x++)
	{
		for(new y;y<size;y++)
		{
		    switch(bStyle_XY)
		    {
		        case 0:tmpX = DGW_ORIGIN_X, tmpY = DGW_ORIGIN_Y;
		        case 1:tmpX = DGW_ORIGIN_X+((dgw_gridSize/2)*DGW_OFFSET_X), tmpY = DGW_ORIGIN_Y+((dgw_gridSize/2)*DGW_OFFSET_X);
		        case 2:tmpX = DGW_ORIGIN_X+((dgw_gridSize/(random(4)+1))*DGW_OFFSET_X), tmpY = DGW_ORIGIN_Y+((dgw_gridSize/(random(4)+1))*DGW_OFFSET_X);
		        case 3:tmpX = DGW_ORIGIN_X+(random(dgw_gridSize)*DGW_OFFSET_X), tmpY = DGW_ORIGIN_Y+(random(dgw_gridSize)*DGW_OFFSET_Y);
				default:tmpX = DGW_ORIGIN_X+(x*DGW_OFFSET_X), tmpY = DGW_ORIGIN_Y+(y*DGW_OFFSET_Y);
		    }
		    switch(bStyle_Z)
		    {
		        case 0:tmpZ = 0.5*x*y;
		        case 1:tmpZ = tmpZ = x*1.0-y*1.0;
		        case 2:tmpZ = (x+y)+(y+x);
		        case 3:tmpZ = (x*y)+x-y;
		        
		        default:tmpZ = 0.0;
		    }
		    switch(bStyle_rotXYZ)
		    {
		        case 0:tmp_rotY = (180.0/dgw_gridSize)*x, tmp_rotZ = (180.0/dgw_gridSize)*y;
		        case 1:tmp_rotY = (180.0/dgw_gridSize)*(x*8), tmp_rotZ = 180.0;
		        case 2:tmp_rotY = x*90.0*y, tmp_rotZ = 0.0;
		        case 3:tmp_rotX = x*90.0*y, tmp_rotY = y*90*x;
		        default:tmp_rotY = 0.0, tmp_rotZ = 0.0;
		    }
		    if(IsValidDynamicObject(dgw_gridObj[x][y]))DestroyDynamicObject(dgw_gridObj[x][y]);
			dgw_gridObj[x][y] = CreateDynamicObject(MODEL_ID, tmpX, tmpY, tmpZ, tmp_rotX, tmp_rotY, tmp_rotZ);
	    	MoveDynamicObject(dgw_gridObj[x][y], DGW_ORIGIN_X+(x*DGW_OFFSET_X), DGW_ORIGIN_Y+(y*DGW_OFFSET_Y), DGW_ORIGIN_Z, 20.0, 0.0, 0.0, 0.0);
		}
	}
}
dgw_DestroyArena()
{
	DestroyDynamicArea(dgw_arenaArea);
	for(new x;x<dgw_gridSize;x++)
	{
		for(new y;y<dgw_gridSize;y++)
		{
		    DestroyDynamicObject(dgw_gridObj[x][y]);
		}
	}
}
dgw_Spawn(playerid)
{
	new
	    obj,
		tmpX = random(dgw_gridSize),
		tmpY = random(dgw_gridSize);

    for(new x;x<dgw_gridSize;x++)for(new y;y<dgw_gridSize;y++)if(IsValidDynamicObject(dgw_gridObj[x][y]))obj++;
	if(obj < 8)return 0;

	while(!IsValidDynamicObject(dgw_gridObj[tmpX][tmpY]))
	{
		tmpX = random(dgw_gridSize), tmpY = random(dgw_gridSize);
	}

	SetPlayerPos(playerid,
		DGW_ORIGIN_X+(tmpX*DGW_OFFSET_X),
		DGW_ORIGIN_Y+(tmpY*DGW_OFFSET_Y),
		DGW_ORIGIN_Z+1.0);

    dgw_Alive[playerid]			= true;
	dgw_Spectating[playerid]	= false;
    dgw_spawnTick[playerid]     = GetTickCount();

	ResetPlayerWeapons(playerid);
	GivePlayerWeapon(playerid, 33, 128);

    TogglePlayerControllable(playerid, true);
	SetCameraBehindPlayer(playerid);
	KillTimer(dgw_SpectateTimer[playerid]);
	return 1;
}
dgw_Out(playerid)
{
	new
		iLoop,
		winner = -1,
		str[128];

    dgw_Alive[playerid] = false;
	if(!dgw_Spectating[playerid])dgw_Spectate(playerid, 0);
    for(new i;i<MAX_PLAYERS;i++)
	{
	    if(dgw_InGame[i])
	    {
	        format(str, 128, " >  %P"#C_YELLOW" has fallen out of the game! %d players remain!", playerid, dgw_GetPlayersInGame());
	        SendClientMessage(i, YELLOW, str);

			if(dgw_Alive[i])
			{
			    winner = i;
				iLoop++;
			}
	    }
		if(i==MAX_PLAYERS-1)
		{
			if(iLoop==1)
			{
			    new Float:z;

			    GetPlayerPos(winner, z, z, z);

			    if(z < 10)dgw_EndGame();
			    else dgw_EndGame(winner);
			}
			if(iLoop==0)dgw_EndGame();
		}
	}
}
dgw_EndGame(winner=INVALID_PLAYER_ID)
{
    new tmpStr[128];

	if(winner!=INVALID_PLAYER_ID)
	{
		format(tmpStr, 128, " >  Game Over! Winner: %P", winner);
		SendClientMessage(winner, GREEN, " >  You won "#C_YELLOW"$50"#C_GREEN"!");
		GivePlayerMoney(winner, 50);
	}
	else tmpStr = " >  Game Over! Winner: Nobody.";

	KillTimer(dgw_UpdateTimer);
    dgw_BuildArena(8);
	dgw_CountDownStarted = false;
    for(new i;i<MAX_PLAYERS;i++)if(dgw_InGame[i])
	{
		SendClientMessage(i, 0xFFFF00FF, tmpStr);
		dgw_Join(i);
	}
	return 1;
}
dgw_StopGame()
{
    for(new i;i<MAX_PLAYERS;i++)if(dgw_InGame[i])dgw_Quit(i);
	KillTimer(dgw_UpdateTimer);
	KillTimer(dgw_SpawnTimer);
	dgw_DestroyArena();
	dgw_State = 0;
}

dgw_GetPlayersInGame()
{
	new count;
	for(new i;i<MAX_PLAYERS;i++)if(dgw_Alive[i])count++;
	return count;
}
