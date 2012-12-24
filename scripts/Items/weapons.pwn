#include <YSI\y_hooks>

hook OnGameModeInit()
{
	DefineItemType("Flare", 354, ITEM_SIZE_SMALL);

	ShiftItemTypeIndex(ItemType:1, 46);

	for(new i = 1; i < 47; i++)
	{
		DefineItemType(WepData[i][WepName], WepData[i][WepModel], ITEM_SIZE_SMALL, .rotx = 90.0);
	}
	return 1;
}


public OnPlayerPickUpItem(playerid, itemid)
{
	new ItemType:type = GetItemType(itemid);
	if(0 < _:type <= WEAPON_PARACHUTE)
	{
	    new weaponid = GetPlayerWeapon(playerid);
		if(weaponid == 0 || weaponid == _:type)
		{
		    new ammo = GetItemExtraData(itemid);

		    if(ammo > 0)
			    GivePlayerWeapon(playerid, _:type, ammo);

		    DestroyItem(itemid);
		}
		else return 1;
	}
    return CallLocalFunction("wep_OnPlayerPickUpItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerPickUpItem
    #undef OnPlayerPickUpItem
#else
    #define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem wep_OnPlayerPickUpItem
forward wep_OnPlayerPickUpItem(playerid, itemid);

public OnPlayerGiveItem(playerid, targetid, itemid)
{
	new ItemType:type = GetItemType(itemid);
	if(0 < _:type <= WEAPON_PARACHUTE)
	{
	    new ammo = GetItemExtraData(itemid);

	    if(ammo > 0)
		    GivePlayerWeapon(targetid, _:type, ammo);

	    DestroyItem(itemid);
	}
    return CallLocalFunction("wep_OnPlayerGiveItem", "ddd", playerid, targetid, itemid);
}
#if defined _ALS_OnPlayerGiveItem
    #undef OnPlayerGiveItem
#else
    #define _ALS_OnPlayerGiveItem
#endif
#define OnPlayerGiveItem wep_OnPlayerGiveItem
forward wep_OnPlayerGiveItem(playerid, targetid, itemid);

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(GetPlayerItem(playerid) != INVALID_ITEM_ID)
		return 1;

	if(newkeys & KEY_NO && !(newkeys & 128))
	{
		PlayerLoop(i)
		{
			if(i == playerid)continue;

			if(IsPlayerInDynamicArea(playerid, gPlayerArea[i]) && !IsPlayerInAnyVehicle(i))
			{
				if(GetPlayerWeapon(i) != 0)
					continue;

				if(GetPlayerItem(playerid) != INVALID_ITEM_ID || GetPlayerItem(i) != INVALID_ITEM_ID)
					continue;

				if(!IsPlayerIdle(playerid) || !IsPlayerIdle(i))
					continue;

				PlayerGiveWeapon(playerid, i);
				return 1;
			}
		}

		if(IsPlayerIdle(playerid))
			PlayerDropWeapon(playerid);
	}
	if(newkeys & KEY_YES)
	{
		new ItemType:type = ItemType:GetPlayerWeapon(playerid);

		if(0 < _:type <= WEAPON_PARACHUTE)
		{
			new
				containerid = GetPlayerContainerID(playerid),
				ammo = GetPlayerAmmo(playerid),
				itemid = CreateItem(ItemType:type, 0.0, 0.0, 0.0,
					.world = GetPlayerVirtualWorld(playerid),
					.interior = GetPlayerInterior(playerid));

			RemovePlayerWeapon(playerid, _:type);
			SetItemExtraData(itemid, ammo);
			if(containerid != INVALID_CONTAINER_ID)
			{

				if(AddItemToContainer(containerid, itemid))
				{
					new
						name[MAX_CONTAINER_NAME],
						str[MAX_CONTAINER_NAME + 14];

					GetContainerName(containerid, name);
					str = "Item added to ";
					strcat(str, name);
					ShowMsgBox(playerid, str, 3000, 100);
				}
				else
				{
					new
						str[MAX_CONTAINER_NAME];

					GetContainerName(containerid, str);
					strcat(str, " full");
					ShowMsgBox(playerid, str, 3000, 100);
				}
			}
			else
			{
				if(AddItemToInventory(playerid, itemid))
					ShowMsgBox(playerid, "Item added to inventory", 3000, 150);

				else
					ShowMsgBox(playerid, "Inventory full", 3000, 100);
			}
		}
	}
	return 1;
}


PlayerDropWeapon(playerid)
{
	new ItemType:type = ItemType:GetPlayerWeapon(playerid);

	if(0 < _:type <= WEAPON_PARACHUTE)
	{
		new
			ammo = GetPlayerAmmo(playerid),
			itemid = CreateItem(ItemType:type, 0.0, 0.0, 0.0,
				.world = GetPlayerVirtualWorld(playerid),
				.interior = GetPlayerInterior(playerid));

		RemovePlayerWeapon(playerid, _:type);

		if(GiveWorldItemToPlayer(playerid, itemid, .call = 0))
		{
			PlayerDropItem(playerid);

			switch(WepData[_:type][GtaSlot])
			{
				case 0, 1, 10, 11, 12: ammo = 1;
				default: defer SetWeaponItemLabel(itemid, _:type, ammo);
			}
		}
		SetItemExtraData(itemid, ammo);
		return itemid;
	}
	return INVALID_ITEM_ID;
}
timer SetWeaponItemLabel[1000](itemid, type, ammo)
{
	new str[32];
	format(str, 32, "%s\nAmmo: %d", WepData[type][WepName], ammo);
	SetItemLabel(itemid, str);
}

PlayerGiveWeapon(playerid, targetid)
{
	new ItemType:type = ItemType:GetPlayerWeapon(playerid);

	if(0 < _:type <= WEAPON_PARACHUTE)
	{
		new
			ammo = GetPlayerAmmo(playerid),
			itemid = CreateItem(ItemType:type, 0.0, 0.0, 0.0,
				.world = GetPlayerVirtualWorld(playerid),
				.interior = GetPlayerInterior(playerid));

		RemovePlayerWeapon(playerid, _:type);
		SetItemExtraData(itemid, ammo);
		GiveWorldItemToPlayer(playerid, itemid, .call = 0);
		PlayerGiveItem(playerid, targetid, 1);
	}
}

IsPlayerIdle(playerid)
{
    new animidx = GetPlayerAnimationIndex(playerid);
    switch(animidx)
	{
		case 320, 1164, 1183, 1188, 1189:return 1;
		default: return 0;
	}
	return 0;
}
