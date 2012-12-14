#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16

#include <zcmd>


#define CAM_HI_SPEED	(30.0)
#define CAM_SPEED		(10.0)
#define CAM_LO_SPEED	(3.0)

new
	cam_Active[MAX_PLAYERS],
	cam_Obj[MAX_PLAYERS];

CMD:freecam(playerid)
{
	if(cam_Active[playerid])ExitFreeCam(playerid);
	else EnterFreeCam(playerid);
	return 1;
}

CMD:freezecam(playerid)
{
	new
		Float:camX,
		Float:camY,
		Float:camZ,
		Float:vecX,
		Float:vecY,
		Float:vecZ;

	GetPlayerCameraPos(playerid, camX, camY, camZ);
	GetPlayerCameraFrontVector(playerid, vecX, vecY, vecZ);

	SetPlayerCameraPos(playerid, camX, camY, camZ);
	SetPlayerCameraLookAt(playerid, camX+vecX, camY+vecY, camZ+vecZ);
	
	return 1;
}

CMD:anm(playerid, params[])
{
    ApplyAnimation(playerid, "PED", "idle_stance", 0.0, 0, 1, 1, 1, 0);
    return 1;
}

EnterFreeCam(playerid)
{
	new
	    Float:camX,
	    Float:camY,
	    Float:camZ;

	GetPlayerCameraPos(playerid, camX, camY, camZ);

    cam_Active[playerid] = true;
	TogglePlayerControllable(playerid, true);
	SetCameraBehindPlayer(playerid);
	ApplyAnimation(playerid, "carry", "crry_prtial", 0.0, 0, 1, 1, 1, 0);

	cam_Obj[playerid] = CreateObject(19300, camX, camY, camZ, 0.0, 0.0, 0.0);
	AttachCameraToObject(playerid, cam_Obj[playerid]);
}
ExitFreeCam(playerid)
{
    cam_Active[playerid] = false;
	DestroyObject(cam_Obj[playerid]);
	SetCameraBehindPlayer(playerid);
}


public OnPlayerUpdate(playerid)
{
	if(!cam_Active[playerid])return 1;

	new
		k,
		ud,
		lr,

		Float:camX,
		Float:camY,
		Float:camZ,
		Float:vecX,
		Float:vecY,
		Float:vecZ,

		Float:angR,
//		Float:angE,
		Float:speed = CAM_SPEED;

	GetPlayerKeys(playerid, k, ud, lr);
	GetPlayerCameraPos(playerid, camX, camY, camZ);
	GetPlayerCameraFrontVector(playerid, vecX, vecY, vecZ);

	angR = atan2(vecY, vecX) - 90.0;
	if(angR<0.0)angR=360.0+angR;
//	angE = -(floatabs(atan2(floatsqroot(floatpower(vecX, 2.0) + floatpower(vecY, 2.0)), vecZ))-90.0);

	if(k&KEY_JUMP)
	{
	    speed = CAM_HI_SPEED;
	}
	if(k&KEY_WALK)
	{
	    speed = CAM_LO_SPEED;
	}

	if(ud==KEY_UP)
	{
		MoveObject(cam_Obj[playerid], camX+(vecX*100), camY+(vecY*100), camZ+(vecZ*100), speed);
	}
	if(ud==KEY_DOWN)
	{
		MoveObject(cam_Obj[playerid], camX-(vecX*100), camY-(vecY*100), camZ-(vecZ*100), speed);
	}
	if(lr==KEY_RIGHT)
	{
		MoveObject(cam_Obj[playerid], camX+(100*floatsin(angR+90.0, degrees)), camY+(100*floatcos(angR+90.0, degrees)), camZ, speed);
	}
	if(lr==KEY_LEFT)
	{
		MoveObject(cam_Obj[playerid], camX+(100*floatsin(angR-90.0, degrees)), camY+(100*floatcos(angR-90.0, degrees)), camZ, speed);
	}
	if(k&KEY_SPRINT)
	{
		MoveObject(cam_Obj[playerid], camX, camY, camZ+100.0, speed);
	}
	if(k&KEY_CROUCH)
	{
		MoveObject(cam_Obj[playerid], camX, camY, camZ-100.0, speed);
	}
	if(ud!=KEY_UP && ud!=KEY_DOWN && lr!=KEY_LEFT && lr!=KEY_RIGHT && k!=KEY_SPRINT && k!=KEY_CROUCH)StopObject(cam_Obj[playerid]);

	return 1;
}

