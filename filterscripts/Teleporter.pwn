#define FILTERSCRIPT

#include <a_samp>
#include <ZCMD>
#include <foreach>
#include <streamer>
#include <YSI\y_timers>

#include "../scripts/Teleporter.pwn"

public OnFilterScriptInit()
{
	CreateTeleporter(1214.01, -1289.05, 13.54, 0, 4);
}