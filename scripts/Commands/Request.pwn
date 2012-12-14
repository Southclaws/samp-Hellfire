enum E_REQUEST_TYPE
{
	REQUEST_TYPE_NULL = -1,
	REQUEST_TYPE_GOTO,
	REQUEST_TYPE_GET
}
enum E_REQUEST_DATA
{
	rq_target,
	rq_tick,
	E_REQUEST_TYPE:rq_type
}
new gPlayerRequest[MAX_PLAYERS][E_REQUEST_DATA];

CMD:goto(playerid, params[])
{
	new targetid;

	if(sscanf(params, "d", targetid))	return Msg(playerid, YELLOW, " >  Usage: /goto [playerid]");
	if(!IsPlayerConnected(targetid))	return Msg(playerid, RED, " >  Invalid ID");
	if(!IsPlayerInFreeRoam(playerid))	return 0;

	if(pAdmin(targetid) > pAdmin(playerid) || !pAdmin(playerid))
	{
	    if(!IsPlayerInFreeRoam(targetid))
	    {
	        Msg(playerid, RED, " >  That player cannot be teleported to.");
	        return 1;
	    }
		MsgF(targetid, YELLOW, " >  %P"#C_YELLOW" is requesting a teleport to you. You can "#C_BLUE"/accept "#C_YELLOW" or ignore this request.", playerid);
		MsgF(playerid, YELLOW, " >  Requesting to teleport to %P", targetid);
		gPlayerRequest[targetid][rq_target] = playerid;
		gPlayerRequest[targetid][rq_tick] = tickcount();
		gPlayerRequest[targetid][rq_type] = REQUEST_TYPE_GOTO;
	}
	else TeleportPlayerToPlayer(playerid, targetid);
	return 1;
}
CMD:get(playerid, params[])
{
	new targetid;

	if(sscanf(params, "d", targetid))	return Msg(playerid, YELLOW, " >  Usage: /get [playerid]");
	if(!IsPlayerConnected(targetid))	return Msg(playerid, RED, " >  Invalid ID");
	if(!IsPlayerInFreeRoam(playerid))	return 0;

	if(pAdmin(targetid) > pAdmin(playerid) || !pAdmin(playerid))
	{
	    if(!IsPlayerInFreeRoam(playerid))return 0;
	    if(!IsPlayerInFreeRoam(targetid))
	    {
	        Msg(playerid, RED, " >  That player cannot be teleported.");
	        return 1;
	    }
		MsgF(targetid, YELLOW, " >  %P"#C_YELLOW" is requesting you teleport to them. You can "#C_BLUE"/accept "#C_YELLOW" or ignore this request.", playerid);
		MsgF(playerid, YELLOW, " >  Requesting to teleport %P", targetid);
		gPlayerRequest[targetid][rq_target] = playerid;
		gPlayerRequest[targetid][rq_tick] = tickcount();
		gPlayerRequest[targetid][rq_type] = REQUEST_TYPE_GET;
	}
	else TeleportPlayerToPlayer(targetid, playerid);
	return 1;
}
CMD:accept(playerid, params[])
{
	if(gPlayerRequest[playerid][rq_type] == REQUEST_TYPE_NULL)
	{
	    Msg(playerid, RED, " >  Invalid request.");
	    return 1;
	}

	if(tickcount() - gPlayerRequest[playerid][rq_tick] < 10000)
    {
		if(gPlayerRequest[playerid][rq_type] == REQUEST_TYPE_GOTO)
		{
			TeleportPlayerToPlayer(gPlayerRequest[playerid][rq_target], playerid);
			gPlayerRequest[playerid][rq_target] = -1;
			gPlayerRequest[playerid][rq_tick] = 0;
			gPlayerRequest[playerid][rq_type] = REQUEST_TYPE_NULL;
		}
		else if(gPlayerRequest[playerid][rq_type] == REQUEST_TYPE_GET)
		{
			TeleportPlayerToPlayer(playerid, gPlayerRequest[playerid][rq_target]);
			gPlayerRequest[playerid][rq_target] = -1;
			gPlayerRequest[playerid][rq_tick] = 0;
			gPlayerRequest[playerid][rq_type] = REQUEST_TYPE_NULL;
		}
    }
    else Msg(playerid, RED, " >  The request has timed out.");
	return 1;
}

TeleportPlayerToPlayer(playerid, targetid)
{
	new
		Float:px,
		Float:py,
		Float:pz,
		Float:ang,
		Float:vx,
		Float:vy,
		Float:vz,
		interior=GetPlayerInterior(targetid),
		virtualworld=GetPlayerVirtualWorld(targetid);

	if(IsPlayerInAnyVehicle(targetid))
	{
		new vehicleid = GetPlayerVehicleID(targetid);

		GetVehiclePos(vehicleid, px, py, pz);
		GetVehicleZAngle(vehicleid, ang);
	    GetVehicleVelocity(vehicleid, vx, vy, vz);
	    pz += 2.0;
	}
	else
	{
		GetPlayerPos(targetid, px, py, pz);
	    GetPlayerFacingAngle(targetid, ang);
	    GetPlayerVelocity(targetid, vx, vy, vz);
	    px -= floatsin(-ang, degrees);
	    py -= floatcos(-ang, degrees);
	}

	if(IsPlayerInAnyVehicle(playerid))
	{
		new vehicleid = GetPlayerVehicleID(playerid);

		SetVehiclePos(vehicleid, px, py, pz);
		SetVehicleZAngle(vehicleid, ang);
		SetVehicleVelocity(vehicleid, vx, vy, vz);
		LinkVehicleToInterior(vehicleid, interior);
		SetVehicleVirtualWorld(vehicleid, virtualworld);
	}
	else
	{
		SetPlayerPos(playerid, px, py, pz);
		SetPlayerFacingAngle(playerid, ang);
		SetPlayerVelocity(playerid, vx, vy, vz);
		SetPlayerInterior(playerid, interior);
		SetPlayerVirtualWorld(playerid, virtualworld);
	}

	MsgF(targetid, YELLOW, " >  %P"#C_YELLOW" Has teleported to you", playerid);
	MsgF(playerid, YELLOW, " >  You have teleported to %P", targetid);
}

