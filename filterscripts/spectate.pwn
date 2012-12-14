#include <a_samp>
#include <YSI\y_va>
#include <formatex>
#include "../scripts/System/PlayerFunctions.pwn"
#include <zcmd>
#include <streamer>
#include <colours>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16


#define GROUP_ALL		(0)
#define GROUP_FREEROAM	(1)
#define GROUP_DM_RAVEN	(2)
#define GROUP_DM_VALOR	(3)
#define GROUP_DM_ALL	(4)
#define GROUP_RACE		(5)
#define GROUP_PARKOUR	(6)
#define GROUP_FALLOUT	(7)
#define GROUP_SUMO		(8)
#define GROUP_DERBY		(9)

new
	PlayerText:SpecControl_Name,
	PlayerText:SpecControl_Text,
	PlayerText:SpecControl_BtnL,
	PlayerText:SpecControl_BtnR,
	PlayerText:SpecControl_Mode,
	PlayerText:SpecControl_Hide;

new
	gPlayerSpectating[MAX_PLAYERS],
	gPlayerSpectateGroup[MAX_PLAYERS],
	gPlayerSpectateMode[MAX_PLAYERS char];

new gSpectateModeNames[3][16]=
{
	"NORMAL",
	"FIXED",
	"SIDE"
};
public OnFilterScriptInit()
{
	for(new i;i<MAX_PLAYERS;i++)
	{
		gPlayerSpectating[i] = -1;
		gPlayerSpectateMode[i] = SPECTATE_MODE_NORMAL;
	}
}
public OnFilterScriptExit()
{
	for(new i;i<MAX_PLAYERS;i++)UnloadPlayerGUI_SpectateButtons(i);
}
CMD:deltd(playerid, params[])
{
    for(new i;i<100;i++)PlayerTextDrawDestroy(playerid, PlayerText:i);
	return 1;
}
CMD:spec(playerid, params[])
{
	if(gPlayerSpectating[playerid] == -1)EnterSpectateMode(playerid, GROUP_ALL);
	else ExitSpectateMode(playerid);
	return 1;
}
EnterSpectateMode(playerid, group)
{
    LoadPlayerGUI_SpectateButtons(playerid);
	ShowSpectateControls(playerid);
	SelectTextDraw(playerid, YELLOW);
	gPlayerSpectateGroup[playerid] = group;
    new id = playerid + 1, iters;
    while(id < MAX_PLAYERS && iters < 100)
    {
        iters++;
        if(id == playerid)continue;
    	if(id == gPlayerSpectating[playerid])break;
        if(IsPlayerConnected(id) && gPlayerSpectating[id] == -1)return SpectatePlayer(playerid, id);
    	if(id == MAX_PLAYERS-1)id=0;
    	id++;
    }
    msg(playerid, YELLOW, " >  Nobody to spectate");
    return 1;
}
ExitSpectateMode(playerid)
{
    UnloadPlayerGUI_SpectateButtons(playerid);
	HideSpectateControls(playerid);
	CancelSelectTextDraw(playerid);
	gPlayerSpectating[playerid] = -1;
	TogglePlayerSpectating(playerid, false);
}
//script_Spectate_ClickTextDraw(playerid, PlayerText:playertextid)
public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(playertextid == SpecControl_BtnL)
	{
	    new id, iters;

		if(gPlayerSpectating[playerid] == 0)id = MAX_PLAYERS-1;
		else id = gPlayerSpectating[playerid] - 1;

	    while(id >= 0 && iters < 100)
	    {
	        iters++;
	        if(id == playerid || !IsPlayerConnected(id))
			{
			    id--;
		    	if(id <= 0)id=MAX_PLAYERS-1;
				continue;
			}

	    	if(id == gPlayerSpectating[playerid])break;
			else return SpectatePlayer(playerid, id);

	    	if(id == 0)id=MAX_PLAYERS-1;
	    	else id--;
	    }
	    return 1;
	}
	if(playertextid == SpecControl_BtnR)
	{
	    new id, iters;

		if(gPlayerSpectating[playerid] == MAX_PLAYERS-1)id = 0;
		else id = gPlayerSpectating[playerid] + 1;

	    while(id < MAX_PLAYERS && iters < 100)
	    {
	        iters++;
	        if(id == playerid || !IsPlayerConnected(id))
			{
			    id++;
		    	if(id >= MAX_PLAYERS-1)id=0;
				continue;
			}

	    	if(id == gPlayerSpectating[playerid])break;
			else return SpectatePlayer(playerid, id);

	    	if(id == MAX_PLAYERS-1)id=0;
	    	else id++;
	    }
	    return 1;
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
        msg(playerid, YELLOW, " >  HUD hidden, type "#C_BLUE"/hud "#C_YELLOW"to show it again");
	}
	return 1;
}
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(gPlayerSpectating[playerid] != -1)
	{
	    if(newkeys & 16)
		{
		    PlayerTextDrawSetString(playerid, SpecControl_Text, "spectating (click for freelook)");
			SelectTextDraw(playerid, YELLOW);
		}
	}
}
SpectatePlayer(playerid, targetid)
{
	if(IsPlayerConnected(targetid))
	{
	    new
			name[MAX_PLAYER_NAME];

	    GetPlayerName(targetid, name, MAX_PLAYER_NAME);
	    PlayerTextDrawSetString(playerid, SpecControl_Name, name);
		TogglePlayerSpectating(playerid, true);
		
        PlayerTextDrawSetString(playerid, SpecControl_Mode, gSpectateModeNames[gPlayerSpectateMode[playerid]-1]);

		if(IsPlayerInAnyVehicle(targetid))PlayerSpectateVehicle(playerid, GetPlayerVehicleID(targetid), gPlayerSpectateMode[playerid]);
		else PlayerSpectatePlayer(playerid, targetid, gPlayerSpectateMode[playerid]);

		gPlayerSpectating[playerid] = targetid;
		return 1;
	}
	return 0;
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



LoadPlayerGUI_SpectateButtons(playerid)
{
	SpecControl_Name				=CreatePlayerTextDraw(playerid, 320.000000, 350.000000, "LongNameTestLongNameTest");
	PlayerTextDrawAlignment			(playerid, SpecControl_Name, 2);
	PlayerTextDrawBackgroundColor	(playerid, SpecControl_Name, 255);
	PlayerTextDrawFont				(playerid, SpecControl_Name, 1);
	PlayerTextDrawLetterSize		(playerid, SpecControl_Name, 0.400000, 2.000000);
	PlayerTextDrawColor				(playerid, SpecControl_Name, -1);
	PlayerTextDrawSetOutline		(playerid, SpecControl_Name, 0);
	PlayerTextDrawSetProportional	(playerid, SpecControl_Name, 1);
	PlayerTextDrawSetShadow			(playerid, SpecControl_Name, 1);
	PlayerTextDrawUseBox			(playerid, SpecControl_Name, 1);
	PlayerTextDrawBoxColor			(playerid, SpecControl_Name, 0x000000AA);
	PlayerTextDrawTextSize			(playerid, SpecControl_Name, 20.000000, 200.000000);

	SpecControl_Text				=CreatePlayerTextDraw(playerid, 320.000000, 336.000000, "spectating (click for freelook)");
	PlayerTextDrawAlignment			(playerid, SpecControl_Text, 2);
	PlayerTextDrawBackgroundColor	(playerid, SpecControl_Text, 255);
	PlayerTextDrawFont				(playerid, SpecControl_Text, 2);
	PlayerTextDrawLetterSize		(playerid, SpecControl_Text, 0.220000, 1.200000);
	PlayerTextDrawColor				(playerid, SpecControl_Text, -1);
	PlayerTextDrawSetOutline		(playerid, SpecControl_Text, 0);
	PlayerTextDrawSetProportional	(playerid, SpecControl_Text, 1);
	PlayerTextDrawSetShadow			(playerid, SpecControl_Text, 1);
	PlayerTextDrawTextSize			(playerid, SpecControl_Text, 10.0, 200.0);
	PlayerTextDrawSetSelectable		(playerid, SpecControl_Text, true);

	SpecControl_BtnL				=CreatePlayerTextDraw(playerid, 202.000000, 347.000000, "<");
	PlayerTextDrawBackgroundColor	(playerid, SpecControl_BtnL, 255);
	PlayerTextDrawFont				(playerid, SpecControl_BtnL, 1);
	PlayerTextDrawLetterSize		(playerid, SpecControl_BtnL, 0.509999, 2.499999);
	PlayerTextDrawColor				(playerid, SpecControl_BtnL, -1);
	PlayerTextDrawSetOutline		(playerid, SpecControl_BtnL, 0);
	PlayerTextDrawSetProportional	(playerid, SpecControl_BtnL, 1);
	PlayerTextDrawSetShadow			(playerid, SpecControl_BtnL, 1);
	PlayerTextDrawTextSize			(playerid, SpecControl_BtnL, 216.0, 20.0);
	PlayerTextDrawSetSelectable		(playerid, SpecControl_BtnL, true);

	SpecControl_BtnR				=CreatePlayerTextDraw(playerid, 426.000000, 347.000000, ">");
	PlayerTextDrawBackgroundColor	(playerid, SpecControl_BtnR, 255);
	PlayerTextDrawFont				(playerid, SpecControl_BtnR, 1);
	PlayerTextDrawLetterSize		(playerid, SpecControl_BtnR, 0.509999, 2.499999);
	PlayerTextDrawColor				(playerid, SpecControl_BtnR, -1);
	PlayerTextDrawSetOutline		(playerid, SpecControl_BtnR, 0);
	PlayerTextDrawSetProportional	(playerid, SpecControl_BtnR, 1);
	PlayerTextDrawSetShadow			(playerid, SpecControl_BtnR, 1);
	PlayerTextDrawTextSize			(playerid, SpecControl_BtnR, 440.0, 20.0);
	PlayerTextDrawSetSelectable		(playerid, SpecControl_BtnR, true);

	SpecControl_Mode				=CreatePlayerTextDraw(playerid, 535.000000, 347.000000, "Mode: Normal");
	PlayerTextDrawAlignment			(playerid, SpecControl_Mode, 2);
	PlayerTextDrawBackgroundColor	(playerid, SpecControl_Mode, 255);
	PlayerTextDrawFont				(playerid, SpecControl_Mode, 2);
	PlayerTextDrawLetterSize		(playerid, SpecControl_Mode, 0.219999, 1.200000);
	PlayerTextDrawColor				(playerid, SpecControl_Mode, -1);
	PlayerTextDrawSetOutline		(playerid, SpecControl_Mode, 0);
	PlayerTextDrawSetProportional	(playerid, SpecControl_Mode, 1);
	PlayerTextDrawSetShadow			(playerid, SpecControl_Mode, 1);
	PlayerTextDrawTextSize			(playerid, SpecControl_Mode, 9.000000, 80.000000);
	PlayerTextDrawSetSelectable		(playerid, SpecControl_Mode, true);

	SpecControl_Hide				=CreatePlayerTextDraw(playerid, 535.000000, 358.000000, "Hide HUD");
	PlayerTextDrawAlignment			(playerid, SpecControl_Hide, 2);
	PlayerTextDrawBackgroundColor	(playerid, SpecControl_Hide, 255);
	PlayerTextDrawFont				(playerid, SpecControl_Hide, 2);
	PlayerTextDrawLetterSize		(playerid, SpecControl_Hide, 0.219999, 1.200000);
	PlayerTextDrawColor				(playerid, SpecControl_Hide, -1);
	PlayerTextDrawSetOutline		(playerid, SpecControl_Hide, 0);
	PlayerTextDrawSetProportional	(playerid, SpecControl_Hide, 1);
	PlayerTextDrawSetShadow			(playerid, SpecControl_Hide, 1);
	PlayerTextDrawTextSize			(playerid, SpecControl_Hide, 9.000000, 80.000000);
	PlayerTextDrawSetSelectable		(playerid, SpecControl_Hide, true);
}
UnloadPlayerGUI_SpectateButtons(playerid)
{
	PlayerTextDrawDestroy(playerid, SpecControl_Name);
	PlayerTextDrawDestroy(playerid, SpecControl_Text);
	PlayerTextDrawDestroy(playerid, SpecControl_BtnL);
	PlayerTextDrawDestroy(playerid, SpecControl_BtnR);
	PlayerTextDrawDestroy(playerid, SpecControl_Mode);
	PlayerTextDrawDestroy(playerid, SpecControl_Hide);
}
