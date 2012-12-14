#include <YSI\y_hooks>

#define MAX_STORE			(8)
#define MAX_STORE_ITEMS		(8)
#define MAX_STORE_NAME		(32)
#define MAX_STORE_ITEM_NAME	(32)

#define INVALID_SHOP_ID		(-1)


enum E_STORE_DATA
{
			shp_name[MAX_STORE_NAME],
			shp_pickupModel,
			shp_pickup,
Text3D:		shp_label,
			shp_itemid,
			shp_totalItems,

Float:		shp_posX,
Float:		shp_posY,
Float:		shp_posZ,
			shp_world,
			shp_interior,

Float:		shp_itemX,
Float:		shp_itemY,
Float:		shp_itemZ
}

enum E_STORE_ITEM_DATA
{
bool:		item_used,
ItemType:	item_type,
			item_price
}


new
			shp_Data[MAX_STORE][E_STORE_DATA],
Iterator:	shp_Index<MAX_STORE>,
			shp_ItemIndex[MAX_STORE][MAX_STORE_ITEMS][E_STORE_ITEM_DATA];

new
			shp_CurrentShop[MAX_PLAYERS],
			shp_MenuTick[MAX_PLAYERS];


CreateShop(name[], Float:x, Float:y, Float:z, Float:itemx, Float:itemy, Float:itemz, pickupmodel = 1274, world = -1, interior = -1)
{
	new id = Iter_Free(shp_Index);


	shp_Data[id][shp_name][0] = EOS;
	strcat(shp_Data[id][shp_name], name);
	shp_Data[id][shp_pickup] = CreateDynamicPickup(pickupmodel, 1, x, y, z, world, 0);
	shp_Data[id][shp_label] = CreateDynamic3DTextLabel(name, YELLOW, x, y, z + 0.5, 100.0, .worldid = world, .testlos = 1);

	shp_Data[id][shp_posX] = x;
	shp_Data[id][shp_posY] = y;
	shp_Data[id][shp_posZ] = z;
	shp_Data[id][shp_world] = world;
	shp_Data[id][shp_interior] = interior;


	shp_Data[id][shp_itemX] = itemx;
	shp_Data[id][shp_itemY] = itemy;
	shp_Data[id][shp_itemZ] = itemz;

	shp_Data[id][shp_pickupModel] = pickupmodel;

	Iter_Add(shp_Index, id);

	return id;
}
DefineStoreItem(shopid, ItemType:itemid, price)
{
	new id;
	while(id < MAX_STORE_ITEMS && shp_ItemIndex[shopid][id][item_used])id++;
	if(id == MAX_STORE_ITEMS)
		return -1;

	shp_ItemIndex[shopid][id][item_price] = price;
	shp_ItemIndex[shopid][id][item_type] = itemid;
	shp_ItemIndex[shopid][id][item_used] = true;

	shp_Data[shopid][shp_totalItems]++;

	return id;
}

FormatStoreList(playerid, shopid)
{
	new
		list[MAX_STORE_ITEMS * (MAX_STORE_ITEM_NAME + 5)],
		tmp[(MAX_STORE_ITEM_NAME + 5)],
		itemname[MAX_STORE_ITEM_NAME];

	for(new i; i < shp_Data[shopid][shp_totalItems]; i++)
	{
		GetItemTypeName(shp_ItemIndex[shopid][i][item_type], itemname);
		format(tmp, sizeof(tmp), "%s - $%d\n", itemname, shp_ItemIndex[shopid][i][item_price]);
		strcat(list, tmp);
	}

	ShowPlayerDialog(playerid, d_GeneralStore, DIALOG_STYLE_LIST, "General Store", list, "Buy", "Exit");
	shp_CurrentShop[playerid] = shopid;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_GeneralStore)
	{
		if(response)
		{
			shp_MenuTick[playerid] = tickcount();

			if(GetPlayerItem(playerid) != INVALID_ITEM_ID)
				return Msg(playerid, RED, " >  You are already holding an item");

			if(GetPlayerMoney(playerid) < shp_ItemIndex[shp_CurrentShop[playerid]][listitem][item_price])
				return Msg(playerid, RED, " >  You don't have enough money for that.");

			new name[MAX_STORE_ITEM_NAME];

			GetItemTypeName(shp_ItemIndex[shp_CurrentShop[playerid]][listitem][item_type], name);

			shp_Data[shp_CurrentShop[playerid]][shp_itemid] = CreateItem(
				shp_ItemIndex[shp_CurrentShop[playerid]][listitem][item_type],
				shp_Data[shp_CurrentShop[playerid]][shp_itemX],
				shp_Data[shp_CurrentShop[playerid]][shp_itemY],
				shp_Data[shp_CurrentShop[playerid]][shp_itemZ]);

			DestroyDynamicPickup(shp_Data[shp_CurrentShop[playerid]][shp_pickup]);
			shp_Data[shp_CurrentShop[playerid]][shp_pickup] = -1;

			GivePlayerMoney(playerid, -shp_ItemIndex[shp_CurrentShop[playerid]][listitem][item_price]);

			MsgF(playerid, YELLOW, " >  You have bought "#C_BLUE"%s for "#C_ORANGE"$%d.",
				name, shp_ItemIndex[shp_CurrentShop[playerid]][listitem][item_price]);
		}
		shp_CurrentShop[playerid] = INVALID_SHOP_ID;
	}
	return 1;
}

public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
	foreach(new i : shp_Index)
	{
		if(pickupid == shp_Data[i][shp_pickup] && tickcount() - shp_MenuTick[playerid] > 3000)
		{
			FormatStoreList(playerid, i);
			return 1;
		}
	}
    return CallLocalFunction("shp_OnPlayerPickUpDynPickup", "dd", playerid, pickupid);
}
#if defined _ALS_OnPlayerPickUpDynPickup
    #undef OnPlayerPickUpDynamicPickup
#else
    #define _ALS_OnPlayerPickUpDynPickup
#endif
#define OnPlayerPickUpDynamicPickup shp_OnPlayerPickUpDynPickup
forward shp_OnPlayerPickUpDynPickup(playerid, pickupid);

public OnPlayerPickedUpItem(playerid, itemid)
{
	foreach(new i : shp_Index)
	{
		if(itemid == shp_Data[i][shp_itemid])
		{
			shp_Data[i][shp_itemid] = INVALID_ITEM_ID;

			shp_Data[i][shp_pickup] = CreateDynamicPickup(shp_Data[i][shp_pickupModel], 1,
				shp_Data[i][shp_posX], shp_Data[i][shp_posY], shp_Data[i][shp_posZ], shp_Data[i][shp_world], shp_Data[i][shp_interior]);
		}
	}
	return CallLocalFunction("shp_OnPlayerPickedUpItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerPickedUpItem
    #undef OnPlayerPickedUpItem
#else
    #define _ALS_OnPlayerPickedUpItem
#endif
#define OnPlayerPickedUpItem shp_OnPlayerPickedUpItem
forward shp_OnPlayerPickedUpItem(playerid, itemid);
