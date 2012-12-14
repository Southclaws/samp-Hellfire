#include <a_samp>
#undef MAX_PLAYERS
#define MAX_PLAYERS 16
#include <sscanf2>
#include <zcmd>


#define msg SendClientMessage

#define MAX_SPAWN (8)

#define MG_IDX_SMO "Sumo/index.ini"
#define MG_IDX_DBY "Derby/index.ini"

#define MG_DAT_SMO "Sumo/%s.dat"
#define MG_DAT_DBY "Derby/%s.dat"


new
	Float:spawns[MAX_PLAYERS][MAX_SPAWN][4],
	curidx[MAX_PLAYERS],
	mgtype[MAX_PLAYERS],
	gHeight[MAX_PLAYERS];

public OnFilterScriptInit()
{
	for(new i;i<MAX_PLAYERS;i++)
	{
	    gHeight[i] = 99999;
	}
}

CMD:setspawn(playerid, params[])
{
	if(curidx[playerid] == MAX_SPAWN)return msg(playerid, -1, "Max spawns reached");

	new vehicleid = GetPlayerVehicleID(playerid);
	if(!IsValidVehicle(vehicleid))return msg(playerid, -1, "You must be in a vehicle");

	GetVehiclePos(vehicleid, spawns[playerid][curidx[playerid]][0], spawns[playerid][curidx[playerid]][1], spawns[playerid][curidx[playerid]][2]);
	GetVehicleZAngle(vehicleid, spawns[playerid][curidx[playerid]][3]);

	if(spawns[playerid][curidx[playerid]][2]-20 < float(gHeight[playerid]))gHeight[playerid] = floatround(spawns[playerid][curidx[playerid]][2]-20);

	curidx[playerid]++;
	msg(playerid, -1, "Spawn saved!");

	return 1;
}
CMD:savemg(playerid, params[])
{
	if(strlen(params) < 4)
	{
		msg(playerid, -1, "Invalid length");
		return 1;
	}
	if(params[0] == 's')
	{
	    new
			name[32];

	    sscanf(params[2], "s[32]d", name, gHeight[playerid]);

	    mgtype[playerid] = 0;
	    SaveData(playerid, name);
	    
	    msg(playerid, -1, "Saved car sumo map");
	    return 1;
	}
	if(params[0] == 'd')
	{
	    mgtype[playerid] = 1;
	    SaveData(playerid, params[2]);

		msg(playerid, -1, "Saved derby map");
		return 1;
	}
	msg(playerid, -1, "Invalid params");
	return 1;
}

SaveData(playerid, name[])
{
	new
	    File:f,
	    file[128],
	    str[256];

	if(mgtype[playerid] == 0)
	{
		format(file, 128, MG_DAT_SMO, name);
		f=fopen(file, io_write);
		for(new i;i<curidx[playerid];i++)
		{
			format(str, 256, "%f, %f, %f, %f\r\n",
				spawns[playerid][i][0],
				spawns[playerid][i][1],
				spawns[playerid][i][2],
				spawns[playerid][i][3]);
			fwrite(f, str);
		}
		fclose(f);

		f=fopen(MG_IDX_SMO, io_append);
		format(str, 256, "%s=%d\r\n", name, gHeight[playerid]);
		fwrite(f, str);
		fclose(f);
	}
	if(mgtype[playerid] == 1)
	{
		format(file, 128, MG_DAT_DBY, name);
		f=fopen(file, io_write);
		for(new i;i<curidx[playerid];i++)
		{
			format(str, 256, "%f, %f, %f, %f\r\n",
				spawns[playerid][i][0],
				spawns[playerid][i][1],
				spawns[playerid][i][2],
				spawns[playerid][i][3]);
			fwrite(f, str);
		}
		fclose(f);

		f=fopen(MG_IDX_DBY, io_append);
		format(str, 256, "%s\r\n", name);
		fwrite(f, str);
		fclose(f);
	}
}

