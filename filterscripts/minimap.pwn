#define FILTERSCRIPT

#include <a_samp>
#include <sscanf2>
#include <zcmd>
#include <colours>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16


new
	PlayerText:mapMain,
	PlayerText:mapText,
	mapShown[MAX_PLAYERS];

new
	Float:MAP_ORIGIN_X	= (460.0),
	Float:MAP_ORIGIN_Y	= (260.0),

	Float:MAP_SIZE_X	= (140.0),
	Float:MAP_SIZE_Y	= (140.0);

#define TXT_OFFSET_X	(-1.0)
#define TXT_OFFSET_Y	(-10.0)

#define MAP_BIT_NW "samaps:gtasamapbit1"
#define MAP_BIT_NE "samaps:gtasamapbit2"
#define MAP_BIT_SW "samaps:gtasamapbit3"
#define MAP_BIT_SE "samaps:gtasamapbit4"


CMD:map(playerid, params[])
{
	if(mapShown[playerid])
	{
	    mapShown[playerid] = false;
		UnloadTD(playerid);
	}
	else
	{
	    mapShown[playerid] = true;
		LoadTD(playerid);
	}
	return 1;
}
CMD:mappos(playerid, params[])
{
	sscanf(params, "ff", MAP_ORIGIN_X, MAP_ORIGIN_Y);
	return 1;
}
CMD:mapsize(playerid, params[])
{
	sscanf(params, "ff", MAP_SIZE_X, MAP_SIZE_Y);
	return 1;
}

public OnPlayerUpdate(playerid)
{
	if(mapShown[playerid])
	{
		new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid, x, y, z);

		LoadTD(playerid);
    	AddMapText(playerid, "~<~ You Are Here", x, y);
    }
}

AddMapText(playerid, text[], Float:x, Float:y)
{
	new
		mapBit[21],
		Float:mapX,
		Float:mapY;

	if(x > 0.0)
	{
		mapX = (x / 3000) * MAP_SIZE_X;
		if(y > 0.0)
		{
			mapY = (y / 3000) * MAP_SIZE_Y;
			mapBit = MAP_BIT_NE;
		}
		else
		{
			mapY = ((y+3000) / 3000) * MAP_SIZE_Y;
			mapBit = MAP_BIT_SE;
		}
	}
	else
	{
		mapX = ((x+3000) / 3000) * MAP_SIZE_X;
		if(y > 0.0)
		{
			mapY = (y / 3000) * MAP_SIZE_Y;
			mapBit = MAP_BIT_NW;
		}
		else
		{
			mapY = ((y+3000) / 3000) * MAP_SIZE_Y;
			mapBit = MAP_BIT_SW;
		}
	}

	UnloadTD(playerid);
	LoadTD(playerid);

	PlayerTextDrawSetString(playerid, mapMain, mapBit);

	mapY = MAP_SIZE_Y - mapY;

	mapText							=CreatePlayerTextDraw(playerid, MAP_ORIGIN_X+TXT_OFFSET_X+mapX, MAP_ORIGIN_Y+TXT_OFFSET_Y+mapY, text);
	PlayerTextDrawBackgroundColor	(playerid, mapText, 255);
	PlayerTextDrawFont				(playerid, mapText, 1);
	PlayerTextDrawLetterSize		(playerid, mapText, 0.400000, 1.799999);
	PlayerTextDrawColor				(playerid, mapText, -1);
	PlayerTextDrawSetOutline		(playerid, mapText, 1);
	PlayerTextDrawSetProportional	(playerid, mapText, 1);

	PlayerTextDrawShow(playerid, mapText);
}

LoadTD(playerid)
{
	mapMain							=CreatePlayerTextDraw(playerid, MAP_ORIGIN_X, MAP_ORIGIN_Y, "samaps:gtasamapbit1");
	PlayerTextDrawBackgroundColor	(playerid, mapMain, 255);
	PlayerTextDrawFont				(playerid, mapMain, 4);
	PlayerTextDrawLetterSize		(playerid, mapMain, 0.500000, 1.000000);
	PlayerTextDrawColor				(playerid, mapMain, -1);
	PlayerTextDrawSetOutline		(playerid, mapMain, 0);
	PlayerTextDrawSetProportional	(playerid, mapMain, 1);
	PlayerTextDrawSetShadow			(playerid, mapMain, 1);
	PlayerTextDrawUseBox			(playerid, mapMain, 1);
	PlayerTextDrawBoxColor			(playerid, mapMain, 255);
	PlayerTextDrawTextSize			(playerid, mapMain, MAP_SIZE_X, MAP_SIZE_Y);
	PlayerTextDrawShow				(playerid, mapMain);
}
UnloadTD(playerid)
{
	PlayerTextDrawDestroy(playerid, mapMain);
	PlayerTextDrawDestroy(playerid, mapText);
}

CMD:deltd(playerid, params[])
{
	for(new i;i<2048;i++)
	{
	    PlayerTextDrawHide(playerid, PlayerText:i);
	}
	return 1;
}
