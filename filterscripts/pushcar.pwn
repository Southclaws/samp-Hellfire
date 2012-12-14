#include <a_samp>
#include <YSI\y_va>
#include <YSI\y_timers>
#include <formatex>
#include "../scripts/System/PlayerFunctions.pwn"
#include <zcmd>
#include <streamer>
#include <colours>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16

new
	tick_gPlayerHitCar[MAX_PLAYERS];


Float:GetAngleToPoint(Float:fPointX, Float:fPointY, Float:fDestX, Float:fDestY)
	return 90-(atan2((fDestY - fPointY), (fDestX - fPointX)));


public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_SPRINT)
	{
	    if(GetTickCount() - tick_gPlayerHitCar[playerid] < 3000)return 0;

		new
		    Float:px,
		    Float:py,
		    Float:vx,
		    Float:vy,
		    Float:z,
		    Float:angToPly,
			id = GetClosestVehicle(playerid);

		GetPlayerPos(playerid, px, py, z);
		GetVehiclePos(id, vx, vy, z);

	    angToPly = GetAngleToPoint(vx, vy, px, py);

		if(-40 < angToPly < 40)
		{
		    SetPlayerFacingAngle(playerid, angToPly-180.0);
		    defer ApplyForceToVehicle(playerid, id, 0);
			tick_gPlayerHitCar[playerid] = GetTickCount();
		}
		if(140 < angToPly < 220)
		{
		    SetPlayerFacingAngle(playerid, angToPly-180.0);
		    defer ApplyForceToVehicle(playerid, id, 1);
			tick_gPlayerHitCar[playerid] = GetTickCount();
		}
    }
	return 1;
}

public OnPlayerUpdate(playerid)
{
	new
	    Float:px,
	    Float:py,
	    Float:vx,
	    Float:vy,
	    Float:vr,
	    Float:z,
	    Float:ang,
		id = GetClosestVehicle(playerid);

	GetPlayerPos(playerid, px, py, z);
	GetVehiclePos(id, vx, vy, z);
	GetVehicleZAngle(id, vr);

    ang = GetAngleToPoint(vx, vy, px, py);
    if(ang<360.0)ang=360.0+ang;

	new str[32];
	format(str, 32, "%f", ang);
	CallRemoteFunction("sffa_msgbox", "dsdd", playerid, str, 0, 100);

}

timer ApplyForceToVehicle[1000](playerid, vehicleid, side)
{
	ApplyAnimation(playerid, "GANGS", "shake_cara", 4.0, 0, 0, 0, 0, 0);
	if(side)SetVehicleAngularVelocity(vehicleid, 0.08, 0.0, 0.0);
	else SetVehicleAngularVelocity(vehicleid, -0.08, 0.0, 0.0);
}

GetClosestVehicle(playerid)
{
    new x,Float:dis,Float:dis2,car;
    car = 0;
    dis = 99999.99;
    for ( x = 0; x < MAX_VEHICLES; x++ )
    {
        if(x != GetPlayerVehicleID(playerid))
        {
            dis2 = GetDistanceToVehicle(playerid, x);
            if(dis2 < dis && dis2 < 10.0)
            {
                dis = dis2;
                car = x;
            }
        }
    }
    return car;
}

forward Float:GetDistanceToVehicle(playerid, vehicleid);
Float:GetDistanceToVehicle(playerid, vehicleid)
{
    new Float:x1,Float:y1,Float:z1,Float:x2,Float:y2,Float:z2;
    GetPlayerPos(playerid,x1,y1,z1);
    GetVehiclePos(vehicleid,x2,y2,z2);
    return floatsqroot(floatpower(floatabs(floatsub(x2,x1)),2)+floatpower(floatabs(floatsub(y2,y1)),2)+floatpower(floatabs(floatsub(z2,z1)),2));
}
