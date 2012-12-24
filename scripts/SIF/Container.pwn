#include <YSI\y_hooks>


#define MAX_CONTAINER			(3000)
#define MAX_CONTAINER_NAME		(32)
#define MAX_CONTAINER_SLOTS		(12)

#define INVALID_CONTAINER_ID	(-1)


enum E_CONTAINER_DATA
{
			cnt_button,
			cnt_name[MAX_CONTAINER_NAME],
Float:		cnt_posX,
Float:		cnt_posY,
Float:		cnt_posZ,
			cnt_size,
			cnt_world,
			cnt_interior,
			cnt_attachedVehicle
}


new
			cnt_Data				[MAX_CONTAINER][E_CONTAINER_DATA],
			cnt_Items				[MAX_CONTAINER][MAX_CONTAINER_SLOTS],
Iterator:	cnt_Index<MAX_CONTAINER>;

new
			cnt_CurrentContainer	[MAX_PLAYERS],
			cnt_SelectedSlot		[MAX_PLAYERS],
			cnt_ContainerOptions	[MAX_PLAYERS];


stock CreateContainer(name[MAX_CONTAINER_NAME], size, Float:x = 0.0, Float:y = 0.0, Float:z = 0.0, world = 0, interior = 0, label = 1, virtual = 0)
{
	new id = Iter_Free(cnt_Index);

	if(id == -1)
		return INVALID_CONTAINER_ID;

	if(!virtual)
		cnt_Data[id][cnt_button] = CreateButton(x, y, z, "Press F to open", world, interior, 1.0, label, name);

	cnt_Data[id][cnt_name]		= name;
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

stock AttachContainerToVehicle(containerid, vehicleid)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	new
		Float:x,
		Float:y,
		Float:z;

	GetVehicleModelInfo(GetVehicleModel(vehicleid), VEHICLE_MODEL_INFO_SIZE, x, y, z);

	AttachButtonToVehicle(cnt_Data[containerid][cnt_button], vehicleid, 180.0, 25.0, y * 0.4, 0.5);
	cnt_Data[containerid][cnt_attachedVehicle] = vehicleid;

	return 1;
}

stock DetachContainerFromVehicle(containerid)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	DetachButtonFromVehicle(cnt_Data[containerid][cnt_button]);
	cnt_Data[containerid][cnt_attachedVehicle] = INVALID_VEHICLE_ID;

	return 1;
}

stock AddItemToContainer(containerid, itemid)
{
	if(!IsValidItem(itemid))
		return 0;

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

stock RemoveItemFromContainer(containerid, slotid)
{
	if(!(0 <= slotid < cnt_Data[containerid][cnt_size]))
		return 0;

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

	if(showoptions)
		ShowPlayerDialog(playerid, d_ContainerInventory, DIALOG_STYLE_LIST, cnt_Data[containerid][cnt_name], list, "Options", "Close");

	else
		ShowPlayerDialog(playerid, d_ContainerInventory, DIALOG_STYLE_LIST, cnt_Data[containerid][cnt_name], list, "Take", "Close");

}



// Internal 



DisplayContainerPlayerInv(playerid, showoptions = 0)
{
	new
		list[INV_MAX_SLOTS * (MAX_ITEM_NAME + 1)],
		tmp[MAX_ITEM_NAME];
	
	for(new i; i < INV_MAX_SLOTS; i++)
	{
		if(!IsValidItem(GetInventorySlotItem(playerid, i))) strcat(list, "<Empty>\n");
		else
		{
			GetItemTypeName(GetItemType(GetInventorySlotItem(playerid, i)), tmp);
			strcat(list, tmp);
			strcat(list, "\n");
		}
	}
	strcat(list, cnt_Data[cnt_CurrentContainer[playerid]][cnt_name]);
	strcat(list, " Inventory >");

	if(showoptions)
		ShowPlayerDialog(playerid, d_ContainerPlayerInv, DIALOG_STYLE_LIST, "Inventory", list, "Options", "Close");

	else
		ShowPlayerDialog(playerid, d_ContainerPlayerInv, DIALOG_STYLE_LIST, "Inventory", list, "Remove", "Close");
}

public OnButtonPress(playerid, buttonid)
{
	if(!IsPlayerInAnyVehicle(playerid))
	{
		foreach(new i : cnt_Index)
		{
			if(buttonid == cnt_Data[i][cnt_button])
			{
				DisplayContainerInventory(playerid, i);
				if(cnt_Data[i][cnt_attachedVehicle])
				{
					new
						engine,
						lights,
						alarm,
						doors,
						bonnet,
						boot,
						objective;

					GetVehicleParamsEx(cnt_Data[i][cnt_attachedVehicle], engine, lights, alarm, doors, bonnet, boot, objective);
					SetVehicleParamsEx(cnt_Data[i][cnt_attachedVehicle], engine, lights, alarm, doors, bonnet, 1, objective);
				}
				break;
			}
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

DisplayContainerOptions(playerid, slotid)
{
	new tmp[MAX_ITEM_NAME];

	GetItemTypeName(GetItemType(cnt_Items[cnt_CurrentContainer[playerid]][slotid]), tmp);

	if(GetItemSize(cnt_Items[cnt_CurrentContainer[playerid]][slotid]) == ITEM_SIZE_SMALL)
		ShowPlayerDialog(playerid, d_ContainerOptions, DIALOG_STYLE_LIST, tmp, "Equip\nUse\nTake", "Accept", "Back");

	else
		ShowPlayerDialog(playerid, d_ContainerOptions, DIALOG_STYLE_LIST, tmp, "Equip\nUse", "Accept", "Back");
}

DisplayContainerPlayerOptions(playerid, slotid)
{
	new tmp[MAX_ITEM_NAME];

	GetItemTypeName(GetItemType(GetInventorySlotItem(playerid, slotid)), tmp);

	ShowPlayerDialog(playerid, d_ContainerPlayerInvOptions, DIALOG_STYLE_LIST, tmp, "Equip\nUse\nRemove", "Accept", "Back");
}


hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_ContainerInventory)
	{
		if(response)
		{
			if(listitem == cnt_Data[cnt_CurrentContainer[playerid]][cnt_size])
				DisplayContainerPlayerInv(playerid, cnt_ContainerOptions[playerid]);

			else
			{
				if(cnt_ContainerOptions[playerid])
				{
					cnt_SelectedSlot[playerid] = listitem;
					DisplayContainerOptions(playerid, listitem);
				}
				else
				{
					new id = cnt_Items[cnt_CurrentContainer[playerid]][listitem];

					if(IsPlayerInventoryFull(playerid) || !IsValidItem(id))
					{
						DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
						return 0;
					}

					RemoveItemFromContainer(cnt_CurrentContainer[playerid], listitem);
					AddItemToInventory(playerid, id);
					DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
				}
			}
		}
		else
		{
			if(cnt_Data[cnt_CurrentContainer[playerid]][cnt_attachedVehicle])
			{
				new
					engine,
					lights,
					alarm,
					doors,
					bonnet,
					boot,
					objective;

				GetVehicleParamsEx(cnt_Data[cnt_CurrentContainer[playerid]][cnt_attachedVehicle], engine, lights, alarm, doors, bonnet, boot, objective);
				SetVehicleParamsEx(cnt_Data[cnt_CurrentContainer[playerid]][cnt_attachedVehicle], engine, lights, alarm, doors, bonnet, 0, objective);
			}
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
					CreateItemInWorld(cnt_Items[cnt_CurrentContainer[playerid]][cnt_SelectedSlot[playerid]], 0.0, 0.0, 0.0);
					GiveWorldItemToPlayer(playerid, cnt_Items[cnt_CurrentContainer[playerid]][cnt_SelectedSlot[playerid]], 1);
					RemoveItemFromContainer(playerid, cnt_SelectedSlot[playerid]);
				}
				else
				{
					Msg(playerid, ORANGE, " >  You are already holding something");
					DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid], 1);
				}
			}
			case 1:
			{
				PlayerUseItem(playerid, cnt_Items[cnt_CurrentContainer[playerid]][cnt_SelectedSlot[playerid]]);
			}
			case 2:
			{
				new id = cnt_Items[cnt_CurrentContainer[playerid]][cnt_SelectedSlot[playerid]];

				if(IsPlayerInventoryFull(playerid) || !IsValidItem(id))
				{
					DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
					return 0;
				}

				RemoveItemFromContainer(cnt_CurrentContainer[playerid], cnt_SelectedSlot[playerid]);
				AddItemToInventory(playerid, id);
				DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
			}
		}
	}

	if(dialogid == d_ContainerPlayerInv)
	{
		if(response)
		{
			if(listitem == INV_MAX_SLOTS)
				DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid], cnt_ContainerOptions[playerid]);

			else
			{
				if(cnt_ContainerOptions[playerid])
				{
					cnt_SelectedSlot[playerid] = listitem;
					DisplayContainerPlayerOptions(playerid, listitem);
				}
				else
				{
					new id = GetInventorySlotItem(playerid, listitem);

					if(IsValidItem(cnt_Items[cnt_CurrentContainer[playerid]][cnt_Data[cnt_CurrentContainer[playerid]][cnt_size]-1]) || !IsValidItem(id))
					{
						DisplayContainerPlayerInv(playerid, cnt_ContainerOptions[playerid]);
						return 0;
					}

					RemoveItemFromInventory(playerid, listitem);
					AddItemToContainer(cnt_CurrentContainer[playerid], id);
					DisplayContainerPlayerInv(playerid, cnt_ContainerOptions[playerid]);
				}
			}
		}
		else
		{
			if(cnt_Data[cnt_CurrentContainer[playerid]][cnt_attachedVehicle])
			{
				new
					engine,
					lights,
					alarm,
					doors,
					bonnet,
					boot,
					objective;

				GetVehicleParamsEx(cnt_Data[cnt_CurrentContainer[playerid]][cnt_attachedVehicle], engine, lights, alarm, doors, bonnet, boot, objective);
				SetVehicleParamsEx(cnt_Data[cnt_CurrentContainer[playerid]][cnt_attachedVehicle], engine, lights, alarm, doors, bonnet, 0, objective);
			}
			cnt_CurrentContainer[playerid] = INVALID_CONTAINER_ID;
		}
	}

	if(dialogid == d_ContainerPlayerInvOptions)
	{
		switch(listitem)
		{
			case 0:
			{
				if(GetPlayerItem(playerid) == INVALID_ITEM_ID && GetPlayerWeapon(playerid) == 0)
				{
					CreateItemInWorld(GetInventorySlotItem(playerid, cnt_SelectedSlot[playerid]), 0.0, 0.0, 0.0);
					GiveWorldItemToPlayer(playerid, GetInventorySlotItem(playerid, cnt_SelectedSlot[playerid]), 1);
					RemoveItemFromInventory(playerid, cnt_SelectedSlot[playerid]);
				}
				else
				{
				    Msg(playerid, ORANGE, " >  You are already holding something");
					DisplayContainerPlayerInv(playerid, cnt_ContainerOptions[playerid]);
				}
			}
			case 1:
			{
				PlayerUseItem(playerid, GetInventorySlotItem(playerid, cnt_SelectedSlot[playerid]));
			}
			case 2:
			{
				new id = GetInventorySlotItem(playerid, cnt_SelectedSlot[playerid]);

				if(IsValidItem(cnt_Items[cnt_CurrentContainer[playerid]][cnt_Data[cnt_CurrentContainer[playerid]][cnt_size]-1]) || !IsValidItem(id))
				{
					DisplayContainerPlayerInv(playerid, cnt_ContainerOptions[playerid]);
					return 0;
				}

				RemoveItemFromInventory(playerid, cnt_SelectedSlot[playerid]);
				AddItemToContainer(cnt_CurrentContainer[playerid], id);
				DisplayContainerPlayerInv(playerid, cnt_ContainerOptions[playerid]);
			}
		}
	}
	return 1;
}

public OnPlayerAddToInventory(playerid, itemid)
{
	if(!IsPlayerInAnyDynamicArea(playerid))
		return 1;

	if(IsValidItem(itemid))
	{
		foreach(new i : cnt_Index)
		{
			if(GetPlayerButtonID(playerid) == cnt_Data[i][cnt_button])
			{
				if(AddItemToContainer(i, itemid))
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



// Interface



stock IsValidContainer(containerid)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	return 1;
}

stock GetPlayerContainerID(playerid)
{
	new button = GetPlayerButtonID(playerid);

	foreach(new i : cnt_Index)
		if(button == cnt_Data[i][cnt_button]) return i;

	return INVALID_CONTAINER_ID;
}

stock GetContainerName(containerid, name[])
{
	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	name[0] = EOS;
	strcat(name, cnt_Data[containerid][cnt_name], MAX_CONTAINER_NAME);

	return 1;
}