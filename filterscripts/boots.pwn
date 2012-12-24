#include <a_samp>
#include <zcmd>

new carstuff;

CMD:boots(playerid, params[])
{
	SetTimer("lols", 10000, true);
	return 1;
}

forward lols();
public lols()
{
	if(carstuff == 0)
	{
		carstuff = 1;
		for(new i; i < MAX_VEHICLES; i++)
			SetVehicleParamsEx(i, 1, 1, 0, 0, 1, 0, 0);
	}
	if(carstuff == 1)
	{
		carstuff = 0;
		for(new i; i < MAX_VEHICLES; i++)
			SetVehicleParamsEx(i, 1, 1, 0, 0, 0, 0, 0);
	}
}