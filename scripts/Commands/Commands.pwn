#include "../scripts/Commands/Admin.pwn"
#include "../scripts/Commands/Anims.pwn"
#include "../scripts/Commands/Lists.pwn"
#include "../scripts/Commands/Cmds.pwn"
#include "../scripts/Commands/Teleports.pwn"
#include "../scripts/Commands/Fun.pwn"
#include "../scripts/Commands/Dev.pwn"
#include "../scripts/Commands/Request.pwn"

#include <YSI\y_hooks>


CMD:home(playerid, params[])
{
	if(gCurrentChallenge != CHALLENGE_NONE)
		return Msg(playerid, ORANGE, " >  There is currently a challenge active, you are not allowed to teleport");

	if(bPlayerGameSettings[playerid] & InDM)ExitDeathmatch(playerid);
	if(bPlayerGameSettings[playerid] & InRace)rc_Leave(playerid);

    LeaveCurrentMinigame(playerid, true);

    gCurrentMinigame[playerid] = MINIGAME_NONE;

	if(bPlayerGameSettings[playerid] & Frozen)
		TogglePlayerControllable(playerid, false);

	else
		TogglePlayerControllable(playerid, true);

	SetPlayerPos(playerid, HomeSpawnData[gHomeSpawn[playerid]][spn_posX], HomeSpawnData[gHomeSpawn[playerid]][spn_posY], HomeSpawnData[gHomeSpawn[playerid]][spn_posZ]);
	SetPlayerFacingAngle(playerid, HomeSpawnData[gHomeSpawn[playerid]][spn_rotZ]);
	SetPlayerVirtualWorld(playerid, FREEROAM_WORLD);
	SetPlayerInterior(playerid, 0);
	SetPlayerSkin(playerid, pSkin(playerid));
	SetCameraBehindPlayer(playerid);
	CancelSelectTextDraw(playerid);

	TextDrawShowForPlayer(playerid, InfoBar);
	TextDrawShowForPlayer(playerid, ClockText);


	HideActionText(playerid);
    return 1;
}
CMD:mystats(playerid, params[])
{
	new
		str[800],
		g_str[128],
		inveh_additional,
		onfoot_additional;

	if(EnterVehTick[playerid]==0)inveh_additional=0;
	else inveh_additional=(tickcount()-EnterVehTick[playerid]);
	if(EnterFootTick[playerid]==0)onfoot_additional=0;
	else onfoot_additional=(tickcount()-EnterFootTick[playerid]);

	new
		t_total		= (gPlayerData[playerid][ply_TimePlayed] + (tickcount() - gPlayerData[playerid][ply_JoinTick])),
		t_session	= (tickcount() - gPlayerData[playerid][ply_JoinTick]),
		t_inveh		= (gPlayerData[playerid][ply_TimeInVeh] + inveh_additional),
		t_onfoot	= (gPlayerData[playerid][ply_TimeOnFoot] + onfoot_additional);

	strcat(str, ""C_WHITE"-  General\n");
	format(g_str, 128, ""#C_BLUE"Admin Level:\t\t\t"#C_GREEN"%d\n", pAdmin(playerid));
	strcat(str, g_str);
	format(g_str, 128, ""#C_BLUE"Time Played (This Session):\t"#C_GREEN"%s\n", MsToString(t_session));
	strcat(str, g_str);
	format(g_str, 128, ""#C_BLUE"Time Played (All Time):\t"#C_GREEN"%s\n", MsToString(t_total));
	strcat(str, g_str);
	format(g_str, 128, ""#C_BLUE"Time In Vehicle:\t\t"#C_GREEN"%s\n",MsToString(t_inveh));
	strcat(str, g_str);
	format(g_str, 128, ""#C_BLUE"Time On Foot:\t\t\t"#C_GREEN"%s\n", MsToString(t_onfoot));
	strcat(str, g_str);

	strcat(str, "\n\n"#C_WHITE"-  Deathmatch\n");
	format(g_str, 128, ""#C_BLUE"Rank:\t\t\t\t"#C_GREEN"%s(%d)\n", RankNames[pRank(playerid)], pRank(playerid));
	strcat(str, g_str);
	format(g_str, 128, ""#C_BLUE"Kills:\t\t\t\t"#C_GREEN"%d\n", pKills(playerid));
	strcat(str, g_str);
	format(g_str, 128, ""#C_BLUE"Deaths:\t\t\t"#C_GREEN"%d\n", pDeaths(playerid));
	strcat(str, g_str);
	format(g_str, 128, ""#C_BLUE"XP:\t\t\t\t"#C_GREEN"%d\n", pExp(playerid));
	strcat(str, g_str);
	format(g_str, 128, ""#C_BLUE"Next Rank:\t\t\t"#C_GREEN"%s(%d)\n", RankNames[pRank(playerid)+1], (pRank(playerid)+1));
	strcat(str, g_str);
	format(g_str, 128, ""#C_BLUE"XP To Go:\t\t\t"#C_GREEN"%d", (RequiredExp[pRank(playerid)+1]-pExp(playerid)));
	strcat(str, g_str);

	ShowPlayerDialog(playerid, d_Stats, DIALOG_STYLE_MSGBOX, "Your Stats", str, "Close", "");
	return 1;
}

CMD:die(playerid, params[])
{
    if(bPlayerGameSettings[playerid] & InDM)dm_SetPlayerHP(playerid, 0.0);
    else
	{
	    GivePlayerWeapon(playerid, 4, 1);
	    ApplyAnimation(playerid, "STRIP", "strip_A", 4.0, 0, 0, 0, 0, 0);
		defer Suicide(playerid);
	}
	return 1;
}
timer Suicide[1000](playerid)
{
	SetPlayerHP(playerid, 0.0);
	MsgAllF(GREEN, " >  %P"#C_GREEN" Comitted Suicide!", playerid);
}
CMD:spawn(playerid, params[])
{
    if(bPlayerGameSettings[playerid] & InDM)dm_SetPlayerHP(playerid, 0.0);
    else if(gCurrentMinigame[playerid] == MINIGAME_PARKOUR)prk_Fall(playerid);
    else if(gCurrentMinigame[playerid] == MINIGAME_FALLOUT)dgw_Out(playerid);
    else if(gCurrentMinigame[playerid] == MINIGAME_CARSUMO)smo_Out(playerid);
    else if(gCurrentMinigame[playerid] == MINIGAME_DESDRBY)dby_Out(playerid);
	else
	{
		SpawnPlayer(playerid);
		Msg(playerid, GREY, " >  Respawned");
	}
	return 1;
}
CMD:skin(playerid, params[])
{
	new skinid;
	if(sscanf(params, "d", skinid)) Msg(playerid, YELLOW, "Usage: /skin [skinid]");
	else if(!IsValidSkin(skinid)) return Msg(playerid, RED, " >  Valid skin values: 0-299");
	else
	{
		SetPlayerSkin(playerid, skinid);
		Msg(playerid, YELLOW, " >  Skin Changed!");
	}
	return 1;
}
CMD:givecash(playerid, params[])
{
	new
		id,
		amount;

	if(sscanf(params, "dd", id, amount)) Msg(playerid, YELLOW, "Usage  /givecash [playerid] [amount]");
	else if(!IsPlayerConnected(id)) Msg(playerid, RED, " >  Invalid ID");
	else if(!(0 < amount <= GetPlayerMoney(playerid))) Msg(playerid, RED, " >  Invalid money amount!");
	else
	{
		GivePlayerMoney(id, amount);
		GivePlayerMoney(playerid, -amount);

		MsgF(playerid, YELLOW, " >  You've given $%d to %P.", amount, id);
		MsgF(id, YELLOW,  " >  You've recieved $%d from %P.", amount, playerid);
	}
	return 1;
}
CMD:god(playerid, params[])
{
	if(!IsPlayerInFreeRoam(playerid))return 2;

	if(bPlayerGameSettings[playerid] & GodMode)
	{
		bitFalse(bPlayerGameSettings[playerid], GodMode);
		Msg(playerid, YELLOW, " >  God Mode "#C_BLUE"Off");
		SetPlayerArmour(playerid, 0.0);
		SetPlayerHP(playerid, 100.0);
	}
	else
	{
		if(!IsPlayerInFreeRoam(playerid) || bPlayerGameSettings[playerid] & GodLock)return 2;
		Msg(playerid, YELLOW, " >  God Mode "#C_BLUE"On");
		bitTrue(bPlayerGameSettings[playerid], GodMode);
	}
	return 1;
}
CMD:health(playerid, params[])
{
	if(!IsPlayerInFreeRoam(playerid))return 2;
	SetPlayerHP(playerid, 100.0);
	return 1;
}
CMD:f(playerid, params[])
{
	if(!IsPlayerInFreeRoam(playerid))return 2;

	new
		vehicleid = GetPlayerVehicleID(playerid),
		Float:rotation;

	GetVehicleZAngle(vehicleid, rotation);
	SetVehicleZAngle(vehicleid, rotation);

	Msg(playerid, GREEN, " >  Flipped And Fixed");
	PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
	RepairVehicle(vehicleid);

	return 1;
}
CMD:w(playerid, params[])
{
	if(
		!IsPlayerInFreeRoam(playerid) ||
		bServerGlobalSettings & WeaponLock ||
		bPlayerGameSettings[playerid] & WepLock ) return 2;


	FormatWeaponIndex(playerid);
	return 1;
}
CMD:v(playerid, params[])
{
	if(!IsPlayerInFreeRoam(playerid) || !(bPlayerGameSettings[playerid] & Spawned))return 2;

	FormatVehicleIndex(playerid);

	return 1;
}
CMD:mod(playerid, params[])
{
	if(!IsPlayerInFreeRoam(playerid))return 2;

	ShowModMenu(playerid);

	return 1;
}
CMD:camera(playerid, params[])
{
	GivePlayerWeapon(playerid, WEAPON_CAMERA, 36*4);
	return 1;
}
CMD:jet(playerid, params[])
{
	if(!IsPlayerInFreeRoam(playerid))return 2;

	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);

	return 1;
}
CMD:mouse(playerid, params[])
{
	SelectTextDraw(playerid, YELLOW);
	return 1;
}
CMD:nos(playerid, params[])
{
	if(!IsPlayerInFreeRoam(playerid))return 2;

	new vehicleid = GetPlayerVehicleID(playerid);

	if(IsPlayerInInvalidNosVehicle(playerid, vehicleid))
		Msg(playerid, RED, " >  NOS Not Available In This Vehicle");

	else if(!IsPlayerInVehicle(playerid, vehicleid))
		Msg(playerid, RED, " >  You are not in a vehicle idiot.");

	else
	{
		Msg(playerid, GREEN, " >  Nitro boost added!");
		PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
		AddVehicleComponent(vehicleid, 1010);
	}

	return 1;
}
CMD:colour(playerid, params[])
{
	new
		list[sizeof(ColourData) * (32 + 1)],
		tmpstr[32];

    for(new i;i<sizeof(ColourData);i++)
    {
        format(tmpstr, 32, "%s\n", ColourData[i][colour_name]);
        strcat(list, tmpstr);
    }

	ShowPlayerDialog(playerid, d_Colourlist, DIALOG_STYLE_LIST,	"Choose a colour for your nametag and icon:", list, "Select", "Cancel");
	return 1;
}
CMD:players(playerid, params[])
{
	MsgF(playerid, YELLOW, " >  There are "#C_BLUE"%d "#C_YELLOW"Players Online", GetPlayersOnline());
	return 1;
}
CMD:sky(playerid, params[])
{
	if(!IsPlayerInFreeRoam(playerid))return 2;

    new
		Float:x,
		Float:y,
		Float:z;

	if(IsPlayerInAnyVehicle(playerid))
	{
		new
			vehicleid = GetPlayerVehicleID(playerid);

		GetVehiclePos(vehicleid, x, y, z);
		SetVehiclePos(vehicleid, x, y, z+500.0);
		PutPlayerInVehicle(playerid, vehicleid, 0);

		GameTextForPlayer(playerid, "Have A nice Fall!", 3000, 5);
	}
	else
	{
		GetPlayerPos(playerid, x, y, z);
		SetPlayerPos(playerid, x, y, z+500.0);
		GivePlayerWeapon(playerid, WEAPON_PARACHUTE, 1);

		GameTextForPlayer(playerid, "Have A nice Fall!", 3000, 5);
	}

	return 1;
}
CMD:para(playerid, params[])
{
	if(!IsPlayerInFreeRoam(playerid))return 2;
	GivePlayerWeapon(playerid, WEAPON_PARACHUTE, 1);
	return 1;
}
CMD:kickme(playerid, params[])
{
	MsgAllF(PINK, " >  %P"#C_PINK" Kicked himself with /kickme", playerid);
	Kick(playerid);
	return 1;
}

CMD:beer(playerid, params[])
{
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DRINK_BEER);
	return 1;
}
CMD:fag(playerid, params[])
{
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_SMOKE_CIGGY);
	return 1;
}
CMD:wine(playerid, params[])
{
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DRINK_WINE);
	return 1;
}
CMD:sprunk(playerid, params[])
{
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DRINK_SPRUNK);
	return 1;
}
CMD:sober(playerid, params[])
{
    SetPlayerDrunkLevel(playerid, 0);
    return 1;
}

CMD:rand(playerid, params[])
{
	new r=random(random(random(random(random(random(random(r*r*r*r*r*r^r^r^r^r^r^r^r^r^r^r^r/random((r^r, r*random(9001))))))))));
	MsgAllF(BLUE, " >  %P "#C_BLUE"Generated a random number... %d", playerid, random(random(random(random(random(random(random(r))))))));
	return 1;
}
CMD:dist(playerid, params[])
{
	new
		Float:px1, Float:py1, Float:pz1,
		Float:px2, Float:py2, Float:pz2;

	GetPlayerPos(strval(params), px1, py1, pz1);
	GetPlayerPos(playerid, px2, py2, pz2);
	MsgF(playerid, GREEN, "Distance To Player: %fm", floatsqroot(((px2-px1)*(px2-px1))+((py2-py1)*(py2-py1))+((pz2-pz1)*(pz2-pz1))));
	return 1;
}
CMD:psave(playerid, params[])
{
	if(pAdmin(playerid)<3 && !IsPlayerInFreeRoam(playerid))return 0;

	if(IsPlayerInAnyVehicle(playerid))
	{
		new vehicleid = GetPlayerVehicleID(playerid);
		GetVehiclePos(vehicleid, gPlayerSavePosition[playerid][sp_posX], gPlayerSavePosition[playerid][sp_posY], gPlayerSavePosition[playerid][sp_posZ]);
		GetVehicleZAngle(vehicleid, gPlayerSavePosition[playerid][sp_rotation]);
	}
	else
	{
		GetPlayerPos(playerid, gPlayerSavePosition[playerid][sp_posX], gPlayerSavePosition[playerid][sp_posY], gPlayerSavePosition[playerid][sp_posZ]);
		GetPlayerFacingAngle(playerid, gPlayerSavePosition[playerid][sp_rotation]);
	}

	gPlayerSavePosition[playerid][sp_world] = GetPlayerVirtualWorld(playerid);
	gPlayerSavePosition[playerid][sp_interior] = GetPlayerInterior(playerid);

	Msg(playerid, YELLOW, " >  Position saved! Type "#C_BLUE"/b "#C_YELLOW"to go back here.");
	return 1;
}
CMD:b(playerid, params[])
{
	if(pAdmin(playerid)<3 && !IsPlayerInFreeRoam(playerid))return 0;

	if(IsPlayerInAnyVehicle(playerid))
	{
	    new vehicleid = GetPlayerVehicleID(playerid);
		SetVehiclePos(vehicleid, gPlayerSavePosition[playerid][sp_posX], gPlayerSavePosition[playerid][sp_posY], gPlayerSavePosition[playerid][sp_posZ]);
		SetVehicleZAngle(vehicleid, gPlayerSavePosition[playerid][sp_rotation]);
		SetVehicleVirtualWorld(vehicleid, gPlayerSavePosition[playerid][sp_world]);
		LinkVehicleToInterior(vehicleid, gPlayerSavePosition[playerid][sp_interior]);
	}
	else
	{
		SetPlayerPos(playerid, gPlayerSavePosition[playerid][sp_posX], gPlayerSavePosition[playerid][sp_posY], gPlayerSavePosition[playerid][sp_posZ]);
		SetPlayerFacingAngle(playerid, gPlayerSavePosition[playerid][sp_rotation]);
	}
	SetPlayerVirtualWorld(playerid, gPlayerSavePosition[playerid][sp_world]);
	SetPlayerInterior(playerid, gPlayerSavePosition[playerid][sp_interior]);
 	return 1;
}
CMD:radio(playerid, params[])
{
    FormatRadioList(playerid);
    return 1;
}
FormatRadioList(playerid)
{
	new
		tmpStr[64],
		finalStr[256];
	for(new x;x<sizeof(RadioStreams);x++)
	{
	    format(tmpStr, 64, "%s\n", RadioStreams[x][1]);
	    strcat(finalStr, tmpStr);
	}
	ShowPlayerDialog(playerid, d_RadioList, DIALOG_STYLE_LIST, "Radio Streams", finalStr, "Play", "Stop");
}


CMD:idea(playerid, params[])
{
	new idea[128];
	if(sscanf(params, "s[128]", idea)) return Msg(playerid, YELLOW, "Usage: /idea [idea]");
	else
	{
		new
			File:tmpfile,
			str[128+MAX_PLAYER_NAME+5];

		format(str, sizeof(str), "%p - %s\r\n", playerid, idea);
		if(!fexist("ideas.txt"))tmpfile = fopen("ideas.txt", io_write);
		else tmpfile = fopen("ideas.txt", io_append);
		fwrite(tmpfile, str);
		fclose(tmpfile);

		Msg(playerid, YELLOW, " >  Your idea has been submitted, thank you!");
	}
	return 1;
}
CMD:bug(playerid, params[])
{
	new bug[128];
	if(sscanf(params, "s[128]", bug)) return Msg(playerid, YELLOW, "Usage: /bug [bug]");
	else
	{
		new
			File:tmpfile,
			str[128+MAX_PLAYER_NAME+5];
		
		format(str, sizeof(str), "%p - %s\r\n", playerid, bug);
		if(!fexist("bugs.txt"))tmpfile = fopen("bugs.txt", io_write);
		else tmpfile = fopen("bugs.txt", io_append);
		fwrite(tmpfile, str);
		fclose(tmpfile);
		
		Msg(playerid, YELLOW, " >  Your bug report has been submitted! Southclaw will get off his arse and fix this when he can.");
	}
	return 1;
}
CMD:clock(playerid, params[])
{
	new
		Hour,
		Minutes,
		Seconds;

	gettime(Hour,Minutes,Seconds);
	MsgF(playerid, YELLOW, " >  Current Time: "#C_BLUE"%02d : %02d : %02d",Hour,Minutes,Seconds);

	return 1;
}
CMD:date(playerid, params[])
{
	new
		Year,
		Month,
		Day;

	getdate(Year,Month,Day);
	MsgF(playerid, YELLOW, " >  Current Date: "#C_BLUE"%02d - %02d - %d", Day, Month, Year);

	return 1;
}
CMD:pos(playerid, params[])
{
	new
		Float:fX,
		Float:fY,
		Float:fZ;

	GetPlayerPos(playerid, fX, fY, fZ);
	MsgF(playerid, YELLOW, " >  Position: "#C_BLUE"%f, %f, %f", fX, fY, fZ);
	return 1;
}



//==============================================================================Account stuff




CMD:report(playerid, params[])
{
	new
		id,
		text[128];

	if(sscanf(params, "ds[128]", id, text)) return Msg(playerid,YELLOW,"Usage: /report [playerid] [Reason]");
	else if(!IsPlayerConnected(id)) return Msg(playerid, RED, " >  Invalid ID");

	MsgAdminsF(1, BLUE, " >  %P"#C_BLUE" Has reported %P"#C_BLUE" for "#C_GREY"%s", playerid, id, text);

	return 1;
}
CMD:getstats(playerid, params[])
{
	if(strlen(params))
	{
		new
			id,
			statsType,
			tmpName[24],
			tmpColour,
			strHeading[32],
			strMain[1024];

		if(!sscanf(params, "dD(0)", id, statsType))
		{
			tmpName = gPlayerName[id];
			tmpColour = GetPlayerColor(id);
		}
		else if(!sscanf(params, "s[24]D(0)", tmpName, statsType))
		{
			id=GetPlayerID(tmpName);
			tmpColour = GREY;
		}
		else return Msg(playerid, YELLOW, "Usage: /getstats [playerid/playername] "#C_ORANGE"OPTIONAL:"#C_YELLOW"[type: 0 = general stats, 1 = deathmatch stats]");

		if(IsPlayerConnected(id))
		{
			strcpy(strMain, FormatGenStats(id, statsType));
		}
		else
		{
			new tmpFile[50];
			format(tmpFile, 50, PLAYER_DATA_FILE, tmpName);
			if(fexist(tmpFile))
			{
				strcpy(strMain, FormatGenStatsFromFile(tmpFile, tmpName, statsType));
			}
			else return Msg(playerid, RED, " >  User does not exist");
		}
		format(strHeading, 32, "%C%s", tmpColour, tmpName);
		ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, strHeading, strMain, "Close", "");
	}
	return 1;
}





// ===================================================================Chat Modes







CMD:me(playerid, params[])
{
	if(isnull(params))
		return Msg(playerid, YELLOW, "Usage: /me [Message]");

	MsgAllF(TEAL, " >  %P"#C_TEAL" %s", playerid, TagScan(playerid, params, YELLOW));

	return 1;
}
CMD:g(playerid, params[])
{
	new msg[128];

	if(sscanf(params, "s", msg))
	{
		gPlayerChatChannel[playerid] = CHANNEL_GLOBAL;
		Msg(playerid, YELLOW, " >  You are now talking on the "#C_BLUE"global "#C_YELLOW"chat channel");
		return 1;
	}

    PlayerSendChat(playerid, msg);

	return 1;
}
CMD:t(playerid, params[])
{
	new msg[128];

	if(sscanf(params, "s", msg))
	{
		gPlayerChatChannel[playerid] = CHANNEL_TEAM;
		Msg(playerid, YELLOW, " >  You are now talking on the "#C_BLUE"Team "#C_YELLOW"chat channel");
		return 1;
	}

	MsgTeamF(pTeam(playerid), BLUE, "(T)%P"#C_WHITE": %s", playerid, msg);

	return 1;
}
CMD:vc(playerid, params[])
{
	if(!IsPlayerInAnyVehicle(playerid))
		return Msg(playerid, ORANGE, " >  You have to be in a vehicle");

	new
		msg[128],
		vehicleid = GetPlayerVehicleID(playerid);

	if(sscanf(params, "s", msg))
	{
		gPlayerChatChannel[playerid] = CHANNEL_VEHICLE;
		Msg(playerid, YELLOW, " >  You are now talking on the "#C_BLUE"Vehicle "#C_YELLOW"chat channel");
		return 1;
	}

	PlayerLoop(i)
	{
		if(IsPlayerInVehicle(i, vehicleid))
			MsgF(i, WHITE, "(V)%P"#C_WHITE": %s", playerid, TagScan(playerid, msg));
	}
	return 1;
}
CMD:pm(playerid, params[])
{
	new id, text[98];
	if(sscanf(params, "ds[98]", id, text))Msg(playerid, YELLOW, "Usage: /pm [playerid] [message]");
	else if(!IsPlayerConnected(id))Msg(playerid, RED, " >  Invalid ID");
	else
	{
	    if(Blocked[playerid][id])
			return Msg(playerid, RED, "This player has blocked you from sending persona messages and using private chat");

		MsgF(id, GREEN, "(PM) from "#C_WHITE"(%d)%P"#C_WHITE": %s", playerid, playerid, text);
		MsgF(playerid, GREEN, "(PM) to "#C_WHITE"(%d)%P"#C_WHITE": %s", id, id, text);
		GameTextForPlayer(id, "~n~~n~~n~~n~~n~~b~PM RECIEVED", 1000, 5);

		new
			logfile[30],
			line[256],
			y, m, d,
			h, mn, s,
			File:f;

		if(!fexist(logfile))
			f = fopen(logfile, io_write);

		else
			f = fopen(logfile, io_append);

		getdate(y, m, d);
		gettime(h, mn, s);
		format(logfile, 30, "Server/Logs/%d-%d-%d.txt", d, m, y);
		format(line, 256, "%d:%d:%d - %p>%p = %s", h, mn, s, playerid, id, text);

		fwrite(f, line);
		fclose(f);
	}
	return 1;
}
CMD:chat(playerid, params[])
{
	new id = strval(params);

	if(!IsPlayerConnected(id) || !isnumeric(params) || isnull(params))
		return Msg(playerid, YELLOW, "Usage: /chat [playerid] - your chat messages will only be sent to this player");

	if(Blocked[playerid][id])return Msg(playerid, RED, "This player has blocked you from sending personal messages and using private chat");

	if(gPlayerChatChannel[playerid] == -1 || gPlayerChatChannel[playerid] >= MAX_PLAYERS)
	{
		gPlayerChatChannel[playerid] = id;
		gPlayerChatChannel[id] = playerid;
		MsgF(playerid, BLUE, " >  You are now in private chat with %P", id);
		MsgF(id, BLUE, " >  You are now in private chat with %P", playerid);
   	}
   	else
   	{
		gPlayerChatChannel[playerid] = -1;
		gPlayerChatChannel[id] = -1;
		MsgF(playerid, BLUE, " >  You have ended chat with %P", id);
		MsgF(id, BLUE, " >  %P"#C_BLUE" has ended the chat with you", playerid);
	}
	return 1;
}
CMD:block(playerid, params[])
{
	new id=strval(params);
	if(!IsPlayerConnected(id)||!isnumeric(params)||!(strlen(params)>0) || id >= MAX_PLAYERS || id < 0)Msg(playerid, YELLOW, "Usage: /block [playerid] - Block or Unblock a player from PM and Private Chatting with you");
	else
	{
	    if(Blocked[playerid][id])
	    {
			Blocked[playerid][id]=false;
			Msg(playerid, YELLOW, "%s has been unblocked, they can now send you personal messages and chat with you");
	    }
	    else
	    {
			Blocked[playerid][id]=true;
			Msg(playerid, YELLOW, "%s has been blocked from sending you personal messages and chatting with you. You can also /report them to an admin");
	    	if(gPlayerChatChannel[playerid]==id)
	    	{
	    	    gPlayerChatChannel[playerid]=-1;
	    	    gPlayerChatChannel[id]=-1;
	    		MsgF(playerid, BLUE, " >  You have ended chat with %P", id);
	    		MsgF(id, BLUE, " >  %P"#C_BLUE" has ended the chat with you", playerid);
	    	}
		}
	}
	return 1;
}
CMD:hide(playerid, params[])
{
	new id=strval(params);
	if(!IsPlayerConnected(id)||!isnumeric(params)||!(strlen(params)>0))Msg(playerid, YELLOW, "Usage: /hide [playerid] - Hide a players chat text from appearing on your chat box");
	else
	{
	    if(Hidden[playerid][id])
	    {
			Hidden[playerid][id]=false;
			Msg(playerid, YELLOW, "%s has been unhidden, you can now see their chat text");
	    }
	    else
	    {
			Hidden[playerid][id]=true;
			Msg(playerid, YELLOW, "%s has been hidden, you won't see their chat text anymore. You can also /report them to an admin");
		}
	}
	return 1;
}










//==============================================================VEHICLE COMMANDS





	CMD:engine(playerid, params[])
	{
	    v_Engine(GetPlayerVehicleID(playerid), !v_Engine(GetPlayerVehicleID(playerid)));
		return 1;
	}
	CMD:lights(playerid, params[])
	{
	    v_Lights(GetPlayerVehicleID(playerid), !v_Lights(GetPlayerVehicleID(playerid)));
		return 1;
	}
	CMD:alarm(playerid, params[])
	{
	    v_Alarm(GetPlayerVehicleID(playerid), !v_Alarm(GetPlayerVehicleID(playerid)));
		return 1;
	}
	CMD:bonnet(playerid, params[])
	{
	    v_Bonnet(GetPlayerVehicleID(playerid), !v_Bonnet(GetPlayerVehicleID(playerid)));
		return 1;
	}
	CMD:boot(playerid, params[])
	{
	    v_Boot(GetPlayerVehicleID(playerid), !v_Boot(GetPlayerVehicleID(playerid)));
		return 1;
	}
	CMD:lock(playerid, params[])
	{
		if(!IsPlayerInAnyVehicle(playerid)) Msg(playerid, ORANGE, "**You Are Not In A Vehicle");
		else
		{
			PlayerLoop(i)
			SetVehicleParamsForPlayer(GetPlayerVehicleID(playerid), i, 0, 1);
			Msg(playerid, YELLOW, "**Vehicle Locked");
		}
		return 1;
	}
	CMD:unlock(playerid, params[])
	{
		PlayerLoop(i)
		SetVehicleParamsForPlayer(GetPlayerVehicleID(playerid), i, 0, 0);
		Msg(playerid, YELLOW, "**Vehicle Unlocked");
		return 1;
	}
	CMD:getspeed(playerid, params[])
	{
		new
			Float:Velocity[3],
			vehicleid = GetPlayerVehicleID(playerid);
		GetVehicleVelocity(vehicleid, Velocity[0], Velocity[1], Velocity[2]);
		MsgF(playerid, YELLOW, "You are going at a velocity of X%f, Y%f, Z%f Total Calculated: %f", Velocity[0], Velocity[1], Velocity[2], CalculateVelocity(Velocity[0], Velocity[1], Velocity[2]));
		return 1;
	}
	CMD:boost(playerid, params[])
	{
		if(bPlayerGameSettings[playerid]&InDM || bPlayerGameSettings[playerid]&InRace || bServerGlobalSettings&FreeDM || !(bServerGlobalSettings&FreeroamCommands) || gCurrentMinigame[playerid] != MINIGAME_NONE || gCurrentChallenge != CHALLENGE_NONE)return 0;
		if(bPlayerGameSettings[playerid]&SpeedBoost)
		{
			bitFalse(bPlayerGameSettings[playerid], SpeedBoost);
			Msg(playerid, YELLOW, " >  Boost Mode "#C_BLUE"off");
		}
		else
		{
			bitTrue(bPlayerGameSettings[playerid], SpeedBoost);
			Msg(playerid, YELLOW, " >  Boost Mode "#C_BLUE"ON! "#C_YELLOW"Press the Horn button to boost your car!");
		}
		return 1;
	}
	CMD:jump(playerid, params[])
	{
		if(bPlayerGameSettings[playerid]&InDM || bPlayerGameSettings[playerid]&InRace || bServerGlobalSettings&FreeDM || !(bServerGlobalSettings&FreeroamCommands) || gCurrentMinigame[playerid] != MINIGAME_NONE || gCurrentChallenge != CHALLENGE_NONE)return 0;
		if(bPlayerGameSettings[playerid]&JumpBoost)
		{
			bitFalse(bPlayerGameSettings[playerid], JumpBoost);
			Msg(playerid, YELLOW, " >  Jump Mode "#C_BLUE"off");
		}
		else
		{
			bitTrue(bPlayerGameSettings[playerid], JumpBoost);
			Msg(playerid, YELLOW, " >  Jump Mode "#C_BLUE"ON! "#C_YELLOW"Press the Horn button to make your car Hop!");
		}
		return 1;
	}
	CMD:falloff(playerid, params[])
	{
		if(bPlayerGameSettings[playerid]&InDM || bPlayerGameSettings[playerid]&InRace || bServerGlobalSettings&FreeDM || !(bServerGlobalSettings&FreeroamCommands) || gCurrentMinigame[playerid] != MINIGAME_NONE || gCurrentChallenge != CHALLENGE_NONE)return 0;
		if(bPlayerGameSettings[playerid]&JumpBoost)
		{
			bitFalse(bPlayerGameSettings[playerid], AntiFallOffBike);
			Msg(playerid, YELLOW, " >  Falling off bikes is now "#C_BLUE"enabled");
		}
		else
		{
			bitTrue(bPlayerGameSettings[playerid], AntiFallOffBike);
			Msg(playerid, YELLOW, " >  Falling off bikes is now "#C_BLUE"disabled");
		}
		return 1;
	}


CMD:carcolour(playerid, params[])
{
	new vehicleid = GetPlayerVehicleID(playerid);
	if(IsValidVehicle(vehicleid))
	{
		new
			colour1,
			colour2;

		if(sscanf(params, "dD(-1)", colour1, colour2)) Msg(playerid, YELLOW, " >  Usage: /carcolor [colour 1] [optional:colour 2]");
		else 
		{
			ChangeVehicleColor(vehicleid, colour1, colour2);
			Msg(playerid, YELLOW, " >  Vehicle colours changed!");
		}
	}
	return 1;
}


hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_Help && response)
	{
	    switch(listitem)
	    {
	        case 0:cmd_info(playerid, "");
	        case 1:cmd_rules(playerid, "");
	        case 2:cmd_cmds(playerid, "");
	        case 3:cmd_chatinfo(playerid, "");
	        case 4:cmd_credits(playerid, "");
	        case 5:cmd_admins(playerid, "");
	    }
	}

	if(dialogid == d_Cmds && response)
	{
	    switch(listitem)
	    {
	        case 0:cmd_fun(playerid, "");
	        case 1:cmd_teles(playerid, "");
	        case 2:cmd_pcmds(playerid, "");
	        case 3:cmd_vcmds(playerid, "");
	        case 4:cmd_misc(playerid, "");
	        case 5:cmd_animlist(playerid, "");
	    }
	}
	if(dialogid == d_Fun && response)
	{
	    switch(listitem)
	    {
	        case 0:cmd_joindm(playerid, "");
	        case 1:cmd_minigames(playerid, "");
	        case 2:cmd_challenges(playerid, "");
	    }
	}
	if(dialogid == d_Minigames && response)
	{
/*
		switch(listitem)
		{
		}
*/
	}

	if(dialogid == d_Places && response)
	{
	    switch(listitem)
	    {
	        case 0:cmd_home(playerid, "");
	        case 1:OnPlayerCommandText(playerid, "/ls");
	        case 2:OnPlayerCommandText(playerid, "/sf");
	        case 3:OnPlayerCommandText(playerid, "/lv");
	        case 4:OnPlayerCommandText(playerid, "/lsair");
	        case 5:OnPlayerCommandText(playerid, "/sfair");
	        case 6:OnPlayerCommandText(playerid, "/lvair");
	        case 7:OnPlayerCommandText(playerid, "/area51");
	        case 8:OnPlayerCommandText(playerid, "/airbase");
	        case 9:OnPlayerCommandText(playerid, "/aa");
	        case 10:OnPlayerCommandText(playerid, "/ch");
	        case 11:OnPlayerCommandText(playerid, "/qu");
	        case 12:OnPlayerCommandText(playerid, "/bay");
	        case 13:OnPlayerCommandText(playerid, "/ear");
	        case 14:OnPlayerCommandText(playerid, "/probe");
	    }
	}
	if(dialogid == d_Drifts && response)
	{
	    switch(listitem)
	    {
	        case 0:OnPlayerCommandText(playerid, "cmd_drift1");
	        case 1:OnPlayerCommandText(playerid, "cmd_drift2");
	        case 2:OnPlayerCommandText(playerid, "cmd_drift3");
	    }
	}
	if(dialogid == d_Jumps && response)
	{
	    switch(listitem)
	    {
	        case 0:OnPlayerCommandText(playerid, "bigjump1");
	        case 1:OnPlayerCommandText(playerid, "bigjump2");
	        case 2:OnPlayerCommandText(playerid, "hugejump");
	        case 3:OnPlayerCommandText(playerid, "halfhugejump");
	    }
	}
	if(dialogid == d_Tuning && response)
	{
	    switch(listitem)
	    {
	        case 0:OnPlayerCommandText(playerid, "/modls");
	        case 1:OnPlayerCommandText(playerid, "/modsf");
	        case 2:OnPlayerCommandText(playerid, "/modlv");
	        case 3:OnPlayerCommandText(playerid, "/waa");
	        case 4:OnPlayerCommandText(playerid, "/loco");
	    }
	}


	if(dialogid == d_PCmds && response)
	{
	    switch(listitem)
	    {
	        case 0:cmd_report(playerid, "");
	        case 1:cmd_psave(playerid, "");
	        case 2:cmd_getstats(playerid, "");
	        case 3:cmd_givecash(playerid, "");
	        case 4:cmd_colour(playerid, "");
	        case 5:cmd_skin(playerid, "");
	        case 6:cmd_para(playerid, "");
	    }
	}
	if(dialogid == d_VCmds && response)
	{
	    switch(listitem)
	    {
	        case 0:cmd_f(playerid, "");
	        case 1:cmd_lock(playerid, "");
	        case 2:cmd_unlock(playerid, "");
	        case 3:cmd_nos(playerid, "");
	        case 4:cmd_vc(playerid, "");
	        case 5:cmd_v(playerid, "");
	        case 6:cmd_mod(playerid, "");
	    }
	}
	if(dialogid == d_Misc && response)
	{
	    switch(listitem)
	    {
	        case 0:cmd_sky(playerid, "");
	        case 1:cmd_para(playerid, "");
	        case 2:cmd_pos(playerid, "");
	        case 3:cmd_idea(playerid, "");
	        case 4:cmd_bug(playerid, "");
	        case 5:cmd_rand(playerid, "");
	    }
	}
	return 1;
}
