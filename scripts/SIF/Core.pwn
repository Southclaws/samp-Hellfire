/*==============================================================================

Southclaw's Interactivity Framework (SIF) (Formerly: Adventure API)


	SIF/Overview
	{
		SIF is a collection of high-level include scripts to make the
		development of interactive features easy for the developer while
		maintaining quality front-end gameplay for players.
	}

	SIF/Core/Description
	{
		A fundamental library with features used by multiple SIF scripts.
	}

	SIF/Core/Dependencies
	{
		Streamer Plugin
		YSI\y_hooks
		YSI\y_timers
	}

	SIF/Core/Credits
	{
		SA:MP Team						- Amazing mod!
		SA:MP Community					- Inspiration and support
		Incognito						- Very useful streamer plugin
		Y_Less							- YSI framework
	}

	SIF/Core/Core Functions
	{
		The functions that control the core features of this script.

		native -
		native - SIF/Core/Core
		native -

		native Func(params)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}
	}

	SIF/Core/Events
	{
		Events called by player actions done by using features from this script.

		native -
		native - SIF/Core/Callbacks
		native -

		native Func(params)
		{
			Called:
				-

			Parameters:
				-

			Returns:
				-
		}
	}

	SIF/Core/Interface Functions
	{
		Functions to get or set data values in this script without editing
		the data directly. These include automatic ID validation checks.

		native -
		native - SIF/Core/Interface
		native -

		native Func(params)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}
	}

	SIF/Core/Internal Functions
	{
		Internal events called by player actions done by using features from
		this script.
	
		Func(params)
		{
			Description:
				-
		}
	}

	SIF/Core/Hooks
	{
		Hooked functions or callbacks, either SA:MP natives or from other
		scripts or plugins.

		SAMP/OnPlayerSomething
		{
			Reason:
				-
		}
	}

==============================================================================*/


/*==============================================================================

	Setup

==============================================================================*/


#include <YSI\y_hooks>


new gPlayerArea[MAX_PLAYERS];


forward OnPlayerEnterPlayerArea(playerid, targetid);
forward OnPlayerLeavePlayerArea(playerid, targetid);


hook OnPlayerSpawn(playerid)
{
	if(!IsValidDynamicArea(gPlayerArea[playerid]))
		gPlayerArea[playerid] = CreateDynamicSphere(0.0, 0.0, 0.0, 2.0);

	AttachDynamicAreaToPlayer(gPlayerArea[playerid], playerid);
}

hook OnPlayerDisconnect(playerid)
{
	DestroyDynamicArea(gPlayerArea[playerid]);
	gPlayerArea[playerid] = -1;
}

public OnPlayerEnterDynamicArea(playerid, areaid)
{
	foreach(new i : Character)
	{
		if(areaid == gPlayerArea[i] && playerid != i)
		{
			CallLocalFunction("OnPlayerEnterPlayerArea", "dd", playerid, i);
		}
	}

	return CallLocalFunction("SIF_OnPlayerEnterDynamicArea", "dd", playerid, areaid);
}
#if defined _ALS_OnPlayerEnterDynamicArea
	#undef OnPlayerEnterDynamicArea
#else
	#define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea SIF_OnPlayerEnterDynamicArea
forward SIF_OnPlayerEnterDynamicArea(playerid, areaid);


public OnPlayerLeaveDynamicArea(playerid, areaid)
{
	foreach(new i : Character)
	{
		if(areaid == gPlayerArea[i] && playerid != i)
		{
			CallLocalFunction("OnPlayerLeavePlayerArea", "dd", playerid, i);
		}
	}

	return CallLocalFunction("SIF_OnPlayerLeaveDynamicArea", "dd", playerid, areaid);
}
#if defined _ALS_OnPlayerLeaveDynamicArea
	#undef OnPlayerLeaveDynamicArea
#else
	#define _ALS_OnPlayerLeaveDynamicArea
#endif
#define OnPlayerLeaveDynamicArea SIF_OnPlayerLeaveDynamicArea
forward SIF_OnPlayerLeaveDynamicArea(playerid, areaid);
