#include <YSI\y_hooks>

#define HLO_LAND_X					(308.1741)
#define HLO_LAND_Y					(1803.7240)
#define HLO_LAND_Z					(16.6254)
		
#define HLO_ANDROM_EXT_X			(308.52)
#define HLO_ANDROM_EXT_Y			(2046.46)
#define HLO_ANDROM_EXT_Z			(539.12)
		
#define HLO_ANDROM_INT_X			(308.52)
#define HLO_ANDROM_INT_Y			(2042.80)
#define HLO_ANDROM_INT_Z			(538.83)
		
#define HLO_SPAWN_X					(308.5571)
#define HLO_SPAWN_Y					(2020.6909)
#define HLO_SPAWN_Z					(532.5810)
		
#define HLO_STATE_NONE				(0)
#define HLO_STATE_COUNTING			(1)
#define HLO_STATE_STARTED			(2)

#define HLO_SPECTATE_MODE_NONE		(0)
#define HLO_SPECTATE_MODE_PLAYER	(1)
#define HLO_SPECTATE_MODE_PLANE		(2)

static
		hlo_State,
		hlo_StartTick,
		hlo_CurrentPlayer = -1,
		hlo_Queue[MAX_PLAYERS],
Timer:	hlo_CountTimer,
		hlo_CountValue,
		hlo_LandingZone,

bool:	hlo_OpenedChute,
bool:	hlo_Landed,
		hlo_Forfeit,

		hlo_FreefallTime,
Float:	hlo_LandDistance,	

		hlo_ExtObject,
		hlo_IntObject;

static
		hlo_Spectating[MAX_PLAYERS];

hook OnGameModeInit()
{
	hlo_ExtObject = CreateDynamicObject(14553, HLO_ANDROM_EXT_X, HLO_ANDROM_EXT_Y, HLO_ANDROM_EXT_Z, 0.00, 0.00, 180.00);
	hlo_IntObject = CreateDynamicObject(14548, HLO_ANDROM_INT_X, HLO_ANDROM_INT_Y, HLO_ANDROM_INT_Z, 0.00, 0.00, 180.00);

	for(new i; i < MAX_PLAYERS; i++)hlo_Queue[i] = -1;
	hlo_CurrentPlayer = -1;
}
hook OnGameModeExit()
{
	DestroyObject(hlo_ExtObject);
	DestroyObject(hlo_IntObject);
}

CMD:halo(playerid)
{
	if(gCurrentChallenge != CHALLENGE_NONE)
	{
		Msg(playerid, YELLOW, " >  You can't start a minigame while a challenge is active.");
		return 1;
	}
	if(gCurrentMinigame[playerid] == MINIGAME_HALOPAR)
	{
		hlo_Leave(playerid);
	}
	else if(gCurrentMinigame[playerid] == MINIGAME_NONE)
	{
		hlo_Join(playerid);
	}
	else
	{
		Msg(playerid, YELLOW, " >  Please exit your current minigame before joining another");
	}
	return 1;
}

hlo_Join(playerid, msg = true)
{
	gCurrentMinigame[playerid] = MINIGAME_HALOPAR;
	if(hlo_CurrentPlayer == -1)
    {
        hlo_CurrentPlayer = playerid;
	    TogglePlayerSpectating(playerid, false);
		SetPlayerVirtualWorld(playerid, MINIGAME_WORLD);
        hlo_Spawn();
    }
    else
    {
    	hlo_Queue[hlo_NextQueueSlot()] = playerid;
		hlo_Spectate(playerid);
	}
	if(msg)
	{
		PlayerLoop(i)if(IsPlayerInFreeRoam(i) || gCurrentMinigame[playerid] == MINIGAME_HALOPAR)
			MsgF(i, YELLOW, " >  %P"#C_YELLOW" Has gone to "#C_BLUE"HALO 'Chuting"#C_YELLOW" minigame. Type "#C_ORANGE"/halo "#C_YELLOW"to join.", playerid);
	}
}
hlo_Leave(playerid, msg = true)
{
	gCurrentMinigame[playerid] = MINIGAME_NONE;

	if(hlo_State == HLO_STATE_COUNTING && hlo_Spectating[playerid] == HLO_SPECTATE_MODE_NONE)
		stop hlo_CountTimer;

	hlo_RemoveFromQueue(playerid);

	if(GetPlayersInHlo() == 0)
	{
	    hlo_CurrentPlayer = -1;
		hlo_State = HLO_STATE_NONE;
	}
	TogglePlayerSpectating(playerid, false);
	SpawnPlayer(playerid);

	if(msg)
	{
		PlayerLoop(i)if(IsPlayerInFreeRoam(i) || gCurrentMinigame[i] == MINIGAME_HALOPAR)
			MsgF(i, YELLOW, " >  %P"#C_YELLOW" has left the "#C_BLUE"Precision Driving"#C_YELLOW" minigame.", playerid);
	}

}
hlo_NextQueueSlot()
{
	new i;

	while(i < MAX_PLAYERS && hlo_Queue[i] != -1)
		i++;

	if(i == MAX_PLAYERS)
		return -1;

	return i;
}
hlo_RemoveFromQueue(playerid)
{
	new
		i,
		slot = MAX_PLAYERS;

	while(i < MAX_PLAYERS)
	{
		if(hlo_Queue[i] == playerid)
			slot = i;

		if(i > slot)
			hlo_Queue[i-1] = hlo_Queue[i];

		i++;
	}
	return i;
}

hlo_Spectate(playerid)
{
	SetPlayerVirtualWorld(playerid, MINIGAME_WORLD);
	if(hlo_State == HLO_STATE_NONE)
	{
		hlo_Spectating[playerid] = HLO_SPECTATE_MODE_PLANE;

		TogglePlayerSpectating(playerid, false);
		TogglePlayerControllable(playerid, false);
		SetPlayerVirtualWorld(playerid, MINIGAME_WORLD);

		SetPlayerPos(playerid, 308.4705, 2050.6060, 541.5371);
		SetPlayerCameraPos(playerid, 308.5883, 2015.8690, 532.0080);
		SetPlayerCameraLookAt(playerid, 308.5957, 2014.8658, 531.7328);
	}
	else
	{
		hlo_Spectating[playerid] = HLO_SPECTATE_MODE_PLAYER;
		TogglePlayerControllable(playerid, true);
		TogglePlayerSpectating(playerid, true);
		PlayerSpectatePlayer(playerid, hlo_CurrentPlayer);
	}
}

timer hlo_Spawn[1000]()
{
	hlo_RemoveFromQueue(hlo_CurrentPlayer);

	SetCameraBehindPlayer(hlo_CurrentPlayer);
	SetPlayerPos(hlo_CurrentPlayer, HLO_SPAWN_X, HLO_SPAWN_Y, HLO_SPAWN_Z);
	SetPlayerFacingAngle(hlo_CurrentPlayer, 180.0);
	SetPlayerVirtualWorld(hlo_CurrentPlayer, MINIGAME_WORLD);
	GivePlayerWeapon(hlo_CurrentPlayer, 46, 1);

	SetPlayerVirtualWorld(hlo_CurrentPlayer, MINIGAME_WORLD);
	TogglePlayerControllable(hlo_CurrentPlayer, false);

	hlo_CountValue = 5;
	hlo_State = HLO_STATE_COUNTING;
	hlo_Spectating[hlo_CurrentPlayer] = HLO_SPECTATE_MODE_NONE;
	hlo_CountTimer = defer hlo_Countdown();

	hlo_OpenedChute = false;
	hlo_Landed = false;
	hlo_Forfeit = false;

	hlo_FreefallTime = 0;
	hlo_LandDistance = 0.0;

	PlayerLoop(i)
	{
		if(gCurrentMinigame[i] == MINIGAME_HALOPAR)
		{
			Streamer_Update(i);
			if(i != hlo_CurrentPlayer)
				hlo_Spectate(i);
		}
	}
}
timer hlo_Countdown[1000]()
{
	new
	    str[4];

	SetPlayerVirtualWorld(hlo_CurrentPlayer, MINIGAME_WORLD);

	if(hlo_CountValue > 0)
	{
		valstr(str, hlo_CountValue);
		GameTextForPlayer(hlo_CurrentPlayer, str, 1000, 5);
		hlo_CountValue--;
		hlo_CountTimer = defer hlo_Countdown();
	}
	else
	{
		GameTextForPlayer(hlo_CurrentPlayer, "~r~Go!", 1000, 5);
		hlo_Start();
	}
}
hlo_Start()
{
	SetCameraBehindPlayer(hlo_CurrentPlayer);
	SetPlayerVirtualWorld(hlo_CurrentPlayer, MINIGAME_WORLD);
	GivePlayerWeapon(hlo_CurrentPlayer, 46, 1);

	hlo_State = HLO_STATE_STARTED;
	hlo_StartTick = GetTickCount();
	hlo_OpenedChute = false;

	hlo_LandingZone = CreateDynamicRaceCP(2,
		HLO_LAND_X, HLO_LAND_Y, HLO_LAND_Z,
		HLO_LAND_X, HLO_LAND_Y, HLO_LAND_Z,
		5.0, MINIGAME_WORLD, 0, hlo_CurrentPlayer);

	TogglePlayerControllable(hlo_CurrentPlayer, true);

}
hook OnPlayerUpdate(playerid)
{
	if(gCurrentMinigame[playerid] != MINIGAME_HALOPAR)
		return 1;

	if(hlo_CurrentPlayer == playerid && hlo_State == HLO_STATE_STARTED)
	{
		new animidx = GetPlayerAnimationIndex(playerid);

		if(animidx == 971 && !hlo_OpenedChute) // Parachute open
		{
			hlo_OpenedChute = true;
			hlo_FreefallTime = GetTickCount() - hlo_StartTick;

			PlayerLoop(i)
				if(gCurrentMinigame[i] == MINIGAME_HALOPAR)
					MsgF(i, YELLOW, " >  %P"#C_YELLOW" freefalled for: "#C_BLUE"%s", playerid, MsToString(hlo_FreefallTime));
		}
		if(animidx == 1131 || GetPlayerWeapon(playerid) != 46) // Parachute land
		{
			if(!hlo_Landed)
			{
				new
					Float:x,
					Float:y,
					Float:z;

				GetPlayerPos(playerid, x, y, z);

				hlo_Landed = true;
				hlo_LandDistance = Distance2D(x, y, HLO_LAND_X, HLO_LAND_Y);

				PlayerLoop(i)
					if(gCurrentMinigame[i] == MINIGAME_HALOPAR)
						MsgF(i, YELLOW, " >  %P"#C_YELLOW" landed "#C_BLUE"%.1fm "#C_YELLOW"from the LZ!", playerid, hlo_LandDistance);

				defer hlo_Finish(playerid);
			}
		}
	}

	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(gCurrentMinigame[playerid] != MINIGAME_HALOPAR)
		return 1;

	if(hlo_CurrentPlayer == playerid && hlo_State == HLO_STATE_STARTED)
	{
		if(newkeys & 16)
		{
			if(hlo_OpenedChute)
			{
				hlo_Forfeit = true;
			}
		}
	}

	return 1;
}

timer hlo_Finish[3000](playerid)
{
	if(!hlo_Forfeit && hlo_Landed && hlo_OpenedChute)
	{
		// hlo_FreefallTime
		// hlo_LandDistance
		// DB highscore stuff
	}

	DestroyDynamicRaceCP(hlo_LandingZone);

	hlo_State = HLO_STATE_NONE;

	if(GetPlayersInHlo() > 1 || IsPlayerConnected(hlo_Queue[0]))
	{
		hlo_Spectate(playerid);
		hlo_CurrentPlayer = hlo_Queue[0];
		hlo_Queue[hlo_NextQueueSlot()] = playerid;
	}
	else hlo_Join(playerid, false);

	TogglePlayerSpectating(hlo_CurrentPlayer, false);

	defer hlo_Spawn();

}

GetPlayersInHlo()
{
	new count;

	PlayerLoop(i)
	    if(gCurrentMinigame[i] == MINIGAME_HALOPAR)count++;

	return count;
}
