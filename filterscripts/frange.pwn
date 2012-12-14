#include <a_samp>
#include <formatex>
#include <foreach>
#include <zcmd>


new FALSE = false;

#define MAX_TARGET			30
#define MAX_TARGET_TYPE		2
#define TARGET_MODEL_1		19315
#define TARGET_MODEL_2		2908

#define TargetLoop(%1)		for(new %1;%1<MAX_TARGET;%1++)
#define RandomCondition(%1)	(random(100)<(%1))
#define msgaF(%1,%2,%3)		do{new _str[128];format(_str,128,%2,%3);SendClientMessageToAll(%1,_str);}while(FALSE)

forward Float:Distance(Float:x1,Float:y1,Float:z1,Float:x2,Float:y2,Float:z2);
forward Float:GetAngleToPoint(Float:fPointX, Float:fPointY, Float:fDestX, Float:fDestY);
forward Float:GetDistancePointLine(Float:line_x,Float:line_y,Float:line_z,Float:vector_x,Float:vector_y,Float:vector_z,Float:point_x,Float:point_y,Float:point_z);

forward FiringRange_Update();

new
    iFiringRange_Timer,
	tick_TimesCalled,
	pShotTick[MAX_PLAYERS];

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

public OnFilterScriptInit()
{
}
public OnFilterScriptExit()
{
    FiringRange_End();
}


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
enum WepEnum
{
	WepName[30],
	WepModel,
	MagSize,
	GtaSlot,
	Float:MinDam,
	Float:MaxDam,
	Float:MinDis,
	Float:MaxDis,
	Float:FireRate,
	Float:MaxRange
}
new const WepData[47][WepEnum]=
{
	{"Fist",			000, 0, 	0,	0.5,	1.0,	0.0, 2.0,	0.0,	1.6}, 		// 0
	{"Knuckle Duster",	331, 0, 	0,	0.5,	1.0,	0.0, 2.0,	0.0,	1.6}, 		// 1
	{"Golf Club",		333, 0, 	1,	0.5,	1.0,	0.0, 2.0,	0.0,	1.6}, 		// 2
	{"Baton", 			334, 0, 	1,	0.5,	1.0,	0.0, 2.0,	0.0,	1.6}, 		// 3
	{"Knife",			335, 0, 	1,	30.0,	35.0,	0.0, 2.0,	0.0,	1.6}, 		// 4
	{"Baseball Bat",	336, 0, 	1,	0.5,	1.0,	0.0, 2.0,	0.0,	1.6}, 		// 5
	{"Spade",			337, 0, 	1,	0.5,	1.0,	0.0, 2.0,	0.0,	1.6}, 		// 6
	{"Pool Cue",		338, 0,		1,	0.5,	1.0,	0.0, 2.0,	0.0,	1.6}, 		// 7
	{"Sword",			339, 0, 	1,	0.5,	1.0,	0.0, 2.0,	0.0,	1.6}, 		// 8
	{"Chainsaw",		341, 0,		1,	0.5,	1.0,	0.0, 2.0,	0.0,	1.6}, 		// 9
	{"Dildo",			321, 0, 	10,	0.5,	1.0,	0.0, 2.0,	0.0,	1.6}, 		// 10
	{"Dildo",			322, 0, 	10,	0.5,	1.0,	0.0, 2.0,	0.0,	1.6}, 		// 11
	{"Dildo",			323, 0, 	10,	0.5,	1.0,	0.0, 2.0,	0.0,	1.6}, 		// 12
	{"Dildo",			324, 0, 	10,	0.5,	1.0,	0.0, 2.0,	0.0,	1.6}, 		// 13
	{"Flowers",			325, 0, 	10,	0.5,	1.0,	0.0, 2.0,	0.0,	1.6}, 		// 14
	{"Cane",			326, 0, 	10,	0.5,	1.0,	0.0, 2.0,	0.0,	1.6}, 		// 15
	{"Grenade",			342, 1, 	8,	50.0,	100.0,	0.0, 2.0,	0.0,	40.0}, 		// 16
	{"Teargas",			343, 1, 	8,	0.0,	0.0,	0.0, 2.0,	0.0,	40.0}, 		// 17
	{"Molotov",			344, 1, 	8,	1.0,	5.0,	0.0, 2.0,	0.0,	40.0}, 		// 18
	{"<null>",			000, 0, 	0,	0.0,	0.0,	0.0, 2.0,	0.0,	0.0}, 		// 19
	{"<null>",			000, 0, 	0,	0.0,	0.0,	0.0, 2.0,	0.0,	0.0}, 		// 20
	{"<null>",			000, 0, 	0,	0.0,	0.0,	0.0, 2.0,	0.0,	0.0}, 		// 21

	{"M9",				346, 17,	2,	15.0,	24.0,	10.0, 30.0,	164.83,	35.0},		// 22
	{"M9 SD",			347, 17,	2,	15.0,	24.0,	10.0, 30.0,	166.61,	35.0},		// 23
	{"Desert Eagle",	348, 7,		2,	20.0,	28.0,	12.0, 36.0,	82.54,	35.0},		// 24
	{"Shotgun",			349, 6,		3,	15.0,	36.0,	11.0, 35.0,	56.40,	40.0},		// 25
	{"Sawnoff",			350, 2,		3,	15.0,	30.0,	4.0, 24.0,	196.07,	35.0},		// 26
	{"Spas 12",			351, 7,		3,	16.0,	35.0,	14.0, 40.0,	179.10,	40.0},		// 27

	{"Mac 10",			352, 100,	4,	12.0,	20.0,	10.0, 36.0,	461.26,	35.0},		// 28
	{"MP5",				353, 30,	4,	12.0,	24.0,	9.0, 38.0,	554.98,	45.0},		// 29
	{"AK-47",			355, 30,	5,	20.0,	26.0,	11.0, 39.0,	474.47,	70.0},		// 30
	{"M4-A1",			356, 50,	5,	24.0,	30.0,	13.0, 46.0,	490.59,	90.0},		// 31
	{"Tec 9",			372, 100,	4,	10.0,	24.0,	10.0, 35.0,	447.48,	35.0},		// 32

	{"Rifle",			357, 5,		6,	60.0,	70.0,	30.0, 100.0,55.83,	100.0},		// 33
	{"Sniper",			358, 5,		6,	60.0,	80.0,	30.0, 100.0,55.67,	100.0},		// 34

	{"RPG-7",			359, 1,		7,	50.0,	100.0,	1.0, 30.0,	0.0,	55.0},		// 35
	{"Heatseek",		360, 1,		7,	50.0,	100.0,	1.0, 30.0,	0.0,	55.0},		// 36
	{"Flamer",			361, 100,	7,	1.0,	5.0,	1.0, 20.0,	2974.95,5.1},		// 37
	{"Chaingun",		362, 500,	7,	1.0,	10.0,	1.0, 60.0,	2571.42,75.0},		// 38

	{"C4",				363, 1,		8,	5.0,	20.0,	10.0, 50.0,	0.0,	40.0},		// 39
	{"Detonator",		364, 1,		40,	0.0,	0.0,	10.0, 50.0,	0.0,	25.0},		// 40
	{"Spray Paint",		365, 1,		9,	1.0,	5.0,	10.0, 50.0,	0.0,	6.1},		// 41
	{"Extinguisher",	366, 1,		9,	1.0,	5.0,	10.0, 50.0,	0.0,	10.1},		// 42
	{"Camera",			367, 1,		9,	0.0,	0.0,	10.0, 50.0,	0.0,	100.0},		// 43
	{"Night Vision",	000, 1,		11,	0.0,	0.0,	10.0, 50.0,	0.0,	100.0},		// 44
	{"Thermal Vision",	000, 1,		11,	0.0,	0.0,	10.0, 50.0,	0.0,	100.0},		// 45
	{"Parachute",		371, 1,		11,	0.0,	0.0,	10.0, 50.0,	0.0,	25.0}		// 46
};


FiringRange_Init()
{
	iFiringRange_Timer = SetTimer("FiringRange_Update", 100, true);

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
	for(new t;t<MAX_TARGET;t++)
	{
	    DestroyTarget(t);
	}
	KillTimer(iFiringRange_Timer);
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

		GetXYFromAngle(px, py, fAngleToPlayer, 0.8);
	    MoveObject(aTargetData[t][target_objectid], px, py, aTargetData[t][zpos], 2.0, aTargetInfo[tmp_iTargetType][fAngleOffsetX], aTargetInfo[tmp_iTargetType][fAngleOffsetY], fAngleToPlayer+aTargetInfo[tmp_iTargetType][fAngleOffsetZ]);

		if(fDistanceToPlayer<=1.0)CallRemoteFunction("GiveFRHP", "df", playerid, -10.0);
		if(tick_TimesCalled==5)
		{
			aTargetData[t][targetplayer]=GetClosestPlayerToPos(aTargetData[t][xpos], aTargetData[t][ypos], aTargetData[t][zpos]);
			tick_TimesCalled=0;
		}
	}
	tick_TimesCalled++;
}

public OnPlayerUpdate(playerid)
{
	new
		iWeaponState = GetPlayerWeaponState(playerid),
		iCurWep = GetPlayerWeapon(playerid),
		tmp_iTargetType,
		k,
		ud,
		lr;

	GetPlayerKeys(playerid, k, ud, lr);

	if(iCurWep <= 21)return 0;
	if(k & KEY_FIRE)
	{
		if( (iWeaponState!=WEAPONSTATE_RELOADING) && (iWeaponState!=WEAPONSTATE_NO_BULLETS) && (GetTickCount()-pShotTick[playerid])>floatround(WepData[iCurWep][FireRate]) )
		{
		    TargetLoop(targetid)
		    {
				GetObjectPos(aTargetData[targetid][target_objectid], aTargetData[targetid][xpos], aTargetData[targetid][ypos], aTargetData[targetid][zpos]);
				tmp_iTargetType = aTargetData[targetid][target_type];
				if( IsPlayerAimingAt(playerid, aTargetData[targetid][xpos], aTargetData[targetid][ypos], aTargetData[targetid][zpos], aTargetInfo[tmp_iTargetType][hitboxSize]) )
				{
					HitTarget(targetid, playerid);
					break;
				}
		    }
			pShotTick[playerid] = GetTickCount();
		}
	}
	return 1;
}

HitTarget(targetid, playerid)
{
	CallRemoteFunction("ShowHitMarker", "dd", playerid, GetPlayerWeapon(playerid));
	aTargetData[targetid][hitpoints]++;

	if(aTargetData[targetid][hitpoints] >= aTargetInfo[aTargetData[targetid][target_type]][maxhitpoints])
		KillTarget(targetid, playerid);

}
KillTarget(targetid, playerid)
{
	msgaF(0xFFFF00FF, "%P{FFFFFF} Killed a target! (%d)", playerid, targetid);
	DestroyTarget(targetid);
}

TrgWalkForward(trg)
{

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

	foreach(new i : Player)
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





stock Float:Distance(Float:x1,Float:y1,Float:z1,Float:x2,Float:y2,Float:z2)
	return floatsqroot((((x1-x2)*(x1-x2))+((y1-y2)*(y1-y2))+((z1-z2)*(z1-z2))));

stock Float:GetDistancePointLine(Float:line_x,Float:line_y,Float:line_z,Float:vector_x,Float:vector_y,Float:vector_z,Float:point_x,Float:point_y,Float:point_z)
	return floatsqroot(floatpower((vector_y) * ((point_z) - (line_z)) - (vector_z) * ((point_y) - (line_y)), 2.0)+floatpower((vector_z) * ((point_x) - (line_x)) - (vector_x) * ((point_z) - (line_z)), 2.0)+floatpower((vector_x) * ((point_y) - (line_y)) - (vector_y) * ((point_x) - (line_x)), 2.0))/floatsqroot((vector_x) * (vector_x) + (vector_y) * (vector_y) + (vector_z) * (vector_z));

stock Float:GetAngleToPoint(Float:fPointX, Float:fPointY, Float:fDestX, Float:fDestY)
	return 90-(atan2((fDestY - fPointY), (fDestX - fPointX)));

stock GetXYFromAngle(&Float:x, &Float:y, Float:a, Float:distance)
	x+=(distance*floatsin(-a,degrees)),y+=(distance*floatcos(-a,degrees));

stock GetXYZFromAngle(&Float:x, &Float:y, &Float:z, Float:angle, Float:elevation, Float:distance)
    x += ( distance*floatsin(angle,degrees)*floatcos(elevation,degrees) ),y += ( distance*floatcos(angle,degrees)*floatcos(elevation,degrees) ),z += ( distance*floatsin(elevation,degrees) );

stock GetPlayerCameraWeaponVector(playerid, &Float:vX, &Float:vY, &Float:vZ)
{
	static
		weapon;
	if(21 < (weapon = GetPlayerWeapon(playerid)) < 39)
	{
		GetPlayerCameraFrontVector(playerid, vX, vY, vZ);
		switch(weapon)
		{
			case WEAPON_SNIPER, WEAPON_ROCKETLAUNCHER, WEAPON_HEATSEEKER: {}
			case WEAPON_RIFLE:
			{
				AdjustVector(vX, vY, vZ, 0.016204, 0.009899, 0.047177);
			}
			case WEAPON_AK47, WEAPON_M4:
			{
				AdjustVector(vX, vY, vZ, 0.026461, 0.013070, 0.069079);
			}
			default:
			{
				AdjustVector(vX, vY, vZ, 0.043949, 0.015922, 0.103412);
			}
		}
		return true;
	}
	return false;
}
stock AdjustVector(& Float: vX, & Float: vY, & Float: vZ, Float: oX, Float: oY, const Float: oZ)
{
	static
		Float: Angle;
	Angle = -atan2(vX, vY);
	if(45.0 < Angle)
	{
		oX ^= oY;
		oY ^= oX;
		oX ^= oY;
		if(90.0 < Angle)
		{
			oX *= -1;
			if(135.0 < Angle)
			{
				oX *= -1;
				oX ^= oY;
				oY ^= oX;
				oX ^= oY;
				oX *= -1;
			}
		}
	}
	else if(Angle < 0.0)
	{
		oY *= -1;
		if(Angle < -45.0)
		{
			oX *= -1;
			oX ^= oY;
			oY ^= oX;
			oX ^= oY;
			oX *= -1;
			if(Angle < -90.0)
			{
				oX *= -1;
				if(Angle < -135.0)
				{
					oX ^= oY;
					oY ^= oX;
					oX ^= oY;
				}
			}
		}
	}
	vX += oX,
	vY += oY;
	vZ += oZ;
	return false;
}
stock IsPlayerAimingAt(playerid, Float:pX, Float:pY, Float:pZ, Float:radius)
{
	new
	    Float:cX, Float:cY, Float:cZ,
	    Float:vX, Float:vY, Float:vZ,
		Float:DistanceToLine;
	GetPlayerCameraPos(playerid, cX, cY, cZ);
	GetPlayerCameraWeaponVector(playerid, vX, vY, vZ);
	DistanceToLine=GetDistancePointLine(cX, cY, cZ, vX, vY, vZ, pX, pY, pZ);
	if(DistanceToLine<radius)return 1;
	return 0;
}










// OLD ZOMBZ:



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

