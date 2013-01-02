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
	gCurModelGroup,
	bVehicleSettings[MAX_VEHICLES],
	gVehicleContainer[MAX_VEHICLES],
	gCurrentContainerVehicle[MAX_PLAYERS];


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
		    if(random(100) < 50)continue;

			if(model == -1)
				model = PickRandomVehicleFromGroup(gCurModelGroup);

			else if(0 <= model <= 12)
				model = PickRandomVehicleFromGroup(model);

			if( model == 403 ||
				model == 443 ||
				model == 514 ||
				model == 515) posZ += 2.0;

			tmpid = CreateVehicle(model, posX, posY, posZ, rotZ, -1, -1, 360000);

			if(IsValidVehicle(tmpid))
			{
				new
					chance = random(100),
					Float:health;

				if(chance < 70)
					health=(250 + random(300));

				else if(chance < 30)
					health=(400 + random(300));

				else if(chance < 5)
					health=(700 + random(300));

				SetVehicleHealth(tmpid, health);
				ApplyRandomDamageToVehicle(tmpid);

				if(VehicleFuelData[model-400][veh_lootType] != LOOT_TYPE_NONE)
				{
					new
						itemid,
						ItemType:itemtype,
						Float:x,
						Float:y,
						Float:z;

					GetVehicleModelInfo(model, VEHICLE_MODEL_INFO_SIZE, x, y, z);

					gVehicleContainer[tmpid] = CreateContainer("Trunk", 12, .virtual = 1);

					for(new i = 1; i <= 4; i++)
					{
						new loottype = LOOT_TYPE_LOW;

						if(i > 2) loottype = VehicleFuelData[model-400][veh_lootType];

						if(random(100) < 100 / i )
						{
							itemtype = GenerateLoot(loottype);
							itemid = CreateItem(itemtype, 0.0, 0.0, 0.0);
							AddItemToContainer(gVehicleContainer[tmpid], itemid);

							if(1 <= _:itemtype <= 46)
								SetItemExtraData(itemid, WepData[_:itemtype][MagSize] * (random(2) + 1));
						}
					}
				}
				gVehicleFuel[tmpid] = random(floatround(VehicleFuelData[model-400][veh_maxFuel], floatround_floor));

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

ApplyRandomDamageToVehicle(vehicleid)
{
	if(random(100) < 20)
	{
		UpdateVehicleDamageStatus(vehicleid,
			encode_tires(random(1), random(1), random(1), random(1)),
			encode_panels(random(4), random(4), random(4), random(4), random(4), random(4), random(4)),
			encode_doors(random(5), random(5), random(5), random(5), random(5), random(5)),
			encode_lights(random(1), random(1), random(1), random(1)));
	}
	else
	{
		UpdateVehicleDamageStatus(vehicleid,
			encode_tires(random(1), random(1), random(1), random(1)),
			encode_panels(1+random(3), 1+random(3), 1+random(3), 1+random(3), 1+random(3), 1+random(3), 1+random(3)),
			encode_doors(1+random(4), 1+random(4), 1+random(4), 1+random(4), 1+random(4), 1+random(4)),
			encode_lights(random(1), random(1), random(1), random(1)));
	}
}

CMD:rdam(playerid, params[])
{
	ApplyRandomDamageToVehicle(GetPlayerVehicleID(playerid));
	return 1;
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerInAnyVehicle(playerid))
		return 0;

	if(newkeys == 16)
	{
		new
			Float:vx,
			Float:vy,
			Float:vz,
			Float:px,
			Float:py,
			Float:pz,
			Float:sx,
			Float:sy,
			Float:sz;

		for(new i; i < MAX_VEHICLES; i++)
		{
			GetVehiclePos(i, vx, vy, vz);
			GetPlayerPos(playerid, px, py, pz);
			GetVehicleModelInfo(GetVehicleModel(i), VEHICLE_MODEL_INFO_SIZE, sx, sy, sz);

			if(Distance(vx, vy, vz, px, py, pz) < sy)
			{
				new Float:vr, Float:angle;
				GetVehicleZAngle(i, vr);

				angle = absoluteangle(vr - GetAngleToPoint(vx, vy, px, py));

				if(155.0 < angle < 205.0)
				{
					new
						engine,
						lights,
						alarm,
						doors,
						bonnet,
						boot,
						objective;

					GetVehicleParamsEx(i, engine, lights, alarm, doors, bonnet, boot, objective);
					SetVehicleParamsEx(i, engine, lights, alarm, doors, bonnet, 1, objective);

					SetPlayerPos(playerid, px, py, pz);

					DisplayContainerInventory(playerid, gVehicleContainer[i]);
					gCurrentContainerVehicle[playerid] = i;

					break;
				}
			}
		}
	}

	return 1;
}

public OnPlayerExitContainerUI(playerid, containerid)
{
	if(IsValidVehicle(gCurrentContainerVehicle[playerid]))
	{
		if(containerid == gVehicleContainer[gCurrentContainerVehicle[playerid]])
		{
			new
				engine,
				lights,
				alarm,
				doors,
				bonnet,
				boot,
				objective;

			GetVehicleParamsEx(gCurrentContainerVehicle[playerid], engine, lights, alarm, doors, bonnet, boot, objective);
			SetVehicleParamsEx(gCurrentContainerVehicle[playerid], engine, lights, alarm, doors, bonnet, 0, objective);

			gCurrentContainerVehicle[playerid] = -1;
		}
	}
}

RandomNumberPlateString()
{
	new str[9];
	for(new c; c < 8; c++)
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


