#include <a_samp>
#include <zcmd>
#include <RNPC>
#include <YSI\y_timers>
#include "../scripts/System/MathFunctions.pwn"

new
		rnpcid,
Timer:	FollowTimer,
		NpcTarget = -1;


public OnFilterScriptInit()
{
	for(new i;i<MAX_PLAYERS;i++)if(IsPlayerNPC(i))Kick(i);

	rnpcid = ConnectRNPC("Bob");

	defer SpawnNPC(0);

	return 1;
}
timer SpawnNPC[2000](playerid)
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);
	SetSpawnInfo(rnpcid, 255, 287, x, y, z, 270.0, 0, 0, 0, 0, 0, 0);
	SpawnPlayer(rnpcid);
	SetPlayerPos(rnpcid, x, y, z);
	GivePlayerWeapon(rnpcid, 31, 4000);

	defer SetNPCToPlayer(playerid);

	return 1;
}
timer SetNPCToPlayer[1000](playerid)
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);

	SetPlayerPos(rnpcid, x, y, z);

	FollowTimer = repeat Follow(rnpcid, playerid);

	return 1;
}

CMD:follow(playerid, params[])
{
	FollowTimer = repeat Follow(rnpcid, playerid);

	return 1;
}
CMD:stop(playerid, params[])
{
	stop FollowTimer;

	return 1;
}
CMD:attack(playerid, params[])
{
	NpcTarget = strval(params);
	return 1;
}
CMD:hold(playerid, params[])
{
	RNPC_StopPlayback(rnpcid);
	NpcTarget = -1;
	return 1;
}
timer Follow[500](id, target)
{
	if(NpcTarget != -1)
	{
		new
			Float:ix,
			Float:iy,
			Float:iz,
			Float:tx,
			Float:ty,
			Float:tz;

		GetPlayerPos(id, ix, iy, iz);
		GetPlayerPos(NpcTarget, tx, ty, tz);

		RNPC_CreateBuild(id, PLAYER_RECORDING_TYPE_ONFOOT, 0);

		RNPC_SetWeaponID(32); // Set weapon
		RNPC_AddPause(500); // wait a bit
		RNPC_AddMovement(0.0, 0.0, 0.0, 20.0, 20.0, 0.0); // start moving
		RNPC_ConcatMovement(0.0, 20.0, 0.0);  // Continue walking
		RNPC_AddPause(200); // wait a bit again
		RNPC_SetKeys(128); // aim straight forward
		RNPC_AddPause(500);
		RNPC_SetKeys(128 + 4); // Start shooting straight forward
		RNPC_AddPause(500);
		for (new i = 0; i < 360; i+=20) {
		    // Makes the NPC rotate slowly
		    RNPC_SetAngleQuats(0.0, i, 0.0);
		    RNPC_AddPause(150);
		}
		RNPC_SetKeys(128); // stop shooting
		RNPC_AddPause(500);
		RNPC_SetKeys(0); // stop aiming
		RNPC_FinishBuild(); // end the build mode and finish the build
 
		RNPC_StartBuildPlayback(id, 0);

		stop FollowTimer;
	}
	else
	{
		new
			Float:x,
			Float:y,
			Float:z,
			Float:ang;

		GetPlayerPos(target, x, y, z);
		GetPlayerFacingAngle(target, ang);

		if(!IsPlayerInRangeOfPoint(id, 0.5, x + floatsin(ang+90, degrees), y + floatcos(ang+90, degrees), z))
			MoveRNPC(id, x + floatsin(ang+90, degrees), y + floatcos(ang+90, degrees), z, 0.006);
	}
}

