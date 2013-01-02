stock AddVehicleComponentEx(vehicleid, ...)
{
	new
		i,
		Component_ID,
		num = numargs();
	if(num > 11) num = 11;
	for(i = 1; i < num; i++)
	{
		Component_ID = getarg(i, 0);
		AddVehicleComponent(vehicleid, Component_ID);
	}
	return i-1;
}
stock GetNearestVehicle(playerid, Float:Distance = 1000.0)
{
	Distance = floatabs(Distance);
	if(!Distance) Distance = 1000.0;
	new
		Float:pX,
		Float:pY,
		Float:pZ,
		Float:NearestPos = Distance,
		Float:NearestDist,
		NearestVeh = INVALID_VEHICLE_ID;

	GetPlayerPos(playerid, pX, pY, pZ);

	for(new i; i<MAX_VEHICLES; i++)
	{
		if(!IsVehicleStreamedIn(i, playerid))continue;
		NearestDist=GetVehicleDistanceFromPoint(i, pX, pY, pZ);
		if(NearestPos > NearestDist)
		{
			NearestPos = NearestDist;
			NearestVeh = i;
		}
	}
	return NearestVeh;
}
stock GetPlayersInVehicle(vehicleid)
{
    new amount;
    PlayerLoop(i)if(!IsPlayerConnected(i)||!IsPlayerInVehicle(i,vehicleid))amount++;
    return amount;
}
stock SetVehicleModel(vehicleid, modelid)
{
	new
		Float:px, // p* = pos
		Float:py,
		Float:pz,
		Float:rot,
		Float:vx, // v* = velocity
		Float:vy,
		Float:vz,
		new_vehicleid,
		tmp_seatid;

	GetVehiclePos(vehicleid, px, py, pz);
	GetVehicleZAngle(vehicleid, rot);
	GetVehicleVelocity(vehicleid, vx, vy, vz);

	new_vehicleid = CreateVehicle(modelid, px, py, pz, rot, -1, -1, -1);
	PlayerLoop(i)
	{
		if(IsPlayerInVehicle(i, vehicleid))
		{
		    if(GetPlayerState(i) == PLAYER_STATE_DRIVER) PutPlayerInVehicle(i, new_vehicleid, 0);
			else
			{
		    	// Needs a seat count check because if the vehicle model changes
				// from a full 4 seat car to a 2 seat car, there will be problems!
			    tmp_seatid = GetPlayerVehicleSeat(i);
			    if(tmp_seatid <= GetVehicleMaxSeats(modelid))
			    {
					PutPlayerInVehicle(i, new_vehicleid, tmp_seatid);
				}
			}
		}
	}
	DestroyVehicle(vehicleid);
	SetVehicleVelocity(new_vehicleid, vx, vy, vz);
}
stock IsPlayerInInvalidNosVehicle(playerid,playerveh)
{
    new InvalidNosVehicles[29]=
	{
		581,523,462,521,463,522,461,448,468,586,
		509,481,510,472,473,493,595,484,430,453,
		452,446,454,590,569,537,538,570,449
    };
    if(IsPlayerInVehicle(playerid,playerveh))for(new i=0;i<29;i++)if(GetVehicleModel(playerveh)==InvalidNosVehicles[i])return true;
    return false;
}
stock IsPlayerInCar(playerid)
{
	new vid=GetPlayerVehicleID(playerid);
	if(vid)
	{
		switch(GetVehicleModel(vid))
		{
  		case 448:return 0;
  		case 461:return 0;
  		case 462:return 0;
  		case 463:return 0;
  		case 468:return 0;
  		case 521:return 0;
  		case 522:return 0;
  		case 523:return 0;
  		case 581:return 0;
  		case 586:return 0;
  		case 481:return 0;
  		case 509:return 0;
  		case 510:return 0;
  		case 430:return 0;
  		case 446:return 0;
  		case 452:return 0;
  		case 453:return 0;
  		case 454:return 0;
 		case 472:return 0;
  		case 473:return 0;
  		case 484:return 0;
  		case 493:return 0;
  		case 595:return 0;
  		case 417:return 0;
  		case 425:return 0;
  		case 447:return 0;
  		case 465:return 0;
  		case 469:return 0;
  		case 487:return 0;
  		case 488:return 0;
  		case 497:return 0;
  		case 501:return 0;
  		case 548:return 0;
  		case 563:return 0;
  		case 406:return 0;
  		case 444:return 0;
  		case 556:return 0;
  		case 557:return 0;
  		case 573:return 0;
  		case 460:return 0;
		case 464:return 0;
  		case 476:return 0;
  		case 511:return 0;
  		case 512:return 0;
  		case 513:return 0;
  		case 519:return 0;
  		case 520:return 0;
  		case 539:return 0;
  		case 553:return 0;
  		case 577:return 0;
		case 592:return 0;
		case 593:return 0;
		case 471:return 0;
		}
		return 1;
	}
	return 0;
}

stock GetVehicleSize(modelID, &Float: size_X, &Float: size_Y, &Float: size_Z) // Author: RyDeR`
{
	static const
		Float: sizeData[212][3] =
		{
			{ 2.32, 5.11, 1.63 }, { 2.56, 5.82, 1.71 }, { 2.41, 5.80, 1.52 }, { 3.15, 9.22, 4.17 },
			{ 2.20, 5.80, 1.84 }, { 2.34, 6.00, 1.49 }, { 5.26, 11.59, 4.42 }, { 2.84, 8.96, 2.70 },
			{ 3.11, 10.68, 3.91 }, { 2.36, 8.18, 1.52 }, { 2.25, 5.01, 1.79 }, { 2.39, 5.78, 1.37 },
			{ 2.45, 7.30, 1.38 }, { 2.27, 5.88, 2.23 }, { 2.51, 7.07, 4.59 }, { 2.31, 5.51, 1.13 },
			{ 2.73, 8.01, 3.40 }, { 5.44, 23.27, 6.61 }, { 2.56, 5.67, 2.14 }, { 2.40, 6.21, 1.40 },
			{ 2.41, 5.90, 1.76 }, { 2.25, 6.38, 1.37 }, { 2.26, 5.38, 1.54 }, { 2.31, 4.84, 4.90 },
			{ 2.46, 3.85, 1.77 }, { 5.15, 18.62, 5.19 }, { 2.41, 5.90, 1.76 }, { 2.64, 8.19, 3.23 },
			{ 2.73, 6.28, 3.48 }, { 2.21, 5.17, 1.27 }, { 4.76, 16.89, 5.92 }, { 3.00, 12.21, 4.42 },
			{ 4.30, 9.17, 3.88 }, { 3.40, 10.00, 4.86 }, { 2.28, 4.57, 1.72 }, { 3.16, 13.52, 4.76 },
			{ 2.27, 5.51, 1.72 }, { 3.03, 11.76, 4.01 }, { 2.41, 5.82, 1.72 }, { 2.22, 5.28, 1.47 },
			{ 2.30, 5.55, 2.75 }, { 0.87, 1.40, 1.01 }, { 2.60, 6.67, 1.75 }, { 4.15, 20.04, 4.42 },
			{ 3.66, 6.01, 3.28 }, { 2.29, 5.86, 1.75 }, { 4.76, 17.02, 4.30 }, { 2.42, 14.80, 3.15 },
			{ 0.70, 2.19, 1.62 }, { 3.02, 9.02, 4.98 }, { 3.06, 13.51, 3.72 }, { 2.31, 5.46, 1.22 },
			{ 3.60, 14.56, 3.28 }, { 5.13, 13.77, 9.28 }, { 6.61, 19.04, 13.84 }, { 3.31, 9.69, 3.63 },
			{ 3.23, 9.52, 4.98 }, { 1.83, 2.60, 2.72 }, { 2.41, 6.13, 1.47 }, { 2.29, 5.71, 2.23 },
			{ 10.85, 13.55, 4.44 }, { 0.69, 2.46, 1.67 }, { 0.70, 2.19, 1.62 }, { 0.69, 2.42, 1.34 },
			{ 1.58, 1.54, 1.14 }, { 0.87, 1.40, 1.01 }, { 2.52, 6.17, 1.64 }, { 2.52, 6.36, 1.66 },
			{ 0.70, 2.23, 1.41 }, { 2.42, 14.80, 3.15 }, { 2.66, 5.48, 2.09 }, { 1.41, 2.00, 1.71 },
			{ 2.67, 9.34, 4.86 }, { 2.90, 5.40, 2.22 }, { 2.43, 6.03, 1.69 }, { 2.45, 5.78, 1.48 },
			{ 11.02, 11.28, 3.28 }, { 2.67, 5.92, 1.39 }, { 2.45, 5.57, 1.74 }, { 2.25, 6.15, 1.99 },
			{ 2.26, 5.26, 1.41 }, { 0.70, 1.87, 1.32 }, { 2.33, 5.69, 1.87 }, { 2.04, 6.19, 2.10 },
			{ 5.34, 26.20, 7.15 }, { 1.97, 4.07, 1.44 }, { 4.34, 7.84, 4.44 }, { 2.32, 15.03, 4.67 },
			{ 2.32, 12.60, 4.65 }, { 2.53, 5.69, 2.14 }, { 2.92, 6.92, 2.14 }, { 2.30, 6.32, 1.28 },
			{ 2.34, 6.17, 1.78 }, { 4.76, 17.82, 3.84 }, { 2.25, 6.48, 1.50 }, { 2.77, 5.44, 1.99 },
			{ 2.27, 4.75, 1.78 }, { 2.32, 15.03, 4.65 }, { 2.90, 6.59, 4.28 }, { 2.64, 7.19, 3.75 },
			{ 2.28, 5.01, 1.85 }, { 0.87, 1.40, 1.01 }, { 2.34, 5.96, 1.51 }, { 2.21, 6.13, 1.62 },
			{ 2.52, 6.03, 1.64 }, { 2.53, 5.69, 2.14 }, { 2.25, 5.21, 1.16 }, { 2.56, 6.59, 1.62 },
			{ 2.96, 8.05, 3.33 }, { 0.70, 1.89, 1.32 }, { 0.72, 1.74, 1.12 }, { 21.21, 21.19, 5.05 },
			{ 11.15, 6.15, 2.99 }, { 8.69, 9.00, 2.23 }, { 3.19, 10.06, 3.05 }, { 3.54, 9.94, 3.42 },
			{ 2.59, 6.23, 1.71 }, { 2.52, 6.32, 1.64 }, { 2.43, 6.00, 1.57 }, { 20.30, 19.29, 6.94 },
			{ 8.75, 14.31, 2.16 }, { 0.69, 2.46, 1.67 }, { 0.69, 2.46, 1.67 }, { 0.69, 2.47, 1.67 },
			{ 3.58, 8.84, 3.64 }, { 3.04, 6.46, 3.28 }, { 2.20, 5.40, 1.25 }, { 2.43, 5.71, 1.74 },
			{ 2.54, 5.55, 2.14 }, { 2.38, 5.63, 1.86 }, { 1.58, 4.23, 2.68 }, { 1.96, 3.70, 1.66 },
			{ 8.61, 11.39, 4.17 }, { 2.38, 5.42, 1.49 }, { 2.18, 6.26, 1.15 }, { 2.67, 5.48, 1.58 },
			{ 2.46, 6.42, 1.29 }, { 3.32, 18.43, 5.19 }, { 3.26, 16.59, 4.94 }, { 2.50, 3.86, 2.55 },
			{ 2.58, 6.07, 1.50 }, { 2.26, 4.94, 1.24 }, { 2.48, 6.40, 1.70 }, { 2.38, 5.73, 1.86 },
			{ 2.80, 12.85, 3.89 }, { 2.19, 4.80, 1.69 }, { 2.56, 5.86, 1.66 }, { 2.49, 5.84, 1.76 },
			{ 4.17, 24.42, 4.90 }, { 2.40, 5.53, 1.42 }, { 2.53, 5.88, 1.53 }, { 2.66, 6.71, 1.76 },
			{ 2.65, 6.71, 3.55 }, { 28.73, 23.48, 7.38 }, { 2.68, 6.17, 2.08 }, { 2.00, 5.13, 1.41 },
			{ 3.66, 6.36, 3.28 }, { 3.66, 6.26, 3.28 }, { 2.23, 5.25, 1.75 }, { 2.27, 5.48, 1.39 },
			{ 2.31, 5.40, 1.62 }, { 2.50, 5.80, 1.78 }, { 2.25, 5.30, 1.50 }, { 3.39, 18.62, 4.71 },
			{ 0.87, 1.40, 1.01 }, { 2.02, 4.82, 1.50 }, { 2.50, 6.46, 1.65 }, { 2.71, 6.63, 1.58 },
			{ 2.71, 4.61, 1.41 }, { 3.25, 18.43, 5.03 }, { 3.47, 21.06, 5.19 }, { 1.57, 2.32, 1.58 },
			{ 1.65, 2.34, 2.01 }, { 2.93, 7.38, 3.16 }, { 1.62, 3.84, 2.50 }, { 2.49, 5.82, 1.92 },
			{ 2.42, 6.36, 1.85 }, { 62.49, 61.43, 34.95 }, { 3.15, 11.78, 2.77 }, { 2.47, 6.21, 2.55 },
			{ 2.66, 5.76, 2.24 }, { 0.69, 2.46, 1.67 }, { 2.44, 7.21, 3.19 }, { 1.66, 3.66, 3.21 },
			{ 3.54, 15.90, 3.40 }, { 2.44, 6.53, 2.05 }, { 0.69, 2.79, 1.96 }, { 2.60, 5.76, 1.45 },
			{ 3.07, 8.61, 7.53 }, { 2.25, 5.09, 2.11 }, { 3.44, 18.39, 5.03 }, { 3.18, 13.63, 4.65 },
			{ 44.45, 57.56, 18.43 }, { 12.59, 13.55, 3.56 }, { 0.50, 0.92, 0.30 }, { 2.84, 13.47, 2.21 },
			{ 2.41, 5.90, 1.76 }, { 2.41, 5.90, 1.76 }, { 2.41, 5.78, 1.76 }, { 2.92, 6.15, 2.14 },
			{ 2.40, 6.05, 1.55 }, { 3.07, 6.96, 3.82 }, { 2.31, 5.53, 1.28 }, { 2.64, 6.07, 1.42 },
			{ 2.52, 6.17, 1.64 }, { 2.38, 5.73, 1.86 }, { 2.93, 3.38, 1.97 }, { 3.01, 3.25, 1.60 },
			{ 1.45, 4.65, 6.36 }, { 2.90, 6.59, 4.21 }, { 2.48, 1.42, 1.62 }, { 2.13, 3.16, 1.83 }
		}
	;
	if(400 <= modelID <= 611)
	{
		size_X = sizeData[modelID - 400][0];
		size_Y = sizeData[modelID - 400][1];
		size_Z = sizeData[modelID - 400][2];
		return 1;
	}
	return 0;
}

stock IsPlayerLookingAtVehicle(playerid,vehicleid)
{
	if(IsPlayerConnected(playerid) && GetVehicleModel(vehicleid))
	{
		new Float:VehPos[3],Float:PlyDis,Float:PlyPos[3],Float:VehSize[3];//,Float:ZDif,Float:RealDis;
		GetVehiclePos(vehicleid,VehPos[0],VehPos[1],VehPos[2]);
		PlyDis = GetPlayerDistanceFromPoint(playerid,VehPos[0],VehPos[1],VehPos[2]);
		IsPlayerAimingAt(playerid,PlyPos[0],PlyPos[1],PlyPos[2],PlyDis);
		GetVehicleSize(GetVehicleModel(vehicleid),VehSize[0],VehSize[1],VehSize[2]);
		if(VehicleToPoint(VehSize[1],vehicleid,PlyPos[0],PlyPos[1],PlyPos[2]))
		{
			return 1;
		}
	}
	return 0;
}

stock GiveVehicleHealth(vehicleid,Float:health)
{
	if(GetVehicleModel(vehicleid))
	{
		new Float:gpHealth;
		GetVehicleHealth(vehicleid,gpHealth);
		if(gpHealth + health >= 1000){gpHealth = 1000;}
		else if(gpHealth + health <= 0){gpHealth = 0;}
		else{gpHealth += health;}
		SetVehicleHealth(vehicleid,gpHealth);
	}
	return 1;
}

stock GetPetrolcapOffsets(modelID, &Float: aimOffset_X, &Float: aimOffset_Y, &Float: aimOffset_Z)
{
	enum e_PetrolcapData
	{
		e_ModelID,
		Float: e_Offset_X,
		Float: e_Offset_Y,
		Float: e_Offset_Z
	};
	static const
		g_PetrolcapData[][e_PetrolcapData] =
		{
			{ 400, -1.100, -2.059, -0.070 },
			{ 401, 1.090, -0.939, 0.000 },
			{ 402, 1.039, -1.919, 0.140 },
			{ 403, -1.450, 0.070, -0.800 },
			{ 404, -0.939, -2.359, -0.009 },
			{ 405, -1.039, -2.180, -0.039 },
			{ 407, -1.110, -3.660, -0.540 },
			{ 408, -1.230, 1.299, -0.660 },
			{ 409, -0.980, -2.829, 0.119 },
			{ 410, -1.019, -1.669, 0.209 },
			{ 411, 1.090, -2.099, 0.090 },
			{ 412, 0.000, -3.549, -0.170 },
			{ 413, -1.049, 0.340, -0.529 },
			{ 414, -0.920, -0.740, -0.699 },
			{ 415, -1.129, -2.069, 0.019 },
			{ 416, -1.350, -2.740, -0.189 },
			{ 418, -1.179, -1.769, -0.019 },
			{ 418, 1.210, -1.570, -0.079 },
			{ 419, -1.080, -1.990, 0.029 },
			{ 420, -1.100, -2.150, 0.100 },
			{ 421, -1.070, -2.440, -0.170 },
			{ 422, -1.080, -0.419, -0.200 },
			{ 423, -1.169, -1.899, -0.319 },
			{ 424, 0.180, 1.080, 0.430 },
			{ 426, -1.100, -2.150, 0.090 },
			{ 427, -1.269, -3.200, -0.159 },
			{ 428, -1.009, -3.059, -0.490 },
			{ 429, 0.990, -2.140, 0.140 },
			{ 431, -1.450, -5.469, -0.129 },
			{ 433, -1.519, 0.159, -0.680 },
			{ 434, -0.730, -1.580, 0.289 },
			{ 436, -1.070, -1.820, 0.140 },
			{ 437, -1.490, -4.969, -0.500 },
			{ 438, -1.090, -1.929, -0.019 },
			{ 439, -1.110, -1.509, 0.059 },
			{ 440, -1.090, -0.460, -0.419 },
			{ 442, -1.210, -2.210, 0.059 },
			{ 443, -1.529, 1.240, -0.899 },
			{ 444, 0.000, -2.599, -0.059 },
			{ 445, -1.039, -1.940, 0.129 },
			{ 451, 1.059, -1.220, -0.039 },
			{ 455, -1.529, -0.009, -0.759 },
			{ 456, 0.790, -0.050, -0.610 },
			{ 458, -1.110, -2.049, -0.109 },
			{ 459, -0.819, -2.390, -0.479 },
			{ 459, -1.049, -2.289, 0.219 },
			{ 461, 0.000, 0.140, 0.540 },
			{ 463, 0.000, 0.170, 0.469 },
			{ 466, 0.000, -3.000, -0.129 },
			{ 467, -1.070, -2.299, 0.119 },
			{ 468, 0.000, 0.009, 0.409 },
			{ 470, -1.259, -2.380, 0.239 },
			{ 475, -1.070, -1.600, 0.129 },
			{ 477, -1.200, -1.529, 0.239 },
			{ 478, 1.090, -0.340, 0.230 },
			{ 479, -1.090, -1.970, 0.029 },
			{ 480, -1.000, -0.879, 0.100 },
			{ 482, 1.070, -2.190, 0.000 },
			{ 483, 0.930, -2.509, -0.039 },
			{ 485, -0.889, 0.720, 0.019 },
			{ 486, -0.699, -3.170, 0.579 },
			{ 489, 1.159, -0.740, 0.000 },
			{ 490, 1.370, -1.250, 0.000 },
			{ 491, -1.070, -2.180, 0.000 },
			{ 492, -0.980, -2.240, 0.119 },
			{ 494, -1.019, -2.200, 0.119 },
			{ 495, 1.210, -1.909, -0.100 },
			{ 496, 1.059, -1.860, 0.150 },
			{ 498, -1.299, -0.009, 0.090 },
			{ 499, -1.110, -1.070, -0.349 },
			{ 500, -0.980, -1.710, -0.070 },
			{ 502, -1.080, -1.879, 0.140 },
			{ 503, -1.100, -2.049, 0.029 },
			{ 504, 0.000, -3.000, -0.129 },
			{ 504, -1.159, -1.830, 0.109 },
			{ 505, 1.159, -0.740, 0.000 },
			{ 506, 1.049, -1.110, -0.050 },
			{ 507, -1.169, -2.299, 0.109 },
			{ 508, -1.379, -3.049, -0.670 },
			{ 514, 1.429, 0.379, -0.649 },
			{ 515, -1.450, 0.479, -1.309 },
			{ 516, -1.100, -2.450, -0.029 },
			{ 517, -1.179, -1.950, 0.070 },
			{ 518, 1.210, -2.190, -0.070 },
			{ 521, 0.000, 0.129, 0.610 },
			{ 522, 0.000, 0.140, 0.610 },
			{ 523, 0.000, 0.150, 0.550 },
			{ 524, 1.529, 0.479, -0.990 },
			{ 525, -1.389, -0.509, -0.090 },
			{ 526, -0.990, -1.960, 0.059 },
			{ 527, -1.139, -1.690, 0.140 },
			{ 528, -1.090, -2.029, 0.119 },
			{ 529, -1.200, -2.220, 0.200 },
			{ 531, -0.009, 0.819, 0.430 },
			{ 533, 1.019, -1.960, 0.140 },
			{ 534, -1.039, -0.819, -0.200 },
			{ 535, -1.200, -0.560, 0.270 },
			{ 536, -1.070, -1.690, 0.090 },
			{ 540, -1.169, -2.519, -0.019 },
			{ 541, 1.009, -1.990, 0.150 },
			{ 542, -1.120, -1.919, 0.310 },
			{ 543, -1.100, -0.949, 0.000 },
			{ 544, -1.299, 2.069, 0.319 },
			{ 545, 0.000, -2.220, -0.319 },
			{ 546, 1.090, -2.029, 0.150 },
			{ 547, -1.169, -2.009, 0.119 },
			{ 549, -1.080, -1.179, 0.219 },
			{ 550, -1.070, -2.490, 0.039 },
			{ 551, -1.149, -2.670, 0.090 },
			{ 552, -1.289, -0.959, 0.490 },
			{ 554, 1.210, -2.390, 0.119 },
			{ 555, -0.790, -1.500, 0.180 },
			{ 557, 1.190, -2.569, 0.850 },
			{ 558, -1.090, -1.940, 0.270 },
			{ 559, -1.080, -1.710, 0.270 },
			{ 560, 1.139, -1.899, 0.129 },
			{ 561, 1.110, -2.299, 0.109 },
			{ 562, 1.039, -0.699, 0.070 },
			{ 565, 0.910, -0.870, 0.029 },
			{ 566, 1.080, -2.440, 0.019 },
			{ 567, 0.000, -2.859, -0.460 },
			{ 568, -0.500, -0.660, 0.379 },
			{ 571, 0.000, 0.189, 0.019 },
			{ 572, -0.379, -0.970, 0.159 },
			{ 573, -1.179, 0.479, -0.479 },
			{ 574, -0.750, -0.970, 0.280 },
			{ 575, 0.000, -2.779, -0.050 },
			{ 576, 0.000, -3.160, -0.250 },
			{ 578, -1.240, 2.910, -0.019 },
			{ 579, 1.220, -2.299, 0.170 },
			{ 580, 1.190, -1.820, 0.239 },
			{ 581, 0.000, 0.129, 0.540 },
			{ 582, -1.059, 0.140, -0.280 },
			{ 583, -0.759, 0.409, -0.059 },
			{ 584, 0.000, 0.000, 0.000 },
			{ 585, 1.139, -2.299, 0.200 },
			{ 587, -1.230, -1.220, 0.100 },
			{ 588, -1.460, -2.160, 0.219 },
			{ 589, 0.980, -0.889, 0.119 },
			{ 596, -1.110, -2.160, 0.100 },
			{ 597, -1.100, -2.150, 0.100 },
			{ 598, -1.080, -1.960, 0.159 },
			{ 599, 1.159, -0.740, 0.000 },
			{ 600, 1.090, -2.029, 0.079 },
			{ 601, -1.330, -1.690, 0.920 },
			{ 602, 1.090, -1.990, 0.109 },
			{ 603, 1.179, -2.190, -0.079 },
			{ 604, 0.000, -3.000, -0.129 },
			{ 605, -1.100, -0.949, 0.000 },
			{ 609, -1.299, 0.000, 0.100 }
		}
	;
	for(new i; i < sizeof(g_PetrolcapData); ++i)
	{
		if(g_PetrolcapData[i][e_ModelID] == modelID)
		{
			aimOffset_X = g_PetrolcapData[i][e_Offset_X];
			aimOffset_Y = g_PetrolcapData[i][e_Offset_Y];
			aimOffset_Z = g_PetrolcapData[i][e_Offset_Z];
			return 1;
		}
	}
	return 0;
}
stock v_Engine(v, t=-1)
{
	new e, l, a, d, bn, bt, o;
	GetVehicleParamsEx(v, e, l, a, d, bn, bt, o);
	if(t!=-1)SetVehicleParamsEx(v, t, l, a, d, bn, bt, o);
	return e;
}
stock v_Lights(v, t=-1)
{
	new e, l, a, d, bn, bt, o;
	GetVehicleParamsEx(v, e, l, a, d, bn, bt, o);
	if(t!=-1)SetVehicleParamsEx(v, e, t, a, d, bn, bt, o);
	return l;
}
stock v_Alarm(v, t=-1)
{
	new e, l, a, d, bn, bt, o;
	GetVehicleParamsEx(v, e, l, a, d, bn, bt, o);
	if(t!=-1)SetVehicleParamsEx(v, e, l, t, d, bn, bt, o);
	return a;
}
stock v_Doors(v, t=-1)
{
	new e, l, a, d, bn, bt, o;
	GetVehicleParamsEx(v, e, l, a, d, bn, bt, o);
	if(t!=-1)SetVehicleParamsEx(v, e, l, a, t, bn, bt, o);
	return d;
}
stock v_Bonnet(v, t=-1)
{
	new e, l, a, d, bn, bt, o;
	GetVehicleParamsEx(v, e, l, a, d, bn, bt, o);
	if(t!=-1)SetVehicleParamsEx(v, e, l, a, d, t, bt, o);
	return bn;
}
stock v_Boot(v, t=-1)
{
	new e, l, a, d, bn, bt, o;
	GetVehicleParamsEx(v, e, l, a, d, bn, bt, o);
	if(t!=-1)SetVehicleParamsEx(v, e, l, a, d, bn, t, o);
	return bt;
}

encode_tires(tire1, tire2, tire3, tire4) return tire1 | (tire2 << 1) | (tire3 << 2) | (tire4 << 3);
encode_panels(flp, frp, rlp, rrp, windshield, front_bumper, rear_bumper)
{
    return flp | (frp << 4) | (rlp << 8) | (rrp << 12) | (windshield << 16) | (front_bumper << 20) | (rear_bumper << 24);
}
encode_doors(bonnet, boot, driver_door, passenger_door, behind_driver_door, behind_passenger_door)
{
    #pragma unused behind_driver_door
    #pragma unused behind_passenger_door
    return bonnet | (boot << 8) | (driver_door << 16) | (passenger_door << 24);
}
encode_lights(light1, light2, light3, light4)
{
    return light1 | (light2 << 1) | (light3 << 2) | (light4 << 3);
}
#define VTYPE_CAR 1
#define VTYPE_HEAVY 2
#define VTYPE_MONSTER 3
#define VTYPE_BIKE 4
#define VTYPE_QUAD 5
#define VTYPE_BMX 6
#define VTYPE_HELI 7
#define VTYPE_PLANE 8
#define VTYPE_SEA 9
#define VTYPE_TRAILER 10
#define VTYPE_TRAIN 11
#define VTYPE_BOAT VTYPE_SEA
#define VTYPE_BICYCLE VTYPE_BMX

stock GetVehicleType(vehicleid)
{
	new type;
	switch(GetVehicleModel(vehicleid))
	{
// ================== CARS =======
	case
	416,   //ambulan  -  car
	445,   //admiral  -  car
	602,   //alpha  -  car
	485,   //baggage  -  car
	568,   //bandito  -  car
	429,   //banshee  -  car
	499,   //benson  -  car
	424,   //bfinject,   //car
	536,   //blade  -  car
	496,   //blistac  -  car
	504,   //bloodra  -  car
	422,   //bobcat  -  car
	609,   //boxburg  -  car
	498,   //boxville,   //car
	401,   //bravura  -  car
	575,   //broadway,   //car
	518,   //buccanee,   //car
	402,   //buffalo  -  car
	541,   //bullet  -  car
	482,   //burrito  -  car
	431,   //bus  -  car
	438,   //cabbie  -  car
	457,   //caddy  -  car
	527,   //cadrona  -  car
	483,   //camper  -  car
	524,   //cement  -  car
	415,   //cheetah  -  car
	542,   //clover  -  car
	589,   //club  -  car
	480,   //comet  -  car
	596,   //copcarla,   //car
	599,   //copcarru,   //car
	597,   //copcarsf,   //car
	598,   //copcarvg,   //car
	578,   //dft30  -  car
	486,   //dozer  -  car
	507,   //elegant  -  car
	562,   //elegy  -  car
	585,   //emperor  -  car
	427,   //enforcer,   //car
	419,   //esperant,   //car
	587,   //euros  -  car
	490,   //fbiranch,   //car
	528,   //fbitruck,   //car
	533,   //feltzer  -  car
	544,   //firela  -  car
	407,   //firetruk,   //car
	565,   //flash  -  car
	455,   //flatbed  -  car
	530,   //forklift,   //car
	526,   //fortune  -  car
	466,   //glendale,   //car
	604,   //glenshit,   //car
	492,   //greenwoo,   //car
	474,   //hermes  -  car
	434,   //hotknife,   //car
	502,   //hotrina  -  car
	503,   //hotrinb  -  car
	494,   //hotring  -  car
	579,   //huntley  -  car
	545,   //hustler  -  car
	411,   //infernus,   //car
	546,   //intruder,   //car
	559,   //jester  -  car
	508,   //journey  -  car
	571,   //kart  -  car
	400,   //landstal,   //car
	403,   //linerun  -  car
	517,   //majestic,   //car
	410,   //manana  -  car
	551,   //merit  -  car
	500,   //mesa  -  car
	418,   //moonbeam,   //car
	572,   //mower  -  car
	423,   //mrwhoop  -  car
	516,   //nebula  -  car
	582,   //newsvan  -  car
	467,   //oceanic  -  car
	404,   //peren  -  car
	514,   //petro  -  car
	603,   //phoenix  -  car
	600,   //picador  -  car
	413,   //pony  -  car
	426,   //premier  -  car
	436,   //previon  -  car
	547,   //primo  -  car
	489,   //rancher  -  car
	441,   //rcbandit,   //car
	594,   //rccam  -  car
	564,   //rctiger  -  car
	515,   //rdtrain  -  car
	479,   //regina  -  car
	534,   //remingtn,   //car
	505,   //rnchlure,   //car
	442,   //romero  -  car
	440,   //rumpo  -  car
	475,   //sabre  -  car
	543,   //sadler  -  car
	605,   //sadlshit,   //car
	495,   //sandking,   //car
	567,   //savanna  -  car
	428,   //securica,   //car
	405,   //sentinel,   //car
	535,   //slamvan  -  car
	458,   //solair  -  car
	580,   //stafford,   //car
	439,   //stallion,   //car
	561,   //stratum  -  car
	409,   //stretch  -  car
	560,   //sultan  -  car
	550,   //sunrise  -  car
	506,   //supergt  -  car
	601,   //swatvan  -  car
	574,   //sweeper  -  car
	566,   //tahoma  -  car
	549,   //tampa  -  car
	420,   //taxi  -  car
	459,   //topfun  -  car
	576,   //tornado  -  car
	583,   //tug  -  car
	451,   //turismo  -  car
	558,   //uranus  -  car
	552,   //utility  -  car
	540,   //vincent  -  car
	491,   //virgo  -  car
	412,   //voodoo  -  car
	478,   //walton  -  car
	421,   //washing  -  car
	529,   //willard  -  car
	555,   //windsor  -  car
	456,   //yankee  -  car
	554,   //yosemite -  car
	477   //zr350  -  car
	: type = VTYPE_CAR;

// ================== BIKES =======
	case
	581,   //bf400  -  bike
	523,   //copbike  -  bike
	462,   //faggio  -  bike
	521,   //fcr900  -  bike
	463,   //freeway  -  bike
	522,   //nrg500  -  bike
	461,   //pcj600  -  bike
	448,   //pizzaboy,   //bike
	468,   //sanchez  -  bike
	586   //wayfarer,   //bike
	: type = VTYPE_BIKE;

// =================== BMX =======
	case
	509,   //bike  -  bmx
	481,   //bmx  -  bmx
	510   //mtbike  -  bmx
	: type = VTYPE_BMX;

// ================== QUADS =======
	case
	471   //quad  -  quad
	: type = VTYPE_QUAD;

// ================== SEA =======
	case
	472,   //coastg  -  boat
	473,   //dinghy  -  boat
	493,   //jetmax  -  boat
	595,   //launch  -  boat
	484,   //marquis  -  boat
	430,   //predator,   //boat
	453,   //reefer  -  boat
	452,   //speeder  -  boat
	446,   //squalo  -  boat
	454   //tropic  -  boat
	: type = VTYPE_SEA;

// ================= HELI =======
	case
	548,   //cargobob,   //heli
	425,   //hunter  -  heli
	417,   //leviathn,   //heli
	487,   //maverick,   //heli
	497,   //polmav  -  heli
	563,   //raindanc,   //heli
	501,   //rcgoblin,   //heli
	465,   //rcraider,   //heli
	447,   //seaspar  -  heli
	469,   //sparrow  -  heli
	488   //vcnmav  -  heli
	: type = VTYPE_HELI;

// ================ PLANE =======
	case
	592,   //androm  -  plane
	577,   //at	400  -  plane
	511,   //beagle  -  plane
	512,   //cropdust,   //plane
	593,   //dodo  -  plane
	520,   //hydra  -  plane
	553,   //nevada  -  plane
	464,   //rcbaron  -  plane
	476,   //rustler  -  plane
	519,   //shamal  -  plane
	460,   //skimmer  -  plane
	513,   //stunt  -  plane
	539   //vortex  -  plane
	: type = VTYPE_PLANE;

// ================== HEAVY =======
	case
	588,   //hotdog  -  car
	437,   //coach  -  car
	532,   //combine  -  car
	433,   //barracks,   //car
	414,   //mule  -  car
	443,   //packer  -  car
	470,   //patriot  -  car
	432,   //rhino  -  car
	525,   //towtruck,   //car
	531,   //tractor  -  car
	408   //trash  -  car
	: type = VTYPE_HEAVY;

// ================ MONSTER =======
	case
	406,   //dumper  -  mtruck
	573,   //duneride,   //mtruck
	444,   //monster  -  mtruck
	556,   //monstera,   //mtruck
	557   //monsterb,   //mtruck
	: type = VTYPE_MONSTER;

// ================ TRAILER =======
	case
	435,   //artict1  -  trailer
	450,   //artict2  -  trailer
	591,   //artict3  -  trailer
	606,   //bagboxa  -  trailer
	607,   //bagboxb  -  trailer
	610,   //farmtr1  -  trailer
	584,   //petrotr  -  trailer
	608,   //tugstair -  trailer
	611   //utiltr1  -  trailer
	: type = VTYPE_TRAILER;

// ================== TRAIN =======
	case
	590,   //freibox  -  train
	569,   //freiflat,   //train
	537,   //freight  -  train
	538,   //streak  -  train
	570,   //streakc  -  train
	449   //tram  -  train
	: type = VTYPE_TRAIN;
	}
	return type;
}


new VehicleSeats[212] =
{
	4,2,2,2,4,4,1,2,2,4,2,2,2,4,2,2,4,2,4,2,4,4,2,2,2,1,4,4,4,2,1,500,1,2,2,0,2,500,4,2,4,1,2,2,2,4,1,2,
	1,0,0,2,1,1,1,2,2,2,4,4,2,2,2,2,1,1,4,4,2,2,4,2,1,1,2,2,1,2,2,4,2,1,4,3,1,1,1,4,2,2,4,2,4,1,2,2,2,4,
	4,2,2,1,2,2,2,2,2,4,2,1,1,2,1,1,2,2,4,2,2,1,1,2,2,2,2,2,2,2,2,4,1,1,1,2,2,2,2,500,500,1,4,2,2,2,2,2,
	4,4,2,2,4,4,2,1,2,2,2,2,2,2,4,4,2,2,1,2,4,4,1,0,0,1,1,2,1,2,2,1,2,4,4,2,4,1,0,4,2,2,2,2,0,0,500,2,2,
	1,4,4,4,2,2,2,2,2,4,2,0,0,0,4,0,0
};
stock GetVehicleMaxSeats(modelid) return VehicleSeats[modelid-400];

stock Float:ph_Velocity(Float:distance, timetaken)
		return(distance/timetaken); // Meters per Second (m/s)
stock Float:ph_Acceleration(Float:velocitychange, timetaken) // (vfinal - vinitial) / (tfinal - tinitial)
		return(velocitychange/timetaken); // Meters per Second Squared (m/s^2)
stock Float:ph_Force(Float:mass, Float:acceleration)
		return(mass*acceleration); // Newtons (N)
stock Float:ph_Momentum(Float:mass, Float:velocity)
		return(mass*velocity); // Kilograms per Meter per Second (kgm/s)
stock Float:ph_ImpactForce(Float:momentum, timetaken)
		return(momentum/timetaken); // Newtons (N)

