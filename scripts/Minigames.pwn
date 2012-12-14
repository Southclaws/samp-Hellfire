/*
	Minigame:
		An event with a start and an end, it will start when a
		player joins one and end when all the players leave it.
*/

#include "../scripts/Minigames/Parkour.pwn"
#include "../scripts/Minigames/dgw.pwn"
#include "../scripts/Minigames/sumo.pwn"
#include "../scripts/Minigames/derby.pwn"
#include "../scripts/Minigames/prd.pwn"
#include "../scripts/Minigames/gungame.pwn"
#include "../scripts/Minigames/collect.pwn"
#include "../scripts/Minigames/halo.pwn"

LoadMinigames()
{
	prk_LoadCourses();
	smo_LoadArenas();
	dby_LoadArenas();
	prd_LoadTracks();
	gun_LoadArenas();
	gun_LoadTextDraws();
	clt_LoadCourses();
}

stock JoinMinigame(playerid, id, msg)
{
	if(id == MINIGAME_PARKOUR)prk_Join(playerid, msg);
	else if(id == MINIGAME_FALLOUT)dgw_Join(playerid, msg);
	else if(id == MINIGAME_CARSUMO)smo_Join(playerid, msg);
	else if(id == MINIGAME_DESDRBY)dby_Join(playerid, msg);
	else if(id == MINIGAME_PRDRIVE)prd_Join(playerid, msg);
	else if(id == MINIGAME_GUNGAME)gun_Join(playerid, msg);
	else if(id == MINIGAME_COLLECT)clt_Join(playerid, msg);
	else if(id == MINIGAME_HALOPAR)hlo_Join(playerid, msg);
}

LeaveCurrentMinigame(playerid, msg)
{
	if(gCurrentMinigame[playerid] == MINIGAME_PARKOUR)prk_Leave(playerid, msg);
	else if(gCurrentMinigame[playerid] == MINIGAME_FALLOUT)dgw_Leave(playerid, msg);
	else if(gCurrentMinigame[playerid] == MINIGAME_CARSUMO)smo_Leave(playerid, msg);
	else if(gCurrentMinigame[playerid] == MINIGAME_DESDRBY)dby_Leave(playerid, msg);
	else if(gCurrentMinigame[playerid] == MINIGAME_PRDRIVE)prd_Leave(playerid, msg);
	else if(gCurrentMinigame[playerid] == MINIGAME_GUNGAME)gun_Leave(playerid, msg);
	else if(gCurrentMinigame[playerid] == MINIGAME_COLLECT)clt_Leave(playerid, msg);
	else if(gCurrentMinigame[playerid] == MINIGAME_HALOPAR)hlo_Leave(playerid, msg);
}

CMD:skip(playerid, params[])
{
	if(gCurrentMinigame[playerid] == MINIGAME_PARKOUR)
		prk_SkipIntroCam(playerid);

	if(gCurrentMinigame[playerid] == MINIGAME_PARKOUR)
		clt_SkipIntroCam(playerid);

	return 1;
}
CMD:skipalways(playerid, params[])
{
	if(gCurrentMinigame[playerid] == MINIGAME_PARKOUR)
	{
		prk_SkipIntroCam(playerid);
		t:bPlayerGameSettings[playerid]<prk_SkipIntro>;
	}

	if(gCurrentMinigame[playerid] == MINIGAME_PARKOUR)
	{
		clt_SkipIntroCam(playerid);
		t:bPlayerGameSettings[playerid]<clt_SkipIntro>;
	}

	return 1;
}
