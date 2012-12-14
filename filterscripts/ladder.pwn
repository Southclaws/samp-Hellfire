#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16

#include <zcmd>
#include <streamer>
#include <foreach>

#define MAX_LADDER (16)

#define CLIMB_SPEED (0.1)
#define IDLE_SPEED  (0.01)


enum E_LADDER_DATA
{
	ldr_areaID,
	Float:ldr_posX,
	Float:ldr_posY,
	Float:ldr_base,
	Float:ldr_top,
	Float:ldr_ang
}

new
	ldr_Data[MAX_LADDER][E_LADDER_DATA],
    Iterator:ldr_Iterator<MAX_LADDER>,

	ldr_currentAnim[MAX_PLAYERS],
	ldr_currentLadder[MAX_PLAYERS],
	ldr_enterLadderTick[MAX_PLAYERS];




public OnFilterScriptInit()
{
	for(new i;i<MAX_PLAYERS;i++)
	{
		ldr_currentLadder[i]=-1;
	}
	CreateLadder(1177.6424, -1305.6337, 13.9241, 29.0859, 0.0);

	CreateLadder(-1164.6187, 370.0174, 1.9609, 14.1484, 221.1218);

	CreateLadder(-1182.6258, 60.4429, 1.9609, 14.1484, 134.2914);
	
	CreateLadder(-1736.4494, -445.9549, 1.9609, 14.1484, 270.7138);

	CreateLadder(-1392.0263, -15.0978, 213.9799, 234.0190, 183.5498);


	return 1;
}
public OnFilterScriptExit()
{
}

stock CreateLadder(Float:x, Float:y, Float:z, Float:height, Float:angle, world = -1, interior = -1)
{
	new id = Iter_Free(ldr_Iterator);

	ldr_Data[id][ldr_areaID] = CreateDynamicCircle(x, y, 1.0, world, interior);
	ldr_Data[id][ldr_posX] = x;
	ldr_Data[id][ldr_posY] = y;
	ldr_Data[id][ldr_base] = z;
	ldr_Data[id][ldr_top] = height;
	ldr_Data[id][ldr_ang] = angle;

	Iter_Add(ldr_Iterator, id);
	return id;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & 16)
	{
		foreach(new i : ldr_Iterator)
		{
		    if(IsPlayerInDynamicArea(playerid, ldr_Data[i][ldr_areaID]))
		    {
		        if(ldr_currentLadder[playerid]==-1)EnterLadder(playerid, i);
		        else ExitLadder(playerid);
		    }
		}
	}
}
EnterLadder(playerid, ladder)
{
	new
		Float:z,
		Float:zOffset = ldr_Data[ladder][ldr_base]+1.5;

	GetPlayerPos(playerid, z, z, z);

	if(floatabs(z - ldr_Data[ladder][ldr_top]) < 2.0)
	{
		zOffset = ldr_Data[ladder][ldr_top] - 2.0926;
	}

	ClearAnimations(playerid);
	SetPlayerFacingAngle(playerid, ldr_Data[ladder][ldr_ang]);
	SetPlayerPos(playerid, ldr_Data[ladder][ldr_posX], ldr_Data[ladder][ldr_posY], zOffset);

	ApplyAnimation(playerid, "PED", "CLIMB_IDLE", 3.0, 0, 0, 0, 1, 0, 1);
    ldr_enterLadderTick[playerid] = GetTickCount();
    ldr_currentLadder[playerid] = ladder;
}
ExitLadder(playerid)
{
	ClearAnimations(playerid);
	SetPlayerFacingAngle(playerid, ldr_Data[ldr_currentLadder[playerid]][ldr_ang]);

	SetPlayerVelocity(playerid,
		0.1*floatsin(-ldr_Data[ldr_currentLadder[playerid]][ldr_ang], degrees),
		0.1*floatcos(-ldr_Data[ldr_currentLadder[playerid]][ldr_ang], degrees), 0.1);

    ldr_currentLadder[playerid] = -1;
    return 1;
}
public OnPlayerEnterDynamicArea(playerid, areaid)
{
	foreach(new i : ldr_Iterator)
	{
	    if(areaid == ldr_Data[i][ldr_areaID])
	    {
	        CallRemoteFunction("sffa_msgbox", "dsdd", playerid, "Press F to climb", 3000, 140);
	    }
	}
}
public OnPlayerLeaveDynamicArea(playerid, areaid)
{
	// Hide messagebox
}


public OnPlayerUpdate(playerid)
{
	if(ldr_currentLadder[playerid] == -1)return 1;

	new
		k,
		ud,
		lr,
		Float:z;

	GetPlayerKeys(playerid, k, ud, lr);
	GetPlayerPos(playerid, z, z, z);
	
	if(GetTickCount()-ldr_enterLadderTick[playerid] > 1000 &&
		( z-ldr_Data[ldr_currentLadder[playerid]][ldr_base]<0.5 || z >= ldr_Data[ldr_currentLadder[playerid]][ldr_top]-0.5) )
			return ExitLadder(playerid);

	if(ud == KEY_UP)
	{
		if(ldr_currentAnim[playerid])
		{
			ApplyAnimation(playerid, "FINALE", "FIN_HANG_LOOP", 4.0, 1, 0, 0, 0, 0);
//		    ApplyAnimation(playerid, "PED", "CLIMB_JUMP", 3.0, 0, 0, 0, 1, 0, 1);
		    ldr_currentAnim[playerid]=0;
			SetPlayerVelocity(playerid, 0.0, 0.0, CLIMB_SPEED);
		}
		else
		{
//		    ApplyAnimation(playerid, "FINALE", "FIN_HANG_LOOP", 4.0, 1, 0, 0, 0, 0);
		    ApplyAnimation(playerid, "PED", "CLIMB_IDLE", 3.0, 0, 0, 0, 1, 0, 1);
		    ldr_currentAnim[playerid]=1;
		}
	}
	else if(ud == KEY_DOWN)
	{
		if(ldr_currentAnim[playerid])
		{
			ApplyAnimation(playerid, "FINALE", "FIN_HANG_LOOP", 4.0, 1, 0, 0, 0, 0);
//		    ApplyAnimation(playerid, "PED", "CLIMB_JUMP", 3.0, 0, 0, 0, 1, 0, 1);
		    ldr_currentAnim[playerid]=0;
		}
		else
		{
//			ApplyAnimation(playerid, "FINALE", "FIN_HANG_LOOP", 4.0, 1, 0, 0, 0, 0);
		    ApplyAnimation(playerid, "PED", "CLIMB_IDLE", 3.0, 0, 0, 0, 1, 0, 1);
		    ldr_currentAnim[playerid]=1;
			SetPlayerVelocity(playerid, 0.0, 0.0, -(CLIMB_SPEED*0.7));
		}
	}
	else
	{
	    ApplyAnimation(playerid, "PED", "CLIMB_IDLE", 3.0, 0, 0, 0, 1, 0, 1);
		SetPlayerVelocity(playerid, 0.0, 0.0, IDLE_SPEED);
	}
	return 1;
}

