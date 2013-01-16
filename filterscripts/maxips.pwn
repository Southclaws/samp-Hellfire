// maxips FS limits the number of players connecting from a
// single IP address.

#include <a_samp>

#define MAX_CONNECTIONS_FROM_IP     3

//---------------------------------------------

public OnFilterScriptInit()
{
	printf("\n*** Player IP limiting FS (maxips) Loaded. Max connections from 1 IP = %d\n",MAX_CONNECTIONS_FROM_IP);
}

//---------------------------------------------
// GetNumberOfPlayersOnThisIP
// Returns the number of players connecting from the
// provided IP address

stock GetNumberOfPlayersOnThisIP(test_ip[])
{
	new against_ip[32+1];
	new x = 0;
	new ip_count = 0;
	for(x=0; x<MAX_PLAYERS; x++) {
		if(IsPlayerConnected(x)) {
		    GetPlayerIp(x,against_ip,32);
		    if(!strcmp(against_ip,test_ip)) ip_count++;
		}
	}
	return ip_count;
}

//---------------------------------------------

public OnPlayerConnect(playerid)
{
	new connecting_ip[32+1];
	GetPlayerIp(playerid,connecting_ip,32);
	new num_players_on_ip = GetNumberOfPlayersOnThisIP(connecting_ip);
	
	if(num_players_on_ip > MAX_CONNECTIONS_FROM_IP) {
		printf("MAXIPs: Connecting player(%d) exceeded %d IP connections from %s.", playerid, MAX_CONNECTIONS_FROM_IP, connecting_ip);
	    Kick(playerid);
	    return 1;
	}

	return 0;
}
	
//---------------------------------------------
	    
