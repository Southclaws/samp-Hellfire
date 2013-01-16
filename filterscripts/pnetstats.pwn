//
// Admin player netstats display
//

#include <a_samp>
#include "../include/gl_common.inc"

#define ADMINFS_MESSAGE_COLOR 0xFF444499
#define ADMIN_NETSTATS_DIALOGID 12898

new gNetStatsPlayerId = INVALID_PLAYER_ID;
new gNetStatsDisplayId = INVALID_PLAYER_ID;

new gNetStatsTimerId = 0;

forward NetStatsDisplay();

//------------------------------------------------

public OnFilterScriptInit()
{
	print("\n--Admin Netstats FS loaded.\n");
	return 1;
}

//------------------------------------------------

public NetStatsDisplay()
{
	new netstats_str[2048+1];
	GetPlayerNetworkStats(gNetStatsDisplayId, netstats_str, 2048);
	ShowPlayerDialog(gNetStatsPlayerId, ADMIN_NETSTATS_DIALOGID, DIALOG_STYLE_MSGBOX, "Player NetStats", netstats_str, "Ok", "");
}

//------------------------------------------------

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(!IsPlayerAdmin(playerid)) return 0; // this is an admin only script

	if(dialogid == ADMIN_NETSTATS_DIALOGID) {
		KillTimer(gNetStatsTimerId);
		gNetStatsPlayerId = INVALID_PLAYER_ID;
		return 1;
	}
	
	return  0;
}

//------------------------------------------------

public OnPlayerCommandText(playerid, cmdtext[])
{
	new cmd[256+1];
	new	idx;

	if(!IsPlayerAdmin(playerid)) return 0;
	
	cmd = strtok(cmdtext, idx);
	
    // netstats command
	if(strcmp("/pnetstats", cmd, true) == 0)
	{
	    new tmp[128];
		tmp = strtok(cmdtext, idx);
		if(!strlen(tmp)) { return 1; }
		 
	    gNetStatsPlayerId = playerid;
	    gNetStatsDisplayId = strval(tmp);
	    
	    NetStatsDisplay();
	    gNetStatsTimerId = SetTimer("NetStatsDisplay", 3000, true); // this will refresh the display every 3 seconds
	    return 1;
	}
	
	return 0;
}
//------------------------------------------------
