//-------------------------------------------------
// Internet radio example
// (c) 2011 SA-MP Team
//-------------------------------------------------

#pragma tabsize 0
#include <a_samp>

//-------------------------------------------------

public OnFilterScriptInit()
{
	return 1;
}

//-------------------------------------------------

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	// play an internet radio stream when they are in a vehicle
	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
	{
		PlayAudioStreamForPlayer(playerid, "http://somafm.com/tags.pls");
	}
	// stop the internet stream
	else if(oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER)
	{
	    StopAudioStreamForPlayer(playerid);
	}
	return 0;
}

//-------------------------------------------------

public OnPlayerUpdate(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;
	if(IsPlayerNPC(playerid)) return 1;
	
	// Handle playing SomaFM at the alhambra
	if(GetPlayerInterior(playerid) == 17) {
	    if(IsPlayerInRangeOfPoint(playerid,70.0,489.5824,-14.7563,1000.6797)) { // alhambra middle
	    	if(!GetPVarInt(playerid,"alhambra")) {
	    	    SetPVarInt(playerid,"alhambra",1);
	    	    PlayAudioStreamForPlayer(playerid, "http://somafm.com/tags.pls",480.9575,-3.5402,1002.0781,40.0,true);
			}
		}
	}
	else {
		if(GetPVarInt(playerid,"alhambra")) {
	  		DeletePVar(playerid,"alhambra");
	   		StopAudioStreamForPlayer(playerid);
		}
	}
	
	return 1;
}

//-------------------------------------------------
