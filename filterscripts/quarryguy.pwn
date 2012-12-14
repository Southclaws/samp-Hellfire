#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16

#include <YSI\y_timers>
#include <foreach>
#include <formatex>
#include <zcmd>
#include <streamer>
#include <colours>
#include <RNPC>

#define BUSY_POSX 490.8514
#define BUSY_POSY 782.2376
#define BUSY_POSZ -22.0485
#define BUSY_POSR 206.2072

new
    gNpcId = 1,
	gArea,
	Timer:gAnimTimer;


public OnFilterScriptInit()
{

	gArea = CreateDynamicSphere(490.7892, 787.8530, -22.0698, 1.8, 0, 0);
	return 1;
}

public OnPlayerConnect(playerid)
{
}

CMD:connectnpc(playerid, params[])
{
	ConnectRNPC("Philip");
	return 1;
}

public OnPlayerSpawn(playerid)
{
	new name[24];

	GetPlayerName(playerid, name, 24);

	if(!strcmp(name, "Philip"))
	{
		gNpcId = playerid;

		SetPlayerSkin(playerid, 50);
		SetPlayerPos(playerid, BUSY_POSX, BUSY_POSY, BUSY_POSZ);
		SetPlayerFacingAngle(playerid, 185.2556);

		ApplyAnimation(gNpcId, "BOMBER", "BOM_Plant_Crouch_Out", 1.0, 0, 0, 0, 1, 0);
		gAnimTimer = defer animTimer(gNpcId, 1);
	}
}

public OnPlayerEnterDynamicArea(playerid, areaid)
{
	if(areaid == gArea)
	{
	    ClearAnimations(gNpcId);
	    MoveRNPC(gNpcId, 491.0726, 786.7578, -22.0643, 0.006);
	    stop gAnimTimer;
	}
}

public OnPlayerLeaveDynamicArea(playerid, areaid)
{
	if(areaid == gArea)
	{
	    ClearAnimations(gNpcId);
	    RNPC_StopPlayback(gNpcId);
	    MoveRNPC(gNpcId, BUSY_POSX, BUSY_POSY, BUSY_POSZ, 0.006);
	    defer ReturnNpc();
	}
}
timer ReturnNpc[2000]()
{
	SetPlayerPos(gNpcId, BUSY_POSX, BUSY_POSY, BUSY_POSZ);
	ApplyAnimation(gNpcId, "BOMBER", "BOM_Plant_Crouch_Out", 1.0, 0, 0, 0, 1, 0);
	defer animTimer(gNpcId, 1);
}

timer animTimer[2000](id, anim)
{
	if(anim)ApplyAnimation(id, "BOMBER", "BOM_Plant_Crouch_In", 1.0, 0, 0, 0, 1, 0);
	else ApplyAnimation(id, "BOMBER", "BOM_Plant_Crouch_Out", 1.0, 0, 0, 0, 1, 0);
	gAnimTimer = defer animTimer(id, !anim);
}


