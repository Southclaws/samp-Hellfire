#define FILTERSCRIPT

#include <a_samp>
#include <ZCMD>


new
	tick_keyTapR[MAX_PLAYERS],
	tick_keyTapL[MAX_PLAYERS],
	tick_useRoll[MAX_PLAYERS],
	key_LeftRight[MAX_PLAYERS],

	tick_keyJump[MAX_PLAYERS],
	tick_dive[MAX_PLAYERS],
	tick_dropkick[MAX_PLAYERS];

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerInAnyVehicle(playerid))return 1;

	if(newkeys & KEY_JUMP)
	{
		new animidx = GetPlayerAnimationIndex(playerid);
		switch(animidx)
		{
			case 1189, 1266, 1231, 1195, 1196, 1197:
			{
				if(tickcount() - tick_keyJump[playerid] < 250)
				{
					ApplyAnimation(playerid, "PED", "EV_dive", 4.0, 0, 1, 1, 1, 0);
					tick_dive[playerid] = tickcount();
				}
				tick_keyJump[playerid] = tickcount();
			}
		}
	}
	if(newkeys & KEY_SPRINT)
	{
		if(tickcount() - tick_dive[playerid] > 2000 && GetPlayerAnimationIndex(playerid) == 1120)
		{
			new Float:a;

			GetPlayerFacingAngle(playerid, a);
			SetPlayerFacingAngle(playerid, a-90.0);
			ApplyAnimation(playerid, "PED", "GETUP_FRONT", 4.0, 0, 1, 1, 0, 0);
		}
	}
	if(newkeys & KEY_FIRE)
	{
		new animidx = GetPlayerAnimationIndex(playerid);
		switch(animidx)
		{
			case 1189, 1266, 1231, 1195, 1196, 1197:
			{
				if(tickcount() - tick_keyJump[playerid] < 1000)
				{
					new k, ud, lr;
					GetPlayerKeys(playerid, k, ud, lr);
					if(k & KEY_JUMP)
					{
						ApplyAnimation(playerid, "FIGHT_C", "FightC_M", 4.0, 0, 1, 1, 0, 0);
					}
					tick_dropkick[playerid] = tickcount();
				}
			}
		}
	}
	
	return 1;
}

public OnPlayerUpdate(playerid)
{
	if(IsPlayerInAnyVehicle(playerid))return 1;

	new k, ud, lr;
	GetPlayerKeys(playerid, k, ud, lr);
	
	
	if(lr & KEY_LEFT && !(key_LeftRight[playerid] & KEY_LEFT))
		OnPlayerLeftRightChange(playerid, lr);

	if(!(lr & KEY_RIGHT) && key_LeftRight[playerid] & KEY_RIGHT)
		OnPlayerLeftRightChange(playerid, lr);

	key_LeftRight[playerid] = lr;

	return 1;
}

OnPlayerLeftRightChange(playerid, newlr)
{
	new animidx = GetPlayerAnimationIndex(playerid);

	if(animidx != 1189 && animidx != 1266 && animidx != 1231)
	    return 0;

	if(newlr == KEY_LEFT)
	{
		if(tickcount() - tick_keyTapL[playerid] < 250)
		    PlayerRoll(playerid, 0);

		tick_keyTapL[playerid] = tickcount();
	}
	if(newlr == KEY_RIGHT)
	{
		if(tickcount() - tick_keyTapR[playerid] < 250)
		    PlayerRoll(playerid, 1);

		tick_keyTapR[playerid] = tickcount();
	}
	
	return 1;
}

PlayerRoll(playerid, direction)
{
	if(tickcount() - tick_useRoll[playerid] < 1000)
		return 0;

	new Float:a;

	GetPlayerFacingAngle(playerid, a);

	if(direction == 0)
	{
		ApplyAnimation(playerid, "PED", "CROUCH_ROLL_L", 4.5, 0, 1, 1, 0, 0, 1);
		SetPlayerFacingAngle(playerid, a-60.0);
	}
	else
	{
		ApplyAnimation(playerid, "PED", "CROUCH_ROLL_R", 4.5, 0, 1, 1, 0, 0, 1);
		SetPlayerFacingAngle(playerid, a+60.0);
	}

    tick_useRoll[playerid] = tickcount();

    return 1;
}

