#define FILTERSCRIPT

#include <a_samp>
#include <ZCMD>

new area1, area2;

public OnFilterScriptInit()
{
    area1 = GangZoneCreate(
		-2977.858, 1693.292,
		852.4849, 2966.18);

	area2 = GangZoneCreate(
		-1179.465, 525.5044,
		852.4849, 1693.292);

    for(new i; i < MAX_PLAYERS; i++)
    {
		GangZoneShowForPlayer(i, area1, 0xFF000050);
		GangZoneShowForPlayer(i, area2, 0xFF0000);
	}
}

public OnFilterScriptExit()
{
    for(new i; i < MAX_PLAYERS; i++)
    {
		GangZoneHideForPlayer(i, area1);
		GangZoneHideForPlayer(i, area2);
    }
}
