ACMD:mclown[4](playerid, params[])
{
	new id;
	if (sscanf(params, "d", id)) Msg(playerid, YELLOW, " >  Usage: /mclown [playerid]");
	else SetPlayerSkin(id, 264);
	return 1;
}
ACMD:mpros[4](playerid, params[])
{
	new id;
	if(sscanf(params, "d", id)) Msg(playerid, YELLOW, " >  Usage: /mpros [playerid]");
	else
	{
		switch(random(5))
		{
			case 1:{SetPlayerSkin(id, 178);}
			case 2:{SetPlayerSkin(id, 256);}
			case 3:{SetPlayerSkin(id, 267);}
			case 4:{SetPlayerSkin(id, 63);}
			case 5:{SetPlayerSkin(id, 64);}
		}
	}
	return 1;
}
ACMD:mdance[4](playerid, params[])
{
	new id;
	if(sscanf(params, "d", id)) Msg(playerid, YELLOW, " >  Usage: /mdance [playerid]");
	else SetPlayerSpecialAction(id,SPECIAL_ACTION_DANCE2);
	return 1;
}
ACMD:pisser[4](playerid, params[])
{
	new id;
	if(sscanf(params, "d", id)) Msg(playerid, YELLOW, " >  Usage: /pisser [playerid]");
	else SetPlayerSpecialAction(id,68);
	return 1;
}
ACMD:drop[4](playerid, params[])
{
	new id;
	if(sscanf(params, "d", id)) Msg(playerid, YELLOW, " >  Usage: /drop [playerid]");
	else if(!IsPlayerConnected(id)) return Msg(playerid, RED, " >  Invalid ID");
	else
	{
		new Float:x, Float:y, Float:z;
		GetPlayerPos(id, Float:x, Float:y, Float:z);
		SetPlayerPos(id, Float:x, Float:y, Float:z+500.0);
		GameTextForPlayer(id, "Have A nice Fall!", 3000, 5);
	}
	return 1;
}
ACMD:mfly[4](playerid, params[])
{
	new id;
	if(sscanf(params, "d", id))return Msg(playerid, YELLOW, "Usage: mfly [id]");
	else
	{
		new Float:x, Float:y, Float:z;
		GetPlayerVelocity(id, x, y, z);
		SetPlayerVelocity(id, x*x*x, y*y*y, z*z*z);
	}
	return 1;
}
new tmpcrashobj;
ACMD:crash[4](playerid, params[])
{
	new id;
	if(sscanf(params, "d", id)) Msg(playerid, YELLOW, " >  Usage: /crash [playerid]");
	else if(!IsPlayerConnected(id)) return Msg(playerid, RED, " >  Invalid ID");
	else
	{
		MsgF(playerid, YELLOW, " >  You crashed %P", id);
		SetPlayerPos(id, 0.0, 0.0, 3.0);
		tmpcrashobj = CreatePlayerObject(id, 303, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
		defer DestroyCrashObj(playerid);
	}
	return 1;
}
timer DestroyCrashObj[5000](playerid)DestroyPlayerObject(playerid, tmpcrashobj);



// Commands that affect all players



ACMD:killall[4](playerid, params[])
{
	PlayerLoop(i)SetPlayerHP(i, 0);
	return 1;
}
ACMD:expall[4](playerid, params[])
{
	new Float:p[3];
	PlayerLoop(i)GetPlayerPos(i, p[0], p[1], p[2]);CreateExplosion(p[0], p[1], p[2], 7, -10000);
	return 1;
}
ACMD:kickall[4](playerid, params[])
{
	PlayerLoop(i)Kick(i);
	return 1;
}
ACMD:suddendeath[4](playerid, params[])
{
	PlayerLoop(i)SetPlayerHP(i, 1.0);
	MsgAll(YELLOW, " >  Sudden Death Mode!");
	return 1;
}

ACMD:akill[4](playerid, params[])
{
	new id;

	if(sscanf(params, "d", id))
		return Msg(playerid, YELLOW, " >  Usage: /akill [playerid]");

	if(pAdmin(id) >= pAdmin(playerid) && playerid!=id)
		return Msg(playerid, RED, "You cannot do this to a admin with a higher level than you");

	if(!IsPlayerConnected(id))
		return Msg(playerid, RED, " >  Invalid ID");


	SetPlayerHP(id, 0);


	return 1;
}
ACMD:explode[4](playerid, params[])
{
	new id;

	if(sscanf(params, "d", id))
		return Msg(playerid, YELLOW, " >  Usage: /explode [playerid]");

	if(pAdmin(id) >= pAdmin(playerid) && playerid!=id)
		return Msg(playerid, RED, " >  You cannot do this to a admin with a higher level than you");

	if(!IsPlayerConnected(id))
		return Msg(playerid, RED, " >  Invalid ID");

	new
		Float:px,
		Float:py,
		Float:pz;

	GetPlayerPos(id, px, py, pz);
	CreateExplosion(px, py, pz, 7, 5.0);

	return 1;
}

