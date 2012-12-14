#define FILTERSCRIPT

#include <a_samp>
#include <streamer>
#include <ZCMD>
#include <YSI\y_timers>
#include "../scripts/System/MessageBox.pwn"


#define TRN_MAX_OBJ (5)


new
	objIndex[MAX_PLAYERS],
	tronobj[MAX_PLAYERS][TRN_MAX_OBJ];


public OnFilterScriptInit()
{
	repeat tronUpdate(0);
}

timer tronUpdate[500](playerid)
{
	new str[32];
	format(str, 32, "idx: %d", objIndex[playerid]);
	ShowMsgBox(playerid, str, 0, 140);

	if(IsPlayerInAnyVehicle(playerid))
	{
		new
			vehicleid = GetPlayerVehicleID(playerid),
			Float:x,
			Float:y,
			Float:z,
			Float:r;

		GetVehiclePos(vehicleid, x, y, z);
		GetVehicleZAngle(vehicleid, r);

		if(objIndex[playerid] < TRN_MAX_OBJ-1)
		{
			tronobj[playerid][objIndex[playerid]] = CreateDynamicObject(19477,
				x + (-1 * floatsin(-r, degrees)),
				y + (-1 * floatcos(-r, degrees)),
				z, 0.0, 0.0, r);

			SetDynamicObjectMaterial(tronobj[playerid][objIndex[playerid]], 0, 18646, "matcolours", "blue");

	        objIndex[playerid]++;
        }
        else
        {
			DestroyDynamicObject(tronobj[playerid][objIndex[playerid]]);
			objIndex[playerid]--;
        }
	}
}

