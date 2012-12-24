/*==============================================================================

Southclaw's Interactivity Framework (SIF) (Formerly: Adventure API)


	SIF/Overview
	{
		SIF is a collection of high-level include scripts to make the
		development of interactive features easy for the developer while
		maintaining quality front-end gameplay for players.
	}

	SIF/Item/Description
	{
		A complex and flexible script to replace the use of pickups as a means
		of displaying objects that the player can pick up and use. Item offers
		picking up, dropping and even giving items to other players. Items in
		the game world consist of static objects combined with buttons from
		SIF/Button to provide a means of interacting.

		Item aims to be an extremely flexible script offering a callback for
		almost every action the player can do with an item. The script also
		allows the ability to add the standard GTA:SA weapons as items that can
		be dropped, given and anything else you script items to do.

		When picked up, items will appear on the character model bone specified
		in the item definition. This combines the visible aspect of weapons and
		items that are already in the game with the scriptable versitility of
		server created and scriptable entities.
	}

	SIF/Item/Dependencies
	{
		SIF/Button
		Streamer Plugin
		YSI\y_hooks
		YSI\y_timers
	}

	SIF/Item/Credits
	{
		SA:MP Team						- Amazing mod!
		SA:MP Community					- Inspiration and support
		Incognito						- Very useful streamer plugin
		Y_Less							- YSI framework
		Patrik356b						- Testing
		Kevin							- Testing
		Cagatay							- Testing
	}

	SIF/Item/Core Functions
	{
		The functions that control the core features of this script.

		native -
		native SIF/Item/
		native -

		native CreateItem(ItemType:type, Float:x, Float:y, Float:z, Float:rx = 0.0, Float:ry = 0.0, Float:rz = 0.0, Float:zoffset = 0.0, world = 0, interior = 0, label = 1)
		{
			Description:
				Creates an item in the game world at the specified coordinates
				with the specified rotation with options for world, interior and
				whether or not to display a 3D text label above the item.

			Parameters:
				<type> (int, ItemType)
					An item type defined with DefineItemType to determine what
					model the item will use and what characteristics it has.

				<x>, <y>, <z> (float)
					The position to create the object and button of the item.

				<rx>, <ry>, <rz> (float)
					The rotation value of the object, overrides item type data.

				<zoffset> (float)
					How high from the object the button will be created, this is
					to ensure the item will always be in pickup range when
					created on the floor.

				<world> (int)
					The virtual world in which the object, button and label will
					appear, only players in this world can see or pick up the
					item.

				<interior> (int)
					Interior world, same as above but for interior worlds.

				<label> (boolean)
					True to show a label with the item name at the item.

			Returns:
				(int, itemid)
					Item ID handle of the newly created item.

				INVALID_ITEM_ID
					If the item index is full and no more items can be created.
		}

		native DestroyItem(itemid)
		{
			Description:
				Destroys an item.

			Parameters:
				<itemid> (int, itemid)
					The item handle ID to delete.

			Returns:
				1
					If destroying the item was successful

				0
					If <itemid> is an invalid item ID handle.
		}

		native ItemType:DefineItemType(name[], model, size, Float:rotx = 0.0, Float:roty = 0.0, Float:rotz = 0.0, Float:attx = 0.0, Float:atty = 0.0, Float:attz = 0.0, Float:attrx = 0.0, Float:attry = 0.0, Float:attrz = 0.0, boneid = 6)
		{
			Description:
				Defines a new item type with the specified name and model. Item
				types are the fundamental pieces of data that give items
				specific characteristics. At least one item definition must
				exist or CreateItem will have no data to use.

			Parameters:
				<name> (string)
					The name of the item, this will be displayed on the label
					of items created using this type (if one is present)

				<model> (int, valid GTA:SA model)
					The GTA:SA model id to use when the item is visible in the
					game world or attached to a player.

				<size> (int, pre-defined size definitions)
					The size of the item has no current use in this script,
					though it can be used in external scripts. It is used in
					SIF/Inventory to disallow large objects in a player's
					inventory.

				<rotx>, <roty>, <rotz> (float)
					The default rotation the item object will have when dropped.

				<attx>, <atty>, <attz>, <attrx>, <attry>, <attrz> (float)
					The attachment coordinates to use when the object is picked
					up and held by a player.

				<boneid> (int, valid SA:MP bones)
					The attachment bone to use, by default this is a hand but
					it's added for special circumstances such as an animation
					problem with held and drinkable beer bottles.

			Returns:
				(int, ItemType)
					Item Type ID handle of the newly defined item type.

				INVALID_ITEM_TYPE
					If the item type definition index is full and no more item
					types can be defined.
		}

		native ShiftItemTypeIndex(ItemType:start, amount)
		{
			Description:
				Shifts the entire item definition index to create <amount> empty
				cells from cell <start>. This can be used to create free spaces
				in the index for items that you want to have a specific ID. For 
				instance, weapons that start from 1 and end at 46.

			Parameters:
				<start> (int, cell index)
					The start cell to shift from, all definitions before this
					won't be affected in any way. All definitions after this
					will be moved up.

				<amount> (int)
					The amount of cells to shift the definitions up by.

			Returns:
				1
					If the shift was successful.

				0
					If the entered values would result in an out-of-bounds
					error with the index.
		}

		native PlayerPickUpItem(playerid, itemid, animtype)
		{
			Description:
				A function to directly make a player pick up an item, regardless
				of whether he is within the button range.

			Parameters:
				<playerid> (int)
					The player to force into picking up something.

				<itemid> (int, itemid)
					The item ID handle to force the player to pick up.

				<animtype> (int, pre-defined)
					The animation type is internally determined by the height
					of the item when the player picks up an item. With this
					function you can specify which animation to use.
						0 item on the ground (bend down)
						1 item in front (reach forward)

			Returns:
		}

		native PlayerDropItem(playerid)
		{
			Description:
			Parameters:
			Returns:
		}

		native PlayerGiveItem(playerid, targetid, call)
		{
			Description:
			Parameters:
			Returns:
		}
	}

	SIF/Item/Events
	{
		Events called by player actions done by using features from this script.

		native -
		native SIF/Item/
		native -

		native OnItemCreate(itemid)
		{
			Called:
				After an item is created.

			Parameters:
				<itemid>
					The ID handle of the newly created item.

			Returns:
		}

		native OnPlayerUseItem(playerid, itemid)
		{
			Called:
				When a player presses F/Enter while holding an item.

			Parameters:

			Returns:
		}
		native OnPlayerUseItemWithItem(playerid, itemid, withitemid)
		{
			Called:
				When a player uses a held item with an item on the floor.

			Parameters:

			Returns:
		}
		native OnPlayerUseItemWithButton(playerid, buttonid, itemid)
		{
			Called:
				When a player uses an item while in the area of a button from an
				item that is in the game world.

			Parameters:

			Returns:
		}
		native OnPlayerPickUpItem(playerid, itemid)
		{
			Called:
				When a player presses the button to pick up an item.

			Parameters:

			Returns:
		}
		native OnPlayerPickedUpItem(playerid, itemid)
		{
			Called:
				When a player finishes the picking up animation.

			Parameters:

			Returns:
		}
		native OnPlayerDropItem(playerid, itemid)
		{
			Called:
				When a player presses the button to drop an item.

			Parameters:

			Returns:
		}
		native OnPlayerDroppedItem(playerid, itemid)
		{
			Called:
				When a player finishes the animation for dropping an item.

			Parameters:

			Returns:
		}
		native OnPlayerGiveItem(playerid, targetid, itemid)
		{
			Called:
				When a player presses the button to give an item to another
				player.

			Parameters:

			Returns:
		}
		native OnPlayerGivenItem(playerid, targetid, itemid)
		{
			Called:
				When a player finishes the animation for giving an item to
				another player.

			Parameters:

			Returns:
		}
	}

	SIF/Item/Interface Functions
	{
		Functions to get or set data values in this script without editing
		the data directly. These include automatic ID validation checks.
	
	}

	SIF/Item/Internal Functions
	{
		Internal events called by player actions done by using features from
		this script.
	
	}

	SIF/Item/Hooks
	{
		Hooked functions or callbacks, either SA:MP natives or from other
		scripts or plugins.

		SAMP/OnFilterScriptInit
		{
			Reason:
				-
		}

		SAMP/OnGameModeInit
		{
			Reason:
				-
		}

		SAMP/OnPlayerConnect
		{
			Reason:
				-
		}

		SAMP/OnPlayerKeyStateChange
		{
			Reason:
				-
		}

		SAMP/OnPlayerDeath
		{
			Reason:
				-
		}

		SIF/Core/OnPlayerEnterPlayerArea
		{
			Reason:
				-
		}

		SIF/Core/OnPlayerLeavePlayerArea
		{
			Reason:
				-
		}

		SIF/Button/OnButtonPress
		{
			Reason:
				-
		}

		SIF/Button/OnPlayerEnterButtonArea
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


#define MAX_ITEMS			(4096)
#define MAX_ITEM_TYPES		(ItemType:256)
#define MAX_ITEM_NAME		(32)
#define ITM_ATTACH_INDEX	(0)

#define FLOOR_OFFSET		(0.8568)
#define INVALID_ITEM_ID		(-1)
#define INVALID_ITEM_TYPE	(ItemType:-1)

#define INVALID_ITEM_SIZE	(-1)
#define ITEM_SIZE_SMALL		(0) // pocket
#define ITEM_SIZE_MEDIUM	(1) // backpack
#define ITEM_SIZE_LARGE		(2) // carry only


enum E_ITEM_DATA
{
			itm_objId,
			itm_button,
ItemType:	itm_type,

Float:		itm_posX,
Float:		itm_posY,
Float:		itm_posZ,

			itm_exData
}

enum E_ITEM_TYPE_DATA
{
bool:		itm_used,
			itm_name			[MAX_ITEM_NAME],
			itm_model,
			itm_size,

Float:		itm_rotX,
Float:		itm_rotY,
Float:		itm_rotZ,

			itm_attachBone,
Float:		itm_attachPosX,
Float:		itm_attachPosY,
Float:		itm_attachPosZ,

Float:		itm_attachRotX,
Float:		itm_attachRotY,
Float:		itm_attachRotZ
}


new
			itm_Data			[MAX_ITEMS][E_ITEM_DATA],
			itm_Interactor		[MAX_ITEMS],
			itm_Holder			[MAX_ITEMS],
Iterator:	itm_Index<MAX_ITEMS>,
Iterator:	itm_WorldIndex<MAX_ITEMS>;

new
			itm_TypeData		[MAX_ITEM_TYPES][E_ITEM_TYPE_DATA];

new
			itm_Holding			[MAX_PLAYERS],
Timer:		itm_InteractTimer	[MAX_PLAYERS],
			itm_Interacting		[MAX_PLAYERS];


forward OnItemCreate(itemid);
forward OnPlayerUseItem(playerid, itemid);
forward OnPlayerUseItemWithItem(playerid, itemid, withitemid);
forward OnPlayerUseItemWithButton(playerid, buttonid, itemid);
forward OnPlayerPickUpItem(playerid, itemid);
forward OnPlayerPickedUpItem(playerid, itemid);
forward OnPlayerDropItem(playerid, itemid);
forward OnPlayerDroppedItem(playerid, itemid);
forward OnPlayerGiveItem(playerid, targetid, itemid);
forward OnPlayerGivenItem(playerid, targetid, itemid);


/*==============================================================================

	Zeroing

==============================================================================*/


#if defined FILTERSCRIPT
hook OnFilterScriptInit()
#else
hook OnGameModeInit()
#endif
{
	for(new i;i<MAX_PLAYERS;i++)
	{
	    itm_Holding[i] = INVALID_ITEM_ID;
	    itm_Interacting[i] = INVALID_ITEM_ID;
	}
	for(new i;i<MAX_ITEMS;i++)
	{
	    itm_Holder[i] = INVALID_PLAYER_ID;
	}
	return 1;
}

hook OnPlayerConnect(playerid)
{
	itm_Holding[playerid]		= INVALID_ITEM_ID;
	itm_Interacting[playerid]	= INVALID_ITEM_ID;
}


/*==============================================================================

	Core Functions

==============================================================================*/


stock CreateItem(ItemType:type, Float:x, Float:y, Float:z, Float:rx = 0.0, Float:ry = 0.0, Float:rz = 0.0, Float:zoffset = 0.0, world = 0, interior = 0, label = 1)
{
	new id = Iter_Free(itm_Index);

	if(id == -1)
	{
		print("ERROR: MAX_ITEMS reached, please increase this constant!");
		return INVALID_ITEM_ID;
	}
	
	if(!IsValidItemType(type))
		return printf("ERROR: Item creation with undefined typeid (%d) failed.", _:type);

	Iter_Add(itm_Index, id);

	itm_Data[id][itm_type] = type;

	CreateItemInWorld(id,
		Float:x, Float:y, Float:z,
		Float:rx, Float:ry, Float:rz,
		Float:zoffset, world, interior, label);

	CallRemoteFunction("OnItemCreate", "d", id);

	Iter_Add(itm_WorldIndex, id);

	return id;
}

stock DestroyItem(itemid)
{
	if(!Iter_Contains(itm_Index, itemid))return 0;

	if(itm_Holder[itemid] != INVALID_PLAYER_ID)
	{
		RemovePlayerAttachedObject(itm_Holder[itemid], ITM_ATTACH_INDEX);
	    itm_Holding[itm_Holder[itemid]] = INVALID_ITEM_ID;
	    itm_Interacting[itm_Holder[itemid]] = INVALID_ITEM_ID;
		stop itm_InteractTimer[itm_Holder[itemid]];
	}
	else
	{
		DestroyDynamicObject(itm_Data[itemid][itm_objId]);
		DestroyButton(itm_Data[itemid][itm_button]);
		itm_Data[itemid][itm_objId] = -1;
		itm_Data[itemid][itm_button] = INVALID_BUTTON_ID;
	}

	itm_Data[itemid][itm_type]	= INVALID_ITEM_TYPE;
	itm_Data[itemid][itm_posX]	= 0.0;
	itm_Data[itemid][itm_posY]	= 0.0;
	itm_Data[itemid][itm_posZ]	= 0.0;
    itm_Holder[itemid]			= INVALID_PLAYER_ID;
    itm_Interactor[itemid]		= INVALID_PLAYER_ID;

	Iter_Remove(itm_Index, itemid);
	Iter_Remove(itm_WorldIndex, itemid);

	return 1;
}

ItemType:DefineItemType(name[], model, size, Float:rotx = 0.0, Float:roty = 0.0, Float:rotz = 0.0, Float:attx = 0.0, Float:atty = 0.0, Float:attz = 0.0, Float:attrx = 0.0, Float:attry = 0.0, Float:attrz = 0.0, boneid = 6)
{
	new ItemType:id;

	while(id < MAX_ITEM_TYPES && itm_TypeData[id][itm_used])
		id++;

	if(id == MAX_ITEM_TYPES)
	{
		print("ERROR: Reached item type limit.");
		return INVALID_ITEM_TYPE;
	}

//	printf("Defining Item: (%d) '%s'", _:id, name);

	itm_TypeData[id][itm_used]			= true;
	format(itm_TypeData[id][itm_name], MAX_ITEM_NAME, name);
	itm_TypeData[id][itm_model]			= model;
	itm_TypeData[id][itm_size]			= size;

	itm_TypeData[id][itm_rotX]			= rotx;
	itm_TypeData[id][itm_rotY]			= roty;
	itm_TypeData[id][itm_rotZ]			= rotz;

	itm_TypeData[id][itm_attachBone]	= boneid;

	itm_TypeData[id][itm_attachPosX]	= attx;
	itm_TypeData[id][itm_attachPosY]	= atty;
	itm_TypeData[id][itm_attachPosZ]	= attz;

	itm_TypeData[id][itm_attachRotX]	= attrx;
	itm_TypeData[id][itm_attachRotY]	= attry;
	itm_TypeData[id][itm_attachRotZ]	= attrz;

	return id;
}

stock ShiftItemTypeIndex(ItemType:start, amount)
{
	if(!(start <= (start + ItemType:amount) < MAX_ITEM_TYPES))
		return 0;

	new ItemType:lastfree;
	while(lastfree < MAX_ITEM_TYPES && itm_TypeData[lastfree][itm_used])
		lastfree++;

	for(new ItemType:i = lastfree - ItemType:1; i >= start; i--)
	{
		if(!IsValidItemType(i))
			continue;

		if(!(i <= (i + ItemType:amount) < MAX_ITEM_TYPES))
			continue;


		itm_TypeData[i + ItemType:amount][itm_used]			= true;
		itm_TypeData[i + ItemType:amount][itm_name]			= itm_TypeData[i][itm_name];
		itm_TypeData[i + ItemType:amount][itm_model]			= itm_TypeData[i][itm_model];
		itm_TypeData[i + ItemType:amount][itm_size]			= itm_TypeData[i][itm_size];

		itm_TypeData[i + ItemType:amount][itm_rotX]			= itm_TypeData[i][itm_rotX];
		itm_TypeData[i + ItemType:amount][itm_rotY]			= itm_TypeData[i][itm_rotY];
		itm_TypeData[i + ItemType:amount][itm_rotZ]			= itm_TypeData[i][itm_rotZ];

		itm_TypeData[i + ItemType:amount][itm_attachBone]	= itm_TypeData[i][itm_attachBone];
		itm_TypeData[i + ItemType:amount][itm_attachPosX]	= itm_TypeData[i][itm_attachPosX];
		itm_TypeData[i + ItemType:amount][itm_attachPosY]	= itm_TypeData[i][itm_attachPosY];
		itm_TypeData[i + ItemType:amount][itm_attachPosZ]	= itm_TypeData[i][itm_attachPosZ];

		itm_TypeData[i + ItemType:amount][itm_attachRotX]	= itm_TypeData[i][itm_attachRotX];
		itm_TypeData[i + ItemType:amount][itm_attachRotY]	= itm_TypeData[i][itm_attachRotY];
		itm_TypeData[i + ItemType:amount][itm_attachRotZ]	= itm_TypeData[i][itm_attachRotZ];


		itm_TypeData[i][itm_used]							= false;
		itm_TypeData[i][itm_name][0]							= EOS;
		itm_TypeData[i][itm_model]							= 0;
		itm_TypeData[i][itm_size]							= 0;

		itm_TypeData[i][itm_rotX]							= 0.0;
		itm_TypeData[i][itm_rotY]							= 0.0;
		itm_TypeData[i][itm_rotZ]							= 0.0;

		itm_TypeData[i][itm_attachBone]						= 0;
		itm_TypeData[i][itm_attachPosX]						= 0.0;
		itm_TypeData[i][itm_attachPosY]						= 0.0;
		itm_TypeData[i][itm_attachPosZ]						= 0.0;

		itm_TypeData[i][itm_attachRotX]						= 0.0;
		itm_TypeData[i][itm_attachRotY]						= 0.0;
		itm_TypeData[i][itm_attachRotZ]						= 0.0;
	}
	
	return 1;
}

stock PlayerPickUpItem(playerid, itemid, animtype)
{
	if(animtype == 0)
    {
		ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 5.0, 0, 0, 0, 0, 450);
		itm_InteractTimer[playerid] = defer PickUpItemDelay(playerid, itemid, .animtype = 0);
	}
	if(animtype == 1)
	{
		ApplyAnimation(playerid, "CASINO", "SLOT_PLYR", 4.0, 0, 0, 0, 0, 0);
		itm_InteractTimer[playerid] = defer PickUpItemDelay(playerid, itemid, .animtype = 1);
	}
	return 1;
}

stock PlayerDropItem(playerid)
{
	if(CallLocalFunction("OnPlayerDropItem", "dd", playerid, itm_Holding[playerid]))
		return 0;

	ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 5.0, 1, 0, 0, 0, 450);
	itm_InteractTimer[playerid] = defer DropItemDelay(playerid);
	return 1;
}

stock PlayerGiveItem(playerid, targetid, call)
{
	new itemid = itm_Holding[playerid];

	if(call)
	{
		if(CallLocalFunction("OnPlayerGiveItem", "ddd", playerid, targetid, itemid))
			return 0;
	}

	if(!Iter_Contains(itm_Index, itemid))return 0;
	if(Iter_Contains(itm_Index, itm_Holding[targetid]))return -1;

	new
		Float:x1,
		Float:y1,
		Float:z1,
		Float:x2,
		Float:y2,
		Float:z2,
		Float:angle;

	GetPlayerPos(targetid, x1, y1, z1);
	GetPlayerPos(playerid, x2, y2, z2);

	angle = GetAngleToPoint(x2, y2, x1, y1);

	SetPlayerPos(targetid,
		x2 + (0.5 * floatsin(-angle, degrees)),
		y2 + (0.5 * floatcos(-angle, degrees)), z2);

	SetPlayerFacingAngle(playerid, angle);
	SetPlayerFacingAngle(targetid, angle+180.0);

	ApplyAnimation(playerid, "CASINO", "SLOT_PLYR", 4.0, 0, 0, 0, 0, 450);
	ApplyAnimation(targetid, "CASINO", "SLOT_PLYR", 4.0, 0, 0, 0, 0, 450);

	itm_Interacting[playerid]	= targetid;
	itm_Interacting[targetid]	= playerid;
	itm_Holder[itemid]			= playerid;

	itm_InteractTimer[playerid] = defer GiveItemDelay(playerid, targetid);

	return 1;
}

PlayerUseItem(playerid, itemid)
{
	internal_OnPlayerUseItem(playerid, itemid);
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


CreateItemInWorld(itemid,
	Float:x, Float:y, Float:z,
	Float:rx = 0.0, Float:ry = 0.0, Float:rz = 0.0,
	Float:zoffset = 0.0, world = 0, interior = 0, label = 1)
{
	if(!Iter_Contains(itm_Index, itemid))return 0;

	new ItemType:itemtype = itm_Data[itemid][itm_type];

	if(!IsValidItemType(itemtype))return 0;

	itm_Data[itemid][itm_posX]					= x;
	itm_Data[itemid][itm_posY]					= y;
	itm_Data[itemid][itm_posZ]					= z;
	
	if(itm_Holder[itemid] != INVALID_PLAYER_ID)
	{
	    itm_Holding[itm_Holder[itemid]]			= INVALID_ITEM_ID;
    	itm_Interacting[itm_Holder[itemid]]		= INVALID_ITEM_ID;
    }
    itm_Interactor[itemid]						= INVALID_PLAYER_ID;
    itm_Holder[itemid]							= INVALID_PLAYER_ID;

	itm_Data[itemid][itm_objId]					= CreateDynamicObject(itm_TypeData[itemtype][itm_model], x, y, z, rx, ry, rz, world, interior);

	itm_Data[itemid][itm_button]				= CreateButton(x, y, z + zoffset, "Press F to pick up", world, interior, 1.0);

	if(label)
		SetButtonLabel(itm_Data[itemid][itm_button], itm_TypeData[itemtype][itm_name]);

	Iter_Add(itm_WorldIndex, itemid);

	return 1;
}

RemoveItemFromWorld(itemid)
{
	if(!Iter_Contains(itm_Index, _:itemid))return 0;

	if(itm_Holder[itemid] != INVALID_PLAYER_ID)
	{
		RemovePlayerAttachedObject(itm_Holder[itemid], ITM_ATTACH_INDEX);
		itm_Holding[itm_Holder[itemid]] = INVALID_ITEM_ID;
		itm_Interacting[itm_Holder[itemid]] = INVALID_ITEM_ID;
		itm_Holder[itemid] = INVALID_PLAYER_ID;
		itm_Interactor[itemid] = INVALID_PLAYER_ID;
	}
	else
	{
		if(!Iter_Contains(itm_WorldIndex, _:itemid))return 0;

		DestroyDynamicObject(itm_Data[itemid][itm_objId]);
		DestroyButton(itm_Data[itemid][itm_button]);
		itm_Data[itemid][itm_objId] = -1;
		itm_Data[itemid][itm_button] = INVALID_BUTTON_ID;
	}

	Iter_Remove(itm_WorldIndex, itemid);

	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerInAnyVehicle(playerid))
		return 1;

	if(newkeys & KEY_NO)
	{
		new animidx = GetPlayerAnimationIndex(playerid);

		if( (animidx == 1164 || animidx == 1189) && itm_Interacting[playerid] == INVALID_ITEM_ID && Iter_Contains(itm_Index, itm_Holding[playerid]))
		{
			foreach(new i : Player)
			{
				if(i == playerid || itm_Holding[i] != INVALID_ITEM_ID || itm_Interacting[i] != INVALID_ITEM_ID)
					continue;

				if(IsPlayerInDynamicArea(playerid, gPlayerArea[i]) && !IsPlayerInAnyVehicle(i))
				{
					PlayerGiveItem(playerid, i, 1);
					return 1;
				}
			}

			PlayerDropItem(playerid);
		}
	}
	if(newkeys & 16)
	{
		new animidx = GetPlayerAnimationIndex(playerid);

		if( (animidx == 1164 || animidx == 1189) && itm_Interacting[playerid] == INVALID_ITEM_ID && Iter_Contains(itm_Index, itm_Holding[playerid]))
		{
			PlayerUseItem(playerid, itm_Holding[playerid]);
		}
	}
    return 1;
}


public OnPlayerEnterPlayerArea(playerid, targetid)
{
	if(Iter_Contains(itm_Index, itm_Holding[playerid]))
	{
		ShowMsgBox(playerid, "Press N to give item");
	}

    return CallLocalFunction("itm_OnPlayerEnterPlayerArea", "dd", playerid, targetid);
}
#if defined _ALS_OnPlayerEnterPlayerArea
    #undef OnPlayerEnterPlayerArea
#else
    #define _ALS_OnPlayerEnterPlayerArea
#endif
#define OnPlayerEnterPlayerArea itm_OnPlayerEnterPlayerArea
forward itm_OnPlayerEnterPlayerArea(playerid, targetid);

public OnPlayerLeavePlayerArea(playerid, targetid)
{
	if(Iter_Contains(itm_Index, itm_Holding[playerid]))
	{
		HideMsgBox(playerid);
	}

    return CallLocalFunction("itm_OnPlayerLeavePlayerArea", "dd", playerid, targetid);
}
#if defined _ALS_OnPlayerLeavePlayerArea
    #undef OnPlayerLeavePlayerArea
#else
    #define _ALS_OnPlayerLeavePlayerArea
#endif
#define OnPlayerLeavePlayerArea itm_OnPlayerLeavePlayerArea
forward itm_OnPlayerLeavePlayerArea(playerid, targetid);



internal_OnPlayerUseItem(playerid, itemid)
{
	new buttonid = GetPlayerButtonID(playerid);

	if(buttonid != -1)
		return CallLocalFunction("OnPlayerUseItemWithButton", "ddd", playerid, buttonid, itm_Holding[playerid]);

	return CallLocalFunction("OnPlayerUseItem", "dd", playerid, itemid);
}


public OnButtonPress(playerid, buttonid)
{
	print("OnButtonPress <Item Script>");
	if(!IsPlayerInAnyVehicle(playerid) && itm_Interacting[playerid] == INVALID_ITEM_ID)
	{
		new item = itm_Holding[playerid];

		foreach(new i : itm_WorldIndex)
		{
			if(buttonid == itm_Data[i][itm_button] && itm_Holder[i] == INVALID_PLAYER_ID && itm_Interactor[i] == INVALID_PLAYER_ID)
			{
				if(Iter_Contains(itm_Index, item))
					return CallRemoteFunction("OnPlayerUseItemWithItem", "ddd", playerid, item, i);

				new
					Float:itm_x = itm_Data[i][itm_posX],
					Float:itm_y = itm_Data[i][itm_posY];

				if(CallLocalFunction("OnPlayerPickUpItem", "dd", playerid, i))
					return 0;

				new
					Float:x,
				    Float:y,
				    Float:z;

			    GetPlayerPos(playerid, x, y, z);
			    SetPlayerFacingAngle(playerid, GetAngleToPoint(x, y, itm_x, itm_y));

				if((itm_Data[i][itm_posZ] - z) > -0.9) // If the player is more than 0.9 units above the item
					PlayerPickUpItem(playerid, i, 1);

				else
					PlayerPickUpItem(playerid, i, 0);

				itm_Interacting[playerid] = i;
				itm_Interactor[i] = playerid;

			    return 1;
			}
		}
	}
	return CallLocalFunction("itm_OnButtonPress", "dd", playerid, buttonid);
}
#if defined _ALS_OnButtonPress
	#undef OnButtonPress
#else
	#define _ALS_OnButtonPress
#endif
#define OnButtonPress itm_OnButtonPress
forward itm_OnButtonPress(playerid, buttonid);

timer PickUpItemDelay[400](playerid, id, animtype)
{
	if(animtype==0)ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_2IDLE", 4.0, 0, 0, 0, 0, 0);

	HideMsgBox(playerid);
	
	itm_Interacting[playerid] = INVALID_ITEM_ID;

	if(CallLocalFunction("OnPlayerPickedUpItem", "dd", playerid, id))
		return 1;

	GiveWorldItemToPlayer(playerid, id, 1);
	
	return 1;
}

timer DropItemDelay[400](playerid)
{
	new
	    id = itm_Holding[playerid],
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	if(!Iter_Contains(itm_Index, id))
	    return 0;

	if(CallLocalFunction("OnPlayerDroppedItem", "dd", playerid, id))
		return 0;

    itm_Holding[playerid] = INVALID_ITEM_ID;
    itm_Interacting[playerid] = INVALID_ITEM_ID;
    itm_Holder[id] = INVALID_PLAYER_ID;
    itm_Interactor[id] = INVALID_PLAYER_ID;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

   	RemovePlayerAttachedObject(playerid, ITM_ATTACH_INDEX);

	CreateItemInWorld(id,
		x + (0.5 * floatsin(-r, degrees)),
		y + (0.5 * floatcos(-r, degrees)),
		z - 0.868,
		itm_TypeData[itm_Data[id][itm_type]][itm_rotX],
		itm_TypeData[itm_Data[id][itm_type]][itm_rotY],
		itm_TypeData[itm_Data[id][itm_type]][itm_rotZ] + r,
		0.7, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), 1);

	ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_2IDLE", 4.0, 0, 0, 0, 0, 0);

	return 1;
}

timer GiveItemDelay[500](playerid, targetid)
{
	new
		id,
		ItemType:type;

	id = itm_Holding[playerid];
	type = itm_Data[id][itm_type];

	CallLocalFunction("OnPlayerGivenItem", "ddd", playerid, targetid, id);

    itm_Holding[playerid] = INVALID_ITEM_ID;
    itm_Interacting[playerid] = INVALID_ITEM_ID;
    itm_Interacting[targetid] = INVALID_ITEM_ID;
	RemovePlayerAttachedObject(playerid, ITM_ATTACH_INDEX);

	SetPlayerAttachedObject(
		targetid, ITM_ATTACH_INDEX, itm_TypeData[type][itm_model], itm_TypeData[type][itm_attachBone],
		itm_TypeData[type][itm_attachPosX], itm_TypeData[type][itm_attachPosY], itm_TypeData[type][itm_attachPosZ],
		itm_TypeData[type][itm_attachRotX], itm_TypeData[type][itm_attachRotY], itm_TypeData[type][itm_attachRotZ]);

	itm_Holding[targetid] = id;
    itm_Holder[id] = targetid;
}


GiveWorldItemToPlayer(playerid, itemid, call)
{
	if(!Iter_Contains(itm_Index, itemid))return 0;
	if(Iter_Contains(itm_WorldIndex, itemid))
	{
		if(itm_Holder[itemid] != INVALID_PLAYER_ID)return 0;
	}

	new
		ItemType:type = itm_Data[itemid][itm_type];

	if(call)
	{
		if(CallLocalFunction("OnPlayerPickUpItem", "dd", playerid, itemid))return 0;
		if(!Iter_Contains(itm_Index, itemid))return 0;
	}

	itm_Data[itemid][itm_posX]		= 0.0;
	itm_Data[itemid][itm_posY]		= 0.0;
	itm_Data[itemid][itm_posZ]		= 0.0;

    itm_Holding[playerid]			= itemid;
    itm_Holder[itemid]				= playerid;
    itm_Interacting[playerid]		= INVALID_ITEM_ID;
    itm_Interactor[itemid]			= INVALID_PLAYER_ID;

	if(Iter_Contains(itm_WorldIndex, itemid))
	{
		DestroyDynamicObject(itm_Data[itemid][itm_objId]);
		DestroyButton(itm_Data[itemid][itm_button]);
		itm_Data[itemid][itm_objId] = -1;
		itm_Data[itemid][itm_button] = INVALID_BUTTON_ID;
	}

	SetPlayerAttachedObject(
		playerid, ITM_ATTACH_INDEX, itm_TypeData[type][itm_model], itm_TypeData[type][itm_attachBone],
		itm_TypeData[type][itm_attachPosX], itm_TypeData[type][itm_attachPosY], itm_TypeData[type][itm_attachPosZ],
		itm_TypeData[type][itm_attachRotX], itm_TypeData[type][itm_attachRotY], itm_TypeData[type][itm_attachRotZ]);

	Iter_Remove(itm_WorldIndex, itemid);

	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	new item = itm_Holding[playerid];
	if(Iter_Contains(itm_Index, item))
	{
	    new
	        Float:x,
	        Float:y,
	        Float:z,
			Float:r;

		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, r);

		RemovePlayerAttachedObject(playerid, ITM_ATTACH_INDEX);
		CreateItemInWorld(item,
			x + (0.5 * floatsin(-r, degrees)),
			y + (0.5 * floatcos(-r, degrees)),
			z-0.868, 0.0, 0.0, r, 0.7,
			GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), 1);

		CallLocalFunction("OnPlayerDropItem", "dd", playerid, item);
	}
    return CallLocalFunction("itm_OnPlayerDeath", "ddd", playerid, killerid, reason);
}
#if defined _ALS_OnPlayerDeath
    #undef OnPlayerDeath
#else
    #define _ALS_OnPlayerDeath
#endif
#define OnPlayerDeath itm_OnPlayerDeath
forward itm_OnPlayerDeath(playerid, killerid, reason);

public OnPlayerEnterButtonArea(playerid, buttonid)
{
	if(!Iter_Contains(itm_Index, itm_Holding[playerid]))return 0;
    return CallLocalFunction("itm_OnPlayerEnterButtonArea", "dd", playerid, buttonid);
}
#if defined _ALS_OnPlayerEnterButtonArea
    #undef OnPlayerEnterButtonArea
#else
    #define _ALS_OnPlayerEnterButtonArea
#endif
#define OnPlayerEnterButtonArea itm_OnPlayerEnterButtonArea
forward itm_OnPlayerEnterButtonArea(playerid, buttonid);


/*==============================================================================

	Interface Functions

==============================================================================*/


stock IsValidItem(itemid)
{
	if(!Iter_Contains(itm_Index, itemid))return 0;
	return 1;
}
stock IsValidItemType(ItemType:itemtype)
{
	if(ItemType:0 <= itemtype < MAX_ITEM_TYPES)
		return itm_TypeData[itemtype][itm_used];

	return false;
}
stock GetItemPos(itemid, &Float:x, &Float:y, &Float:z)
{
	if(!Iter_Contains(itm_Index, itemid))return 0;
	x = itm_Data[itemid][itm_posX];
	y = itm_Data[itemid][itm_posY];
	z = itm_Data[itemid][itm_posZ];
	return 1;
}
stock SetItemPos(itemid, Float:x, Float:y, Float:z)
{
	if(!Iter_Contains(itm_Index, itemid))return 0;
	itm_Data[itemid][itm_posX] = x;
	itm_Data[itemid][itm_posY] = y;
	itm_Data[itemid][itm_posZ] = z;
	SetButtonPos(itm_Data[itemid][itm_button], x, y, z);
	SetDynamicObjectPos(itm_Data[itemid][itm_objId], x, y, z);
	return 1;
}
stock SetItemRotation(itemid, Float:rx, Float:ry, Float:rz)
{
	if(!Iter_Contains(itm_Index, itemid))return 0;
	if(!Iter_Contains(itm_WorldIndex, itemid))return 0;
	SetDynamicObjectRot(itm_Data[itemid][itm_objId], rx, ry, rz);
	return 1;	
}
stock ItemType:GetItemType(itemid)
{
	if(!Iter_Contains(itm_Index, itemid))return INVALID_ITEM_TYPE;
	return itm_Data[itemid][itm_type];
}
stock GetItemTypeName(ItemType:itemtype, string[])
{
	if(!IsValidItemType(itemtype))return 0;
	
	string[0] = EOS;
	strcat(string, itm_TypeData[itemtype][itm_name], MAX_ITEM_NAME);
	
	return 1;
}
stock GetItemSize(itemid)
{
	if(!Iter_Contains(itm_Index, itemid))return INVALID_ITEM_SIZE;
	return itm_TypeData[itm_Data[itemid][itm_type]][itm_size];
}
stock GetItemHolder(itemid)
{
	if(!Iter_Contains(itm_Index, itemid))return INVALID_PLAYER_ID;
	return itm_Holder[itemid];
}

stock GetPlayerItem(playerid)
{
	if(!Iter_Contains(itm_Index, itm_Holding[playerid]))return INVALID_ITEM_ID;
	return itm_Holding[playerid];
}
stock ItemType:GetPlayerItemType(playerid)
{
	if(!Iter_Contains(itm_Index, itm_Holding[playerid]))return INVALID_ITEM_TYPE;
	return itm_Data[itm_Holding[playerid]][itm_type];
}
stock RemoveCurrentItem(playerid)
{
	if(!Iter_Contains(itm_Index, itm_Holding[playerid]))return INVALID_ITEM_ID;

	new
	    id = itm_Holding[playerid],
		Float:x,
		Float:y,
		Float:z,
		Float:r;

    itm_Holding[playerid] = INVALID_ITEM_ID;
    itm_Interacting[playerid] = INVALID_ITEM_ID;
    itm_Holder[id] = INVALID_PLAYER_ID;
    itm_Interactor[id] = INVALID_PLAYER_ID;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

   	RemovePlayerAttachedObject(playerid, ITM_ATTACH_INDEX);

	CreateItemInWorld(id, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7, 0, 0, 1);

	return 1;

}

stock SetItemExtraData(itemid, data)
{
	if(!Iter_Contains(itm_Index, itemid))return 0;
	itm_Data[itemid][itm_exData] = data;
	return 1;
}
stock GetItemExtraData(itemid)
{
	if(!Iter_Contains(itm_Index, itemid))return 0;
	return itm_Data[itemid][itm_exData];
}
stock SetItemLabel(itemid, text[], colour = 0xFFFF00FF, Float:range = 10.0)
{
	if(!Iter_Contains(itm_Index, itemid))return 0;
	SetButtonLabel(itm_Data[itemid][itm_button], text, colour, range);
	return 1;
}




/*
	Can't change the material of held objects, only world objects so these
	functions are pretty useless.

enum E_ITEM_OBJECT_MATERIAL_DATA
{
			mat_objMatIndex,
			mat_modelid,
			mat_txdname			[32],
			mat_texname			[32],
			mat_colour
}
enum E_ITEM_OBJECT_TEXT_DATA
{
			mat_objTxtIndex,
			mat_text			[32],
			mat_materialsize,
			mat_font			[32],
			mat_fontsize,
			mat_bold,
			mat_fontcolour,
			mat_backcolour,
			mat_alignment
}

stock SetItemTypeObjectMaterial(ItemType:itemtype, index, model, txdname[], texname[], colour)
{
	if(!IsValidItemType(itemtype))return 0;

	itm_ObjectMaterial[itemtype][mat_objMatIndex]		= index;
	itm_ObjectMaterial[itemtype][mat_modelid]			= model;
	itm_ObjectMaterial[itemtype][mat_colour]			= colourl

	itm_ObjectMaterial[itemtype][mat_txdname][0] = EOS;
	strcat(itm_ObjectMaterial[itemtype][mat_txdname], txdname);

	itm_ObjectMaterial[itemtype][mat_texname][0] = EOS;
	strcat(itm_ObjectMaterial[itemtype][mat_texname], texname);

	t:itm_TypeData[itemtype][itm_flags]<ITEMTYPE_FLAG_MATERIAL>;

	return 1;
}
stock SetItemTypeObjectText(ItemType:itemtype, text[], index, materialsize, fontface[], fontsize, bold, fontoclour, backcolour, alignment)
{
	if(!IsValidItemType(itemtype))return 0;

	itm_ObjectText[itemtype][mat_objTxtIndex]	= index

	itm_ObjectText[itemtype][mat_text][0] = EOS;
	strcpy(itm_ObjectText[itemtype][mat_text],	text);

	itm_ObjectText[itemtype][mat_materialsize]	= materialsize;

	itm_ObjectText[itemtype][mat_font][0] = EOS;
	strcpy(itm_ObjectText[itemtype][mat_font],	fontface);

	itm_ObjectText[itemtype][mat_fontsize]		= fontsize;
	itm_ObjectText[itemtype][mat_bold]			= bold;
	itm_ObjectText[itemtype][mat_fontcolour]	= fontcolour;
	itm_ObjectText[itemtype][mat_backcolour]	= backcolour;
	itm_ObjectText[itemtype][mat_alignment]		= alignment;

	t:itm_TypeData[itemtype][itm_flags]<ITEMTYPE_FLAG_MATERIAL>;

	return 1;
}
*/
