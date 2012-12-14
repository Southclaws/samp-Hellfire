#include <a_samp>
#include <formatex>
#include <zcmd>
#include <colours>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16

#define MAX_SLOT 8

new
	veh,
	
	editing[MAX_PLAYERS],

    TotalSlot = 1,

    racename[32],
	Float:rot,
	Float:offset = 90.0,
	Float:startpos[3],
	Float:slotx[MAX_SLOT],
	Float:sloty[MAX_SLOT],
	Float:slotz[MAX_SLOT],

	editSlot = 1,
	Float:slotDist[MAX_SLOT],

	slotCar[MAX_SLOT];

new const
	Float:rc_FinishLocPos[10][3]=
	{
		{-2504.467041, 2420.883789, 16.249454},
		{-221.315994, 2634.838378, 62.516883},
		{2048.720947, 1545.601196, 10.503570},
		{-2853.802001, 465.324096, 4.102130},
		{225.974609, 970.993408, 27.908227},
		{2340.568115, 320.036682, 32.374656},
		{-1762.798339, -580.206115, 16.058029},
		{-2144.647216, -2411.305419, 30.184822},
		{86.070411, -1536.633300, 5.259685},
		{2866.315429, -1658.848632, 10.591567}
	},
	rc_FinishLocName[10][33]=
	{
		"Bayside",
		"Las Payasdas",
		"Las Venturas Strip",
		"San Fierro Westside",
		"Fort Carson Cluckin Bell",
		"Palomino Creek Freeway Junction",
		"Easter Bay Airport Entrance",
		"Angel Pine Crossroads",
		"Los Santos West Bridge",
		"Los Santos Stadium"
	};

public OnFilterScriptInit()
{
	for(new i;i<MAX_SLOT;i++)
	{
		slotCar[i] = CreateVehicle(411, 0.0, 0.0, 10.0,  0.0,  -1, -1,  -1);
	}
}
public OnFilterScriptExit()
{
	for(new i;i<MAX_SLOT;i++)
	{
	    DestroyVehicle(slotCar[i]);
	}
}
CMD:racestart(playerid, params[])
{
	if(IsPlayerInAnyVehicle(playerid))GetVehiclePos(GetPlayerVehicleID(playerid), startpos[0], startpos[1], startpos[2]);
	else GetPlayerPos(playerid, startpos[0], startpos[1], startpos[2]);
	SendClientMessage(playerid, -1, "Start CP pos set");
	return 1;
}
CMD:makerace(playerid, params[])
{
    editing[playerid] = true;

	veh = GetPlayerVehicleID(playerid);

	GetVehiclePos(veh, slotx[0], sloty[0], slotz[0]);
	GetVehicleZAngle(veh, rot);
	
	for(new i;i<MAX_SLOT;i++)
	{
		slotDist[i] = (i*5.0);
	    slotx[i] = slotx[0] + (slotDist[i]*floatsin(-rot+offset, degrees));
		sloty[i] = sloty[0] + (slotDist[i]*floatcos(-rot+offset, degrees));
		slotz[i] = slotz[0];
	}
	
	TotalSlot = 2;

	new e, l, a, d, bon, boot, o;
	GetVehicleParamsEx(veh, e, l, a, d, bon, boot, o);
	SetVehicleParamsEx(veh, 0, l, a, d, bon, boot, o);

	return 1;
}
CMD:left(playerid, params[])
{
	offset = 270.0;
	for(new i=1;i<MAX_SLOT;i++)
	{
		slotDist[i] = (i*5.0);
	    slotx[i] = slotx[0] + (slotDist[i]*floatsin(-rot+offset, degrees));
		sloty[i] = sloty[0] + (slotDist[i]*floatcos(-rot+offset, degrees));
		slotz[i] = slotz[0];
	}
	return 1;
}
CMD:right(playerid, params[])
{
	offset = 90.0;
	for(new i=1;i<MAX_SLOT;i++)
	{
		slotDist[i] = (i*5.0);
	    slotx[i] = slotx[0] + (slotDist[i]*floatsin(-rot+offset, degrees));
		sloty[i] = sloty[0] + (slotDist[i]*floatcos(-rot+offset, degrees));
		slotz[i] = slotz[0];
	}
	return 1;
}
CMD:slots(playerid, params[])
{
    TotalSlot = strval(params);
	return 1;
}
CMD:editslot(playerid, params[])
{
	editSlot = strval(params);
	return 1;
}
CMD:slotdis(playerid, params[])
{
    slotDist[editSlot] = floatstr(params);
    return 1;
}

CMD:finishicons(playerid, params[])
{
	for(new i;i<10;i++)SetPlayerMapIcon(playerid, playerid+i, rc_FinishLocPos[i][0], rc_FinishLocPos[i][1], rc_FinishLocPos[i][2], 0, -1, MAPICON_GLOBAL);
}

CMD:saverace(playerid, params[])
{
	if(startpos[0]==0.0 && startpos[1]==0.0)SendClientMessage(playerid, -1, "Please set CP pos");
	if(strlen(params) < 3 || strlen(params) >=32)SendClientMessage(playerid, -1, "Invalid name length");
	else
	{
		format(racename, 32, params);
		FormatFinishPosList(playerid);
	}
	return 1;
}
FormatFinishPosList(playerid)
{
	new list[256];
	for(new i;i<10;i++)
	{
	    strcat(list, rc_FinishLocName[i]);
	    strcat(list, "\n");
	}
	ShowPlayerDialog(playerid, 9000, DIALOG_STYLE_LIST, "Select a finish position", list, "Accept", "Cancel");
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == 9000 && response)
	{
	    SaveRace(playerid, racename, listitem);
	}
}

SaveRace(playerid, name[], finishpos)
{
	new
	    File:f,
	    file[128],
	    str[256];

	format(file, 128, "Races/%s.ini", name);
	f=fopen(file, io_write);

	format(str, 256, "MaxPlayers=%d \r\n", TotalSlot);
	fwrite(f, str);
	format(str, 256, "FinishPos=%d \r\n", finishpos);
	fwrite(f, str);

	for(new i;i<TotalSlot;i++)
	{
	    format(str, 256, "Slot%d=%f, %f, %f, %f\r\n", i, slotx[i], sloty[i], slotz[i], rot);
		fwrite(f, str);
	}

	fclose(f);
	f=fopen("Races/index.ini", io_append);
	format(str, 256, "%s, %f, %f, %f\r\n", name, startpos[0], startpos[1], startpos[2]);
	fwrite(f, str);
	fclose(f);

	ResetVars(playerid);
	
	SendClientMessage(playerid, -1, "Race saved successfully");
}

public OnPlayerUpdate(playerid)
{
	new k, ud, lr;
	GetPlayerKeys(playerid, k, ud, lr);
	
	if(!editing[playerid])return 1;
	
	if(!IsPlayerInAnyVehicle(playerid))return 1;
	
	if(ud == KEY_UP)
	{
		slotDist[editSlot] = slotDist[editSlot] + 0.5;
	}
	if(ud == KEY_DOWN)
	{
		slotDist[editSlot] = slotDist[editSlot] - 0.5;
	}

	if(lr == KEY_LEFT)
	{
		rot+=1.0;
		SetVehicleZAngle(veh, rot);
	}
	if(lr == KEY_RIGHT)
	{
		rot-=1.0;
		SetVehicleZAngle(veh, rot);
	}
	
	new str[128];
	format(str, 128, "Editing Slot: %d~n~dist: %f~n~Rot: %f", editSlot, slotDist[editSlot], rot);
	CallRemoteFunction("sffa_msgbox", "dsdd", playerid, str, 0, 150);

	for(new i=1;i<MAX_SLOT;i++)
	{
		slotx[i] = slotx[0] + slotDist[i] * floatsin(-rot+offset, degrees);
		sloty[i] = sloty[0] + slotDist[i] * floatcos(-rot+offset, degrees);

		SetVehicleZAngle(slotCar[i], rot);
		SetVehiclePos(slotCar[i], slotx[i], sloty[i], slotz[i]);
		
		if(i>=TotalSlot)
		{
			SetVehiclePos(slotCar[i], 0.0, 0.0, 0.0);
		}
	}
	
	SetVehiclePos(veh, slotx[0], sloty[0], slotz[0]);
	
	return 1;
}

ResetVars(playerid)
{
    
    racename[0] = EOS;

	for(new i=1;i<MAX_SLOT;i++)
	{
	    slotx[i] = 0.0;
		sloty[i] = 0.0;
		slotz[i] = 10.0;
	}
    editing[playerid] = false;

	TotalSlot = 2;

	new e, l, a, d, bon, boot, o;
	GetVehicleParamsEx(veh, e, l, a, d, bon, boot, o);
	SetVehicleParamsEx(veh, 1, l, a, d, bon, boot, o);
}
