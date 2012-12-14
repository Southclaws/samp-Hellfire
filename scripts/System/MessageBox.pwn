new
	PlayerText:MsgBox,
	bool:gViewingMsgBox[MAX_PLAYERS],
	Timer:gPlayerMsgBoxTimer[MAX_PLAYERS];

ShowMsgBox(playerid, message[], time=0, width=200)
{
	PlayerTextDrawSetString(playerid, MsgBox, message);
	PlayerTextDrawTextSize(playerid, MsgBox, width, 300);
	PlayerTextDrawShow(playerid, MsgBox);
	if(time!=0)
	{
	    stop gPlayerMsgBoxTimer[playerid];
		gPlayerMsgBoxTimer[playerid] = defer Internal_HideMsgBox(playerid, time);
	}
	gViewingMsgBox[playerid] = true;
}
timer Internal_HideMsgBox[time](playerid, time)
{
#pragma unused time
	HideMsgBox(playerid);
}
HideMsgBox(playerid)
{
	PlayerTextDrawHide(playerid, MsgBox);
	gViewingMsgBox[playerid] = false;
}

bool:IsPlayerViewingMsgBox(playerid)
{
	if(!IsPlayerConnected(playerid))
		return false;

	return gViewingMsgBox[playerid];
}

public OnPlayerConnect(playerid)
{
    MsgBox							=CreatePlayerTextDraw(playerid, 24.0, 180.0, "Test message Box");
	PlayerTextDrawUseBox			(playerid, MsgBox, 1);
	PlayerTextDrawBoxColor			(playerid, MsgBox, 0x00000055);
	PlayerTextDrawTextSize			(playerid, MsgBox, 150.0, 300.0);
	PlayerTextDrawFont				(playerid, MsgBox, 1);
	PlayerTextDrawLetterSize		(playerid, MsgBox, 0.3, 1.4);
	PlayerTextDrawSetShadow			(playerid, MsgBox, 1);

    return CallLocalFunction("msg_OnPlayerConnect", "d", playerid);
}
#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect msg_OnPlayerConnect
forward msg_OnPlayerConnect(playerid);


public OnPlayerDisconnect(playerid, reason)
{
	PlayerTextDrawDestroy(playerid, MsgBox);

    return CallLocalFunction("msg_OnPlayerDisconnect", "dd", playerid, reason);
}
#if defined _ALS_OnPlayerDisconnect
    #undef OnPlayerDisconnect
#else
    #define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect msg_OnPlayerDisconnect
forward msg_OnPlayerDisconnect(playerid, reason);


