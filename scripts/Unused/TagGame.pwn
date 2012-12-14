new
	ItPlayer = -1,
	TagGameType;

script_TagGame_TakeDamage(playerid, issuerid)
{
	if(issuerid == ItPlayer)
	{
		if(TagGameType==1)
		{
		    ResetPlayerWeapons(ItPlayer);
			GivePlayerWeapon(playerid, 33, 10000);
		}
	    ItPlayer=playerid;
	    MsgAllF(YELLOW, " >  %P"#C_YELLOW" {0000FF}is now IT!", playerid);
	}
}


StartTag(playerid, type)
{
	SetPlayerPos(playerid, 0.0+random(20), 0.0+random(20), 6.0);
	TagGameType=type;
	if(ItPlayer==-1)ItPlayer=playerid;
	if(type==1)
	{
		GivePlayerWeapon(ItPlayer, 33, 10000);
	}
}
