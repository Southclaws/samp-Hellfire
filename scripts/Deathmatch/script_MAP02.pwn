#define MAX_CCTV 10

//======================CCTV Variables

new
	Float:CCTV_Positions[MAX_CCTV][3]=
	{
		{201.4361, 1858.0842, 14.1406},
		{255.5510, 1880.5475, 14.4609},
		{237.9282, 1807.8387, 12.1190},
		{299.4411, 1816.5137, 7.0000},
		{275.5638, 1841.6835, 10.0000},
		{332.0320, 1837.6627, 10.0000},
		{295.6037, 1853.4476, 10.0000},
		{266.4689, 1853.2777, 12.7578},
		{262.7636, 1889.6595, 11.0781},
		{274.4807, 1883.5447, -22.4219}
	},
	Float:CCTV_LookPos[MAX_CCTV][3],

	Float:CCTV_Elevation[MAX_CCTV],
	Float:CCTV_Rotation[MAX_CCTV],

	CCTV_Timer,
	CurrentCCTV[MAX_PLAYERS] = -1,
	Text:CameraControlText,
	Menu:CCTV_Menu;

GetPlayersInCCTV()
{
	new count;
	PlayerLoop(i)if(CurrentCCTV[i] != -1)count++;
	return count;
}

//======================Pickup/Menu Variables

new
	basecontrol,
	Menu:BaseControlMenu,
	bool:BaseDoorOpen,
	bool:ControlRoomLocked,
	BaseLockdown;

//======================Door Pickup Variables

new
	frontgateinner,frontgateouter,
	frontdoorouter,frontdoorinner,
	door2outer,door2inner,
	door3outer,door3inner,
	door4outer,door4inner,
	hqdoorouter,hqdoorinner,
	door5inner,door5middle,door5outer,
	door6outer,door6inner;

//======================Door Object Variables

new
	armygate,
	frontdoorL,frontdoorR,
	door2,
	h1,h2,
	door3,door4,
	d1r,d1l,
	hqd1,vdb,vdt,hqd2,
	door5,door6;

//======================Door Close Callbacks [for the timers]

	forward CloseDoorSet(doorsetid);
	forward HackBaseGate(playerid);
	forward CheckKeysForCCTV(playerid);
	forward script_MAP02_LoadItems();





//=================================ArmyBase Control Menu========================
script_MAP02_MenuRow(playerid, row, Menu:pMenu)
{
	if(pMenu == BaseControlMenu)
	{
		switch(row)
		{
			case 1:
			{
				if(ControlRoomLocked)
				{
					ControlRoomLocked = false;
					Msg(playerid, YELLOW, "ControlRoom Unlocked");
				}
				else if(!ControlRoomLocked)
				{
					ControlRoomLocked = true;
					Msg(playerid, YELLOW, "ControlRoom Locked");
				}
				ShowMenuForPlayer(BaseControlMenu, playerid);
			}
			case 2:
			{
				if(BaseLockdown)
				{
					BaseLockdown = false;
					Msg(playerid, YELLOW, "Base Lockdown Ended");
				}
				else if(!BaseLockdown)
				{
					BaseLockdown = true;
					Msg(playerid, YELLOW, "Base Under Lockdown");
				}
				ShowMenuForPlayer(BaseControlMenu, playerid);
			}
			case 3:
			{
				TogglePlayerControllable(playerid, 0);
				ShowMenuForPlayer(CCTV_Menu, playerid);
			}
		}
	}
	if(pMenu == CCTV_Menu)
	{
	    if(row==10)ShowMenuForPlayer(BaseControlMenu, playerid);
	    else SetPlayerToCCTVCamera(playerid, row);
	}
	return 1;
}
public CheckKeysForCCTV()
	PlayerLoop(i)if(CurrentCCTV[i] != -1)CheckKeys(i);

CheckKeys(playerid)
{
	new
		keys,
		updown,
		leftright,
		tmpID = CurrentCCTV[playerid];

	GetPlayerKeys(playerid, keys, updown, leftright);
	
	if(tmpID>-1)
	{
		if(leftright == KEY_RIGHT)
	  	{
	  		if(keys == KEY_SPRINT)
			  	CCTV_Rotation[tmpID]-=5.0;
			else
				CCTV_Rotation[tmpID]-=3.0;

	  		if(CCTV_Rotation[tmpID] < 0.0)
			  	CCTV_Rotation[tmpID]=359.0;
		}
		if(leftright == KEY_LEFT)
		{
			if(keys == KEY_SPRINT)
				CCTV_Rotation[tmpID]+=5.0;
			else
				CCTV_Rotation[tmpID]+=3.0;

			if(CCTV_Rotation[tmpID] >= 360.0)
				CCTV_Rotation[tmpID]=0.0;
		}
		if(updown == KEY_UP)
		{
			if(CCTV_Elevation[tmpID]<40.0)
			{
				if(keys == KEY_SPRINT)
					CCTV_Elevation[tmpID]+=5.0;
				else
					CCTV_Elevation[tmpID]+=3.0;
			}
		}
		if(updown == KEY_DOWN)
		{
			if(CCTV_Elevation[tmpID]>-40.0)
			{
				if(keys == KEY_SPRINT)
					CCTV_Elevation[tmpID]-=5.0;
				else
					CCTV_Elevation[tmpID]-=3.0;
			}
		}
		if(keys == KEY_CROUCH)ExitCCTV(playerid);
		MovePlayerCCTV(playerid);
	}
}
stock MovePlayerCCTV(playerid)
{
	new tmpID = CurrentCCTV[playerid];
/*
	CCTV_LookPos[tmpID][0] = CCTV_Positions[tmpID][0] + (CCTV_Elevation[tmpID] * floatsin(-CCTV_Rotation[tmpID], degrees));
	CCTV_LookPos[tmpID][1] = CCTV_Positions[tmpID][1] + (CCTV_Elevation[tmpID] * floatcos(-CCTV_Rotation[tmpID], degrees));
*/
    CCTV_LookPos[tmpID][0] = CCTV_Positions[tmpID][0] + (floatsin(-CCTV_Rotation[tmpID], degrees) * floatcos(CCTV_Elevation[tmpID], degrees));
    CCTV_LookPos[tmpID][1] = CCTV_Positions[tmpID][1] + (floatcos(-CCTV_Rotation[tmpID], degrees) * floatcos(CCTV_Elevation[tmpID], degrees));
	CCTV_LookPos[tmpID][2] = CCTV_Positions[tmpID][2] + (floatsin(CCTV_Elevation[tmpID], degrees));

	SetPlayerCameraLookAt(playerid, CCTV_LookPos[tmpID][0], CCTV_LookPos[tmpID][1], CCTV_LookPos[tmpID][2]);
}
SetPlayerToCCTVCamera(playerid, CCTV)
{
	CurrentCCTV[playerid] = CCTV;
	TogglePlayerControllable(playerid, 0);

	SetPlayerPos			(playerid, CCTV_Positions[CCTV][0], CCTV_Positions[CCTV][1], (CCTV_Positions[CCTV][2]-50));
	SetPlayerCameraPos		(playerid, CCTV_Positions[CCTV][0], CCTV_Positions[CCTV][1], CCTV_Positions[CCTV][2]);
	SetPlayerCameraLookAt	(playerid, CCTV_Positions[CCTV][0], CCTV_Positions[CCTV][1], CCTV_Positions[CCTV][2]-10.0);

	CCTV_LookPos[CCTV][0]	= CCTV_Positions[CCTV][0];
	CCTV_LookPos[CCTV][1]	= CCTV_Positions[CCTV][1]+0.2;
	CCTV_LookPos[CCTV][2]	= CCTV_Positions[CCTV][2];
	CCTV_Elevation[CCTV]	= 12.5;
	CCTV_Rotation[CCTV]		= 0.0;
	
	if(GetPlayersInCCTV()==0)CCTV_Timer=SetTimer("CheckKeysForCCTV", 100, true);

	TextDrawShowForPlayer(playerid, CameraControlText);

	MovePlayerCCTV(playerid);

	return 1;
}
ExitCCTV(playerid)
{
	if(CurrentCCTV[playerid] > -1)
	{
		TogglePlayerControllable(playerid, 0);
		SetPlayerPos(playerid, 213.1613, 1822.1256, 6.4141);

		SetCameraBehindPlayer(playerid);
		TextDrawHideForPlayer(playerid, CameraControlText);
		CurrentCCTV[playerid] = -1;
		if(GetPlayersInCCTV()==0)KillTimer(CCTV_Timer);
		ShowMenuForPlayer(CCTV_Menu, playerid);
		return 1;
	}
	return 0;
}


public HackBaseGate(playerid)
{
	MoveDynamicObject(armygate, 96.886208, 1922.040039, 17.310095, 4.0);
	TeamMsgF(pTeam(playerid), BLUE, " >  %P"#C_BLUE" has hacked the base gate", playerid);
	TeamMsg(poTeam(playerid), RED, " >  Enemies have breached the front gate");
	TogglePlayerControllable(playerid, true);
	ClearAnimations(playerid);
	GiveXP(playerid, 10, "hacking gate");
}


