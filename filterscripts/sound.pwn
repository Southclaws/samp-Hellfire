#include <a_samp>
#include <zcmd>

CMD:sound(playerid, params[])
{
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	PlayerPlaySound(playerid, strval(params), x, y, z);

	return 1;
}