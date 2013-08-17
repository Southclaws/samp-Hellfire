#include <YSI\y_hooks>

#define WEAPON_DATA_FILE		"Server/weaponmenu.dat"
#define MAX_WEP_LIST_CATEGORY	(8)
#define MAX_WEP_LIST_NAME		(8)
#define MAX_WEP_LIST_ITEMS		(11)
#define MAX_WEP_ITEM_NAME		(32)
#define MAX_WEP_RESULTS			(16)


new
	aWeaponMenuCategoryNames	[MAX_WEP_LIST_CATEGORY][MAX_WEP_LIST_NAME],
	aWeaponMenuData				[MAX_WEP_LIST_CATEGORY][MAX_WEP_LIST_ITEMS],
	iTotalWeaponsInList			[MAX_WEP_LIST_CATEGORY],
	gPlayerCurrentWeaponList	[MAX_PLAYERS],
	gWeaponResults				[MAX_WEP_RESULTS];


FormatWeaponIndex(playerid)
{
	new list[MAX_WEP_LIST_CATEGORY * (MAX_WEP_LIST_NAME+1)];
	for(new i;i<MAX_WEP_LIST_CATEGORY;i++)
	{
		strcat(list, aWeaponMenuCategoryNames[i]);
		strcat(list, "\n");
	}
	strcat(list, "Search...");
	ShowPlayerDialog(playerid, d_WeaponIndex, DIALOG_STYLE_LIST, "Weapons", list, "Open", "Cancel");
}
FormatWeaponList(playerid, index)
{
	new list[MAX_WEP_LIST_ITEMS * (MAX_WEP_ITEM_NAME+1)];
	for(new i;i<iTotalWeaponsInList[index];i++)
	{
		strcat(list, WepData[aWeaponMenuData[index][i]][WepName]);
		strcat(list, "\n");
	}
	ShowPlayerDialog(playerid, d_WeaponList, DIALOG_STYLE_LIST, aWeaponMenuCategoryNames[index], list, "Spawn", "Back");
}

LoadWeaponMenu()
{
	new
	    File:file,
	    str[32],
		len,
		tmpId,
		categoryIdx = -1;

	if(fexist(WEAPON_DATA_FILE))file = fopen(WEAPON_DATA_FILE, io_read);
	else return print("WEAPON MENU DATA FILE NOT FOUND");

	while(fread(file, str))
	{
	    strtrim(str);
	    len = strlen(str);
	    if(strfind(str, "category") > -1)
	    {
			categoryIdx++;
			strmid(aWeaponMenuCategoryNames[categoryIdx], str, 9, len);
		}
		if(isnumeric(str))
		{
			tmpId = strval(str);
			if(0 <= tmpId <= WEAPON_PARACHUTE)
			{
			    aWeaponMenuData[categoryIdx][iTotalWeaponsInList[categoryIdx]] = tmpId;
			    iTotalWeaponsInList[categoryIdx]++;
			}
		}
	}
	return 1;
}

CMD:reloadweaponmenu(playerid, params[])
{
	for(new i;i<MAX_WEP_LIST_CATEGORY;i++)
	{
		for(new j;j<iTotalWeaponsInList[i];j++)aWeaponMenuData[i][j]=0;
		aWeaponMenuCategoryNames[i][0] = EOS;
		iTotalWeaponsInList[i]=0;
	}

    LoadWeaponMenu();
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_WeaponIndex && response)
	{
	    if(listitem==MAX_WEP_LIST_CATEGORY)
			ShowPlayerDialog(playerid, d_WeaponQuery, DIALOG_STYLE_INPUT, "Weapon Search", "Enter a weapon ID or name:", "Spawn", "Back");

		else
		{
	    	FormatWeaponList(playerid, listitem);
	    	gPlayerCurrentWeaponList[playerid] = listitem;
	    }
	}
	if(dialogid == d_WeaponList)
	{
	    if(response)
	    {
	        new id = aWeaponMenuData[gPlayerCurrentWeaponList[playerid]][listitem];
			GivePlayerWeapon(playerid, id, WepData[id][MagSize] * 6);
	        gPlayerCurrentWeaponList[playerid] = -1;
        }
	    else FormatWeaponIndex(playerid);
	}
	if(dialogid == d_WeaponQuery)
	{
	    if(response)
	    {
	        new result = FormatWeaponSearchDialog(playerid, inputtext);

			if(result == -2)ShowPlayerDialog(playerid, d_WeaponQuery, DIALOG_STYLE_INPUT, "Weapon Search", "Enter a weapon ID or name:\n\nError: Weapon Not Found!", "Spawn", "Back");
			else if(result == -3)ShowPlayerDialog(playerid, d_WeaponQuery, DIALOG_STYLE_INPUT, "Weapon Search", "Enter a weapon ID or name:\n\nError: Query Too Short!", "Spawn", "Back");
			else if(0 <= result <= WEAPON_PARACHUTE)GivePlayerWeapon(playerid, result, WepData[result][MagSize] * 6);
        }
	    else FormatWeaponIndex(playerid);
	}
	if(dialogid == d_WeaponResults)
	{
	    if(response)GivePlayerWeapon(playerid, gWeaponResults[listitem], WepData[gWeaponResults[listitem]][MagSize] * 6);
	    else ShowPlayerDialog(playerid, d_WeaponQuery, DIALOG_STYLE_INPUT, "Weapon Search", "Enter a weapon ID or name:", "Spawn", "Back");
	}
}

FormatWeaponSearchDialog(playerid, query[])
{
	new
		list[MAX_WEP_RESULTS * (32 + 2 + 32 + 3)],
		tmp[(32 + 2 + 32 + 3)],
		id;

	if(isnumeric(query))
	{
	    id = strval(query);
		if(0 <= id <= WEAPON_PARACHUTE)return id;
	}
	else
	{
	    new count;
	    if(strlen(query) < 2)return -3;
		while(id < 48 && count < MAX_WEP_RESULTS)
		{
			if(strfind(WepData[id][WepName], query, true) != -1)
			{
			    format(tmp, sizeof(tmp), "%s (%d)\n", WepData[id][WepName], id);
			    strcat(list, tmp);
			    gWeaponResults[count] = id;
			    count++;
			}
			id++;
		}
		if(!count) return -2;
		else
		{
		    if(count == 1)return gWeaponResults[0];
			else
			{
				ShowPlayerDialog(playerid, d_WeaponResults, DIALOG_STYLE_LIST, "Search Results", list, "Spawn", "Back");
				return -4;
			}
		}
	}
	return -2;
}

