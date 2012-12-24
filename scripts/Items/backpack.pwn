new
	ItemType:item_Backpack = INVALID_ITEM_TYPE,
	gPlayerBackpack[MAX_PLAYERS],
	bool:gTakingOffBag[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	gPlayerBackpack[playerid] = INVALID_ITEM_ID;
}

public OnItemCreate(itemid)
{
	if(GetItemType(itemid) == item_Backpack)
	{
		SetItemExtraData(itemid, CreateContainer("Backpack", 6, .virtual = 1));
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
	if(GetItemType(itemid) == item_Backpack)
	{
		if(!IsValidItem(gPlayerBackpack[playerid]))
		{
			gPlayerBackpack[playerid] = itemid;
			SetPlayerAttachedObject(playerid, 1, 3026, 1, -0.110900, -0.073500, 0.000000, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000);
			RemoveItemFromWorld(itemid);
		}
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

public OnPlayerOpenInventory(playerid, list[])
{
	if(IsValidItem(gPlayerBackpack[playerid]))
	{
		return 1;
	}

	return CallLocalFunction("pack_OnPlayerOpenInventory", "ds", playerid, list);
}
#if defined _ALS_OnPlayerOpenInventory
	#undef OnPlayerOpenInventory
#else
	#define _ALS_OnPlayerOpenInventory
#endif
#define OnPlayerOpenInventory pack_OnPlayerOpenInventory
forward pack_OnPlayerOpenInventory(playerid, list[]);

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsValidItem(gPlayerBackpack[playerid]))
	{
		if(newkeys & KEY_CTRL_BACK)
		{
			if(IsValidItem(gPlayerBackpack[playerid]))
				DisplayContainerInventory(playerid, GetItemExtraData(gPlayerBackpack[playerid]), 1);
		}
		else if(newkeys & KEY_NO)
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
}

public OnPlayerDropItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Backpack && gTakingOffBag[playerid])
	{
		gTakingOffBag[playerid] = false;
		return 1;
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
