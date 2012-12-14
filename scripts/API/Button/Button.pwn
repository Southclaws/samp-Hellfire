#include <YSI\y_hooks>

#define MAX_BUTTON			(1024)
#define INVALID_BUTTON_ID	(-1)


/*
native CreateButton(Float:x, Float:y, Float:z, Msg[], world=0, interior=0, type=0, label=0)
native LinkTP(buttonid1, buttonid2)
native UnLinkTP(buttonid1, buttonid2)
native IsValidButtonID(buttonid)
native IsButtonActive(buttonid)
native SetButtonMessage(buttonid, Msg[])
native SetButtonUsable(buttonid, bool:toggle)
native SetButtonLabel(buttonid, text[], colour = 0xFFFF00FF, Float:range = 10.0)
*/



enum E_BTN_DATA
{
		btn_area,
Text3D:	btn_label,
Float:	btn_posX,
Float:	btn_posY,
Float:	btn_posZ,
		btn_world,
		btn_interior,
		btn_link,
		btn_msg[128]
}


new
	btn_Data[MAX_BUTTON][E_BTN_DATA],
	Iterator:btn_Index<MAX_BUTTON>,
	btn_Pressing[MAX_PLAYERS];


forward OnButtonPress(playerid, buttonid);
forward OnButtonRelease(playerid, buttonid);
forward OnPlayerEnterButtonArea(playerid, buttonid);
forward OnPlayerLeaveButtonArea(playerid, buttonid);


#if defined FILTERSCRIPT
hook OnFilterScriptInit()
#else
hook OnGameModeInit()
#endif
{
	for(new i;i<MAX_PLAYERS;i++)
	{
	    btn_Pressing[i] = INVALID_BUTTON_ID;
	}
}


CreateButton(Float:x, Float:y, Float:z, Msg[], world=0, interior=0, Float:areasize = 1.0)
{
	new id = Iter_Free(btn_Index);

	btn_Data[id][btn_area]				= CreateDynamicSphere(x, y, z, areasize, world, interior);

	btn_Data[id][btn_posX]				= x;
	btn_Data[id][btn_posY]				= y;
	btn_Data[id][btn_posZ]				= z;
	btn_Data[id][btn_world]				= world;
	btn_Data[id][btn_interior]			= interior;
	btn_Data[id][btn_link]				= INVALID_BUTTON_ID;
	format(btn_Data[id][btn_msg], 128, Msg);

	Iter_Add(btn_Index, id);
	return id;
}
stock DestroyButton(id)
{
	if(!Iter_Contains(btn_Index, id))return 0;

	DestroyDynamicArea(btn_Data[id][btn_area]);
	DestroyDynamic3DTextLabel(btn_Data[id][btn_label]);

	btn_Data[id][btn_posX]				= 0.0;
	btn_Data[id][btn_posY]				= 0.0;
	btn_Data[id][btn_posZ]				= 0.0;
	btn_Data[id][btn_world]				= 0;
	btn_Data[id][btn_interior]			= 0;
	btn_Data[id][btn_link]				= INVALID_BUTTON_ID;
	btn_Data[id][btn_msg][0]			= EOS;

	foreach(new i : Player)
		if(IsPlayerViewingMsgBox(i))
			HideMsgBox(i);

	Iter_Remove(btn_Index, id);
	return 1;
}

stock LinkTP(buttonid1, buttonid2)
{
	if(!Iter_Contains(btn_Index, buttonid1) || !Iter_Contains(btn_Index, buttonid2))return 0;

	btn_Data[buttonid1][btn_link] = buttonid2;
	btn_Data[buttonid2][btn_link] = buttonid1;

	return 1;
}
stock UnLinkTP(buttonid1, buttonid2)
{
	if(!Iter_Contains(btn_Index, buttonid1) || !Iter_Contains(btn_Index, buttonid2))return 0;

	btn_Data[buttonid1][btn_link] = INVALID_BUTTON_ID;
	btn_Data[buttonid2][btn_link] = INVALID_BUTTON_ID;

	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & 16)
	{
		foreach(new i : btn_Index)
		{
			if(IsPlayerInDynamicArea(playerid, btn_Data[i][btn_area]))
			{
				Internal_OnButtonPress(playerid, i);
				break;
			}
		}
	}
	if(oldkeys & 16)
	{
	    if(btn_Pressing[playerid] != INVALID_BUTTON_ID)
	    {
			CallLocalFunction("OnButtonRelease", "dd", playerid, btn_Pressing[playerid]);
			btn_Pressing[playerid] = INVALID_BUTTON_ID;
	    }
	}
    return 1;
}

Internal_OnButtonPress(playerid, buttonid)
{
	printf("\n\nOnButtonPress <Root Script> buttonid: %d", buttonid);

	if(!Iter_Contains(btn_Index, buttonid))return 0;

	new id = btn_Data[buttonid][btn_link];
	
	if(Iter_Contains(btn_Index, id))
	{
		TogglePlayerControllable(playerid, false);
		defer btn_Unfreeze(playerid);

		SetPlayerVirtualWorld(playerid, btn_Data[id][btn_world]);
		SetPlayerInterior(playerid, btn_Data[id][btn_interior]);
		SetPlayerPos(playerid, btn_Data[id][btn_posX], btn_Data[id][btn_posY], btn_Data[id][btn_posZ]);

		Streamer_UpdateEx(playerid,
			btn_Data[id][btn_posX], btn_Data[id][btn_posY], btn_Data[id][btn_posZ],
			btn_Data[id][btn_world], btn_Data[id][btn_interior]);
	}
	else
	{
        btn_Pressing[playerid] = buttonid;
		CallLocalFunction("OnButtonPress", "dd", playerid, buttonid);
	}
	return 1;
}

timer btn_Unfreeze[1000](playerid)
{
	TogglePlayerControllable(playerid, true);
}

public OnPlayerEnterDynamicArea(playerid, areaid)
{
    foreach(new i : btn_Index)
	{
		if(areaid == btn_Data[i][btn_area])
		{
			ShowMsgBox(playerid, btn_Data[i][btn_msg]);
			CallLocalFunction("OnPlayerEnterButtonArea", "dd", playerid, i);
			break;
		}
	}
    return CallLocalFunction("btn_OnPlayerEnterDynamicArea", "dd", playerid, areaid);
}
#if defined _ALS_OnPlayerEnterDynamicArea
    #undef OnPlayerEnterDynamicArea
#else
    #define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea btn_OnPlayerEnterDynamicArea
forward btn_OnPlayerEnterDynamicArea(playerid, areaid);


public OnPlayerLeaveDynamicArea(playerid, areaid)
{
    foreach(new i : btn_Index)
	{
		if(areaid == btn_Data[i][btn_area])
		{
		    CallLocalFunction("OnPlayerLeaveButtonArea", "dd", playerid, i);
			HideMsgBox(playerid);
			break;
		}
	}
    return CallLocalFunction("btn_OnPlayerLeaveDynamicArea", "dd", playerid, areaid);
}
#if defined _ALS_OnPlayerLeaveDynamicArea
    #undef OnPlayerLeaveDynamicArea
#else
    #define _ALS_OnPlayerLeaveDynamicArea
#endif
#define OnPlayerLeaveDynamicArea btn_OnPlayerLeaveDynamicArea
forward btn_OnPlayerLeaveDynamicArea(playerid, areaid);


// Extras

stock IsValidButtonID(buttonid)
{
	if(!Iter_Contains(btn_Index, buttonid))return 0;
	return 1;
}

stock GetPlayerButtonArea(playerid)
{
	foreach(new i : btn_Index)
		if(IsPlayerInDynamicArea(playerid, btn_Data[i][btn_area]))return i;

	return INVALID_BUTTON_ID;
}

stock GetButtonPos(buttonid, &Float:x, &Float:y, &Float:z)
{
	if(!Iter_Contains(btn_Index, buttonid))return 0;

	x = btn_Data[buttonid][btn_posX];
	y = btn_Data[buttonid][btn_posY];
	z = btn_Data[buttonid][btn_posZ];

	return 1;
}

stock GetButtonLinkedID(buttonid)
{
	if(!Iter_Contains(btn_Index, buttonid))return INVALID_BUTTON_ID;
	return btn_Data[buttonid2][btn_link][buttonid];
}

stock SetButtonMessage(buttonid, msg[])
{
	if(!Iter_Contains(btn_Index, buttonid))return 0;

    btn_Data[buttonid][btn_msg][0] = EOS;
	strcpy(btn_Data[buttonid][btn_msg], msg);

	foreach(new i : Player)
		if(IsPlayerViewingMsgBox(i))
			ShowMsgBox(playerid, btn_Data[i][btn_msg]);

	return 1;
}

stock SetButtonLabel(buttonid, text[], colour = 0xFFFF00FF, Float:range = 10.0)
{
	if(!Iter_Contains(btn_Index, buttonid))return 0;

	if(IsValidDynamic3DTextLabel(btn_Data[buttonid][btn_label]))
	{
	    UpdateDynamic3DTextLabelText(btn_Data[buttonid][btn_label], colour, text);
	}
	else
	{
		btn_Data[buttonid][btn_label] = CreateDynamic3DTextLabel(text, colour,
			btn_Data[buttonid][btn_posX],
			btn_Data[buttonid][btn_posY],
			btn_Data[buttonid][btn_posZ],
			range, _, _, 1,
			btn_Data[buttonid][btn_world], btn_Data[buttonid][btn_interior], _, range);
	}
	return 1;
}
stock DestroyButtonLabel(buttonid)
{
	if(!IsValidDynamic3DTextLabel(btn_Data[buttonid][btn_label]))return 0;
	DestroyDynamic3DTextLabel(btn_Data[buttonid][btn_label]);
	btn_Data[buttonid][btn_label] = INVALID_3D_TEXT_LABEL_ID;
	return 1;
}
