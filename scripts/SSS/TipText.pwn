#define KEYTEXT_INTERACT	"~k~~VEHICLE_ENTER_EXIT~"
#define KEYTEXT_PUT_AWAY	"~k~~CONVERSATION_YES~"
#define KEYTEXT_DROP_ITEM	"~k~~CONVERSATION_NO~"
#define KEYTEXT_INVENTORY	"~k~~GROUP_CONTROL_BWD~"
#define KEYTEXT_ENGINE		"~k~~CONVERSATION_YES~"
#define KEYTEXT_LIGHTS		"~k~~CONVERSATION_NO~"


new
	gToolTipText[MAX_PLAYERS][512];


// Help Tips (bottom of screen)


ShowHelpTip(playerid, text[], time = 0)
{
	PlayerTextDrawSetString(playerid, HelpTipText, text);
	PlayerTextDrawShow(playerid, HelpTipText);

	if(time > 0)
		defer HideHelpTip(playerid, time);
}

timer HideHelpTip[time](playerid, time)
{
	#pragma unused time
	PlayerTextDrawHide(playerid, HelpTipText);
}


// Tool Tips (top right)


ClearToolTipText(playerid)
{
	gToolTipText[playerid][0] = EOS;
}

AddToolTipText(playerid, key[], use[])
{
	new tmp[128];
	format(tmp, sizeof(tmp), "~y~%s ~w~%s~n~", key, use);
	strcat(gToolTipText[playerid], tmp);
}

ShowPlayerToolTip(playerid)
{
	PlayerTextDrawSetString(playerid, ToolTip, gToolTipText[playerid]);
	PlayerTextDrawShow(playerid, ToolTip);
}

HidePlayerToolTip(playerid)
{
	PlayerTextDrawHide(playerid, ToolTip);
}
