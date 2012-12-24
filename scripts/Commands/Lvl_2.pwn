#define LEVEL 2

new gAdminCommandList_Lvl2[] =
	{
		"/kick [id] - kick a player from the server\n\
		/(un)freeze [id] (seconds) - freeze/unfreeze a player\n\
		/(un)mute [id] (seconds) - mute/unmute a player\n\
		/dmglock [id] - Block a player from damaging others\n\
		/weplock [id] - Block a player from using weapons\n\
		/warn [id] - give a player a warning\n\
		/ej [id] - eject a player from his vehicle\n\
		/time [hour] [optional:minute] - set the server time\n\
		/weather [optional:weather id/name] - set the weather or open the weather menu\n"
	};

ACMD:kick[2](playerid, params[])
{
	new
		id,
		reason[64],
		highestAdminID;

	PlayerLoop(i)if(pAdmin(i) > pAdmin(highestAdminID)) highestAdminID = i;

	if(sscanf(params, "ds[64]", id, reason))
		return Msg(playerid, YELLOW, " >  Usage: /kick [playerid] [reason]");

	if(pAdmin(id) >= pAdmin(playerid) && playerid != id)
		return 3;

	if(!IsPlayerConnected(id))
		return 4;

	if(pAdmin(playerid)!=pAdmin(highestAdminID))
		return MsgF(highestAdminID, YELLOW, " >  %P"#C_YELLOW" Is trying to kick %P"#C_YELLOW", You are the highest online admin, it's your decision.", playerid, id);


	if(playerid == id)
		MsgAllF(PINK, " >  %P"#C_PINK" failed and kicked themselves", playerid);

	else
		MsgAllF(YELLOW, " >  %P"#C_YELLOW" Kicked %P"#C_YELLOW" Reason: %s", playerid, id, reason);

	Kick(id);

	return 1;
}
ACMD:freeze[2](playerid, params[])
{
	new id, delay;

	if(sscanf(params, "dD(0)", id, delay))
		return Msg(playerid, YELLOW, " >  Usage: /freeze [playerid] (seconds)");

	if(pAdmin(id) >= pAdmin(playerid) && playerid != id)
		return 3;

	if(!IsPlayerConnected(id))
		return 4;

	TogglePlayerControllable(id, false);
	t:bPlayerGameSettings[id]<Frozen>;
	
	if(delay > 0)
	{
	    defer CmdDelay_unfreeze(playerid, delay * 1000);
		MsgF(playerid, YELLOW, " >  Frozen %P for %d seconds", id, delay);
		MsgF(id, YELLOW, " >  %P"#C_YELLOW" has Frozen you for %d seconds", playerid, delay);
	}
	else
	{
		MsgF(playerid, YELLOW, " >  Frozen %P", id);
		MsgF(id, YELLOW, " >  %P"#C_YELLOW" has Frozen you", playerid);
	}

	return 1;
}

timer CmdDelay_unfreeze[time](playerid, time)
{
	#pragma unused time

	TogglePlayerControllable(playerid, true);
	f:bPlayerGameSettings[playerid]<Frozen>;

	Msg(playerid, YELLOW, " >  You are now unfrozen.");
}

ACMD:unfreeze[2](playerid, params[])
{
	new id;

	if(sscanf(params, "d", id))
		return Msg(playerid, YELLOW, " >  Usage: /unfreeze [playerid]");

	if(!IsPlayerConnected(id))
		return 4;

	TogglePlayerControllable(id, true);
	f:bPlayerGameSettings[id]<Frozen>;

	MsgF(playerid, YELLOW, " >  Unfrozen %P", id);
	MsgF(id, YELLOW, " >  %P"#C_YELLOW" has Unfrozen you", playerid);

	return 1;
}
ACMD:mute[2](playerid, params[])
{
	new id, reason[128], delay;


	if(sscanf(params, "ds[128]D(0)", id, reason, delay))
		return Msg(playerid,YELLOW," >  Usage: /mute [playerid] [reason] (seconds)");

	if(!IsPlayerConnected(id))
		return Msg(playerid,RED, " >  Invalid ID");

	if(pAdmin(id) >= pAdmin(playerid))
		return 3;

	if(bPlayerGameSettings[id]&Muted)
		return Msg(playerid, YELLOW, " >  Player Aready Muted");

	t:bPlayerGameSettings[id]<Muted>;

	if(delay > 0)
	{
	    defer CmdDelay_unmute(playerid, delay * 1000);
		MsgAllF(YELLOW, " >  %P"#C_YELLOW" Muted %P"#C_YELLOW" for "#C_ORANGE"%d "#C_YELLOW"seconds, Reason: %s", playerid, id, delay, reason);
	}
	else
	{
		MsgAllF(YELLOW, " >  %P"#C_YELLOW" Muted %P"#C_YELLOW", Reason: %s", playerid, id, reason);
	}

	return 1;
}

timer CmdDelay_unmute[time](playerid, time)
{
	#pragma unused time
	
	f:bPlayerGameSettings[playerid]<Muted>;

	Msg(playerid, YELLOW, " >  You are now un-muted.");

}

ACMD:unmute[2](playerid, params[])
{
	new id;

	if(sscanf(params, "d", id))
		return Msg(playerid, YELLOW, " >  Usage: /unmute [playerid]");

	if(pAdmin(id) >= pAdmin(playerid) && playerid != id)
		return 3;

	if(!IsPlayerConnected(id))
		return 4;

	f:bPlayerGameSettings[id]<Muted>;

	MsgF(playerid, YELLOW, " >  Un-muted %P", id);
	MsgF(id, YELLOW, " >  %P"#C_YELLOW" has un-muted you.", id);

	return 1;
}
ACMD:dmglock[2](playerid, params[])
{
	new id;

	if(sscanf(params, "d", id))
		return Msg(playerid, YELLOW, " >  Usage: /dmglock [playerid]");

	if(pAdmin(id) >= pAdmin(playerid) && playerid != id)
		return 3;

	if(!IsPlayerConnected(id))
		return 4;

	if(bPlayerGameSettings[id] & DmgLock)
	{
		f:bPlayerGameSettings[id]<DmgLock>;
		MsgF(playerid, YELLOW, " >  Enabled %P"#C_YELLOW"'s damage (Type again to disable)", id);
	}
	else
	{
		t:bPlayerGameSettings[id]<DmgLock>;
		MsgF(playerid, YELLOW, " >  Disabled %P"#C_YELLOW"'s damage (Type again to enable)", id);
	}

	return 1;
}

ACMD:weplock[4](playerid, params[])
{
	new id;

	if(sscanf(params, "d", id))
		return Msg(playerid, YELLOW, " >  Usage: /weplock [id]");

	if(pAdmin(id) >= pAdmin(playerid) && playerid != id)
		return 3;

	if(!IsPlayerConnected(id))
		return 4;

	if(bPlayerGameSettings[id] & WepLock)
	{
		f:bPlayerGameSettings[id]<WepLock>;
		MsgF(playerid, YELLOW, " >  You have unlocked %P"#C_YELLOW"'s weapons", id);
	}
	else
	{
		t:bPlayerGameSettings[id]<WepLock>;
		MsgF(playerid, YELLOW, " >  You have locked %P"#C_YELLOW"'s weapons", id);
	}

	return 1;
}
ACMD:warn[2](playerid, params[])
{
	new id, reason[128];

	if(sscanf(params, "ds[128]", id, reason))
		return Msg(playerid, YELLOW, " >  Usage: /warn [playerid] [reason]");

	if(!IsPlayerConnected(id))
		return Msg(playerid,RED, " >  Invalid ID");

	if(pAdmin(id) >= pAdmin(playerid) && playerid != id)
		return 3;

	Warnings[id]++;
	MsgAllF(ORANGE, "%P"#C_YELLOW" Has been warned (%d/5) for: %s", id, Warnings[id], reason);
	if(Warnings[id] >= 5)
	{
		MsgAllF(YELLOW, " >  %P"#C_YELLOW" Has been kicked for having too many warnings", id);
		Kick(id);
	}

	return 1;
}
ACMD:ej[2](playerid, params[])
{
	new id;

	if(sscanf(params, "d", id))
		return Msg(playerid, YELLOW, " >  Usage: /ej [playerid]");

	if(pAdmin(id) >= pAdmin(playerid) && playerid != id)
		return 3;

	if(!IsPlayerConnected(id))
		return 4;

	RemovePlayerFromVehicle(id);
	MsgF(playerid, YELLOW, " >  Ejected %P", id);

	return 1;
}
//==========================================================================Server Control

ACMD:time[2](playerid, params[])
{
	new hour, minute;
	if(!sscanf(params, "dD(0)", hour, minute))
	{
		if(! (0 <= hour <= 24) ) return Msg(playerid, RED, " >  Hour  must be between 0 and 24.");
		if(! (0 <= minute < 60) ) return Msg(playerid, RED, " >  Minute  must be between 0 and 59.");

		MsgAllF(YELLOW, " >  Time set to "#C_BLUE"%02d:%02d", hour, minute);
		gTimeHour = hour;
		gTimeMinute = minute;

		return 1;
	}
	else if(strlen(params) > 2)
	{
		if(!strcmp(params, "stop"))
		{
			Msg(playerid, YELLOW, " >  Time has been "#C_BLUE"stopped.");
			f:bServerGlobalSettings<ServerTimeFlow>;
			return 1;
		}
		if(!strcmp(params, "start"))
		{
			Msg(playerid, YELLOW, " >  Time has been "#C_BLUE"started.");
			t:bServerGlobalSettings<ServerTimeFlow>;
			return 1;
		}
		for(new i;i<sizeof(TimeData);i++)
		{
			if(strfind(TimeData[i][time_name], params, true) != -1)
			{
				PlayerLoop(j)
					if(!(bPlayerGameSettings[j] & InDM))
						MsgF(j, YELLOW, " >  Time set to "#C_BLUE"%s (%d:00)", TimeData[i][time_name], TimeData[i][time_hour]);

				gTimeHour = TimeData[i][time_hour];
				gTimeMinute = 0;
				return 1;
			}
		}
		Msg(playerid, RED, " >  Invalid time!");
		return 1;
	}
	Msg(playerid, YELLOW, " >  Usage: /time [Hour] [Optional:Minute]");
	return 1;
}
ACMD:weather[2](playerid, params[])
{
	new weatherid;
	if(!sscanf(params, "d", weatherid))
	{
		PlayerLoop(i)SetPlayerWeather(i, weatherid);
		MsgAllF(YELLOW, " >  Weather set to "#C_BLUE"ID:%d", weatherid);
		gWeatherID = weatherid;
		return 1;
	}
	else if(strlen(params) > 2)
	{
		for(new i;i<sizeof(WeatherData);i++)
		{
			if(strfind(WeatherData[i][weather_name], params, true) != -1)
			{
				PlayerLoop(j)
				{
					if(!(bPlayerGameSettings[j] & InDM))
					{
						SetPlayerWeather(j, WeatherData[i][weather_id]);
						MsgF(j, YELLOW, " >  Weather set to "#C_BLUE"%s", WeatherData[i][weather_name]);
					}
				}
				gWeatherID = WeatherData[i][weather_id];
				return 1;
			}
		}
		Msg(playerid, RED, " >  Invalid weather!");
		return 1;
	}

	new str[320];
	for(new x;x<sizeof(WeatherData);x++)format(str, sizeof str, "%s\n%s", str, WeatherData[x][weather_name]);
	ShowPlayerDialog(playerid, d_WeatherList, DIALOG_STYLE_LIST, "Choose a weather type", str, "Set", "Cancel");

	return 1;
}

#undef LEVEL
