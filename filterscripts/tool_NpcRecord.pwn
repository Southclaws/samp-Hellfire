//-------------------------------------------------
//
//  Recording player data for NPC playback +
//  some test regression commands.
//  Kye 2009
//
//-------------------------------------------------

#pragma tabsize 0

#include <a_samp>
#include <core>
#include <float>

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

new Text3D:textid;
new PlayerText3D:playertextid;

new recordingonfoot[MAX_PLAYERS];
new recordinginveh[MAX_PLAYERS];

//-------------------------------------------------
public OnPlayerCommandText(playerid, cmdtext[])
{
	new cmd[128];
	new idx;
	cmd = strtok(cmdtext, idx);
	
	
	// Start recording vehicle data (/vrecord recording_name[])
	// Find the recording_name[] file in /scriptfiles/
 	if(strcmp(cmd, "/vrecord", true) == 0) {
	    new tmp[512];
      	tmp = strtok(cmdtext, idx);
		if(!strlen(tmp)) {
			SendClientMessage(playerid,0xFF0000FF,"Usage: /vrecord {name}");
			return 1;
		}
		if(!IsPlayerInAnyVehicle(playerid)) {
            SendClientMessage(playerid,0xFF0000FF,"Recording: Get in a vehicle.");
			return 1;
		}
		StartRecordingPlayerData(playerid,PLAYER_RECORDING_TYPE_DRIVER,tmp);
		SendClientMessage(playerid,0xFF0000FF,"Recording: started.");
		return 1;
	}

	// Start recording onfoot data (/ofrecord recording_name[])
	// Find the recording_name[] file in /scriptfiles/
 	if(strcmp(cmd, "/ofrecord", true) == 0) {
	    new tmp[512];
      	tmp = strtok(cmdtext, idx);
		if(!strlen(tmp)) {
			SendClientMessage(playerid,0xFF0000FF,"Usage: /ofrecord {name}");
			return 1;
		}
 		if(IsPlayerInAnyVehicle(playerid)) {
            SendClientMessage(playerid,0xFF0000FF,"Recording: Leave the vehicle and reuse the command.");
			return 1;
		}
		StartRecordingPlayerData(playerid,PLAYER_RECORDING_TYPE_ONFOOT,tmp);
		SendClientMessage(playerid,0xFF0000FF,"Recording: started.");
		return 1;
	}
 	if(strcmp(cmd, "/record", true) == 0)
	 {
	    new tmp[512];
      	tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid,0xFF0000FF,"Usage: /vrecord {name}");
			return 1;
		}
		if(!IsPlayerInAnyVehicle(playerid))
		{
			StartRecordingPlayerData(playerid,PLAYER_RECORDING_TYPE_DRIVER,tmp);
			SendClientMessage(playerid,0xFF0000FF,"Recording Started In Vehicle.");
			recordinginveh[playerid] = 1;
			return 1;
		}
		else
		{
			StartRecordingPlayerData(playerid,PLAYER_RECORDING_TYPE_ONFOOT,tmp);
			SendClientMessage(playerid,0xFF0000FF,"Recording: started.");
			recordingonfoot[playerid] = 1;
		}
	}
	// Stop recording any data
	if(strcmp(cmd, "/stoprecord", true) == 0) {
		StopRecordingPlayerData(playerid);
		SendClientMessage(playerid,0xFF0000FF,"Recording: stopped.");
		recordinginveh[playerid] = 0;
		recordingonfoot[playerid] = 0;
		return 1;
	}
	
	if(strcmp(cmd, "/player2v", true) == 0)
	{
  		new tmp[256];
	  	new tmp2[256];
		tmp = strtok(cmdtext,idx);
		tmp2 = strtok(cmdtext,idx);
		PutPlayerInVehicle(strval(tmp),strval(tmp2),0);

	    return 1;
	}

	if(strcmp( cmd, "/vehicle", true ) == 0 )
	{
		new Float:X, Float:Y, Float:Z;
		new tmp[256];
		new created_vehicle_id;
		tmp = strtok( cmdtext, idx );

		GetPlayerPos( playerid, X, Y, Z );

		created_vehicle_id = CreateVehicle( strval(tmp), X+2, Y+2, Z, 0, 0, 0, -1 );

		new msg[256];
		format(msg,256,"Created vehicle: %d",created_vehicle_id);
		SendClientMessage(playerid,0xAAAAAAAA,msg);

		return 1;
	}

	if(strcmp( cmd, "/dvehicle", true ) == 0 )
	{
		new tmp[256];
		tmp = strtok( cmdtext, idx );

		DestroyVehicle( strval(tmp) );

		new msg[256];
		format(msg,256,"Destroyed vehicle: %d",strval(tmp));
		SendClientMessage(playerid,0xAAAAAAAA,msg);

		return 1;
	}

	if ( strcmp( cmd, "/goto", true ) == 0 )
	{
	    new tmp[256];

	    tmp = strtok( cmdtext, idx );

	    if ( !strlen( tmp ) ) { return 1; }

	    new Float:X, Float:Y, Float:Z;

	    if ( GetPlayerVehicleID( playerid ) )
	    {
		    GetPlayerPos( strval(tmp), X, Y, Z );
		    SetVehiclePos( GetPlayerVehicleID(playerid), X+2, Y+2, Z );
	    } else {
		    GetPlayerPos( strval(tmp), X, Y, Z );
		    SetPlayerPos( playerid, X+2, Y+2, Z );
	    }

	    return 1;
	}

	if ( strcmp( cmd, "/bring", true ) == 0 )
	{
	    new tmp[256];

	    tmp = strtok( cmdtext, idx );

	    if ( !strlen( tmp ) ) { return 1; }

	    new Float:X, Float:Y, Float:Z;

	    if ( GetPlayerVehicleID( strval(tmp) ) )
	    {
		    GetPlayerPos( playerid, X, Y, Z );
		    SetVehiclePos( GetPlayerVehicleID(strval(tmp)), X+2, Y+2, Z );
	    } else {
		    GetPlayerPos( playerid, X, Y, Z );
		    SetPlayerPos( strval(tmp), X+2, Y+2, Z );
	    }

	    return 1;
	}

	if (strcmp(cmd, "/me2v", true) == 0)
	{
	  	new tmp[256];
		tmp = strtok(cmdtext,idx);
		PutPlayerInVehicle(playerid,strval(tmp),0);
	    return 1;
	}

	if (strcmp(cmd, "/tpzero", true) == 0)
	{
	  	new vid = GetPlayerVehicleID(playerid);
	  	if(vid != INVALID_VEHICLE_ID) {
			SetVehiclePos(vid,0.0,0.0,10.0);
		}
	    return 1;
	}

	if(strcmp(cmd, "/myvw", true) == 0)
	{
        new tmp[256];
		tmp = strtok(cmdtext,idx);
		SetPlayerVirtualWorld(playerid,strval(tmp));
	    return 1;
	}

	if(strcmp( cmd, "/fight", true ) == 0)
	{
		new tmp[256];
		new name[128];
		
		tmp = strtok(cmdtext, idx);
		new style = strval(tmp);
		SetPlayerFightingStyle(playerid, style);
		GetPlayerName(playerid,name,128);
		format(tmp, 256, "(%s) fighting style changed to %d", name, style);
		SendClientMessageToAll(0x4499CCFF,tmp);
		return 1;
	}
	
	if(strcmp( cmd, "/myfacingangle", true ) == 0)
	{
	    new Float:angle;
	    new tmp[256];
	    GetPlayerFacingAngle(playerid,angle);
		format(tmp, 256, "Facing: %f",angle);
		SendClientMessage(playerid,0x4499CCFF,tmp);
		return 1;
	}
	
	if(strcmp(cmd, "/crime", true) == 0) {
	    new tmp[256];
	  	new tmp2[256];
		tmp = strtok(cmdtext,idx);
		tmp2 = strtok(cmdtext,idx);
		PlayCrimeReportForPlayer(playerid, strval(tmp), strval(tmp2));
		return 1;
	}
	
	if(strcmp(cmd, "/repairmycar", true) == 0) {
	    new vid = GetPlayerVehicleID(playerid);
	    if (vid) RepairVehicle(vid);
		return 1;
	}
	
    if(strcmp(cmd, "/bv", true) == 0)
	{
		new tmp[128], iCar, string[128];

		tmp = strtok(cmdtext, idx);

		if(strlen(tmp) == 0) return SendClientMessage(playerid, 0xFFFFFFFF, "DO: /bv [vehicleid]");

		iCar = strval(tmp);

		new File:file = fopen("badvehicles.txt",io_append);
		format(string,sizeof(string),"%d\r\n", iCar);
		fwrite(file,string);
		fclose(file);
		
		GetPlayerName(playerid,tmp,128);
		format(string, sizeof(string), "Veh ID %i marked as bad vehicle by %s", iCar, tmp);
		SendClientMessageToAll(0xFFFFFFFF, string);
		return 1;
	}
	
	if(strcmp(cmd, "/weapskill", true) == 0) {
	    new tmp[256];
	  	new tmp2[256];
		tmp = strtok(cmdtext,idx);
		tmp2 = strtok(cmdtext,idx);
		SetPlayerSkillLevel(playerid, strval(tmp), strval(tmp2));
		return 1;
	}
	
	if(strcmp(cmd, "/labelonvehicle", true) == 0) {
	    new vid = GetPlayerVehicleID(playerid);
	    textid = Create3DTextLabel("My Vehicle\nOwned by me\nNo Fuel\nRunning on vapour",0xEEEEEE50,0.0,0.0,0.0,15.0,0);
	    Attach3DTextLabelToVehicle(textid, vid, 0.0, -1.6, -0.35); // tail of the vehicle toward the ground
		return 1;
	}

	if(strcmp(cmd, "/labelonplayer", true) == 0) {
		new tmp[256];
		tmp = strtok(cmdtext,idx);
 		textid = Create3DTextLabel("Player Label",0xFFFFFFFF,0.0,0.0,0.0,40.0,0);
	    Attach3DTextLabelToPlayer(textid, strval(tmp), 0.0, 0.0, -0.4);
		return 1;
	}

    if(strcmp(cmd, "/dellabel", true) == 0) {
	    Delete3DTextLabel(textid);
		return 1;
	}
	
	if(strcmp(cmd, "/playerlabel", true) == 0) {
	    new Float:X, Float:Y, Float:Z;
	    GetPlayerPos( playerid, X, Y, Z );
	    playertextid = CreatePlayer3DTextLabel(playerid,"Hello\nI'm at your position",0x008080FF,X,Y,Z,40.0);
		return 1;
	}

	if(strcmp(cmd, "/playerlabelveh", true) == 0) {
	    new vid = GetPlayerVehicleID(playerid);
	    playertextid = CreatePlayer3DTextLabel(playerid,"im in ur vehicles",0x008080FF,0.0,-1.6,-0.35,20.0,INVALID_PLAYER_ID,vid);
		return 1;
	}
	
	if(strcmp(cmd, "/playerlabelpl", true) == 0) {
	    new tmp[256];
		tmp = strtok(cmdtext,idx);
	    playertextid = CreatePlayer3DTextLabel(playerid,"Hello Testing",0x008080FF,0.0,0.0,0.0,30.0,strval(tmp));
		return 1;
	}
	
    if(strcmp(cmd, "/delplayerlabel", true) == 0) {
	    DeletePlayer3DTextLabel(playerid, playertextid);
		return 1;
	}
	
	if(strcmp(cmd, "/updateplayerlabel", true) == 0) {
	    UpdatePlayer3DTextLabelText(playerid, playertextid, 0xFFFFFFFF, "");
		return 1;
	}

	if(!strcmp(cmd, "/record1"))
	{
		StartRecordingPlayerData(1,PLAYER_RECORDING_TYPE_ONFOOT,"att");
		StartRecordingPlayerData(2,PLAYER_RECORDING_TYPE_ONFOOT,"def");

	    return 1;
	}

	return 0;
}

//-------------------------------------------------
// EOF


