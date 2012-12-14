#define LEVEL 4


CMD:adminlvl(playerid, params[])
{
    if(!IsPlayerAdmin(playerid))
		return 0;

	new level;

	if(sscanf(params, "d", level))
		return Msg(playerid, YELLOW, " >  Usage: /adminlvl [level]");

	if(!SetPlayerAdminLevel(playerid, level))
		return Msg(playerid, RED, " >  Admin level must be equal to or between 0 and 4");


	MsgF(playerid, YELLOW, " >  Admin Level Secretly Set To: %d", level);

	return 1;
}

//==============================================================================Player

ACMD:getinfo[4](playerid, params[])
{
	if(!strlen(params))
		return Msg(playerid, YELLOW, " >  Usage: /getinfo [playerid/playername]");

	new
		id,
		strHeading[54],
		strMain[550],
		tmpName[24],
		tmpColour;

	if(!sscanf(params, "d", id))
	{
		tmpName = gPlayerName[id];
		tmpColour = GetPlayerColor(id);
	}
	else if(!sscanf(params, "s[24]", tmpName))
	{
		id=GetPlayerID(tmpName);
		tmpColour = GREY;
	}
	else return Msg(playerid, YELLOW, " >  Usage: /getinfo [playerid/playername]");

	if(IsPlayerConnected(id))
	{
		strMain = FormatGenStats(id, 2);
	}
	else
	{
		new tmpFile[50];
		format(tmpFile, 50, PLAYER_DATA_FILE, tmpName);
		if(fexist(tmpFile))
		{
			strMain = FormatGenStatsFromFile(tmpFile, tmpName, 2);
		}
		else return Msg(playerid, RED, " >  User does not exist");
	}
	format(strHeading, 32, "%C%s", tmpColour, tmpName);
	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, strHeading, strMain, "Close", "");

    return 1;
}
ACMD:setname[4](playerid, params[])
{
	new
		id,
		name[24];

	if(sscanf(params, "ds[25]", id, name))
		return Msg(playerid, GREEN, " >  Usage: setname[playerid][new name]");

	if(!IsPlayerConnected(id))
		return 4;

	SetPlayerName(id, params);
	Msg(playerid, YELLOW, " >  Name Changed!");

	return 1;
}
ACMD:givegod[4](playerid, params[])
{
	new id;

	if(sscanf(params, "d", id))
		return Msg(playerid, YELLOW, "Usage /givegod [playerid]");

	MsgF(id, YELLOW, " >  %P"#C_YELLOW" Gave you godmode", playerid);
	MsgF(playerid, YELLOW, " >  You Gave %P"#C_YELLOW" godmode", id);
	bitTrue(bPlayerGameSettings[id], GodMode);

	return 1;
}
ACMD:stopgod[4](playerid, params[])
{
	new id;
	if(sscanf(params, "d", id))
		return Msg(playerid, YELLOW, "Usage /stopgod [playerid]");

	bitFalse(bPlayerGameSettings[id], GodMode);
	MsgF(playerid, YELLOW, " >  You Stopped %P"#C_YELLOW"'s godmode", id);
	SetPlayerArmour(id, 0.0);
	SetPlayerHP(id, 100.0);

	return 1;
}
ACMD:view[4](playerid, params[])
{
	new id;

	if(sscanf(params, "d", id))
		return Msg(playerid, YELLOW, " >  Usage: /view [playerid]");

	if(pAdmin(id) >= pAdmin(playerid) && playerid != id)
		return 3;

	SetPlayerMarkerForPlayer(playerid, id, ColourData[id][colour_value]);

	return 1;
}
ACMD:setscore[4](playerid, params[])
{
	new
		id,
		score;

	if(sscanf(params, "dd", id, score))
		return Msg(playerid, YELLOW, " >  Usage: /setscore [playerid] [score]");

	if(pAdmin(id) >= pAdmin(playerid) && playerid != id)
		return 3;

	if(!IsPlayerConnected(id))
		return 4;

	SetPlayerScore(id, score);
	MsgF(playerid, YELLOW, " >  You set the score of %P"#C_YELLOW" to "#C_BLUE"%d", id, score);

	return 1;
}
ACMD:godlock[4](playerid, params[])
{
	new id;

	if(sscanf(params, "d", id))
		return Msg(playerid, YELLOW, " >  Usage: /godlock [id]");

	if(pAdmin(id) >= pAdmin(playerid) && playerid != id)
		return 3;

	if(!IsPlayerConnected(id))
		return 4;

    if(bPlayerGameSettings[id]&GodLock)
	{
		MsgF(playerid, YELLOW, " >  You have unlocked %P"#C_YELLOW"'s godmode", id);
		bitFalse(bPlayerGameSettings[id], GodLock);
	}
	else
	{
		MsgF(playerid, YELLOW, " >  You have locked %P"#C_YELLOW"'s godmode", id);
		bitTrue(bPlayerGameSettings[id], GodLock);
		if(bPlayerGameSettings[id]&GodMode)bitFalse(bPlayerGameSettings[id], GodMode);
	}

	return 1;
}


//==============================================================================Server Control

ACMD:motd[4](playerid, params[])
{
	if(sscanf(params, "s[128]", gMessageOfTheDay))
		return Msg(playerid, YELLOW, " >  Usage: /motd [message]");

	MsgAllF(YELLOW, " >  MOTD updated: "#C_BLUE"%s", gMessageOfTheDay);
	file_Open(SETTINGS_FILE);
	file_SetStr("motd", gMessageOfTheDay);
	file_Save(SETTINGS_FILE);
	file_Close();

	return 1;
}
ACMD:gamename[4](playerid,params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid,YELLOW," >  Usage: /gamename [name]");

	SetGameModeText(params);
	MsgF(playerid, YELLOW, " >  GameMode name set to "#C_BLUE"%s", params);

	return 1;
}
ACMD:hostname[4](playerid,params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid,YELLOW," >  Usage: /hostname [name]");

	new str[74];
	format(str, sizeof(str), "hostname %s", params);
	SendRconCommand(str);

	MsgF(playerid, YELLOW, " >  Hostname set to "#C_BLUE"%s", params);

	return 1;
}
ACMD:mapname[4](playerid,params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid,YELLOW," >  Usage: /mapname [name]");

	SetMapName(params);

	return 1;
}
ACMD:gmx[4](playerid, params[])
{
	MsgAll(BLUE, " ");
	MsgAll(BLUE, " ");
	MsgAll(BLUE, " ");
	MsgAll(BLUE, " ");
	MsgAll(BLUE, " ");
	MsgAll(BLUE, " ");
	MsgAll(BLUE, " ");
	MsgAll(BLUE, " ");
	MsgAll(BLUE, HORIZONTAL_RULE);
	MsgAll(YELLOW, " >  The Server Is Restarting, Please Wait...");
	MsgAll(BLUE, HORIZONTAL_RULE);

	RestartGamemode();
	return 1;
}
ACMD:loadfs[4](playerid, params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid, YELLOW, " >  Usage: /loadfs [FS name]");

	new str[64];
	format(str, sizeof(str), "loadfs %s", params);
	SendRconCommand(str);
	MsgF(playerid, YELLOW, " >  Loading Filterscript: "#C_BLUE"'%s'", params);

	return 1;
}
ACMD:reloadfs[4](playerid, params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid, YELLOW, " >  Usage: /loadfs [FS name]");

	new str[64];
	format(str, sizeof(str), "reloadfs %s", params);
	SendRconCommand(str);
	MsgF(playerid, YELLOW, " >  Reloading Filterscript: "#C_BLUE"'%s'", params);

	return 1;
}
ACMD:unloadfs[4](playerid, params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid, YELLOW, " >  Usage: /loadfs [FS name]");

	new str[64];
	format(str, sizeof(str), "unloadfs %s", params);
	SendRconCommand(str);
	MsgF(playerid, YELLOW, " >  Unloading Filterscript: "#C_BLUE"'%s'", params);

	return 1;
}


//==============================================================================Server Players

ACMD:getall[4](playerid, params[])
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);

	PlayerLoop(i)
	{
		if(pAdmin(i) < pAdmin(playerid))
		{
			if(IsPlayerInAnyVehicle(playerid))
			{
			    new
					vehicleid = GetPlayerVehicleID(i),
					seat = GetPlayerVehicleSeat(i);

				SetVehiclePos(vehicleid, x, y, z);
				PutPlayerInVehicle(i, vehicleid, seat);
			}
			else SetPlayerPos(i, x, y, z);
		}
	}
	MsgAllF(YELLOW, " >  %P"#C_YELLOW" Has teleported everyone", playerid);
	return 1;
}
ACMD:disarmall[4](playerid, params[])
{
	PlayerLoop(i)ResetPlayerWeapons(i);
	MsgAllF(YELLOW, " >  %P"#C_YELLOW" Has disarmed all players", playerid);
	return 1;
}
ACMD:sethp[4](playerid, params[])
{
	new
		id,
		Float:hlth;

	if(sscanf(params, "df", id, hlth))
		return Msg(playerid, YELLOW, " >  Usage: /sethealth [playerid] [health]");

	if(pAdmin(id) >= pAdmin(playerid) && playerid != id)
		return 3;

	if(!IsPlayerConnected(id))
		return 4;

	if(!IsPlayerInFreeRoam(id))
		return Msg(playerid, RED, " >  You can only heal freeroaming players.");

	SetPlayerHP(id, hlth);
	MsgF(id, YELLOW, " >  %P"#C_YELLOW" Set Your Health To %d", playerid, floatround(hlth));
	MsgF(playerid, YELLOW, " >  You set %P"#C_YELLOW"'s health to %d", id, floatround(hlth));

	return 1;
}
ACMD:allhp[4](playerid, params[])
{
	new Float:hp;

	if(sscanf(params, "f", hp))
		return Msg(playerid, YELLOW, " >  Usage: /allhealth [health]");

	PlayerLoop(i) SetPlayerHP(i, hp);
	MsgAllF(YELLOW, " >  %P"#C_YELLOW" has set everyones health to %d", playerid, floatround(hp));

	return 1;
}
ACMD:ann[4](playerid, params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid,YELLOW," >  Usage: /ann [Message]");

	GameTextForAll(params, 5000, 5);

	return 1;
}

#undef LEVEL
