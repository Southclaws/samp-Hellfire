#include <a_samp>


#define FileName "BulkSavedPositions.txt"


new
	PosSave[MAX_PLAYERS]=false,
	SaveRot[MAX_PLAYERS]=false;


public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print(" Southclaw's Position Saver!");
	print("--------------------------------------\n");
	return 1;
}


public OnPlayerCommandText(playerid, cmdtext[])
{
	if(!strcmp("/savepos", cmdtext))
	{
	    if(PosSave[playerid])
	    {
	        PosSave[playerid] = false;
	        SendClientMessage(playerid, 0xFFFF00AA, "Pos Saver Inactive");
	    }
	    else
	    {
	        PosSave[playerid] = true;
	        SendClientMessage(playerid, 0xFFFF00AA, "Pos Saver Active, use C and SPACE to save a position");
	    }
		return 1;
	}
	if(!strcmp("/saverot", cmdtext))
	{
	    if(SaveRot[playerid])
	    {
	        SaveRot[playerid] = false;
	        SendClientMessage(playerid, 0xFFFF00AA, "Not Saving Rotation");
	    }
	    else
	    {
	        SaveRot[playerid] = true;
	        SendClientMessage(playerid, 0xFFFF00AA, "Saving Rotation");
	    }
		return 1;
	}
	return 0;
}


public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(PosSave[playerid])if((newkeys & KEY_CROUCH) && (newkeys & KEY_SPRINT) && (!IsPlayerInAnyVehicle(playerid)) ) SavePosition(playerid);
	return 1;
}


SavePosition(playerid)
{
	new
		Float:x,
		Float:y,
		Float:z,
		Float:a,
		str[100];

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, a);

	if(SaveRot[playerid])
		format(str, 100, "%f, %f, %f, %f\r\n", x, y, z, a);

	else
		format(str, 100, "%f, %f, %f\r\n", x, y, z);

	new File:f;

	if(fexist(FileName))
		f = fopen(FileName, io_append);

	else
		f = fopen(FileName, io_write);

	fwrite(f, str);
	fclose(f);

	SendClientMessage(playerid, 0xFFFF00FF, "Position Saved");
}
