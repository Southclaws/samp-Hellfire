#include <YSI\y_hooks>

#define VEHICLE_INDEX_FILE		"vehicles/index.ini"
#define VEHICLE_DATA_FILE		"vehicles/%s.dat"
#define PERSONAL_VEHICLE_FILE	"vehicles/special/player.dat"
#define MAX_PERSONAL_VEHICLE	16


enum
{
	VEHICLE_GROUP_NONE				= -1,
	VEHICLE_GROUP_CASUAL,			// 0
	VEHICLE_GROUP_CASUAL_DESERT,	// 1
	VEHICLE_GROUP_CASUAL_COUNTRY,	// 2
	VEHICLE_GROUP_SPORT,			// 3
	VEHICLE_GROUP_OFFROAD,			// 4
	VEHICLE_GROUP_BIKE,				// 5
	VEHICLE_GROUP_FASTBIKE,			// 6
	VEHICLE_GROUP_MILITARY,			// 7
	VEHICLE_GROUP_POLICE,			// 8
	VEHICLE_GROUP_BIGPLANE,			// 9
	VEHICLE_GROUP_SMALLPLANE,		// 10
	VEHICLE_GROUP_HELICOPTER,		// 11
	VEHICLE_GROUP_BOAT				// 12
}
enum E_PVEHICLE_DATA
{
	pv_vehicleid,
	pv_owner[24],
	pv_command[16],
	pv_model,
	Float:pv_pos[4],
	pv_colour[2],
	pv_Plate[12]
}
enum (<<=1)
{
	v_Used,
	v_Occupied
}


new
	TotalVehicles,
	TotalPersonalVehicles,
	gCurModelGroup,
	bVehicleSettings[MAX_VEHICLES],
	gVehicleContainer[MAX_VEHICLES];

new
	pv_Data[MAX_PERSONAL_VEHICLE][E_PVEHICLE_DATA],
	pv_custom_invisible,
	pv_custom_hydra;


new gModelGroup[13][68]=
{
	// VEHICLE_GROUP_CASUAL
	{
		404,442,479,549,600,496,496,401,
		410,419,436,439,517,518,401,410,
		419,436,439,474,491,496,517,518,
		526,527,533,545,549,580,589,600,
		602,400,404,442,458,479,489,505,
		579,405,421,426,445,466,467,492,
		507,516,529,540,546,547,550,551,
		566,585,587,412,534,535,536,567,
		575,576, 0, ...
	},
	// VEHICLE_GROUP_CASUAL_DESERT,
	{
	    404,479,445,542,466,467,549,540,
		424,400,500,505,489,499,422,600,
		515,543,554,443,508,525, 0, ...
	},
	// VEHICLE_GROUP_CASUAL_COUNTRY,
	{
	    499,422,498,609,455,403,414,514,
		600,413,515,440,543,531,478,456,
		554,445,518,401,527,542,546,410,
		549,508,525, 0, ...
	},
	// VEHICLE_GROUP_SPORT,
	{
		558,559,560,561,562,565,411,451,
		477,480,494,502,503,506,541, 0, ...
	},
	// VEHICLE_GROUP_OFFROAD,
	{
		400,505,579,422,478,543,554, 0, ...
	},
	// VEHICLE_GROUP_BIKE,
	{
	    509,481,510,462,448,463,586,468,
		471, 0, ...
	},
	// VEHICLE_GROUP_FASTBIKE,
	{
	    581,522,461,521, 0, ...
	},
	// VEHICLE_GROUP_MILITARY,
	{
	    433,432,601,470, 0, ...
	},
	// VEHICLE_GROUP_POLICE,
	{
	    523,596,598,597,599,490,528,427
	},
	// VEHICLE_GROUP_BIGPLANE,
	{
	    519,553,577,592, 0, ...
	},
	// VEHICLE_GROUP_SMALLPLANE,
	{
	    460,476,511,512,513,593, 0, ...
	},
	// VEHICLE_GROUP_HELICOPTER,
	{
	    548,487,417,487,488,487,497,487,
		563,477,469,487, 0, ...
	},
	// VEHICLE_GROUP_BOAT,
	{
	    472,473,493,595,484,430,453,452,
		446,454, 0, ...
	}
};


LoadVehicles(bool:prints = true)
{
	LoadAllVehicles(prints);
	LoadStaticVehiclesFromFile("vehicles/special/trains.dat", prints);
	LoadPersonalVehicles(prints);

	if(prints)
		printf("Total Vehicles: %d", TotalVehicles);
}
UnloadVehicles()
{
	for(new i; i < MAX_VEHICLES; i++)
	{
		if(IsValidVehicle(i))
		{
			DestroyVehicle(i);
			DestroyContainer(gVehicleContainer[i]);
		}
	}

    TotalVehicles = 0;
}
ReloadVehicles()
{
	UnloadVehicles();
	LoadVehicles(false);
}


LoadAllVehicles(bool:prints = true)
{
	new
	    File:f=fopen(VEHICLE_INDEX_FILE, io_read),
		line[128],
		str[128];

	while(fread(f, line))
	{
	    if(line[strlen(line)-2] == '\r')line[strlen(line) - 2] = EOS;
		format(str, 128, VEHICLE_DATA_FILE, line);
		LoadVehiclesFromFile(str, prints);
	}

	fclose(f);
}
LoadStaticVehiclesFromFile(file[], bool:prints = true)
{
	if(!fexist(file))return print("VEHICLE FILE NOT FOUND");

	new
	    File:f=fopen(file, io_read),
		line[128],
		Float:posX,
		Float:posY,
		Float:posZ,
		Float:rotZ,
		model,
		count;

	while(fread(f, line))
	{
		if(!sscanf(line, "p<,>ffffD(0)", posX, posY, posZ, rotZ, model))
		{
			AddStaticVehicle(model, posX, posY, posZ, rotZ, -1, -1);
			TotalVehicles++;
			count++;
		}
	}
	fclose(f);

	if(prints)
		printf("\t-Loaded %d vehicles from %s", count, file);

	return 1;
}


LoadVehiclesFromFile(file[], bool:prints = true)
{
	if(!fexist(file))return print("VEHICLE FILE NOT FOUND");
	new
	    File:f=fopen(file, io_read),
		line[128],
		Float:posX,
		Float:posY,
		Float:posZ,
		Float:rotZ,
		model,
		count,
		tmpid;

	while(fread(f, line))
	{
		if(!sscanf(line, "p<,>ffffD(-1)", posX, posY, posZ, rotZ, model))
		{
		    if(random(100) < 10)continue;

			if(model == -1)
				model = PickRandomVehicleFromGroup(gCurModelGroup);

			else if(0 <= model <= 12)
				model = PickRandomVehicleFromGroup(model);

			if( model == 403 ||
				model == 443 ||
				model == 514 ||
				model == 515) posZ += 2.0;

			tmpid = CreateVehicle(model, posX, posY, posZ, rotZ, -1, -1, -1);

			if(IsValidVehicle(tmpid))
			{
				SetVehicleNumberPlate(tmpid, RandomNumberPlateString());

				TotalVehicles++;
				count++;
			}
		}
		else if(sscanf(line, "'MODELGROUP:'d", gCurModelGroup) && strlen(line) > 3)print("LINE ERROR");
	}
	fclose(f);

	if(prints)
		printf("\t-Loaded %d vehicles from %s", count, file);

	return 1;
}
PickRandomVehicleFromGroup(group)
{
	new idx;
	while(gModelGroup[group][idx] != 0)idx++;
	return gModelGroup[group][random(idx)];
}



LoadPersonalVehicles(bool:prints = true)
{
	new
	    File:f = fopen(PERSONAL_VEHICLE_FILE, io_read),
	    line[128],
		idx;

	while(fread(f, line))
	{
		sscanf(line, "p<,>s[24]s[16]da<f>[4]a<d>[2]s[12]",
			pv_Data[idx][pv_owner],
			pv_Data[idx][pv_command],
			pv_Data[idx][pv_model],
			pv_Data[idx][pv_pos],
			pv_Data[idx][pv_colour],
			pv_Data[idx][pv_Plate]);

		pv_Data[idx][pv_vehicleid] = CreateVehicle(
			pv_Data[idx][pv_model],
			pv_Data[idx][pv_pos][0],
			pv_Data[idx][pv_pos][1],
			pv_Data[idx][pv_pos][2],
			pv_Data[idx][pv_pos][3],
			pv_Data[idx][pv_colour][0],
			pv_Data[idx][pv_colour][1], -1);

		SetVehicleNumberPlate(pv_Data[idx][pv_vehicleid], pv_Data[idx][pv_Plate]);

		TotalVehicles++;
		idx++;
	}
	fclose(f);
	TotalPersonalVehicles = idx;

	if(prints)
		printf("\t-Loaded %d Personal Vehicles", idx);
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	for(new i; i < TotalPersonalVehicles; i++)
	{
		if(vehicleid == pv_Data[i][pv_vehicleid])
		{
		    new name[MAX_PLAYER_NAME];
		    GetPlayerName(playerid, name, MAX_PLAYER_NAME);

			if(!strcmp(name, pv_Data[i][pv_owner]))
			{
			    new str[128];
				format(str, 128, " >  Welcome to your Car, %P"#C_YELLOW". Summon Command: "#C_BLUE"%s", playerid, pv_Data[i][pv_command]);
				SendClientMessage(playerid, YELLOW, str);
			}
			else if(ispassenger)
			{
			    new str[128];
				format(str, 128, " >  You are now riding in "#C_BLUE"%s"#C_YELLOW"'s private car", pv_Data[i][pv_owner]);
				SendClientMessage(playerid, YELLOW, str);
			}
			else
			{
/*
				new
					Float:x,
					Float:y,
					Float:z;

				ClearAnimations(playerid);
			    GetPlayerPos(playerid, x, y, z);
				SetPlayerPos(playerid, x, y, z);
*/
			    new str[128];
				format(str, 128, " >  This car belongs to %s", pv_Data[i][pv_owner]);
				SendClientMessage(playerid, YELLOW, str);
			}
		}
	}
	return 1;
}
script_Vehicles_CommandText(playerid, cmd[])
{
	if(cmd[1] == EOS)return 0;
	for(new i; i < TotalPersonalVehicles; i++)
	{
		if(!strcmp(cmd[1], pv_Data[i][pv_command]))
		{
		    new name[MAX_PLAYER_NAME];
		    GetPlayerName(playerid, name, MAX_PLAYER_NAME);

		    if(!strcmp(name, pv_Data[i][pv_owner]))
		    {
				new
					Float:px, Float:py, Float:pz, Float:r,
					Float:vx, Float:vy, Float:vz;

				if(IsPlayerInAnyVehicle(playerid))
				{
					new vehicleid = GetPlayerVehicleID(playerid);

					GetVehiclePos(vehicleid, px, py, pz);
					GetVehicleZAngle(vehicleid, r);
					GetVehicleVelocity(vehicleid, vx, vy, vz);
					DestroyVehicle(vehicleid);
				}
				else
				{
					GetPlayerPos(playerid, px, py, pz);
					GetPlayerFacingAngle(playerid, r);
					GetPlayerVelocity(playerid, vx, vy, vz);
				}

				if(IsValidVehicle(pv_Data[i][pv_vehicleid]) && GetVehicleModel(pv_Data[i][pv_vehicleid]) == pv_Data[i][pv_model])
				{
					DestroyVehicle(pv_Data[i][pv_vehicleid]);
					pv_Data[i][pv_vehicleid] = INVALID_VEHICLE_ID;
				}

				pv_Data[i][pv_vehicleid] = CreateVehicle(
					pv_Data[i][pv_model],
					px, py, pz, r,
					pv_Data[i][pv_colour][0],
					pv_Data[i][pv_colour][1], -1);

				PutPlayerInVehicle(playerid, pv_Data[i][pv_vehicleid], 0);

				SetVehicleVirtualWorld(pv_Data[i][pv_vehicleid], FREEROAM_WORLD);
                SetVehicleNumberPlate(pv_Data[i][pv_vehicleid], pv_Data[i][pv_Plate]);
				SetVehicleVelocity(pv_Data[i][pv_vehicleid], vx, vy, vz);
				SetVehicleParamsEx(pv_Data[i][pv_vehicleid], 1, 1, 0, 0, 0, 0, 0);

				gPlayerVehicleID[playerid] = pv_Data[i][pv_vehicleid];
				PlayerTextDrawSetString(playerid, VehicleNameText, VehicleNames[pv_Data[i][pv_model]-400]);
				PlayerTextDrawShow(playerid, VehicleNameText);

				MsgF(playerid, YELLOW, " >  Welcome to your Car, %P"#C_YELLOW". Summon Command: "#C_BLUE"%s", playerid, pv_Data[i][pv_command]);
				return 1;
			}
			return 0;
		}
	}
	return 0;
}
hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	new vehicleid = GetPlayerVehicleID(playerid);
	if(vehicleid == pv_Data[0][pv_vehicleid])
	{
	    new name[MAX_PLAYER_NAME];
	    GetPlayerName(playerid, name, MAX_PLAYER_NAME);

		if(!strcmp(name, "[HLF]Southclaw"))
		{
			if(newkeys == KEY_SUBMISSION)
			{
				new
					Float:px,
					Float:py,
					Float:pz,
					Float:r,
					Float:vx,
					Float:vy,
					Float:vz;

				GetVehiclePos(vehicleid, px, py, pz);
				GetVehicleZAngle(vehicleid, r);
				GetVehicleVelocity(vehicleid, vx, vy, vz);

				if(IsValidVehicle(pv_custom_hydra) && GetVehicleModel(pv_custom_hydra) == 520)
				{
					DestroyVehicle(pv_custom_hydra);
					pv_custom_hydra = INVALID_VEHICLE_ID;
				}

				pv_custom_hydra = CreateVehicle(520, px, py, pz+1.0, r, 0, 0, -1);
				PutPlayerInVehicle(playerid, pv_custom_hydra, 0);
				SetVehicleVelocity(pv_custom_hydra, vx, vy, vz);
				SetVehicleParamsEx(pv_custom_hydra, 1, 1, 0, 0, 0, 0, 0);

				gPlayerVehicleID[playerid] = pv_custom_hydra;
				PlayerTextDrawSetString(playerid, VehicleNameText, VehicleNames[120]);
				PlayerTextDrawShow(playerid, VehicleNameText);

				GameTextForPlayer(playerid, "~b~Fly Mode Activated", 3000, 5);
				DestroyVehicle(pv_Data[0][pv_vehicleid]);
				pv_Data[0][pv_vehicleid] = INVALID_VEHICLE_ID;
			}
			if(newkeys & KEY_ANALOG_DOWN)
			{
				if(pv_custom_invisible)
				{
					LinkVehicleToInterior(pv_Data[0][pv_vehicleid], 0);
					GameTextForPlayer(playerid, "~b~Stealth Mode Deactivated", 3000, 5);
					pv_custom_invisible = false;
				}
				else
				{
					LinkVehicleToInterior(pv_Data[0][pv_vehicleid], 1);
					GameTextForPlayer(playerid, "~b~Stealth Mode Activated", 3000, 5);
					pv_custom_invisible = true;
				}
			}
		}
	}
    return 1;
}

RandomNumberPlateString()
{
	new str[9];
	for(new c;c<8;c++)
	{
	    if(c<4)str[c] = 'A' + random(26);
	    else if(c>4)str[c] = '0' + random(10);
	    str[4] = ' ';
	}
	return str;
}


CMD:reloadvehicles(playerid, params[])
{
	ReloadVehicles();
	Msg(playerid, YELLOW, " >  Reloading Vehicles...");
	return 1;
}


