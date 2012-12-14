#include <a_samp>
#include <zcmd>

public OnFilterScriptInit()
{
	for(new i;i<MAX_PLAYERS;i++)if(IsPlayerNPC(i))Kick(i);
	ConnectNPC("Tester0", "1");
	ConnectNPC("Tester1", "1");
	ConnectNPC("Tester2", "1");
	ConnectNPC("Tester3", "1");
	ConnectNPC("Tester4", "1");
	ConnectNPC("Tester5", "1");
	ConnectNPC("Tester6", "1");
	ConnectNPC("Tester7", "1");
	ConnectNPC("Tester8", "1");
	ConnectNPC("Tester9", "1");
	for(new i;i<MAX_PLAYERS;i++)if(IsPlayerNPC(i))
	{
		SetSpawnInfo(i, 255, 287, 0.0 + i, 0.0, 3.0, 270.0, 0, 0, 0, 0, 0, 0);
		SpawnPlayer(i);
		SetPlayerPos(i, 0.0 + 3*i, 0.0, 3.0);
	}
	SetTimer("spawn", 1000, false);
}

forward spawn();
public spawn()
{
	for(new i;i<MAX_PLAYERS;i++)if(IsPlayerNPC(i))
	{
	    SetPlayerPos(i, 0.0 + 3*i, 0.0, 3.0);
	}
	return 1;
}


