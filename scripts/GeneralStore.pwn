#include <YSI\y_hooks>

#define MAX_STORE				(8)
#define MAX_STORE_NAME			(32)
#define MAX_STORE_ITEM_NAME		(32)
#define MAX_ITEM_INDEX			ItemIndex:(8)
#define MAX_ITEM_INDEX_ITEMS	(32)

#define INVALID_SHOP_ID			(-1)


enum E_STORE_DATA
{
			shp_name[MAX_STORE_NAME],
ItemIndex:	shp_itemIndex,
			shp_pickupModel,
			shp_button,
			shp_pickup,
			shp_itemid,

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
			item_price,
			item_extradata
}


new
			shp_Data				[MAX_STORE][E_STORE_DATA],
Iterator:	shp_Index<MAX_STORE>,
			shp_ItemIndexSize		[MAX_ITEM_INDEX],
			shp_ItemIndex			[MAX_ITEM_INDEX][MAX_ITEM_INDEX_ITEMS][E_STORE_ITEM_DATA];

new
			shp_CurrentShop[MAX_PLAYERS];


CreateShop(name[], ItemIndex:itemindex, Float:x, Float:y, Float:z, Float:itemx, Float:itemy, Float:itemz, pickupmodel = 1274, world = -1, interior = -1)
{
	new id = Iter_Free(shp_Index);

	if(id == -1)
		return INVALID_SHOP_ID;

	strcpy(shp_Data[id][shp_name], name, MAX_STORE_NAME);
	shp_Data[id][shp_itemIndex] = itemindex;

	shp_Data[id][shp_button] = CreateButton(x, y, z, name, world, interior, 1.0, 1, name);
	shp_Data[id][shp_pickup] = CreateDynamicPickup(pickupmodel, 1, x, y, z, world, 0);

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
DefineStoreIndexItem(ItemIndex:itemindex, ItemType:itemid, price, extradata = 0)
{
	new id;
	while(id < MAX_ITEM_INDEX_ITEMS && shp_ItemIndex[itemindex][id][item_used])id++;
	if(id == MAX_ITEM_INDEX_ITEMS)
		return -1;

	shp_ItemIndex[itemindex][id][item_used] = true;
	shp_ItemIndex[itemindex][id][item_type] = itemid;
	shp_ItemIndex[itemindex][id][item_price] = price;
	shp_ItemIndex[itemindex][id][item_extradata] = extradata;

	shp_ItemIndexSize[itemindex]++;

	return id;
}

FormatStoreList(playerid, shopid)
{
	new
		list[MAX_ITEM_INDEX_ITEMS * (MAX_STORE_ITEM_NAME + 5)],
		tmp[(MAX_STORE_ITEM_NAME + 5)],
		itemname[MAX_STORE_ITEM_NAME],
		ItemIndex:index = shp_Data[shopid][shp_itemIndex];

	for(new i; i < shp_ItemIndexSize[index]; i++)
	{
		GetItemTypeName(shp_ItemIndex[index][i][item_type], itemname);
		format(tmp, sizeof(tmp), "%s - $%d\n", itemname, shp_ItemIndex[index][i][item_price]);
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
			new ItemIndex:index = shp_Data[shp_CurrentShop[playerid]][shp_itemIndex];

			if(GetPlayerItem(playerid) != INVALID_ITEM_ID)
				return Msg(playerid, RED, " >  You are already holding an item");

			if(GetPlayerMoney(playerid) < shp_ItemIndex[index][listitem][item_price])
				return Msg(playerid, RED, " >  You don't have enough money for that.");

			new name[MAX_STORE_ITEM_NAME];

			GetItemTypeName(shp_ItemIndex[index][listitem][item_type], name);

			shp_Data[shp_CurrentShop[playerid]][shp_itemid] = CreateItem(
				shp_ItemIndex[index][listitem][item_type],
				shp_Data[shp_CurrentShop[playerid]][shp_itemX],
				shp_Data[shp_CurrentShop[playerid]][shp_itemY],
				shp_Data[shp_CurrentShop[playerid]][shp_itemZ]);

			SetItemExtraData(shp_Data[shp_CurrentShop[playerid]][shp_itemid], shp_ItemIndex[index][listitem][item_extradata]);

			DestroyButton(shp_Data[shp_CurrentShop[playerid]][shp_button]);
			shp_Data[shp_CurrentShop[playerid]][shp_button] = INVALID_BUTTON_ID;

			GivePlayerMoney(playerid, -shp_ItemIndex[index][listitem][item_price]);

			MsgF(playerid, YELLOW, " >  You have bought "#C_BLUE"%s for "#C_ORANGE"$%d.",
				name, shp_ItemIndex[index][listitem][item_price]);
		}
		shp_CurrentShop[playerid] = INVALID_SHOP_ID;
	}
	return 1;
}

public OnButtonPress(playerid, buttonid)
{
	foreach(new i : shp_Index)
	{
		if(buttonid == shp_Data[i][shp_button])
		{
			FormatStoreList(playerid, i);
			return 1;
		}
	}
    return CallLocalFunction("shp_OnButtonPress", "dd", playerid, buttonid);
}
#if defined _ALS_OnButtonPress
    #undef OnButtonPress
#else
    #define _ALS_OnButtonPress
#endif
#define OnButtonPress shp_OnButtonPress
forward shp_OnButtonPress(playerid, buttonid);

public OnPlayerPickedUpItem(playerid, itemid)
{
	foreach(new i : shp_Index)
	{
		if(itemid == shp_Data[i][shp_itemid])
		{
			shp_Data[i][shp_itemid] = INVALID_ITEM_ID;

			shp_Data[i][shp_button] = CreateButton(
				shp_Data[i][shp_posX], shp_Data[i][shp_posY], shp_Data[i][shp_posZ],
				shp_Data[i][shp_name], shp_Data[i][shp_world], shp_Data[i][shp_interior],
				1.0, 1, shp_Data[i][shp_name]);
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
