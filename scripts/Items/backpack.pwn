#include <YSI\y_hooks>


new
	ItemType:item_Backpack = INVALID_ITEM_TYPE,
	ItemType:item_Satchel = INVALID_ITEM_TYPE,
	gPlayerBackpack[MAX_PLAYERS],
	pack_InventoryOptionID[MAX_PLAYERS],
	bool:gTakingOffBag[MAX_PLAYERS];


stock GivePlayerBackpack(playerid, itemid)
{
	if(GetItemType(itemid) == item_Backpack)
	{
		gPlayerBackpack[playerid] = itemid;
		SetPlayerAttachedObject(playerid, 1, 3026, 1, -0.110900, -0.073500, 0.000000, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000);
		RemoveItemFromWorld(itemid);
	}
	else if(GetItemType(itemid) == item_Satchel)
	{
		gPlayerBackpack[playerid] = itemid;
		SetPlayerAttachedObject(playerid, 1, 363, 1, 0.241894, -0.160918, 0.181463, 0.000000, 90.000000, 0.000000, 1.000000, 1.000000, 1.000000);
		RemoveItemFromWorld(itemid);
	}
	else
	{
		return 0;
	}

	return 1;
}

stock RemovePlayerBackpack(playerid)
{
	RemovePlayerAttachedObject(playerid, 1);
	CreateItemInWorld(gPlayerBackpack[playerid], 0.0, 0.0, 0.0, .world = GetPlayerVirtualWorld(playerid), .interior = GetPlayerInterior(playerid));
	gPlayerBackpack[playerid] = INVALID_ITEM_ID;
}

stock GetPlayerBackpackItem(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return INVALID_ITEM_ID;

	return gPlayerBackpack[playerid];
}

hook OnPlayerConnect(playerid)
{
	gPlayerBackpack[playerid] = INVALID_ITEM_ID;
}

public OnItemCreate(itemid)
{
	if(GetItemType(itemid) == item_Backpack)
	{
		SetItemExtraData(itemid, CreateContainer("Backpack", 8, .virtual = 1));
	}
	if(GetItemType(itemid) == item_Satchel)
	{
		SetItemExtraData(itemid, CreateContainer("Patrol Pack", 4, .virtual = 1));
	}

	return CallLocalFunction("pack_OnItemCreate", "d", itemid);
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
#define OnItemCreate pack_OnItemCreate
forward pack_OnItemCreate(itemid);


public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Backpack || GetItemType(itemid) == item_Satchel)
	{
		DisplayContainerInventory(playerid, GetItemExtraData(itemid), 1);
	}
	return CallLocalFunction("pack_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem pack_OnPlayerUseItem
forward pack_OnPlayerUseItem(playerid, itemid);

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerInAnyVehicle(playerid))
		return 1;

	if(IsValidItem(gPlayerBackpack[playerid]))
	{
/*
		if(newkeys & KEY_CTRL_BACK)
		{
			if(IsValidItem(gPlayerBackpack[playerid]))
				DisplayContainerInventory(playerid, GetItemExtraData(gPlayerBackpack[playerid]), 1);
		}
*/
		if(newkeys & KEY_NO)
		{
			if(!IsValidItem(GetPlayerItem(playerid)))
			{
				RemovePlayerAttachedObject(playerid, 1);
				CreateItemInWorld(gPlayerBackpack[playerid], 0.0, 0.0, 0.0, .world = GetPlayerVirtualWorld(playerid), .interior = GetPlayerInterior(playerid));
				GiveWorldItemToPlayer(playerid, gPlayerBackpack[playerid], 1);
				gPlayerBackpack[playerid] = INVALID_ITEM_ID;
				gTakingOffBag[playerid] = true;
			}
		}
	}
	else
	{
		if(newkeys & KEY_YES)
		{
			new itemid = GetPlayerItem(playerid);

			if(GetItemType(itemid) == item_Satchel || GetItemType(itemid) == item_Backpack)
				GivePlayerBackpack(playerid, itemid);
		}
	}

	return 1;
}

public OnPlayerAddToInventory(playerid, itemid)
{
	if(IsPlayerInventoryFull(playerid))
	{
		new
			containerid = GetItemExtraData(gPlayerBackpack[playerid]),
			containername[MAX_CONTAINER_NAME];

		GetContainerName(containerid, containername);

		if(AddItemToContainer(containerid, itemid))
		{
			new str[32];
			format(str, 32, "Item added to %s", containername);
			ShowMsgBox(playerid, str, 3000, 150);
			return 1;
		}
		else
		{
			new str[32];
			format(str, 32, "%s full", containername);
			ShowMsgBox(playerid, str, 3000, 100);
			return 1;
		}
	}

	return CallLocalFunction("pack_OnPlayerAddToInventory", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerAddToInventory
	#undef OnPlayerAddToInventory
#else
	#define _ALS_OnPlayerAddToInventory
#endif
#define OnPlayerAddToInventory pack_OnPlayerAddToInventory
forward pack_OnPlayerAddToInventory(playerid, itemid);

public OnPlayerDropItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Backpack || GetItemType(itemid) == item_Satchel)
	{
		if(gTakingOffBag[playerid])
		{
			gTakingOffBag[playerid] = false;
			return 1;
		}
	}

	return CallLocalFunction("pack_OnPlayerDropItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerDropItem
	#undef OnPlayerDropItem
#else
	#define _ALS_OnPlayerDropItem
#endif
#define OnPlayerDropItem pack_OnPlayerDropItem
forward pack_OnPlayerDropItem(playerid, itemid);

public OnPlayerGiveItem(playerid, targetid, itemid)
{
	if(GetItemType(itemid) == item_Backpack || GetItemType(itemid) == item_Satchel)
	{
		if(gTakingOffBag[playerid])
		{
			gTakingOffBag[playerid] = false;
			return 1;
		}
	}

	return CallLocalFunction("pack_OnPlayerGiveItem", "ddd", playerid, targetid, itemid);
}
#if defined _ALS_OnPlayerGiveItem
	#undef OnPlayerGiveItem
#else
	#define _ALS_OnPlayerGiveItem
#endif
#define OnPlayerGiveItem pack_OnPlayerGiveItem
forward pack_OnPlayerGiveItem(playerid, targetid, itemid);

public OnPlayerViewInventoryOpt(playerid)
{
	if(IsValidItem(gPlayerBackpack[playerid]))
	{
		pack_InventoryOptionID[playerid] = AddInventoryOption(playerid, "Remove");
	}

	return CallLocalFunction("pack_PlayerViewInventoryOpt", "d", playerid);
}
#if defined _ALS_OnPlayerViewInventoryOpt
	#undef OnPlayerViewInventoryOpt
#else
	#define _ALS_OnPlayerViewInventoryOpt
#endif
#define OnPlayerViewInventoryOpt pack_PlayerViewInventoryOpt
forward OnPlayerViewInventoryOpt(playerid);

public OnPlayerSelectInventoryOpt(playerid, option)
{
	if(IsValidItem(gPlayerBackpack[playerid]))
	{
		if(option == pack_InventoryOptionID[playerid])
		{
			new
				containerid,
				slot,
				itemid;
			
			containerid = GetItemExtraData(gPlayerBackpack[playerid]);
			slot = GetPlayerSelectedInventorySlot(playerid);
			itemid = GetInventorySlotItem(playerid, slot);

			if(!IsValidItem(itemid))
			{
				DisplayPlayerInventory(playerid);
				return 0;
			}

			if(IsContainerFull(containerid))
			{
				new
					str[MAX_CONTAINER_NAME + 6],
					name[MAX_CONTAINER_NAME];

				GetContainerName(containerid, name);
				format(str, sizeof(str), "%s full", name);
				ShowMsgBox(playerid, str, 3000, 100);
				DisplayPlayerInventory(playerid);
				return 0;
			}

			RemoveItemFromInventory(playerid, slot);
			AddItemToContainer(containerid, itemid, playerid);
			DisplayPlayerInventory(playerid);
		}
	}

	return CallLocalFunction("pack_PlayerSelectInventoryOption", "dd", playerid, option);
}
#if defined _ALS_OnPlayerSelectInventoryOpt
	#undef OnPlayerSelectInventoryOpt
#else
	#define _ALS_OnPlayerSelectInventoryOpt
#endif
#define OnPlayerSelectInventoryOpt pack_PlayerSelectInventoryOpt
forward OnPlayerSelectInventoryOpt(playerid, option);

