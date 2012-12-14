#define FILTERSCRIPT

#include <a_samp>
#include <YSI\y_hooks>
#include <YSI\y_timers>
#include <streamer>
#include <zcmd>
#include <foreach>
#include "../scripts/System/Trajectory.pwn"
#include "../scripts/System/MathFunctions.pwn"
#include "../scripts/System/MessageBox.pwn"
#include "../scripts/Releases/Button/Button.pwn"

#include "../scripts/Releases/Turret/Turret.pwn"


public OnFilterScriptInit()
{
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

CMD:mtr(playerid, params[])
{
	CreateTurret(287.0, 2047.0, 17.5, 270.0, .type = 1);
	CreateTurret(335.0, 1843.0, 17.5, 270.0, .type = 1);
	CreateTurret(10.0, 1805.0, 17.40, 180.0, .type = 1);
	return 1;
}


