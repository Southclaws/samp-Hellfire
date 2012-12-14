#include <YSI\y_hooks>

#define MAX_DGW_SIZE		(8)
#define DGW_DEFAULTSIZE		(8)
#define DGW_START_DELAY     (10000)
#define DGW_UPDATE_INTERVAL (1000)
#define DGW_COUNTDOWN       (5)
#define DGW_CAM_OFFSET		(10.0)
#define DGW_CAM_TIME		(20000)

#define DGW_ORIGIN_X		(500.0)
#define DGW_ORIGIN_Y		(-2600.0)
#define DGW_ORIGIN_Z		(10.0)

#define MODEL_ID1			(3095)
#define MODEL_ID2			(3374)
#define DGW1_OFFSET_X		(9.0)
#define DGW2_OFFSET_X		(4.0)
#define DGW1_OFFSET_Y		(9.0)
#define DGW2_OFFSET_Y		(4.0)

#define DGW_TYPE_AUTO		(0)
#define DGW_TYPE_WEAP		(1)

#define DGW_STATE_INACTIVE	(0)
#define DGW_STATE_STARTING  (1)
#define DGW_STATE_STARTED   (2)

new
	MODEL_ID,
	Float:DGW_OFFSET_X,
	Float:DGW_OFFSET_Y;

new
	dgw_gridObj[MAX_DGW_SIZE][MAX_DGW_SIZE],
	dgw_gridSize,
	dgw_arenaArea,
	dgw_quitArea,
	Iterator:dgw_SpawnedIndex<MAX_PLAYERS>,
	bool:dgw_Spectating[MAX_PLAYERS],
	dgw_Type,
	dgw_State,
	dgw_spawnCounter,
	dgw_CountDownStarted,
	dgw_SpectateTimer[MAX_PLAYERS],
	dgw_SpawnTimer,
	dgw_UpdateTimer,
	dgw_objCounter,
	dgw_spawnTick[MAX_PLAYERS];


forward dgw_SpawnCount();
forward dgw_Spectate(playerid, corner);
forward dgw_Update();


CMD:dgw(playerid, params[])
{
	if(gCurrentChallenge != CHALLENGE_NONE)
	{
	    Msg(playerid, YELLOW, " >  You can't start a minigame while a challenge is active.");
	    return 1;
	}
	if(gCurrentMinigame[playerid] == MINIGAME_FALLOUT)
	{
		dgw_Leave(playerid);
	}
	else if(gCurrentMinigame[playerid] == MINIGAME_NONE)
	{
	    if(dgw_State == DGW_STATE_INACTIVE)
	    {
			ShowPlayerDialog(playerid, d_DgwType, DIALOG_STYLE_MSGBOX, "Don't Get Wet Minigame",
				"Choose a game type below\n\
				"#C_YELLOW"Type 1: "#C_WHITE"Plates remove one by one automatically.\n\
				"#C_YELLOW"Type 2: "#C_WHITE"Players get weapons to shoot the plates under other PlayerSpectatePlayer.",
				"Type 1", "Type 2");
		}
	    else ShowPlayerDialog(playerid, d_DgwJoin, DIALOG_STYLE_MSGBOX, "Don't Get Wet Minigame", "Choose an option below", "Play", "Spectate");
	}
	else
	{
	    Msg(playerid, YELLOW, " >  Please exit your current minigame before joining another");
	}
	return 1;
}


dgw_Join(playerid, msg = true)
{
	new iCount;

	if(Iter_Contains(dgw_SpawnedIndex, playerid))Iter_Remove(dgw_SpawnedIndex, playerid);
	gCurrentMinigame[playerid] = MINIGAME_FALLOUT;
	SetPlayerVirtualWorld(playerid, MINIGAME_WORLD);

	iCount = dgw_GetPlayersInGame();
	dgw_Spectating[playerid] = false;
	KillTimer(dgw_SpectateTimer[playerid]);

	if(dgw_State == DGW_STATE_INACTIVE || iCount == 1)
	{
		dgw_BuildArena(DGW_DEFAULTSIZE);
		if(!dgw_Spectating[playerid])dgw_Spectate(playerid, 0);
	}
	else if(dgw_State == DGW_STATE_STARTING && !dgw_Spectating[playerid])dgw_Spectate(playerid, 0);
	else if(dgw_State == DGW_STATE_STARTED)
	{
		if(dgw_Spawn(playerid))return 1;
	}

	if(iCount > 1 && !dgw_CountDownStarted)
	{
	    dgw_spawnCounter = DGW_COUNTDOWN;
		dgw_SpawnTimer = SetTimer("dgw_SpawnCount", 1000, true);
		dgw_CountDownStarted = true;
	}

	if(msg)
	{
		PlayerLoop(i)if(IsPlayerInFreeRoam(i) || gCurrentMinigame[playerid] == MINIGAME_FALLOUT)
			MsgF(i, YELLOW, " >  %P"#C_YELLOW" has joined the "#C_BLUE"Don't Get Wet Type %d"#C_YELLOW" minigame! Type "#C_ORANGE"/dgw"#C_YELLOW" to join.", playerid, dgw_Type+1);
	}
	return 0;
}
dgw_Leave(playerid, msg = true, respawn = true)
{
	gCurrentMinigame[playerid] = MINIGAME_NONE;

	if(respawn)SpawnPlayer(playerid);
	f:bPlayerGameSettings[playerid]<GodMode>;
	SetCameraBehindPlayer(playerid);
	TogglePlayerControllable(playerid, true);
    KillTimer(dgw_SpectateTimer[playerid]);
    dgw_Spectating[playerid] = false;
    ResetSpectatorTarget(playerid);
	SetPlayerVirtualWorld(playerid, FREEROAM_WORLD);

    Iter_Remove(dgw_SpawnedIndex, playerid);

	if(dgw_GetPlayersInGame()<=1 && dgw_State != DGW_STATE_INACTIVE)dgw_StopGame();

	if(msg)
	{
		PlayerLoop(i)
		{
			if(IsPlayerInFreeRoam(i) || gCurrentMinigame[i] == MINIGAME_FALLOUT)
				MsgF(i, YELLOW, " >  %P"#C_YELLOW" has left the "#C_BLUE"/dgw"#C_YELLOW" minigame!", playerid);
		}
	}
}
public dgw_SpawnCount()
{
	if(dgw_State!=1)KillTimer(dgw_SpawnTimer);
    for(new x;x<dgw_gridSize;x++)for(new y;y<dgw_gridSize;y++)if(IsDynamicObjectMoving(dgw_gridObj[x][y]))return 1;

	if(dgw_spawnCounter == 0)
	{
		dgw_State = DGW_STATE_STARTED;
		dgw_objCounter = dgw_gridSize * dgw_gridSize;
		KillTimer(dgw_SpawnTimer);
		if(dgw_Type == DGW_TYPE_AUTO)dgw_UpdateTimer = SetTimer("dgw_Update", DGW_START_DELAY, false);
		PlayerLoop(i)
		{
			if(gCurrentMinigame[i] == MINIGAME_FALLOUT)
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

		PlayerLoop(i)
		{
			if(gCurrentMinigame[i] == MINIGAME_FALLOUT)
			{
				GameTextForPlayer(i, tmpStr, 1000, 5);
			}
		}
	}

	dgw_spawnCounter--;
	return 0;
}
public dgw_Spectate(playerid, corner)
{
	if(Iter_Contains(dgw_SpawnedIndex, playerid) || !dgw_State)return 0;
	dgw_Spectating[playerid] = true;
	SetPlayerPos(playerid, DGW_ORIGIN_X, DGW_ORIGIN_Y, 0.0);
	TogglePlayerControllable(playerid, false);
	SetPlayerVirtualWorld(playerid, MINIGAME_WORLD);
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

public dgw_Update()
{
	new
		obj,
		tmpX = random(dgw_gridSize),
		tmpY = random(dgw_gridSize);

	while(!IsValidDynamicObject(dgw_gridObj[tmpX][tmpY]))
	{
		tmpX = random(dgw_gridSize), tmpY = random(dgw_gridSize);
	}

	MoveDynamicObject(dgw_gridObj[tmpX][tmpY], DGW_ORIGIN_X+(tmpX*DGW_OFFSET_X), DGW_ORIGIN_Y+(tmpY*DGW_OFFSET_Y), DGW_ORIGIN_Z-1.0, 1.0);

    for(new x;x<dgw_gridSize;x++)for(new y;y<dgw_gridSize;y++)if(IsValidDynamicObject(dgw_gridObj[x][y]))obj++;
	if(obj > 0)dgw_UpdateTimer = SetTimer("dgw_Update", DGW_UPDATE_INTERVAL, false);

	return 1;
}

script_dgw_OnObjectMoved(objectid)
{
	if(dgw_State == DGW_STATE_STARTED)
	{
		for(new x;x<dgw_gridSize;x++)
		{
			for(new y;y<dgw_gridSize;y++)
			{
				if(objectid == dgw_gridObj[x][y])
				{
					DestroyDynamicObject(dgw_gridObj[x][y]);
					dgw_objCounter--;

					if(dgw_objCounter <= 0)return dgw_EndGame();

					return 1;
				}
			}
		}
	}
	return 1;
}

script_dgw_Update(playerid)
{
	if(Iter_Contains(dgw_SpawnedIndex, playerid))
	{
		if(dgw_State == DGW_STATE_STARTED && tickcount()-dgw_spawnTick[playerid] > 1000)
		{
			new Float:z;
			GetPlayerPos(playerid, z, z, z);
			if(z < 1.0 || z > 13.4)dgw_Out(playerid);
		}
	}
	return 1;
}
script_dgw_LeaveDynamicArea(playerid, areaid)
{
	if(areaid == dgw_arenaArea && Iter_Contains(dgw_SpawnedIndex, playerid) && gCurrentMinigame[playerid] == MINIGAME_FALLOUT)
	{
		if(dgw_State==DGW_STATE_STARTED)
		{
		    if(IsPlayerInDynamicArea(playerid, dgw_quitArea))dgw_Out(playerid);
		    else dgw_Leave(playerid, false);
		}
	}
}

dgw_BuildArena(size)
{
    new
		bStyle_XY = random(4),
		bStyle_Z = random(4),
		bStyle_rotXYZ = random(4),
        Float:tmpX,
        Float:tmpY,
        Float:tmpZ,
		Float:tmp_rotX,
        Float:tmp_rotY,
		Float:tmp_rotZ;

    dgw_State = DGW_STATE_STARTING;
    dgw_gridSize = size;
	if(dgw_Type == 0)
	{
		MODEL_ID		= MODEL_ID1,
		DGW_OFFSET_X	= DGW1_OFFSET_X,
		DGW_OFFSET_Y	= DGW1_OFFSET_Y;
	}
	else
	{
		MODEL_ID		= MODEL_ID2,
		DGW_OFFSET_X	= DGW2_OFFSET_X,
		DGW_OFFSET_Y	= DGW2_OFFSET_Y;
	}

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
			dgw_gridObj[x][y] = CreateDynamicObject(MODEL_ID, tmpX, tmpY, tmpZ, tmp_rotX, tmp_rotY, tmp_rotZ, MINIGAME_WORLD);
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

	SetPlayerVirtualWorld(playerid, MINIGAME_WORLD);
	ResetPlayerWeapons(playerid);
	if(dgw_Type == DGW_TYPE_WEAP)
	{
		GivePlayerWeapon(playerid, 33, 64);
		t:bPlayerGameSettings[playerid]<GodMode>;
	}

    Iter_Add(dgw_SpawnedIndex, playerid);
	dgw_Spectating[playerid]	= false;
    dgw_spawnTick[playerid]     = tickcount();

    TogglePlayerControllable(playerid, true);
	SetCameraBehindPlayer(playerid);
	KillTimer(dgw_SpectateTimer[playerid]);
	return 1;
}
dgw_Out(playerid)
{
	new
		iLoop,
		winner = -1;

    Iter_Remove(dgw_SpawnedIndex, playerid);
    ResetSpectatorTarget(playerid);
	if(!dgw_Spectating[playerid])dgw_Spectate(playerid, 0);
	PlayerLoop(i)
	{
	    if(gCurrentMinigame[i] == MINIGAME_FALLOUT)
	    {
	        MsgF(i, YELLOW, " >  %P"#C_YELLOW" has fallen out of the game! %d players remain!", playerid, Iter_Count(dgw_SpawnedIndex));

			if(Iter_Contains(dgw_SpawnedIndex, i))
			{
			    winner = i;
				iLoop++;
			}
	    }
	}
	if(iLoop==1)
	{
	    new Float:z;

	    GetPlayerPos(winner, z, z, z);

	    if(z < 10)dgw_EndGame();
	    else dgw_EndGame(winner);
	}
	if(iLoop==0)dgw_EndGame();
}
dgw_EndGame(winner=INVALID_PLAYER_ID)
{
	new tmpStr[64];
	if(winner!=INVALID_PLAYER_ID)
	{
	    format(tmpStr, 128, " >  Game Over! Winner: %P", winner);
		Msg(winner, GREEN, " >  You won "#C_YELLOW"$50 "#C_GREEN"and 1 score point!");
		GivePlayerMoney(winner, 50);
		GivePlayerScore(winner, 1);
	}
	else tmpStr = " >  Game Over! Winner: Nobody.";
	Iter_Clear(dgw_SpawnedIndex);

	KillTimer(dgw_UpdateTimer);
    dgw_BuildArena(8);
	dgw_CountDownStarted = false;
	PlayerLoop(i)
	{
	    if(gCurrentMinigame[i] == MINIGAME_FALLOUT)
	    {
			MsgF(i, YELLOW, tmpStr);
			dgw_Join(i, false);
		}
	}
	return 1;
}
dgw_StopGame()
{
	dgw_State = DGW_STATE_INACTIVE;
	KillTimer(dgw_UpdateTimer);
	KillTimer(dgw_SpawnTimer);
	dgw_DestroyArena();
	PlayerLoop(i)
	{
	    if(gCurrentMinigame[i] == MINIGAME_FALLOUT)
	    {
			Msg(i, YELLOW, " >  The minigame has ended.");
			dgw_Leave(i, true);
		}
	}
	dgw_CountDownStarted = false;
	Iter_Clear(dgw_SpawnedIndex);
}
dgw_GetPlayersInGame()
{
	new count;
	PlayerLoop(i)if(gCurrentMinigame[i]==MINIGAME_FALLOUT)count++;
	return count;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_DgwType)
	{
	    dgw_Type = !response;
	    dgw_Join(playerid);
		PlayerLoop(i)if(IsPlayerInFreeRoam(i) || gCurrentMinigame[i] == MINIGAME_FALLOUT)
			MsgF(i, YELLOW, " >  %P"#C_YELLOW" has joined the "#C_BLUE"Don't Get Wet Type %d"#C_YELLOW" minigame! Type "#C_ORANGE"/dgw"#C_YELLOW" to join.", playerid, dgw_Type+1);
	}
	if(dialogid == d_DgwJoin)
	{
	    if(response)
		{
			dgw_Join(playerid);
		}
	    else
		{
			gCurrentMinigame[playerid] = MINIGAME_FALLOUT;
			dgw_Spectate(playerid, 0);
		}
	}
}
