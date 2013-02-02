#define MAX_BBQ				(8)

#define COOKER_STATE_NONE	(0)
#define COOKER_STATE_FUEL	(1)
#define COOKER_STATE_COOK	(2)


enum E_BBQ_DATA
{
			bbq_objectId,
			bbq_buttonId,
			bbq_state,
			bbq_fuel,
			bbq_grillItem[2],
			bbq_grillPart[2],
Float:		bbq_posX,
Float:		bbq_posY,
Float:		bbq_posZ,
Float:		bbq_rotZ
}


new
			bbq_Data[MAX_BBQ][E_BBQ_DATA],
Iterator:	bbq_Index<MAX_BBQ>,
Timer:		bbq_CookTimer[MAX_BBQ];


stock CreateBbq(Float:x, Float:y, Float:z, Float:r)
{
	new id = Iter_Free(bbq_Index);

	bbq_Data[id][bbq_objectId]		= CreateDynamicObject(1481, x, y, z, 0.0, 0.0, r);
	bbq_Data[id][bbq_buttonId]		= CreateButton(x, y, z, "Press "KEYTEXT_INTERACT" to use");

	bbq_Data[id][bbq_state]			= COOKER_STATE_NONE;
	bbq_Data[id][bbq_grillItem][0]	= INVALID_ITEM_ID;
	bbq_Data[id][bbq_grillItem][1]	= INVALID_ITEM_ID;
	bbq_Data[id][bbq_posX]			= x;
	bbq_Data[id][bbq_posY]			= y;
	bbq_Data[id][bbq_posZ]			= z;
	bbq_Data[id][bbq_rotZ]			= r;

	Iter_Add(bbq_Index, id);

	return id;
}

stock DestroyBbq(bbqid)
{
	if(!Iter_Contains(bbq_Index, bbqid))
		return 0;

	DestroyDynamicObject(bbq_Data[id][bbq_objectId]);
	DestroyButton(bbq_Data[id][bbq_buttonId]);

	bbq_Data[id][bbq_state]			= COOKER_STATE_NONE;
	bbq_Data[id][bbq_grillItem][0]	= INVALID_ITEM_ID;
	bbq_Data[id][bbq_grillItem][1]	= INVALID_ITEM_ID;
	bbq_Data[id][bbq_posX]			= 0.0;
	bbq_Data[id][bbq_posY]			= 0.0;
	bbq_Data[id][bbq_posZ]			= 0.0;
	bbq_Data[id][bbq_rotZ]			= 0.0;

	stop bbq_CookTimer[bbqid];

	return 1;
}

public OnPlayerUseItemWithButton(playerid, buttonid, itemid)
{
	foreach(new i : bbq_Index)
	{
		if(buttonid == bbq_Data[i][bbq_buttonId])
		{
			new ItemType:itemtype = GetItemType(itemid);

			if(itemtype == item_GasCan)
			{
				if(GetItemExtraData(itemid) > 0)
				{
					SetItemExtraData(itemid, GetItemExtraData(itemid) - 1);
					bbq_Data[i][bbq_fuel] += 10;
					ShowMsgBox(playerid, "1 Liter of petrol added", 3000);
				}
				else
				{
					ShowMsgBox(playerid, "Petrol can empty", 3000);
				}
			}

			if(itemtype == item_Pizza || itemtype == item_Burger || itemtype == item_BurgerBox || itemtype == item_Taco || itemtype == item_HotDog)
			{
				if(bbq_Data[i][bbq_grillItem][0] == INVALID_ITEM_ID)
				{
					CreateItemInWorld(itemid,
						bbq_Data[i][bbq_posX] + (0.25 * floatsin(bbq_Data[i][bbq_rotZ] + 90.0, degrees)),
						bbq_Data[i][bbq_posY] + (0.25 * floatcos(bbq_Data[i][bbq_rotZ] + 90.0, degrees)),
						bbq_Data[i][bbq_posZ] + 0.174);

					bbq_Data[i][bbq_grillItem][0] = itemid;
					ShowMsgBox(playerid, "Food added", 3000);
				}
				else if(bbq_Data[i][bbq_grillItem][1] == INVALID_ITEM_ID)
				{
					CreateItemInWorld(itemid,
						bbq_Data[i][bbq_posX] + (0.25 * floatsin(bbq_Data[i][bbq_rotZ] - 90.0, degrees)),
						bbq_Data[i][bbq_posY] + (0.25 * floatcos(bbq_Data[i][bbq_rotZ] - 90.0, degrees)),
						bbq_Data[i][bbq_posZ] + 0.174);

					bbq_Data[i][bbq_grillItem][1] = itemid;
					ShowMsgBox(playerid, "Food added", 3000);
				}
				else
				{
					return 1;
				}
			}

			if(itemtype == item_FireLighter && bbq_Data[i][bbq_fuel] > 0)
			{
				bbq_Data[i][bbq_grillPart][0] = CreateDynamicObject(18701,
					bbq_Data[i][bbq_posX] + (0.25 * floatsin(-bbq_Data[i][bbq_rotZ] + 90.0, degrees)),
					bbq_Data[i][bbq_posY] + (0.25 * floatcos(-bbq_Data[i][bbq_rotZ] + 90.0, degrees)),
					bbq_Data[i][bbq_posZ] - 1.436,
					0.0, 0.0, bbq_Data[i][bbq_rotZ]);

				bbq_Data[i][bbq_grillPart][1] = CreateDynamicObject(18701,
					bbq_Data[i][bbq_posX] + (0.25 * floatsin(-bbq_Data[i][bbq_rotZ] + 270.0, degrees)),
					bbq_Data[i][bbq_posY] + (0.25 * floatcos(-bbq_Data[i][bbq_rotZ] + 270.0, degrees)),
					bbq_Data[i][bbq_posZ] - 1.436,
					0.0, 0.0, bbq_Data[i][bbq_rotZ]);

				ShowMsgBox(playerid, "BBQ Lit", 3000);
				bbq_CookTimer[i] = defer bbq_FinishCooking(i);
			}

		}
	}

	return CallLocalFunction("bbq_OnPlayerUseItemWithButton", "ddd", playerid, buttonid, itemid);
}
#if defined _ALS_OnPlayerUseItemWithButton
	#undef OnPlayerUseItemWithButton
#else
	#define _ALS_OnPlayerUseItemWithButton
#endif
#define OnPlayerUseItemWithButton bbq_OnPlayerUseItemWithButton
forward bbq_OnPlayerUseItemWithButton(playerid, buttonid, itemid);

timer bbq_FinishCooking[30000](bbqid)
{
	DestroyDynamicObject(bbq_Data[bbqid][bbq_grillPart][0]);
	DestroyDynamicObject(bbq_Data[bbqid][bbq_grillPart][1]);

	SetItemExtraData(bbq_Data[bbqid][bbq_grillItem][0], 1);
	SetItemExtraData(bbq_Data[bbqid][bbq_grillItem][1], 1);

	bbq_Data[bbqid][bbq_fuel] -= 1;
}


public OnPlayerPickUpItem(playerid, itemid)
{
	foreach(new i : bbq_Index)
	{
		if(itemid == bbq_Data[i][bbq_grillItem][0])
			bbq_Data[i][bbq_grillItem][0] = INVALID_ITEM_ID;

		if(itemid == bbq_Data[i][bbq_grillItem][1])
			bbq_Data[i][bbq_grillItem][1] = INVALID_ITEM_ID;
	}

	return CallLocalFunction("bbq_OnPlayerPickUpItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerPickUpItem
	#undef OnPlayerPickUpItem
#else
	#define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem bbq_OnPlayerPickUpItem
forward bbq_OnPlayerPickUpItem(playerid, itemid);
