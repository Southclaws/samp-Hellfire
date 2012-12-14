#define FILTERSCRIPT

#include <a_samp>
#include <streamer>
#include <sscanf2>
#include <colours>
#include <foreach>
#include <formatex>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16

#define VEHICLE_INDEX_FILE		"vehicles/index.ini"
#define VEHICLE_DATA_FILE		"vehicles/%s.dat"

#define GRID_DIVIDE				(50)
#define GRID_TOTAL				(GRID_DIVIDE * GRID_DIVIDE)
#define MAX_STREAMED_IN_AREA	(MAX_VEHICLES / MAX_PLAYERS)
#define MAX_STREAMED_VEHICLES	(2500)
#define VEHICLE_STREAM_RANGE    100.0
#define MAX_PERSONAL_VEHICLE	16
#define PERSONAL_VEHICLE_DATA	"vehicles/special/player.dat"


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

enum E_VEHICLE_DATA
{
	v_id,
	v_model,
	Float:v_posX,
	Float:v_posY,
	Float:v_posZ,
	Float:v_rot,
	v_spawnArea
}

enum E_PVEHICLE_DATA
{
	pv_vehicleid,
	pv_owner[24],
	pv_command[6],
	pv_model,
	Float:pv_pos[4],
	pv_colour[2],
	pv_Plate[12]
}

new
	TotalVehicles,
	TotalPersonalVehicles,
	gVehicleData[MAX_STREAMED_VEHICLES][E_VEHICLE_DATA],
//	Iterator:gVehicleIndex<MAX_STREAMED_VEHICLES>,
	gAreaData[GRID_TOTAL+1],
	gAreaStreamed[GRID_TOTAL+1],
	gAreaStreamedBy[GRID_TOTAL+1],
	gPlayerCurrentArea[MAX_PLAYERS];

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

new
	gZone[GRID_DIVIDE * GRID_DIVIDE],
	gZoneCol[GRID_DIVIDE * GRID_DIVIDE],
	pass;





public OnFilterScriptInit()
{
	new
		Float:xMax,
		Float:xMin,
		Float:yMax,
		Float:yMin,
		xLoop,
		yLoop,
		idx;

	for(new i;i<1024;i++)
	{
		GangZoneHideForAll(i);
		GangZoneDestroy(i);
	}

	while(idx < GRID_DIVIDE * GRID_DIVIDE)
	{
	    xMin = ((6000 / GRID_DIVIDE) * xLoop) - 3000.0;
	    xMax = ((6000 / GRID_DIVIDE) * (xLoop+1)) - 3000.0;

		yMin = ((6000 / GRID_DIVIDE) * yLoop) - 3000.0;
		yMax = ((6000 / GRID_DIVIDE) * (yLoop+1)) - 3000.0;

		gAreaData[idx] = CreateDynamicRectangle(xMin, yMin, xMax, yMax, -1, 0);


		gZone[idx] = GangZoneCreate(xMin, yMin, xMax, yMax);
		if(pass==0)gZoneCol[idx] = 0x60606099;
		else gZoneCol[idx]  = 0x80808099;
		pass =! pass;


		xLoop++;
		idx++;

		if(xLoop == GRID_DIVIDE)
		{
			pass =! pass;
		    xLoop = 0;
			yLoop++;
		}

	}
	LoadAllVehicles();
	LoadStaticVehiclesFromFile("vehicles/special/trains.dat");
	LoadPersonalVehicles();
	
	for(new i;i<MAX_PLAYERS;i++)gPlayerCurrentArea[i] = -1;
	
	printf("Total Dynamic Vehicles: %d", TotalVehicles);
}

public OnFilterScriptExit()
{
	for(new i; i < MAX_STREAMED_VEHICLES; i++)
	{
		if(IsValidVehicle(gVehicleData[i][v_id]))
			DestroyVehicle(gVehicleData[i][v_id]);
	}
	for(new i; i < TotalPersonalVehicles; i++)
		if(IsValidVehicle(pv_Data[i][pv_vehicleid]))
			DestroyVehicle(pv_Data[i][pv_vehicleid]);
}

LoadAllVehicles()
{
	new
	    File:f=fopen(VEHICLE_INDEX_FILE, io_read),
		line[128],
		str[128];

	while(fread(f, line))
	{
	    if(line[strlen(line)-2] == '\r')line[strlen(line) - 2] = EOS;
		format(str, 128, VEHICLE_DATA_FILE, line);
		LoadVehiclesFromFile(str);
	}
	
	fclose(f);
}

LoadStaticVehiclesFromFile(file[])
{
	if(!fexist(file))return print("VEHICLE FILE NOT FOUND");

	new
	    File:f=fopen(file, io_read),
		line[128],
		Float:tmp_posX,
		Float:tmp_posY,
		Float:tmp_posZ,
		Float:tmp_rot,
		tmp_model;

	while(fread(f, line))
	{
		if(!sscanf(line, "p<,>ffffD(0)", tmp_posX, tmp_posY, tmp_posZ, tmp_rot, tmp_model))
		{
			AddStaticVehicle(tmp_model, tmp_posX, tmp_posY, tmp_posZ, tmp_rot, -1, -1);
		}
	}
	fclose(f);
	return 1;
}


new gCurModelGroup;
LoadVehiclesFromFile(file[])
{
	if(!fexist(file))return print("VEHICLE FILE NOT FOUND");
	new
	    File:f=fopen(file, io_read),
		line[128],
		Float:tmp_posX,
		Float:tmp_posY,
		Float:tmp_posZ,
		Float:tmp_rot,
		tmp_model,
		idx;

	while(fread(f, line))
	{
		if(!sscanf(line, "p<,>ffffD(-1)", tmp_posX, tmp_posY, tmp_posZ, tmp_rot, tmp_model))
		{
		    idx = 0;
			while(idx < GRID_TOTAL)
			{
				if(IsPointInDynamicArea(gAreaData[idx], tmp_posX, tmp_posY, tmp_posZ))break;
				idx++;
			}

			if(tmp_model == -1)tmp_model = PickRandomVehicleFromGroup(gCurModelGroup);
			else if(0 <= tmp_model <= 12)tmp_model = PickRandomVehicleFromGroup(tmp_model);

			if( gVehicleData[TotalVehicles][v_model] == 403 ||
				gVehicleData[TotalVehicles][v_model] == 443 ||
				gVehicleData[TotalVehicles][v_model] == 514 ||
				gVehicleData[TotalVehicles][v_model] == 515)tmp_posZ+=2.0;

			gVehicleData[TotalVehicles][v_model]		= tmp_model;
			gVehicleData[TotalVehicles][v_posX]			= tmp_posX;
			gVehicleData[TotalVehicles][v_posY]			= tmp_posY;
			gVehicleData[TotalVehicles][v_posZ]			= tmp_posZ;
			gVehicleData[TotalVehicles][v_rot]			= tmp_rot;
			gVehicleData[TotalVehicles][v_spawnArea]	= idx;

			TotalVehicles++;
		}
		else if(sscanf(line, "'MODELGROUP:'d", gCurModelGroup) && strlen(line) > 3)print("LINE ERROR");
	}
	printf("\t-Loaded %d vehicles from %s", TotalVehicles, file);
	fclose(f);
	return 1;
}
PickRandomVehicleFromGroup(group)
{
	new idx;
	while(gModelGroup[group][idx] != 0)idx++;
	return gModelGroup[group][random(idx)];
}
public OnPlayerEnterDynamicArea(playerid, areaid)
{
	if(gPlayerCurrentArea[playerid] == -1)
	{
		for(new i; i < GRID_TOTAL; i++)
		{
			if(IsPlayerInDynamicArea(playerid, gAreaData[i]))
			{
				OnPlayerChangeArea(playerid, i, -1);
				return 1;
			}
		}
	}
	return 1;
}
public OnPlayerLeaveDynamicArea(playerid, areaid)
{
	for(new i; i < GRID_TOTAL; i++)
	{
		if(IsPlayerInDynamicArea(playerid, gAreaData[i]))
		{
			OnPlayerChangeArea(playerid, i, gPlayerCurrentArea[playerid]);
		    return 1;
	    }
    }
	OnPlayerChangeArea(playerid, -1, gPlayerCurrentArea[playerid]);
	return 1;
}

OnPlayerChangeArea(playerid, newareaid, oldareaid)
{
	new
		tmpNewAreas[9],
		tmpOldAreas[9];

	tmpNewAreas[0] = newareaid;
	tmpNewAreas[1] = newareaid+1;
	tmpNewAreas[2] = newareaid-1;
	tmpNewAreas[3] = newareaid+GRID_DIVIDE;
	tmpNewAreas[4] = newareaid+GRID_DIVIDE+1;
	tmpNewAreas[5] = newareaid+GRID_DIVIDE-1;
	tmpNewAreas[6] = newareaid-GRID_DIVIDE;
	tmpNewAreas[7] = newareaid-GRID_DIVIDE+1;
	tmpNewAreas[8] = newareaid-GRID_DIVIDE-1;

	tmpOldAreas[0] = oldareaid;
	tmpOldAreas[1] = oldareaid+1;
	tmpOldAreas[2] = oldareaid-1;
	tmpOldAreas[3] = oldareaid+GRID_DIVIDE;
	tmpOldAreas[4] = oldareaid+GRID_DIVIDE+1;
	tmpOldAreas[5] = oldareaid+GRID_DIVIDE-1;
	tmpOldAreas[6] = oldareaid-GRID_DIVIDE;
	tmpOldAreas[7] = oldareaid-GRID_DIVIDE+1;
	tmpOldAreas[8] = oldareaid-GRID_DIVIDE-1;

	if(-1 < tmpNewAreas[0] < GRID_TOTAL)
	{
		StreamArea(newareaid, playerid);
		gPlayerCurrentArea[playerid] = newareaid;
	}
	for(new i=1;i<9;i++)
		if(-1 < tmpNewAreas[i] < GRID_TOTAL)	StreamArea(tmpNewAreas[i], playerid);





	new i, j;
	while(i<9)
	{
	    if(!(-1 < tmpOldAreas[i] < GRID_TOTAL))
		{
		    i++;
			continue;
		}
		j=0;
		while(j<9)
		{
		    if(tmpOldAreas[i] == tmpNewAreas[j])break;
		    j++;
		}
		if(j==9)UnStreamArea(tmpOldAreas[i], playerid);
		i++;
	}


	return 1;
}
StreamArea(area, playerid)
{
	if(gAreaStreamed[area])return 0;
	
//	GangZoneShowForAll(gZone[area], gZoneCol[area]);

	gAreaStreamedBy[area] = playerid;
	gAreaStreamed[area] = true;

    for(new i; i < MAX_STREAMED_VEHICLES; i++)
    {
        if(gVehicleData[i][v_model] == 0)continue;

		if(IsPointInDynamicArea(gAreaData[area], gVehicleData[i][v_posX], gVehicleData[i][v_posY], gVehicleData[i][v_posZ]))
		{
			gVehicleData[i][v_id] = CreateVehicle(
				gVehicleData[i][v_model],
				gVehicleData[i][v_posX],
				gVehicleData[i][v_posY],
				gVehicleData[i][v_posZ],
				gVehicleData[i][v_rot],
				-1, -1, -1);
			SetVehicleNumberPlate(gVehicleData[i][v_id], RandomNumberPlateString());
		}
	}
	return 1;
}
UnStreamArea(area, playerid)
{
	if(!gAreaStreamed[area] || gAreaStreamedBy[area] != -1 && gAreaStreamedBy[area] != playerid)return 0;

//	GangZoneHideForAll(gZone[area]);

	gAreaStreamedBy[area] = -1;
	gAreaStreamed[area] = false;

	for(new i; i < MAX_STREAMED_VEHICLES; i++)
	{
		if(IsPointInDynamicArea(gAreaData[area], gVehicleData[i][v_posX], gVehicleData[i][v_posY], gVehicleData[i][v_posZ]))
		{
			if(!IsAnyPlayerInVehicle(gVehicleData[i][v_id]) && IsValidVehicle(gVehicleData[i][v_id]))
				DestroyVehicle(gVehicleData[i][v_id]);
		}
	}
	return 1;
}

IsAnyPlayerInVehicle(vehicleid)
{
	for(new i;i<MAX_PLAYERS;i++)if(IsPlayerInVehicle(i, vehicleid))return 1;
	return 0;
}





LoadPersonalVehicles()
{
	new
	    File:f = fopen(PERSONAL_VEHICLE_DATA, io_read),
	    line[128],
		idx;

	while(fread(f, line))
	{
		sscanf(line, "p<,>s[24]s[6]da<f>[4]a<d>[2]s[12]",
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

		idx++;
	}
	fclose(f);
	TotalPersonalVehicles = idx;
	printf("\t-Loaded %d Personal Vehicles", idx);
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
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
public OnPlayerCommandText(playerid, cmdtext[])
{
	if(cmdtext[1] == EOS)return 0;
	for(new i; i < TotalPersonalVehicles; i++)
	{
		if(!strcmp(cmdtext[1], pv_Data[i][pv_command]))
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
					DestroyVehicle(pv_Data[i][pv_vehicleid]);

				pv_Data[i][pv_vehicleid] = CreateVehicle(
					pv_Data[i][pv_model],
					px, py, pz, r,
					pv_Data[i][pv_colour][0],
					pv_Data[i][pv_colour][1], -1);

                SetVehicleNumberPlate(pv_Data[i][pv_vehicleid], pv_Data[i][pv_Plate]);

				PutPlayerInVehicle(playerid, pv_Data[i][pv_vehicleid], 0);
				SetVehicleVelocity(pv_Data[i][pv_vehicleid], vx, vy, vz);
				SetVehicleParamsEx(pv_Data[i][pv_vehicleid], 1, 1, 0, 0, 0, 0, 0);

			    new str[128];
				format(str, 128, " >  Welcome to your Car, %P"#C_YELLOW". Summon Command: "#C_BLUE"%s", playerid, pv_Data[i][pv_command]);
				SendClientMessage(playerid, YELLOW, str);
				return 1;
			}
			else return 0;
		}
	}
	return 0;
}
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
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
					DestroyVehicle(pv_custom_hydra);

				pv_custom_hydra = CreateVehicle(520, px, py, pz+1.0, r, 0, 0, -1);
				PutPlayerInVehicle(playerid, pv_custom_hydra, 0);
				SetVehicleVelocity(pv_custom_hydra, vx, vy, vz);
				SetVehicleParamsEx(pv_custom_hydra, 1, 1, 0, 0, 0, 0, 0);

				GameTextForPlayer(playerid, "~b~Fly Mode Activated", 3000, 5);
				DestroyVehicle(pv_Data[0][pv_vehicleid]);
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







/*
LinkDynamicVehicleToInterior(vehicleid, interiorid)
{
    LinkVehicleToInterior(
}
DestroyDynamicVehicle(vehicleid)
{
}
SetDynamicVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective)
{
}
SetDynamicVehicleVelocity(vehicleid, Float:x, Float:y, Float:z)
{
}
PutPlayerInDynamicVehicle(playerid, vehicleid, seat)
{
}
GetDynamicVehicleModel(vehicleid)
{
}
IsValidDynamicVehicle(vehicleid)
{
}
GetDynamicVehiclePos(vehicleid, Float:x, Float:y, Float:z)
{
}
GetDynamicVehicleZAngle(vehicleid, Float:angle)
{
}
GetPlayerDynamicVehicleID(playerid)
{
}
SetDynamicVehicleNumberPlate(vehicleid, text[])
{
}
*/






#endinput

new curGrp;

SaveVehicle(file[], modelgroup, model, Float:x, Float:y, Float:z, Float:r, c1, c2)
{
	print(file);
#pragma unused c1, c2
	new
	    File:f,
	    str[128];

	format(str, 128, "vehicles/NEW/%s.dat", file);
	
	if(!fexist(str))f = fopen(str, io_write);
	else f = fopen(str, io_append);

	if(modelgroup == -1)
	{
		format(str, 128, "%f, %f, %f, %f, %d\r\n\n", x, y, z, r, model);
		fwrite(f, str);
	}
	else
	{
		if(curGrp != modelgroup)
		{
		    format(str, 128, "MODELGROUP:%d\r\n", modelgroup);
		    fwrite(f, "\r\n\r\n");
		    fwrite(f, str);
		    
		    curGrp = modelgroup;
		}

		format(str, 128, "%f, %f, %f, %f\r\n", x, y, z, r);
		fwrite(f, str);
	}
	
	
	
	fclose(f);
}































