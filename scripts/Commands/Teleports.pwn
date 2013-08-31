#include <YSI\y_hooks>

#define MAX_TELEPORTS					(64)
#define TELEPORT_DATA_FILE				"Server/teleports.dat"
#define MAX_TELEPORT_LIST_CATEGORY		(6)
#define MAX_TELEPORT_LIST_NAME			(8)
#define MAX_TELEPORT_LIST_ITEMS			(15)
#define MAX_TELEPORT_ITEM_NAME			(32)
#define MAX_TELEPORT_RESULTS			(16)

enum E_TELEPORT_DATA
{
		tp_Cmd[32],
		tp_Name[32],
Float:	tp_PosX,
Float:	tp_PosY,
Float:	tp_PosZ,
Float:  tp_Rot,
		tp_Freeze
}
new
	TeleportData				[MAX_TELEPORTS][E_TELEPORT_DATA],
	TotalTeleports,

	aTeleportMenuCategoryNames	[MAX_TELEPORT_LIST_CATEGORY][MAX_TELEPORT_LIST_NAME],
	aTeleportMenuData			[MAX_TELEPORT_LIST_CATEGORY][MAX_TELEPORT_LIST_ITEMS],
	iTotalTeleportsInList		[MAX_TELEPORT_LIST_CATEGORY],
	gPlayerCurrentTeleportList	[MAX_PLAYERS],
	gPlayerTeleportMessageTick	[MAX_PLAYERS][MAX_TELEPORTS],
	gTeleportResults			[MAX_TELEPORT_RESULTS];


script_Teleports_CommandText(playerid, cmd[])
{
	if(cmd[1] == EOS)return 0;
	for(new i; i < TotalTeleports; i++)
	{
		if(!strcmp(cmd[1], TeleportData[i][tp_Cmd], true))
		{
			TeleportPlayer(playerid, i);
			return 1;
		}
	}
	return 0;
}
TeleportPlayer(playerid, id)
{
	new
	    Float:x = TeleportData[id][tp_PosX],
	    Float:y = TeleportData[id][tp_PosY],
	    Float:z = TeleportData[id][tp_PosZ];

	Streamer_UpdateEx(playerid, x, y, z, 0, 0);

	if(GetPlayerState(playerid)==PLAYER_STATE_DRIVER)
	{
		new vehicleid = GetPlayerVehicleID(playerid);

		SetVehiclePos(vehicleid, x, y, z);
		SetPlayerPos(playerid, x, y, z);
		PutPlayerInVehicle(playerid, vehicleid, 0);
	}
	else SetPlayerPos(playerid, x, y, z);

	SetCameraBehindPlayer(playerid);

	if(TeleportData[id][tp_Freeze])
		FreezePlayer(playerid, 3000);

	if(GetTickCount() - gPlayerTeleportMessageTick[playerid][id] > 5000)
	{
		PlayerLoop(i)if(IsPlayerInFreeRoam(i))
		{
			MsgF(i, LGREEN, " >  %P"#C_LGREEN" Has gone to "#C_BLUE"%s "#C_YELLOW"(/%s)",
				playerid, TeleportData[id][tp_Name], TeleportData[id][tp_Cmd]);
		}

		gPlayerTeleportMessageTick[playerid][id] = GetTickCount();
	}
}



FormatTeleportIndex(playerid)
{
	new list[MAX_TELEPORT_LIST_CATEGORY * (MAX_TELEPORT_LIST_NAME+1)];
	for(new i;i<MAX_TELEPORT_LIST_CATEGORY;i++)
	{
		strcat(list, aTeleportMenuCategoryNames[i]);
		strcat(list, "\n");
	}
	strcat(list, "Search...");
	ShowPlayerDialog(playerid, d_TeleportIndex, DIALOG_STYLE_LIST, "Teleports", list, "Open", "Cancel");
}
FormatTeleportList(playerid, index)
{
	new list[MAX_TELEPORT_LIST_ITEMS * (MAX_TELEPORT_ITEM_NAME+1)];
	for(new i;i<iTotalTeleportsInList[index];i++)
	{
		strcat(list, TeleportData[aTeleportMenuData[index][i]][tp_Name]);
		strcat(list, "\n");
	}
	ShowPlayerDialog(playerid, d_TeleportList, DIALOG_STYLE_LIST, aTeleportMenuCategoryNames[index], list, "Spawn", "Back");
}

LoadTeleportMenu()
{
	new
	    File:file,
	    line[128],
		len,
		idx,
		categoryIdx = -1;

	if(fexist(TELEPORT_DATA_FILE))file = fopen(TELEPORT_DATA_FILE, io_read);
	else return print("TELEPORT MENU DATA FILE NOT FOUND");

	while(fread(file, line))
	{
	    strtrim(line);
		len = strlen(line);
	    if(strfind(line, "category") > -1)
	    {
			categoryIdx++;
			strmid(aTeleportMenuCategoryNames[categoryIdx], line, 9, len);
		}
		else if(!sscanf(line, "e<p<,>s[32]s[32]ffffd>", TeleportData[idx]))
		{
		    aTeleportMenuData[categoryIdx][iTotalTeleportsInList[categoryIdx]] = idx;
			iTotalTeleportsInList[categoryIdx]++;
			idx++;
		}
	}
	printf("Loaded %d Teleports", idx);
	TotalTeleports = idx;
	return 1;
}

CMD:reloadtpmenu(playerid, params[])
{
	for(new i;i<MAX_TELEPORT_LIST_CATEGORY;i++)
	{
		for(new j;j<iTotalTeleportsInList[i];j++)aTeleportMenuData[i][j]=0;
		aTeleportMenuCategoryNames[i][0] = EOS;
		iTotalTeleportsInList[i]=0;
	}

    LoadTeleportMenu();
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_TeleportIndex && response)
	{
		if(listitem==MAX_TELEPORT_LIST_CATEGORY)
			ShowPlayerDialog(playerid, d_TeleportQuery, DIALOG_STYLE_INPUT, "Teleport Search", "Enter a location name:", "Search", "Back");

		else
		{
			FormatTeleportList(playerid, listitem);
			gPlayerCurrentTeleportList[playerid] = listitem;
		}
	}
	if(dialogid == d_TeleportList)
	{
	    if(response)
	    {
			TeleportPlayer(playerid, aTeleportMenuData[gPlayerCurrentTeleportList[playerid]][listitem]);
	        gPlayerCurrentTeleportList[playerid] = -1;
        }
	    else FormatTeleportIndex(playerid);
	}
	if(dialogid == d_TeleportQuery)
	{
	    if(response)
	    {
	        new result = FormatTeleportSearchDialog(playerid, inputtext);

			if(result == -2)ShowPlayerDialog(playerid, d_TeleportQuery, DIALOG_STYLE_INPUT, "Teleport Search", "Enter a location name:\n\nError: Location not found!", "Spawn", "Back");
			else if(result == -3)ShowPlayerDialog(playerid, d_TeleportQuery, DIALOG_STYLE_INPUT, "Teleport Search", "Enter a location name:\n\nError: Query too short!", "Spawn", "Back");
			else if(0 <= result <= MAX_TELEPORTS)TeleportPlayer(playerid, result);
        }
	    else FormatTeleportIndex(playerid);
	}
	if(dialogid == d_TeleportResults)
	{
	    if(response)TeleportPlayer(playerid, gTeleportResults[listitem]);
	    else ShowPlayerDialog(playerid, d_TeleportQuery, DIALOG_STYLE_INPUT, "Teleport Search", "Enter a location name:", "Spawn", "Back");
	}
	return 1;
}

FormatTeleportSearchDialog(playerid, query[])
{
	new
		list[MAX_TELEPORT_RESULTS * (32 + 2 + 32 + 3)],
		tmp[(32 + 2 + 32 + 3)],
		id;

	if(isnumeric(query))
	{
	    id = strval(query);
		if(0 <= id <= TotalTeleports)return id;
	}
	else
	{
	    new count;
	    if(strlen(query) < 2)return -3;
		while(id < 48 && count < MAX_TELEPORT_RESULTS)
		{
			if(strfind(TeleportData[id][tp_Name], query, true) != -1)
			{
			    format(tmp, sizeof(tmp), "%s\n", TeleportData[id][tp_Name]);
			    strcat(list, tmp);
			    gTeleportResults[count] = id;
			    count++;
			}
			id++;
		}
		if(!count) return -2;
		else
		{
		    if(count == 1)return gTeleportResults[0];
			else
			{
				ShowPlayerDialog(playerid, d_TeleportResults, DIALOG_STYLE_LIST, "Search Results", list, "Spawn", "Back");
				return -4;
			}
		}
	}
	return -2;
}
CMD:teles(playerid, params[])
{
	if(!IsPlayerInFreeRoam(playerid))return 2;
	FormatTeleportIndex(playerid);
	return 1;
}


/*
CMD:places(playerid, params[])
{
    new str[512];
	strcat(str, "/home - return to your home spawnpoint\n");
	strcat(str, "/ls - los santos\n");
	strcat(str, "/sf - san fierro\n");
	strcat(str, "/lv - las venturas\n");
	strcat(str, "/lsair - LS airport\n");
	strcat(str, "/sfair - SF airport\n");
	strcat(str, "/lvair - LV airport\n");
	strcat(str, "/area69 - Area 69\n");
	strcat(str, "/airbase - Area 69 airfield\n");
	strcat(str, "/aa - Abandonded Airport\n");
	strcat(str, "/ch - Mount Chilliad\n");
	strcat(str, "/qu - Hunter Quarry\n");
	strcat(str, "/bay - Bayside Fishing Village\n");
	strcat(str, "/ear - The Big Ear satalite\n");
	strcat(str, "/probe - Li'l Probe Inn\n");
	ShowPlayerDialog(playerid, d_Places, DIALOG_STYLE_MSGBOX, "Cities, Towns, Airports and Places of interest", str, "Close", "");
	return 1;
}
CMD:drifts(playerid, params[])
{
    new str[118];
	strcat(str, "/drift1 - The Big Ear stalite telescope\n");
	strcat(str, "/drift2 - Radio antenna near san fierro\n");
	strcat(str, "/drift3 - Drift road in south country\n");
	ShowPlayerDialog(playerid, d_Drifts, DIALOG_STYLE_MSGBOX, "Drift Road List", str, "Close", "");
	return 1;
}
CMD:jumps(playerid, params[])
{
    new str[179];
	strcat(str, "/bigjump1 - Big Jump 1 at LV Airport\n");
	strcat(str, "/bigjump2 - Big Jump 2 at LV Airport\n");
	strcat(str, "/hugejump - HUGE jump landing you at SF Airport [maybe further if you go fast enough!]\n");
	strcat(str, "/halfhugejump - Half way down the huge jump\n");
	ShowPlayerDialog(playerid, d_Jumps, DIALOG_STYLE_MSGBOX, "Stunt Jumps List", str, "Close", "");
	return 1;
}
CMD:tuning(playerid, params[])
{
    new str[148];
	strcat(str, "/modls - Transfender Los Santos\n");
	strcat(str, "/modsf - Transfender San Fierro\n");
	strcat(str, "/modlv - Transfender Las Venturas\n");
	strcat(str, "/waa - Wheel arch angles in San Fierro\n");
	strcat(str, "/loco - Loco Low Co. Lowrider pimping shop\n");
	ShowPlayerDialog(playerid, d_Tuning, DIALOG_STYLE_MSGBOX, "Tuning Shops List", str, "Close", "");
	return 1;
}
*/

