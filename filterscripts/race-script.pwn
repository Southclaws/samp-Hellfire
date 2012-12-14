new Float:VanRaceCheckpoints[][]={
{-512.272339,-154.279739,72.976563},
{-493.745544,39.066315,42.419228},
{-616.524475,182.073776,17.810425},
{-764.178711,193.052536,1.497314},
{-737.805237,36.330212,31.105286},
{-684.001526,35.373520,32.537552},
{-702.694824,114.715904,16.232853},
{-775.446777,166.816956,3.712494},
{-669.570374,214.777618,2.277287},
{-506.143311,62.028564,35.965122},
{-506.787903,-41.418549,58.751743},
{-542.835388,-88.377419,62.241611},
{-623.547546,-61.458580,62.659523},
{-681.548401,183.270660,22.209030},
{-626.631958,235.772995,18.357948},
{-454.871216,191.024155,4.968330},
{-338.841858,169.303741,5.491722},
{-233.968430,207.980408,10.333893},
{-205.179413,229.268616,11.071045},
{-225.643845,245.131775,10.578335},
{-669.460999,255.632568,1.078125},
{-765.376831,118.820976,11.383125},
{-794.771545,17.436625,32.230515},
{-732.336243,-1.553062,55.288429},
{-738.255737,-83.974525,66.427612},
{-894.336975,-136.116241,55.958458},
{-938.813416,-196.597366,41.392525},
{-921.618164,-241.811722,37.143791},
{-562.046875,-253.943497,60.247559},
{-356.485504,-264.799103,14.806458},
{-268.848022,-236.489136,0.190723},
{-310.635956,-99.929306,0.085846},
{-275.583740,57.317032,0.078125},
{-228.195251,180.870575,6.213570},
{-234.417847,207.973190,10.363998},
{-274.470520,200.106415,6.707726},
{-299.572540,95.768555,8.087227},
{-392.582184,29.474148,34.327511},
{-352.156921,-108.495216,47.529640},
{-413.056366,-182.599976,67.511406},
{-482.170563,-189.363235,77.179611}
}; // Last checkpoint is near start so you could even have multiple laps

new Float:SultanRaceCheckpoints[][]={
	{371.2087,-95.8173,1.0678,273.1996},
	{387.4589,-62.4971,2.2749,359.8029},
	{458.5520,29.6226,11.5967,307.6124},
	{547.0475,-15.1765,27.2186,246.4589},
	{745.1796,15.2579,45.8917,301.5761},
	{989.0279,-6.6728,92.2203,279.2920},
	{1189.1224,47.8633,36.6537,305.7000},
	{1243.0840,134.4697,19.6240,347.6075},
	{1237.9070,272.4267,19.1098,64.5973},
	{1192.1578,306.6451,19.1617,72.7496},
	{1133.0513,262.0240,23.5560,144.3396},
	{988.1041,164.1483,27.9478,116.3401},
	{828.2374,216.1807,36.6760,101.2124},
	{796.2215,214.0766,35.3777,90.3516},
	{744.4565,213.6269,27.8526,84.6415},
	{555.5907,166.6857,24.8797,127.9340},
	{524.6296,120.0259,22.9303,179.6221},
	{530.7641,5.9863,23.7503,180.9020},
	{565.9884,-31.9612,24.5626,193.5909},
	{683.5255,-32.5470,23.2852,315.6909},
	{713.3294,-41.4530,29.4292,226.5492},
	{840.9796,-28.0144,61.9985,273.5970},
	{973.9255,-52.6322,78.9652,290.0784},
	{1089.0673,-29.2612,76.9676,298.9051},
	{1082.0859,0.7064,72.2832,93.2968},
	{926.0976,-12.1177,91.0474,87.7186},
	{824.9892,35.4321,78.8652,98.8638},
	{645.4738,-69.2568,16.1690,125.1896},
	{545.6332,-16.7288,27.3176,72.0959},
	{531.1163,-2.0603,24.9884,0.2676},
	{524.0486,124.7246,23.1710,3.1888},
	{582.3809,186.8837,20.1557,309.8080},
	{814.7042,214.0562,37.8452,270.1143},
	{945.5797,176.9539,31.3634,231.0132},
	{1179.7633,129.9434,23.8076,244.2712},
	{1237.7878,100.9212,20.7152,225.9488},
	{1437.7358,-182.9601,30.9744,174.5262},
	{1406.0844,-294.9240,2.4255,317.3392}
}; // Sprint Race - Does not head back to starting point

new VanRaceCars[4];
new SultanRaceCars[4];
new VanColors[]={79, 3, 1, 6, 0};
new SultanColors[]={79, 3, 1, 6, 0};

public OnFilterScriptInit()
{
	for(new i=0; i<4; i++)
	{
		VanRaceCars[i] = CreateVehicle(482,-506.6+(3*i), -198.63, 78.7, 0, VanColors[random(sizeof(VanColors))], VanColors[random(sizeof(VanColors))], -1);
		SultanRaceCars[i] = CreateVehicle(560, 358.17+(i*4),-77.96,1.08,180, SultanColors[random(sizeof(SultanColors))], SultanColors[random(sizeof(SultanColors))], -1);
	}
	return 1;
}

public OnFilterScriptExit()
{
	for(new p=0; p<MAX_PLAYERS; p++) DestroyPlayerObject(p, GetPVarInt(p, "SultanRaceObject"));
	for(new i=0; i<4; i++)
	{
		DestroyVehicle(VanRaceCars[i]); // Racing Vans
		DestroyVehicle(SultanRaceCars[i]); // Sultans
	}
	return 1;
}

public OnPlayerConnect(playerid)
{
	RemoveBuildingForPlayer(playerid, 1503, 1434.1094, -185.9766, 30.3672, 25); // it's easier with this object removed...
	return 1;
}

//===============================================//
Actual race script below:
//===============================================//

public OnPlayerEnterRaceCheckpoint(playerid)
{
	if(VanRace[playerid]>=1)
	{
		VanRace[playerid]++;
		DisablePlayerCheckpoint(playerid);
		DisablePlayerRaceCheckpoint(playerid);
		new i=VanRace[playerid];
		if(VanRace[playerid]<40)
		{
			SetPlayerRaceCheckpoint(playerid, 0, VanRaceCheckpoints[i][0],VanRaceCheckpoints[i][1],VanRaceCheckpoints[i][2], VanRaceCheckpoints[i+1][0],VanRaceCheckpoints[i+1][1],VanRaceCheckpoints[i+1][2],5);
			SetPlayerCheckpoint(playerid, VanRaceCheckpoints[i+1][0],VanRaceCheckpoints[i+1][1],VanRaceCheckpoints[i+1][2], 10);
		}else if(VanRace[playerid]==40){
		    SetPlayerRaceCheckpoint(playerid, 1, VanRaceCheckpoints[i][0],VanRaceCheckpoints[i][1],VanRaceCheckpoints[i][2], VanRaceCheckpoints[i][0],VanRaceCheckpoints[i][1],VanRaceCheckpoints[i][2],5);
		}else{ // Finnish
		    new vehicleid = GetPlayerVehicleID(playerid);
	        for(new z=0; z<4; z++)
			{
	    		if(VanRaceSlots[z]==vehicleid && VanRaceSlots[z+4]!=0)
	    		{
	    			VanRaceSlots[z+4]=0;
	    		}
	    	}
	    	VanRace[playerid]=0;
		    GameTextForPlayer(playerid, "Congratulatons!~n~~y~You have completed~n~~w~this race!", 7300, 4);
		    GivePlayerMoney(playerid, 7777);
		}
	}else if(SultanRace[playerid]>=1)
	{
		SultanRace[playerid]++;
		DisablePlayerCheckpoint(playerid);
		DisablePlayerRaceCheckpoint(playerid);
		new i=SultanRace[playerid];
		if(SultanRace[playerid]<36)
		{
			SetPlayerRaceCheckpoint(playerid, 0, SultanRaceCheckpoints[i][0],SultanRaceCheckpoints[i][1],SultanRaceCheckpoints[i][2], SultanRaceCheckpoints[i+1][0],SultanRaceCheckpoints[i+1][1],SultanRaceCheckpoints[i+1][2],5);
			SetPlayerCheckpoint(playerid, SultanRaceCheckpoints[i+1][0],SultanRaceCheckpoints[i+1][1],SultanRaceCheckpoints[i+1][2], 10);
		}else if(SultanRace[playerid]==36)
		{
			SetPVarInt(playerid, "SultanRaceObject",CreatePlayerObject(playerid, 18753, 1392.93, -321.23, -1.04, -2.04, 0.00, 2.14));
			SetPlayerRaceCheckpoint(playerid, 0, SultanRaceCheckpoints[i][0],SultanRaceCheckpoints[i][1],SultanRaceCheckpoints[i][2], SultanRaceCheckpoints[i+1][0],SultanRaceCheckpoints[i+1][1],SultanRaceCheckpoints[i+1][2],12);
			SetPlayerCheckpoint(playerid, SultanRaceCheckpoints[i+1][0],SultanRaceCheckpoints[i+1][1],SultanRaceCheckpoints[i+1][2], 24);
		}else if(SultanRace[playerid]==37){
		    SetPlayerRaceCheckpoint(playerid, 1, SultanRaceCheckpoints[i][0],SultanRaceCheckpoints[i][1],SultanRaceCheckpoints[i][2], SultanRaceCheckpoints[i][0],SultanRaceCheckpoints[i][1],SultanRaceCheckpoints[i][2],40);
		}else{ // Finnish
		    new vehicleid = GetPlayerVehicleID(playerid);
	        for(new z=0; z<4; z++)
			{
	    		if(SultanRaceSlots[z]==vehicleid && SultanRaceSlots[z+4]!=0)
	    		{
	    			SultanRaceSlots[z+4]=0;
	    		}
	    	}
	    	DestroyPlayerObject(playerid, GetPVarInt(playerid, "SultanRaceObject"));
	    	SultanRace[playerid]=0;
		    GameTextForPlayer(playerid, "Congratulatons!~n~~y~You have completed~n~~w~this race!", 7300, 4);
		    GivePlayerMoney(playerid, 7777);
		}
	}
	return 1;
}

CMD:race(playerid, params[])
{
	if(IsPlayerInRangeOfPoint(playerid, 25, -501.6, -198.63, 78.7)) // Van Race
	{
	
		//If above applies, put player in the first empty slot, and do this: 
				VanRace[playerid]=1;
	    	    PutPlayerInVehicle(playerid, VanRaceCars[i], 0);
				SetPlayerRaceCheckpoint(playerid, 0, VanRaceCheckpoints[0][0],VanRaceCheckpoints[0][1],VanRaceCheckpoints[0][2], VanRaceCheckpoints[1][0],VanRaceCheckpoints[1][1],VanRaceCheckpoints[1][2],5);
				SetPlayerCheckpoint(playerid, VanRaceCheckpoints[1][0],VanRaceCheckpoints[1][1],VanRaceCheckpoints[1][2], 10);
		

	}else if(IsPlayerInRangeOfPoint(playerid, 25, 363, -78.63, 1.7)) // Sultan Race
	{
		//If above applies, put player in the first empty slot, and do this: 
				SultanRace[playerid]=1;
	    	    PutPlayerInVehicle(playerid, SultanRaceCars[i], 0);
				SetPlayerRaceCheckpoint(playerid, 0, SultanRaceCheckpoints[0][0],SultanRaceCheckpoints[0][1],SultanRaceCheckpoints[0][2], SultanRaceCheckpoints[1][0],SultanRaceCheckpoints[1][1],SultanRaceCheckpoints[1][2],5);
				SetPlayerCheckpoint(playerid, SultanRaceCheckpoints[1][0],SultanRaceCheckpoints[1][1],SultanRaceCheckpoints[1][2], 10);
	    
	}
	return 1;
}