#include <a_samp>
#include <sscanf2>
#define PLAYERS 10
#define YELLOW 0xFFFF00FF
#define msg(%0,%1,%2)		SendClientMessage(%0,%1,%2)
#define msgF(%0,%1,%2,%3)	do{new _str[128];format(_str,128,%2,%3);SendClientMessage(%0,%1,_str);}while(f)
#define cmd(%1) if((!strcmp(cmd,%1,true,strlen(%1)))&&(cmd[strlen(%1)+1]==EOS))
new f=false;
public OnPlayerCommandText(playerid, cmdtext[])
{
	new cmd[30], params[100];
	sscanf(cmdtext, "s[30]s[100]", cmd, params);
	cmd("/playerpos")
	{
	    new id, Float:x, Float:y, Float:z;
	    if(!sscanf(params, "dfff", id, x, y, z))SetPlayerPos(id, x, y, z);
	    else if(sscanf(params, "d", id))GetPlayerPos(playerid, x, y, z);
	    msgF(playerid, YELLOW, "pos: %f, %f, %f", x, y, z);
	}
	cmd("/playervelocity")
	{
	    new id, Float:x, Float:y, Float:z;
	    if(!sscanf(params, "dfff", id, x, y, z))SetPlayerVelocity(id, x, y, z);
	    else if(sscanf(params, "d", id))SetPlayerVelocity(playerid, x, y, z);
	    msgF(playerid, YELLOW, "velocity: %f, %f, %f", x, y, z);
	}
	cmd("/playeranim")
	{
	    new id, lib[30], anim[30], Float:speed, loop, lockx, locky, frz, time, sync;
	    if(!sscanf(params, "dssfdddddd", id, lib, anim, speed, loop, lockx, locky, frz, time, sync))ApplyAnimation(id, lib, anim, speed, loop, lockx, locky, frz, time, sync);
	    else msg(playerid, YELLOW, "use: id, lib, anim, speed, loop, lockx, locky, frz, time, sync");
	}
	return 0;
}
public OnFilterScriptInit()print("\n--------------------------------------\n"" Test CMDS loaded\n""--------------------------------------\n");
public OnFilterScriptExit()print("\n--------------------------------------\n"" Test CMDS unloaded\n""--------------------------------------\n");

stock test(id, Float:dist)
{
	new Float:x, Float:y, Float:z, Float:a, Float:x2, Float:y2;
	GetPlayerPos(id, x, y, z);
	GetPlayerPos(id, x2, y2, z);
	GetPlayerFacingAngle(id, a);

	GetXYFromAngle(x2, y2, a, dist);

	x2-=x,y2-=y;

	SetPlayerVelocity(id, x, y, z);
}

stock GetXYFromAngle(&Float:x, &Float:y, Float:a, Float:distance)x+=(distance*floatsin(-a,degrees)),y+=(distance*floatcos(-a,degrees));
