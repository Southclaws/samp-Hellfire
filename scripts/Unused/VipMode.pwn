#define MAX_VIP_AREA (32)
/*
	VIP_SPAWN		= Spawn area for VIP and guards
	ATTACKER_SPAWN  = Spawn area for attackers
	VIP_DEST        = Area guards have to get VIP to
*/
new
	VipPlayer,
	VipTeam[MAX_PLAYERS],
	VipSpawnArea[MAX_VIP_AREA][3];



StartVipMatch(
{

}
SelectMatchAreas()
{
	new
		iVipSp = random(sizeof VipSpawnArea),   // initial defender spawn, chosen at random
	    aAttSp[sizeof VipSpawnArea],            // array of valid attacker spawns

		aDest[sizeof VipSpawnArea],				// array of valid destinations
		iLoop_a,								// a = attacker
		iLoop_d;								// d = destination
	for(new x;x<sizeof VipSpawnArea - 1;x++)
	{
		if (MIN_ATT_DIST <= GetDist2D(iVipSp, x) < MAX_ATT_DIST)
		{
		    aAttSp[iLoop] = x;
		    iLoop_a++;
		}
		if (MIN_DES_DIST <= GetDist2D(iVipSp, x) < MAX_DES_DIST)
		{
		    aDest[iLoop_d] = x;
		    iLoop_d++;
		}
	}
	if (iLoop_a == 0 || iLoop_d == 0) return 0; // If no valid areas were found, exit
	
}


JoinVipMatch(playerid)
{
	
}


script_VipMode_handleDialog(
{
	if(dialogid == d_VipDialog)
	{
	    if(response)
	    {
			VipTeam[playerid]=listitem;
			JoinVipMatch(playerid);
		}
	}
}
