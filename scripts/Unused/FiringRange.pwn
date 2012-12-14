#define MAX_TARGET			30
#define MAX_TARGET_TYPE		2

#define TARGET_MODEL_1	19315
#define TARGET_MODEL_2	2908

#define TargetLoop(%1) for(new %1;%1<MAX_TARGET;%1++)

forward FiringRange_Update();

new
    iFiringRange_Timer,
	tick_TimesCalled;

enum TARGET_TYPE_ENUM
{
	targetmodel,
	maxhitpoints,
	Float:hitboxSize,
	Float:fAngleOffsetX,
	Float:fAngleOffsetY,
	Float:fAngleOffsetZ
}
new aTargetInfo[MAX_TARGET_TYPE][TARGET_TYPE_ENUM]=
{
	{TARGET_MODEL_1,	5,	1.0, 0.000, 0.00, 90.0},
	{TARGET_MODEL_2,	8,	0.8, 270.0, 90.0, 0.000}
};

enum TARGET_DATA_ENUM
{
	target_objectid,
	target_type,
	targetplayer,
	hitpoints,
	Float:xpos,
	Float:ypos,
	Float:zpos
}
new
	aTargetData[MAX_TARGET][TARGET_DATA_ENUM],
	TargetID_Used[MAX_TARGET];


CreateTarget(Float:x, Float:y, Float:z, Float:r, targettype)
{
	new id;
	while(TargetID_Used[id])id++;

	aTargetData[id][target_objectid]=CreateObject(aTargetInfo[targettype][targetmodel], x, y, z, aTargetInfo[targettype][fAngleOffsetX], aTargetInfo[targettype][fAngleOffsetY], r);
	aTargetData[id][target_type]=targettype;
	aTargetData[id][xpos]=x;
	aTargetData[id][ypos]=y;
	aTargetData[id][zpos]=z;
	aTargetData[id][targetplayer]=GetClosestPlayerToPos(x, y, z);

	TargetID_Used[id]=1;
}
DestroyTarget(id)
{
	DestroyObject(aTargetData[id][target_objectid]);
	aTargetData[id][target_type]=0;
	aTargetData[id][xpos]=0.0;
	aTargetData[id][ypos]=0.0;
	aTargetData[id][zpos]=0.0;
	aTargetData[id][targetplayer]=0;
	TargetID_Used[id]=0;
}

new const Float:fTargetSpawns[5][3]=
{
	{-1546.064819, 2601.723388, 55.687500},
	{-1427.274536, 2602.571289, 55.687500},
	{-1429.020385, 2668.618408, 55.687500},
	{-1494.828247, 2671.186523, 55.687500},
	{-1545.859619, 2672.157226, 55.687500}
};


FiringRange_Init()
{
	iFiringRange_Timer = SetTimer("FiringRange_Update", 250, true);
	bitTrue(bServerGlobalSettings, TargetPractice);
	
	for(new t;t<MAX_TARGET;t++)
	{
		new
			iRandCell = random(sizeof fTargetSpawns),
			iType;
			
		if(RandomCondition(10))iType=0;
		else iType=1;
		CreateTarget(fTargetSpawns[iRandCell][0], fTargetSpawns[iRandCell][1], fTargetSpawns[iRandCell][2], random(360), iType);
	}
}
FiringRange_End()
{
	KillTimer(iFiringRange_Timer);
	bitFalse(bServerGlobalSettings, TargetPractice);
}


public FiringRange_Update()
{
	new
		Float:px, Float:py, Float:pz,
 		playerid,
		tmp_iTargetType,
		Float:fAngleToPlayer,
		Float:fDistanceToPlayer;

    TargetLoop(t)
    {
        playerid=aTargetData[t][targetplayer];
        tmp_iTargetType=aTargetData[t][target_type];
		GetPlayerPos(playerid, px, py, pz);
		GetObjectPos(aTargetData[t][target_objectid], aTargetData[t][xpos], aTargetData[t][ypos], aTargetData[t][zpos]);

		fAngleToPlayer=GetAngleToPoint(aTargetData[t][xpos], aTargetData[t][ypos], px, py);
		fDistanceToPlayer=Distance(px, py, pz, aTargetData[t][xpos], aTargetData[t][ypos], aTargetData[t][zpos]);

	    SetObjectRot(aTargetData[t][target_objectid], aTargetInfo[tmp_iTargetType][fAngleOffsetX], aTargetInfo[tmp_iTargetType][fAngleOffsetY], fAngleToPlayer+aTargetInfo[tmp_iTargetType][fAngleOffsetZ]);

		GetXYFromAngle(px, py, (fAngleToPlayer+180.0), 0.5);
	    MoveObject(aTargetData[t][target_objectid], px, py, aTargetData[t][zpos], 2.0, aTargetInfo[tmp_iTargetType][fAngleOffsetX], aTargetInfo[tmp_iTargetType][fAngleOffsetY], fAngleToPlayer+aTargetInfo[tmp_iTargetType][fAngleOffsetZ]);

		if(fDistanceToPlayer<=1.0&&bPlayerGameSettings[playerid]&Spawned)GivePlayerHealth(playerid, -10.0);
		if(tick_TimesCalled==5)
		{
			aTargetData[t][targetplayer]=GetClosestPlayerToPos(aTargetData[t][xpos], aTargetData[t][ypos], aTargetData[t][zpos]);
			tick_TimesCalled=0;
		}
		PlayerLoop(i)FireUpdate(i, t);
	}
	tick_TimesCalled++;
	
}

FireUpdate(playerid, targetid)
{
	new
		iWeaponState = GetPlayerWeaponState(playerid),
		tmp_iTargetType,
		k,
		ud,
		lr;


	if(GetPlayerWeapon(playerid) <= 21)return 0;
	if( (k&KEY_FIRE) && (iWeaponState!=WEAPONSTATE_RELOADING) && (iWeaponState!=WEAPONSTATE_NO_BULLETS) )
	{
		GetPlayerKeys(playerid, k, ud, lr);
		GetObjectPos(aTargetData[targetid][target_objectid], aTargetData[targetid][xpos], aTargetData[targetid][ypos], aTargetData[targetid][zpos]);
		tmp_iTargetType = aTargetData[targetid][target_type];
		if( IsPlayerAimingAt(playerid, aTargetData[targetid][xpos], aTargetData[targetid][ypos], aTargetData[targetid][zpos], aTargetInfo[tmp_iTargetType][hitboxSize]) )
	    {
			ShowHitMarker(playerid, GetPlayerWeapon(playerid));
			aTargetData[targetid][hitpoints]++;
			if(aTargetData[targetid][hitpoints] >= aTargetInfo[tmp_iTargetType][maxhitpoints])KillTarget(targetid, playerid);
	    }
	}
	return 1;
}

KillTarget(targetid, playerid)
{
	MsgAllF(YELLOW, "%p Killed a target! (%d)", playerid, targetid);
	DestroyTarget(targetid);
}

GetClosestPlayerToPos(Float:x, Float:y, Float:z)
{
	new
		Float:tmp_distance1 = 99999.99,
		Float:tmp_distance2,
		tmp_targetplayer=-1,
		Float:tmp_player_x,
		Float:tmp_player_y,
		Float:tmp_player_z;

	PlayerLoop(i)
	{
	    GetPlayerPos(i, tmp_player_x, tmp_player_y, tmp_player_z);
		tmp_distance2 = Distance(x, y, z, tmp_player_x, tmp_player_y, tmp_player_z);
		if(tmp_distance2 < tmp_distance1 && tmp_distance2 != 10000.0)
		{
			tmp_distance1 = tmp_distance2;
			tmp_targetplayer = i;
		}
	}
	return tmp_targetplayer;
}







CMD:targetstop(playerid, params[])
{
    FiringRange_End();
    return 1;
}
CMD:targetinit(playerid, params[])
{
    FiringRange_Init();
    return 1;
}
CMD:target(playerid, params[])
{
    new Float:x, Float:y, Float:z, Float:r;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, r);
    GetXYFromAngle(x, y, r, 20.0);
    CreateTarget(x, y, z+0.7, r, random(3));
    return 1;
}



















#endinput

#define TARGET_MODEL_HEAD	2908
#define TARGET_MODEL_TORS	2907
#define TARGET_MODEL_ARM    2906
#define TARGET_MODEL_LEG    2905

enum OFFSET_DATA_ENUM
{
	HEAD,
	TORSO,
	R_ARM,
	L_ARM,
	R_LEG,
	L_LEG
}
new Float:tOffsetData[OFFSET_DATA_ENUM][5]=
{
	{0.0000000, 0.0000000, 0.0000000,	270.000000, 90.000000},	//Head
	{-0.032227, -0.045897, -0.544213,	270.000000, 0.0000000},	//Torso

	{-0.218995, 0.2009280, -0.253135,	0.000000, 180.0000000},	//RightArm
	{0.1879870, 0.1584480, -0.265793,	0.000000, 0.000000000},	//LeftArm

	{-0.115479, -0.023924, -1.280131,	-90.000000, 90.000000},	//RightLeg
	{0.1010740, -0.012694, -1.288253,	270.000000, 90.000000}	//LeftLeg
};

CreateTarget(Float:x, Float:y, Float:z, Float:r)
{
	new
		Float:tmpX = x,
		Float:tmpY = y,
		Float:tmpZ = z;


	CreateObject(TARGET_MODEL_HEAD, x, y, z, tOffsetData[HEAD][3], tOffsetData[HEAD][4], r);

	tmpZ = z + tOffsetData[TORSO][2];
	CreateObject(TARGET_MODEL_TORS,  tmpX, tmpY, tmpZ,  tOffsetData[TORSO][3], tOffsetData[TORSO][4], r);


	tmpX=x+(0.25*floatsin((-45.0+r), degrees));
	tmpY=y+(0.25*floatcos((-45.0+r), degrees));
	tmpZ = z + tOffsetData[R_ARM][2];
	CreateObject(TARGET_MODEL_ARM,  tmpX, tmpY, tmpZ,  tOffsetData[R_ARM][3], tOffsetData[R_ARM][4], r);

	tmpX=x+(0.25*floatsin((-315.0+r), degrees));
	tmpY=y+(0.25*floatcos((-315.0+r), degrees));
	tmpZ = z + tOffsetData[L_ARM][2];
	CreateObject(TARGET_MODEL_ARM,  tmpX, tmpY, tmpZ,  tOffsetData[L_ARM][3], tOffsetData[L_ARM][4], r);


	tmpX=x+(0.1*floatsin((-70.0+r), degrees));
	tmpY=y+(0.1*floatcos((-70.0+r), degrees));
	tmpZ = z + tOffsetData[R_LEG][2];
	CreateObject(TARGET_MODEL_LEG,  tmpX, tmpY, tmpZ,  tOffsetData[R_LEG][3], tOffsetData[R_LEG][4], r);

	tmpX=x+(0.1*floatsin((-290.0+r), degrees));
	tmpY=y+(0.1*floatcos((-290.0+r), degrees));
	tmpZ = z + tOffsetData[L_LEG][2];
	CreateObject(TARGET_MODEL_LEG,  tmpX, tmpY, tmpZ,  tOffsetData[L_LEG][3], tOffsetData[L_LEG][4], r);
}
/*
stock GetXYFromAngle(&Float:x, &Float:y, Float:a, Float:distance)
	x+=(distance*floatsin(-a,degrees)),y+=(distance*floatcos(-a,degrees));


stock Float:GetAngleToPoint(Float:fDestX, Float:fDestY, Float:fPointX, Float:fPointY)
	return atan2((fDestY - fPointY), (fDestX - fPointX)) + 270.0

*/
