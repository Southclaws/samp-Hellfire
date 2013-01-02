/*==============================================================================

Southclaw's Interactivity Framework (SIF) (Formerly: Adventure API)


	SIF/Overview
	{
		SIF is a collection of high-level include scripts to make the
		development of interactive features easy for the developer while
		maintaining quality front-end gameplay for players.
	}

	SIF/Inventory/Description
	{
		Offers extended item functionality using the virtual item feature in
		SIF/Item. This enables multiple items to be stored by players and
		retrieved when needed. It contains functions and callbacks for complete
		control from external scripts over inventory actions by players.
	}

	SIF/Inventory/Dependencies
	{
		SIF/Item
		Streamer Plugin
		YSI\y_hooks
	}

	SIF/Inventory/Credits
	{
		SA:MP Team						- Amazing mod!
		SA:MP Community					- Inspiration and support
		Incognito						- Very useful streamer plugin
		Y_Less							- YSI framework
	}

	SIF/Inventory/Core Functions
	{
		The functions that control the core features of this script.

		native -
		native - SIF/Inventory/Core
		native -

		native AddItemToInventory(playerid, itemid)
		{
			Description:
				Adds the specified item to a players inventory and removes the
				item from the world.

			Parameters:
				<playerid> (int)
					The player to add the item to.

				<itemid> (int, itemid)
					The ID handle of the item to add.

			Returns:
				0
					If the item specified is an invalid item ID.

				-1
					If the inventory is full.

				1
					If the function completed successfully.
		}

		native RemoveItemFromInventory(playerid, slotid)
		{
			Description:
				Removes the item from the specified slot if there is one.

			Parameters:
				<playerid> (int)
					The player to remove the item from.
				
				<slotid>
					The inventory slot, must be between 0 and INV_MAX_SLOT.

			Returns:
				0
					If the specified slot is invalid.
		}

		native DisplayPlayerInventory(playerid)
		{
			Description:
				Displays a dialog to the player listing his inventory contents.

			Parameters:
				-

			Returns:
				0
					If OnPlayerOpenInventory has returned true and cancelled
					displaying the dialog to the player.
		}
	}

	SIF/Inventory/Events
	{
		Events called by player actions done by using features from this script.

		native -
		native - SIF/Inventory/Callbacks
		native -

		native OnPlayerAddToInventory(playerid, itemid);
		{
			Called:
				When a player adds an item to his inventory by pressing Y.

			Parameters:
				<playerid> (int)
					The player who added an item to his inventory.

				<itemid> (int, itemid)
					The ID handle of the item that was added.

			Returns:
				1
					To cancel the action and disallow the player to add the
					item to his inventory.
		}

		native OnPlayerOpenInventory(playerid, list[]);
		{
			Called:
				When a player presses H to open his inventory.

			Parameters:
				<playerid> (int)
					The player who opened their inventory.

			Returns:
				1
					To cancel displaying the inventory to the player.
		}

		native OnPlayerViewInventoryOptions(playerid);
		{
			Called:
				When a player opens the options menu for an item in his
				inventory. This callback can be used to add extra options.

			Parameters:
				<playerid>
					The player who opened the options menu.

			Returns:
				(none)
		}

		native OnPlayerRemoveFromInventory(playerid, slotid);
		{
			Called:
				When a player removes an item from his inventory either by
				equipping it or dropping it.

			Parameters:
				<playerid> (int)
					The player who removed an item from his inventory.

				<slotid> (int)
					The inventory slot which he removed the item from.

			Returns:
				1
					To cancel the action and disallow the player from removing
					the item from his inventory.
		}

		native OnPlayerSelectInventoryOption(playerid, option);
		{
			Called:
				When a player selects an additional option from the item options
				menu. Note that this is only called when extra options are
				selected and not for the default Equip, Use and Drop options.

			Parameters:
				<playerid> (int)
					The player who selected an option in his inventory options.

				<option> (int)
					The option selected starting from 0, not the dialog
					listitem value. (it's listitem + number of default options)

			Returns:
				(none)
		}
	}

	SIF/Inventory/Interface Functions
	{
		Functions to get or set data values in this script without editing
		the data directly. These include automatic ID validation checks.

		native -
		native - SIF/Inventory/Interface
		native -

		native GetInventorySlotItem(playerid, slotid)
		{
			Description:
				Returns the ID handle of the item stored in the specified slot.

			Parameters:
				<slotid> (int)
					The slot to get the item ID of, from 0 to INV_MAX_SLOTS - 1.

			Returns:
				(int, itemid)
					ID handle of the item in the specified slot.

				INVALID_ITEM_ID
					If the slot was invalid or the slot is empty.
		}

		native IsInventorySlotUsed(playerid, slotid)
		{
			Description:
				Checks if the specified inventory slot contains an item.

			Parameters:
				<slotid> (int)
					The slot to check, from 0 to INV_MAX_SLOTS - 1.

			Returns:
				-1
					If the specified slot is invalid.

				0
					If the slot is used.

				1
					If the slot is empty.
		}

		native GetPlayerSelectedInventorySlot(playerid)
		{
			Description:
				Returns the inventory slot that the player is currently
				interacting with. The value this function returns will reset to
				-1 once the player exits his inventory menu.

			Parameters:
				-

			Returns:
				-1
					If the player has exited his inventory.
		}

		native IsPlayerInventoryFull(playerid)
		{
			Description:
				Checks if a players inventory is full. This is simply done by
				checking if the last slot is full as items are automatically
				shifted up the index when an item is removed.

			Parameters:
				-

			Returns:
				0
					If it isn't full.

				1
					If it is full.
		}

		native AddInventoryOption(option[])
		{
			Description:
				Only works properly when used in OnPlayerViewInventoryOptions.
				This function adds an option to the inventory item options list.
				The inventory options are addressed from 0, not the number of
				default options.

			Parameters:
				<option> (string)
					The option name, note that a new line character is not
					required as the function adds these automatically.

			Returns:
				0
					If the options string can't fit the specified option.
		}
	}

	SIF/Inventory/Internal Functions
	{
		Internal events called by player actions done by using features from
		this script.
	
		DisplayPlayerInventoryOptions(playerid, slotid)
		{
			Description:
				Displays the options menu and calls OnPlayerViewInventoryOptions
				in order to add any additional options.
		}
	}

	SIF/Inventory/Hooks
	{
		Hooked functions or callbacks, either SA:MP natives or from other
		scripts or plugins.

		SAMP/OnPlayerKeyStateChange
		{
			Reason:
				To detect if a player presses Y to put an item in their
				inventory or H to access their inventory.
		}
		SAMP/OnDialogResponse
		{
			Reason:
				To handle the dialogs used in the script for listing inventory
				items and item options.
		}
	}

==============================================================================*/


/*==============================================================================

	Setup

==============================================================================*/


#include <YSI\y_hooks>


#define INV_MAX_SLOTS (4)


new
	inv_Data[MAX_PLAYERS][INV_MAX_SLOTS],
	inv_SelectedSlot[MAX_PLAYERS],
	inv_OptionsList[128];


forward OnPlayerAddToInventory(playerid, itemid);
forward OnPlayerOpenInventory(playerid);
forward OnPlayerViewInventoryOptions(playerid);
forward OnPlayerRemoveFromInventory(playerid, slotid);
forward OnPlayerSelectInventoryOption(playerid, option);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnGameModeInit()
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		for(new j; j < INV_MAX_SLOTS; j++)
		{
			inv_Data[i][j] = INVALID_ITEM_ID;
			inv_SelectedSlot[i] = -1;
		}
	}
}

hook OnPlayerConnect(playerid)
{
	for(new j; j < INV_MAX_SLOTS; j++)
	{
		inv_Data[playerid][j] = INVALID_ITEM_ID;
		inv_SelectedSlot[i] = -1;
	}

	return;
}


/*==============================================================================

	Core Functions

==============================================================================*/


stock AddItemToInventory(playerid, itemid)
{
	if(!IsValidItem(itemid))
		return 0;

	new i;
	while(i < INV_MAX_SLOTS)
	{
		if(!IsValidItem(inv_Data[playerid][i]))break;
		i++;
	}
	if(i == INV_MAX_SLOTS)
		return -1;
	
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

stock DisplayPlayerInventory(playerid)
{
	new
		list[(INV_MAX_SLOTS * (MAX_ITEM_NAME + 1)) + 32],
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

	if(CallRemoteFunction("OnPlayerOpenInventory", "d", playerid))
		return 0;
	
	ShowPlayerDialog(playerid, d_Inventory, DIALOG_STYLE_LIST, "Inventory", list, "Options", "Close");

	return 1;
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_CTRL_BACK)
	{
		if(!IsPlayerInAnyVehicle(playerid))
			DisplayPlayerInventory(playerid);
	}
	if(newkeys & KEY_YES)
	{
		new itemid = GetPlayerItem(playerid);

		if(IsValidItem(itemid))
		{
			if(CallLocalFunction("OnPlayerAddToInventory", "dd", playerid, itemid))
				return 0;

			if(GetItemTypeSize(GetItemType(itemid)) != ITEM_SIZE_SMALL)
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
	new
		name[MAX_ITEM_NAME];

	GetItemTypeName(GetItemType(inv_Data[playerid][slotid]), name);
	inv_OptionsList = "Equip\nUse\nDrop\n";

	CallLocalFunction("OnPlayerViewInventoryOptions", "d", playerid);

	ShowPlayerDialog(playerid, d_InventoryOptions, DIALOG_STYLE_LIST, name, inv_OptionsList, "Accept", "Back");
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
		else
		{
			inv_SelectedSlot[playerid] = -1;
		}
	}
	if(dialogid == d_InventoryOptions)
	{
		if(!response)
		{
			DisplayPlayerInventory(playerid);
			return 1;
		}

		switch(listitem)
		{
			case 0:
			{
				if(GetPlayerItem(playerid) == INVALID_ITEM_ID && GetPlayerWeapon(playerid) == 0)
				{
					if(CallLocalFunction("OnPlayerRemoveFromInventory", "dd", playerid, inv_SelectedSlot[playerid]))
						return 0;

					new itemid = inv_Data[playerid][inv_SelectedSlot[playerid]];

					RemoveItemFromInventory(playerid, inv_SelectedSlot[playerid]);
					CreateItemInWorld(itemid);
					GiveWorldItemToPlayer(playerid, itemid, 1);
				}
				else
				{
					Msg(playerid, ORANGE, " >  You are already holding something");
					DisplayPlayerInventory(playerid);
				}
			}
			case 1:
			{
				if(GetPlayerItem(playerid) == INVALID_ITEM_ID && GetPlayerWeapon(playerid) == 0)
				{
					new itemid = inv_Data[playerid][inv_SelectedSlot[playerid]];

					RemoveItemFromInventory(playerid, inv_SelectedSlot[playerid]);
					CreateItemInWorld(itemid);
					GiveWorldItemToPlayer(playerid, itemid, 1);

					PlayerUseItem(playerid);
				}
				else
				{
					Msg(playerid, ORANGE, " >  You are already holding something");
					DisplayPlayerInventory(playerid);
				}
			}
			case 2:
			{
				if(GetPlayerItem(playerid) == INVALID_ITEM_ID && GetPlayerWeapon(playerid) == 0)
				{
					new itemid = inv_Data[playerid][inv_SelectedSlot[playerid]];

					RemoveItemFromInventory(playerid, inv_SelectedSlot[playerid]);
					CreateItemInWorld(itemid);
					GiveWorldItemToPlayer(playerid, itemid, 1);

					PlayerDropItem(playerid);
				}
				else
				{
					Msg(playerid, ORANGE, " >  You are already holding something");
					DisplayPlayerInventory(playerid);
				}
			}
			default:
			{
				CallLocalFunction("OnPlayerSelectInventoryOption", "dd", playerid, listitem - 3);
			}
		}
	}
	return 1;
}


/*==============================================================================

	Interface Functions

==============================================================================*/


stock GetInventorySlotItem(playerid, slotid)
{
	if(!(0 <= slotid < INV_MAX_SLOTS))
		return INVALID_ITEM_ID;

	return inv_Data[playerid][slotid];
}

stock IsInventorySlotUsed(playerid, slotid)
{
	if(!(0 <= slotid < INV_MAX_SLOTS))
		return -1;

	if(!IsValidItem(inv_Data[playerid][slotid]))
		return 0;

	return 1;
}

stock GetPlayerSelectedInventorySlot(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return -1;

	return inv_SelectedSlot[playerid];
}

stock IsPlayerInventoryFull(playerid)
{
	return IsValidItem(inv_Data[playerid][INV_MAX_SLOTS-1]);
}

stock AddInventoryOption(option[])
{
	if(strlen(inv_OptionsList) + strlen(option) > sizeof(inv_OptionsList))
		return 0;

	strcat(inv_OptionsList, option);
	strcat(inv_OptionsList, "\n");

	return 1;
}