#define REQ_CAPTURE_POINTS	10
#define CP_POLE_ZOFFSET		(-5.0)
#define CP_FLAG_ZOFFSET		(5.5)
#define FLAG_MOVE_SPEED		(0.65)


new
	CQS_Leader,
	Text3D:CPlabel	[MAX_CP][2],
	CPicon			[MAX_CP][2],
	CPflag			[MAX_CP],
	CP_ObjPole      [MAX_CP],
	CP_ObjFlag      [MAX_CP][2][2],
	PlayerBar:CPbar	[MAX_PLAYERS][MAX_CP],

	CPowner			[MAX_CP]=-1,
	CPname          [MAX_CP][MAX_CPNAME],
	Float:CPpoint	[MAX_CP][3],
	Float:CPOfSet   [MAX_CP][3],
	Float:CPfill	[MAX_CP],
	bool:CPtimer	[MAX_CP],
	FirstToCapture  [MAX_CP],
	CPFlash         [MAX_CP]=-1,
	CapturingCP		[MAX_PLAYERS]=-1,
	cq_Spawn		[MAX_PLAYERS];


//======================Conquest Functions

stock GetPlayersCapturing(cp)
{
	new c;
	PlayerLoop(i)if(CapturingCP[i]==cp)c++;
	return c;
}
stock GetPlayersInTeamCapturing(teamid, cp)
{
	new c;
	PlayerLoop(i) if( (pTeam(i)==teamid) && (IsPlayerInDynamicArea(i, CPflag[cp])) ) c++;
	return c;
}
stock GetRavenCPs()
{
	new TcpS;
	for(new t;t<MAX_CP;t++)if(CPowner[t] == 0) TcpS++;
	return TcpS;
}
stock GetValorCPs()
{
	new TcpS;
	for(new t;t<MAX_CP;t++)if(CPowner[t] == 1) TcpS++;
	return TcpS;
}
stock GetEmptyCPs()
{
	new TcpS;
	for(new t;t<MAX_CP;t++)if(CPowner[t] == -1) TcpS++;
	return TcpS;
}

CreateCommandPost(cp, Float:x, Float:y, Float:z)
{
	new Float:tmpOffset;
	if(CPowner[cp]!=-1)tmpOffset = 4.5;

	CPflag[cp]	= CreateDynamicSphere(x, y, z, 10.0, DEATHMATCH_WORLD);
	PlayerLoop(i) CPbar[i][cp] = CreatePlayerProgressBar(i, 50, 200, 60, 5, BLUE, REQ_CAPTURE_POINTS);

	CPlabel[cp][0] = CreateDynamic3DTextLabel("<COMMAND POST>", YELLOW, x, y, z, 1000.0, _, DEATHMATCH_WORLD);
	CPlabel[cp][1] = CreateDynamic3DTextLabel("<COMMAND POST>", YELLOW, x, y, z, 1000.0, _, DEATHMATCH_WORLD);

    CPicon[cp][0] = CreateDynamicMapIcon(x, y, z, 0, WHITE, DEATHMATCH_WORLD, .streamdistance = 1000.0);
    CPicon[cp][1] = CreateDynamicMapIcon(x, y, z, 0, WHITE, DEATHMATCH_WORLD, .streamdistance = 1000.0);

	CP_ObjPole[cp] = CreateDynamicObject(16101, x, y, z+CP_POLE_ZOFFSET, 0.0, 0.0, 0.0, DEATHMATCH_WORLD);
	CP_ObjFlag[cp][0][0] = CreateDynamicObject(2048, x+0.98, y, z+CP_POLE_ZOFFSET+CP_FLAG_ZOFFSET+tmpOffset, 0.0, 0.0, 0.0, DEATHMATCH_WORLD);
	CP_ObjFlag[cp][0][1] = CreateDynamicObject(2048, x+0.98, y, z+CP_POLE_ZOFFSET+CP_FLAG_ZOFFSET+tmpOffset, 0.0, 0.0, 180.0, DEATHMATCH_WORLD);
	CP_ObjFlag[cp][1][0] = CreateDynamicObject(2048, x+0.98, y, z+CP_POLE_ZOFFSET+CP_FLAG_ZOFFSET+tmpOffset, 0.0, 0.0, 0.0, DEATHMATCH_WORLD);
	CP_ObjFlag[cp][1][1] = CreateDynamicObject(2048, x+0.98, y, z+CP_POLE_ZOFFSET+CP_FLAG_ZOFFSET+tmpOffset, 0.0, 0.0, 180.0, DEATHMATCH_WORLD);

	if(CPowner[cp] == -1)
	{
		SetDynamicObjectMaterial(CP_ObjFlag[cp][0][0], 0, 18646, "matcolours", "white", 0);
		SetDynamicObjectMaterial(CP_ObjFlag[cp][0][1], 0, 18646, "matcolours", "white", 0);
		SetDynamicObjectMaterial(CP_ObjFlag[cp][1][0], 0, 18646, "matcolours", "white", 0);
		SetDynamicObjectMaterial(CP_ObjFlag[cp][1][1], 0, 18646, "matcolours", "white", 0);
	}
	else
	{
		SetDynamicObjectMaterial(CP_ObjFlag[cp][CPowner[cp]][0], 0, 18646, "matcolours", "blue", 0);
		SetDynamicObjectMaterial(CP_ObjFlag[cp][CPowner[cp]][1], 0, 18646, "matcolours", "blue", 0);
		SetDynamicObjectMaterial(CP_ObjFlag[cp][!CPowner[cp]][0], 0, 18646, "matcolours", "red", 0);
		SetDynamicObjectMaterial(CP_ObjFlag[cp][!CPowner[cp]][1], 0, 18646, "matcolours", "red", 0);
	}
}
MoveCPFlag(cp)
{
	MoveDynamicObject(CP_ObjFlag[cp][0][0], CPpoint[cp][0]+0.98, CPpoint[cp][1], CPpoint[cp][2]+CP_POLE_ZOFFSET+CP_FLAG_ZOFFSET+(CPfill[cp] * (4.5/REQ_CAPTURE_POINTS)), FLAG_MOVE_SPEED);
	MoveDynamicObject(CP_ObjFlag[cp][0][1], CPpoint[cp][0]+0.98, CPpoint[cp][1], CPpoint[cp][2]+CP_POLE_ZOFFSET+CP_FLAG_ZOFFSET+(CPfill[cp] * (4.5/REQ_CAPTURE_POINTS)), FLAG_MOVE_SPEED);
	MoveDynamicObject(CP_ObjFlag[cp][1][0], CPpoint[cp][0]+0.98, CPpoint[cp][1], CPpoint[cp][2]+CP_POLE_ZOFFSET+CP_FLAG_ZOFFSET+(CPfill[cp] * (4.5/REQ_CAPTURE_POINTS)), FLAG_MOVE_SPEED);
	MoveDynamicObject(CP_ObjFlag[cp][1][1], CPpoint[cp][0]+0.98, CPpoint[cp][1], CPpoint[cp][2]+CP_POLE_ZOFFSET+CP_FLAG_ZOFFSET+(CPfill[cp] * (4.5/REQ_CAPTURE_POINTS)), FLAG_MOVE_SPEED);
}


CP_CaptureUpdate(playerid, cp)
{
	new
		friendlyCaptureCount	= GetPlayersInTeamCapturing(pTeam(playerid), cp),
		enemyCaptureCount		= GetPlayersInTeamCapturing(pTeam(playerid), cp);

	if(enemyCaptureCount>friendlyCaptureCount)CPFlash[cp]=1;
	else
	{
	    CPFlash[cp]=-1;
		if(CPowner[cp] == -1)
		{			
			CPfill[cp] += (1*GetPlayersCapturing(cp));			
			MoveCPFlag(cp);
			PlayerLoop(i)
			{
				if(CapturingCP[i]==cp)
				{
					SetPlayerProgressBarColour(i, CPbar[i][cp], BLUE);
					SetPlayerProgressBarValue(i, CPbar[i][cp], CPfill[cp]);
				}
			}

			if(CPfill[cp]==REQ_CAPTURE_POINTS)
			{
				OnCPCapture(playerid, cp);
				CPtimer[cp]=false;
			}
		}
		if(CPowner[cp] == poTeam(playerid))
		{
			CPfill[cp] -= (1*GetPlayersCapturing(cp));
			MoveCPFlag(cp);
			PlayerLoop(i)
			{
				if(CapturingCP[i]==cp)
				{
					SetPlayerProgressBarColour(i, CPbar[i][cp], RED);
					SetPlayerProgressBarValue(i, CPbar[i][cp], CPfill[cp]);
				}
			}

			if(CPfill[cp]==0)
			{
			    OnCPLoss(playerid, cp);
			}
		}
		if(CPowner[cp] == pTeam(playerid))
		{
		    MsgF(playerid, YELLOW, "CP: "#C_ORANGE"%s"#C_YELLOW" Owned by your team", CPname[cp]);
			CPtimer[cp]=false;
		}
	}
	return 1;
}
OnCPLoss(playerid, cp)
{
	CPowner[cp]=-1;
	MsgTeamF(poTeam(playerid), BLUE, "We have lost %s", CPname[cp]);
	PlayerLoop(i)if(CapturingCP[i]==cp)GiveXP(i, 20, "Neutralized");
	SetCPTeam(cp, -1);
}
OnCPCapture(playerid, cp)
{
	MsgTeamF(pTeam(playerid), BLUE, "We Have Captured "#C_BLUE"%s!", CPname[cp]);
	MsgTeamF(poTeam(playerid), BLUE, "They Have Captured "#C_RED"%s!", CPname[cp]);
	HidePlayerProgressBar(playerid, CPbar[playerid][cp]);
	PlayerLoop(i)
	{
		if(CapturingCP[i]==cp)
		{
			CapturingCP[i] = -1;
			GiveXP(i, 20, "Capture");
			pStatCount[playerid][st_Obj][st_CqsCaps]++;
			AwardDataUpdate(playerid, .obj=1);
		}
	}
	SetCPTeam(cp, pTeam(playerid));
	CheckWinningState();
}

CheckWinningState()
{
	new TeamCPs[2];

	TeamCPs[0]=GetRavenCPs();
	TeamCPs[1]=GetValorCPs();

	for(new i;i<2;i++)
	{
		if(CQS_Leader == -1)
		{
			if(TeamCPs[i] == MAX_CP)
			{
			    CQS_Leader = i;
			    MatchTime(0, 20);
			    PlayerLoop(a)if(bPlayerGameSettings[a]&InDM)TextDrawShowForPlayer(a, MatchTimeCounter);
			}
		}
	}
	if(CQS_Leader != -1)
	{
		if(TeamCPs[CQS_Leader] < MAX_CP)
		{
			CQS_Leader = -1;
			StopMatchTime();
		}
	}
}
SetCPTeam(cp, team)
{
	CPowner[cp] = team;

	PlayerLoop(i)
		if(bPlayerGameSettings[i]&InDM)
			UpdateCPForPlayer(i, cp);

	return 1;
}

UpdateAllCPsForPlayer(playerid)
{
	for(new cp;cp<MAX_CP;cp++)
        UpdateCPForPlayer(playerid, cp);
}

UpdateCPForPlayer(playerid, cp)
{
	new
	    tmpCP_Name[MAX_CPNAME+22],
		team = pTeam(playerid);

	if(CPowner[cp]==team)
	{
		Streamer_SetIntData(STREAMER_TYPE_MAP_ICON, CPicon[cp][team], E_STREAMER_COLOR, BLUE);

		format(tmpCP_Name, (MAX_CPNAME+11), ">> "#C_BLUE"%s"#C_YELLOW" <<", CPname[cp]);
		UpdateDynamic3DTextLabelText(CPlabel[cp][team], YELLOW, tmpCP_Name);

		SetDynamicObjectMaterial(CP_ObjFlag[cp][team][0], 0, 18646, "matcolours", "blue", 0);
		SetDynamicObjectMaterial(CP_ObjFlag[cp][team][1], 0, 18646, "matcolours", "blue", 0);

		SetDynamicObjectMaterial(CP_ObjFlag[cp][!team][0], 0, 18646, "matcolours", "red", 0);
		SetDynamicObjectMaterial(CP_ObjFlag[cp][!team][1], 0, 18646, "matcolours", "red", 0);
	}
	if(CPowner[cp]!=team)
	{
		Streamer_SetIntData(STREAMER_TYPE_MAP_ICON, CPicon[cp][team], E_STREAMER_COLOR, RED);

		format(tmpCP_Name, (MAX_CPNAME+11), ">> "#C_RED"%s"#C_YELLOW" <<", CPname[cp]);
		UpdateDynamic3DTextLabelText(CPlabel[cp][team], YELLOW, tmpCP_Name);

		SetDynamicObjectMaterial(CP_ObjFlag[cp][!team][0], 0, 18646, "matcolours", "blue", 0);
		SetDynamicObjectMaterial(CP_ObjFlag[cp][!team][1], 0, 18646, "matcolours", "blue", 0);

		SetDynamicObjectMaterial(CP_ObjFlag[cp][team][0], 0, 18646, "matcolours", "red", 0);
		SetDynamicObjectMaterial(CP_ObjFlag[cp][team][1], 0, 18646, "matcolours", "red", 0);
	}
	if(CPowner[cp]==-1)
	{
		Streamer_SetIntData(STREAMER_TYPE_MAP_ICON, CPicon[cp][team], E_STREAMER_COLOR, WHITE);

		format(tmpCP_Name, (MAX_CPNAME+11), ">> "#C_WHITE"%s"#C_YELLOW" <<", CPname[cp]);
		UpdateDynamic3DTextLabelText(CPlabel[cp][0], YELLOW, tmpCP_Name);
		UpdateDynamic3DTextLabelText(CPlabel[cp][1], YELLOW, tmpCP_Name);

		SetDynamicObjectMaterial(CP_ObjFlag[cp][0][0], 0, 18646, "matcolours", "white", 0);
		SetDynamicObjectMaterial(CP_ObjFlag[cp][0][1], 0, 18646, "matcolours", "white", 0);

		SetDynamicObjectMaterial(CP_ObjFlag[cp][1][0], 0, 18646, "matcolours", "white", 0);
		SetDynamicObjectMaterial(CP_ObjFlag[cp][1][1], 0, 18646, "matcolours", "white", 0);
	}

	Streamer_AppendArrayData(STREAMER_TYPE_OBJECT, CP_ObjFlag[cp][pTeam(playerid)][0], E_STREAMER_PLAYER_ID, playerid);
	Streamer_AppendArrayData(STREAMER_TYPE_OBJECT, CP_ObjFlag[cp][pTeam(playerid)][1], E_STREAMER_PLAYER_ID, playerid);
	Streamer_RemoveArrayData(STREAMER_TYPE_OBJECT, CP_ObjFlag[cp][!pTeam(playerid)][0], E_STREAMER_PLAYER_ID, playerid);
	Streamer_RemoveArrayData(STREAMER_TYPE_OBJECT, CP_ObjFlag[cp][!pTeam(playerid)][1], E_STREAMER_PLAYER_ID, playerid);

	Streamer_AppendArrayData(STREAMER_TYPE_3D_TEXT_LABEL, CPlabel[cp][pTeam(playerid)], E_STREAMER_PLAYER_ID, playerid);
	Streamer_RemoveArrayData(STREAMER_TYPE_3D_TEXT_LABEL, CPlabel[cp][!pTeam(playerid)], E_STREAMER_PLAYER_ID, playerid);

	Streamer_AppendArrayData(STREAMER_TYPE_MAP_ICON, CPicon[cp][pTeam(playerid)], E_STREAMER_PLAYER_ID, playerid);
	Streamer_RemoveArrayData(STREAMER_TYPE_MAP_ICON, CPicon[cp][!pTeam(playerid)], E_STREAMER_PLAYER_ID, playerid);
}

/*


*/
