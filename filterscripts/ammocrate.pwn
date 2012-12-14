#include <a_samp>
#include <foreach>
#include <YSI\y_timers>
#include <streamer>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16

#define MAX_AMMO_CRATE 16


new
	gCrateObj			[MAX_AMMO_CRATE],
	Float:gCratePos		[MAX_AMMO_CRATE][3],
	gCrateArea			[MAX_AMMO_CRATE],
	Iterator:gCrateTable<MAX_AMMO_CRATE>,
	gCrateTick			[MAX_PLAYERS],
	Timer:gCrateTimer	[MAX_PLAYERS],
	gUsingCrate         [MAX_PLAYERS];


public OnFilterScriptInit()
{
	CreateSupplyCrate(0.0, 0.0, 2.0, 90.0); // Debug
}

stock CreateSupplyCrate(Float:x, Float:y, Float:z, Float:r=0.0)
{
	new
		id = Iter_Free(gCrateTable);

	gCrateObj[id]	= CreateDynamicObject(964, x, y, z, 0, 0, r);
	gCrateArea[id]	= CreateDynamicSphere(x, y, z, 1.0);
	gCratePos[id][0]	= x,
	gCratePos[id][1] = y,
	gCratePos[id][2] = z;

	Iter_Add(gCrateTable, id);

	return id;
}


public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & 16) // 16 = F/Enter
	{
		for(new x;x<MAX_AMMO_CRATE;x++)
		{
			if(
				IsPlayerInRangeOfPoint(playerid, 2.0, gCratePos[x][0], gCratePos[x][1], gCratePos[x][2]) &&
				GetTickCount() - gCrateTick[playerid] > 30000) // Only works every 30s
			{
				Crate_Use(playerid);
				break;
			}
		}
	}
	if(oldkeys & 16 && gUsingCrate[playerid]) // When the release the key
	{
	    ClearAnimations(playerid);
	    stop gCrateTimer[playerid];
	}
}

Crate_Use(playerid)
{
	ApplyAnimation(playerid, "bomber", "bom_Plant", 1.0, 1, 0, 0, 0, 0);
	gCrateTimer[playerid] = defer Crate_Refil(playerid);
	gUsingCrate[playerid] = true;
}

timer Crate_Refil[2000](playerid)
{
    gUsingCrate[playerid] = false;
	gCrateTick[playerid] = GetTickCount();
	ClearAnimations(playerid);
	SendClientMessage(playerid, -1, "Ammo Refilled!");
	// GivePlayerWeapon(...); etc
}
