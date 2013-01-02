#include <YSI\y_hooks>


#define CFT_MAX_COMBO (16)


enum E_CRAFT_COMBO_DATA
{
ItemType:	cft_item1,
ItemType:	cft_item2,
ItemType:	cft_result
}


static 
ItemType:	cft_Data[CFT_MAX_COMBO][E_CRAFT_COMBO_DATA],
Iterator:	cft_Index<CFT_MAX_COMBO>;

static
			cft_SelectedInvSlot[MAX_PLAYERS];


forward ItemType:GetItemComboResult(ItemType:item1, ItemType:item2);


DefineItemCombo(ItemType:item1, ItemType:item2, ItemType:result)
{
	new id = Iter_Free(cft_Index);
	if(id == -1)
		return -1;

	cft_Data[id][cft_item1] = item1;
	cft_Data[id][cft_item2] = item2;
	cft_Data[id][cft_result] = result;

	Iter_Add(cft_Index, id);

	return id;
}

public OnPlayerViewInventoryOptions(playerid)
{
	AddInventoryOption("Combine");
}
public OnPlayerSelectInventoryOption(playerid, option)
{
	if(option == 0)
	{
		cft_SelectedInvSlot[playerid] = GetPlayerSelectedInventorySlot(playerid);

		DisplayCombineInventory(playerid);
	}
}

DisplayCombineInventory(playerid)
{
	new
		list[INV_MAX_SLOTS * (MAX_ITEM_NAME + 1)],
		tmp[MAX_ITEM_NAME];
	
	for(new i; i < INV_MAX_SLOTS; i++)
	{
		if(!IsValidItem(GetInventorySlotItem(playerid, i)))
			strcat(list, "<Empty>\n");

		else
		{
			GetItemTypeName(GetItemType(GetInventorySlotItem(playerid, i)), tmp);
			strcat(list, tmp);
			strcat(list, "\n");
		}
	}

	ShowPlayerDialog(playerid, d_InventoryCombine, DIALOG_STYLE_LIST, "Inventory", list, "Combine", "Close");
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_InventoryCombine)
	{
		// If the player picks the same inventory item as the one he is trying to combine
		// Or if he picks an empty slot, re-render the dialog.
		// You can't combine something with itself or nothing, that's like dividing by zero!

		if(listitem == GetPlayerSelectedInventorySlot(playerid) || !IsInventorySlotUsed(playerid, listitem))
		{
			DisplayCombineInventory(playerid);
			return 1;
		}

		// Get the item combination result, AKA the item that the two items will create.

		new ItemType:result = GetItemComboResult(
			GetItemType(GetInventorySlotItem(playerid, GetPlayerSelectedInventorySlot(playerid))),
			GetItemType(GetInventorySlotItem(playerid, listitem)) );

		// The above function returns an invalid item if there is no combination
		// If it's valid then delete the original items and add the new one to the inventory.

		if(IsValidItemType(result))
		{
			new newitem = CreateItem(result, 0.0, 0.0, 0.0);

			DestroyItem(GetInventorySlotItem(playerid, GetPlayerSelectedInventorySlot(playerid)));
			DestroyItem(GetInventorySlotItem(playerid, listitem));

			// Remove from the highest slot first
			// Because the remove code shifts other inventory items up by 1 slot.

			if(GetPlayerSelectedInventorySlot(playerid) > listitem)
			{
				RemoveItemFromInventory(playerid, GetPlayerSelectedInventorySlot(playerid));
				RemoveItemFromInventory(playerid, listitem);
			}
			else
			{
				RemoveItemFromInventory(playerid, listitem);
				RemoveItemFromInventory(playerid, GetPlayerSelectedInventorySlot(playerid));
			}

			AddItemToInventory(playerid, newitem);

			DisplayPlayerInventory(playerid);
		}

		// If it's not valid, re-render the dialog.

		else DisplayCombineInventory(playerid);
	}

	return 1;
}

ItemType:GetItemComboResult(ItemType:item1, ItemType:item2)
{
	// Loop through all "recipe" item combinations
	// If a match is found, return that combo result.
	foreach(new i : cft_Index)
	{
		if(cft_Data[i][cft_item1] == item1 && cft_Data[i][cft_item2] == item2)
			return cft_Data[i][cft_result];

		if(cft_Data[i][cft_item2] == item1 && cft_Data[i][cft_item1] == item2)
			return cft_Data[i][cft_result];
	}

	// If no match is found, return an invalid item type.

	return INVALID_ITEM_TYPE;
}