#include <a_samp>
#include <sscanf2>

new ConvoyVehicle[5];

public OnFilterScriptInit()
{
	ConvoyVehicle[0]=CreateVehicle(470, -2179.398193, -2152.478759, 48.994297, 304.642913, -1, -1, 1000);
	ConvoyVehicle[1]=CreateVehicle(470, -2186.333251, -2157.456542, 47.582000, 306.366424, -1, -1, 1000);
	ConvoyVehicle[2]=CreateVehicle(433, -2194.882812, -2163.549316, 46.272315, 305.128845, -1, -1, 1000);
	ConvoyVehicle[3]=CreateVehicle(432, -2204.270019, -2170.071533, 43.906547, 304.006835, -1, -1, 1000);
	ConvoyVehicle[4]=CreateVehicle(470, -2213.376464, -2176.106689, 42.039813, 303.704681, -1, -1, 1000);


	ConnectNPC("V1_P", "V1_PATRIOT");
	print("\n\n============CONVOY LOADED============\n\n");

}
public OnPlayerSpawn(playerid)
{
    new pName[24];
    GetPlayerName(playerid, pName, 24);
    
    if(!strcmp(pName, "V1_P", true))
    {
        SetSpawnInfo(playerid, 0, 287, -2187.058837, -2148.730468, 48.693794, 15.0, 31, 4000, 0, 0, 0, 0 );
        SetPlayerPos(playerid, -2187.058837, -2148.730468, 48.693794);
        SetPlayerColor(playerid, 0xFFFFFFFF);
        SetPlayerSkin(playerid, 287);
    }
}

new
	SpeedBlock[MAX_PLAYERS],
	ShowSpeed[MAX_PLAYERS],
	Float:PlayerSpeed[MAX_PLAYERS];

public OnPlayerCommandText(playerid, cmdtext[])
{
	if(!strcmp(cmdtext, "/inveh"))
	{
		PutPlayerInVehicle(0, ConvoyVehicle[0], 0);
	    return 1;
	}
	
	if(!strcmp(cmdtext, "/speedblock"))
	{
	    SpeedBlock[playerid]=true;
	    return 1;
	}

	if(!strcmp(cmdtext, "/showspeed"))
	{
	    ShowSpeed[playerid]=true;
	    return 1;
	}
	
	if(!strcmp(cmdtext, "/starttimer"))
	{
	    SetTimerEx("SpeedUpdate", 100, true, "d", playerid);
	    return 1;
	}
	return 0;
}


stock Float:CalculateVelocity(Float:X, Float:Y, Float:Z)
	return (floatsqroot((X*X)+(Y*Y)+(Z*Z))*200);

forward SpeedUpdate(playerid);
public SpeedUpdate(playerid)
{
	new
		Float:vx,
		Float:vy,
		Float:vz,
		vehicleid = GetPlayerVehicleID(playerid);

	GetVehicleVelocity(vehicleid, vx, vy, vz);
    PlayerSpeed[playerid] = CalculateVelocity(vx, vy, vz);
    
	if(ShowSpeed[playerid])
	{
	    new str[32];
	    format(str, 32, "SPEED: %f", PlayerSpeed[playerid]);
	    GameTextForPlayer(playerid, str, 1000, 5);
	}
	if(SpeedBlock[playerid])
	{
	    if(PlayerSpeed[playerid] > 100.0)
	    {
			SetVehicleVelocity(vehicleid, vx*0.9, vy*0.9, vz);
	    }
	}
    
}





