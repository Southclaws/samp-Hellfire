#define LEVEL 3

new gAdminCommandList_Lvl3[] =
	{
		"/setadmin [id] [level] - set a player's admin level\n\
		/port [id] [id] - teleport one player to another\n\
		/(un)ban - ban/unban a player from the server\n\
		/givewep [id] [weapon id/name] [optional:ammo] - give a player a weapon\n\
		/grav [float:value] - set the gravity (default/normal gravity is 0.008)\n\
		/clearchat - clear the chatbox\n\
		/allwep [weapon id/name] - give all players a weapon\n\
		/lockweps - block weapons for all freeroam players\n"
	};

ACMD:setadmin[3](playerid, params[])
{
	new
		id,
		level;

	if (sscanf(params, "dd", id, level))
		return Msg(playerid, YELLOW, " >  Usage: /setadmin [playerid] [level]");

	if(playerid == id)
		return Msg(playerid, RED, " >  You cannot set your own level");

	if(pAdmin(id) >= pAdmin(playerid) && pAdmin(playerid) < 4)
		return 3;

	if(!IsPlayerConnected(id))
		return 4;

	if(pAdmin(playerid) == 3 && level > 1)
		return Msg(playerid, RED, " >  You can only set players to levels 0 and 1");

	if(!SetPlayerAdminLevel(id, level))
		return Msg(playerid, RED, " >  Admin level must be equal to or between 0 and 4");


	MsgF(playerid, YELLOW, " >  You made %P"#C_YELLOW" a Level %d Admin", id, level);
	MsgF(id, YELLOW, " >  %P"#C_YELLOW" Made you a Level %d Admin", playerid, level);

	return 1;
}
ACMD:invis[3](playerid,params[])
{
	if(!IsPlayerInFreeRoam(playerid))
		return 2;

	bitTrue(bPlayerGameSettings[playerid], Invis);
	Msg(playerid, YELLOW, " >  You are now invisible.");

	return 1;
}
ACMD:vis[3](playerid,params[])
{
	if(!IsPlayerInFreeRoam(playerid))
		return 2;

	bitFalse(bPlayerGameSettings[playerid], Invis);
	Msg(playerid, YELLOW, " >  You are now visible.");

	return 1;
}

//==========================================================================Player Control

ACMD:port[3](playerid, params[])
{
	new
		id1,
		id2;

	if(sscanf(params, "dd", id1, id2))
		return Msg(playerid, YELLOW, " >  Usage: /tp [ID 1] [ID 2] - teleports one player to another");

	if(!IsPlayerConnected(id1) || !IsPlayerConnected(id2))
		return 4;

	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(id2, x, y, z);
	SetPlayerPos(id1, x, y, z);

	MsgF(playerid, YELLOW, " >  You teleported %P"#C_YELLOW" to %P", id1, id2);
	MsgF(id1, YELLOW, " >  You were teleported to %P", id2);
	MsgF(id2, YELLOW, " >  %P"#C_YELLOW" Was teleported to you", id1);

	return 1;
}
ACMD:ban[3](playerid, params[])
{
	new
		id = -1,
		reason[64],
		highestAdminID;

	PlayerLoop(i)if(pAdmin(i) > pAdmin(highestAdminID)) highestAdminID = i;

	if(!sscanf(params, "dS(None)[64]", id, reason))
	{
	    if(strlen(reason) > 64)
	        return Msg(playerid, RED, " >  Reason must be below 64 characters");

		if(pAdmin(id) >= pAdmin(playerid) && playerid != id)
			return 2;

		if(!IsPlayerConnected(id))
			return 4;

		if(playerid == id)
			return Msg(playerid, RED, " >  You typed your own player ID and nearly banned yourself! Now that would be embarrassing!");

		if(pAdmin(playerid)!=pAdmin(highestAdminID))
			return MsgF(highestAdminID, YELLOW, " >  %P"#C_YELLOW" Is trying to ban %P"#C_YELLOW", You are the highest online admin, it's your decision.", playerid, id);

		BanPlayer(id, reason, playerid);

		MsgAllF(YELLOW, " >  %P"#C_YELLOW" banned %P"#C_YELLOW" Reason: "#C_BLUE"%s", playerid, id, reason);

		return 1;
	}

	Msg(playerid, YELLOW, " >  Usage: /ban [playerid] [reason]");

	return 1;
}

BanPlayer(playerid, reason[], byid)
{
	new tmpQuery[256];

	format(tmpQuery, sizeof(tmpQuery), "\
		INSERT INTO `Bans`\
		(`"#ROW_NAME"`, `"#ROW_IPV4"`, `"#ROW_DATE"`, `"#ROW_REAS"`, `"#ROW_BNBY"`)\
		VALUES('%p', '%d', '%d', '%s', '%p')",
		playerid, gPlayerData[playerid][ply_IP], gettime(), reason, byid);

	print(tmpQuery);

	db_free_result(db_query(gAccounts, tmpQuery));
	Kick(playerid);
}

ACMD:unban[3](playerid, params[])
{
	new name[24];

	if(sscanf(params, "s[24]", name))
		return Msg(playerid, YELLOW, " >  Usage: /unban [player name]");

	new
	    tmpQuery[128];

	format(tmpQuery, 128, "DELETE FROM `Bans` WHERE `"#ROW_NAME"` = '%s'", name);
	
	db_free_result(db_query(gAccounts, tmpQuery));
	
	MsgF(playerid, YELLOW, " >  Banned "#C_BLUE"%s "#C_YELLOW"from the server.", name);

	return 1;
}
ACMD:givewep[3](playerid, params[])
{
	new
		id,
		weaponid,
		weaponname[32],
		ammo;

	if(sscanf(params, "ddD(0)", id, weaponid, ammo))
	{
		if(sscanf(params, "ds[32]D(0)", id, weaponname, ammo))
		    return Msg(playerid, YELLOW, " >  Usage: /givewep [playerid] [weaponid] [optional:ammo]");

		else
		{
			for(new i; i<sizeof(WepData); i++)
			{
				if(strfind(WepData[i][WepName], weaponname, true) != -1)
				{
				    weaponid = i;
					break;
				}
			}
		}
	}

	if(!IsPlayerConnected(id))
		return 4;

	if(!IsPlayerInFreeRoam(id))
		return 2;

    if(ammo == 0)ammo = WepData[weaponid][MagSize];

	GivePlayerWeapon(id, weaponid, ammo);
	MsgF(id, YELLOW, "%P"#C_YELLOW" gave you "#C_BLUE"%s with "#C_ORANGE"%d ammo", playerid, WepData[weaponid][WepName], ammo);
	MsgF(playerid, YELLOW, "you gave %P"#C_YELLOW" "#C_BLUE"%s with "#C_ORANGE"%d ammo", id, WepData[weaponid][WepName], ammo);

	return 1;
}

//==========================================================================Server Control

ACMD:grav[3](playerid, params[])
{
	new Float:grav;
	if(sscanf(params, "f", grav))
		return Msg(playerid, YELLOW, " >  Usage: /gravity [Float:Gravity]");

	SetGravity(grav);
	MsgAllF(YELLOW, " >  Gravity: %f", grav);

	return 1;
}
ACMD:clearchat[3](playerid, params[])
{
	for(new i;i<100;i++)MsgAll(WHITE, " ");
	return 1;
}
ACMD:allwep[3](playerid, params[])
{
	new
		weaponid,
		weaponname[32],
		ammo;

	if(sscanf(params, "dD(0)", weaponid, ammo))
	{
		if(sscanf(params, "s[32]D(0)", weaponname, ammo))
		    return Msg(playerid, YELLOW, " >  Usage: /allwep [weaponid] [optional:ammo]");

		else
		{
			for(new i; i<sizeof(WepData); i++)
			{
				if(strfind(WepData[i][WepName], weaponname, true) != -1)
				{
				    weaponid = i;
					break;
				}
			}
		}
	}

    if(ammo == 0)ammo = WepData[weaponid][MagSize];

	PlayerLoop(i)if(IsPlayerInFreeRoam(i))GivePlayerWeapon(i, weaponid, ammo);

	MsgAllF(YELLOW, " >  %P"#C_YELLOW" has given everyone a "#C_BLUE"%s "#C_YELLOW"with "#C_ORANGE"%d ammo!", playerid, WepData[weaponid][WepName], ammo);

	return 1;
}

ACMD:lockweps[3](playerid, params[])
{
	if(bServerGlobalSettings & WeaponLock)
	{
		f:bServerGlobalSettings<WeaponLock>;
		Msg(playerid, YELLOW, " >  Weapons Unlocked");
	}
	else
	{
		t:bServerGlobalSettings<WeaponLock>;
		Msg(playerid, YELLOW, " >  Weapons Locked");
	}
	return 1;
}


#undef LEVEL
