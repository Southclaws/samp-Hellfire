new ItemType:item_GasCan = INVALID_ITEM_TYPE;

public OnItemCreate(itemid)
{
	if(GetItemType(itemid) == item_GasCan)
	{
		SetItemExtraData(itemid, random(10));
	}

	return CallLocalFunction("gas_OnItemCreate", "d", itemid);
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
#define OnItemCreate gas_OnItemCreate
forward gas_OnItemCreate(itemid);
