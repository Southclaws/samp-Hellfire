#include <YSI\y_hooks>


new
	PlayerText:MsgBox,
	bool:gViewingMsgBox[MAX_PLAYERS],
	Timer:gPlayerMsgBoxTimer[MAX_PLAYERS];


ShowMsgBox(playerid, message[], time=0, width=200)
{
	PlayerTextDrawSetString(playerid, MsgBox, message);
	PlayerTextDrawTextSize(playerid, MsgBox, width, 300);
	PlayerTextDrawShow(playerid, MsgBox);
	if(time != 0)
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

stock bool:IsPlayerViewingMsgBox(playerid)
{
	if(!IsPlayerConnected(playerid))
		return false;

	return gViewingMsgBox[playerid];
}


hook OnPlayerConnect(playerid)
{
	MsgBox					=CreatePlayerTextDraw(playerid, 24.0, 180.0, "Test message Box");
	PlayerTextDrawUseBox	(playerid, MsgBox, 1);
	PlayerTextDrawBoxColor	(playerid, MsgBox, 0x00000055);
	PlayerTextDrawTextSize	(playerid, MsgBox, 150.0, 300.0);
	PlayerTextDrawFont		(playerid, MsgBox, 1);
	PlayerTextDrawLetterSize(playerid, MsgBox, 0.3, 1.4);
	PlayerTextDrawSetShadow	(playerid, MsgBox, 1);
}


hook OnPlayerDisconnect(playerid, reason)
{
	PlayerTextDrawDestroy(playerid, MsgBox);
}


