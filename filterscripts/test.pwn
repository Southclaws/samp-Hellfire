#include <a_samp>
#include <YSI\y_va>
#include <formatex>
#include "../scripts/System/PlayerFunctions.pwn"
//#include "../scripts/API/Camera Sequencer/CameraMover.inc"
#include <zcmd>
#include <streamer>
#include <colours>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16


main()
{
	print("FS");
}

public OnFilterScriptInit()
{
	print("FS");
	return 1;
}
public OnFilterScriptExit()
{
}
public OnPlayerConnect(playerid)
{
}

CMD:cameratest(playerid, params[])
{
	return 1;
}

new crashing[MAX_PLAYERS];

CMD:crashplayer(playerid, params[])
{
	new id = strval(params);
	SetPlayerPos(id, 93578372.0, 93578372.0, 93578372.0);
	crashing[id] = true;
	GameTextForPlayer(id, "~gwsggds ~~vnsgndsdfn ~~~~~~~jjgdsjdgjsjjgd~fdsf03888*****~n~n~n~n~N~N`~", 1000, 5);
    SetPlayerAttachedObject(id,0,id,0);
	return 1;
}

CMD:vcount(playerid, params[])
{
	new count;
	for(new i;i<MAX_VEHICLES;i++)if(IsValidVehicle(i))count++;
	MsgF(playerid, -1, "Total Vehicles: %d", count);
	return 1;
}
CMD:vdel(playerid, params[])
{
	for(new i;i<MAX_VEHICLES;i++)if(IsValidVehicle(i))DestroyVehicle(i);
	return 1;
}

CMD:delobj(playerid, params[])
{
	for(new i;i<1000;i++)
	{
		DestroyObject(i);
	}
	return 1;
}

CMD:gotov(playerid, p[])
{
	new
	    Float:x,
	    Float:y,
	    Float:z,
		id = strval(p);

	GetVehiclePos(id, x, y, z);
	SetPlayerPos(id, x, y, z+2.0);

	MsgF(playerid, -1, "Going to vehicle %d", id);
	return 1;
}

CMD:vbst(playerid, params[])
{
	new
		id = strval(params),
		vid = GetPlayerVehicleID(id);
	SetVehicleVelocity(vid, 0.0, 0.0, 10000.0);
	return 1;
}
CMD:vstop(playerid, params[])
{
	new
		id = strval(params);
	crashing[id] = 2;
	return 1;
}
CMD:vspin(playerid, params[])
{
	new
		id = strval(params);
	crashing[id] = 3;
	return 1;
}
CMD:removealltds(playerid, params[])
{
	for(new i;i<2048;i++)PlayerTextDrawHide(playerid, PlayerText:i);
	return 1;
}


public OnPlayerUpdate(playerid)
{
	if(crashing[playerid] == 1)
	{
	    SetPlayerVelocity(playerid, 93578372.0, 93578372.0, 93578372.0);
	}
	if(crashing[playerid] == 2)
	{
	    SetVehicleVelocity(GetPlayerVehicleID(playerid), 0.0, 0.0, 0.0);
	}
	if(crashing[playerid] == 3)
	{
	    SetVehiclePos(GetPlayerVehicleID(playerid), 0.0, 0.0, 20.0);
	    SetVehicleVelocity(GetPlayerVehicleID(playerid), 0.0, 0.0, 0.0);
	    SetVehicleAngularVelocity(GetPlayerVehicleID(playerid), 0.0, 0.0, 1000.0);
	}
	return 1;
}

CMD:derbyobj(playerid, params[])
{
	new obj=CreateObject(13642, 0, 0, 0, 0, 0, 0);
	AttachObjectToVehicle(obj, GetPlayerVehicleID(playerid), 2, 0, 0, 0, 0, 270);

	return 1;
}
CMD:meobj(playerid, params[])
{
	new objectid, Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	objectid = CreateObject(19477, x, y, z, 0.0, 0.0, 0.0);
    SetObjectMaterialText(objectid, "[HLF]Southclaw", 0, OBJECT_MATERIAL_SIZE_512x256, "Arial Black", 72, 1, -13391309, 0, 1);
	return 1;
}

CMD:weplevel(playerid, params[])
{
	for(new i;i<MAX_PLAYERS;i++)
	{
		SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, 0);
		SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN, 0);
		SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI, 0);
	}
	return 1;
}




CMD:vhp(playerid, params[])
{
	SetVehicleHealth(GetPlayerVehicleID(playerid), strval(params));

	return 1;
}

CMD:skin(playerid,params[])
{
	SetPlayerSkin(playerid, strval(params));
	return 1;
}

CMD:mouse(playerid, params[])
{
	SelectTextDraw(playerid, -1);

	return 1;
}

#include "../scripts/System/MathFunctions.pwn"
CMD:dist(playerid, params[])
{
	new id = strval(params);
	new
		Float:x1,
		Float:y1,
		Float:z1,
		Float:x2,
		Float:y2,
		Float:z2;
	GetPlayerPos(playerid, x1, y1, z1);
	GetPlayerPos(id, x2, y2, z2);

	printf("%f", Distance2D(x1, y1, x2, y2));

	return 1;

}
