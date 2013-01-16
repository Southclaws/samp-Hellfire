#include <a_samp>
#include <zcmd>
#include <YSI\y_timers>


#define UI_CENTRE_X			(320.0)
#define UI_CENTRE_Y			(240.0)
#define UI_TILE_COUNT_X		(4)
#define UI_TILE_COUNT_Y		(1)
#define UI_ORIGIN_X			(UI_CENTRE_X - ((UI_TILE_COUNT_X / 2) * (UI_TILE_WIDTH_X + UI_TILE_SPACING_X)))
#define UI_ORIGIN_Y			(300) // (UI_CENTRE_Y - ((UI_TILE_COUNT_Y / 2) * (UI_TILE_WIDTH_Y + UI_TILE_SPACING_Y)))
#define UI_TILE_WIDTH_X		(50.0)
#define UI_TILE_WIDTH_Y		(50.0)
#define UI_TILE_SPACING_X	(10.0)
#define UI_TILE_SPACING_Y	(10.0)


public OnFilterScriptInit()
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i))
			continue;

		for(new j; j < MAX_PLAYER_TEXT_DRAWS; j++)
		{
			PlayerTextDrawDestroy(i, PlayerText:j);
		}

//		CreateTileGrid(i);

		CreateTile(i, 346, 		480.0, 130.0, 50.0, 50.0, 0xFFFFFF10, 0xFFFFFFFF, "M9");
		CreateTile(i, 335, 		420.0, 220.0, 50.0, 80.0, 0xFFFFFF10, 0xFFFFFFFF, "Knife");
		CreateTile(i, 1580, 	480.0, 220.0, 50.0, 80.0, 0xFFFFFF10, 0xFFFFFFFF, "Medkit");
		CreateTile(i, 18633, 	540.0, 220.0, 50.0, 80.0, 0xFFFFFF10, 0xFFFFFFFF, "Wrench");

		ShowPlayerDialog(i, 1000, DIALOG_STYLE_LIST, "list", "item\nitem\nitem\nitem", "close", "close");
		SelectTextDraw(i, 0xFFFF00FF);
	}
}

public OnFilterScriptExit()
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		for(new j; j < MAX_PLAYER_TEXT_DRAWS; j++)
		{
			PlayerTextDrawDestroy(i, PlayerText:j);
		}
	}
}

PlayerText:CreateTile(playerid, model, Float:x, Float:y, Float:width, Float:height, colour, overlaycolour, name[])
{
	new PlayerText:temp;

	temp							=CreatePlayerTextDraw(playerid, x, y, "");
	PlayerTextDrawFont				(playerid, temp, TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawBackgroundColor	(playerid, temp, colour);
	PlayerTextDrawColor				(playerid, temp, overlaycolour);
	PlayerTextDrawTextSize			(playerid, temp, width, height);


	PlayerTextDrawSetPreviewModel	(playerid, temp, model);
	PlayerTextDrawSetPreviewRot		(playerid, temp, -45.0, 0.0, 45.0, 1.0);

	PlayerTextDrawSetSelectable		(playerid, temp, true);

	PlayerTextDrawShow(playerid, temp);

	temp							=CreatePlayerTextDraw(playerid, x + width/2, y + height, name);
	PlayerTextDrawAlignment			(playerid, temp, 2);
	PlayerTextDrawBackgroundColor	(playerid, temp, 255);
	PlayerTextDrawFont				(playerid, temp, 2);
	PlayerTextDrawLetterSize		(playerid, temp, 0.2, 1.0);
	PlayerTextDrawColor				(playerid, temp, -1);
	PlayerTextDrawSetOutline		(playerid, temp, 1);
	PlayerTextDrawSetProportional	(playerid, temp, 1);
	PlayerTextDrawShow(playerid, temp);

	temp							=CreatePlayerTextDraw(playerid, x + width/2, y - 12, name);
	PlayerTextDrawAlignment			(playerid, temp, 2);
	PlayerTextDrawBackgroundColor	(playerid, temp, 255);
	PlayerTextDrawFont				(playerid, temp, 2);
	PlayerTextDrawLetterSize		(playerid, temp, 0.2, 1.0);
	PlayerTextDrawColor				(playerid, temp, -1);
	PlayerTextDrawSetOutline		(playerid, temp, 1);
	PlayerTextDrawSetProportional	(playerid, temp, 1);
	PlayerTextDrawTextSize			(playerid, temp, height, width - 4);
	PlayerTextDrawUseBox			(playerid, temp, true);
	PlayerTextDrawShow(playerid, temp);

	return temp;
}

CreateTileGrid(playerid)
{
	for(new i; i < UI_TILE_COUNT_X; i++)
	{
		for(new j; j < UI_TILE_COUNT_Y; j++)
		{
			printf("%f, %f", 
				UI_ORIGIN_X + ((UI_TILE_WIDTH_X + UI_TILE_SPACING_X) * i),
				UI_ORIGIN_Y + ((UI_TILE_WIDTH_Y + UI_TILE_SPACING_Y) * j) );

			CreateTile(playerid, 402,
				UI_ORIGIN_X + ((UI_TILE_WIDTH_X + UI_TILE_SPACING_X) * i),
				UI_ORIGIN_Y + ((UI_TILE_WIDTH_Y + UI_TILE_SPACING_Y) * j),
				UI_TILE_WIDTH_X,
				UI_TILE_WIDTH_Y,
				0xFFFFFF00,
				0xFFFFFFFF);
		}
	}
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	print("CLICKED");
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	printf("dialog %d item: %d texT: %s", dialogid, listitem, inputtext);
}
