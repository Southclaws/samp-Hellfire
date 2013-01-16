#include <YSI\y_hooks>


#define UI_ELEMENT_TITLE	(0)
#define UI_ELEMENT_TILE		(1)
#define UI_ELEMENT_ITEM		(2)


new
	PlayerText:ApparelSlot_Head[3],
	PlayerText:ApparelSlot_Hand[3],
	PlayerText:ApparelSlot_Tors[3],
	PlayerText:ApparelSlot_Back[3];


forward CreatePlayerTile(playerid, &PlayerText:title, &PlayerText:tile, &PlayerText:item, Float:x, Float:y, Float:width, Float:height, colour, overlaycolour);


hook OnPlayerConnect(playerid)
{
	CreatePlayerTile(playerid, ApparelSlot_Head[0], ApparelSlot_Head[1], ApparelSlot_Head[2], 480.0, 130.0, 60.0, 60.0, 0xFFFFFF08, 0xFFFFFFFF);
	CreatePlayerTile(playerid, ApparelSlot_Hand[0], ApparelSlot_Hand[1], ApparelSlot_Hand[2], 420.0, 220.0, 60.0, 60.0, 0xFFFFFF08, 0xFFFFFFFF);
	CreatePlayerTile(playerid, ApparelSlot_Tors[0], ApparelSlot_Tors[1], ApparelSlot_Tors[2], 480.0, 220.0, 60.0, 60.0, 0xFFFFFF08, 0xFFFFFFFF);
	CreatePlayerTile(playerid, ApparelSlot_Back[0], ApparelSlot_Back[1], ApparelSlot_Back[2], 540.0, 220.0, 60.0, 60.0, 0xFFFFFF08, 0xFFFFFFFF);

	PlayerTextDrawSetString(playerid, ApparelSlot_Head[0], "Head");
	PlayerTextDrawSetString(playerid, ApparelSlot_Hand[0], "Hand");
	PlayerTextDrawSetString(playerid, ApparelSlot_Tors[0], "Torso");
	PlayerTextDrawSetString(playerid, ApparelSlot_Back[0], "Back");
}


CreatePlayerTile(playerid, &PlayerText:title, &PlayerText:tile, &PlayerText:item, Float:x, Float:y, Float:width, Float:height, colour, overlaycolour)
{
	title							=CreatePlayerTextDraw(playerid, x + width / 2.0, y - 12.0, "_");
	PlayerTextDrawAlignment			(playerid, title, 2);
	PlayerTextDrawBackgroundColor	(playerid, title, 255);
	PlayerTextDrawFont				(playerid, title, 2);
	PlayerTextDrawLetterSize		(playerid, title, 0.15, 1.0);
	PlayerTextDrawColor				(playerid, title, -1);
	PlayerTextDrawSetOutline		(playerid, title, 1);
	PlayerTextDrawSetProportional	(playerid, title, 1);
	PlayerTextDrawTextSize			(playerid, title, height, width - 4);
	PlayerTextDrawUseBox			(playerid, title, true);

	tile							=CreatePlayerTextDraw(playerid, x, y, "_");
	PlayerTextDrawFont				(playerid, tile, TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawBackgroundColor	(playerid, tile, colour);
	PlayerTextDrawColor				(playerid, tile, overlaycolour);
	PlayerTextDrawTextSize			(playerid, tile, width, height);
	PlayerTextDrawSetSelectable		(playerid, tile, true);

	item							=CreatePlayerTextDraw(playerid, x + width / 2.0, y + height, "_");
	PlayerTextDrawAlignment			(playerid, item, 2);
	PlayerTextDrawBackgroundColor	(playerid, item, 255);
	PlayerTextDrawFont				(playerid, item, 2);
	PlayerTextDrawLetterSize		(playerid, item, 0.15, 1.0);
	PlayerTextDrawColor				(playerid, item, -1);
	PlayerTextDrawSetOutline		(playerid, item, 1);
	PlayerTextDrawSetProportional	(playerid, item, 1);
}

ShowPlayerGear(playerid)
{
	for(new i; i < 3; i++)
	{
		PlayerTextDrawShow(playerid, ApparelSlot_Head[i]);
		PlayerTextDrawShow(playerid, ApparelSlot_Hand[i]);
		PlayerTextDrawShow(playerid, ApparelSlot_Tors[i]);
		PlayerTextDrawShow(playerid, ApparelSlot_Back[i]);
	}
}

HidePlayerGear(playerid)
{
	for(new i; i < 3; i++)
	{
		PlayerTextDrawHide(playerid, ApparelSlot_Head[i]);
		PlayerTextDrawHide(playerid, ApparelSlot_Hand[i]);
		PlayerTextDrawHide(playerid, ApparelSlot_Tors[i]);
		PlayerTextDrawHide(playerid, ApparelSlot_Back[i]);
	}
}

UpdatePlayerGear(playerid)
{
	new
		tmp[MAX_ITEM_NAME],
		itemid;


	itemid = INVALID_ITEM_ID;
	if(IsValidItem(itemid))
	{
		PlayerTextDrawSetString(playerid, ApparelSlot_Head[UI_ELEMENT_ITEM], "none");
		PlayerTextDrawSetPreviewModel(playerid, ApparelSlot_Head[UI_ELEMENT_TILE], 23);
		PlayerTextDrawSetPreviewRot(playerid, ApparelSlot_Head[UI_ELEMENT_TILE], -45.0, 0.0, -45.0, 1.0);
	}
	else
	{
		PlayerTextDrawSetString(playerid, ApparelSlot_Head[UI_ELEMENT_ITEM], "<Empty>");
		PlayerTextDrawSetPreviewModel(playerid, ApparelSlot_Head[UI_ELEMENT_TILE], 19300);
	}

	itemid = GetPlayerItem(playerid);
	if(IsValidItem(itemid))
	{
		GetItemTypeName(GetItemType(itemid), tmp);
		PlayerTextDrawSetString(playerid, ApparelSlot_Hand[UI_ELEMENT_ITEM], tmp);
		PlayerTextDrawSetPreviewModel(playerid, ApparelSlot_Hand[UI_ELEMENT_TILE], GetItemTypeModel(GetItemType(itemid)));
		PlayerTextDrawSetPreviewRot(playerid, ApparelSlot_Hand[UI_ELEMENT_TILE], -45.0, 0.0, -45.0, 1.0);
	}
	else
	{
		PlayerTextDrawSetString(playerid, ApparelSlot_Hand[UI_ELEMENT_ITEM], "<Empty>");
		PlayerTextDrawSetPreviewModel(playerid, ApparelSlot_Hand[UI_ELEMENT_TILE], 19300);
	}

	itemid = INVALID_ITEM_ID;
	if(IsValidItem(itemid))
	{
		PlayerTextDrawSetString(playerid, ApparelSlot_Tors[UI_ELEMENT_ITEM], "none");
		PlayerTextDrawSetPreviewModel(playerid, ApparelSlot_Tors[UI_ELEMENT_TILE], 23);
		PlayerTextDrawSetPreviewRot(playerid, ApparelSlot_Tors[UI_ELEMENT_TILE], -45.0, 0.0, -45.0, 1.0);
	}
	else
	{
		PlayerTextDrawSetString(playerid, ApparelSlot_Tors[UI_ELEMENT_ITEM], "<Empty>");
		PlayerTextDrawSetPreviewModel(playerid, ApparelSlot_Tors[UI_ELEMENT_TILE], 19300);
	}

	itemid = GetPlayerBackpackItem(playerid);
	if(IsValidItem(itemid))
	{
		GetItemTypeName(GetItemType(itemid), tmp);
		PlayerTextDrawSetString(playerid, ApparelSlot_Back[UI_ELEMENT_ITEM], tmp);
		PlayerTextDrawSetPreviewModel(playerid, ApparelSlot_Back[UI_ELEMENT_TILE], GetItemTypeModel(GetItemType(itemid)));
		PlayerTextDrawSetPreviewRot(playerid, ApparelSlot_Back[UI_ELEMENT_TILE], -45.0, 0.0, -45.0, 1.0);
	}
	else
	{
		PlayerTextDrawSetString(playerid, ApparelSlot_Back[UI_ELEMENT_ITEM], "<Empty>");
		PlayerTextDrawSetPreviewModel(playerid, ApparelSlot_Back[UI_ELEMENT_TILE], 19300);
	}
}

public OnPlayerOpenInventory(playerid)
{
	ShowPlayerGear(playerid);
	UpdatePlayerGear(playerid);
	ShowPlayerGear(playerid);

	return CallLocalFunction("app_OnPlayerOpenInventory", "d", playerid);
}
#if defined _ALS_OnPlayerOpenInventory
	#undef OnPlayerOpenInventory
#else
	#define _ALS_OnPlayerOpenInventory
#endif
#define OnPlayerOpenInventory app_OnPlayerOpenInventory
forward app_OnPlayerOpenInventory(playerid);

public OnPlayerCloseInventory(playerid)
{
	HidePlayerGear(playerid);

	return CallLocalFunction("app_OnPlayerCloseInventory", "d", playerid);
}
#if defined _ALS_OnPlayerCloseInventory
	#undef OnPlayerCloseInventory
#else
	#define _ALS_OnPlayerCloseInventory
#endif
#define OnPlayerCloseInventory app_OnPlayerCloseInventory
forward app_OnPlayerCloseInventory(playerid);

public OnPlayerCloseContainer(playerid, containerid)
{
	HidePlayerGear(playerid);

	return CallLocalFunction("app_OnPlayerCloseContainer", "dd", playerid, containerid);
}
#if defined _ALS_OnPlayerCloseContainer
	#undef OnPlayerCloseContainer
#else
	#define _ALS_OnPlayerCloseContainer
#endif
#define OnPlayerCloseContainer app_OnPlayerCloseContainer
forward app_OnPlayerCloseContainer(playerid, containerid);

public OnPlayerTakeFromContainer(playerid, containerid, slotid)
{
	if(containerid == GetItemExtraData(GetPlayerBackpackItem(playerid)))
	{
		UpdatePlayerGear(playerid);
	}

	return CallLocalFunction("app_OnPlayerTakeFromContainer", "ddd", playerid, containerid, slotid);
}
#if defined _ALS_OnPlayerTakeFromContainer
	#undef OnPlayerTakeFromContainer
#else
	#define _ALS_OnPlayerTakeFromContainer
#endif
#define OnPlayerTakeFromContainer app_OnPlayerTakeFromContainer
forward app_OnPlayerTakeFromContainer(playerid, containerid, slotid);

public OnPlayerRemoveFromInventory(playerid)
{
	UpdatePlayerGear(playerid);

	return CallLocalFunction("app_OnPlayerRemoveFromInventory", "d", playerid);
}
#if defined _ALS_OnPlayerRemoveFromInv
	#undef OnPlayerRemoveFromInventory
#else
	#define _ALS_OnPlayerRemoveFromInv
#endif
#define OnPlayerRemoveFromInventory app_OnPlayerRemoveFromInventory
forward app_OnPlayerRemoveFromInventory(playerid);


hook OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(playertextid == ApparelSlot_Head[UI_ELEMENT_TILE])
	{
		Msg(playerid, YELLOW, "Head");
	}
	if(playertextid == ApparelSlot_Hand[UI_ELEMENT_TILE])
	{
		new itemid = GetPlayerItem(playerid);

		if(IsValidItem(itemid))
		{
			if(GetItemTypeSize(GetItemType(itemid)) != ITEM_SIZE_SMALL)
				ShowMsgBox(playerid, "That item is too big for your inventory", 3000, 140);

			else
			{
				if(AddItemToInventory(playerid, itemid) == 1)
					ShowMsgBox(playerid, "Item added to inventory", 3000, 150);

				else
					ShowMsgBox(playerid, "Inventory full", 3000, 100);
			}
		}
	}
	if(playertextid == ApparelSlot_Tors[UI_ELEMENT_TILE])
	{
		Msg(playerid, YELLOW, "Torso");
	}
	if(playertextid == ApparelSlot_Back[UI_ELEMENT_TILE])
	{
		new itemid = GetPlayerBackpackItem(playerid);

		if(IsValidItem(itemid))
		{
			if(GetPlayerCurrentContainer(playerid) == GetItemExtraData(itemid))
			{
				ClosePlayerContainer(playerid);
				DisplayPlayerInventory(playerid);
			}
			else
			{
				DisplayContainerInventory(playerid, GetItemExtraData(itemid), 1);
			}
		}
	}
}
