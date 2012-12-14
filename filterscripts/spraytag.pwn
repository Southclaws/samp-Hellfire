#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16

#include <streamer>
#include <foreach>
#include <YSI\y_timers>
#include <playerbar>
#include "../scripts/System/Functions.pwn"
#include "../scripts/Resources/WeaponResources.pwn"

#define MAX_SPRAYTAG 16

enum E_SPRAYTAG_DATA
{
	spt_objID,
	spt_areaID,
	spt_text[24],
	Float:spt_posX,
	Float:spt_posY,
	Float:spt_posZ,
	Float:spt_rotX,
	Float:spt_rotY,
	Float:spt_rotZ
}

new
	spt_Data[MAX_SPRAYTAG][E_SPRAYTAG_DATA],
	Iterator:spt_Iterator<MAX_SPRAYTAG>,

    PlayerBar:spt_SprayBar,
	spt_Spraying[MAX_PLAYERS],
	Timer:spt_SprayTimer[MAX_PLAYERS];

forward SprayTag(playerid, tagid);

public OnFilterScriptInit()
{
	print("\n - Spraytags Loaded\n");

	for(new i;i<MAX_PLAYERS;i++)
	{
		spt_Spraying[i] = -1;

	    if(IsPlayerConnected(i))
			spt_SprayBar = CreatePlayerProgressBar(i, 291.0, 345.0, 57.50, 5.19, 0x5F13FFFF, 5.0);
	}

	AddSprayTag(1172.8808, -1313.0510, 14.2463, 10.0, 0.0, 180.0);
	AddSprayTag(1237.39, -1631.60, 28.02, 0.00, 0.00, 91.00);
	AddSprayTag(1118.51, -1540.14, 24.66, 0.00, 0.00, 178.46);
	AddSprayTag(1202.11, -1201.55, 20.47, 0.00, 0.00, 90.00);
	AddSprayTag(1264.15, -1270.28, 15.16, 0.00, 0.00, 270.00);
	AddSprayTag(-399.77, 1514.92, 76.96, 0.00, 0.00, 0.00);
	AddSprayTag(-2442.17, 2299.23, 5.71, 0.00, 0.00, 270.00);
	AddSprayTag(-2662.95, 2121.44, 2.14, 0.00, 0.00, 180.00);
	AddSprayTag(-229.34, 1082.35, 20.89, 0.00, 0.00, 0.00);
	AddSprayTag(146.92, 1831.78, 18.02, 0.00, 0.00, 90.00);
	AddSprayTag(2267.55, 1518.13, 46.33, 0.00, 0.00, 180.00);
	AddSprayTag(-1908.91, 299.56, 41.52, 0.00, 0.00, 180.00);
	AddSprayTag(-2636.70, 635.52, 15.63, 0.00, 0.00, 0.00);
	AddSprayTag(-2224.75, 881.27, 84.13, 0.00, 0.00, 90.00);
	AddSprayTag(-1788.32, 748.42, 25.36, 0.00, 0.00, 270.00);
}
public OnFilterScriptExit()
{
	foreach(new i : spt_Iterator)
	{
		i = DeleteSprayTag(i);
	}
	for(new i;i<MAX_PLAYERS;i++)
	{
	    if(IsPlayerConnected(i))
			DestroyPlayerProgressBar(i, spt_SprayBar);
	}
	print("\n - Spraytags Unloaded\n");
}

stock AddSprayTag(Float:posx, Float:posy, Float:posz, Float:rotx, Float:roty, Float:rotz)
{
	new id = Iter_Free(spt_Iterator);
	
	rotz -= 180.0;

	spt_Data[id][spt_objID] = CreateDynamicObject(19477, posx, posy, posz, rotx, roty, rotz);
	spt_Data[id][spt_areaID] = CreateDynamicSphere(posx, posy, posz, 1.5, 0, 0);
    spt_Data[id][spt_posX] = posx;
    spt_Data[id][spt_posY] = posy;
    spt_Data[id][spt_posZ] = posz;
    spt_Data[id][spt_rotX] = rotx;
    spt_Data[id][spt_rotY] = roty;
    spt_Data[id][spt_rotZ] = rotz;

    SetDynamicObjectMaterialText(spt_Data[id][spt_objID], 0, "HELLFIRE", OBJECT_MATERIAL_SIZE_512x256, "IMPACT", 72, 1, 0xFFFF0000, 0, 1);

	Iter_Add(spt_Iterator, id);
	return id;
}
stock DeleteSprayTag(tagid)
{
	new next;

	DestroyDynamicObject(spt_Data[tagid][spt_objID]);
    spt_Data[tagid][spt_posX] = 0.0;
    spt_Data[tagid][spt_posY] = 0.0;
    spt_Data[tagid][spt_posZ] = 0.0;
    spt_Data[tagid][spt_rotX] = 0.0;
    spt_Data[tagid][spt_rotY] = 0.0;
    spt_Data[tagid][spt_rotZ] = 0.0;

	Iter_SafeRemove(spt_Iterator, tagid, next);
	return next;
}
stock SetSprayTagText(tagid, text[], colour = -1, font[] = "Arial Black")
{
    format(spt_text, 24, text);
    SetDynamicObjectMaterialText(spt_Data[tagid][spt_objID], 0, text, OBJECT_MATERIAL_SIZE_512x256, font, 72, 1, colour, 0, 1);
}

public OnPlayerEnterDynamicArea(playerid, areaid)
{
	foreach(new i : spt_Iterator)
	{
	    if(areaid == spt_Data[i][spt_areaID])
	    {
	        if(strcmp(spt_text, gPlayerName[playerid]))
	        {
		        if(GetPlayerWeapon(playerid) == WEAPON_SPRAYCAN)
		        {
		        	CallRemoteFunction("sffa_msgbox", "dsdd", playerid, "Hold ~b~FIRE ~w~to spray your tag", 3000, 150);
		        }
		        else
		        {
		        	CallRemoteFunction("sffa_msgbox", "dsdd", playerid, "~r~You need a spray can.", 3000, 140);
		        }
	        }
	    }
	}
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_FIRE)
	{
	    new
			wepState = GetPlayerWeaponState(playerid),
			wepID = GetPlayerWeapon(playerid);
	    if( wepID == WEAPON_SPRAYCAN && (wepState != WEAPONSTATE_RELOADING || wepState != WEAPONSTATE_NO_BULLETS) && spt_Spraying[playerid] == -1)
	    {
	        foreach(new i : spt_Iterator)
	        {
	            if(IsPlayerInDynamicArea(playerid, spt_Data[i][spt_areaID]))
	            {
//			        CallRemoteFunction("sffa_msgbox", "dsdd", playerid, "Tagging...", 3000, 150);
	                spt_Spraying[playerid] = i;
	                SetPlayerProgressBarValue(playerid, spt_SprayBar, 0.0);
	                ShowPlayerProgressBar(playerid, spt_SprayBar);
	                spt_SprayTimer[playerid] = repeat SprayTag(playerid, i);
	            }
	        }
	    }
	}
	if(oldkeys & KEY_FIRE)
	{
		if(spt_Spraying[playerid] != -1)
		{
			CallRemoteFunction("sffa_msgbox", "dsdd", playerid, "Tagging canceled by key.", 3000, 150);
		    stop spt_SprayTimer[playerid];
		    HidePlayerProgressBar(playerid, spt_SprayBar);
			spt_Spraying[playerid] = -1;
		}
	}
}
/*
public OnPlayerUpdate(playerid)
{
	if(spt_Spraying[playerid] != -1)
	{
		new
			str[128],
			Float:ang,
			Float:spt = spt_Data[spt_Spraying[playerid]][spt_rotZ] + 90;


		GetPlayerFacingAngle(playerid, ang);
		
		if(ang>180)ang=360-ang;

		format(str, 128, "s ang: %f~n~p ang: %f~n~total: %f",
			spt,
			ang,
			ang-spt);

		CallRemoteFunction("sffa_msgbox", "dsdd", playerid, str, 0, 150);
	}
	else
		CallRemoteFunction("sffa_msgbox", "dsdd", playerid, "ang: invalid", 0, 150);
	return 1;
}
*/
timer SprayTag[500](playerid, tagid)
{
	new
		name[MAX_PLAYER_NAME],
		colour = GetPlayerColor(playerid),
		Float:progress = GetPlayerProgressBarValue(playerid, spt_SprayBar),
		animIdx = GetPlayerAnimationIndex(playerid),
		Float:ang;

	GetPlayerFacingAngle(playerid, ang);
	
	if(ang>180)ang=360-ang;
	
	if(animIdx != 1167 && animIdx != 1160 && animIdx != 1161 && animIdx != 1162 && animIdx != 1163)return CancelTagging(playerid);
	if( (ang-(spt_Data[tagid][spt_rotZ]+90.0)) > 30.0 )return CancelTagging(playerid);

	progress += 1.0;
	SetPlayerProgressBarValue(playerid, spt_SprayBar, progress);
	UpdatePlayerProgressBar(playerid, spt_SprayBar);
	
	if(progress == 5.0)
	{
		GetPlayerName(playerid, name, MAX_PLAYER_NAME);
		SetSprayTagText(tagid, name, colour >>> 8 | colour << 24, "Arial Black");
		SetPlayerProgressBarValue(playerid, spt_SprayBar, 0.0);
		HidePlayerProgressBar(playerid, spt_SprayBar);
		spt_Spraying[playerid] = -1;
		stop spt_SprayTimer[playerid];
	}
	return 1;
}
CancelTagging(playerid)
{
//	CallRemoteFunction("sffa_msgbox", "dsdd", playerid, "Tagging canceled.", 3000, 150);
	stop spt_SprayTimer[playerid];
	HidePlayerProgressBar(playerid, spt_SprayBar);
	spt_Spraying[playerid] = -1;
	return 0;
}
