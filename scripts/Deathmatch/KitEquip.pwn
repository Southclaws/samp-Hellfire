//==============================================================================Support

KitEquip_Supp(playerid)
{
	if(dm_EquipCount[playerid] >= 1)
	{
	    new
			Float:x,
			Float:y,
			Float:z,
			Float:r;

	    GetPlayerPos(playerid, x, y, z);
	    GetPlayerFacingAngle(playerid, r);

		ApplyAnimation(playerid, "grenade", "WEAPON_throwu", 4.0, 0, 0, 0, 0, 0, 1);

		CreateSupplyCrate(
			x + floatsin(-r, degrees),
			y + floatcos(-r, degrees),
			z - 0.9, r, CRATE_TYPE_AMMO, playerid);

		Streamer_Update(playerid);
		dm_EquipCount[playerid]--;
		UpdateEqipmentText(playerid);
		SetTimerEx("ResetKitEquip", 8000, false, "d", playerid);
	}
}

//==============================================================================Mechanic

KitEquip_Mech(playerid)
{
	if(dm_EquipCount[playerid] >= 1)
	{
		new Float:vX, Float:vY, Float:vZ, Float:vH, vehicleID;
		vehicleID = GetNearestVehicle(playerid);
		GetVehiclePos(vehicleID, vX, vY, vZ);
		GetVehicleHealth(vehicleID, vH);
		if(IsPlayerInRangeOfPoint(playerid, 5, vX, vY, vZ))
		{
			if(vH > 800) Msg(playerid, ORANGE, "Does not need fixing");
			else
			{
				TogglePlayerControllable(playerid, false);
				SetTimerEx("Engineer_Repair", 3000, false, "dd", playerid, vehicleID);
				ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, 1, 0, 0, 0, 3000, 1);
				dm_EquipCount[playerid]--;
				bitTrue(bPlayerDeathmatchSettings[playerid], dm_UsingEquip);
			}
		}
		UpdateEqipmentText(playerid);
	}
}
public Engineer_Repair(playerid, vehicleid)
{
	SetVehicleHealth(vehicleid, 1000);
	ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Crouch_Out", 4.0, 0, 0, 0, 0, 0, 1);

	GiveXP(playerid, 5, "repair");
	pStatCount[playerid][st_Sup][st_SupRepr]++;
	AwardDataUpdate(playerid, .sup=1);

	Msg(playerid, LGREEN, "Vehicle Repaired!");
	TogglePlayerControllable(playerid,true);
	SetTimerEx("RefilRepair", 10000, false, "d", playerid);
	bitFalse(bPlayerDeathmatchSettings[playerid], dm_UsingEquip);
}

//==============================================================================Medic

KitEquip_Meds(playerid)
{
	if(dm_EquipCount[playerid] >= 1)
	{
	    PlayerLoop(i)
	    {
			if(IsPlayerInDynamicArea(playerid, gPlayerArea[i]))
			{
				if(bPlayerDeathmatchSettings[i] & dm_Bleeding)
				{
					Medic_revive(playerid, i);
					UpdateEqipmentText(playerid);
					return 1;
				}

			}
		}

	    new
			Float:x,
			Float:y,
			Float:z,
			Float:r;

	    GetPlayerPos(playerid, x, y, z);
	    GetPlayerFacingAngle(playerid, r);

		ApplyAnimation(playerid, "grenade", "WEAPON_throwu", 4.0, 0, 0, 0, 0, 0, 1);

		CreateSupplyCrate(
			x + floatsin(-r, degrees),
			y + floatcos(-r, degrees),
			z - 0.9, r, CRATE_TYPE_MEDS, playerid);

		Streamer_Update(playerid);
		dm_EquipCount[playerid]--;
		UpdateEqipmentText(playerid);
		SetTimerEx("ResetKitEquip", 8000, false, "d", playerid);

	}
	return 1;
}
Medic_revive(playerid, targetid)
{
	SetPlayerToFacePlayer(playerid, targetid);
	TogglePlayerControllable(targetid, true);
	ApplyAnimation(playerid, "bomber", "bom_Plant", 4.0, 0, 0, 0, 0, 0, 1);
	ApplyAnimation(targetid, "ped", "getup", 4.0, 0, 0, 0, 0, 0, 1);
	dm_EquipCount[playerid]--;
	SetTimerEx("Medic_RevivePlayer", 1500, false, "dd", playerid, targetid);
}
public Medic_RevivePlayer(playerid, targetid)
{
	gPlayerHP[targetid]=MAX_HEALTH;
	SetCameraBehindPlayer(targetid);

	ExitBleedOut(targetid);
	GiveXP(playerid, 10, "Revive");
	pStatCount[playerid][st_Sup][st_SupRevv]++;
	AwardDataUpdate(playerid, .sup=1);

	ClearAnimations(playerid, 1);
	ClearAnimations(targetid, 1);

	SetTimerEx("ResetKitEquip", 8000, false, "d", playerid);
	bitTrue(bPlayerDeathmatchSettings[playerid], dm_UsingEquip);
}

//==============================================================================SpecOps

KitEquip_Spec(playerid)
{
	Msg(playerid, RED, "Not implemented yet :(");
}

//==============================================================================Bomber

KitEquip_Bomb(playerid)
{
	if(dm_EquipCount[playerid] >= 1)
	{
		ApplyAnimation(playerid, "bomber", "bom_Plant", 4.0, 1, 0, 0, 0, 2000, 1);
		SetTimerEx("Bomber_PlaceMine", 1500, false, "i", playerid);
		dm_EquipCount[playerid]--;
		bitTrue(bPlayerDeathmatchSettings[playerid], dm_UsingEquip);
		UpdateEqipmentText(playerid);
	}
}
public Bomber_PlaceMine(playerid)
{
	new
		Float:x,
		Float:y,
		Float:z;
	GetPlayerPos(playerid, x, y, z);
	GetXYInFrontOfPlayer(playerid, x, y, 0.6);
	CreateMine(playerid, x, y, z-0.9);
	bitFalse(bPlayerDeathmatchSettings[playerid], dm_UsingEquip);
}

//==============================================================================Functions


public ResetKitEquip(playerid)
{
	dm_EquipCount[playerid]=1;
	UpdateEqipmentText(playerid);
}

UpdateEqipmentText(playerid)
{
	if(dm_Preset == DM_BAREBONES)
	{
		PlayerTextDrawSetString(playerid, dm_EquipText, " ");
		return 0;
	}

	new string[20];
	if(pKit(playerid)==KIT_SUPPORT)
	{
		new SuppliesReady[16] = "~y~Ready";
		if(dm_EquipCount[playerid] == 0)SuppliesReady="~r~Wait...";
		format(string, 20, "Supply: %s", SuppliesReady);
	}
	if(pKit(playerid) == KIT_MECHANIC)
	{
		new RepairKitReady[16]="~y~Ready";
		if(dm_EquipCount[playerid]>=1)RepairKitReady="~r~Wait...";
		format(string, 20, "Repair: %s", RepairKitReady);
	}
	if(pKit(playerid) == KIT_MEDIC)
	{
		new HealReady[16]="~y~Ready";
		if(dm_EquipCount[playerid]==0) HealReady="~r~Wait...";
		format(string, 20, "Medkit: %s", HealReady);
	}
	if(pKit(playerid) == KIT_SPECOPS)
	{
		new HealReady[16]="~y~Ready";
		if(dm_EquipCount[playerid]==0) HealReady="~r~Wait...";
		format(string, 20, "Beacon: %s", HealReady);
	}
	if(pKit(playerid) == KIT_BOMBER)
	{
		format(string, 20, "Mines: %d", dm_EquipCount[playerid]);
	}

	PlayerTextDrawSetString(playerid, dm_EquipText, string);
	PlayerTextDrawShow(playerid, dm_EquipText);

	return 1;
}

