#include <YSI\y_hooks>

#define VEHICLE_LIST_DATA_FILE	"Server/vehiclemenu.dat"
#define MAX_VEH_LIST_CATEGORY	(10)
#define MAX_VEH_LIST_NAME		(8)
#define MAX_VEH_LIST_ITEMS		(32)
#define MAX_VEH_ITEM_NAME		(32)
#define MAX_VEH_RESULTS			(16)

new
	aVehicleMenuCategoryNames	[MAX_VEH_LIST_CATEGORY][MAX_VEH_LIST_NAME],
	aVehicleMenuData			[MAX_VEH_LIST_CATEGORY][MAX_VEH_LIST_ITEMS],
	iTotalVehiclesInList		[MAX_VEH_LIST_CATEGORY],
	gPlayerCurrentVehicleList	[MAX_PLAYERS],
	gVehicleResults				[MAX_VEH_RESULTS];


FormatVehicleIndex(playerid)
{
	new list[MAX_VEH_LIST_CATEGORY * (MAX_VEH_LIST_NAME+1)];
	for(new i;i<MAX_VEH_LIST_CATEGORY;i++)
	{
		strcat(list, aVehicleMenuCategoryNames[i]);
		strcat(list, "\n");
	}
	strcat(list, "Search...");
	ShowPlayerDialog(playerid, d_VehicleIndex, DIALOG_STYLE_LIST, "Vehicles", list, "Open", "Cancel");
}
FormatVehicleList(playerid, index)
{
	new list[MAX_VEH_LIST_ITEMS * (MAX_VEH_ITEM_NAME+1)];
	for(new i;i<iTotalVehiclesInList[index];i++)
	{
		strcat(list, VehicleNames[aVehicleMenuData[index][i]-400]);
		strcat(list, "\n");
	}
	ShowPlayerDialog(playerid, d_VehicleList, DIALOG_STYLE_LIST, aVehicleMenuCategoryNames[index], list, "Spawn", "Back");
}

LoadVehicleMenu()
{
	new
	    File:file,
	    str[32],
		len,
		tmpId,
		categoryIdx = -1;

	if(fexist(VEHICLE_LIST_DATA_FILE))file = fopen(VEHICLE_LIST_DATA_FILE, io_read);
	else return print("VEHICLE MENU DATA FILE NOT FOUND");

	while(fread(file, str))
	{
		len = strlen(str);
		if(str[len-2] == '\r')
		{
			str[len-2] = EOS;
			len -= 2;
	    }

	    if(strfind(str, "category") > -1)
	    {
			categoryIdx++;
			strmid(aVehicleMenuCategoryNames[categoryIdx], str, 9, len);
		}
		else
		{
			tmpId = strval(str);
			if(400 <= tmpId <= 612)
			{
			    aVehicleMenuData[categoryIdx][iTotalVehiclesInList[categoryIdx]] = tmpId;
			    iTotalVehiclesInList[categoryIdx]++;
			}
		}
	}
	return 1;
}

CMD:reloadvehiclemenu(playerid, params[])
{
	for(new i;i<MAX_VEH_LIST_CATEGORY;i++)
	{
		for(new j;j<iTotalVehiclesInList[i];j++)aVehicleMenuData[i][j]=0;
		aVehicleMenuCategoryNames[i][0] = EOS;
		iTotalVehiclesInList[i]=0;
	}

    LoadVehicleMenu();
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_VehicleIndex && response)
	{
	    if(listitem==MAX_VEH_LIST_CATEGORY)
			ShowPlayerDialog(playerid, d_VehicleQuery, DIALOG_STYLE_INPUT, "Vehicle Search", "Enter a Model ID between 400 and 611 (or 0 and 211)\nOr a vehicle name or real life version name:", "Spawn", "Back");

		else
		{
	    	FormatVehicleList(playerid, listitem);
	    	gPlayerCurrentVehicleList[playerid] = listitem;
	    }
	}
	if(dialogid == d_VehicleList)
	{
	    if(response)
	    {
			SpawnCarForPlayer(playerid, aVehicleMenuData[gPlayerCurrentVehicleList[playerid]][listitem]);
	        gPlayerCurrentVehicleList[playerid] = -1;
        }
	    else FormatVehicleIndex(playerid);
	}
	if(dialogid == d_VehicleQuery)
	{
	    if(response)
	    {
	        new result = FormatVehicleSearchDialog(playerid, inputtext);

			if(result == -2)ShowPlayerDialog(playerid, d_VehicleQuery, DIALOG_STYLE_INPUT, "Vehicle Search", "Enter a model id between 400 and 611 (or 0 and 211)\n\nError: Vehicle Not Found!", "Spawn", "Back");
			else if(result == -3)ShowPlayerDialog(playerid, d_VehicleQuery, DIALOG_STYLE_INPUT, "Vehicle Search", "Enter a model id between 400 and 611 (or 0 and 211)\n\nError: Query Too Short!", "Spawn", "Back");
			else
			{
				if(400 <= result <= 611)SpawnCarForPlayer(playerid, result);
				else if(0 <= result <= 211)SpawnCarForPlayer(playerid, result+400);
			}
        }
	    else FormatVehicleIndex(playerid);
	}
	if(dialogid == d_VehicleResults)
	{
	    if(response)SpawnCarForPlayer(playerid, gVehicleResults[listitem]);
	    else ShowPlayerDialog(playerid, d_VehicleQuery, DIALOG_STYLE_INPUT, "Vehicle Search", "Enter a model id between 400 and 611 (or 0 and 211)", "Spawn", "Back");
	}
}

FormatVehicleSearchDialog(playerid, query[])
{
	new
		list[MAX_VEH_RESULTS * (32 + 2 + 32 + 3)],
		tmp[(32 + 2 + 32 + 3)],
		id;

	if(IsNumeric(query))
	{
	    id = strval(query);
		if(400 <= id <= 611)return id;
		else if(0 <= id <= 211)return id+400;
	}
	else
	{
	    new count;
	    if(strlen(query) < 2)return -3;
		while(id < 212 && count < MAX_VEH_RESULTS)
		{
			if(
				(strfind(VehicleNames[id], query, true) != -1) ||
				(strfind(RealVehicleNames[id], query, true) != -1) )
			{
			    format(tmp, sizeof(tmp), "%s (%s)\n", VehicleNames[id], RealVehicleNames[id]);
			    strcat(list, tmp);
			    gVehicleResults[count] = id+400;
			    count++;
			}
			id++;
		}
		if(!count) return -2;
		else
		{
		    if(count == 1)return gVehicleResults[0];
			else
			{
				ShowPlayerDialog(playerid, d_VehicleResults, DIALOG_STYLE_LIST, "Search Results", list, "Spawn", "Back");
				return -4;
			}
		}
	}
	return -2;
}

