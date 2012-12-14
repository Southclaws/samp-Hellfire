new
	wepTier[PLAYERS]=-1,
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



				if(dm_Mini)
				{
				    if(DMmode==5)
				    {
				    	if( (reason==22) || (reason==4) )
						{
							HasBullet[killerid]=true;
							Lives[playerid]--;
							//if(Lives[Playerid]==0)SetPlayerToSpectate
							GivePlayerWeapon(playerid, 22, 1);
							GiveXP(killerid,  10);
				    	}
				    }
				    if(DMmode==6)
				    {
						if(killerid!=INVALID_PLAYER_ID)
						{
							if(wepTier[killerid]<=15)
							{
								wepTier[killerid]++;
								setWeaponTier(killerid);
								GiveXP(killerid, 10);
							}
							if(wepTier[killerid]==15)
							{
							    Winner=killerid;
							    EndRound();
							}
						}
					}
				}
			}

