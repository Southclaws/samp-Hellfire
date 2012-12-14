#include <a_samp>
#undef MAX_PLAYERS
#define MAX_PLAYERS 16

#define MAX_SHOT 1000

enum SHOT_ENUM
{
	shotTick,
	Float:shotDamg
}


new
	shotArray[MAX_PLAYERS][MAX_SHOT][SHOT_ENUM],
	shotFirst[MAX_PLAYERS],
	shotInt[MAX_PLAYERS],
	shotWep[MAX_PLAYERS];


public OnFilterScriptInit()
{

}



public OnPlayerGiveDamage(playerid, damagedid, Float: amount, weaponid)
{
	new
		str[64];

	format(str, 64, "GIVEN %f DAMAGE TO %d", amount, damagedid);
	SendClientMessage(playerid, -1, str);

	if(shotFirst[playerid] == 0)shotFirst[playerid] = GetTickCount();

	shotArray[playerid][shotInt[playerid]][shotTick] = GetTickCount();

	shotArray[playerid][shotInt[playerid]][shotDamg] = amount;

    shotInt[playerid]++;
    
	shotWep[playerid] = weaponid;
}


public OnPlayerTakeDamage(playerid, issuerid, Float: amount, weaponid)
{
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if(!strcmp(cmdtext, "/results"))
	{
		new
			tmpStr[128],
			str[2048],
			aveStr[64],
			intAve,
			Float:AverageRoFPerMS,
			tmpInt;

	    for(new x=1;x<shotInt[playerid];x++)
	    {
	        tmpInt = shotArray[playerid][x][shotTick] - shotArray[playerid][x-1][shotTick];

	        format(tmpStr, 128, "{FFFF00}INT: %02d\n", tmpInt);
	        strcat(str, tmpStr);
	        intAve+=tmpInt;
	    }

	    AverageRoFPerMS = floatdiv(intAve, shotInt[playerid]-1);
	    format(aveStr, 64, "\n\nAverage: %f\nRate Of Fire: %f", AverageRoFPerMS, ((1000/AverageRoFPerMS)*60) );
	    strcat(str, aveStr);

	    ShowPlayerDialog(playerid, 1337, DIALOG_STYLE_MSGBOX, "Weapon Test Results", str, "close", "");


		new
			File:rFile = fopen("rofdata.txt", io_append),
			line[32];

		format(line, 32, ",\t%f},\t\t// %d\r\n", ((1000/AverageRoFPerMS)*60), shotWep[playerid]);
		fwrite(rFile, line);
		fclose(rFile);
		SendClientMessage(playerid, 0xFFFF00FF, "Saved to file!");
		SendClientMessage(playerid, -1, line);
		return 1;
	}
	if(!strcmp(cmdtext, "/resetdata"))
	{
	    shotInt[playerid] = 0;
	    shotFirst[playerid] = 0;
		return 1;
	}
	return 0;
}









