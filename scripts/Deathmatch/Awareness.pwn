playerSpot(playerid)
{
	if(tickcount() - tick_LastTag[playerid] < TAG_TICK)return 0;

	new
		Float:x,
		Float:y,
		Float:z;

	PlayerLoop(i)
	{
		if(i==playerid)continue;

		GetPlayerPos(i, x, y, z);
		if(IsPlayerAimingAt(playerid, x, y, z, 1.0))
		{
	    	if(bPlayerGameSettings[i] & InDM)
	    	{
	    	    tick_LastTag[playerid] = tickcount();
				if( (pTeam(i) != pTeam(playerid)) )
				{
				    if( !(bPlayerDeathmatchSettings[i] & dm_Spotted) )SpotPlayer(i, playerid);
				}
				else
				{
					CallPlayer(i, playerid);
				}
			}
		}
	}
	return 1;
}


SpotPlayer(playerid, spotterid)
{
	t:bPlayerDeathmatchSettings[playerid]<dm_Spotted>;
	UpdatePlayerIconForAll(playerid);
	tick_Spotted[playerid] = tickcount();
	flag_Spotted[playerid] = spotterid;
}
UnSpotPlayer(playerid)
{
	f:bPlayerDeathmatchSettings[playerid]<dm_Spotted>;
	UpdatePlayerIconForAll(playerid);
	tick_Spotted[playerid] = 0;
	flag_Spotted[playerid] = -1;
}


ShowPlayerForEnemy(playerid, forenemyid)
{
	SetPlayerMarkerForPlayer(forenemyid, playerid, ENEMY_PLAYER_VISIBLE);
	ShowPlayerNameTagForPlayer(forenemyid, playerid, true);
}
HidePlayerForEnemy(playerid, forenemyid)
{
	SetPlayerMarkerForPlayer(forenemyid, playerid, ENEMY_PLAYER_INVISIBLE);
	ShowPlayerNameTagForPlayer(forenemyid, playerid, false);
}
ShowPlayerNeutralForPlayer(playerid, forplayerid)
{
	SetPlayerMarkerForPlayer(forplayerid, playerid, GREEN);
	ShowPlayerNameTagForPlayer(forplayerid, playerid, false);
}


UpdatePlayerIconForAll(playerid)
{
	PlayerLoop(i)UpdatePlayerIconForPlayer(playerid, i);
	PlayerLoop(i)UpdatePlayerIconForPlayer(i, playerid);
}
UpdatePlayerIconForPlayer(playerid, forplayerid)
{
    if(!(bPlayerGameSettings[forplayerid] & InDM))ShowPlayerNeutralForPlayer(playerid, forplayerid);
    if(pTeam(playerid) == pTeam(forplayerid))
    {
		SetPlayerMarkerForPlayer(forplayerid, playerid, FRIENDLY_PLAYER_VISIBLE);
		ShowPlayerNameTagForPlayer(forplayerid, playerid, true);
    }
    else
    {
        if(bPlayerDeathmatchSettings[playerid] & dm_Spotted)ShowPlayerForEnemy(playerid, forplayerid);
        else HidePlayerForEnemy(playerid, forplayerid);
    }
}


CallPlayer(playerid, callerid)
{
	if(pKit(playerid) == KIT_SUPPORT)
	{
		MsgF(playerid, YELLOW, " >  %P"#C_BLUE" needs ammo!", callerid);
	}
	if(pKit(playerid) == KIT_MECHANIC)
	{
		MsgF(playerid, YELLOW, " >  %P"#C_BLUE" needs repair!", callerid);
	}
	if(pKit(playerid) == KIT_MEDIC)
	{
		MsgF(playerid, YELLOW, " >  %P"#C_BLUE" needs medical support!", callerid);
	}
	if(pKit(playerid) == KIT_SPECOPS)
	{
		MsgF(playerid, YELLOW, " >  %P"#C_BLUE" needs you to hack a terminal!", callerid);
	}
	if(pKit(playerid) == KIT_BOMBER)
	{
		MsgF(playerid, YELLOW, " >  %P"#C_BLUE" needs you to blow something up!", callerid);
	}
}







