#include <YSI\y_hooks>


#define MAX_DISPENSER			(64)
#define MAX_DISPENSER_TYPE		DispenserType:(8)
#define DISPENSER_REFIL_TIME	(60000)


enum E_DISPENSER_DATA
{
DispenserType:	dsp_type,
				dsp_objId,
				dsp_buttonId,
				dsp_labelId,
				dsp_itemId,
Float:			dsp_posX,
Float:			dsp_posY,
Float:			dsp_posZ,
Float:			dsp_rotZ,
				dsp_world,
				dsp_interior
}

enum E_DISPENSER_TYPE_DATA
{
				dsp_name[32],
ItemType:		dsp_itemType,
				dsp_price
}


new
				dsp_Data[MAX_DISPENSER][E_DISPENSER_DATA],
Iterator:		dsp_Index<MAX_DISPENSER>;

new
				dsp_TypeData[MAX_DISPENSER_TYPE][E_DISPENSER_TYPE_DATA],
Iterator:		dsp_TypeIndex<_:MAX_DISPENSER_TYPE>;


forward OnPlayerUseDispenser(playerid, dispenserid);


stock CreateDispenser(Float:x, Float:y, Float:z, Float:rz, DispenserType:type, worldid = 0, interiorid = 0)
{
	new
		id = Iter_Free(dsp_Index),
		str[64];
	
	dsp_Data[id][dsp_type]		= type;

	dsp_Data[id][dsp_objId]		= CreateDynamicObject(
		2942, x, y, z, 0.0, 0.0, rz, worldid, interiorid);

	dsp_Data[id][dsp_buttonId]	= CreateButton(
		x, y, z + 0.5, "Press F to buy", worldid, interiorid);

	format(str, sizeof(str), ""#C_YELLOW"%s\n"#C_GREEN"$%d",
		dsp_TypeData[type][dsp_name],
		dsp_TypeData[type][dsp_price]);

	SetButtonLabel(dsp_Data[id][dsp_buttonId], str);

	dsp_Data[id][dsp_posX]		= x;
	dsp_Data[id][dsp_posY]		= y;
	dsp_Data[id][dsp_posZ]		= z;
	dsp_Data[id][dsp_rotZ]		= rz;
	dsp_Data[id][dsp_world]		= worldid;
	dsp_Data[id][dsp_interior]	= interiorid;

	Iter_Add(dsp_Index, id);
	
	return id;
}
stock DestroyDispenser(id)
{
	if(!Iter_Contains(dsp_Index, id))return 0;

	DestroyDynamicObject(dsp_Data[id][dsp_objId]);
	DestroyButton(dsp_Data[id][dsp_buttonId]);
	DestroyDynamic3DTextLabel(dsp_Data[id][dsp_labelId]);

	Iter_Remove(dsp_Index, id);
	return 1;
}

stock DispenserType:DefineDispenserType(name[], ItemType:type, price)
{
	new DispenserType:id = DispenserType:Iter_Free(dsp_TypeIndex);
	
	format(dsp_TypeData[id][dsp_name], 32, name);
	dsp_TypeData[id][dsp_itemType] = type;
	dsp_TypeData[id][dsp_price] = price;
	
	Iter_Add(dsp_TypeIndex, _:id);
	
	return id;
}

public OnButtonPress(playerid, buttonid)
{
	print("OnButtonPress <Dispenser Script>");
	foreach(new i : dsp_Index)
	{
		if(buttonid == dsp_Data[i][dsp_buttonId])
		{
			if(GetPlayerMoney(playerid) < dsp_TypeData[ dsp_Data[i][dsp_type] ][dsp_price])
			{
				MsgF(playerid, ORANGE,
					" >  You need another "#C_RED"$%d "#C_ORANGE"to buy that.",
					dsp_TypeData[ dsp_Data[i][dsp_type] ][dsp_price] - GetPlayerMoney(playerid));

				return 0;
			}
			if(CallLocalFunction("OnPlayerUseDispenser", "dd", playerid, i))
				return 0;

			dsp_Data[i][dsp_itemId] = CreateItem(dsp_TypeData[ dsp_Data[i][dsp_type] ][dsp_itemType],
				dsp_Data[i][dsp_posX],
				dsp_Data[i][dsp_posY],
				dsp_Data[i][dsp_posZ] + 0.5,
				.rx = 30.0,
				.rz = dsp_Data[i][dsp_rotZ],
				.world = dsp_Data[i][dsp_world],
				.interior = dsp_Data[i][dsp_interior]);

			DestroyButton(dsp_Data[i][dsp_buttonId]);
			GivePlayerMoney(playerid, -dsp_TypeData[ dsp_Data[i][dsp_type] ][dsp_price]);

			return 1;
		}
	}
    return CallLocalFunction("dsp_OnButtonPress", "dd", playerid, buttonid);
}
#if defined _ALS_OnButtonPress
    #undef OnButtonPress
#else
    #define _ALS_OnButtonPress
#endif
#define OnButtonPress dsp_OnButtonPress
forward dsp_OnButtonPress(playerid, buttonid);

public OnPlayerPickUpItem(playerid, itemid)
{
	foreach(new i : dsp_Index)
	{
	    if(itemid == dsp_Data[i][dsp_itemId])
	    {
	        new str[64];

			dsp_Data[i][dsp_buttonId] = CreateButton(
				dsp_Data[i][dsp_posX],
				dsp_Data[i][dsp_posY],
				dsp_Data[i][dsp_posZ] + 0.5,
				"Press F to buy",
				dsp_Data[i][dsp_world],
				dsp_Data[i][dsp_interior]);

			format(str, sizeof(str), ""#C_YELLOW"%s\n"#C_GREEN"$%d",
				dsp_TypeData[dsp_Data[i][dsp_type]][dsp_name],
				dsp_TypeData[dsp_Data[i][dsp_type]][dsp_price]);

			SetButtonLabel(dsp_Data[i][dsp_buttonId], str);
			
			dsp_Data[i][dsp_itemId] = INVALID_ITEM_ID;
		}
	}
    return CallLocalFunction("dsp_OnPlayerPickUpItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerPickUpItem
    #undef OnPlayerPickUpItem
#else
    #define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem dsp_OnPlayerPickUpItem
forward dsp_OnPlayerPickUpItem(playerid, itemid);

