#include <a_samp>
#include <YSI\y_va>
#include <YSI\y_timers>
#include <formatex>
#include "../scripts/System/PlayerFunctions.pwn"
#include "../scripts/System/MathFunctions.pwn"
#include <zcmd>
#include <streamer>
#include <sscanf>
#include <colours>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16


CMD:meobj(playerid, params[])
{
	new objectid, Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	objectid = CreateDynamicObject(19477, x, y, z, 0.0, 0.0, 0.0);
    SetObjectMaterialText(objectid, "[HLF]Southclaw", 0, OBJECT_MATERIAL_SIZE_512x256, "Arial Black", 72, 1, -13391309, 0, 1);
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

CMD:o(playerid, params[])
{
	new
		id = strval(params),
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	CreateDynamicObject(id, x, y, z, 0.0, 90.0, r);

	return 1;
}

CMD:carry(playerid, params[])
{
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
	return 1;
}

CMD:none(playerid, params[])
{
	SetPlayerSpecialAction(playerid, 0);
	return 1;
}

CMD:up(playerid, params[])
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);
	SetPlayerPos(playerid, x, y, z + strval(params));

	return 1;
}

CMD:gotopos(playerid, params[])
{
	new
		Float:x,
		Float:y,
		Float:z;

	sscanf(params, "fff", x, y, z);

	SetPlayerPos(playerid, x, y, z);

	return 1;
}

CMD:getanim(playerid, params[])
{
	new
		animidx = GetPlayerAnimationIndex(playerid),
		animlib[32],
		animname[32];

	GetAnimationName(animidx, animlib, 32, animname, 32);
	printf("IDX %d %s %s", animidx, animlib, animname);
	return 1;
}

CMD:hideall(playerid, params[])
{
	for(new i; i < 1024; i++)
	{
		PlayerTextDrawHide(playerid, PlayerText:i);
		TextDrawHideForPlayer(playerid, Text:i);
	}
	return 1;
}
