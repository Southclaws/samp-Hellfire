#include <YSI\y_hooks>

#define MAX_SPAWNED_VEHICLES	(400)
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
	v_Used = 1,
	v_Occupied
}


new
	TotalVehicles,
	gCurModelGroup,
	bVehicleSettings[MAX_VEHICLES],
	Iterator:gVehicleIndex<MAX_SPAWNED_VEHICLES>,
	gVehicleArea[MAX_VEHICLES],
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
		    if(random(100) < 80)continue;

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

public OnVehicleSpawn(vehicleid)
{
	new
		chance = random(100),
		model = GetVehicleModel(vehicleid),
		Float:sx,
		Float:sy,
		Float:sz;

	if(chance < 5)
		SetVehicleHealth(vehicleid, 700 + random(300));

	else if(chance < 30)
		SetVehicleHealth(vehicleid, 400 + random(300));

	else
		SetVehicleHealth(vehicleid, 300 + random(300));

	chance = random(100);

	if(chance < 5)
		gVehicleFuel[vehicleid] = VehicleFuelData[model-400][veh_maxFuel] / 2 + frandom(VehicleFuelData[model-400][veh_maxFuel] / 2);

	else if(chance < 30)
		gVehicleFuel[vehicleid] = VehicleFuelData[model-400][veh_maxFuel] / 4 + frandom(VehicleFuelData[model-400][veh_maxFuel] / 3);

	else
		gVehicleFuel[vehicleid] = VehicleFuelData[model-400][veh_maxFuel] / 8 + frandom(VehicleFuelData[model-400][veh_maxFuel] / 4);

	UpdateVehicleDamageStatus(vehicleid,
		encode_panels(random(4), random(4), random(4), random(4), random(4), random(4), random(4)),
		encode_doors(random(5), random(5), random(5), random(5), random(5), random(5)),
		encode_lights(random(2), random(2), random(2), random(2)),
		encode_tires(random(2), random(2), random(2), random(2)));

	if(VehicleFuelData[model-400][veh_lootType] != LOOT_TYPE_NONE)
	{
		new
			itemid,
			ItemType:itemtype,
			Float:x,
			Float:y,
			Float:z;

		GetVehicleModelInfo(model, VEHICLE_MODEL_INFO_SIZE, x, y, z);

		gVehicleContainer[vehicleid] = CreateContainer("Trunk", 12, .virtual = 1);

		for(new i = 1; i <= 4; i++)
		{
			new loottype = LOOT_TYPE_LOW;

			if(i > 2) loottype = VehicleFuelData[model-400][veh_lootType];

			if(random(100) < 100 / i )
			{
				itemtype = GenerateLoot(loottype);
				itemid = CreateItem(itemtype, 0.0, 0.0, 0.0);
				AddItemToContainer(gVehicleContainer[vehicleid], itemid);

				if(1 <= _:itemtype <= 46)
					SetItemExtraData(itemid, (WepData[_:itemtype][MagSize] * (random(3))) + random(WepData[_:itemtype][MagSize]));
			}
		}
	}

	GetVehicleModelInfo(GetVehicleModel(vehicleid), VEHICLE_MODEL_INFO_SIZE, sx, sy, sz);

	gVehicleArea[vehicleid] = CreateDynamicSphere(0.0, 0.0, 0.0, sy, 0);
	AttachDynamicAreaToVehicle(gVehicleArea[vehicleid], vehicleid);

	SetVehicleNumberPlate(vehicleid, RandomNumberPlateString());

	Iter_Add(gVehicleIndex, vehicleid);
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
		foreach(new i : gVehicleIndex)
		{
			if(IsPlayerInDynamicArea(playerid, gVehicleArea[i]))
			{
				new
					Float:px,
					Float:py,
					Float:pz,
					Float:vx,
					Float:vy,
					Float:vz,
					Float:vr,
					Float:angle;

				GetPlayerPos(playerid, px, py, pz);
				GetVehiclePos(i, vx, vy, vz);
				GetVehicleZAngle(i, vr);

				angle = absoluteangle(vr - GetAngleToPoint(vx, vy, px, py));

				if(angle < 25.0 || angle > 335.0)
				{
					new Float:vehiclehealth;

					GetVehicleHealth(i, vehiclehealth);

					if(GetItemType(GetPlayerItem(playerid)) == item_Wrench)
					{
						if(250.0 <= vehiclehealth < 450.0 || 800.0 <= vehiclehealth < 1000.0)
						{
							SetPlayerPos(playerid, px, py, pz);
							PlayerStartRepairVehicle(playerid, i);
							break;
						}
						else
						{
							ShowMsgBox(playerid, "You need another tool", 3000, 100);
							SetPlayerPos(playerid, px, py, pz);
						}
					}	
					else if(GetItemType(GetPlayerItem(playerid)) == item_Screwdriver)
					{
						if(450.0 <= vehiclehealth < 650.0)
						{
							SetPlayerPos(playerid, px, py, pz);
							PlayerStartRepairVehicle(playerid, i);
							break;
						}
						else
						{
							ShowMsgBox(playerid, "You need another tool", 3000, 100);
							SetPlayerPos(playerid, px, py, pz);
						}
					}	
					else if(GetItemType(GetPlayerItem(playerid)) == item_Hammer)
					{
						if(650.0 <= vehiclehealth < 800.0)
						{
							SetPlayerPos(playerid, px, py, pz);
							PlayerStartRepairVehicle(playerid, i);
							break;
						}
						else
						{
							ShowMsgBox(playerid, "You need another tool", 3000, 100);
							SetPlayerPos(playerid, px, py, pz);
						}
					}
					else
					{
						ShowMsgBox(playerid, "You don't have the right tool", 3000, 100);
						SetPlayerPos(playerid, px, py, pz);
					}
				}
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
					SetPlayerFacingAngle(playerid, GetAngleToPoint(px, py, vx, vy));

					DisplayContainerInventory(playerid, gVehicleContainer[i]);
					gCurrentContainerVehicle[playerid] = i;

					break;
				}
			}
		}
		if(oldkeys == 16)
		{
			PlayerStopRepairVehicle(playerid);
		}
	}

	return 1;
}

public OnPlayerEnterDynamicArea(playerid, areaid)
{
	foreach(new i : gVehicleIndex)
	{
		if(areaid == gVehicleArea[i])
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
				Float:sz,
				Float:vr,
				Float:angle;

			GetVehiclePos(i, vx, vy, vz);
			GetPlayerPos(playerid, px, py, pz);
			GetVehicleModelInfo(GetVehicleModel(i), VEHICLE_MODEL_INFO_SIZE, sx, sy, sz);

			GetVehicleZAngle(i, vr);

			angle = absoluteangle(vr - GetAngleToPoint(vx, vy, px, py));

			if(155.0 < angle < 205.0)
			{
				ShowMsgBox(playerid, "Press ~k~~VEHICLE_ENTER_EXIT~ to open trunk", 3000, 100);
			}
			if(-25.0 < angle < 25.0 || 335.0 < angle < 385.0)
			{
				ShowMsgBox(playerid, "Hold ~k~~VEHICLE_ENTER_EXIT~ to repair", 3000, 100);
			}
		}
	}

	return CallLocalFunction("veh_OnPlayerEnterDynamicArea", "dd", playerid, areaid);
}
#if defined _ALS_OnPlayerEnterDynamicArea
	#undef OnPlayerEnterDynamicArea
#else
	#define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea veh_OnPlayerEnterDynamicArea
forward veh_OnPlayerEnterDynamicArea(playerid, containerid);

public OnPlayerCloseContainer(playerid, containerid)
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

			gCurrentContainerVehicle[playerid] = INVALID_VEHICLE_ID;
		}
	}
	return CallLocalFunction("veh_OnPlayerCloseContainer", "dd", playerid, containerid);
}
#if defined _ALS_OnPlayerCloseContainer
	#undef OnPlayerCloseContainer
#else
	#define _ALS_OnPlayerCloseContainer
#endif
#define OnPlayerCloseContainer veh_OnPlayerCloseContainer
forward veh_OnPlayerCloseContainer(playerid, containerid);

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


