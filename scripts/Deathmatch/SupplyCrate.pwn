#define MAX_SUPPLY_CRATE	((MAX_PLAYERS*2)+16)

#define CRATE_TYPE_MAIN		(0)
#define CRATE_TYPE_AMMO		(1)
#define CRATE_TYPE_MEDS		(2)


enum E_SUPPLY_CRATE_DATA
{
			crt_objId,
			crt_buttonId,
			crt_ownerId,
			crt_type
}


new
			crt_Data[MAX_SUPPLY_CRATE][E_SUPPLY_CRATE_DATA],
			crt_UseCount[MAX_SUPPLY_CRATE],
Iterator:	crt_Index<MAX_SUPPLY_CRATE>;

new
			crt_CrateUseTick[MAX_PLAYERS][3],
Timer:		crt_UpdateTimer[MAX_PLAYERS];


CreateSupplyCrate(Float:x, Float:y, Float:z, Float:r, type, playerid = INVALID_PLAYER_ID)
{
	new id = Iter_Free(crt_Index);

	switch(type)
	{
	    case CRATE_TYPE_MAIN:
	    {
			crt_Data[id][crt_objId]		= CreateDynamicObject(964, x, y, z, 0.0, 0.0, r, DEATHMATCH_WORLD);
			crt_Data[id][crt_buttonId]	= CreateButton(x, y, z + 1.0, "Hold F to re-supply", DEATHMATCH_WORLD, .areasize = 2.0);
			SetButtonLabel(crt_Data[id][crt_buttonId], "Supply");
		}
	    case CRATE_TYPE_AMMO:
	    {
			crt_Data[id][crt_objId]		= CreateDynamicObject(3052, x, y, z, 0.0, 0.0, r, DEATHMATCH_WORLD);
			crt_Data[id][crt_buttonId]	= CreateButton(x, y, z + 1.0, "Hold F to get ammo", DEATHMATCH_WORLD);
			SetButtonLabel(crt_Data[id][crt_buttonId], "Ammo");
		}
	    case CRATE_TYPE_MEDS:
	    {
			crt_Data[id][crt_objId]		= CreateDynamicObject(1580, x, y, z, 0.0, 0.0, r, DEATHMATCH_WORLD);
			crt_Data[id][crt_buttonId]	= CreateButton(x, y, z + 1.0, "Hold F to heal", DEATHMATCH_WORLD);
			SetButtonLabel(crt_Data[id][crt_buttonId], "Medkit");
		}
	}

	crt_Data[id][crt_type]		= type;
	crt_Data[id][crt_ownerId]	= playerid;

	Iter_Add(crt_Index, id);

	return id;
}
DestroySupplyCrate(crateid)
{
	if(!Iter_Contains(crt_Index, crateid))return 0;

	DestroyDynamicObject(crt_Data[crateid][crt_objId]);
	DestroyButton(crt_Data[crateid][crt_buttonId]);

	crt_Data[crateid][crt_type] = 0;
	crt_Data[crateid][crt_ownerId] = INVALID_PLAYER_ID;

	Iter_Remove(crt_Index, crateid);

	return 1;
}

public OnButtonPress(playerid, buttonid)
{
	foreach(new i : crt_Index)
	{
	    if(buttonid == crt_Data[i][crt_buttonId])
	    {
			if( (GetTickCount() - crt_CrateUseTick[playerid][crt_Data[i][crt_type]]) >= MAX_CRATE_COOL)
				UseSupplyCrate(playerid, i);

			break;
		}
	}
    return CallLocalFunction("crt_OnButtonPress", "dd", playerid, buttonid);
}
#if defined _ALS_OnButtonPress
    #undef OnButtonPress
#else
    #define _ALS_OnButtonPress
#endif
#define OnButtonPress crt_OnButtonPress
forward crt_OnButtonPress(playerid, buttonid);


public OnButtonRelease(playerid, buttonid)
{
	if(bPlayerDeathmatchSettings[playerid] & dm_UsingSupplyCrate)
	{
	    stop crt_UpdateTimer[playerid];

		f:bPlayerDeathmatchSettings[playerid]<dm_UsingSupplyCrate>;

		HidePlayerProgressBar(playerid, ActionBar);
		SetPlayerProgressBarValue(playerid, ActionBar, 0.0);
		ClearAnimations(playerid);
	}
    return CallLocalFunction("crt_OnButtonRelease", "dd", playerid, buttonid);
}
#if defined _ALS_OnButtonRelease
    #undef OnButtonRelease
#else
    #define _ALS_OnButtonRelease
#endif
#define OnButtonRelease crt_OnButtonRelease
forward crt_OnButtonRelease(playerid, buttonid);

UseSupplyCrate(playerid, crateid)
{
	t:bPlayerDeathmatchSettings[playerid]<dm_UsingSupplyCrate>;
	crt_UpdateTimer[playerid] = repeat UseSupplyCrateUpdate(playerid, crateid);

	ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 1.0, 1, 0, 0, 0, 0);
	ShowPlayerProgressBar(playerid, ActionBar);
	SetPlayerProgressBarMaxValue(playerid, ActionBar, 50.0);

	return 1;
}
timer UseSupplyCrateUpdate[100](playerid, crateid)
{
	new
		Float:val = GetPlayerProgressBarValue(playerid, ActionBar);

	SetPlayerProgressBarValue(playerid, ActionBar, val + 1.0);
	UpdatePlayerProgressBar(playerid, ActionBar);

	if(val >= 50.0)
	{
	    stop crt_UpdateTimer[playerid];
		UseSupplyCrateEnd(playerid, crateid);
	}
}
UseSupplyCrateEnd(playerid, crateid)
{
	f:bPlayerDeathmatchSettings[playerid]<dm_UsingSupplyCrate>;
	HidePlayerProgressBar(playerid, ActionBar);
	ClearAnimations(playerid);

	if(crt_Data[crateid][crt_type] == CRATE_TYPE_MAIN)
	{
		t:bPlayerDeathmatchSettings[playerid]<dm_GearUse>;
		flag_ShotBy[playerid] = -1;

		dm_SetPlayerHP(playerid, dm_GlobalMaxHP);
		GivePlayerKitWeapons(playerid, 1);
	}
	else
	{
	    new ownerid = crt_Data[crateid][crt_ownerId];

		switch(crt_Data[crateid][crt_type])
		{
			case CRATE_TYPE_AMMO:
			{
				GivePlayerKitWeapons(playerid, 1);
			}
			case CRATE_TYPE_MEDS:
			{
				dm_GivePlayerHP(playerid, MEDCRATE_HP);
			}
		}

		crt_UseCount[crateid]++;
		if(crt_UseCount[crateid] >= 5)
			DestroySupplyCrate(crateid);

		if(IsPlayerConnected(ownerid) && ownerid != playerid && pTeam(ownerid) == pTeam(playerid))
		{
			switch(crt_Data[crateid][crt_type])
			{
				case CRATE_TYPE_AMMO:
				{
					GiveXP(ownerid, 10, "Supply");
					pStatCount[ownerid][st_Sup][st_SupAmmo]++;
				}
				case CRATE_TYPE_MEDS:
				{
					GiveXP(ownerid, 10, "Heal");
					pStatCount[ownerid][st_Sup][st_SupHeal]++;
				}
			}
			AwardDataUpdate(ownerid, .sup=1);
		}
	}
}

