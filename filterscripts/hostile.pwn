#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16

#include "../scripts/Resources/WeaponResources.pwn"
#include "../scripts/System/Functions.pwn"
#include "../scripts/System/MathFunctions.pwn"
#include "../scripts/System/PlayerFunctions.pwn"

#include <YSI\y_timers>
#include <foreach>
#include <formatex>
#include <zcmd>
#include <streamer>
#include <colours>
#include <RNPC>


#define SetSpawn(%0,%1,%2,%3,%4)	SetSpawnInfo(%0, NO_TEAM, 0, %1, %2, %3, %4, 0,0,0,0,0,0)


new
	Float:gNpcIdlePos[3][4]=
	{
		{-2805.0747, -1515.7370, 140.8359, 265.4249},
		{-2803.7458, -1518.4135, 139.2890, 265.4681},
		{-2803.9814, -1517.0273, 139.2890, 265.4681}
	},
	gNpcName[3][24]=
	{
	    {"Marty"},
	    {"John"},
	    {"Carl"}
	},
	gNpcSkin[3]=
	{
		158,
		133,
		159
	},
	Float:gNpcProx[3]=
	{
	    -2803.9106, -1517.6843, 139.2890
	},
	gNpcWeapon[3]=
	{
	    24,
	    25,
	    33
	};

new
    gNpcId[3],
	gArea,
	gNpcSmokes,
	gNpcLastAction,
	bool:gNpcBusy,
	bool:gNpcAttacking,
	gNpcHealth[3] = {5, 5, 5};

new
	Timer:gAnimTimer_Init,

	Timer:gAnimTimer_IdleLoopLong,
	Timer:gAnimTimer_IdleLoopNormal,
	Timer:gAnimTimer_IdleLoopShort,

	Timer:gAnimTimer_Smoke,
	Timer:gAnimTimer_TapSmoke,

	Timer:gAnimTimer_PutSmokeOut,
	Timer:gAnimTimer_NewSmoke,


	Timer:gAction_AttackTimer,
	Timer:gAction_AttackUpdate;


public OnFilterScriptInit()
{
	defer load();
}
timer load[5000]()
{
	gNpcId[0] = ConnectRNPC(gNpcName[0]);
	gNpcId[1] = ConnectRNPC(gNpcName[1]);
	gNpcId[2] = ConnectRNPC(gNpcName[2]);

	gArea = CreateDynamicSphere(gNpcProx[0], gNpcProx[1], gNpcProx[2], 10.0, 0, 0);
	return 1;
}
public OnFilterScriptExit()
{
	Kick(gNpcId[0]);
	Kick(gNpcId[1]);
	Kick(gNpcId[2]);
}

public OnPlayerConnect(playerid)
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetSpawn(playerid, -907.5452, 272.7235, 1014.1449, 0.0);

	return 0;
}
public OnPlayerRequestSpawn(playerid)
{
	SetSpawn(playerid, -907.5452, 272.7235, 1014.1449, 0.0);

	return 1;
}

public OnPlayerSpawn(playerid)
{
	new name[24];

	GetPlayerName(playerid, name, 24);

	for(new i;i<3;i++)
	{
		if(!strcmp(name, gNpcName[i]))
		{
			gNpcId[i] = playerid;
			
			defer Init(playerid, i);
		}
	}
}

timer Init[5000](playerid, i)
{
	SetPlayerSkin(playerid, gNpcSkin[i]);
	SetPlayerPos(playerid, gNpcIdlePos[i][0], gNpcIdlePos[i][1], gNpcIdlePos[i][2]);
	SetPlayerFacingAngle(playerid, gNpcIdlePos[i][3]);

	gAnimTimer_Init = defer AnimTimer(i);
}

timer AnimTimer[3000](i)
{
	SetPlayerPos(gNpcId[i], gNpcIdlePos[i][0], gNpcIdlePos[i][1], gNpcIdlePos[i][2]);
	SetPlayerFacingAngle(gNpcId[i], gNpcIdlePos[i][3]);
	if(i == 0)
	{
		gNpcBusy = false;
		ApplyAnimation(gNpcId[i], "SMOKING", "M_smk_in", 4.0, 0, 0, 0, 0, 0, 1);
	    gAnimTimer_IdleLoopLong = defer Anim_IdleLoopLong(gNpcId[i]);
	}
	if(i == 1)
	{
		ApplyAnimation(gNpcId[i], "SMOKING", "M_smkstnd_loop", 4.0, 1, 0, 0, 0, 0, 1);
	}
	if(i == 2)
	{
		ApplyAnimation(gNpcId[i], "GANGS", "leanIDLE", 4.0, 1, 0, 0, 0, 0, 1);
	}
}
timer Anim_IdleLoopLong[3800](id)
{
    if(gNpcBusy)return 0;
	Anim_IdleLoop(id);
	return 1;
}
timer Anim_IdleLoopNormal[3000](id)
{
    if(gNpcBusy)return 0;
    Anim_IdleLoop(id);
	return 1;
}
timer Anim_IdleLoopShort[1800](id)
{
    if(gNpcBusy)return 0;
    Anim_IdleLoop(id);
	return 1;
}
Anim_IdleLoop(id)
{
	if(gNpcBusy)return 0;
	ApplyAnimation(id, "SMOKING", "M_smk_loop", 4.0, 1, 0, 0, 0, 0);
	if(gNpcLastAction == 1)
	{
	    gAnimTimer_TapSmoke = defer Anim_TapSmoke(id);
	    gNpcLastAction = 0;
	}
	else
	{
		gAnimTimer_Smoke = defer Anim_Smoke(id);
		gNpcLastAction = 1;
	}
	return 1;
}

timer Anim_Smoke[5000](id)
{
    if(gNpcBusy)return 0;
	gNpcSmokes++;
	if(gNpcSmokes >= 3+random(3))
	{
	    gAnimTimer_PutSmokeOut = defer Anim_PutSmokeOut(id);
	}
	else
	{
		ApplyAnimation(id, "SMOKING", "M_smk_drag", 4.0, 0, 0, 0, 0, 0);
		gAnimTimer_IdleLoopNormal = defer Anim_IdleLoopNormal(id);
	}
	return 1;
}
timer Anim_TapSmoke[3600](id)
{
    if(gNpcBusy)return 0;
	ApplyAnimation(id, "SMOKING", "M_smk_tap", 4.0, 0, 0, 0, 0, 0);
	gAnimTimer_IdleLoopShort = defer Anim_IdleLoopShort(id);
	return 1;
}
timer Anim_PutSmokeOut[2000](id)
{
    if(gNpcBusy)return 0;
	ApplyAnimation(id, "SMOKING", "M_smk_out", 4.0, 0, 0, 0, 0, 0);
	gAnimTimer_NewSmoke = defer Anim_NewSmoke(id);
	return 1;
}
timer Anim_NewSmoke[5000](id)
{
    if(gNpcBusy)return 0;
	ApplyAnimation(id, "SMOKING", "M_smk_in", 4.0, 0, 0, 0, 0, 0);
	gAnimTimer_IdleLoopLong = defer Anim_IdleLoopLong(id);
	return 1;
}

Anim_Cancel(id)
{
	if(id == gNpcId[0])
	{
		stop gAnimTimer_Init;

		stop gAnimTimer_IdleLoopLong;
		stop gAnimTimer_IdleLoopNormal;
		stop gAnimTimer_IdleLoopShort;

		stop gAnimTimer_Smoke;
		stop gAnimTimer_TapSmoke;

		stop gAnimTimer_PutSmokeOut;
		stop gAnimTimer_NewSmoke;
		gNpcBusy = true;
	}

	ClearAnimations(id);
}

public OnPlayerEnterDynamicArea(playerid, areaid)
{
	if(areaid == gArea && !gNpcAttacking)
	{
	    Anim_Cancel(gNpcId[1]);
	    Anim_Cancel(gNpcId[2]);

		msgbox(playerid, "We don't like you're type around here!", 3000, 140);

		gAction_AttackTimer = defer Action_AttackPlayer(playerid);

	}
}

timer Action_AttackPlayer[3000](playerid)
{
    Anim_Cancel(gNpcId[1]);
    Anim_Cancel(gNpcId[2]);

    gNpcAttacking = true;
	msgbox(playerid, "I warned you!~n~Eat lead!", 3000, 140);
	gAction_AttackUpdate = repeat Action_AttackPlayerUpdate(playerid);
	return 1;
}

timer Action_AttackPlayerUpdate[1000](playerid)
{
	new
	    Float:x,
	    Float:y,
	    Float:z,
		Float:ang,
		Float:npc_x,
		Float:npc_y,
		Float:npc_z,
		Float:npc_rot;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, ang);


	GetPlayerPos(gNpcId[1], npc_x, npc_y, npc_z);
	SetPlayerPos(gNpcId[1], npc_x, npc_y, npc_z);
	npc_rot = GetAngleToPoint(npc_x, npc_y, x, y);
	NpcShootAt(gNpcId[1], npc_rot, gNpcWeapon[1]);

	GetPlayerPos(gNpcId[2], npc_x, npc_y, npc_z);
	GetPlayerPos(gNpcId[2], npc_x, npc_y, npc_z);
	npc_rot = GetAngleToPoint(npc_x, npc_y, x, y);
	NpcShootAt(gNpcId[2], npc_rot, gNpcWeapon[2]);

	return 1;
}

NpcShootAt(npcid, Float:rotation, weapon)
{
	RNPC_CreateBuild(npcid, PLAYER_RECORDING_TYPE_ONFOOT);

	RNPC_SetWeaponID(weapon);
	RNPC_SetKeys(128 + 4);
    RNPC_SetAngleQuats(0.0, rotation, 0.0);
	RNPC_AddPause(1000);
	RNPC_SetKeys(0);

	RNPC_FinishBuild();

	RNPC_StartBuildPlayback(npcid); 
}

public OnPlayerLeaveDynamicArea(playerid, areaid)
{
	if(areaid == gArea && !gNpcAttacking)
	{
	    stop gAction_AttackTimer;
	    stop gAction_AttackUpdate;

		gAnimTimer_Init = defer AnimTimer(1);
		gAnimTimer_Init = defer AnimTimer(2);
	}
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & 4)
	{
	    new wepState = GetPlayerWeaponState(playerid);
	    if(wepState != WEAPONSTATE_NO_BULLETS && wepState != WEAPONSTATE_RELOADING)
	    {
	        new Float:x, Float:y, Float:z;

	        GetPlayerPos(gNpcId[0], x, y, z);
	        if(IsPlayerAimingAt(playerid, x, y, z, 1.0) && gNpcAttacking)
	        {
	            gNpcHealth[0]--;
	            if(gNpcHealth[0] <= 0)NpcKill(gNpcId[0]);
	        }

	        GetPlayerPos(gNpcId[1], x, y, z);
	        if(IsPlayerAimingAt(playerid, x, y, z, 1.0) && gNpcAttacking)
	        {
	            gNpcHealth[1]--;
	            if(gNpcHealth[1] <= 0)ApplyAnimation(gNpcId[1], "PED", "KO_shot_front", 4.0, 0, 0, 0, 1, 0, 1);
	        }

	        GetPlayerPos(gNpcId[2], x, y, z);
	        if(IsPlayerAimingAt(playerid, x, y, z, 1.0) && gNpcAttacking)
	        {
	            gNpcHealth[2]--;
	            if(gNpcHealth[2] <= 0)ApplyAnimation(gNpcId[2], "PED", "KO_shot_front", 4.0, 0, 0, 0, 1, 0, 1);
	        }
	    }
	}
}

NpcKill(id)
{
	ApplyAnimation(gNpcId[id], "PED", "KO_shot_front", 4.0, 0, 0, 0, 1, 0, 1);
	stop gAction_AttackTimer;
	stop gAction_AttackUpdate;
	gNpcAttacking = false;
}


stock msgbox(playerid, msg[], time = 0, width = 150)
{
    CallRemoteFunction("sffa_msgbox", "dsdd", playerid, msg, time, width);
}


