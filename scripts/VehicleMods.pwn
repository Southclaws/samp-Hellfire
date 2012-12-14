#include <YSI\y_hooks>

enum E_WHEEL_MOD_DATA
{
	wheel_id,
	wheel_name[10]
}
new VehicleWheelData[17][E_WHEEL_MOD_DATA]=
{
	{1073, "Shadow"},
	{1074, "Mega"},
	{1075, "Rimshine"},
	{1076, "Wires"},
	{1077, "Classic"},
	{1078, "Twist"},
	{1079, "Cutter"},
	{1080, "Switch"},
	{1081, "Grove"},
	{1082, "Import"},
	{1083, "Dollar"},
	{1084, "Trance"},
	{1085, "Atomic"},
	{1096, "Ahab"},
	{1097, "Virtual"},
	{1098, "Access"},
	{1025, "Offroad"}
};

enum E_VEHICLE_COLOUR_DATA
{
	colour_id,
	colour_name[8]
}
new VehicleColourData[8][E_VEHICLE_COLOUR_DATA]=
{
	{0, "Black"},
	{1, "White"},
	{7, "Blue"},
	{3, "Red"},
	{6, "Yellow"},
	{86, "Green"},
	{126, "Pink"},
	{148, "Purple"}
};




ShowModMenu(playerid)
{
	ShowPlayerDialog(playerid, d_eVehicleMod, DIALOG_STYLE_LIST, "Choose some mods for your car", "Nitro\nHydraulics\nWheels\nColours\nPaintjobs", "Select", "Cancel");
}
ShowWheelMenu(playerid)
{
	new str[170];
	for(new x;x<sizeof(VehicleWheelData);x++)format(str, 170, "%s\n%s", str, VehicleWheelData[x][wheel_name]);
	ShowPlayerDialog(playerid, d_eWheels, DIALOG_STYLE_LIST, "Choose some wheels to add to your vehicle", str, "Select", "Cancel");
}
ShowColourMenu(playerid)
{
	new str[256];
	for(new x;x<sizeof(VehicleColourData);x++)
	{
		strcat(str, VehicleColourData[x][colour_name]);
		strcat(str, "\n");
	}
	ShowPlayerDialog(playerid, d_eColours, DIALOG_STYLE_LIST, "Choose vehicle "#C_FFFF00"colours", str, "Set", "Cancel");
}
ShowPaintjobMenu(playerid)
{
	ShowPlayerDialog(playerid, d_ePaintjob, DIALOG_STYLE_LIST, "Choose a vehicle "#C_FFFF00"Paintjob", "Paintjob 1\nPaintjob 2\nPaintjob 3", "Set", "Cancel");
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_eVehicleMod && response)
	{
		switch(listitem)
		{
			case 0:
			{
			    new
					vehicleid = GetPlayerVehicleID(playerid),
					component;

				component = GetVehicleComponentInSlot(vehicleid, CARMODTYPE_NITRO);

			    if(component == 1008 || component == 1009 || component == 1010)
			        RemoveVehicleComponent(vehicleid, component);
				else
					AddVehicleComponent(vehicleid, 1010);

				PlayerPlaySound(playerid, 1133, 0, 0, 0);
				ShowModMenu(playerid);
			}
			case 1:
			{
			    new vehicleid = GetPlayerVehicleID(playerid);

			    if(GetVehicleComponentInSlot(vehicleid, CARMODTYPE_HYDRAULICS) == 1087)
			        RemoveVehicleComponent(vehicleid, 1087);
				else
					AddVehicleComponent(vehicleid, 1087);

				PlayerPlaySound(playerid, 1133, 0, 0, 0);
				ShowModMenu(playerid);
			}
			case 2:ShowWheelMenu(playerid);
			case 3:ShowColourMenu(playerid);
			case 4:ShowPaintjobMenu(playerid);
		}
	}
	if(dialogid == d_eWheels && response)
	{
		AddVehicleComponent(GetPlayerVehicleID(playerid), VehicleWheelData[listitem][wheel_id]);
		PlayerPlaySound(playerid, 1133, 0, 0, 0);
		ShowModMenu(playerid);
	}
	if(dialogid == d_eColours && response)
	{
		ChangeVehicleColor(GetPlayerVehicleID(playerid), VehicleColourData[listitem][colour_id], VehicleColourData[listitem][colour_id]);
		ShowModMenu(playerid);
	}
	if(dialogid == d_ePaintjob && response)
	{
		ChangeVehiclePaintjob(GetPlayerVehicleID(playerid), listitem);
		ShowModMenu(playerid);
	}
	return 1;
}

