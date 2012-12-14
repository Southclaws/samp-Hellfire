#include <a_samp>
#include <sscanf2>
#include <zcmd>
#include "../scripts/Resources/VehicleResources.pwn"
#include "../scripts/System/PlayerFunctions.pwn"
#include <colours>

#define d_VehicleSearchResults 1000


CMD:search(playerid, params[])
{
	new result = FormatSearchDialog(playerid, params);
	if(result == -1)msg(playerid, -1, "return -1; = Vehicle Found");
	else if(result == -2)msg(playerid, -1, "return -2; = Vehicle Not Found");
	else if(result == -3)msg(playerid, -1, "return -3; = Query Too Short");
	else if(result == -4)msg(playerid, -1, "return -4; = Should show the dialog with vehicle list!");
	else
	{
		if(400 <= result <= 611)msgF(playerid, -1, "return %d; Spawning a %s", result, VehicleNames[result-400]);
		else if(0 <= result <= 211)msgF(playerid, -1, "return %d; Spawning a %s", result, VehicleNames[result]);
		else msgF(playerid, -1, "return %d; UNKNOWN RETURN VALUE!", result);
	}
	return 1;
}


FormatSearchDialog(playerid, query[])
{
	new
		list[16 * (32 + 2 + 32 + 3)],
		tmp[(32 + 2 + 32 + 3)],
		id;

	msgF(playerid, YELLOW, "Searching for: '%s'", query);
	if(IsNumeric(query))
	{
	    id = strval(query);
		if(400 <= id <= 611)
		{
		    msgF(playerid, YELLOW, "%s (%s) - [Vehicle ID 400-611 detected]",
				VehicleNames[id-400], RealVehicleNames[id-400]);
			return id;
		}
		else if(0 <= id <= 211)
		{
		    msgF(playerid, YELLOW, "%s (%s) - [Vehicle ID 0-211 detected]",
				VehicleNames[id], RealVehicleNames[id]);
			return id;
		}
	}
	else
	{
	    new count;
	    if(strlen(query) < 2)return -3;
		while(id < 212)
		{
			if(
				(strfind(VehicleNames[id], query, true) != -1) ||
				(strfind(RealVehicleNames[id], query, true) != -1) )
			{
			    format(tmp, sizeof(tmp), "%s (%s)\n", VehicleNames[id], RealVehicleNames[id]);
			    msg(playerid, -1, tmp);
			    strcat(list, tmp);
			    count++;
			}
			id++;
		}
		if(!count) return -2;
		else
		{
		    if(count == 1)return id;
			else
			{
				ShowPlayerDialog(playerid, d_VehicleSearchResults, DIALOG_STYLE_LIST, "Search Results", list, "Spawn", "Cancel");
				return -4;
			}
		}
	}
	return -2;
}

stock IsNumeric(const string[])
{
	for(new i,j=strlen(string);i<j;i++)if (string[i] > '9' || string[i] < '0') return 0;
	return 1;
}

