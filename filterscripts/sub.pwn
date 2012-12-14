#include <a_samp>
#include <zcmd>


// Variables

new
	subObj,
	subCam,
	subDriver = -1,
	subTimer,
	Float:subVelocity = 5.0,
	Float:subHeading = 0.0,
	Float:subDistance = 50.0,
	Float:subHeight = 2.0;

// Commands

public OnFilterScriptExit()
{
	DestroyObject(subObj);
	DestroyObject(subCam);
}

CMD:makesub(playerid, params[])
{
	new Float:x, Float:y, Float:z, Float:a;
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, a);
	CreateSub(x, y, a);
	return 1;
}
CMD:pilotsub(playerid, params[])
{
	SetPlayerDriveSub(playerid);
	return 1;
}
CMD:exitsub(playerid, params[])
{
	EjectPlayerFromSub(playerid);
	return 1;
}

// Functions

CreateSub(Float:x, Float:y, Float:a)
{
	subObj = CreateObject(9958, x, y, subHeight, 0.0, 0.0, a);
	subCam = CreateObject(19300, x, y, subHeight+5.0, 0.0, 0.0, 0.0);
	AttachObjectToObject(subCam, subObj, 0.0, -4.0, 5.0, 0.0, 0.0, 0.0);
}
SetPlayerDriveSub(playerid)
{
	AttachCameraToObject(playerid, subCam);
	subTimer = SetTimer("SubKeys", 100, true);
	subDriver = playerid;
}
EjectPlayerFromSub(playerid)
{
	SetCameraBehindPlayer(playerid);
	KillTimer(subTimer);
	subDriver = -1;
}
forward SubKeys();
public SubKeys()
{
	new
		k, ud, lr;

	GetPlayerKeys(subDriver, k, ud, lr);

	if(ud==KEY_UP && subVelocity<20.0)
	{
	    subVelocity+=1.0;
	}
	if(ud==KEY_DOWN && subVelocity>0.0)
	{
	    subVelocity-=1.0;
	}
	if(lr==KEY_LEFT)
	{
	    subHeading+=1.0;
	}
	if(lr==KEY_RIGHT)
	{
	    subHeading-=1.0;
	}
	/*
	if(k&KEY_SPRINT)
	{
	    subDistance+=5.0;
	}
	if(k&KEY_CROUCH)
	{
	    subDistance-=5.0;
	}
	*/
	UpdateSubMovement();
}
UpdateSubMovement()
{
	new
		Float:x,
		Float:y,
		Float:z,
		Float:rx,
		Float:ry,
		Float:rz,
		Float:tmpRot,
		Float:tmpRoll;

	GetObjectPos(subObj, x, y, z);
	GetObjectRot(subObj, rx, ry, rz);

	tmpRot = rz - subHeading;
	tmpRoll = tmpRot*0.8;

	GetXYFromAngle(x, y, subHeading, subDistance);

	MoveObject(subObj, x, y, subHeight, subVelocity, 0.0, tmpRoll, subHeading);
}


stock GetXYFromAngle(&Float:x, &Float:y, Float:a, Float:distance)
	x+=(distance*floatsin(-a,degrees)),y+=(distance*floatcos(-a,degrees));

stock GetXYZFromAngle(&Float:x, &Float:y, &Float:z, Float:angle, Float:elevation, Float:distance)
    x += ( distance*floatsin(angle,degrees)*floatcos(elevation,degrees) ),y += ( distance*floatcos(angle,degrees)*floatcos(elevation,degrees) ),z += ( distance*floatsin(elevation,degrees) );

