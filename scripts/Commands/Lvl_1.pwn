#define LEVEL 1

stock const gAdminCommandList_Lvl1[] =
	{
		"/heal [id] - heal a player\n\
		/disarm [id] - take away player weapons\n\
		/dmkick [id] - kick a player from deathmatch\n\
		/(un)dmban [id] [reason] (minutes) - ban/unban a player from deathmatch\n\
		/racekick [id] - kick a player from the current race\n\
		/mgkick [id] - kick a player from a minigame\n\
		/count [seconds] (minutes) - start a countdown\n\
		/healall - heal all players\n\
		/msg [message] - send a chat message\n\
		/challenge - start a challenge\n\
		/stopchallenge - stop the challenge"
	};


//==========================================================================Player Control

ACMD:heal[1](playerid, params[])
{
	new id;

	if(sscanf(params, "d", id))
		return Msg(playerid, YELLOW, " >  Usage: /heal [playerid]");

	if(!IsPlayerConnected(id))
		return 4;

	if(!IsPlayerInFreeRoam(id))
		return 3;

	SetPlayerHP(id, 100.0);
	MsgF(id, YELLOW, " >  %P"#C_YELLOW" Has healed you", playerid);

	return 1;
}
ACMD:disarm[1](playerid, params[])
{
	new id;

	if(sscanf(params, "d", id))
		return Msg(playerid, YELLOW, " >  Usage: /disarm [playerid]");

	if(pAdmin(id) >= pAdmin(playerid) && playerid != id)
		return 3;

	if(!IsPlayerConnected(id))
		return 4;

	if(!IsPlayerInFreeRoam(id))
		return 3;

	ResetPlayerWeapons(id);
	MsgF(id, YELLOW, " >  %P"#C_YELLOW" Has disarmed you", playerid);
	MsgF(playerid, YELLOW, " >  You disarmed %P"#C_YELLOW"", id);

	return 1;
}
ACMD:dmkick[1](playerid, params[])
{
	new
		id,
		reason[128];

	if(sscanf(params, "dS[128](None)", id, reason))
		return Msg(playerid, YELLOW, " >  Usage: /dmkick [playerid] [reason]");

	if(pAdmin(id) >= pAdmin(playerid) && playerid != id)
		return 3;

	if(!IsPlayerConnected(id))
		return 4;

	if(!(bPlayerGameSettings[id] & InDM))
		return Msg(playerid, RED, " >  That player is not in a deathmatch.");

	ExitDeathmatch(id);
	MsgF(playerid, YELLOW, " >  You have "#C_RED"kicked %P "#C_YELLOW"from deathmatches", id);
	MsgAllF(YELLOW, " >  %P"#C_YELLOW" Has been "#C_RED"kicked "#C_YELLOW"from the deathmatch, reason: "#C_BLUE"%s", id, reason);

	return 1;
}
ACMD:dmban[1](playerid, params[])
{
	new
		id,
		reason[128],
		delay;

	if(sscanf(params, "dS[128](None)D(0)", id, reason, delay))
		return Msg(playerid, YELLOW, " >  Usage: /dmban [playerid] [reason] (minutes)");

	if(pAdmin(id) >= pAdmin(playerid) && playerid != id)
		return 3;

	if(!IsPlayerConnected(id))
		return 4;

	if(!(bPlayerGameSettings[id] & InDM))
		return 3;

	ExitDeathmatch(id);
	bitTrue(bPlayerDeathmatchSettings[id], dm_Banned);

	if(delay > 0)
	{
		defer CmdDelay_undmban(id, delay * 60000);
		MsgAllF(YELLOW, " >  %P"#C_YELLOW" Has been "#C_RED"banned "#C_YELLOW"from all deathmatches for "#C_ORANGE"%d "#C_YELLOW"minutes, reason: "#C_BLUE"%s", id, delay, reason);
	}
	else
	{
		MsgAllF(YELLOW, " >  %P"#C_YELLOW" Has been "#C_RED"banned "#C_YELLOW"from all deathmatches, reason: "#C_BLUE"%s", id, reason);
	}


	return 1;
}

timer CmdDelay_undmban[time](playerid, time)
{
	#pragma unused time
	
	f:bPlayerDeathmatchSettings[playerid]<dm_Banned>;
	Msg(playerid, YELLOW, " >  You have been "#C_BLUE"un-banned "#C_YELLOW"from deathmatches.");
}

ACMD:undmban[1](playerid, params[])
{
	new id;

	if(sscanf(params, "d", id))
		return Msg(playerid, YELLOW, " >  Usage: /dmunban [playerid]");

	if(!IsPlayerConnected(id))
		return 4;

	if(!(bPlayerDeathmatchSettings[id] & dm_Banned))
		return 3;

	bitFalse(bPlayerDeathmatchSettings[id], dm_Banned);
	MsgF(playerid, YELLOW, " >  You have "#C_BLUE"un-banned %P "#C_YELLOW"from deathmatches", id);
	Msg(id, YELLOW, " >  You have been "#C_BLUE"un-banned "#C_YELLOW"from deathmatches");

	return 1;
}
ACMD:racekick[1](playerid, params[])
{
	new
		id,
		reason[128];

	if(sscanf(params, "dS[128](None)", id, reason))
		return Msg(playerid, YELLOW, " >  Usage: /racekick [playerid] [reason]");

	if(pAdmin(id) >= pAdmin(playerid) && playerid != id)
		return 3;

	if(!IsPlayerConnected(id))
		return 4;

	if(!(bPlayerGameSettings[id] & InRace))
		return 3;

	rc_Leave(id);
	MsgAllF(YELLOW, " >  %P"#C_YELLOW" Has been "#C_RED"kicked "#C_YELLOW"from the race, reason: "#C_BLUE"%s", id, reason);

	return 1;
}
ACMD:mgkick[1](playerid, params[])
{
	new
		id,
		reason[128];

	if(sscanf(params, "dS[128](None)", id, reason))
		return Msg(playerid, YELLOW, " >  Usage: /mgkick [playerid] [reason]");

	if(pAdmin(id) >= pAdmin(playerid) && playerid != id)
		return 3;

	if(!IsPlayerConnected(id))
		return 4;

	if(gCurrentMinigame[id] == MINIGAME_NONE)
		return 3;

	LeaveCurrentMinigame(id, false);
	MsgAllF(YELLOW, " >  %P"#C_YELLOW" Has been "#C_RED"kicked "#C_YELLOW"from the minigame, reason: "#C_BLUE"%s", id, reason);

	return 1;
}

//==========================================================================Server Control

ACMD:count[1](playerid, params[])
{
	if(gCurrentChallenge==CHALLENGE_MARKEDMAN)return 2;

	new tM, tS;
	if(!sscanf(params, "dD(0)", tS, tM))
	{
	    if(tM == 0 && tS == 0 )return StopCountdown();
		if(tM > 60 || tS > 60)return Msg(playerid, ORANGE, " >  Time must be under 60:60");
		StartCountdown(tM, tS);
	}
	else Msg(playerid, YELLOW, " >  Usage: /count [seconds] [optional:minutes] If 0, timer will be stopped");

	return 1;
}

ACMD:healall[1](playerid, params[])
{
	PlayerLoop(i)
		if(IsPlayerInFreeRoam(i))SetPlayerHP(i, 100.0);

	MsgAllF(YELLOW, " >  %P"#C_YELLOW" healed everyone", playerid);
	return 1;
}

ACMD:a[1](playerid, params[])
{
	new
		level = 1,
		text[128];

	if(!sscanf(params, "D(1)s[128]", level, text))
	{
		if(!(1 <= level <= 4))Msg(playerid, RED, " >  Invalid admin level. Must be between 1 and 4.");

		PlayerLoop(i)
		{
		    if(pAdmin(i) >= level)
		    {
				MsgF(i, WHITE, "%C(ADM) %P"#C_WHITE": %s",
					AdminColours[pAdmin(playerid)],
					playerid,
					TagScan(playerid, text));
		    }
		}
	}
	else Msg(playerid, YELLOW, " >  Usage: /a [optional:level] [message] - Sends a message to all admins with <level> or higher");

	return 1;
}
ACMD:msg[1](playerid, params[])
{
	if(!(0 < strlen(params) < 128))
		Msg(playerid,YELLOW," >  Usage: /Msg [Message]");

	new str[130] = {" >  "#C_BLUE""};

	strcat(str, TagScan(playerid, params));

	MsgAll(YELLOW, str);
	return 1;
}

ACMD:challenge[1](playerid, params[])
{
	if(!IsPlayerInFreeRoam(playerid))
	    return 2;

	if(GetPlayersOnline() < 2)
		return Msg(playerid, RED, " >  There aren't enough players online");

	FormatChallengeList(playerid);
	return 1;
}
ACMD:stopchallenge[1](playerid, params[])
{
	if(gCurrentChallenge == CHALLENGE_NONE)
	    return Msg(playerid, YELLOW, " >  There isn't a challenge active");

	ch_Stop(-3);

	return 1;
}

#undef LEVEL
