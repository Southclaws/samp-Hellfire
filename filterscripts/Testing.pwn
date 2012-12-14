#include <a_samp>
#include <zcmd>

new
    iCamTimer[MAX_PLAYERS]={-1, ...},
	igPlayerVehicle[MAX_PLAYERS],
	camType[MAX_PLAYERS],
	Float:tmpCamDist[MAX_PLAYERS];

CMD:lockcam(playerid, params[])
{
	if(iCamTimer[playerid]==-1)
	{
	    camType[playerid]=1;
	    tmpCamDist[playerid] = 10.0;
	    igPlayerVehicle[playerid] = GetPlayerVehicleID(playerid);
		iCamTimer[playerid] = SetTimerEx("CameraUpdate", 10, true, "d", playerid);
	}
	else
	{
	    camType[playerid]=0;
	    SetCameraBehindPlayer(playerid);
		KillTimer(iCamTimer[playerid]);
		iCamTimer[playerid]=-1;
	}
	return 1;
}
CMD:camdist(playerid, params[])
{
	if(sscanf(params, "f", tmpCamDist[playerid]))msg(playerid, YELLOW, "Invalid");
	msgF(playerid, YELLOW, "CamDist set to %f", tmpCamDist[playerid]);
	return 1;
}
CMD:followplayer(playerid, params[])
{
	if(iCamTimer[playerid]==-1)
	{
		new id = strval(params);
	    camType[playerid]=2;
	    tmpCamDist[playerid] = 10.0;
		igPlayerVehicle[playerid]=GetPlayerVehicleID(id);
		iCamTimer[playerid] = SetTimerEx("CameraUpdate", 100, true, "d", playerid);
	}
	else
	{
	    camType[playerid]=0;
	    SetCameraBehindPlayer(playerid);
		KillTimer(iCamTimer[playerid]);
		iCamTimer[playerid]=-1;
	}
	return 1;
}

forward CameraUpdate(playerid);
public CameraUpdate(playerid)
{
	new
		Float:fLX,
		Float:fLY,
		Float:fLZ,
		Float:a;

	if(camType[playerid]==1)
	{
		InterpolateCameraLookAt(playerid, fLX, fLY, fLZ, fLX, fLY, fLZ, 10, CAMERA_MOVE);
	}
	if(camType[playerid]==2)
	{
		GetVehiclePos(igPlayerVehicle[playerid], fLX, fLY, fLZ);
		GetVehicleZAngle(igPlayerVehicle[playerid], a);
		fLX+= (tmpCamDist[playerid]*floatsin(-a,degrees));
		fLY+= (tmpCamDist[playerid]*floatcos(-a,degrees));

		InterpolateCameraLookAt(playerid, fLX, fLY, fLZ, fLX, fLY, fLZ, 10, CAMERA_MOVE);
	}
}



new
	Float:CamPos1[3],
	Float:CamPos2[3],
	Float:CamLook1[3],
	Float:CamLook2[3];

CMD:setcampos(playerid, params[])
{
	new
		var = strval(params);
	if(var==1) GetPlayerPos(playerid, CamPos1[0], CamPos1[1], CamPos1[2]);
	else if(var==2) GetPlayerPos(playerid, CamPos2[0], CamPos2[1], CamPos2[2]);
	else msg(playerid, YELLOW, "Usage: /setcampos [1 or 2] Sets campos 1 or 2 to your current position");
	return 1;
}
CMD:setcamlook(playerid, params[])
{
	new
		var = strval(params);
	if(var==1) GetPlayerPos(playerid, CamLook1[0], CamLook1[1], CamLook1[2]);
	else if(var==2) GetPlayerPos(playerid, CamLook2[0], CamLook2[1], CamLook2[2]);
	else msg(playerid, YELLOW, "Usage: /setcamlook [1 or 2] Sets camlookat 1 or 2 to your current position");
	return 1;
}
CMD:movecam(playerid, params[])
{
	new tmpTime = strval(params);
	InterpolateCameraPos(playerid, CamPos1[0], CamPos1[1], CamPos1[2], CamPos2[0], CamPos2[1], CamPos2[2], tmpTime, CAMERA_MOVE);
	InterpolateCameraLookAt(playerid, CamLook1[0], CamLook1[1], CamLook1[2], CamLook2[0], CamLook2[1], CamLook2[2], tmpTime, CAMERA_MOVE);
	return 1;
}




new
	Float:ttelevation = 45.0,
	Float:ttrotation = 90.0,
	Float:ttdistance = 10.0,

	cameraobject,

	Float:ttox,
	Float:ttoy,
	Float:ttoz;

CMD:makeit(playerid, params[])
{
	GetPlayerPos(playerid, ttox, ttoy, ttoz);
	cameraobject = CreateObject(19300, ttox, ttoy, ttoz, 0.0, 0.0, 0.0);
	AttachCameraToObject(playerid, cameraobject);
	return 1;
}
stock script_CamMover_OnUpdate2(playerid)
{
	new
		Float:camX,
		Float:camY,
		Float:camZ,
		Float:vecX,
		Float:vecY,
		Float:vecZ,

		k, ud, lr;

	GetPlayerKeys(playerid, k, ud, lr);
	GetPlayerCameraPos(playerid, camX, camY, camZ);
	GetPlayerCameraFrontVector(playerid, vecX, vecY, vecZ);

	ttrotation = 90-(atan2(vecY, vecX));
	if(ttrotation<0.0)ttrotation=360.0+ttrotation;
	ttelevation = -(floatabs(atan2(floatsqroot(floatpower(vecX, 2.0) + floatpower(vecY, 2.0)), vecZ))-90.0);


	if(ud==KEY_UP)
	{
		GetXYZFromAngle(camX, camY, camZ, ttrotation, ttelevation, ttdistance);
		MoveObject(cameraobject, camX, camY, camZ, 10.0);
	}
	if(ud==KEY_DOWN)
	{
		GetXYZFromAngle(camX, camY, camZ, ttrotation, ttelevation, -ttdistance);
		MoveObject(cameraobject, camX, camY, camZ, 10.0);
	}
	if(lr==KEY_LEFT)
	{
		GetXYFromAngle(camX, camY, 270, -ttdistance);
		MoveObject(cameraobject, camX, camY, camZ, 10.0);
	}
	if(lr==KEY_RIGHT)
	{
		GetXYFromAngle(camX, camY, 90, -ttdistance);
		MoveObject(cameraobject, camX, camY, camZ, 10.0);
	}
	if(ud!=KEY_UP && ud!=KEY_DOWN && lr!=KEY_LEFT && lr!=KEY_RIGHT)StopObject(cameraobject);
}
CMD:fps(playerid, params[])
{
	AttachObjectToPlayer(cameraobject, playerid, 0.0, 0.0, 0.65, 0.0, 0.0, 0.0);
	return 1;
}
CMD:setz(playerid, params[])
{
	new Float:zval;
	sscanf(params, "f", zval);
	AttachObjectToPlayer(cameraobject, playerid, 0.0, 0.0, zval, 0.0, 0.0, 0.0);
	return 1;
}

























enum ob_data{ob_id,ob_name[20]}
new objects_ParticleFX[][ob_data]=
{
	{18668,	"blood_heli"},
	{18669,	"boat_prop"},
	{18670,	"camflash"},
	{18671,	"carwashspray"},
	{18672,	"cementp"},
	{18673,	"cigarette_smoke"},
	{18674,	"cloudfast"},//
	{18675,	"coke_puff"},
	{18676,	"coke_trail"},
	{18677,	"exhale"},
	{18678,	"explosion_barrel"},
	{18679,	"explosion_crate"},
	{18680,	"explosion_door"},//
	{18681,	"explosion_fuel_car"},
	{18682,	"explosion_large"},
	{18683,	"explosion_medium"},
	{18684,	"explosion_molotov"},
	{18685,	"explosion_small"},
	{18686,	"explosion_tiny"},
	{18687,	"extinguisher"},
	{18688,	"fire"},//
	{18689,	"fire_bike"},
	{18690,	"fire_car"},
	{18691,	"fire_large"},
	{18692,	"fire_med"},//
	{18693,	"Flame99"},
	{18694,	"flamethrower"},//
	{18695,	"gunflash"},
	{18696,	"gunsmoke"},
	{18697,	"heli_dust"},
	{18698,	"insects"},
	{18699,	"jetpack"},
	{18700,	"jetthrust"},
	{18701,	"molotov_flame"},
	{18702,	"nitro"},
	{18703,	"overheat_car"},
	{18704,	"overheat_car_elec"},//
	{18705,	"petrolcan"},
	{18706,	"prt_blood"},
	{18707,	"prt_boatsplash"},
	{18708,	"prt_bubble"},
	{18709,	"prt_cardebris"},
	{18710,	"prt_collisionsmoke"},
	{18711,	"prt_glass"},
	{18712,	"prt_gunshell"},
	{18713,	"prt_sand2"},
	{18714,	"prt_sand"},
	{18715,	"prt_smoke_huge"},
	{18716,	"prt_smoke_expand"},
	{18717,	"prt_spark"},//
	{18718,	"prt_spark_2"},//
	{18719,	"prt_wake"},
	{18720,	"prt_watersplash"},
	{18721,	"prt_wheeldirt"},
	{18722,	"puke"},
	{18723,	"riot_smoke"},
	{18724,	"shootlight"},
	{18725,	"smoke30lit"},
	{18726,	"smoke30m"},
	{18727,	"smoke50lit"},
	{18728,	"smoke_flare"},
	{18729,	"spraycan"},
	{18730,	"tank_fire"},
	{18731,	"teargas99"},
	{18732,	"teargasAD"},
	{18733,	"18747"},
	{18748,	"WS_factorysmoke"}
};

CMD:makeob(playerid, params[])
{
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	for(new i;i<sizeof(objects_ParticleFX);i++)
	{
	    if(!strcmp(params, objects_ParticleFX[i][ob_name]))
	    {
	        CreateDynamicObject(objects_ParticleFX[i][ob_id], x, y, z, 0.0, 0.0, 0.0);
	        Streamer_Update(playerid);
	    }
	}
	return 1;
}

















