#define FILTERSCRIPT

#include <a_samp>
#include <ZCMD>
#include <foreach>
#include <streamer>
#include <YSI\y_timers>

#include "../scripts/API/Line/Line.pwn"


forward public CheckLineLength();


public OnFilterScriptInit()
{
	// 19087 - ROPE

	CreateLineSegment(19087, 2.46,
		0.0, 0.0, 3.0,
		5.0, 5.0, 3.0,
		90.0, 0.0, 0.0);
/*

	CreateLineSegment(19087, 2.46,
		10.0, 0.0, 3.0,
		10.0, 10.0, 3.0,
		90.0, 0.0, 0.0);

	CreateLineSegment(19087, 2.46,
		10.0, 10.0, 3.0,
		0.0, 5.0, 3.0,
		90.0, 0.0, 0.0);

	CreateLineSegment(19087, 2.46,
		0.0, 5.0, 3.0,
		10.0, 0.0, 3.0,
		90.0, 0.0, 0.0);
*/
	SetTimer("CheckLineLength", 100, true);
}

new
	player1 = 0,
	player2 = 1;

CMD:setplayer1(playerid, params[])
{
    player1 = strval(params);
	return 1;
}
CMD:setplayer2(playerid, params[])
{
    player2 = strval(params);
	return 1;
}

public OnPlayerUpdate(playerid)
{
	if(playerid == player1)
	{
		new
			Float:x,
			Float:y,
			Float:z;

		GetPlayerPos(playerid, x, y, z);
		SetLineSegmentDest(0, x, y, z);

	}
	if(playerid == player2)
	{
		new
			Float:x,
			Float:y,
			Float:z;

		GetPlayerPos(playerid, x, y, z);
		SetLineSegmentPoint(0, x, y, z);
	}
	return 1;
}

public CheckLineLength()
{
	if(GetLineLength(0) > 20.0)
	{
	    new
			Float:vx1,
			Float:vy1,
			Float:vz1,
			Float:vx2,
			Float:vy2,
			Float:vz2,
			Float:v1,
			Float:v2;

       	if(IsPlayerInAnyVehicle(player1))
       		GetVehicleVelocity(GetPlayerVehicleID(player1), vx1, vy1, vz1);
       	else
       		GetPlayerVelocity(player1, vx1, vy1, vz1);

       	v1 = floatsqroot( (vx1*vx1) + (vy1*vy1) + (vz1*vz1) );


       	if(IsPlayerInAnyVehicle(player2))
       		GetVehicleVelocity(GetPlayerVehicleID(player2), vx2, vy2, vz2);
       	else
       		GetPlayerVelocity(player2, vx2, vy2, vz2);

       	v2 = floatsqroot( (vx2*vx2) + (vy2*vy2) + (vz2*vz2) );


       	if(v1 > v2)
       	{
			if(IsPlayerInAnyVehicle(player2))
				SetVehicleVelocity(GetPlayerVehicleID(player2), vx1, vy1, vz1);

			else
				SetPlayerVelocity(player2, vx1, vy1, vz1);
       	}
       	else
       	{
			if(IsPlayerInAnyVehicle(player1))
				SetVehicleVelocity(GetPlayerVehicleID(player1), vx2, vy2, vz2);

			else
				SetPlayerVelocity(player1, vx2, vy2, vz2);
       	}
	}

	return 1;
}
