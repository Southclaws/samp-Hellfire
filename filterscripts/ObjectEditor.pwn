#include <a_samp>
#include <YSI\y_va>
#include <formatex>
#include "../scripts/System/PlayerFunctions.pwn"
#include <zcmd>
#include <sscanf2>
#include <streamer>
#include <colours>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16

#define OBJECT_FILE "savedobjects.txt"

new
    editingObj[MAX_PLAYERS],
	editObj,
	Float:objX,
	Float:objY,
	Float:objZ,
	Float:objRX,
	Float:objRY,
	Float:objRZ,
	
	Float:speed = 0.01,
	Float:fast = 1.0,

	Float:camAngle = 270.0,
	Float:camDist = 4.0;

public OnFilterScriptInit()
{
/*
	new
		File:f,
		str[180],
		m;

	f = fopen(OBJECT_FILE, io_read);

	while(fread(f, str))
	{
	    print(str);
	    if(!sscanf(str, "p<(>{s[20]}p<,>dfffffp<)>f{s[4]}", m, objX, objY, objZ, objRX, objRY, objRZ))
	    {
			SetDynamicObjectMaterial(
				CreateDynamicObject(m, objX, objY, objZ, objRX, objRY, objRZ),
				0, 3942, "bistro", "mp_snow", 0);
	    }
	}
	fclose(f);
*/
}

CMD:addobj(playerid, params[])
{
	new
		world = GetPlayerVirtualWorld(playerid),
		interior = GetPlayerInterior(playerid);

	GetPlayerPos(playerid, objX, objY, objZ);
	GetPlayerFacingAngle(playerid, objRZ);

	objX += floatsin(-objRZ, degrees);
	objY += floatcos(-objRZ, degrees);
	objRZ += 90.0;


	editObj = CreateDynamicObject(19475, objX, objY, objZ, objRX, objRY, objRZ, world, interior, playerid);
	SetDynamicObjectMaterialText(editObj, 0, "system:\n  >", OBJECT_MATERIAL_SIZE_512x512, "Courier New", 30, 1, -1, 0, 0);
	TogglePlayerControllable(playerid, false);
	editingObj[playerid] = true;
	
	SetTimerEx("Update", 50, true, "d", playerid);
	
	return 1;
}

CMD:saveobj(playerid, params[])
{
	new
		File:f,
		str[128];
	
	if(!fexist(OBJECT_FILE))f = fopen(OBJECT_FILE, io_write);
	else f = fopen(OBJECT_FILE, io_append);

	format(str, 128, "CreateObject(19477, %f, %f, %f, %f, %f, %f);\r\n",
		objX, objY, objZ, objRX, objRY, objRZ);
	fwrite(f, str);
	
	fclose(f);
	
	editingObj[playerid] = false;
	SetCameraBehindPlayer(playerid);
	TogglePlayerControllable(playerid, true);
	
	return 1;
}

CMD:mspeed(playerid, params[])
{
	speed = floatstr(params);
	return 1;
}
CMD:mult(playerid, params[])
{
	fast = floatstr(params);
	return 1;
}
CMD:camdis(playerid, params[])
{
	camDist = floatstr(params);
	return 1;
}
forward Update(playerid);
public Update(playerid)
{
	if(!editingObj[playerid])return 1;

	new
		k, ud, lr;

	GetPlayerKeys(playerid, k, ud, lr);
	
	if(k & KEY_JUMP)speed = fast;
	else speed = 0.01;

	if(k & KEY_FIRE)
	{
		if(ud == KEY_UP)objRX+=1.0*speed;
		else if(ud == KEY_DOWN)objRX-=1.0*speed;

		if(lr == KEY_RIGHT)objRZ+=1.0*speed;
		else if(lr == KEY_LEFT)objRZ-=1.0*speed;

		if(k == KEY_SPRINT)objRY+=1.0*speed;
		else if(k == KEY_CROUCH)objRY-=1.0*speed;

		SetDynamicObjectRot(editObj, objRX, objRY, objRZ);
	}
	else
	{
		if(ud == KEY_UP)
		{
			objX -= speed * floatsin(-objRZ+camAngle, degrees);
			objY -= speed * floatcos(-objRZ+camAngle, degrees);
		}
		else if(ud == KEY_DOWN)
		{
			objX += speed * floatsin(-objRZ+camAngle, degrees);
			objY += speed * floatcos(-objRZ+camAngle, degrees);
		}

		if(lr == KEY_RIGHT)
		{
			objX -= speed * floatsin(-objRZ+camAngle+90.0, degrees);
			objY -= speed * floatcos(-objRZ+camAngle+90.0, degrees);
		}
		else if(lr == KEY_LEFT)
		{
			objX += speed * floatsin(-objRZ+camAngle+90.0, degrees);
			objY += speed * floatcos(-objRZ+camAngle+90.0, degrees);
		}

		if(k == KEY_SPRINT)
		{
			objZ += 1.0 * speed;
		}
		else if(k == KEY_CROUCH)
		{
			objZ -= 1.0 * speed;
		}

		SetDynamicObjectPos(editObj, objX, objY, objZ);
	}
	
	if(k == KEY_ANALOG_RIGHT)camAngle+=10.0;
	else if(k == KEY_ANALOG_LEFT)camAngle-=10.0;

	if(k == KEY_YES)camDist+=1.0;
	else if(k == KEY_NO)camDist-=1.0;


	SetPlayerCameraPos(playerid,
		objX+camDist*floatsin(-objRZ+camAngle, degrees),
		objY+camDist*floatcos(-objRZ+camAngle, degrees),
		objZ);

	SetPlayerCameraLookAt(playerid, objX, objY, objZ);


	new
	    Float:x,
	    Float:y,
	    Float:z;

	GetPlayerPos(playerid, x, y, z);
	SetPlayerPos(playerid, x, y, z);

	return 1;
}
