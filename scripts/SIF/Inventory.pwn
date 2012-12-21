// Setup


#include <YSI\y_hooks>


#define INV_MAX_SLOTS (4)


new
	inv_Data[MAX_PLAYERS][INV_MAX_SLOTS],
	inv_SelectedSlot[MAX_PLAYERS];


forward OnPlayerAddToInventory(playerid, itemid);



// Zeroing



hook OnGameModeInit()
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		for(new j; j < INV_MAX_SLOTS; j++)
		{
			inv_Data[i][j] = INVALID_ITEM_ID;
		}
	}
}

hook OnPlayerConnect(playerid)
{
	for(new j; j < INV_MAX_SLOTS; j++)
		inv_Data[playerid][j] = INVALID_ITEM_ID;

	return;
}



// Core



stock AddItemToInventory(playerid, itemid)
{
	new i;
	while(i < INV_MAX_SLOTS)
	{
		if(!IsValidItem(inv_Data[playerid][i]))break;
		i++;
	}
	if(i == INV_MAX_SLOTS)return 0;
	
	inv_Data[playerid][i] = itemid;

	RemoveItemFromWorld(itemid);

	return 1;
}
stock RemoveItemFromInventory(playerid, slotid)
{
	if(!(0 <= slotid < INV_MAX_SLOTS))
		return 0;

	inv_Data[playerid][slotid] = INVALID_ITEM_ID;
	
	if(slotid < (INV_MAX_SLOTS - 1))
	{
		for(new i = slotid; i < (INV_MAX_SLOTS - 1); i++)
		    inv_Data[playerid][i] = inv_Data[playerid][i+1];

		inv_Data[playerid][(INV_MAX_SLOTS - 1)] = INVALID_ITEM_ID;
	}
	
	return 1;
}

stock DisplayPlayerInventory(playerid, dialogid, optiontext[])
{
	new
		list[INV_MAX_SLOTS * (MAX_ITEM_NAME + 1)],
		tmp[MAX_ITEM_NAME];
	
	for(new i; i < INV_MAX_SLOTS; i++)
	{
		if(!IsValidItem(inv_Data[playerid][i])) strcat(list, "<Empty>\n");
		else
		{
			GetItemTypeName(GetItemType(inv_Data[playerid][i]), tmp);
			strcat(list, tmp);
			strcat(list, "\n");
		}
	}
	
	ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, "Inventory", list, optiontext, "Close");
}



// Internal



hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_CTRL_BACK)
	{
		if(!IsPlayerInAnyVehicle(playerid))
			DisplayPlayerInventory(playerid, d_Inventory, "Options");
	}
	if(newkeys & KEY_YES)
	{
		new itemid = GetPlayerItem(playerid);
		
		if(IsValidItem(itemid))
		{
			if(CallLocalFunction("OnPlayerAddToInventory", "dd", playerid, itemid))
				return 0;

			if(GetItemSize(itemid) != ITEM_SIZE_SMALL)
				Msg(playerid, ORANGE, " >  That item is too big for your pocket!");

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

DisplayPlayerInventoryOptions(playerid, slotid)
{
	new tmp[MAX_ITEM_NAME];

	GetItemTypeName(GetItemType(inv_Data[playerid][slotid]), tmp);

	ShowPlayerDialog(playerid, d_InventoryOptions, DIALOG_STYLE_LIST, tmp, "Equip\nCombine", "Accept", "Back");
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_Inventory)
	{
		if(response)
		{
			inv_SelectedSlot[playerid] = listitem;
			DisplayPlayerInventoryOptions(playerid, listitem);
		}
	}
	if(dialogid == d_InventoryOptions)
	{
		switch(listitem)
		{
			case 0:
			{
				if(GetPlayerItem(playerid) == INVALID_ITEM_ID && GetPlayerWeapon(playerid) == 0)
				{
					GiveWorldItemToPlayer(playerid, inv_Data[playerid][inv_SelectedSlot[playerid]], 1);
					RemoveItemFromInventory(playerid, inv_SelectedSlot[playerid]);
				}
				else
				{
				    Msg(playerid, ORANGE, " >  You are already holding something");
					DisplayPlayerInventory(playerid, d_Inventory, "Options");
				}
			}
			case 1: DisplayPlayerInventory(playerid, d_InventoryCombine, "Combine");
		}
	}
	return 1;
}


// Interface


stock GetInventorySlotItem(playerid, slotid)
{
	if(!(0 <= slotid < INV_MAX_SLOTS))return INVALID_ITEM_ID;
	return inv_Data[playerid][slotid];
}

stock IsInventorySlotUsed(playerid, slotid)
{
	if(!(0 <= slotid < INV_MAX_SLOTS))return -1;
	if(!IsValidItem(inv_Data[playerid][slotid]))return 0;
	return 1;
}

stock IsPlayerInventoryFull(playerid)
{
	return IsValidItem(inv_Data[playerid][INV_MAX_SLOTS-1]);
}