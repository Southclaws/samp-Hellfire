#include <YSI\y_hooks>

/*
	Challenge:
		A global game type set by an admin that puts all connected players into
		the game, these are, Jugganaut and Marked Man.
	    
		Planned: VIP and treasure hunt
*/

new
    BankedMoney,
	MarkedMan = -1,
	Juggernaut = -1;


ACMD:markedman[4](playerid, params[])
{
    if(GetPlayersOnline() < 2)
		return Msg(playerid, RED, " >  There aren't enough players online");

	if(!IsPlayerInFreeRoam(playerid))
	    return 2;

	sscanf(params, "D(-1)", MarkedMan);

	if(MarkedMan != -1)
	{
		if(!IsPlayerConnected(MarkedMan))
			return Msg(playerid, RED, " >  Invalid ID");
	}

	ch_Load(CHALLENGE_MARKEDMAN);

	return 1;
}
ACMD:jugga[4](playerid, params[])
{
    if(GetPlayersOnline() < 2)
		return Msg(playerid, RED, " >  There aren't enough players online");

	if(!IsPlayerInFreeRoam(playerid))
	    return 2;

	sscanf(params, "D(-1)", Juggernaut);

	if(Juggernaut != -1)
	{
		if(!IsPlayerConnected(Juggernaut))
			return Msg(playerid, RED, " >  Invalid ID");
	}

	ch_Load(CHALLENGE_JUGGERNAUT);

	return 1;
}

ch_Load(ch)
{
	if(ch == CHALLENGE_MARKEDMAN)
	{
		BankedMoney = 1000;
		gCurrentChallenge = CHALLENGE_MARKEDMAN;

		MsgAll(YELLOW, " >  Marked-Man challenge started the "#C_RED"Marked Man"#C_YELLOW" is...");
	}
	if(ch == CHALLENGE_JUGGERNAUT)
	{
		BankedMoney=1000;
		gCurrentChallenge=CHALLENGE_JUGGERNAUT;

		MsgAll(YELLOW, " >  Juggernaut challenge started the "#C_RED"Juggernaut"#C_YELLOW" is...");
	}
	defer ch_Start(gCurrentChallenge);
}
timer ch_Start[3000](mg)
{
	if(mg==0)
	{
	    if(MarkedMan == -1)MarkedMan = Iter_Random(Player);
		PlayerLoop(i)
		{
	    	ToggleRaceStarts(i, false);
		    ResetPlayerWeapons(i);
			f:bPlayerGameSettings[i]<GodMode>;
			f:bPlayerGameSettings[i]<WepLock>;
			SetPlayerArmour(i, 0.0);
			if(i!=MarkedMan)
			{
				MsgF(i, YELLOW, " >  ... %P"#C_YELLOW"! Get chasing them!", MarkedMan);

				GivePlayerWeapon(i, 30, 600);
				GivePlayerWeapon(i, 22, 21);
				GivePlayerWeapon(i, 25, 48);
				
			}
			else
			{
				Msg(i, YELLOW, " >  ... "#C_BLUE"You!"#C_YELLOW" Get Running!!");

				GivePlayerWeapon(i, 31, 600);
				GivePlayerWeapon(i, 24, 21);
				GivePlayerWeapon(i, 27, 48);
			}

			SetPlayerHP(i, 100);
			SetPlayerArmour(i, 0);
		}
		StartCountdown(5, 30);
	}
	if(mg==1)
	{
	    if(Juggernaut == -1)Juggernaut = Iter_Random(Player);
		PlayerLoop(i)
		{
	    	ToggleRaceStarts(i, false);
		    ResetPlayerWeapons(i);
			f:bPlayerGameSettings[i]<GodMode>;
			f:bPlayerGameSettings[i]<WepLock>;
			SetPlayerArmour(i, 0.0);
			if(i!=Juggernaut)
			{
				MsgF(i, YELLOW, " >  ... %P"#C_YELLOW"! Watch out! They're a mean machine, but there's a prize for the killer!", Juggernaut);

				GivePlayerWeapon(i, 30, 600);
				GivePlayerWeapon(i, 22, 21);
				GivePlayerWeapon(i, 25, 48);

				SetPlayerArmour(i, 0);
			}
			else
			{
				Msg(i, YELLOW, " >  ... "#C_BLUE"You!"#C_YELLOW" Get Hunting!!");

				GivePlayerWeapon(i, 25, 48);
				GivePlayerWeapon(Juggernaut, 38, 500);

				SetPlayerHP(Juggernaut, 100);
				SetPlayerArmour(Juggernaut, 100);
			}
			SetPlayerHP(i, 100);
		}
		StartCountdown(5, 30);
	}
	f:bServerGlobalSettings<FreeroamCommands>;
}
script_Challenge_OnPlayerDeath(playerid, killerid)
{
	if(killerid == INVALID_PLAYER_ID)return 1;
	if(gCurrentChallenge == CHALLENGE_MARKEDMAN)
	{
		if(killerid == MarkedMan)
		{
			GameTextForAll("~r~The marked man fights back!", 3000, 5);
			Msg(MarkedMan, BLUE, " >  You got "#C_YELLOW"$100"#C_BLUE" bonus!");
			BankedMoney += 100;
		}
		if(playerid == MarkedMan)
		{
	        ch_Stop(killerid);
		}
	}
	else if(gCurrentChallenge == CHALLENGE_JUGGERNAUT)
	{
		if(killerid == Juggernaut)
		{
			GameTextForAll("~r~Another one bites the dust!", 3000, 5);
			Msg(Juggernaut, BLUE, " >  You got "#C_YELLOW"$100"#C_BLUE" bonus!");
			BankedMoney += 100;
		}
		if(playerid == Juggernaut)
		{
			ch_Stop(killerid);
		}
	}
	return 1;
}
hook OnPlayerSpawn(playerid)
{
	if(gCurrentChallenge == CHALLENGE_MARKEDMAN)
	{
		GivePlayerWeapon(playerid, 30, 600);
		GivePlayerWeapon(playerid, 22, 21);
		GivePlayerWeapon(playerid, 25, 48);
	}
	else if(gCurrentChallenge == CHALLENGE_JUGGERNAUT)
	{
		GivePlayerWeapon(playerid, 31, 600);
		GivePlayerWeapon(playerid, 24, 21);
		GivePlayerWeapon(playerid, 25, 48);
	}
	return 1;
}

hook OnPlayerDisconnect(playerid)
{
	if(gCurrentChallenge == CHALLENGE_MARKEDMAN)
		if(playerid == MarkedMan)ch_Stop(-2);

	if(gCurrentChallenge == CHALLENGE_JUGGERNAUT)
		if(playerid == Juggernaut)ch_Stop(-2);
}


ch_Stop(winner = -2)
{
	if(gCurrentChallenge == CHALLENGE_MARKEDMAN)
	{
		if(winner == -3)
		{
			MsgAllF(YELLOW, " >  The challenge was stopped.");
			StopCountdown();
		}
		else if(winner == -2)
	    {
			MsgAllF(YELLOW, " >  %P"#C_YELLOW" got scared and left the game!", Juggernaut);
			StopCountdown();
	    }
	    else if(winner == -1)
	    {
			GivePlayerMoney(MarkedMan, BankedMoney);
			GivePlayerScore(MarkedMan, 1);

			GameTextForAll("~r~The marked man escaped!", 3000, 5);
			MsgAllF(YELLOW, " >  %P "#C_YELLOW"escaped, and won "#C_BLUE"$%d!", MarkedMan, BankedMoney);
		}
		else
		{
			GivePlayerMoney(winner, 1000);
			GivePlayerScore(winner, 1);

			BankedMoney=0;
			StopCountdown();

			GameTextForAll("~r~The marked man is captured!", 3000, 5);
			MsgAllF(YELLOW, " >  %P "#C_YELLOW"Killed the Marked Man! reward money: "#C_BLUE"$1000", winner);
		}
		MarkedMan = -1;
	}
	else if(gCurrentChallenge == CHALLENGE_JUGGERNAUT)
	{
		if(winner == -3)
		{
			MsgAllF(YELLOW, " >  The challenge was stopped.");
			StopCountdown();
		}
	    else if(winner == -2)
	    {
			MsgAllF(YELLOW, " >  %P"#C_YELLOW" got scared and left the game!", Juggernaut, BankedMoney);
			StopCountdown();
	    }
	    else if(winner == -1)
	    {
			GivePlayerMoney(Juggernaut, BankedMoney);
			GivePlayerScore(Juggernaut, 1);

			GameTextForAll("~r~The Juggernaut survived!", 3000, 5);
			MsgAllF(YELLOW, " >  %P"#C_YELLOW" survived, and won "#C_BLUE"$%d!", Juggernaut, BankedMoney);
		}
		else
		{
			GivePlayerMoney(winner, 1000);
			GivePlayerScore(winner, 1);

			BankedMoney = 0;
			StopCountdown();

			GameTextForAll("~r~The Juggernaut was taken down!", 3000, 5);
			MsgAllF(YELLOW, " >  %P"C_YELLOW"Killed the Juggernaut! Reward money: "#C_BLUE"$1000", winner);
		}
		Juggernaut = -1;
	}
	gCurrentChallenge = CHALLENGE_NONE;
	t:bServerGlobalSettings<FreeroamCommands>;
	PlayerLoop(i)
	{
   		ToggleRaceStarts(i, true);

	    if(IsPlayerInFreeRoam(i))
	    	ResetPlayerWeapons(i);
	}
}


FormatChallengeList(playerid)
{
	ShowPlayerDialog(playerid, d_ChallengeList, DIALOG_STYLE_LIST, "Challenge", "Marked Man\nJuggernaut\nCancel", "Accept", "Info");
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_ChallengeList)
	{
		if(!strcmp(inputtext, "Cancel", true)) return 1;

		if(response)
		{
			MarkedMan = -1;
			Juggernaut = -1;
			ch_Load(listitem);
		}
		else
		{
			if(listitem == 0)
			{
				ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Marked Man",
					""#C_YELLOW"Marked Man\n\t\t\t"#C_WHITE"One player is 'marked' The first player to kill him gets a reward. But watch out, he will fight back for his own rewards!", "Close", "");
			}
			if(listitem == 1)
			{
				ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Marked Man",
					""#C_YELLOW"Juggernaut\n\t\t\t"#C_WHITE"One player is chosen to be the 'Juggernaut' other players must team up to take him down, he's heavily armed and extremely dangerous!", "Close", "");
			}
		}
	}
	return 1;
}
