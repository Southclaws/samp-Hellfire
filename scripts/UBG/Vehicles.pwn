stock LoadVehiclesFromFile(const filename[])
{
	new
		File:file_ptr=fopen(filename,filemode:io_read),
		m, Float:x, Float:y, Float:z, Float:a, c1, c2,
		line[128],
		TotalVehicles;

	if(!file_ptr)return printf("Error: file: %s not found", filename);

	while(fread(file_ptr,line))
	{
	    sscanf(line, "p<,>dffffdd", m, x, y, z, a, c1, c2);
	    ApplyRandomFeaturesToVehicle(CreateVehicle(m, x, y, z, a, c1, c2, 999999));
	    TotalVehicles++;
	}
	printf("Total Vehicles: %d", TotalVehicles);
	fclose(file_ptr);
	return 1;
}
ApplyRandomFeaturesToVehicle(vehicleid)
{
	new
	    mod = GetVehicleModel(vehicleid),
		Float:health;
	if(chance(80))health=random(500);
	else if(chance(10))health=(400+random(200));
	else health=(600+random(400));

	SetVehicleParamsEx(vehicleid, 0, 0, 0, random(1), random(1), random(1), 0);
	SetVehicleHealth(vehicleid, health);

	vehicleData[vehicleid][model]=mod;
	vehicleData[vehicleid][locked]=random(1);
	vehicleData[vehicleid][alarm]=random(1);
	vehicleData[vehicleid][condition]=health;
//	vehicleData[vehicleid][fuel]=random(maxFuel[mod]);
}
stock encode_panels(flp, frp, rlp, rrp, windshield, front_bumper, rear_bumper)return flp | (frp << 4)  | (rlp << 8)  | (rrp << 12)  | (windshield << 16)  | (front_bumper << 20)  | (rear_bumper << 24);
stock encode_doors(bonnet, boot, driver_door, passenger_door/*, behind_driver_door, behind_passenger_door*/)return bonnet | (boot << 8) | (driver_door << 16) | (passenger_door << 24);
stock encode_lights(light1, light2, light3, light4)return light1 | (light2 << 1) | (light3 << 2) | (light4 << 3);
stock encode_tires(tire1, tire2, tire3, tire4)return tire1 | (tire2 << 1) | (tire3 << 2) | (tire4 << 3);
stock encode_tires_bike(rear, front)return rear | (front << 1);

