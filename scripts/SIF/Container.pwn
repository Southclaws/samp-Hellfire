/*==============================================================================

Southclaw's Interactivity Framework (SIF) (Formerly: Adventure API)


	SIF/Overview
	{
		SIF is a collection of high-level include scripts to make the
		development of interactive features easy for the developer while
		maintaining quality front-end gameplay for players.
	}

	SIF/Container/Description
	{
	}

	SIF/Container/Dependencies
	{
		SIF/Button
		Streamer Plugin
		YSI\y_hooks
		YSI\y_timers
	}

	SIF/Container/Credits
	{
		SA:MP Team						- Amazing mod!
		SA:MP Community					- Inspiration and support
		Incognito						- Very useful streamer plugin
		Y_Less							- YSI framework
	}

	SIF/Container/Core Functions
	{
		The functions that control the core features of this script.

		native -
		native - SIF/Container/Core
		native -

		native CreateContainer(name[], size, Float:x = 0.0, Float:y = 0.0, Float:z = 0.0, world = 0, interior = 0, label = 1, virtual = 0)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native DestroyContainer(containerid)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native AddItemToContainer(containerid, itemid, playerid = INVALID_PLAYER_ID)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native RemoveItemFromContainer(containerid, slotid, playerid = INVALID_PLAYER_ID)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native DisplayContainerInventory(playerid, containerid, showoptions = 0)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}
	}

	SIF/Container/Events
	{
		Events called by player actions done by using features from this script.

		native -
		native - SIF/Container/Callbacks
		native -

		native OnPlayerOpenContainer(playerid, containerid);
		{
			Called:
				-

			Parameters:
				-

			Returns:
				-
		}

		native OnPlayerCloseContainer(playerid, containerid);
		{
			Called:
				-

			Parameters:
				-

			Returns:
				-
		}
		native OnPlayerAddToContainer(playerid, containerid, itemid);
		{
			Called:
				-

			Parameters:
				-

			Returns:
				-
		}

		native OnPlayerTakeFromContainer(playerid, containerid, slotid);
		{
			Called:
				-

			Parameters:
				-

			Returns:
				-
		}

		native OnPlayerViewContainerOpt(playerid, containerid);
		{
			Called:
				-

			Parameters:
				-

			Returns:
				-
		}

		native OnPlayerSelectContainerOpt(playerid, containerid, option);
		{
			Called:
				-

			Parameters:
				-

			Returns:
				-
		}
	}

	SIF/Container/Interface Functions
	{
		Functions to get or set data values in this script without editing
		the data directly. These include automatic ID validation checks.

		native -
		native - SIF/Container/Interface
		native -

		native IsValidContainer(containerid)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native GetContainerButton(containerid)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native GetContainerName(containerid, name[])
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native GetContainerPos(containerid, &Float:x, &Float:y, &Float:z)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native SetContainerPos(containerid, Float:x, Float:y, Float:z)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native GetContainerSize(containerid)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native SetContainerSize(containerid, size)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native GetContainerWorld(containerid)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native SetContainerWorld(containerid, world)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native GetContainerInterior(containerid)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native SetContainerInterior(containerid, interior)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native GetPlayerCurrentContainer(playerid)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native GetPlayerContainerButtonArea(playerid)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native GetPlayerContainerSlot(playerid)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native GetContainerSlotItem(containerid, slot)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}
	}

	SIF/Container/Internal Functions
	{
		Internal events called by player actions done by using features from
		this script.
	
		DisplayContainerOptions(playerid, slotid)
		{
			Description:
				-
		}
	}

	SIF/Container/Hooks
	{
		Hooked functions or callbacks, either SA:MP natives or from other
		scripts or plugins.

		SAMP/OnPlayerConnect
		{
			Reason:
				-
		}
		SAMP/OnDialogResponse
		{
			Reason:
				-
		}
		SIF/Button/OnButtonPress
		{
			Reason:
				-
		}
		SIF/Inventory/OnPlayerAddToInventory
		{
			Reason:
				-
		}
	}

==============================================================================*/


/*==============================================================================

	Setup

==============================================================================*/


#include <YSI\y_hooks>


#define MAX_CONTAINER			(3000)
#define MAX_CONTAINER_NAME		(32)
#define MAX_CONTAINER_SLOTS		(12)

#define INVALID_CONTAINER_ID	(-1)


enum E_CONTAINER_DATA
{
			cnt_button,
			cnt_name					[MAX_CONTAINER_NAME],
Float:		cnt_posX,
Float:		cnt_posY,
Float:		cnt_posZ,
			cnt_size,
			cnt_world,
			cnt_interior
}


static
			cnt_Data					[MAX_CONTAINER][E_CONTAINER_DATA],
			cnt_Items					[MAX_CONTAINER][MAX_CONTAINER_SLOTS],
Iterator:	cnt_Index<MAX_CONTAINER>;

static
			cnt_CurrentContainer		[MAX_PLAYERS],
			cnt_SelectedSlot			[MAX_PLAYERS],
			cnt_InventoryContainerItem	[MAX_PLAYERS],
			cnt_ContainerOptions		[MAX_PLAYERS],
			cnt_InventoryOptionID		[MAX_PLAYERS];


forward OnPlayerOpenContainer(playerid, containerid);
forward OnPlayerCloseContainer(playerid, containerid);
forward OnPlayerAddToContainer(playerid, containerid, itemid);
forward OnPlayerTakeFromContainer(playerid, containerid, slotid);
forward OnPlayerViewContainerOpt(playerid, containerid);
forward OnPlayerSelectContainerOpt(playerid, containerid, option);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnPlayerConnect(playerid)
{
	cnt_CurrentContainer[playerid] = INVALID_CONTAINER_ID;
}


/*==============================================================================

	Core Functions

==============================================================================*/


stock CreateContainer(name[], size, Float:x = 0.0, Float:y = 0.0, Float:z = 0.0, world = 0, interior = 0, label = 1, virtual = 0)
{
	new id = Iter_Free(cnt_Index);

	if(id == -1)
		return INVALID_CONTAINER_ID;

	if(!virtual)
		cnt_Data[id][cnt_button] = CreateButton(x, y, z, "Press F to open", world, interior, 1.0, label, name);

	strcpy(cnt_Data[id][cnt_name], name, MAX_CONTAINER_NAME);
	cnt_Data[id][cnt_posX]		= x;
	cnt_Data[id][cnt_posY]		= y;
	cnt_Data[id][cnt_posZ]		= z;
	cnt_Data[id][cnt_size]		= size;
	cnt_Data[id][cnt_world]		= world;
	cnt_Data[id][cnt_interior]	= interior;

	for(new i; i < size; i++)
		cnt_Items[id][i] = INVALID_ITEM_ID;

	Iter_Add(cnt_Index, id);

	return id;
}

stock DestroyContainer(containerid)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	DestroyButton(cnt_Data[containerid][cnt_button]);

	for(new i; i < cnt_Data[containerid][cnt_size]; i++)
		DestroyItem(cnt_Items[containerid][i]);

	cnt_Data[containerid][cnt_name][0]	= EOS;
	cnt_Data[containerid][cnt_posX]		= 0.0;
	cnt_Data[containerid][cnt_posY]		= 0.0;
	cnt_Data[containerid][cnt_posZ]		= 0.0;
	cnt_Data[containerid][cnt_size]		= 0;
	cnt_Data[containerid][cnt_world]	= 0;
	cnt_Data[containerid][cnt_interior]	= 0;

	Iter_Remove(cnt_Index, containerid);

	return 1;
}

stock AddItemToContainer(containerid, itemid, playerid = INVALID_PLAYER_ID)
{
	if(!IsValidItem(itemid))
		return 0;

	if(playerid != INVALID_PLAYER_ID)
	{
		if(CallLocalFunction("OnPlayerAddToContainer", "ddd", playerid, containerid, itemid))
			return 1;
	}

	new i;
	while(i < cnt_Data[containerid][cnt_size])
	{
		if(!IsValidItem(cnt_Items[containerid][i]))break;
		i++;
	}
	if(i == cnt_Data[containerid][cnt_size])return 0;
	
	cnt_Items[containerid][i] = itemid;

	RemoveItemFromWorld(itemid);

	return 1;
}

stock RemoveItemFromContainer(containerid, slotid, playerid = INVALID_PLAYER_ID)
{
	if(!(0 <= slotid < cnt_Data[containerid][cnt_size]))
		return 0;

	if(playerid != INVALID_PLAYER_ID)
	{
		if(CallLocalFunction("OnPlayerTakeFromContainer", "ddd", playerid, containerid, slotid))
			return 1;
	}

	cnt_Items[containerid][slotid] = INVALID_ITEM_ID;
	
	if(slotid < (cnt_Data[containerid][cnt_size] - 1))
	{
		for(new i = slotid; i < (cnt_Data[containerid][cnt_size] - 1); i++)
		    cnt_Items[containerid][i] = cnt_Items[containerid][i+1];

		cnt_Items[containerid][(cnt_Data[containerid][cnt_size] - 1)] = INVALID_ITEM_ID;
	}
	
	return 1;
}

stock DisplayContainerInventory(playerid, containerid, showoptions = 0)
{
	new
		list[MAX_CONTAINER_SLOTS * (MAX_ITEM_NAME + 1)],
		tmp[MAX_ITEM_NAME];

	for(new i; i < cnt_Data[containerid][cnt_size]; i++)
	{
		if(!IsValidItem(cnt_Items[containerid][i])) strcat(list, "<Empty>\n");
		else
		{
			GetItemTypeName(GetItemType(cnt_Items[containerid][i]), tmp);
			strcat(list, tmp);
			strcat(list, "\n");
		}
	}

	strcat(list, "My Inventory >");

	cnt_CurrentContainer[playerid] = containerid;
	cnt_ContainerOptions[playerid] = showoptions;

	if(CallLocalFunction("OnPlayerOpenContainer", "dd", playerid, containerid))
		return 0;

	if(!showoptions)
		ShowPlayerDialog(playerid, d_ContainerInventory, DIALOG_STYLE_LIST, cnt_Data[containerid][cnt_name], list, "Take", "Close");

	else
		ShowPlayerDialog(playerid, d_ContainerInventory, DIALOG_STYLE_LIST, cnt_Data[containerid][cnt_name], list, "Options", "Close");

	SelectTextDraw(playerid, 0xFFFF00FF);

	return 1;
}

ClosePlayerContainer(playerid)
{
	ShowPlayerDialog(playerid, -1, 0, "", "", "", "");
	cnt_CurrentContainer[playerid] = INVALID_CONTAINER_ID;
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


DisplayContainerOptions(playerid, slotid)
{
	new tmp[MAX_ITEM_NAME];

	GetItemTypeName(GetItemType(cnt_Items[cnt_CurrentContainer[playerid]][slotid]), tmp);

	CallLocalFunction("OnPlayerViewContainerOpt", "dd", playerid, cnt_CurrentContainer[playerid]);

	if(GetItemTypeSize(GetItemType(cnt_Items[cnt_CurrentContainer[playerid]][slotid])) == ITEM_SIZE_SMALL)
		ShowPlayerDialog(playerid, d_ContainerOptions, DIALOG_STYLE_LIST, tmp, "Equip\nTake", "Accept", "Back");

	else
		ShowPlayerDialog(playerid, d_ContainerOptions, DIALOG_STYLE_LIST, tmp, "Equip", "Accept", "Back");
}

public OnButtonPress(playerid, buttonid)
{
	foreach(new i : cnt_Index)
	{
		if(buttonid == cnt_Data[i][cnt_button])
		{
			DisplayContainerInventory(playerid, i);
			break;
		}
	}

	return CallLocalFunction("cnt_OnButtonPress", "dd", playerid, buttonid);
}
#if defined _ALS_OnButtonPress
	#undef OnButtonPress
#else
	#define _ALS_OnButtonPress
#endif
#define OnButtonPress cnt_OnButtonPress
forward OnButtonPress(playerid, buttonid);

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_ContainerInventory)
	{
		if(response)
		{
			if(listitem == cnt_Data[cnt_CurrentContainer[playerid]][cnt_size])
				DisplayPlayerInventory(playerid);

			else
			{
				new id = cnt_Items[cnt_CurrentContainer[playerid]][listitem];
				if(!IsValidItem(id))
				{
					DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid], cnt_ContainerOptions[playerid]);
					return 0;
				}

				if(cnt_ContainerOptions[playerid])
				{
					cnt_SelectedSlot[playerid] = listitem;
					DisplayContainerOptions(playerid, listitem);
				}
				else
				{

					if(IsPlayerInventoryFull(playerid) || !IsValidItem(id))
					{
						DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid], cnt_ContainerOptions[playerid]);
						return 0;
					}

					RemoveItemFromContainer(cnt_CurrentContainer[playerid], listitem, playerid);
					AddItemToInventory(playerid, id);
					DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid], cnt_ContainerOptions[playerid]);
				}
			}
		}
		else
		{
			CallLocalFunction("OnPlayerCloseContainer", "dd", playerid, cnt_CurrentContainer[playerid]);
			CancelSelectTextDraw(playerid);
			cnt_CurrentContainer[playerid] = INVALID_CONTAINER_ID;
		}
	}

	if(dialogid == d_ContainerOptions)
	{
		switch(listitem)
		{
			case 0:
			{
				if(GetPlayerItem(playerid) == INVALID_ITEM_ID && GetPlayerWeapon(playerid) == 0)
				{
					new id = cnt_Items[cnt_CurrentContainer[playerid]][cnt_SelectedSlot[playerid]];

					RemoveItemFromContainer(cnt_CurrentContainer[playerid], cnt_SelectedSlot[playerid], playerid);
					CreateItemInWorld(id);
					GiveWorldItemToPlayer(playerid, id, 1);
					DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid], cnt_ContainerOptions[playerid]);
				}
				else
				{
					ShowMsgBox(playerid, "You are already holding something", 3000, 200);
					DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid], cnt_ContainerOptions[playerid]);
				}
			}
			case 1:
			{
				new id = cnt_Items[cnt_CurrentContainer[playerid]][cnt_SelectedSlot[playerid]];

				if(IsPlayerInventoryFull(playerid) || !IsValidItem(id))
				{
					ShowMsgBox(playerid, "Inventory full", 3000, 100);
					DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid], cnt_ContainerOptions[playerid]);
					return 0;
				}

				RemoveItemFromContainer(cnt_CurrentContainer[playerid], cnt_SelectedSlot[playerid], playerid);
				AddItemToInventory(playerid, id);
				DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid], cnt_ContainerOptions[playerid]);
			}
			case 2:
			{
				CallLocalFunction("OnPlayerSelectContInvOpt", "ddd", playerid, cnt_CurrentContainer[playerid], listitem - 2);
			}
		}
	}

	return 1;
}

public OnPlayerAddToInventory(playerid, itemid)
{
	if(IsPlayerInAnyDynamicArea(playerid))
	{
		foreach(new i : cnt_Index)
		{
			if(GetPlayerButtonID(playerid) == cnt_Data[i][cnt_button])
			{
				if(AddItemToContainer(i, itemid, playerid))
				{
					new str[32];
					format(str, 32, "Item added to %s", cnt_Data[i][cnt_name]);
					ShowMsgBox(playerid, str, 3000, 150);
					return 1;
				}
				else
				{
					new str[32];
					format(str, 32, "%s full", cnt_Data[i][cnt_name]);
					ShowMsgBox(playerid, str, 3000, 100);
					return 1;
				}
			}
		}
	}
	
	return CallLocalFunction("cnt_OnPlayerAddToInventory", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerAddToInventory
	#undef OnPlayerAddToInventory
#else
	#define _ALS_OnPlayerAddToInventory
#endif
#define OnPlayerAddToInventory cnt_OnPlayerAddToInventory
forward OnPlayerAddToInventory(playerid, itemid);

public OnPlayerViewInventoryOpt(playerid)
{
	if(cnt_CurrentContainer[playerid] != INVALID_CONTAINER_ID)
	{
		cnt_InventoryOptionID[playerid] = AddInventoryOption(playerid, "Remove");
	}

	return CallLocalFunction("cnt_OnPlayerViewInventoryOpt", "d", playerid);
}
#if defined _ALS_OnPlayerViewInventoryOpt
	#undef OnPlayerViewInventoryOpt
#else
	#define _ALS_OnPlayerViewInventoryOpt
#endif
#define OnPlayerViewInventoryOpt cnt_OnPlayerViewInventoryOpt
forward OnPlayerViewInventoryOpt(playerid);

public OnPlayerSelectInventoryOpt(playerid, option)
{
	if(cnt_CurrentContainer[playerid] != INVALID_CONTAINER_ID)
	{
		if(option == cnt_InventoryOptionID[playerid])
		{
			new
				slot,
				itemid;

			slot = GetPlayerSelectedInventorySlot(playerid);
			itemid = GetInventorySlotItem(playerid, slot);

			if(IsValidItem(cnt_Items[cnt_CurrentContainer[playerid]][cnt_Data[cnt_CurrentContainer[playerid]][cnt_size]-1]) || !IsValidItem(itemid))
			{
				DisplayPlayerInventory(playerid);
				return 0;
			}

			RemoveItemFromInventory(playerid, slot);
			AddItemToContainer(cnt_CurrentContainer[playerid], itemid, playerid);
			DisplayPlayerInventory(playerid);
		}
	}

	return CallLocalFunction("cnt_OnPlayerSelectInventoryOpt", "dd", playerid, option);
}
#if defined _ALS_OnPlayerSelectInventoryOpt
	#undef OnPlayerSelectInventoryOpt
#else
	#define _ALS_OnPlayerSelectInventoryOpt
#endif
#define OnPlayerSelectInventoryOpt cnt_OnPlayerSelectInventoryOpt
forward OnPlayerSelectInventoryOpt(playerid, option);

public OnPlayerOpenInventory(playerid)
{
	if(Iter_Contains(cnt_Index, cnt_CurrentContainer[playerid]))
	{
		new str[MAX_CONTAINER_NAME + 2];
		strcat(str, cnt_Data[cnt_CurrentContainer[playerid]][cnt_name]);
		strcat(str, " >");
		cnt_InventoryContainerItem[playerid] = AddInventoryListItem(playerid, str);
	}

	return CallLocalFunction("cnt_OnPlayerOpenInventory", "d", playerid);
}
#if defined _ALS_OnPlayerOpenInventory
	#undef OnPlayerOpenInventory
#else
	#define _ALS_OnPlayerOpenInventory
#endif
#define OnPlayerOpenInventory cnt_OnPlayerOpenInventory
forward OnPlayerOpenInventory(playerid);

public OnPlayerSelectExtraItem(playerid, item)
{
	if(Iter_Contains(cnt_Index, cnt_CurrentContainer[playerid]))
	{
		if(item == cnt_InventoryContainerItem[playerid])
		{
			DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid], cnt_ContainerOptions[playerid]);
		}
	}

	return CallLocalFunction("cnt_OnPlayerSelectExtraItem", "dd", playerid, item);
}
#if defined _ALS_OnPlayerSelectExtraItem
	#undef OnPlayerSelectExtraItem
#else
	#define _ALS_OnPlayerSelectExtraItem
#endif
#define OnPlayerSelectExtraItem cnt_OnPlayerSelectExtraItem
forward OnPlayerSelectExtraItem(playerid, item);


/*==============================================================================

	Interface

==============================================================================*/


stock IsValidContainer(containerid)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	return 1;
}

// cnt_button
stock GetContainerButton(containerid)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	return cnt_Data[containerid][cnt_button];
}

// cnt_name
stock GetContainerName(containerid, name[])
{
	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	name[0] = EOS;
	strcat(name, cnt_Data[containerid][cnt_name], MAX_CONTAINER_NAME);

	return 1;
}

// cnt_posX
// cnt_posY
// cnt_posZ
stock GetContainerPos(containerid, &Float:x, &Float:y, &Float:z)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	x = cnt_Data[containerid][cnt_posX];
	y = cnt_Data[containerid][cnt_posY];
	z = cnt_Data[containerid][cnt_posZ];

	return 1;
}
stock SetContainerPos(containerid, Float:x, Float:y, Float:z)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	SetButtonPos(cnt_Data[containerid][cnt_button], x, y, z);

	cnt_Data[containerid][cnt_posX] = x;
	cnt_Data[containerid][cnt_posY] = y;
	cnt_Data[containerid][cnt_posZ] = z;

	return 1;
}

// cnt_size
stock GetContainerSize(containerid)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return -1;

	return cnt_Data[containerid][cnt_size];
}
stock SetContainerSize(containerid, size)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	cnt_Data[containerid][cnt_size] = size;

	return 1;
}

// cnt_world
stock GetContainerWorld(containerid)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return -1;

	return cnt_Data[containerid][cnt_world];
}
stock SetContainerWorld(containerid, world)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	SetButtonWorld(cnt_Data[containerid][cnt_button], world);
	cnt_Data[containerid][cnt_world] = world;

	return 1;
}

// cnt_interior
stock GetContainerInterior(containerid)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return -1;

	return cnt_Data[containerid][cnt_interior];
}
stock SetContainerInterior(containerid, interior)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	SetButtonWorld(cnt_Data[containerid][cnt_button], interior);
	cnt_Data[containerid][cnt_interior] = interior;

	return 1;
}

// cnt_CurrentContainer
stock GetPlayerCurrentContainer(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return INVALID_CONTAINER_ID;

	return cnt_CurrentContainer[playerid];
}
stock GetPlayerContainerButtonArea(playerid)
{
	new button = GetPlayerButtonID(playerid);

	foreach(new i : cnt_Index)
		if(button == cnt_Data[i][cnt_button]) return i;

	return INVALID_CONTAINER_ID;
}

// cnt_SelectedSlot
stock GetPlayerContainerSlot(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return -1;

	return cnt_SelectedSlot[playerid];
}

// cnt_Items
stock GetContainerSlotItem(containerid, slotid)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return INVALID_ITEM_ID;

	if(!(0 <= slotid < MAX_CONTAINER_SLOTS))
		return INVALID_ITEM_ID;

	return cnt_Items[containerid][slotid];
}

stock IsContainerSlotUsed(containerid, slotid)
{
	if(!(0 <= slotid < MAX_CONTAINER_SLOTS))
		return -1;

	if(!IsValidItem(cnt_Items[containerid][slotid]))
		return 0;

	return 1;
}

stock IsContainerFull(containerid)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	return IsValidItem(cnt_Items[containerid][cnt_Data[containerid][cnt_size]-1]);
}
