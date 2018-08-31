#define AD_FLAG_MOVE_SPEED	(0.5)
#define AD_POLE_ZOFFSET		(-5.0)
#define AD_FLAG_ZOFFSET		(5.5)

new
	PointToCapture,		 				// Sphere to detect player presence
	MaxPoints,                      	// Maximum points to capture for large maps with multiple capture points
	CaptureProgress,                	// For extra spawn points for large A/D maps
	Float:CapturePoint[3][3],	  		// Capture Point Position
	CaptureIcon,						// Icon for capture point position
	bool:PointCT,						// Timer variable
	capturer,                       	// Person who is capturing
	DefendingTeam,	 					// Defending Team
	PlayerBar:ADbar[MAX_PLAYERS],                      	// Progress Bar
	Float:ADfill,                         	// Fill amount for Bar
	ADcaptureTime=30,					// Capture Time In Seconds
	
	AD_ObjPole,
	AD_ObjFlag[2][2];


CreateCaptureBase(Float:x, Float:y, Float:z)
{
	PointToCapture		= CreateDynamicSphere(x, y, z, 5.0, DEATHMATCH_WORLD);
	CaptureIcon			= CreateDynamicMapIcon(x, y, z, 19, BLUE, DEATHMATCH_WORLD, _, _, 1000.0);

	AD_ObjPole			= CreateDynamicObject(16101, x, y, z+AD_POLE_ZOFFSET, 0.0, 0.0, 0.0, DEATHMATCH_WORLD);
	AD_ObjFlag[0][0]	= CreateDynamicObject(2048, x+0.98, y, z+AD_POLE_ZOFFSET+AD_FLAG_ZOFFSET, 0.0, 0.0, 0.0, DEATHMATCH_WORLD);
	AD_ObjFlag[0][1]	= CreateDynamicObject(2048, x+0.98, y, z+AD_POLE_ZOFFSET+AD_FLAG_ZOFFSET, 0.0, 0.0, 180.0, DEATHMATCH_WORLD);
	AD_ObjFlag[1][0]	= CreateDynamicObject(2048, x+0.98, y, z+AD_POLE_ZOFFSET+AD_FLAG_ZOFFSET, 0.0, 0.0, 0.0, DEATHMATCH_WORLD);
	AD_ObjFlag[1][1]	= CreateDynamicObject(2048, x+0.98, y, z+AD_POLE_ZOFFSET+AD_FLAG_ZOFFSET, 0.0, 0.0, 180.0, DEATHMATCH_WORLD);

	SetDynamicObjectMaterial(AD_ObjFlag[DefendingTeam][0], 0, 18646, "matcolours", "blue", 0);
	SetDynamicObjectMaterial(AD_ObjFlag[DefendingTeam][1], 0, 18646, "matcolours", "blue", 0);
	SetDynamicObjectMaterial(AD_ObjFlag[!DefendingTeam][0], 0, 18646, "matcolours", "red", 0);
	SetDynamicObjectMaterial(AD_ObjFlag[!DefendingTeam][1], 0, 18646, "matcolours", "red", 0);
}
ResetCaptureBase()
{
	Streamer_SetFloatData(STREAMER_TYPE_AREA, PointToCapture, E_STREAMER_X, CapturePoint[CaptureProgress][0]);
	Streamer_SetFloatData(STREAMER_TYPE_AREA, PointToCapture, E_STREAMER_Y, CapturePoint[CaptureProgress][1]);
	Streamer_SetFloatData(STREAMER_TYPE_AREA, PointToCapture, E_STREAMER_Z, CapturePoint[CaptureProgress][2]);

	Streamer_SetFloatData(STREAMER_TYPE_MAP_ICON, CaptureIcon, E_STREAMER_X, CapturePoint[CaptureProgress][0]);
	Streamer_SetFloatData(STREAMER_TYPE_MAP_ICON, CaptureIcon, E_STREAMER_Y, CapturePoint[CaptureProgress][1]);
	Streamer_SetFloatData(STREAMER_TYPE_MAP_ICON, CaptureIcon, E_STREAMER_Z, CapturePoint[CaptureProgress][2]);

	Streamer_SetFloatData(STREAMER_TYPE_OBJECT, AD_ObjPole, E_STREAMER_X, CapturePoint[CaptureProgress][0]);
	Streamer_SetFloatData(STREAMER_TYPE_OBJECT, AD_ObjPole, E_STREAMER_Y, CapturePoint[CaptureProgress][1]);
	Streamer_SetFloatData(STREAMER_TYPE_OBJECT, AD_ObjPole, E_STREAMER_Z, CapturePoint[CaptureProgress][2]+AD_POLE_ZOFFSET);
	
	printf("Moving CB to: %f, %f, %f", CapturePoint[CaptureProgress][0], CapturePoint[CaptureProgress][1], CapturePoint[CaptureProgress][2]);


	for(new t;t<2;t++)
	{
		for(new f;f<2;f++)
		{
			StopDynamicObject(AD_ObjFlag[t][f]);
			Streamer_SetFloatData(STREAMER_TYPE_OBJECT, AD_ObjFlag[t][f], E_STREAMER_X, CapturePoint[CaptureProgress][0]+0.98);
			Streamer_SetFloatData(STREAMER_TYPE_OBJECT, AD_ObjFlag[t][f], E_STREAMER_Y, CapturePoint[CaptureProgress][1]);
			Streamer_SetFloatData(STREAMER_TYPE_OBJECT, AD_ObjFlag[t][f], E_STREAMER_Z, CapturePoint[CaptureProgress][2]+AD_POLE_ZOFFSET+AD_FLAG_ZOFFSET);
		}
	}
}
MoveADFlag()
{
	MoveDynamicObject(AD_ObjFlag[0][0], CapturePoint[CaptureProgress][0]+0.98, CapturePoint[CaptureProgress][1], CapturePoint[CaptureProgress][2]+AD_POLE_ZOFFSET+AD_FLAG_ZOFFSET+(ADfill * (4.5/ADcaptureTime)), AD_FLAG_MOVE_SPEED);
	MoveDynamicObject(AD_ObjFlag[0][1], CapturePoint[CaptureProgress][0]+0.98, CapturePoint[CaptureProgress][1], CapturePoint[CaptureProgress][2]+AD_POLE_ZOFFSET+AD_FLAG_ZOFFSET+(ADfill * (4.5/ADcaptureTime)), AD_FLAG_MOVE_SPEED);
	MoveDynamicObject(AD_ObjFlag[1][0], CapturePoint[CaptureProgress][0]+0.98, CapturePoint[CaptureProgress][1], CapturePoint[CaptureProgress][2]+AD_POLE_ZOFFSET+AD_FLAG_ZOFFSET+(ADfill * (4.5/ADcaptureTime)), AD_FLAG_MOVE_SPEED);
	MoveDynamicObject(AD_ObjFlag[1][1], CapturePoint[CaptureProgress][0]+0.98, CapturePoint[CaptureProgress][1], CapturePoint[CaptureProgress][2]+AD_POLE_ZOFFSET+AD_FLAG_ZOFFSET+(ADfill * (4.5/ADcaptureTime)), AD_FLAG_MOVE_SPEED);
}
UpdateBaseFlag(playerid)
{
	Streamer_AppendArrayData(STREAMER_TYPE_OBJECT, AD_ObjFlag[pTeam(playerid)][0], E_STREAMER_PLAYER_ID, playerid);
	Streamer_AppendArrayData(STREAMER_TYPE_OBJECT, AD_ObjFlag[pTeam(playerid)][1], E_STREAMER_PLAYER_ID, playerid);
	Streamer_RemoveArrayData(STREAMER_TYPE_OBJECT, AD_ObjFlag[!pTeam(playerid)][0], E_STREAMER_PLAYER_ID, playerid);
	Streamer_RemoveArrayData(STREAMER_TYPE_OBJECT, AD_ObjFlag[!pTeam(playerid)][1], E_STREAMER_PLAYER_ID, playerid);
}

GetPlayersCapturingAD()
{
	new c;
	PlayerLoop(i)if(bPlayerDeathmatchSettings[i]&dm_Capturing)c++;
	return c;
}


AD_CaptureUpdate(playerid)
{
	ADfill += (1*GetPlayersCapturingAD());
	MoveADFlag();
	PlayerLoop(i)if( (bPlayerGameSettings[i]&InDM) && (bPlayerDeathmatchSettings[i]&dm_Capturing) ) SetPlayerProgressBarValue(i, ADbar[i], ADfill);
	if(ADfill >= ADcaptureTime)
	{
		GiveXP(playerid, 25, "Capture");
		pStatCount[playerid][st_Obj][st_AdCaps]++;
		AwardDataUpdate(playerid, .obj=1);

	    PlayerLoop(i)
		{
			if(IsPlayerInDynamicArea(i, PointToCapture) && i!=playerid && pTeam(i)!=DefendingTeam)GiveXP(i, 15, "Capture Assist");
			if(bPlayerGameSettings[i]&InDM) HidePlayerProgressBar(i, ADbar[i]);
		}

		ADfill=0;
		PointCT=false;

		CaptureProgress++;
		if(CaptureProgress>=MaxPoints)
		{
			StopMatchTime();
			EndRound(!DefendingTeam);
		}
		else
		{
			ResetCaptureBase();
			PlayerLoop(i)if(bPlayerGameSettings[i]&InDM)Streamer_Update(i);
		}
	}
}

