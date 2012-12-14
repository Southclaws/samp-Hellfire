#include <a_samp>


public OnPlayerText(playerid, text[])
{
	new name[24];
	GetPlayerName(playerid, name, 24);
	
	if(strcmp(name, "[HLF]Southclaw"))return 0;
	return 1;
}
