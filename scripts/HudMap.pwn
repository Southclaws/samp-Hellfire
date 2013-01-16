#include <YSI\y_hooks>

new
	PlayerText:mapMain,
	PlayerText:mapText;


#define MAP_ORIGIN_X	(200.0)
#define MAP_ORIGIN_Y	(140.0)

#define MAP_SIZE_X		(260.0)
#define MAP_SIZE_Y		(260.0)

#define TXT_OFFSET_X	(-1.0)
#define TXT_OFFSET_Y	(-10.0)

#define MAP_BIT_NW "samaps:gtasamapbit1"
#define MAP_BIT_NE "samaps:gtasamapbit2"
#define MAP_BIT_SW "samaps:gtasamapbit3"
#define MAP_BIT_SE "samaps:gtasamapbit4"


ShowMapForPlayer(playerid, text[], Float:x, Float:y)
{
	new
		mapbit[21],
		Float:mapX,
		Float:mapY;

	if(x > 0.0)
	{
		mapX = (x / 3000) * MAP_SIZE_X;
		if(y > 0.0)
		{
			mapY = (y / 3000) * MAP_SIZE_Y;
			mapbit = MAP_BIT_NE;
		}
		else
		{
			mapY = ((y+3000) / 3000) * MAP_SIZE_Y;
			mapbit = MAP_BIT_SE;
		}
	}
	else
	{
		mapX = ((x+3000) / 3000) * MAP_SIZE_X;
		if(y > 0.0)
		{
			mapY = (y / 3000) * MAP_SIZE_Y;
			mapbit = MAP_BIT_NW;
		}
		else
		{
			mapY = ((y+3000) / 3000) * MAP_SIZE_Y;
			mapbit = MAP_BIT_SW;
		}
	}
	PlayerTextDrawSetString(playerid, mapMain, mapbit);

    if(bPlayerGameSettings[playerid] & ViewingMap)PlayerTextDrawDestroy(playerid, mapText);

	mapY = MAP_SIZE_Y - mapY;

	mapText							=CreatePlayerTextDraw(playerid, MAP_ORIGIN_X+TXT_OFFSET_X+mapX, MAP_ORIGIN_Y+TXT_OFFSET_Y+mapY, text);
	PlayerTextDrawBackgroundColor	(playerid, mapText, 255);
	PlayerTextDrawTextSize			(playerid, mapText, MAP_ORIGIN_X+TXT_OFFSET_X+mapX+(strlen(text)*6), 16.0);
	PlayerTextDrawFont				(playerid, mapText, 1);
	PlayerTextDrawLetterSize		(playerid, mapText, 0.400000, 1.799999);
	PlayerTextDrawColor				(playerid, mapText, -1);
	PlayerTextDrawSetOutline		(playerid, mapText, 1);
	PlayerTextDrawSetProportional	(playerid, mapText, 1);
	PlayerTextDrawSetSelectable		(playerid, mapText, 1);

	PlayerTextDrawShow				(playerid, mapMain);
	PlayerTextDrawShow				(playerid, mapText);

	t:bPlayerGameSettings[playerid]<ViewingMap>;
}
HideMapForPlayer(playerid)
{
	PlayerTextDrawHide(playerid, mapMain);
	PlayerTextDrawHide(playerid, mapText);
	PlayerTextDrawDestroy(playerid, mapText);
	f:bPlayerGameSettings[playerid]<ViewingMap>;
}

hook OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(playertextid == mapText)
	{
		if(bPlayerGameSettings[playerid] & InRace)
		{
		    MsgF(playerid, YELLOW, " >  Race Finish: "#C_BLUE"%s", rc_FinishLocName[rc_Data[rc_CurrentRace][rc_FinishLocationID]]);
		}
	}
}
