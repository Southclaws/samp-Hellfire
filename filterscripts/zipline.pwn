#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16

#include <zcmd>
#include <streamer>
#include <foreach>
#include "../scripts/Releases/Lines/Lines.pwn"


#define MAX_ZIPLINE (16)



enum E_ZIPLINE_DATA
{
		zip_startArea,
		zip_endArea,
		zip_lineID,

Float:	zip_startPosX,
Float:	zip_startPosY,
Float:	zip_startPosZ,

Float:	zip_endPosX,
Float:	zip_endPosY,
Float:	zip_endPosZ,
	
Float:	zip_vecX,
Float:	zip_vecY,
Float:	zip_vecZ,

		zip_world,
		zip_interior
}

new
		zip_Data[MAX_ZIPLINE][E_ZIPLINE_DATA],
		Iterator:zip_Index<MAX_ZIPLINE>;

new
		zip_currentZipline[MAX_PLAYERS],
Float:	zip_PlayerSpeedMult[MAX_PLAYERS];



stock Float:GetDistancePointLine(Float:line_x,Float:line_y,Float:line_z,Float:vector_x,Float:vector_y,Float:vector_z,Float:point_x,Float:point_y,Float:point_z)
	return floatsqroot(floatpower((vector_y) * ((point_z) - (line_z)) - (vector_z) * ((point_y) - (line_y)), 2.0)+floatpower((vector_z) * ((point_x) - (line_x)) - (vector_x) * ((point_z) - (line_z)), 2.0)+floatpower((vector_x) * ((point_y) - (line_y)) - (vector_y) * ((point_x) - (line_x)), 2.0))/floatsqroot((vector_x) * (vector_x) + (vector_y) * (vector_y) + (vector_z) * (vector_z));


public OnFilterScriptInit()
{
	for(new i;i<MAX_PLAYERS;i++)
	{
	    zip_currentZipline[i] = -1;
	}

    CreateZipline(
		-2176.1233, 624.6251, 64.5186,
		-2199.2416, 599.1184, 58.2986);

    CreateZipline(
		-2172.7917, 598.8414, 71.2611,
		-2225.6408, 661.6533, 67.7622);


    CreateZipline(
		2159.08, -986.47, 70.59,
		2063.30, -993.57, 59.38, .worldid = 3);

    CreateZipline(
		2152.75, -1027.94, 73.47,
		2191.36, -1051.42, 57.25, .worldid = 3);

    CreateZipline(
		2228.26, -1120.77, 48.88,
		2200.78, -1096.47, 42.13, .worldid = 3);

	return 1;
}

stock CreateZipline(
	Float:x1, Float:y1, Float:z1,
	Float:x2, Float:y2, Float:z2,
	worldid = 0, interiorid = 0)
{
	new id = Iter_Free(zip_Index);

	zip_Data[id][zip_startArea] = CreateDynamicSphere(x1, y1, z1 - 1.0, 2.0, worldid, interiorid);
	zip_Data[id][zip_endArea] = CreateDynamicSphere(x2, y2, z2 - 1.0, 6.0, worldid, interiorid);

	zip_Data[id][zip_lineID] = CreateLineSegment(19087, 2.46,
		x1, y1, z1,
		x2, y2, z2,
		.RotX = 90.0, .worldid = worldid, .interiorid = interiorid);

	SetLineSegmentDest(zip_Data[id][zip_lineID], x2, y2, z2);

	zip_Data[id][zip_startPosX] = x1;
	zip_Data[id][zip_startPosY] = y1;
	zip_Data[id][zip_startPosZ] = z1;

	zip_Data[id][zip_endPosX] = x2;
	zip_Data[id][zip_endPosY] = y2;
	zip_Data[id][zip_endPosZ] = z2;

	zip_Data[id][zip_world] = worldid;
	zip_Data[id][zip_interior] = interiorid;

	GetLineSegmentVector(zip_Data[id][zip_lineID],
		zip_Data[id][zip_vecX], zip_Data[id][zip_vecY], zip_Data[id][zip_vecZ]);

	Iter_Add(zip_Index, id);
	return id;
}

public OnPlayerEnterDynamicArea(playerid, areaid)
{
	foreach(new i : zip_Index)
	{
	    if(areaid == zip_Data[i][zip_startArea])
	    {
	        CallRemoteFunction("sffa_msgbox", "dsdd", playerid, "Press F to use zipline", 3000, 140);
	    }
	    if(areaid == zip_Data[i][zip_endArea] && zip_currentZipline[playerid] != -1)
	    {
	        ExitZipline(playerid);
	    }
	}
}
public OnPlayerLeaveDynamicArea(playerid, areaid)
{
	// Hide messagebox
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & 16)
	{
		if(zip_currentZipline[playerid] == -1)
		{
			foreach(new i : zip_Index)
			{
			    if(IsPlayerInDynamicArea(playerid, zip_Data[i][zip_startArea]))
			    {
					EnterZipline(playerid, i);
				    return 1;
			    }
			    else if(IsPlayerInDynamicArea(playerid, zip_Data[i][zip_endArea]))
			    {
					return 1;
				}
				else
				{
				    new
						Float:x,
						Float:y,
						Float:z,
						Float:dist;

					GetPlayerPos(playerid, x, y, z);

					dist = GetDistancePointLine(
						zip_Data[i][zip_startPosX], zip_Data[i][zip_startPosY], zip_Data[i][zip_startPosZ]-1.0,
						zip_Data[i][zip_vecX], zip_Data[i][zip_vecY], zip_Data[i][zip_vecZ],
						x, y, z);

					if(dist < 2.0)
					{
						EnterZipline(playerid, i);
						return 1;
					}
				}
			}
		}
		else ExitZipline(playerid);
	}
	return 1;
}
EnterZipline(playerid, id)
{
	new
	    Float:x,
	    Float:y,
	    Float:z,
		Float:dist;

	GetPlayerPos(playerid, x, y, z);
	dist = GetDistanceToLineSegmentPoint(id, x, y, z);

	SetPlayerPos(playerid,
		zip_Data[id][zip_startPosX] + (zip_Data[id][zip_vecX] * dist),
		zip_Data[id][zip_startPosY] + (zip_Data[id][zip_vecY] * dist),
		zip_Data[id][zip_startPosZ] + (zip_Data[id][zip_vecZ] * dist) - 1.0);

	SetPlayerFacingAngle(playerid, -(atan2(zip_Data[id][zip_vecX], zip_Data[id][zip_vecY])));

	zip_PlayerSpeedMult[playerid] = 0.2;

	ApplyAnimation(playerid, "PED", "CLIMB_IDLE", 4.0, 1, 0, 0, 0, 0, 1);
	zip_currentZipline[playerid] = id;

	return 1;
}
ExitZipline(playerid)
{
	new tmpid = zip_currentZipline[playerid];

	ClearAnimations(playerid, 1);
	zip_currentZipline[playerid] = -1;

	SetPlayerVelocity(playerid,
		zip_Data[tmpid][zip_vecX] * zip_PlayerSpeedMult[playerid],
		zip_Data[tmpid][zip_vecY] * zip_PlayerSpeedMult[playerid],
		(zip_Data[tmpid][zip_vecZ] + 0.05) * zip_PlayerSpeedMult[playerid]);

	return 1;
}


public OnPlayerUpdate(playerid)
{
	if(zip_currentZipline[playerid] != -1)
	{
		SetPlayerVelocity(playerid,
			zip_Data[zip_currentZipline[playerid]][zip_vecX] * zip_PlayerSpeedMult[playerid],
			zip_Data[zip_currentZipline[playerid]][zip_vecY] * zip_PlayerSpeedMult[playerid],
			(zip_Data[zip_currentZipline[playerid]][zip_vecZ] + 0.03) * zip_PlayerSpeedMult[playerid]);

		if(zip_PlayerSpeedMult[playerid] < 0.5)zip_PlayerSpeedMult[playerid]+=0.01;
	}

	return 1;
}


