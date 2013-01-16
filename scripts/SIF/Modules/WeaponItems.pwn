#include <YSI\y_hooks>


new stock gHolsterWeaponData[MAX_PLAYERS][2];


stock GetPlayerHolsteredWeapon(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return 0;

	return gHolsterWeaponData[playerid][0];
}
stock GetPlayerHolsteredWeaponAmmo(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return 0;

	return gHolsterWeaponData[playerid][1];
}
stock ClearPlayerHolsterWeapon(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return 0;

	gHolsterWeaponData[playerid][0] = 0;
	gHolsterWeaponData[playerid][1] = 0;

	return 1;
}

hook OnGameModeInit()
{
	new size;

	DefineItemType("Flare", 354, ITEM_SIZE_SMALL);

	ShiftItemTypeIndex(ItemType:1, 46);

	for(new i = 1; i < 47; i++)
	{
		switch(i)
		{
			case 1, 4, 16, 17, 22..24, 41, 43, 44, 45:
				size = ITEM_SIZE_SMALL;

			case 18, 10..13, 26, 28, 32, 39, 40:
				size = ITEM_SIZE_MEDIUM;

			default: size = ITEM_SIZE_LARGE;
		}

		DefineItemType(WepData[i][WepName], WepData[i][WepModel], size, .rotx = 90.0);
	}
	return 1;
}


public OnPlayerPickedUpItem(playerid, itemid)
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
    return CallLocalFunction("wep_OnPlayerPickedUpItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerPickedUpItem
    #undef OnPlayerPickedUpItem
#else
    #define _ALS_OnPlayerPickedUpItem
#endif
#define OnPlayerPickedUpItem wep_OnPlayerPickedUpItem
forward wep_OnPlayerPickedUpItem(playerid, itemid);

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
	if(IsPlayerInAnyVehicle(playerid))
		return 1;

	if(GetPlayerItem(playerid) != INVALID_ITEM_ID)
		return 1;

	if(newkeys & KEY_NO && !(newkeys & 128))
	{
		PlayerLoop(i)
		{
			if(i == playerid)continue;

			if(IsPlayerInDynamicArea(playerid, gPlayerArea[i]))
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
				containerid = GetPlayerContainerButtonArea(playerid),
				ammo = GetPlayerAmmo(playerid);

			if(containerid != INVALID_CONTAINER_ID)
			{
				if(IsContainerFull(containerid))
				{
					new
						str[MAX_CONTAINER_NAME];

					GetContainerName(containerid, str);
					strcat(str, " full");
					ShowMsgBox(playerid, str, 3000, 100);
				}
				else
				{
					new
						name[MAX_CONTAINER_NAME],
						str[MAX_CONTAINER_NAME + 14],
						itemid = CreateItem(ItemType:type, 0.0, 0.0, 0.0, .world = GetPlayerVirtualWorld(playerid), .interior = GetPlayerInterior(playerid));

					SetItemExtraData(itemid, ammo);
					AddItemToContainer(containerid, itemid, playerid);
					RemovePlayerWeapon(playerid, _:type);

					GetContainerName(containerid, name);
					str = "Item added to ";
					strcat(str, name);
					ShowMsgBox(playerid, str, 3000, 100);
				}
			}
			else
			{
				if(GetItemTypeSize(type) == ITEM_SIZE_SMALL)
				{
					if(IsContainerFull(containerid))
					{
						ShowMsgBox(playerid, "Inventory full", 3000, 100);
					}
					else
					{
						new itemid = CreateItem(ItemType:type, 0.0, 0.0, 0.0, .world = GetPlayerVirtualWorld(playerid), .interior = GetPlayerInterior(playerid));

						SetItemExtraData(itemid, ammo);
						AddItemToInventory(playerid, itemid);
						RemovePlayerWeapon(playerid, _:type);

						ShowMsgBox(playerid, "Item added to inventory", 3000, 150);
					}

				}
				else
				{
					switch(type)
					{
						case 2, 3, 5, 6, 7, 8, 15, 1, 4, 16..18, 22..24, 10..13, 26, 28, 32, 39..41, 43, 44, 45, 25, 27, 29, 30, 31, 33, 34, 35, 36:
						{
							SetPlayerAttachedObject(playerid, ATTACHSLOT_HOLD, WepData[_:type][WepModel], 6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
							ApplyAnimation(playerid, "GOGGLES", "GOGGLES_PUT_ON", 1.7, 0, 0, 0, 0, 0);
							defer HolsterWeapon(playerid, _:type, ammo);
						}
						default:
						{
							ShowMsgBox(playerid, "That item is too big for your inventory", 3000, 140);
							return 0;
						}
					}
				}
			}
		}
		if(_:type == 0 && GetPlayerItem(playerid) == INVALID_ITEM_ID)
		{
			if(gHolsterWeaponData[playerid][0] != 0)
			{
				ApplyAnimation(playerid, "GOGGLES", "GOGGLES_PUT_ON", 1.7, 0, 0, 0, 0, 0);
				defer UnholsterWeapon(playerid);
			}
		}
	}
	return 1;
}

timer HolsterWeapon[800](playerid, type, ammo)
{
	switch(type)
	{
		case 2, 3, 5, 6, 7, 8, 15:
			SetPlayerAttachedObject(playerid, ATTACHSLOT_HOLSTER, WepData[type][WepModel], 1, 0.123097, -0.129424, -0.139251, 0.000000, 301.455871, 0.000000, 1.000000, 1.000000, 1.000000);

		case 1, 4, 16..18, 22..24, 10..13, 26, 28, 32, 39..41, 43, 44, 45:
			SetPlayerAttachedObject(playerid, ATTACHSLOT_HOLSTER, WepData[type][WepModel], 8, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 1.000000, 1.000000, 1.000000 ); // tec9 - small

		case 25, 27, 29, 30, 31, 33, 34:
			SetPlayerAttachedObject(playerid, ATTACHSLOT_HOLSTER, WepData[type][WepModel], 1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 1.000000, 1.000000, 1.000000 ); // ak47 - ak

		case 35, 36:
			SetPlayerAttachedObject(playerid, ATTACHSLOT_HOLSTER, WepData[type][WepModel], 1, 0.181966, -0.238397, -0.094830, 252.791229, 353.893859, 357.529418, 1.000000, 1.000000, 1.000000 ); // rocketla - rpg

		default: return 0;
	}

	if(gHolsterWeaponData[playerid][0] == 0)
	{
		RemovePlayerWeapon(playerid, type);
		ShowMsgBox(playerid, "Weapon Holstered", 3000, 120);
	}
	else
	{
		GivePlayerWeapon(playerid, gHolsterWeaponData[playerid][0], gHolsterWeaponData[playerid][1]);
		ShowMsgBox(playerid, "Weapon Swapped", 3000, 110);
	}

	gHolsterWeaponData[playerid][0] = type;
	gHolsterWeaponData[playerid][1] = ammo;

	RemovePlayerAttachedObject(playerid, ATTACHSLOT_HOLD);
	ClearAnimations(playerid);

	return 1;
}
timer UnholsterWeapon[800](playerid)
{
	GivePlayerWeapon(playerid, gHolsterWeaponData[playerid][0], gHolsterWeaponData[playerid][1]);

	gHolsterWeaponData[playerid][0] = 0;
	gHolsterWeaponData[playerid][1] = 0;

	ShowMsgBox(playerid, "Weapon Equipped", 3000, 110);
	RemovePlayerAttachedObject(playerid, ATTACHSLOT_HOLSTER);

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
