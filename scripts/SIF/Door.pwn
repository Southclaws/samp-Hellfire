/*==============================================================================

Southclaw's Interactivity Framework (SIF) (Formerly: Adventure API)


	SIF/Overview
	{
		SIF is a collection of high-level include scripts to make the
		development of interactive features easy for the developer while
		maintaining quality front-end gameplay for players.
	}

	SIF/Door/Description
	{
		A simple object movement manager that supports buttons as the default
		method of interacting. Doors support multiple buttons, so a button on
		the inside and outside of a door is possible. Doors can be opened and
		closed manually by calling OpenDoor or CloseDoor. The door state change
		callbacks can be used to restrict the use of doors by returning 1.
	}

	SIF/Door/Dependencies
	{
		SIF/Button
		Streamer Plugin
		YSI\y_hooks
		YSI\y_timers
	}

	SIF/Door/Credits
	{
		SA:MP Team						- Amazing mod!
		SA:MP Community					- Inspiration and support
		Incognito						- Very useful streamer plugin
		Y_Less							- YSI framework
	}

	SIF/Door/Core Functions
	{
		The functions that control the core features of this script.

		native -
		native - SIF/Door/Core
		native -

		CreateDoor(model, buttonids[], Float:px,  Float:py,  Float:pz,  Float:rx,  Float:ry,  Float:rz, Float:mpx, Float:mpy, Float:mpz, Float:mrx, Float:mry, Float:mrz, Float:movespeed = 1.0, closedelay = 3000, maxbuttons = sizeof(buttonids), movesound = -1, stopsound = -1, worldid = 0, interiorid = 0, initstate = DR_STATE_CLOSED)
		{
			Description:
				Creates a world object that is assigned a move position and a
				set of buttons that will trigger it's movement.

			Parameters:
				<model> (int)
					The GTA model ID of the door.

				<buttonids[]> (array)
					An array of buttons that will be used to activate the door.

				<px>, <py>, <pz> (float, absolute world position)
					The world position of the door object.

				<rx>, <ry>, <rz> (float, euler rotation)
					The rotation of the door object.

				<mpx>, <mpy>, <mpz> (float, absolute world position)
					The world position which the door will move to.

				<mrx>, <mry>, <mrz> (float, euler rotation)
					The rotation which the door will rotate to when moved.

				<movespeed> (int)
					The speed at which the door will move (both open and close)

				<closedelay> (int)
					The time before closing after opening, when 0, the door will
					not automatically close after it finishes opening.

				<maxbuttons> (int)
					Maximum amount of buttons, automatically set to the size of
					the button array.

				<movesound> (int)
					The sound that will be played when the door moves. (either
					when opening or closing)

				<stopsound> (int)
					The sound that will be played when the door stops moving.
					(either when it finishes opening or finishes closing.)

				<worldid> (int)
					The virtual world in which the door object will be made.
					(be aware that this doesn't affect the buttons)

				<interiorid> (int)
					The interior world in which the door object will be made.
					(be aware that this doesn't affect the buttons)

				<initstate> (int)
					The initial state which the door will be created as, valid
					values are: DOOR_STATE_OPEN or DOOR_STATE_CLOSED.

			Returns:
				(int, doorid)
					Door ID handle of the newly created door.

				INVALID_DOOR_ID
					If another door cannot be created due to MAX_DOOR limit.
		}

		DestroyDoor(doorid)
		{
			Description:
				Destroys a door object and clears it's memory. This does not
				destroy the buttons associated with the door.

			Parameters:
				<doorid> (int, doorid)
					The ID handle of the door to destroy.

			Returns:
				0
					If the door ID handle is invalid.
		}
	}

	SIF/Door/Events
	{
		Events called by player actions done by using features from this script.

		native -
		native - SIF/Door/Callbacks
		native -

		native OnPlayerActivateDoor(playerid, doorid, newstate)
		{
			Called:
				Called when a player presses a door button. Depending on whether
				the door is currently open, closed, opening or closing the
				door will act differently.

			Parameters:
				<playerid> (int)
					Player who triggered the door.

				<doorid> (int, doorid)
					The ID handle of the door that was activated.

				<newstate> (int)
					The new state the door is in after being activated.

			Returns:
				1
					To cancel the door action request. This will stop the door
					from opening or closing. Useful for a door lock system.
		}
		native OnDoorStateChange(doorid, doorstate)
		{
			Called:
				Called when a door changes state between:
					DOOR_STATE_OPEN,
					DOOR_STATE_CLOSED,
					DOOR_STATE_OPENING,
					DOOR_STATE_CLOSING.
				Note: A door can never change state between OPEN and CLOSED
				without CLOSING or OPENING in between.

			Parameters:
				<doorid> (int, doorid)
					The ID handle of the door which changed state.

				<doorstate> (int, DOOR_STATE_*)
					The state which the door changed to.

			Returns:
				(nothing)
		}

	}

	SIF/Door/Interface Functions
	{
		Functions to get or set data values in this script without editing
		the data directly. These include automatic ID validation checks.

		native -
		native - SIF/Door/Interface
		native -

		native IsValidDOor(doorid)
		{
			Description:
				Checks if a door is valid.

			Parameters:
				-

			Returns:
				-
		}
		native GetDoorObjectID(doorid)
		{
			Description:
				Returns the dynamic object ID that acts as the door.

			Parameters:
				-

			Returns:
				-
		}
		native GetDoorButton(doorid, slot)
		{
			Description:
				Returns the button ID handle in the specified slot of a door.

			Parameters:
				-

			Returns:
				-
		}
		native GetDoorButtonCount(doorid)
		{
			Description:
				Returns the amount of buttons assigned to a door.

			Parameters:
				-

			Returns:
				-
		}
		native GetDoorCloseDelay(doorid)
		{
			Description:
				Returns the close delay for a door in milliseconds.

			Parameters:
				-

			Returns:
				-
		}
		native SetDoorCloseDelay(doorid, closedelay)
		{
			Description:
				Sets the close delay for a door in milliseconds.

			Parameters:
				-

			Returns:
				-
		}
		native GetDoorMoveSpeed(doorid)
		{
			Description:
				Returns a door open/close move speed.

			Parameters:
				-

			Returns:
				-
		}
		native SetDoorMoveSpeed(doorid, movespeed)
		{
			Description:
				Sets a door open/close move speed.

			Parameters:
				-

			Returns:
				-
		}
		native GetDoorMoveSound(doorid)
		{
			Description:
				Returns a door sound ID for when it moves.

			Parameters:
				-

			Returns:
				-
		}
		native SetDoorMoveSound(doorid, movesound)
		{
			Description:
				Sets the door sound ID for when it moves.

			Parameters:
				-

			Returns:
				-
		}
		native GetDoorStopSound(doorid)
		{
			Description:
				Returns the door sound ID for when it stops moving.

			Parameters:
				-

			Returns:
				-
		}
		native SetDoorStopSound(doorid, stopsound)
		{
			Description:
				Sets the door sound ID for when it stops moving.

			Parameters:
				-

			Returns:
				-
		}
		native GetDoorPos(doorid, &Float:x, &Float:y, &Float:z)
		{
			Description:
				Assigns the door object position into the referenced variables.

			Parameters:
				-

			Returns:
				-
		}
		native SetDoorPos(doorid, Float:x, Float:y, Float:z)
		{
			Description:
				Sets the door object position.

			Parameters:
				-

			Returns:
				-
		}
		native GetDoorRot(doorid, &Float:rx, &Float:ry, &Float:rz)
		{
			Description:
				Assigns the door object rotation into the referenced variables.

			Parameters:
				-

			Returns:
				-
		}
		native SetDoorRot(doorid, &Float:rx, &Float:ry, &Float:rz)
		{
			Description:
				Sets the door object rotation.

			Parameters:
				-

			Returns:
				-
		}
		native GetDoorMovePos(doorid, &Float:x, &Float:y, &Float:z)
		{
			Description:
				Assigns the door object move position into the referenced
				variables.

			Parameters:
				-

			Returns:
				-
		}
		native SetDoorMovePos(doorid, Float:x, Float:y, Float:z)
		{
			Description:
				Sets the door object move position.

			Parameters:
				-

			Returns:
				-
		}
		native GetDoorMoveRot(doorid, &Float:rx, &Float:ry, &Float:rz)
		{
			Description:
				Assigns the door object move rotation into the referenced
				variables.

			Parameters:
				-

			Returns:
				-
		}
		native SetDoorMoveRot(doorid, Float:rx, Float:ry, Float:rz)
		{
			Description:
				Sets the door object move rotation.

			Parameters:
				-

			Returns:
				-
		}
	}

	SIF/Door/Internal Functions
	{
		Internal events called by player actions done by using features from
		this script.

		OpenDoor(doorid)
		{
			Description:
				Moves a door object to it's open position.
		}
		CloseDoor(doorid)
		{
			Description:
				Moves a door object to it's closed position.
		}
	}

	SIF/Door/Hooks
	{
		Hooked functions or callbacks, either SA:MP natives or from other
		scripts or plugins.

		SIF/Button/OnButtonPress
		{
			Reason:
				Detect when a player presses a button associated with a door.
		}
		Streamer/OnDynamicObjectMoved
		{
			Reason:
				Detect when a door object stops moving in order to play the stop
				sound and close it again if a close delay value is set.
		}
	}

==============================================================================*/


/*==============================================================================

	Setup

==============================================================================*/


#define MAX_DOOR				(64)
#define MAX_BUTTONS_PER_DOOR	(4)
#define INVALID_DOOR_ID			(-1)

#define DR_STATE_OPEN			(0)
#define DR_STATE_CLOSED			(1)
#define DR_STATE_OPENING		(2)
#define DR_STATE_CLOSING		(3)


enum E_DOOR_DATA
{
			dr_objectid,
			dr_buttonArray[MAX_BUTTONS_PER_DOOR],
			dr_buttonCount,
			dr_closeDelay,
Float:		dr_moveSpeed,
			dr_moveSound,
			dr_stopSound,

Float:		dr_posX,
Float:		dr_posY,
Float:		dr_posZ,
Float:		dr_rotX,
Float:		dr_rotY,
Float:		dr_rotZ,

Float:		dr_posMoveX,
Float:		dr_posMoveY,
Float:		dr_posMoveZ,
Float:		dr_rotMoveX,
Float:		dr_rotMoveY,
Float:		dr_rotMoveZ
}

static
			dr_Data[MAX_DOOR][E_DOOR_DATA],
			dr_State[MAX_DOOR char],
Iterator:	dr_Index<MAX_DOOR>;


forward OnPlayerActivateDoor(playerid, doorid, newstate);
forward OnDoorStateChange(doorid, doorstate);


/*==============================================================================

	Core Functions

==============================================================================*/


CreateDoor(model, buttonids[],
	Float:px,  Float:py,  Float:pz,  Float:rx,  Float:ry,  Float:rz,
	Float:mpx, Float:mpy, Float:mpz, Float:mrx, Float:mry, Float:mrz,
	Float:movespeed = 1.0, closedelay = 3000, maxbuttons = sizeof(buttonids),
	movesound = -1, stopsound = -1,
	worldid = 0, interiorid = 0, initstate = DR_STATE_CLOSED)
{
	new id = Iter_Free(dr_Index);

	if(id == -1)
		return INVALID_DOOR_ID;

	dr_Data[id][dr_objectid] = CreateDynamicObject(model, px, py, pz, rx, ry, rz, worldid, interiorid);
	dr_Data[id][dr_buttonCount] = maxbuttons;
	dr_Data[id][dr_closeDelay] = closedelay;
	dr_Data[id][dr_moveSpeed] = movespeed;

	for(new i; i < maxbuttons; i++)
		dr_Data[id][dr_buttonArray][i] = buttonids[i];

	dr_Data[id][dr_moveSound] = movesound;
	dr_Data[id][dr_stopSound] = stopsound;

	dr_Data[id][dr_posX] = px;
	dr_Data[id][dr_posY] = py;
	dr_Data[id][dr_posZ] = pz;
	dr_Data[id][dr_rotX] = rx;
	dr_Data[id][dr_rotY] = ry;
	dr_Data[id][dr_rotZ] = rz;

	dr_Data[id][dr_posMoveX] = mpx;
	dr_Data[id][dr_posMoveY] = mpy;
	dr_Data[id][dr_posMoveZ] = mpz;
	dr_Data[id][dr_rotMoveX] = mrx;
	dr_Data[id][dr_rotMoveY] = mry;
	dr_Data[id][dr_rotMoveZ] = mrz;

	dr_State{id} = initstate;

	Iter_Add(dr_Index, id);
	return id;
}

stock DestroyDoor(doorid)
{
	if(!Iter_Contains(dr_Index, doorid))
		return 0;

	for(new i; i < dr_Data[id][dr_buttonCount]; i++)
		dr_Data[id][dr_buttonArray][i] = INVALID_BUTTON_ID;

	DestroyDynamicObject(dr_Data[id][dr_objectid]);
	dr_Data[id][dr_buttonCount] = 0;
	dr_Data[id][dr_closeDelay] = 0;
	dr_Data[id][dr_moveSpeed] = 0.0;

	dr_Data[id][dr_moveSound] = 0;
	dr_Data[id][dr_stopSound] = 0;

	dr_Data[id][dr_posX] = 0.0;
	dr_Data[id][dr_posY] = 0.0;
	dr_Data[id][dr_posZ] = 0.0;
	dr_Data[id][dr_rotX] = 0.0;
	dr_Data[id][dr_rotY] = 0.0;
	dr_Data[id][dr_rotZ] = 0.0;

	dr_Data[id][dr_posMoveX] = 0.0;
	dr_Data[id][dr_posMoveY] = 0.0;
	dr_Data[id][dr_posMoveZ] = 0.0;
	dr_Data[id][dr_rotMoveX] = 0.0;
	dr_Data[id][dr_rotMoveY] = 0.0;
	dr_Data[id][dr_rotMoveZ] = 0.0;

	dr_State{id} = 0;

	Iter_Remove(dr_Index, id);
	return 1;
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


public OnButtonPress(playerid, buttonid)
{
	print("OnButtonPress <Door Script>");
	foreach(new i : dr_Index)
	{
		for(new j; j < dr_Data[i][dr_buttonCount]; j++)
		{
			if(buttonid == dr_Data[i][dr_buttonArray][j])
			{
				if(dr_State{i} == DR_STATE_CLOSED)
				{
					if(CallLocalFunction("OnPlayerActivateDoor", "ddd", playerid, i, DR_STATE_OPENING))
						return 0;

					OpenDoor(i);
				}

				if(dr_State{i} == DR_STATE_OPEN)
				{
					if(CallLocalFunction("OnPlayerActivateDoor", "ddd", playerid, i, DR_STATE_CLOSING))
						return 0;

					CloseDoor(i);
				}
			}
		}
	}
	return CallLocalFunction("dr_OnButtonPress", "dd", playerid, buttonid);
}
#if defined _ALS_OnButtonPress
    #undef OnButtonPress
#else
    #define _ALS_OnButtonPress
#endif
#define OnButtonPress dr_OnButtonPress
forward dr_OnButtonPress(playerid, buttonid);


OpenDoor(doorid)
{
	if(!Iter_Contains(dr_Index, doorid))return 0;

	MoveDynamicObject(dr_Data[doorid][dr_objectid],
		dr_Data[doorid][dr_posMoveX], dr_Data[doorid][dr_posMoveY], dr_Data[doorid][dr_posMoveZ], dr_Data[doorid][dr_moveSpeed],
		dr_Data[doorid][dr_rotMoveX], dr_Data[doorid][dr_rotMoveY], dr_Data[doorid][dr_rotMoveZ]);

	dr_State{doorid} = DR_STATE_OPENING;

	if(dr_Data[doorid][dr_moveSound] != -1)
		PlaySound(dr_Data[doorid][dr_moveSound], dr_Data[doorid][dr_posX], dr_Data[doorid][dr_posY], dr_Data[doorid][dr_posZ]);

	CallLocalFunction("OnDoorStateChange", "dd", doorid, DR_STATE_OPENING);

	return 1;
}

timer CloseDoor[ dr_Data[doorid][dr_closeDelay] ](doorid)
{
	if(!Iter_Contains(dr_Index, doorid))return 0;

	MoveDynamicObject(dr_Data[doorid][dr_objectid],
		dr_Data[doorid][dr_posX], dr_Data[doorid][dr_posY], dr_Data[doorid][dr_posZ], dr_Data[doorid][dr_moveSpeed],
		dr_Data[doorid][dr_rotX], dr_Data[doorid][dr_rotY], dr_Data[doorid][dr_rotZ]);

	dr_State{doorid} = DR_STATE_CLOSING;

	if(dr_Data[doorid][dr_moveSound] != -1)
		PlaySound(dr_Data[doorid][dr_moveSound], dr_Data[doorid][dr_posX], dr_Data[doorid][dr_posY], dr_Data[doorid][dr_posZ]);

	CallLocalFunction("OnDoorStateChange", "dd", doorid, DR_STATE_CLOSING);

	return 1;
}

public OnDynamicObjectMoved(objectid)
{
	foreach(new i : dr_Index)
	{
	    if(objectid == dr_Data[i][dr_objectid] && dr_State{i} == DR_STATE_OPENING)
	    {
	        dr_State{i} = DR_STATE_OPEN;
	        if(dr_Data[i][dr_closeDelay] >= 0)
		        defer CloseDoor(i);

			if(dr_Data[i][dr_stopSound] != -1)
				PlaySound(dr_Data[i][dr_stopSound], dr_Data[i][dr_posX], dr_Data[i][dr_posY], dr_Data[i][dr_posZ]);

			CallLocalFunction("OnDoorStateChange", "dd", i, DR_STATE_OPEN);
	    }
	    if(objectid == dr_Data[i][dr_objectid] && dr_State{i} == DR_STATE_CLOSING)
	    {
	        dr_State{i} = DR_STATE_CLOSED;

			if(dr_Data[i][dr_stopSound] != -1)
				PlaySound(dr_Data[i][dr_stopSound], dr_Data[i][dr_posX], dr_Data[i][dr_posY], dr_Data[i][dr_posZ]);

			CallLocalFunction("OnDoorStateChange", "dd", i, DR_STATE_CLOSED);
	    }
	}
    return CallLocalFunction("dr_OnDynamicObjectMoved", "d", objectid);
}
#if defined _ALS_OnDynamicObjectMoved
    #undef OnDynamicObjectMoved
#else
    #define _ALS_OnDynamicObjectMoved
#endif
#define OnDynamicObjectMoved dr_OnDynamicObjectMoved
forward dr_OnDynamicObjectMoved(objectid);


/*==============================================================================

	Interface Functions

==============================================================================*/


stock IsValidDOor(doorid)
{
	if(!Iter_Contains(dr_Index, doorid))
		return 0;

	return 1;
}

// dr_objectid
stock GetDoorObjectID(doorid)
{
	if(!Iter_Contains(dr_Index, doorid))
		return -1;

	return dr_Data[doorid][dr_objectid];
}

// dr_buttonArray[MAX_BUTTONS_PER_DOOR]
stock GetDoorButton(doorid, slot)
{
	if(!Iter_Contains(dr_Index, doorid))
		return -1;

	if(!(0 <= slot < dr_Data[doorid][dr_buttonCount]))
		return -2;

	return dr_Data[doorid][dr_buttonArray][slot];
}

// dr_buttonCount
stock GetDoorButtonCount(doorid)
{
	if(!Iter_Contains(dr_Index, doorid))
		return -1;

	return dr_Data[doorid][dr_buttonCount];
}

// dr_closeDelay
stock GetDoorCloseDelay(doorid)
{
	if(!Iter_Contains(dr_Index, doorid))
		return -1;

	return dr_Data[doorid][dr_closeDelay];
}
stock SetDoorCloseDelay(doorid, closedelay)
{
	if(!Iter_Contains(dr_Index, doorid))
		return -1;

	dr_Data[doorid][dr_closeDelay] = closedelay;

	return 1;
}

// dr_moveSpeed
stock GetDoorMoveSpeed(doorid)
{
	if(!Iter_Contains(dr_Index, doorid))
		return -1;

	return dr_Data[doorid][dr_moveSpeed];
}
stock SetDoorMoveSpeed(doorid, movespeed)
{
	if(!Iter_Contains(dr_Index, doorid))
		return -1;

	dr_Data[doorid][dr_moveSpeed] = movespeed;

	return 1;
}

// dr_moveSound
stock GetDoorMoveSound(doorid)
{
	if(!Iter_Contains(dr_Index, doorid))
		return -1;

	return dr_Data[doorid][dr_moveSound];
}
stock SetDoorMoveSound(doorid, movesound)
{
	if(!Iter_Contains(dr_Index, doorid))
		return -1;

	dr_Data[doorid][dr_moveSound] = movesound;

	return 1;
}

// dr_stopSound
stock GetDoorStopSound(doorid)
{
	if(!Iter_Contains(dr_Index, doorid))
		return -1;

	return dr_Data[doorid][dr_stopSound];
}
stock SetDoorStopSound(doorid, stopsound)
{
	if(!Iter_Contains(dr_Index, doorid))
		return -1;

	dr_Data[doorid][dr_stopSound] = stopsound;

	return 1;
}

// dr_posX
// dr_posY
// dr_posZ
stock GetDoorPos(doorid, &Float:x, &Float:y, &Float:z)
{
	if(!Iter_Contains(dr_Index, doorid))
		return 0;

	x = dr_Data[doorid][dr_posX];
	y = dr_Data[doorid][dr_posY];
	z = dr_Data[doorid][dr_posZ];
	
	return 1;
}
stock SetDoorPos(doorid, Float:x, Float:y, Float:z)
{
	if(!Iter_Contains(dr_Index, doorid))
		return 0;

	dr_Data[doorid][dr_posX] = x;
	dr_Data[doorid][dr_posY] = y;
	dr_Data[doorid][dr_posZ] = z;

	SetDynamicObjectPos(dr_Data[doorid][dr_objectid], x, y, z);
	
	return 1;
}

// dr_rotX
// dr_rotY
// dr_rotZ
stock GetDoorRot(doorid, &Float:rx, &Float:ry, &Float:rz)
{
	if(!Iter_Contains(dr_Index, doorid))
		return 0;

	rx = dr_Data[doorid][dr_rotX];
	ry = dr_Data[doorid][dr_rotY];
	rz = dr_Data[doorid][dr_rotZ];
	
	return 1;
}
stock SetDoorRot(doorid, &Float:rx, &Float:ry, &Float:rz)
{
	if(!Iter_Contains(dr_Index, doorid))
		return 0;

	dr_Data[doorid][dr_rotX] = rx;
	dr_Data[doorid][dr_rotY] = ry;
	dr_Data[doorid][dr_rotZ] = rz;

	SetDynamicObjectRot(dr_Data[doorid][dr_objectid], rx, ry, rz);
	
	return 1;
}

// dr_posMoveX
// dr_posMoveY
// dr_posMoveZ
stock GetDoorMovePos(doorid, &Float:x, &Float:y, &Float:z)
{
	if(!Iter_Contains(dr_Index, doorid))
		return 0;

	x = dr_Data[doorid][dr_posMoveX];
	y = dr_Data[doorid][dr_posMoveY];
	z = dr_Data[doorid][dr_posMoveZ];
	
	return 1;
}
stock SetDoorMovePos(doorid, Float:x, Float:y, Float:z)
{
	if(!Iter_Contains(dr_Index, doorid))
		return 0;

	dr_Data[doorid][dr_posMoveX] = x;
	dr_Data[doorid][dr_posMoveY] = y;
	dr_Data[doorid][dr_posMoveZ] = z;

	return 1;
}

// dr_rotMoveX
// dr_rotMoveY
// dr_rotMoveZ
stock GetDoorMoveRot(doorid, &Float:rx, &Float:ry, &Float:rz)
{
	if(!Iter_Contains(dr_Index, doorid))
		return 0;

	rx = dr_Data[doorid][dr_rotMoveX];
	ry = dr_Data[doorid][dr_rotMoveY];
	rz = dr_Data[doorid][dr_rotMoveZ];
	
	return 1;
}
stock SetDoorMoveRot(doorid, Float:rx, Float:ry, Float:rz)
{
	if(!Iter_Contains(dr_Index, doorid))
		return 0;

	dr_Data[doorid][dr_rotMoveX] = rx;
	dr_Data[doorid][dr_rotMoveY] = ry;
	dr_Data[doorid][dr_rotMoveZ] = rz;
	
	return 1;
}


