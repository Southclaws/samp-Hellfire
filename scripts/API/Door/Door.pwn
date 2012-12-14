#define MAX_DOOR				(64)
#define MAX_BUTTONS_PER_DOOR	(4)

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
	Float:dr_moveSpeed,

	Float:dr_posX,
	Float:dr_posY,
	Float:dr_posZ,
	Float:dr_rotX,
	Float:dr_rotY,
	Float:dr_rotZ,

	Float:dr_posMoveX,
	Float:dr_posMoveY,
	Float:dr_posMoveZ,
	Float:dr_rotMoveX,
	Float:dr_rotMoveY,
	Float:dr_rotMoveZ
}

new
	dr_Data[MAX_DOOR][E_DOOR_DATA],
	dr_State[MAX_DOOR char],
	Iterator:dr_Index<MAX_DOOR>;


forward OnPlayerActivateDoor(playerid, doorid, newstate);
forward OnDoorStateChange(doorid, doorstate);


CreateDoor(model, buttonids[],
	Float:px,  Float:py,  Float:pz,  Float:rx,  Float:ry,  Float:rz,
	Float:mpx, Float:mpy, Float:mpz, Float:mrx, Float:mry, Float:mrz,
	Float:movespeed = 1.0, closedelay = 3000, maxbuttons = sizeof(buttonids),
	worldid = 0, interiorid = 0, initstate = DR_STATE_CLOSED)
{
	new id = Iter_Free(dr_Index);

	dr_Data[id][dr_objectid] = CreateDynamicObject(model, px, py, pz, rx, ry, rz, worldid, interiorid);
	dr_Data[id][dr_buttonCount] = maxbuttons;
	dr_Data[id][dr_closeDelay] = closedelay;
	dr_Data[id][dr_moveSpeed] = movespeed;
	for(new i;i<maxbuttons;i++)dr_Data[id][dr_buttonArray][i] = buttonids[i];

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

			CallLocalFunction("OnDoorStateChange", "dd", i, DR_STATE_OPEN);
	    }
	    if(objectid == dr_Data[i][dr_objectid] && dr_State{i} == DR_STATE_CLOSING)
	    {
	        dr_State{i} = DR_STATE_CLOSED;
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


// Interface


GetDoorPos(doorid, &Float:x, &Float:y, &Float:z)
{
	if(!Iter_Contains(dr_Index, doorid))return 0;

	x = dr_Data[doorid][dr_posX];
	y = dr_Data[doorid][dr_posY];
	z = dr_Data[doorid][dr_posZ];
	
	return 1;
}
