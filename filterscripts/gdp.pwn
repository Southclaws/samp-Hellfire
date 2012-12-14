#include <a_samp>
#include <formatex>
#include <zcmd>
#include <streamer>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16

#define MAX_GDP_SIZE		(8)
#define MODEL_ID			(3374)
#define GDP_DEFAULTSIZE		(8)
#define GDP_COUNTDOWN       (5)

#define GDP_ORIGIN_X		(500.0)
#define GDP_ORIGIN_Y		(-2600.0)
#define GDP_ORIGIN_Z		(10.0)

#define GDP_OFFSET_X		(4.0)
#define GDP_OFFSET_Y		(4.0)
#define GDP_CAM_OFFSET		(10.0)
#define GDP_CAM_TIME		(20000)

new
	gdp_gridObj[MAX_GDP_SIZE][MAX_GDP_SIZE],
	gdp_gridSize,
	gdp_arenaArea,
	gdp_quitArea,
	bool:gdp_InGame[MAX_PLAYERS],
	bool:gdp_Alive[MAX_PLAYERS],
	gdp_State,
	gdp_spawnCounter,
	gdp_CountDownStarted,
	gdp_SpectateTimer[MAX_PLAYERS],
	gdp_SpawnTimer,
	gdp_Spectating[MAX_PLAYERS];

forward gdp_SpawnCount();
forward gdp_Spectate(playerid, corner);

public OnFilterScriptInit()
{
	return 1;
}
public OnFilterScriptExit()
{
	return 1;
}

CMD:npcgdp(playerid, params[])
{
	cmd_gdp(1, "");
	return 1;
}
CMD:gdp(playerid, params[])
{
	if(gdp_InGame[playerid])gdp_Quit(playerid);
	else gdp_Join(playerid);
	return 1;
}


gdp_Join(playerid)
{
	new iCount;

	gdp_InGame[playerid] = true;
	gdp_Alive[playerid] = false;

	for(new i;i<MAX_PLAYERS;i++)if(gdp_InGame[i])iCount++;

	if(gdp_State == 0 || iCount == 1)
	{
		gdp_BuildArena(GDP_DEFAULTSIZE);
		gdp_Spectate(playerid, 0);
	}
	else if(gdp_State == 1 && !gdp_Spectating[playerid])gdp_Spectate(playerid, 0);
	else if(gdp_State == 2)
	{
		if(gdp_Spawn(playerid))return 1;
	}

	if(iCount >= 1 && !gdp_CountDownStarted)
	{
		gdp_spawnCounter = GDP_COUNTDOWN;
		gdp_SpawnTimer = SetTimer("gdp_SpawnCount", 1000, true);
		gdp_CountDownStarted = true;
	}
	
	return 0;
}
gdp_Quit(playerid, respawn = true)
{
	new iCount;

	gdp_InGame[playerid] = false;
	if(respawn)SpawnPlayer(playerid);
	SetCameraBehindPlayer(playerid);
	TogglePlayerControllable(playerid, true);
    KillTimer(gdp_SpectateTimer[playerid]);
    gdp_SpectateTimer[playerid] = -1;
    ResetPlayerWeapons(playerid);

	for(new i;i<MAX_PLAYERS;i++)if(gdp_InGame[i])iCount++;
	if(iCount<=1 && gdp_State != 0)gdp_StopGame();
}
public gdp_SpawnCount()
{
	if(gdp_State!=1)KillTimer(gdp_SpawnTimer);
    for(new x;x<gdp_gridSize;x++)for(new y;y<gdp_gridSize;y++)if(IsDynamicObjectMoving(gdp_gridObj[x][y]))return 1;

	if(gdp_spawnCounter == 0)
	{
		for(new i;i<MAX_PLAYERS;i++)
		{
			if(gdp_InGame[i])
			{
			    GameTextForPlayer(i, "GO!", 1000, 5);
			    gdp_Spawn(i);
			}
		}
		gdp_State = 2;
		KillTimer(gdp_SpawnTimer);
		return 1;
	}
	else
	{
		new
			tmpStr[3];

		valstr(tmpStr, gdp_spawnCounter);
		for(new i;i<MAX_PLAYERS;i++)if(gdp_InGame[i])GameTextForPlayer(i, tmpStr, 1000, 5);
	}

	gdp_spawnCounter--;
	return 0;
}
public gdp_Spectate(playerid, corner)
{
	if(gdp_Alive[playerid] || !gdp_State || gdp_SpectateTimer[playerid]!=-1)return 0;
	SetPlayerPos(playerid, GDP_ORIGIN_X, GDP_ORIGIN_Y, 0.0);
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
			GDP_ORIGIN_X-GDP_CAM_OFFSET, GDP_ORIGIN_Y-GDP_CAM_OFFSET, GDP_ORIGIN_Z+(GDP_CAM_OFFSET/2),
			GDP_CAM_TIME, CAMERA_MOVE);

		InterpolateCameraLookAt(playerid,
			cam_lX, cam_lY, cam_lZ,
			GDP_ORIGIN_X+(GDP_OFFSET_X), GDP_ORIGIN_Y+(GDP_OFFSET_Y), GDP_ORIGIN_Z,
			GDP_CAM_TIME, CAMERA_MOVE);

		gdp_SpectateTimer[playerid] = SetTimerEx("gdp_Spectate", 500, false, "dd", playerid, 0);
	}
	if(corner == 0) // Moving along the X +
	{
		InterpolateCameraPos(playerid,
			GDP_ORIGIN_X-GDP_CAM_OFFSET, GDP_ORIGIN_Y-GDP_CAM_OFFSET, GDP_ORIGIN_Z+(GDP_CAM_OFFSET/2),
			GDP_ORIGIN_X+((gdp_gridSize-1)*GDP_OFFSET_X)+GDP_CAM_OFFSET, GDP_ORIGIN_Y-GDP_CAM_OFFSET, GDP_ORIGIN_Z+(GDP_CAM_OFFSET/2),
			GDP_CAM_TIME, CAMERA_MOVE);

		InterpolateCameraLookAt(playerid,
			GDP_ORIGIN_X+(GDP_OFFSET_X), GDP_ORIGIN_Y+(GDP_OFFSET_Y), GDP_ORIGIN_Z,
			GDP_ORIGIN_X+((gdp_gridSize-2)*GDP_OFFSET_X), GDP_ORIGIN_Y+(GDP_OFFSET_Y), GDP_ORIGIN_Z,
			GDP_CAM_TIME, CAMERA_MOVE);

		gdp_SpectateTimer[playerid] = SetTimerEx("gdp_Spectate", GDP_CAM_TIME, false, "dd", playerid, corner+1);
	}
	if(corner == 1) // Moving along the Y +
	{
		InterpolateCameraPos(playerid,
			GDP_ORIGIN_X+((gdp_gridSize-1)*GDP_OFFSET_X)+GDP_CAM_OFFSET, GDP_ORIGIN_Y-GDP_CAM_OFFSET, GDP_ORIGIN_Z+(GDP_CAM_OFFSET/2),
			GDP_ORIGIN_X+((gdp_gridSize-1)*GDP_OFFSET_X)+GDP_CAM_OFFSET, GDP_ORIGIN_Y+((gdp_gridSize-1)*GDP_OFFSET_Y)+GDP_CAM_OFFSET, GDP_ORIGIN_Z+(GDP_CAM_OFFSET/2),
			GDP_CAM_TIME, CAMERA_MOVE);

		InterpolateCameraLookAt(playerid,
			GDP_ORIGIN_X+((gdp_gridSize-2)*GDP_OFFSET_X), GDP_ORIGIN_Y+(GDP_OFFSET_Y), GDP_ORIGIN_Z,
			GDP_ORIGIN_X+((gdp_gridSize-2)*GDP_OFFSET_X), GDP_ORIGIN_Y+((gdp_gridSize-2)*GDP_OFFSET_Y), GDP_ORIGIN_Z,
			GDP_CAM_TIME, CAMERA_MOVE);

		gdp_SpectateTimer[playerid] = SetTimerEx("gdp_Spectate", GDP_CAM_TIME, false, "dd", playerid, corner+1);
	}
	if(corner == 2) // Moving along the X -
	{
		InterpolateCameraPos(playerid,
			GDP_ORIGIN_X+((gdp_gridSize-1)*GDP_OFFSET_X)+GDP_CAM_OFFSET, GDP_ORIGIN_Y+((gdp_gridSize-1)*GDP_OFFSET_Y)+GDP_CAM_OFFSET, GDP_ORIGIN_Z+(GDP_CAM_OFFSET/2),
			GDP_ORIGIN_X-GDP_OFFSET_X, GDP_ORIGIN_Y+((gdp_gridSize-1)*GDP_OFFSET_Y)+GDP_CAM_OFFSET, GDP_ORIGIN_Z+(GDP_CAM_OFFSET/2),
			GDP_CAM_TIME, CAMERA_MOVE);

		InterpolateCameraLookAt(playerid,
			GDP_ORIGIN_X+((gdp_gridSize-2)*GDP_OFFSET_X), GDP_ORIGIN_Y+((gdp_gridSize-2)*GDP_OFFSET_Y), GDP_ORIGIN_Z,
			GDP_ORIGIN_X+GDP_OFFSET_X, GDP_ORIGIN_Y+((gdp_gridSize-1)*GDP_OFFSET_Y)-GDP_OFFSET_Y, GDP_ORIGIN_Z,
			GDP_CAM_TIME, CAMERA_MOVE);

		gdp_SpectateTimer[playerid] = SetTimerEx("gdp_Spectate", GDP_CAM_TIME, false, "dd", playerid, corner+1);
	}
	if(corner == 3) // Moving along the Y -
	{
		InterpolateCameraPos(playerid,
			GDP_ORIGIN_X-GDP_OFFSET_X, GDP_ORIGIN_Y+((gdp_gridSize-1)*GDP_OFFSET_Y)+GDP_CAM_OFFSET, GDP_ORIGIN_Z+(GDP_CAM_OFFSET/2),
			GDP_ORIGIN_X-GDP_CAM_OFFSET, GDP_ORIGIN_Y-GDP_CAM_OFFSET, GDP_ORIGIN_Z+(GDP_CAM_OFFSET/2),
			GDP_CAM_TIME, CAMERA_MOVE);

		InterpolateCameraLookAt(playerid,
			GDP_ORIGIN_X+GDP_OFFSET_X, GDP_ORIGIN_Y+((gdp_gridSize-1)*GDP_OFFSET_Y)-GDP_OFFSET_Y, GDP_ORIGIN_Z,
			GDP_ORIGIN_X+(GDP_OFFSET_X), GDP_ORIGIN_Y+(GDP_OFFSET_Y), GDP_ORIGIN_Z,
			GDP_CAM_TIME, CAMERA_MOVE);

		gdp_SpectateTimer[playerid] = SetTimerEx("gdp_Spectate", GDP_CAM_TIME, false, "dd", playerid, 0);
	}
	return 1;
}

public OnPlayerUpdate(playerid)
{
	if(gdp_State == 2 && gdp_InGame[playerid] && gdp_Alive[playerid])
	{
		new Float:z;
		GetPlayerPos(playerid, z, z, z);
		if(z < 1.0 || z > 13.5)gdp_Out(playerid);
	}
	return 1;
}
public OnPlayerLeaveDynamicArea(playerid, areaid)
{
	if(areaid == gdp_arenaArea && gdp_InGame[playerid])
	{
		if(gdp_State==1)gdp_Quit(playerid, false);
		if(gdp_State==2)
		{
		    if(IsPlayerInDynamicArea(playerid, gdp_quitArea))gdp_Out(playerid);
		    else gdp_Quit(playerid, false);
		}
	}
}
gdp_BuildArena(size)
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
		Float:tmp_rotZ,
		Float:tmpSpeed = 15.0;

    gdp_State = 1;
    gdp_gridSize = size;
    
	gdp_arenaArea = CreateDynamicRectangle(
		GDP_ORIGIN_X-(GDP_OFFSET_X/2), GDP_ORIGIN_Y-(GDP_OFFSET_Y/2),
		GDP_ORIGIN_X+((gdp_gridSize-1)*GDP_OFFSET_X)+(GDP_OFFSET_X/2), GDP_ORIGIN_Y+((gdp_gridSize-1)*GDP_OFFSET_Y)+(GDP_OFFSET_Y/2) );

    gdp_quitArea = CreateDynamicRectangle(
		GDP_ORIGIN_X-(GDP_OFFSET_X*2), GDP_ORIGIN_Y-(GDP_OFFSET_Y*2),
		GDP_ORIGIN_X+((gdp_gridSize-1)*GDP_OFFSET_X)+(GDP_OFFSET_X*2), GDP_ORIGIN_Y+((gdp_gridSize-1)*GDP_OFFSET_Y)+(GDP_OFFSET_Y*2) );

	for(new x;x<size;x++)
	{
		for(new y;y<size;y++)
		{
		    switch(bStyle_XY)
		    {
		        case 0:tmpX = GDP_ORIGIN_X, tmpY = GDP_ORIGIN_Y;
		        case 1:tmpX = GDP_ORIGIN_X+((gdp_gridSize/2)*GDP_OFFSET_X), tmpY = GDP_ORIGIN_Y+((gdp_gridSize/2)*GDP_OFFSET_X), tmpSpeed = 20.0;
		        case 2:tmpX = GDP_ORIGIN_X+((gdp_gridSize/(random(4)+1))*GDP_OFFSET_X), tmpY = GDP_ORIGIN_Y+((gdp_gridSize/(random(4)+1))*GDP_OFFSET_X), tmpSpeed = 20.0;
		        case 3:tmpX = GDP_ORIGIN_X+(random(gdp_gridSize)*GDP_OFFSET_X), tmpY = GDP_ORIGIN_Y+(random(gdp_gridSize)*GDP_OFFSET_Y);
				default:tmpX = GDP_ORIGIN_X+(x*GDP_OFFSET_X), tmpY = GDP_ORIGIN_Y+(y*GDP_OFFSET_Y);
		    }
		    switch(bStyle_Z)
		    {
		        case 0:tmpZ = 0.5*x*y;
		        case 1:tmpZ = tmpZ = x*1.0-y*1.0;
		        case 2:tmpZ = (x+y)+(y+x), tmpSpeed = 20.0;
		        case 3:tmpZ = (x*y)+x-y, tmpSpeed = 20.0;
		        
		        default:tmpZ = 0.0;
		    }
		    switch(bStyle_rotXYZ)
		    {
		        case 0:tmp_rotY = (180.0/gdp_gridSize)*x, tmp_rotZ = (180.0/gdp_gridSize)*y;
		        case 1:tmp_rotY = (180.0/gdp_gridSize)*(x*8), tmp_rotZ = 180.0;
		        case 2:tmp_rotY = x*90.0*y, tmp_rotZ = 0.0;
		        case 3:tmp_rotX = x*90.0*y, tmp_rotY = y*90*x;
		        default:tmp_rotY = 0.0, tmp_rotZ = 0.0;
		    }
		    if(IsValidDynamicObject(gdp_gridObj[x][y]))DestroyDynamicObject(gdp_gridObj[x][y]);
			gdp_gridObj[x][y] = CreateDynamicObject(MODEL_ID, tmpX, tmpY, tmpZ, tmp_rotX, tmp_rotY, tmp_rotZ);
	    	MoveDynamicObject(gdp_gridObj[x][y], GDP_ORIGIN_X+(x*GDP_OFFSET_X), GDP_ORIGIN_Y+(y*GDP_OFFSET_Y), GDP_ORIGIN_Z, tmpSpeed, 0.0, 0.0, 0.0);
		}
	}
}
gdp_DestroyArena()
{
	DestroyDynamicArea(gdp_arenaArea);
	for(new x;x<gdp_gridSize;x++)
	{
		for(new y;y<gdp_gridSize;y++)
		{
		    DestroyDynamicObject(gdp_gridObj[x][y]);
		}
	}
}
gdp_Spawn(playerid)
{
	SetPlayerPos(playerid,
		GDP_ORIGIN_X+(random(gdp_gridSize)*GDP_OFFSET_X),
		GDP_ORIGIN_Y+(random(gdp_gridSize)*GDP_OFFSET_Y),
		GDP_ORIGIN_Z+1.0);

	ResetPlayerWeapons(playerid);
	GivePlayerWeapon(playerid, 33, 128);

    gdp_Alive[playerid] = true;
    TogglePlayerControllable(playerid, true);
	SetCameraBehindPlayer(playerid);
	KillTimer(gdp_SpectateTimer[playerid]);
	gdp_SpectateTimer[playerid] = -1;
	return 1;
}
gdp_Out(playerid)
{
	new iLoop, winner;
    gdp_Alive[playerid] = false;
    for(new i;i<MAX_PLAYERS;i++)
	{
		if(gdp_Alive[i])
		{
		    winner = i;
			iLoop++;
		}
		if(i==MAX_PLAYERS-1)
		{
			if(iLoop==1)gdp_EndGame(winner);
			else gdp_EndGame();
		}
	}
    gdp_Spectate(playerid, -1);
    return 0;
}
gdp_EndGame(winner=INVALID_PLAYER_ID)
{
    new tmpStr[128];

	if(winner!=INVALID_PLAYER_ID)format(tmpStr, 128, "Winner: %P", winner);
	else tmpStr = "Nobody Won.";

    gdp_BuildArena(8);
	gdp_CountDownStarted = false;
    for(new i;i<MAX_PLAYERS;i++)if(gdp_InGame[i])
	{
		SendClientMessage(i, 0xFFFF00FF, tmpStr);
		gdp_Join(i);
	}
	return 1;
}
gdp_StopGame()
{
    for(new i;i<MAX_PLAYERS;i++)if(gdp_InGame[i])gdp_Quit(i);
	KillTimer(gdp_SpawnTimer);
	gdp_DestroyArena();
	gdp_State = 0;
}
