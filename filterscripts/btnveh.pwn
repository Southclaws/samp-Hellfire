#define FILTERSCRIPT

#include <a_samp>
#include <ZCMD>
#include <streamer>
#include <YSI\y_timers>
#include <YSI\y_hooks>
#include "../scripts/System/MessageBox.pwn"
#include <foreach>
#include "../scripts/System/MathFunctions.pwn"
#include "../scripts/SIF/Button.pwn"
#include "../scripts/SIF/Item.pwn"
#include "../scripts/SIF/Container.pwn"

public OnFilterScriptInit()
{

}

CMD:addbtn(playerid, params)
{
	new id = CreateButton(0.0, 0.0, 0.0, "IT WORKS!", 0, 0, 1.0, 1, "Boot");

	AttachButtonToVehicle(id, GetPlayerVehicleID(playerid), 180.0, 15.0);

	SendClientMessage(playerid, -1, "Button added!");

	return 1;
}

public OnButtonPress(playerid, buttonid)
{
	print("WORKS");
}