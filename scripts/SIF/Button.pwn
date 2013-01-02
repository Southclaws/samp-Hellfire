/*==============================================================================

Southclaw's Interactivity Framework (SIF) (Formerly: Adventure API)


	SIF/Overview
	{
		SIF is a collection of high-level include scripts to make the
		development of interactive features easy for the developer while
		maintaining quality front-end gameplay for players.
	}

	SIF/Button/Description
	{
		A simple framework using streamer areas and key checks to give
		the in-game effect of physical buttons that players must press instead
		of using a command. It was created as an alternative to the default
		GTA:SA spinning pickups for a few reasons:

			1. A player might want to stand where a pickup is but not use it
			(if the	pickup is a building entrance or interior warp, he might
			want to stand in the doorway without being teleported.)

			2. Making hidden doors or secrets that can only be found by walking
			near the button area and seeing the textdraw. (or spamming F!)

			3. Spinning objects don't really add immersion to a role-play
			environment!
	}

	SIF/Button/Dependencies
	{
		Streamer Plugin
		YSI\y_hooks
		YSI\y_timers
	}

	SIF/Button/Credits
	{
		SA:MP Team						- Amazing mod!
		SA:MP Community					- Inspiration and support
		Incognito						- Very useful streamer plugin
		Y_Less							- YSI framework
	}

	SIF/Button/Core Functions
	{
		The functions that control the core features of this script.

		native -
		native - SIF/Button/Core
		native -

		native CreateButton(Float:x, Float:y, Float:z, text[], world = 0, interior = 0, Float:areasize = 1.0, label = 0, labeltext[] = "", labelcolour = 0xFFFF00FF, Float:streamdist = 10.0)
		{
			Description:
				Creates an interactive button players can activate by pressing F.

			Parameters:
				<x>, <y>, <z> (float)
					X, Y and Z world position.

				<text> (string)
					Message box text for when the player approaches the button.

				<world>	(int)
					The virtual world to show the button in.

				<interior> (int)
					The interior world to show the button in.

				<areasize> (float)
					Size of the button's detection area.

				<label> (boolean)
					Determines whether a 3D Text Label should be at the button.

				<labeltext> (string)
					The text that the label should show.

				<labelcolour> (int)
					The colour of the label.

				<streamdist> (float)
					Stream distance of the label.


			Returns:
				(int, buttonid)
					Button ID handle of the newly created button.

				INVALID_BUTTON_ID
					If another button cannot be created due to MAX_BUTTON limit.
		}

		native DestroyButton(buttonid)
		{
			Description:
				Destroys a button.

			Parameters:
				<buttonid> (int, buttonid)
					The button handle ID to delete.

			Returns:
				1
					If destroying the button was successful

				0
					If <buttonid> is an invalid button ID handle.
		}
	
		native LinkTP(buttonid1, buttonid2)
		{
			Description:
				Links two buttons to be teleport buttons, if a user presses
				<buttonid1> he will be teleported to the position of <buttonid2>
				and vice versa, the buttonids require no particular order.
	
			Parameters:
				<buttonid1> (int, buttonid)
					The first button ID to link.

				<buttonid2> (int, buttonid)
					The second button ID to link <buttonid1> to.

			Returns:
				1
					If the link was successful
				0
					If either of the button IDs are invalid.
		}
	
		native UnLinkTP(buttonid1, buttonid2)
		{
			Description:
				Un-links two linked buttons
	
			Parameters:
				<buttonid1> (int, buttonid)
					The first button ID to un-link, must be a linked button.

				<buttonid2> (int, buttonid)
					The second button ID to un-link, must be a linked button.

			Returns:
				0
					If either of the button IDs are invalid.

				-1
					If either of the button IDs are not linked.

				-2
					If both buttons are linked, but not to each other.
		}
	}

	SIF/Button/Events
	{
		Events called by player actions done by using features from this script.

		native -
		native - SIF/Button/Callbacks
		native -

		native OnButtonPress(playerid, buttonid)
		{
			Called:
				When a player presses the F/Enter key while at a button.

			Parameters:
				<playerid> (int)
					The ID of the player who pressed the button.

				<buttonid> (int, buttonid)
					The ID handle of the button he pressed.

			Returns:
				0
					To allow a linked button teleport.

				1
					To deny a linked button teleport.
		}

		native OnButtonRelease(playerid, buttonid)
		{
			Called:
				When a player releases the F/Enter key after pressing it while
				at a button.

			Parameters:
				<playerid> (int)
					The ID of the player who originally pressed the button.

				<buttonid> (int, buttonid)
					The ID handle of the button he was at when he originally
					pressed the F/Enter key.

			Returns:
				(none)
		}

		native OnPlayerEnterButtonArea(playerid, buttonid)
		{
			Called:
				When a player enters the dynamic streamed area of a button.

			Parameters:
				<playerid> (int)
					The ID of the player who entered the button area.

				<buttonid> (int, buttonid)
					The ID handle of the button.

			Returns:
				(none)
		}

		native OnPlayerLeaveButtonArea(playerid, buttonid)
		{
			Called:
				When a player leaves the dynamic streamed area of a button.

			Parameters:
				<playerid> (int)
					The ID of the player who left the button area.

				<buttonid> (int, buttonid)
					The ID handle of the button.

			Returns:
				(none)
		}
	}

	SIF/Button/Interface Functions
	{
		Functions to get or set data values in this script without editing
		the data directly. These include automatic ID validation checks.

		native -
		native - SIF/Button/Interface
		native -

		native IsValidButtonID(buttonid)
		{
			Description:
				Checks if <buttonid> is a valid button ID handle.

			Parameters:
				<buttonid> (int, buttonid)
					The button ID handle to check.

			Returns:
				1
					If the button ID handle <buttonid> is valid.

				0
					If the button ID handle <buttonid> is invalid.
		}

		native GetButtonPos(buttonid, &Float:x, &Float:y, &Float:z)
		{
			Description:

			Parameters:
				<buttonid> (int, buttonid)
					The ID handle of the button to get the position of.

				<x, y, z> (float)
					The X, Y and Z values of the button's position in the world.

			Returns:
				1
					If the position was obtained successfully.

				0
					If <buttonid> is an invalid button ID handle.
		}

		native SetButtonPos(buttonid, Float:x, Float:y, Float:z)
		{
			Description:
				Sets the world position for a button area and 3D Text label
				if it exists.

			Parameters:
				<buttonid> (int, buttonid)
					The ID handle of the button to set the position of.

				<x, y, z> (float)
					The X, Y and Z position values to set the button to.

			Returns:
				1
					If the position was set successfully.

				0
					If <buttonid> is an invalid button ID handle.
		}

		native GetPlayerButtonArea(playerid)
		{
			Description:
				Returns the ID of the button which <playerid> is within the area
				of if any.

			Parameters:
				<playerid> (int)
					The player you want to retreive the button area of.

			Returns:
				(int)
					Button ID handle of the button area that the player is in.

				INVALID_BUTTON_ID
					If the player isn't in a button's area.
		}

		native GetButtonLinkedID(buttonid)
		{
			Description:
				Returns the linked button of <buttonid>.

			Parameters:
				<buttonid> (int, buttonid)
					The button ID handle to get the linked button from.

			Returns:
				(int, buttonid)
					The button ID handle that <buttonid> is linked to

				INVALID_BUTTON_ID
					If the button isn't linked to another button.
		}

		native SetButtonMessage(buttonid, msg[])
		{
			Description:
				Sets the button's on-screen message text for when a player
				enters the button's area.

			Parameters:
				<buttonid> (int, buttonid)
					The button ID handle to set the message text of.

				<msg> (string)
					The text to set the message to.

			Returns:
				1
					If the message text was set successfully.

				0
					If <buttonid> is an invalid button ID handle.
		}

		native SetButtonLabel(buttonid, text[], colour = 0xFFFF00FF, Float:range = 10.0)
		{
			Description:
				Creates a 3D Text Label at the specified button ID handle, if
				a label already exists it updates the text, colour and range.

			Parameters:
				<buttonid> (int, buttonid)
					The button ID handle to set the label of.

				<text> (string)
					The text to display in the label.

				<colour> (int)
					The colour of the label.

				<range> (float)
					The stream range of the label.

			Returns:
				0
					If the button ID handle is invalid

				1
					If the label was created successfully.

				2
					If the label already existed and was updated successfully.
		}

		native DestroyButtonLabel(buttonid)
		{
			Description:
				Removes the label from a button.

			Parameters:
				<buttonid>
					The button ID handle to remove the label from.

			Returns:
				0
					If the button ID handle is invalid

				-1
					If the button does not have a label to remove.
		}
	}

	SIF/Button/Internal Functions
	{
		Internal events called by player actions done by using features from
		this script.
	
		Internal_OnButtonPress(playerid, buttonid)
		{
			Description:
				Called to handle linked button teleports, 
		}
	}

	SIF/Button/Hooks
	{
		Hooked functions or callbacks, either SA:MP natives or from other
		scripts or plugins.

		SAMP/OnPlayerKeyStateChange
		{
			Reason:
				To detect player key inputs to allow players to press the
				default F/Enter keys to operate buttons and call OnButtonPress
				or OnButtonRelease.
		}

		Streamer/OnPlayerEnterDynamicArea
		{
			Reason:
				To detect if a player enters a button's area and call
				OnPlayerEnterButtonArea.
		}

		Streamer/OnPlayerLeaveDynamicArea
		{
			Reason:
				To detect if a player leaves a button's area and call
				OnPlayerLeaveButtonArea.
		}
	}




==============================================================================*/


/*==============================================================================

	Setup

==============================================================================*/


#include <YSI\y_hooks>


#define MAX_BUTTON			(4096)
#define MAX_BUTTON_TEXT		(128)

#define INVALID_BUTTON_ID	(-1)


enum E_BTN_DATA
{
			btn_area,
Text3D:		btn_label,
Float:		btn_posX,
Float:		btn_posY,
Float:		btn_posZ,
			btn_world,
			btn_interior,
			btn_link,
			btn_text[MAX_BUTTON_TEXT],
			btn_attachVehicle,
Float:		btn_attachAngle,
Float:		btn_attachAngleRange,
}


static
			btn_Data[MAX_BUTTON][E_BTN_DATA],
Iterator:	btn_Index<MAX_BUTTON>,
			btn_Pressing[MAX_PLAYERS];


forward OnButtonPress(playerid, buttonid);
forward OnButtonRelease(playerid, buttonid);
forward OnPlayerEnterButtonArea(playerid, buttonid);
forward OnPlayerLeaveButtonArea(playerid, buttonid);


/*==============================================================================

	Zeroing

==============================================================================*/


#if defined FILTERSCRIPT
hook OnFilterScriptInit()
#else
hook OnGameModeInit()
#endif
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		btn_Pressing[i] = INVALID_BUTTON_ID;
	}
}

hook OnPlayerConnect(playerid)
{
	btn_Pressing[playerid] = INVALID_BUTTON_ID;
}


/*==============================================================================

	Core Functions

==============================================================================*/


stock CreateButton(Float:x, Float:y, Float:z, text[/*MAX_BUTTON_TEXT*/], world = 0, interior = 0, Float:areasize = 1.0, label = 0, labeltext[/*MAX_BUTTON_TEXT*/] = "", labelcolour = 0xFFFF00FF, Float:streamdist = 10.0)
{
	new id = Iter_Free(btn_Index);

	if(id == -1)
		return INVALID_BUTTON_ID;

	btn_Data[id][btn_area]				= CreateDynamicSphere(x, y, z, areasize, world, interior);

	btn_Data[id][btn_posX]				= x;
	btn_Data[id][btn_posY]				= y;
	btn_Data[id][btn_posZ]				= z;
//	btn_Data[id][btn_text]				= text;
	btn_Data[id][btn_text][0] = EOS;
	strcat(btn_Data[id][btn_text], text);
	btn_Data[id][btn_world]				= world;
	btn_Data[id][btn_interior]			= interior;
	btn_Data[id][btn_link]				= INVALID_BUTTON_ID;

	if(label)
		btn_Data[id][btn_label] = CreateDynamic3DTextLabel(labeltext, labelcolour, x, y, z, streamdist, _, _, 1, world, interior, _, streamdist);

	else
		btn_Data[id][btn_label] = Text3D:INVALID_3DTEXT_ID;

	Iter_Add(btn_Index, id);
	return id;
}
stock DestroyButton(buttonid)
{
	if(!Iter_Contains(btn_Index, buttonid))return 0;

	DestroyDynamicArea(btn_Data[buttonid][btn_area]);

	if(IsValidDynamic3DTextLabel(btn_Data[buttonid][btn_label]))
		DestroyDynamic3DTextLabel(btn_Data[buttonid][btn_label]);

	btn_Data[buttonid][btn_area]		= -1;
	btn_Data[buttonid][btn_label]		= Text3D:INVALID_3DTEXT_ID;

	btn_Data[buttonid][btn_posX]		= 0.0;
	btn_Data[buttonid][btn_posY]		= 0.0;
	btn_Data[buttonid][btn_posZ]		= 0.0;
	btn_Data[buttonid][btn_world]		= 0;
	btn_Data[buttonid][btn_interior]	= 0;
	btn_Data[buttonid][btn_link]		= INVALID_BUTTON_ID;
	btn_Data[buttonid][btn_text][0]		= EOS;

	foreach(new i : Player)
		if(IsPlayerViewingMsgBox(i))
			HideMsgBox(i);

	Iter_Remove(btn_Index, buttonid);
	return 1;
}

stock LinkTP(buttonid1, buttonid2)
{
	if(!Iter_Contains(btn_Index, buttonid1) || !Iter_Contains(btn_Index, buttonid2))
		return 0;

	btn_Data[buttonid1][btn_link] = buttonid2;
	btn_Data[buttonid2][btn_link] = buttonid1;

	return 1;
}
stock UnLinkTP(buttonid1, buttonid2)
{
	if(!Iter_Contains(btn_Index, buttonid1) || !Iter_Contains(btn_Index, buttonid2))
		return 0;

	if(btn_Data[buttonid1][btn_link] == INVALID_BUTTON_ID || btn_Data[buttonid1][btn_link] == INVALID_BUTTON_ID)
		return -1;

	if(btn_Data[buttonid1][btn_link] != buttonid2 || btn_Data[buttonid2][btn_link] != buttonid1)
		return -2;

	btn_Data[buttonid1][btn_link] = INVALID_BUTTON_ID;
	btn_Data[buttonid2][btn_link] = INVALID_BUTTON_ID;

	return 1;
}
stock AttachButtonToVehicle(buttonid, vehicleid, Float:angle, Float:range, Float:distance, Float:z = 0.0)
{
	if(!Iter_Contains(btn_Index, buttonid))
		return 0;

	if(!IsValidVehicle(vehicleid))
		return 0;

	AttachDynamicAreaToVehicle(btn_Data[buttonid][btn_area], vehicleid);
	Streamer_SetFloatData(STREAMER_TYPE_AREA, btn_Data[buttonid][btn_area], E_STREAMER_SIZE, distance + 2.0);

	if(IsValidDynamic3DTextLabel(btn_Data[buttonid][btn_label]))
	{
		Streamer_SetIntData(STREAMER_TYPE_3D_TEXT_LABEL, btn_Data[buttonid][btn_label], E_STREAMER_ATTACHED_VEHICLE, vehicleid);
		Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, btn_Data[buttonid][btn_label], E_STREAMER_X, distance * floatsin(angle, degrees));
		Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, btn_Data[buttonid][btn_label], E_STREAMER_Y, distance * floatcos(angle, degrees));
		Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, btn_Data[buttonid][btn_label], E_STREAMER_Z, z);
	}

	btn_Data[buttonid][btn_attachVehicle] = vehicleid;
	btn_Data[buttonid][btn_attachAngle] = angle;
	btn_Data[buttonid][btn_attachAngleRange] = range;

	return 1;
}
stock DetatchButtonFromVehicle(buttonid)
{
	if(!Iter_Contains(btn_Index, buttonid))
		return 0;

	if(!IsValidVehicle(btn_Data[buttonid][btn_attachVehicle]))
		return 0;

	Streamer_SetIntData(STREAMER_TYPE_AREA, btn_Data[buttonid][btn_area], E_STREAMER_ATTACHED_VEHICLE, INVALID_VEHICLE_ID);
	Streamer_SetFloatData(STREAMER_TYPE_AREA, btn_Data[buttonid][btn_area], E_STREAMER_X, btn_Data[buttonid][btn_posX]);
	Streamer_SetFloatData(STREAMER_TYPE_AREA, btn_Data[buttonid][btn_area], E_STREAMER_Y, btn_Data[buttonid][btn_posY]);
	Streamer_SetFloatData(STREAMER_TYPE_AREA, btn_Data[buttonid][btn_area], E_STREAMER_Z, btn_Data[buttonid][btn_posZ]);

	if(IsValidDynamic3DTextLabel(btn_Data[buttonid][btn_label]))
	{
		Streamer_SetIntData(STREAMER_TYPE_3D_TEXT_LABEL, btn_Data[buttonid][btn_label], E_STREAMER_ATTACHED_VEHICLE, INVALID_VEHICLE_ID);
		Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, btn_Data[buttonid][btn_label], E_STREAMER_X, btn_Data[buttonid][btn_posX]);
		Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, btn_Data[buttonid][btn_label], E_STREAMER_Y, btn_Data[buttonid][btn_posY]);
		Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, btn_Data[buttonid][btn_label], E_STREAMER_Z, btn_Data[buttonid][btn_posZ]);
	}

	btn_Data[buttonid][btn_attachVehicle] = INVALID_VEHICLE_ID;
	btn_Data[buttonid][btn_attachAngle] = 0.0;
	btn_Data[buttonid][btn_attachAngleRange] = 0.0;

	return 1;
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(!IsPlayerInAnyVehicle(playerid) && IsPlayerInAnyDynamicArea(playerid))
	{
		if(newkeys & 16)
		{
			foreach(new i : btn_Index)
			{
				if(IsPlayerInDynamicArea(playerid, btn_Data[i][btn_area]))
				{
					if(IsValidVehicle(btn_Data[i][btn_attachVehicle]))
					{
						new
							Float:px,
							Float:py,
							Float:pz,
							Float:vx,
							Float:vy,
							Float:vz,
							Float:vr,
							Float:angle;

						GetVehiclePos(btn_Data[i][btn_attachVehicle], vx, vy, vz);
						GetVehicleZAngle(btn_Data[i][btn_attachVehicle], vr);
						GetPlayerPos(playerid, px, py, pz);

						angle = -(90-(atan2((py - vy), (px - vx))));

						if(-btn_Data[i][btn_attachAngleRange] < (btn_Data[i][btn_attachAngle] - (vr-angle)) < btn_Data[i][btn_attachAngleRange])
						{
							SetPlayerPos(playerid, px, py, pz);
							SetPlayerFacingAngle(playerid, angle-180.0);
							ClearAnimations(playerid);
							Internal_OnButtonPress(playerid, i);
						}
					}
					else Internal_OnButtonPress(playerid, i);
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
	}
	return 1;
}

Internal_OnButtonPress(playerid, buttonid)
{
	printf("\n\nOnButtonPress <Root Script> buttonid: %d", buttonid);

	if(!Iter_Contains(btn_Index, buttonid))
		return 0;

	new id = btn_Data[buttonid][btn_link];
	
	if(Iter_Contains(btn_Index, id))
	{
		if(CallLocalFunction("OnButtonPress", "dd", playerid, buttonid))
			return 0;

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
		new
			Float:x,
			Float:y,
			Float:z,
			Float:a;

		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, a);

		SetPlayerPos(playerid, x, y, z);
		SetPlayerFacingAngle(playerid, a);

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
			ShowMsgBox(playerid, btn_Data[i][btn_text]);
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


/*==============================================================================

	Interface Functions

==============================================================================*/


stock IsValidButtonID(buttonid)
{
	if(!Iter_Contains(btn_Index, buttonid))
		return 0;

	return 1;
}

stock GetButtonPos(buttonid, &Float:x, &Float:y, &Float:z)
{
	if(!Iter_Contains(btn_Index, buttonid))
		return 0;

	x = btn_Data[buttonid][btn_posX];
	y = btn_Data[buttonid][btn_posY];
	z = btn_Data[buttonid][btn_posZ];

	return 1;
}

stock SetButtonPos(buttonid, Float:x, Float:y, Float:z)
{
	if(!Iter_Contains(btn_Index, buttonid))
		return 0;

	Streamer_SetFloatData(STREAMER_TYPE_AREA, btn_Data[buttonid][btn_area], E_STREAMER_X, x);
	Streamer_SetFloatData(STREAMER_TYPE_AREA, btn_Data[buttonid][btn_area], E_STREAMER_Y, y);
	Streamer_SetFloatData(STREAMER_TYPE_AREA, btn_Data[buttonid][btn_area], E_STREAMER_Z, z);

	if(IsValidDynamic3DTextLabel(btn_Data[buttonid][btn_label]))
	{
		Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, btn_Data[buttonid][btn_label], E_STREAMER_X, x);
		Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, btn_Data[buttonid][btn_label], E_STREAMER_Y, y);
		Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, btn_Data[buttonid][btn_label], E_STREAMER_Z, z);
	}

	btn_Data[buttonid][btn_posX] = x;
	btn_Data[buttonid][btn_posY] = y;
	btn_Data[buttonid][btn_posZ] = z;

	return 1;
}

stock GetPlayerButtonID(playerid)
{
	foreach(new i : btn_Index)
		if(IsPlayerInDynamicArea(playerid, btn_Data[i][btn_area]))return i;

	return INVALID_BUTTON_ID;
}

stock GetButtonLinkedID(buttonid)
{
	if(!Iter_Contains(btn_Index, buttonid))
		return INVALID_BUTTON_ID;

	return btn_Data[buttonid2][btn_link][buttonid];
}

stock SetButtonMessage(buttonid, msg[])
{
	if(!Iter_Contains(btn_Index, buttonid))
		return 0;

	btn_Data[buttonid][btn_text][0] = EOS;
	strcpy(btn_Data[buttonid][btn_text], msg);

	foreach(new i : Player)
		if(IsPlayerViewingMsgBox(i))
			ShowMsgBox(playerid, btn_Data[i][btn_text]);

	return 1;
}

stock SetButtonLabel(buttonid, text[], colour = 0xFFFF00FF, Float:range = 10.0)
{
	if(!Iter_Contains(btn_Index, buttonid))
		return 0;

	if(IsValidDynamic3DTextLabel(btn_Data[buttonid][btn_label]))
	{
		UpdateDynamic3DTextLabelText(btn_Data[buttonid][btn_label], colour, text);
		return 2;
	}

	btn_Data[buttonid][btn_label] = CreateDynamic3DTextLabel(text, colour,
		btn_Data[buttonid][btn_posX],
		btn_Data[buttonid][btn_posY],
		btn_Data[buttonid][btn_posZ],
		range, _, _, 1,
		btn_Data[buttonid][btn_world], btn_Data[buttonid][btn_interior], _, range);

	return 1;
}
stock DestroyButtonLabel(buttonid)
{
	if(!Iter_Contains(btn_Index, buttonid))
		return 0;

	if(!IsValidDynamic3DTextLabel(btn_Data[buttonid][btn_label]))
		return -1;

	DestroyDynamic3DTextLabel(btn_Data[buttonid][btn_label]);
	btn_Data[buttonid][btn_label] = INVALID_3DTEXT_ID;

	return 1;
}
