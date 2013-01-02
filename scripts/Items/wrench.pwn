#include <YSI\y_hooks>


new
ItemType:	item_Wrench = INVALID_ITEM_TYPE,
Timer:		gPlayerWrenchTimer[MAX_PLAYERS],
Float:		gPlayerWrenchProgress[MAX_PLAYERS],
			gPlayerWrenchTarget[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	gPlayerWrenchTarget[playerid] = INVALID_VEHICLE_ID;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(GetItemType(GetPlayerItem(playerid)) == item_Wrench)
	{
		if(newkeys == 16)
		{
			new
				Float:vx,
				Float:vy,
				Float:vz,
				Float:px,
				Float:py,
				Float:pz,
				Float:sx,
				Float:sy,
				Float:sz;

			for(new i; i < MAX_VEHICLES; i++)
			{
				GetVehiclePos(i, vx, vy, vz);
				GetPlayerPos(playerid, px, py, pz);
				GetVehicleModelInfo(GetVehicleModel(i), VEHICLE_MODEL_INFO_SIZE, sx, sy, sz);

				if(Distance(vx, vy, vz, px, py, pz) < sy)
				{
					new Float:vr, Float:angle;
					GetVehicleZAngle(i, vr);

					angle = (vr - GetAngleToPoint(vx, vy, px, py));

					if(-25.0 < angle < 25.0 || 335.0 < angle < 385.0)
					{
						new
							engine,
							lights,
							alarm,
							doors,
							bonnet,
							boot,
							objective;

						GetVehicleParamsEx(i, engine, lights, alarm, doors, bonnet, boot, objective);
						SetVehicleParamsEx(i, engine, lights, alarm, doors, 1, boot, objective);

						SetPlayerPos(playerid, px, py, pz);
						GetVehicleHealth(i, gPlayerWrenchProgress[playerid]);
						gPlayerWrenchTarget[playerid] = i;
						gPlayerWrenchTimer[playerid] = repeat WrenchFixUpdate(playerid);
						ApplyAnimation(playerid, "INT_SHOP", "SHOP_CASHIER", 4.0, 1, 0, 0, 0, 0, 1);
						break;
					}
				}
			}
		}
		if(oldkeys == 16)
		{
			if(gPlayerWrenchTarget[playerid] != INVALID_VEHICLE_ID)
			{
				new
					engine,
					lights,
					alarm,
					doors,
					bonnet,
					boot,
					objective;

				GetVehicleParamsEx(gPlayerWrenchTarget[playerid], engine, lights, alarm, doors, bonnet, boot, objective);
				SetVehicleParamsEx(gPlayerWrenchTarget[playerid], engine, lights, alarm, doors, 0, boot, objective);

				stop gPlayerWrenchTimer[playerid];

				HidePlayerProgressBar(playerid, ActionBar);
				ClearAnimations(playerid);

				gPlayerWrenchTarget[playerid] = INVALID_VEHICLE_ID;
			}
		}
	}
    return 1;
}

timer WrenchFixUpdate[100](playerid)
{
	new
		Float:px,
		Float:py,
		Float:pz,
		Float:vx,
		Float:vy,
		Float:vz;

	gPlayerWrenchProgress[playerid] += 5.0;
	
	SetPlayerProgressBarValue(playerid, ActionBar, gPlayerWrenchProgress[playerid]);
	SetPlayerProgressBarMaxValue(playerid, ActionBar, 1000.0);
	ShowPlayerProgressBar(playerid, ActionBar);

	SetVehicleHealth(gPlayerWrenchTarget[playerid], gPlayerWrenchProgress[playerid]);

	GetVehiclePos(gPlayerWrenchTarget[playerid], vx, vy, vz);
	GetPlayerPos(playerid, px, py, pz);
	SetPlayerFacingAngle(playerid, GetAngleToPoint(px, py, vx, vy));


	if(gPlayerWrenchProgress[playerid] >= 1000.0)
	{
		new
			engine,
			lights,
			alarm,
			doors,
			bonnet,
			boot,
			objective;

		GetVehicleParamsEx(gPlayerWrenchTarget[playerid], engine, lights, alarm, doors, bonnet, boot, objective);
		SetVehicleParamsEx(gPlayerWrenchTarget[playerid], engine, lights, alarm, doors, 0, boot, objective);

		stop gPlayerWrenchTimer[playerid];

		HidePlayerProgressBar(playerid, ActionBar);
		ClearAnimations(playerid);

		gPlayerWrenchTarget[playerid] = INVALID_VEHICLE_ID;
	}
}


