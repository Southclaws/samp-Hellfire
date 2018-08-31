#include <YSI\y_hooks>

#define MAX_SPECTATE_GROUP		(10)
#define MAX_SPECTATE_GROUP_NAME	(12)

#define GROUP_ALL				(0)
#define GROUP_FREEROAM			(1)
#define GROUP_DM_RAVEN			(2)
#define GROUP_DM_VALOR			(3)
#define GROUP_DM_ALL			(4)
#define GROUP_RACE				(5)
#define GROUP_PARKOUR			(6)
#define GROUP_FALLOUT			(7)
#define GROUP_SUMO				(8)
#define GROUP_DERBY				(9)

new
	gPlayerSpectating[MAX_PLAYERS],
	gPlayerSpectateGroup[MAX_PLAYERS],
	gPlayerSpectateMode[MAX_PLAYERS],
	gSpectateGroupIndex[MAX_SPECTATE_GROUP];

new
	gSpectateModeNames[3][7]=
	{
		"Normal",
		"Fixed",
		"Side"
	},
	gSpectateGroupNames[MAX_SPECTATE_GROUP][MAX_SPECTATE_GROUP_NAME]=
	{
		"All",
		"Freeroam",
		"Raven",
		"Valor",
		"Deathmatch",
		"Race",
		"Parkour",
		"Fallout",
		"Sumo",
		"Derby"
	};

CMD:spec(playerid, params[])
{
    new id;
    if(!sscanf(params, "d", id))
	{
	    if(!IsPlayerConnected(id))Msg(playerid, RED, " >  Invalid ID");
		SpectatePlayer(playerid, id);
	}

	if(gPlayerSpectating[playerid] == INVALID_PLAYER_ID)
	{
		new result = FormatSpecGroupList(playerid);
		if(result == 0)Msg(playerid, YELLOW, " >  Nobody to spectate");
	}
	else ExitSpectateMode(playerid);
	
	return 1;
	
}

EnterSpectateMode(playerid, group)
{
	new id;

    gPlayerSpectating[playerid] = playerid;
	id = SelectNextPlayer(playerid, group);
	
	if(id != -1)
	{
	    ResetSpectatorTarget(playerid);
		ShowSpectateControls(playerid);
		SelectTextDraw(playerid, YELLOW);
		gPlayerSpectateGroup[playerid] = group;
		SpectatePlayer(playerid, id);
		return 1;
	}
	else
	{
		Msg(playerid, YELLOW, " >  Nobody to spectate");
    	return 0;
    }
}
SelectNextPlayer(playerid, group)
{
    new
        id = gPlayerSpectating[playerid] + 1,
		iters;

	if(id == MAX_PLAYERS)id = 0;

    while(id < MAX_PLAYERS && iters < 100)
    {
        iters++;
		if(id == playerid || !IsPlayerConnected(id) || !(bPlayerGameSettings[id] & Spawned) || !GroupChecks(id, group))
		{
		    id++;
	    	if(id >= MAX_PLAYERS-1)id=0;
			continue;
		}
		break;
	}
	return id;
}
SelectPrevPlayer(playerid, group)
{
	new
		id = gPlayerSpectating[playerid] - 1,
		iters;

	if(id < 0)id = MAX_PLAYERS-1;

	while(id >= 0 && iters < 100)
	{
		iters++;
		if(id == playerid || !IsPlayerConnected(id) || !(bPlayerGameSettings[id] & Spawned) || !GroupChecks(id, group))
		{
			id--;
			if(id <= 0)id=MAX_PLAYERS-1;
			continue;
		}
		break;
    }
	return id;
}
GroupChecks(id, group)
{
	if(!IsPlayerConnected(id)) return 0;
	if(group == GROUP_ALL) return 1;
	else if(group == GROUP_FREEROAM)
	{
		if(gCurrentMinigame[id] != MINIGAME_NONE || bPlayerGameSettings[id] & InDM || bPlayerGameSettings[id] & InRace)
		{
		    return 0;
		}
	}
	else if(group == GROUP_DM_RAVEN)
	{
	    if(!(bPlayerGameSettings[id] & InDM) && pTeam(id) != TEAM_RAVEN)
		{
		    return 0;
		}
	}
	else if(group == GROUP_DM_VALOR)
	{
	    if(!(bPlayerGameSettings[id] & InDM) && pTeam(id) != TEAM_VALOR)
		{
		    return 0;
		}
	}
	else if(group == GROUP_DM_ALL)
	{
	    if(!(bPlayerGameSettings[id] & InDM))
		{
		    return 0;
		}
	}
	else if(group == GROUP_RACE)
	{
	    if(!(bPlayerGameSettings[id] & InRace))
		{
		    return 0;
		}
	}
	else if(group == GROUP_PARKOUR)
	{
	    if(gCurrentMinigame[id] != MINIGAME_PARKOUR)
		{
		    return 0;
		}
	}
	else if(group == GROUP_FALLOUT)
	{
	    if(gCurrentMinigame[id] != MINIGAME_FALLOUT)
		{
		    return 0;
		}
	}
	else if(group == GROUP_SUMO)
	{
		if(gCurrentMinigame[id] != MINIGAME_CARSUMO)
		{
		    return 0;
		}
	}
	else if(group == GROUP_DERBY)
	{
	    if(gCurrentMinigame[id] != MINIGAME_DESDRBY)
		{
		    return 0;
		}
	}
	return 1;
}
ResetSpectatorTarget(targetid, msg = 1, leftserver = 0)
{
	foreach(new i : Player)
	{
	    if(gPlayerSpectating[i] == INVALID_PLAYER_ID || gPlayerSpectating[i] != targetid || i == targetid)continue;

		if(GroupChecks(targetid, gPlayerSpectateGroup[i]))return 1;
		new newtarget = SelectNextPlayer(i, gPlayerSpectateGroup[i]);

		if(msg)
			MsgF(i, YELLOW, " >  %P "#C_YELLOW"left the group you are spectating.", targetid);

		if(newtarget == -1)
		{
		    if(leftserver)
		    {
		    	Msg(i, YELLOW, " >  There are no more players in this group.");
		    	ExitSpectateMode(i);
		    }
		    else newtarget = targetid;
		}
		else SpectatePlayer(i, newtarget);
	}
	return 0;
}
ExitSpectateMode(playerid)
{
	HideSpectateControls(playerid);
	CancelSelectTextDraw(playerid);
	gPlayerSpectating[playerid] = INVALID_PLAYER_ID;
	gPlayerSpectateGroup[playerid] = -1;
	TogglePlayerSpectating(playerid, false);
}
hook OnPlayerClickPlayerTD(playerid, PlayerText:playertextid)
{
	if(gPlayerSpectating[playerid] == INVALID_PLAYER_ID)return 1;

	if(playertextid == SpecControl_BtnL)
	{
	    new id;

		id = SelectPrevPlayer(playerid, gPlayerSpectateGroup[playerid]);
		if(id != -1)
		{
			SpectatePlayer(playerid, id);
			return 1;
		}
	}
	if(playertextid == SpecControl_BtnR)
	{
	    new id;

		id = SelectNextPlayer(playerid, gPlayerSpectateGroup[playerid]);
		if(id != -1)
		{
			SpectatePlayer(playerid, id);
			return 1;
		}
	}
	if(playertextid == SpecControl_Text)
	{
		PlayerTextDrawSetString(playerid, SpecControl_Text, "spectating (F for mouse mode)");
	    CancelSelectTextDraw(playerid);
	}
	if(playertextid == SpecControl_Mode)
	{
        gPlayerSpectateMode[playerid]++;
        if(gPlayerSpectateMode[playerid] > SPECTATE_MODE_SIDE)gPlayerSpectateMode[playerid] = SPECTATE_MODE_NORMAL;
        SpectatePlayer(playerid, gPlayerSpectating[playerid]);
	}
	if(playertextid == SpecControl_Hide)
	{
        HideSpectateControls(playerid);
        CancelSelectTextDraw(playerid);
        Msg(playerid, YELLOW, " >  HUD hidden, type "#C_BLUE"/hud "#C_YELLOW"to show it again");
	}

	return 1;
}
hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(gPlayerSpectating[playerid] == INVALID_PLAYER_ID)return 1;

    if(newkeys & 16)
	{
	    PlayerTextDrawSetString(playerid, SpecControl_Text, "spectating (click for freelook)");
		SelectTextDraw(playerid, YELLOW);
	}
	if(newkeys & 4)
	{
	    new id;

		id = SelectPrevPlayer(playerid, gPlayerSpectateGroup[playerid]);
		if(id != -1)
		{
			SpectatePlayer(playerid, id);
		}
		PlayerTextDrawColor(playerid, SpecControl_BtnL, YELLOW);
	}
	if(oldkeys & 4)PlayerTextDrawColor(playerid, SpecControl_BtnL, WHITE);

	if(newkeys & 128)
	{
	    new id;

		id = SelectNextPlayer(playerid, gPlayerSpectateGroup[playerid]);
		if(id != -1)
		{
			SpectatePlayer(playerid, id);
		}
		PlayerTextDrawColor(playerid, SpecControl_BtnR, YELLOW);
	}
	if(oldkeys & 128)PlayerTextDrawColor(playerid, SpecControl_BtnR, WHITE);
	
    return 1;
}


SpectatePlayer(playerid, targetid)
{
	if(IsPlayerConnected(targetid))
	{
		new
			world = GetPlayerVirtualWorld(targetid),
			interior = GetPlayerInterior(targetid);

		SetPlayerVirtualWorld(playerid, world);
		SetPlayerInterior(playerid, interior);
		TogglePlayerSpectating(playerid, true);

		if(IsPlayerInAnyVehicle(targetid))PlayerSpectateVehicle(playerid, GetPlayerVehicleID(targetid), gPlayerSpectateMode[playerid]);
		else PlayerSpectatePlayer(playerid, targetid, gPlayerSpectateMode[playerid]);

		if(gPlayerSpectateMode[playerid] == SPECTATE_MODE_FIXED)
		{
			new
				Float:x,
				Float:y,
				Float:z;

			GetPlayerCameraPos(playerid, x, y, z);
			SetPlayerCameraPos(playerid, x, y, z);
		}

		PlayerTextDrawSetString(playerid, SpecControl_Name, gPlayerName[targetid]);
		PlayerTextDrawSetString(playerid, SpecControl_Mode, gSpectateModeNames[gPlayerSpectateMode[playerid]-1]);
		ShowSpectateControls(playerid);

		gPlayerSpectating[playerid] = targetid;
		return 1;
	}
	return 0;
}


FormatSpecGroupList(playerid)
{
	new
		list[MAX_SPECTATE_GROUP * (MAX_SPECTATE_GROUP_NAME+6)],
		str[(MAX_SPECTATE_GROUP_NAME+6)],
		ingrp,
		count;
	
	for(new i;i<MAX_SPECTATE_GROUP;i++)
	{
	    ingrp = GetPlayersInGroup(playerid, i);
	    if(ingrp > 0)
	    {
	        format(str, sizeof(str), "%s (%d)\n", gSpectateGroupNames[i], ingrp);
	        strcat(list, str);
	        gSpectateGroupIndex[count] = i;
	        count++;
	    }
	}

	if(count==0)return 0;
	ShowPlayerDialog(playerid, d_SpectateGroupList, DIALOG_STYLE_LIST, "Spectate", list, "Spectate", "Cancel");
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_SpectateGroupList && response)
	{
		EnterSpectateMode(playerid, gSpectateGroupIndex[listitem]);
	}
}



GetPlayersInGroup(exceptionid, group)
{
	new count;
	if(group == GROUP_ALL)		foreach(new i : Character)if(exceptionid != i)count++;
	if(group == GROUP_FREEROAM)	foreach(new i : Character)if(gCurrentMinigame[i] == MINIGAME_NONE && !(bPlayerGameSettings[i] & InDM) && !(bPlayerGameSettings[i] & InRace) && exceptionid != i)count++;
	if(group == GROUP_DM_RAVEN)	foreach(new i : Character)if(bPlayerGameSettings[i] & InDM && pTeam(i) == TEAM_RAVEN && exceptionid != i)count++;
	if(group == GROUP_DM_VALOR)	foreach(new i : Character)if(bPlayerGameSettings[i] & InDM && pTeam(i) == TEAM_VALOR && exceptionid != i)count++;
	if(group == GROUP_DM_ALL)	foreach(new i : Character)if(bPlayerGameSettings[i] & InDM && exceptionid != i)count++;
	if(group == GROUP_RACE)		foreach(new i : Character)if(bPlayerGameSettings[i] & InRace && exceptionid != i)count++;
	if(group == GROUP_PARKOUR)	foreach(new i : Character)if(gCurrentMinigame[i] == MINIGAME_PARKOUR && exceptionid != i)count++;
	if(group == GROUP_FALLOUT)	foreach(new i : Character)if(gCurrentMinigame[i] == MINIGAME_FALLOUT && exceptionid != i)count++;
	if(group == GROUP_SUMO)		foreach(new i : Character)if(gCurrentMinigame[i] == MINIGAME_CARSUMO && exceptionid != i)count++;
	if(group == GROUP_DERBY)	foreach(new i : Character)if(gCurrentMinigame[i] == MINIGAME_DESDRBY && exceptionid != i)count++;
	return count;
}


ShowSpectateControls(playerid)
{
	PlayerTextDrawShow(playerid, SpecControl_Name);
	PlayerTextDrawShow(playerid, SpecControl_Text);
	PlayerTextDrawShow(playerid, SpecControl_BtnL);
	PlayerTextDrawShow(playerid, SpecControl_BtnR);
	PlayerTextDrawShow(playerid, SpecControl_Mode);
	PlayerTextDrawShow(playerid, SpecControl_Hide);
}
HideSpectateControls(playerid)
{
	PlayerTextDrawHide(playerid, SpecControl_Name);
	PlayerTextDrawHide(playerid, SpecControl_Text);
	PlayerTextDrawHide(playerid, SpecControl_BtnL);
	PlayerTextDrawHide(playerid, SpecControl_BtnR);
	PlayerTextDrawHide(playerid, SpecControl_Mode);
	PlayerTextDrawHide(playerid, SpecControl_Hide);
}

CMD:hud(playerid, params[])
{
	ShowSpectateControls(playerid);
	return 1;
}

