#define CTF_FLAG_MODEL  (1279)

new
	CtfFlag[2],
	Float:CtfPosF[2][3],
	CtfIcon;

script_Deathmatch_Pickup(playerid, pickupid)
{
	if(dm_Mode==DM_MODE_CTF)
	{
	    new
			tmpPlayerTeam=pTeam(playerid),
			tmpEnemyTeam=poTeam(playerid);

		if(pickupid == CtfFlag[tmpEnemyTeam])
		{
		    if(IsValidDynamicPickup(CtfFlag[tmpPlayerTeam]))
		    {
				if(!(bPlayerDeathmatchSettings[playerid]&dm_HasFlag))
				{
					DestroyDynamicPickup(pickupid);
					bitTrue(bPlayerDeathmatchSettings[playerid], dm_HasFlag);
					UpdateFlagIcons();

					ShowActionText(playerid, "Get the flag back to the ~n~~b~drop point!", 3000);
					MsgDeathmatchF(BLUE, " >  %P"#C_BLUE" Has picked up the Raven flag!", playerid);
					GiveXP(playerid, 10, "Flag Picked Up");
				}
			}
			return 1;
		}
		else if(pickupid == CtfFlag[tmpPlayerTeam])
		{
			if(bPlayerDeathmatchSettings[playerid]&dm_HasFlag)
			{
			    CtfFlag[tmpEnemyTeam]=CreateDynamicPickup(CTF_FLAG_MODEL, 1, CtfPosF[tmpEnemyTeam][0], CtfPosF[tmpEnemyTeam][1], CtfPosF[tmpEnemyTeam][2]);
				bitFalse(bPlayerDeathmatchSettings[playerid], dm_HasFlag);
				dm_TeamScore[score_Flags][tmpPlayerTeam]++;
				UpdateFlagIcons();
				TeamScoreUpdate();

				MsgDeathmatchF(BLUE, "%p "#C_ORANGE"Has Captured a Flag for the "#C_RED"%s"#C_ORANGE" team", playerid, dm_TeamNames[tmpPlayerTeam]);
				GiveXP(playerid, 30, "Flag Captured");
				pStatCount[playerid][st_Obj][st_CtfCaps]++;
				AwardDataUpdate(playerid, .obj=1);
			}
			else ShowActionText(playerid, "~w~This is your flag, ~r~defend it!~n~~w~If you capture an enemy flag, ~b~drop it here!", 3000);
		}
	}
	return 1;
}
UpdateFlagIcons()
{
	new
		TeamHasFlag=-1;

	PlayerLoop(i)
	{
		if(bPlayerDeathmatchSettings[i]&dm_HasFlag)
		{
			TeamHasFlag=pTeam(i);
			break;
		}
	}
	if(TeamHasFlag!=-1)
	{
	    PlayerLoop(i)if(pTeam(i)==TeamHasFlag)
	    {
			SetPlayerMapIcon(i, CtfIcon, CtfPosF[pTeam(i)][0], CtfPosF[pTeam(i)][1], CtfPosF[pTeam(i)][2], 0, BLUE, MAPICON_GLOBAL);
		}
	}
	else
	{
	    PlayerLoop(i)
	    {
			SetPlayerMapIcon(i, CtfIcon, CtfPosF[poTeam(i)][0], CtfPosF[poTeam(i)][1], CtfPosF[poTeam(i)][2], 0, RED, MAPICON_GLOBAL);
		}
	}
}

