//======================Mini Deathmatch Game Variables
new
// - Core
	bool:dm_Mini,
	Menu:m_Mdm_game,

// - One In The Chamber
	HasBullet[MAX_PLAYERS],
	Lives[MAX_PLAYERS],

//GunGame
	wepTier[MAX_PLAYERS]=-1,
	wepData[15][2]=
	{

		{22, 17*3},
		{23, 17*3},
		{24, 7*5},
		{25, 40},
		{26, 2*10},
		{27, 8*4},
		{28, 100*2},
		{32, 100*2},
		{29, 30*4},
		{33, 40},
		{30, 30*3},
		{31, 50*2},
		{34, 40},
		{35, 11},
		{37, 100}
	};
setWeaponTier(playerid)
{
	ResetPlayerWeapons(playerid);
	GivePlayerWeapon(playerid, wepData[wepTier[playerid]][0], wepData[wepTier[playerid]][1]);
}


		cmd(("/minidm"))
		{
			if(bPlayerGameSettings[playerid]&dm_Banned)Msg(playerid, RED, "**You are banned from ALL deathmatches, try following the rules next time");
			else
			{
				if(bServerGlobalSettings&DMInProgress)Msg(playerid, RED, "There is already a Deathmatch in progress");
				else
				{
					if(DMhost == -1 || DMhost == playerid)
					{
					    dm_Mini=true;
						ShowPlayerDialog(playerid, d_RegionSelect, DIALOG_STYLE_LIST, "Choose a map style category", RegionMenu, "Accept", "Info");
						TogglePlayerControllable(playerid, false);
						DMhost = playerid;
					}
					else if(playerid != DMhost)MsgF(playerid, BLUE, "%s is already starting a deathmatch", GetName(DMhost));
				}
			}
			return 1;
		}


//dmspawn
    if(!dm_Mini)
    {
		if(bDeathmatchSettings&Hardcore)SetPlayerHP(playerid, GlobalMaxHP/2);
		else SetPlayerHP(playerid, GlobalMaxHP);
		GivePlayerKitWeapons(playerid);
	}
	else
	{
	    SetPlayerHP(playerid, GlobalMaxHP/5);
		if(DMmode == 5)
		{
		    GivePlayerWeapon(playerid, 24, 1);
		    GivePlayerWeapon(playerid, 4, 1);
		    HasBullet[playerid]=true;
		    Lives[playerid]=3;
		}
		else if(DMmode == 6)
		{
			setWeaponTier(playerid);
		}
		else if(DMmode == 7)
		{
		}
		else if(DMmode == 8)
		{
		}
		else if(DMmode == 9)
		{
		}
	}


//playershoot
	if(HasBullet[playerid])HasBullet[playerid]=false;


//===============================================================Mini Deathmatch
	m_Mdm_game = CreateMenu("~b~Mini Deathmatch", 1, 32.0, 170.0, 150);
	AddMenuItem(m_Mdm_game, 0, "One in the Chamber");
	AddMenuItem(m_Mdm_game, 0, "Gun Game");
	AddMenuItem(m_Mdm_game, 0, "Sharp Shooter");
	AddMenuItem(m_Mdm_game, 0, "Timed Expedition");
	AddMenuItem(m_Mdm_game, 0, "Last Man");

