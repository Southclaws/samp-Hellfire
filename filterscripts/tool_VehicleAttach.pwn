/*
///////////////////////////////////////////////////////////////////////////////////

                      • Insanity Vehicle Attachment Editor •

- Description

  It allows you to edit the offsets of any object to attach in any vehicle, 
  the functions will be saved in the file scriptfiles/editions.pwn.

- Author

  Allan Jader (CyNiC)


- Note

  You can change how much you want the filterscript, leaving the credit to creator.

////////////////////////////////////////////////////////////////////////////////////
*/


#include "a_samp"

#define CBLUE 0x4E76B1FF
#define CRED  0xF40B74FF

enum playerSets
{
	Float:OffSetX,
	Float:OffSetY,
	Float:OffSetZ,
	Float:OffSetRX,
	Float:OffSetRY,
	Float:OffSetRZ,
	obj,
	EditStatus,
	lr,
	vehicleid,
	objmodel,
	timer
}

new Float:player[MAX_PLAYERS][playerSets];

const FloatX =  1;
const FloatY =  2;
const FloatZ =  3;
const FloatRX = 4;
const FloatRY = 5;
const FloatRZ = 6;

public OnPlayerConnect(playerid)
{
	player[playerid][timer] = -1;
	player[playerid][obj] =  -1;
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	new cmd[128], tmp[128], idx;
	cmd = strtok(cmdtext, idx);
	
	if(!strcmp("/edit", cmd, true))
	{
	    tmp = strtok(cmdtext, idx);
		if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, CBLUE, "((ERROR)) You are not in any vehicle.");
	    if(!strlen(tmp)) return SendClientMessage(playerid, CBLUE, "((ERROR)) Use: /edit [objectid]");
	    if(player[playerid][timer] != -1) KillTimer(player[playerid][timer]);
	    if(IsValidObject(player[playerid][obj])) DestroyObject(player[playerid][obj]);
		
	    new Obj = CreateObject(strval(tmp), 0.0, 0.0, -10.0, -50.0, 0, 0, 0);
	    new vId = GetPlayerVehicleID(playerid);
	    AttachObjectToVehicle(Obj, vId, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
	    player[playerid][timer] = SetTimerEx("GetKeys", true, true, "i", playerid);
	    player[playerid][EditStatus] = FloatX;
	    player[playerid][obj] = Obj;
	    player[playerid][vehicleid] = vId;		
		player[playerid][objmodel] = strval(tmp);
		if(Obj != player[playerid][obj])
		{
			player[playerid][OffSetX]  = 0.0;
			player[playerid][OffSetY]  = 0.0;
			player[playerid][OffSetZ]  = 0.0;
			player[playerid][OffSetRX] = 0.0;
			player[playerid][OffSetRY] = 0.0;
			player[playerid][OffSetRZ] = 0.0;
		}	
		new str[100];
		format(str, 100, "| Editing the object %d. Use KEY_LEFT, KEY_RIGHT and KEY_FIRE to adjust the offset's |", strval(tmp));		
		SendClientMessage(playerid, CBLUE, str);
		SendClientMessage(playerid, CBLUE, "| Use {F40B74}/X{4E76B1} to adjust the offset X |");
		SendClientMessage(playerid, CBLUE, "| Use {F40B74}/Y{4E76B1} to adjust the offset Y |");
		SendClientMessage(playerid, CBLUE, "| Use {F40B74}/Z{4E76B1} to adjust the offset Z |");
		SendClientMessage(playerid, CBLUE, "| Use {F40B74}/RX{4E76B1} to adjust the offset RX |");
		SendClientMessage(playerid, CBLUE, "| Use {F40B74}/RY{4E76B1} to adjust the offset RY |");
		SendClientMessage(playerid, CBLUE, "| Use {F40B74}/RZ{4E76B1} to adjust the offset RZ |");
		SendClientMessage(playerid, CBLUE, "| Use {F40B74}/FREEZE{4E76B1} and {F40B74}/UNFREEZE{4E76B1} to freeze and unfreeze yourself |");
		SendClientMessage(playerid, CBLUE, "| Use {F40B74}/STOP{4E76B1} to stop the edition. |");
		SendClientMessage(playerid, CBLUE, "| Use {F40B74}/SAVEOBJ{4E76B1} to save the object to file \"editions.pwn\". |");		
	    return true;
	}
	if(!strcmp("/stop", cmd, true))
	{
	    KillTimer(player[playerid][timer]);
	    return SendClientMessage(playerid, CBLUE, "Edition stoped.");
	}
	if(!strcmp("/saveobj", cmd, true))
	{		
		tmp = strtok(cmdtext, idx);
	    new File: file = fopen("editions.pwn", io_append);
	    new str[200];
	    format(str, 200, "\r\nAttachObjectToVehicle(vehicleid, objectid, %f, %f, %f, %f, %f, %f); //Object Model: %d | %s", player[playerid][OffSetX], player[playerid][OffSetY], player[playerid][OffSetZ], player[playerid][OffSetRX], player[playerid][OffSetRY], player[playerid][OffSetRZ], player[playerid][objmodel], tmp);
	    fwrite(file, str);
	    fclose(file);
	    return SendClientMessage(playerid, CBLUE, "Edition saved to file \"editions.pwn\".");
	}	
	if(!strcmp("/x", cmd, true))
	{
	    player[playerid][EditStatus] = FloatX;
	    return SendClientMessage(playerid, CBLUE, "Editing Float X.");
	}
	if(!strcmp("/y", cmd, true))
	{
	    player[playerid][EditStatus] = FloatY;
	    return SendClientMessage(playerid, CBLUE, "Editing Float Y.");
	}
	if(!strcmp("/z", cmd, true))
	{
	    player[playerid][EditStatus] = FloatZ;
	    return SendClientMessage(playerid, CBLUE, "Editing Float Z.");
	}
	if(!strcmp("/rx", cmd, true))
	{
	    player[playerid][EditStatus] = FloatRX;
	    return SendClientMessage(playerid, CBLUE, "Editing Float RX.");
	}
	if(!strcmp("/ry", cmd, true))
	{
	    player[playerid][EditStatus] = FloatRY;
	    return SendClientMessage(playerid, CBLUE, "Editing Float RY.");
	}
	if(!strcmp("/rz", cmd, true))
	{
	    player[playerid][EditStatus] = FloatRZ;
	    return SendClientMessage(playerid, CBLUE, "Editing Float RZ.");
	}
	if(!strcmp("/freeze", cmd, true))
	{
        TogglePlayerControllable(playerid, false);
		SendClientMessage(playerid, CBLUE, "You're freezed, use /unfreeze to unfreeze yourself.");
		return 1;
	}
	if(!strcmp("/unfreeze", cmd, true))
	{
        TogglePlayerControllable(playerid, true);
		SendClientMessage(playerid, CBLUE, "You're unfreezed.");
		return 1;
	}
	return 0;
}



public OnFilterScriptInit()
{
	for(new i = 0; i < MAX_PLAYERS; ++i)
	{
		if(IsPlayerConnected(i))
		{
			player[i][timer] = -1;
			player[i][obj] =  -1;
		}
	}
    return true;
}

public OnFilterScriptExit()
{
	for(new i = 0; i < MAX_PLAYERS; ++i) DestroyObject(player[i][obj]);
	return 1;
}

forward GetKeys(playerid);
public GetKeys(playerid)
{
	new Keys, ud, gametext[36], Float: toAdd;
    GetPlayerKeys(playerid,Keys,ud,player[playerid][lr]);    
	switch(Keys)
	{
		case KEY_FIRE:   toAdd = 0.000500;		
		default:         toAdd = 0.005000;
	}	
    if(player[playerid][lr] == 128)
    {
        switch(player[playerid][EditStatus])
        {
            case FloatX:
            {
                player[playerid][OffSetX] = floatadd(player[playerid][OffSetX], toAdd);
                format(gametext, 36, "offsetx: ~w~%f", player[playerid][OffSetX]);
				GameTextForPlayer(playerid, gametext, 1000, 3);
            }
            case FloatY:
            {
                player[playerid][OffSetY] = floatadd(player[playerid][OffSetY], toAdd);
                format(gametext, 36, "offsety: ~w~%f", player[playerid][OffSetY]);
				GameTextForPlayer(playerid, gametext, 1000, 3);
            }
            case FloatZ:
            {
                player[playerid][OffSetZ] = floatadd(player[playerid][OffSetZ], toAdd);
                format(gametext, 36, "offsetz: ~w~%f", player[playerid][OffSetZ]);
				GameTextForPlayer(playerid, gametext, 1000, 3);
            }
            case FloatRX:
            {
				if(Keys == 0) player[playerid][OffSetRX] = floatadd(player[playerid][OffSetRX], floatadd(toAdd, 1.000000));	
				else player[playerid][OffSetRX] = floatadd(player[playerid][OffSetRX], floatadd(toAdd,0.100000));					                			
                format(gametext, 36, "offsetrx: ~w~%f", player[playerid][OffSetRX]);
				GameTextForPlayer(playerid, gametext, 1000, 3);
            }
            case FloatRY:
            {
            	if(Keys == 0) player[playerid][OffSetRY] = floatadd(player[playerid][OffSetRY], floatadd(toAdd, 1.000000));	
				else player[playerid][OffSetRY] = floatadd(player[playerid][OffSetRY], floatadd(toAdd,0.100000));	
            	format(gametext, 36, "offsetry: ~w~%f", player[playerid][OffSetRY]);
				GameTextForPlayer(playerid, gametext, 1000, 3);
            }
            case FloatRZ:
            {
                if(Keys == 0) player[playerid][OffSetRZ] = floatadd(player[playerid][OffSetRZ], floatadd(toAdd, 1.000000));	
				else player[playerid][OffSetRZ] = floatadd(player[playerid][OffSetRZ], floatadd(toAdd,0.100000));	
                format(gametext, 36, "offsetrz: ~w~%f", player[playerid][OffSetRZ]);
				GameTextForPlayer(playerid, gametext, 1000, 3);
            }
		}
		AttachObjectToVehicle(player[playerid][obj], player[playerid][vehicleid], player[playerid][OffSetX], player[playerid][OffSetY], player[playerid][OffSetZ], player[playerid][OffSetRX], player[playerid][OffSetRY], player[playerid][OffSetRZ]);
	}
	else if(player[playerid][lr] == -128)
	{
	    switch(player[playerid][EditStatus])
        {
            case FloatX:
            {
                player[playerid][OffSetX] = floatsub(player[playerid][OffSetX], toAdd);
                format(gametext, 36, "offsetx: ~w~%f", player[playerid][OffSetX]);
				GameTextForPlayer(playerid, gametext, 1000, 3);
            }
            case FloatY:
            {
                player[playerid][OffSetY] = floatsub(player[playerid][OffSetY], toAdd);
                format(gametext, 36, "offsety: ~w~%f", player[playerid][OffSetY]);
				GameTextForPlayer(playerid, gametext, 1000, 3);
            }
            case FloatZ:
            {
                player[playerid][OffSetZ] = floatsub(player[playerid][OffSetZ], toAdd);
                format(gametext, 36, "offsetz: ~w~%f", player[playerid][OffSetZ]);
				GameTextForPlayer(playerid, gametext, 1000, 3);
            }
            case FloatRX:
            {
				if(Keys == 0) player[playerid][OffSetRX] = floatsub(player[playerid][OffSetRX], floatadd(toAdd, 1.000000));	
				else player[playerid][OffSetRX] = floatsub(player[playerid][OffSetRX], floatadd(toAdd,0.100000));			
                format(gametext, 36, "offsetrx: ~w~%f", player[playerid][OffSetRX]);
				GameTextForPlayer(playerid, gametext, 1000, 3);
            }
            case FloatRY:
            {
            	if(Keys == 0) player[playerid][OffSetRY] = floatsub(player[playerid][OffSetRY], floatadd(toAdd, 1.000000));	
				else player[playerid][OffSetRY] = floatsub(player[playerid][OffSetRY], floatadd(toAdd,0.100000));	
            	format(gametext, 36, "offsetry: ~w~%f", player[playerid][OffSetRY]);
				GameTextForPlayer(playerid, gametext, 1000, 3);
            }
            case FloatRZ:
            {
                if(Keys == 0) player[playerid][OffSetRZ] = floatsub(player[playerid][OffSetRZ], floatadd(toAdd, 1.000000));	
				else player[playerid][OffSetRZ] = floatsub(player[playerid][OffSetRZ], floatadd(toAdd,0.100000));	
                format(gametext, 36, "offsetrz: ~w~%f", player[playerid][OffSetRZ]);
				GameTextForPlayer(playerid, gametext, 1000, 3);
            }
		}
		AttachObjectToVehicle(player[playerid][obj], player[playerid][vehicleid], player[playerid][OffSetX], player[playerid][OffSetY], player[playerid][OffSetZ], player[playerid][OffSetRX], player[playerid][OffSetRY], player[playerid][OffSetRZ]);
	}
    return 1;
}


strtok(const string[], &index)
{
	new length = strlen(string);
	while ((index < length) && (string[index] <= ' '))
	{
		index++;
	}

	new offset = index;
	new result[20];
	while ((index < length) && (string[index] > ' ') && ((index - offset) < (sizeof(result) - 1)))
	{
		result[index - offset] = string[index];
		index++;
	}
	result[index - offset] = EOS;
	return result;
}
