#include <a_samp>
#include <sscanf2>
#include <zcmd>

#define MAX_IMAGE           (32)
#define MAX_IMAGE_NAME      (32)
#define MAX_COLOUR          (13)
#define IMAGE_INDEX			"Images/index.txt"
#define IMAGE_FILE          "Images/%s.dat"
#define DOUBLE_CLICK_TICK   (500)
#define ORIGIN_X			(240.0)
#define ORIGIN_Y			(200.0)
#define GRID_SIZE			(8)
#define HOVER_COLOUR        (0xFFFFFFFF)

#define d_PaintColList		2174
#define d_PaintImgList		2175

#define strcpy(%0,%1)		strcat((%0[0] = '\0', %0), %1)


enum E_SWATCH_DATA
{
	swatch_colour,
	swatch_clicktick
}

enum E_COLOUR_ARRAY
{
	colour_name[32],
	colour_value
}

enum E_IMAGE_DATA
{
	image_data[GRID_SIZE*GRID_SIZE],
	image_maker[MAX_PLAYER_NAME],
	image_name[MAX_IMAGE_NAME]
}

new
	gGridData[MAX_PLAYERS][GRID_SIZE][GRID_SIZE],
	PlayerText:gPaintGrid[GRID_SIZE][GRID_SIZE],

    PlayerText:swatchBackGround,
	PlayerText:swatchColour1Txt,
	PlayerText:swatchColour2Txt,
	PlayerText:swatchColour1Box,
	PlayerText:swatchColour2Box,

	gCursorColour[MAX_PLAYERS] = 0xFFFFFFFF,
	selectedSwatch[MAX_PLAYERS],
	colourData[MAX_PLAYERS][2][E_SWATCH_DATA],
	colourArray[MAX_COLOUR][E_COLOUR_ARRAY]=
	{
		{"Red",			0xAA3333FF},
		{"Green",		0x33AA33FF},
		{"Blue",		0x0000BBFF},
		{"Yellow",		0xFFFF00FF},
		{"Orange",		0xFF9900FF},
		{"Lightblue",	0x33CCFFFF},
		{"Navy",		0x000080FF},
		{"Grey",		0xAFAFAFFF},
		{"Lime",		0x10F441FF},
		{"Magenta",		0xFF00FFFF},
		{"Aqua",		0xF0F8FFFF},
		{"White",		0xFFFFFFFF},
		{"Black",		0x000000FF}
	},
	
	ShowingImage[MAX_PLAYERS],
	TotalImages,
	gImageData[MAX_IMAGE][E_IMAGE_DATA];

new
	Float:xGap = 20.0,
	Float:yGap = 20.0,
	Float:xSize = 16.0,
	Float:ySize = 1.7;


public OnFilterScriptInit()
{
	if(!fexist(IMAGE_INDEX))fclose(fopen(IMAGE_INDEX, io_write));

    LoadImages();
	for(new p;p<MAX_PLAYERS;p++)
	{
	    if(IsPlayerConnected(p))
		{
			LoadPlayerTextDraws(p);
		}
	}
}
public OnFilterScriptExit()
{
	for(new p;p<MAX_PLAYERS;p++)
	{
	    if(IsPlayerConnected(p))
	    {
			DeletePixelGrid(p);
			DeletePlayerTextDraws(p);
		}
	}
}
public OnPlayerConnect(playerid)
{
    LoadPlayerTextDraws(playerid);
}
public OnPlayerDisconnect(playerid)
{
    DeletePlayerTextDraws(playerid);
}
public OnPlayerCommandText(playerid, cmdtext[])
{
	return 0;
}
CMD:paint(playerid, params[])
{
    EnterPaintMode(playerid);
	DrawPaintGrid(playerid);
	return 1;
}
CMD:paintoff(playerid, params[])
{
    ExitPaintMode(playerid);
    CancelSelectTextDraw(playerid);
	return 1;
}
CMD:saveimage(playerid, params[])
{
	if(strlen(params)<=1)return SendClientMessage(playerid, 0xFFFF00FF, "Usage: /saveimage [image name]");
	if(SavePlayerImage(playerid, params))SendClientMessage(playerid, 0xFFFF00FF, "Image saved!");
	else SendClientMessage(playerid, 0xFF0000FF, "Save Failed! Too many images.");
	return 1;
}
CMD:imagelist(playerid, params[])
{
	FormatImageList(playerid);
	return 1;
}
CMD:loadall(playerid, params[])
{
	LoadImages();
	return 1;
}

CMD:setboth(playerid, params[])
{
	sscanf(params, "f", xGap);
	yGap = xGap;
	DeletePixelGrid(playerid);
	DrawPaintGrid(playerid);
	return 1;
}
CMD:setx(playerid, params[])
{
	sscanf(params, "f", xGap);
	DeletePixelGrid(playerid);
	DrawPaintGrid(playerid);
	return 1;
}
CMD:sety(playerid, params[])
{
	sscanf(params, "f", yGap);
	DeletePixelGrid(playerid);
	DrawPaintGrid(playerid);
	return 1;
}
CMD:sizex(playerid, params[])
{
	sscanf(params, "f", xSize);
	DeletePixelGrid(playerid);
	DrawPaintGrid(playerid);
	return 1;
}
CMD:sizey(playerid, params[])
{
	sscanf(params, "f", ySize);
	DeletePixelGrid(playerid);
	DrawPaintGrid(playerid);
	return 1;
}

EnterPaintMode(playerid)
{
	colourData[playerid][0][swatch_colour] = 0xFFFFFFFF;
	colourData[playerid][1][swatch_colour] = 0x000000FF;

    SelectTextDraw(playerid, HOVER_COLOUR);
	ShowColourSwatch(playerid);
}
ExitPaintMode(playerid)
{
    DeletePixelGrid(playerid);
	HideColourSwatch(playerid);
}
SavePlayerImage(playerid, name[])
{
	if(TotalImages == MAX_IMAGE)return 0;

	new
	    File:idxFile = fopen(IMAGE_INDEX, io_append),
		File:imgFile,
		tmpFileDir[MAX_IMAGE_NAME + 5],
		data[(GRID_SIZE*GRID_SIZE) + MAX_PLAYER_NAME],
		pName[MAX_PLAYER_NAME],
		idxOffset,
		xLoop,
		yLoop = -1;

	GetPlayerName(playerid, pName, MAX_PLAYER_NAME);

	fwrite(idxFile, name);
	fwrite(idxFile, "\r\n");

	format(tmpFileDir, sizeof(tmpFileDir), IMAGE_FILE, name);

	imgFile = fopen(tmpFileDir, io_write);


	while(gImageData[idxOffset][image_name] != 0)idxOffset++;
	format(gImageData[idxOffset][image_name], MAX_IMAGE_NAME, name);
	gImageData[idxOffset][image_maker] = pName;


	for(new i;i<GRID_SIZE*GRID_SIZE;i++)
	{
	    if(xLoop == GRID_SIZE)xLoop = 0;
	    if(i % GRID_SIZE == 0)yLoop++;

	    data[i] = gGridData[playerid][xLoop][yLoop];
	    gImageData[idxOffset][image_data][i] = gGridData[playerid][xLoop][yLoop];

	    xLoop++;
	}
	for(new i;i<MAX_PLAYER_NAME;i++)
	{
	    data[i+(GRID_SIZE*GRID_SIZE)] = pName[i];
	}
	fblockwrite(imgFile, data);
	fclose(imgFile);
	fclose(idxFile);

    TotalImages++;
	return 1;
}
LoadImages()
{
	new
	    File:idxFile = fopen(IMAGE_INDEX, io_read),
		File:imgFile,
		tmpLine[MAX_IMAGE_NAME+2],
		tmpFileDir[MAX_IMAGE_NAME + 5],
		data[(GRID_SIZE*GRID_SIZE) + MAX_PLAYER_NAME];


	while(fread(idxFile, tmpLine))
	{
	    if(TotalImages == MAX_IMAGE)
		{
		    print("Image limit reached.");
			break;
		}

		tmpLine[strlen(tmpLine)-2] = EOS;
		format(tmpFileDir, sizeof(tmpFileDir), IMAGE_FILE, tmpLine);

		if(fexist(tmpFileDir))
		{
			format(gImageData[TotalImages][image_name], MAX_IMAGE_NAME, tmpLine);

			imgFile = fopen(tmpFileDir, io_read);
			fblockread(imgFile, data);
			for(new d;d<(GRID_SIZE*GRID_SIZE);d++)gImageData[TotalImages][image_data][d] = data[d];
			for(new d;d<MAX_PLAYER_NAME;d++)gImageData[TotalImages][image_maker][d] = data[d+(GRID_SIZE*GRID_SIZE)];
			TotalImages++;
			fclose(imgFile);
		}
	}
	fclose(idxFile);
	return 1;
}
DrawImageFromData(playerid, idx)
{
	new
		xLoop,
		yLoop;

	for(new i;i<(GRID_SIZE*GRID_SIZE);i++)
	{
	    if(xLoop == GRID_SIZE)xLoop = 0;
	    if(i % GRID_SIZE == 0 && i!=0)yLoop++;
	    if(ShowingImage[playerid])SetPixelColour(playerid, xLoop, yLoop, gImageData[idx][image_data][i]);
	    else DrawPixel(playerid, xLoop, yLoop, gImageData[idx][image_data][i]);
	    xLoop++;
	}
    ShowingImage[playerid] = true;
}
FormatImageList(playerid)
{
	new
		list[(MAX_IMAGE_NAME + 7 + MAX_PLAYER_NAME) * MAX_IMAGE],
		tmpStr[MAX_IMAGE_NAME + 7 + MAX_PLAYER_NAME];

	for(new i;i<TotalImages;i++)
	{
	    format(tmpStr, sizeof(tmpStr), "%s by %s\n", gImageData[i][image_name], gImageData[i][image_maker]);
	    strcat(list, tmpStr);
	}
	ShowPlayerDialog(playerid, d_PaintImgList, DIALOG_STYLE_LIST, "Player Image Library", list, "Accept", "Exit");
}

DrawPaintGrid(playerid)
{
	for(new x; x<GRID_SIZE; x++)
	{
	    for(new y; y<GRID_SIZE; y++)
	    {
	        DrawPixel(playerid, x, y, RGBAToHex(x*10+y*10, x*10+y*10, x*10+y*10, 255));
	    }
	}
	ShowingImage[playerid] = true;
}
DeletePixelGrid(playerid)
{
	for(new x; x<GRID_SIZE; x++)
	{
	    for(new y; y<GRID_SIZE; y++)
	    {
	        PlayerTextDrawDestroy(playerid, gPaintGrid[x][y]);
	    }
	}
	ShowingImage[playerid] = false;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	for(new x; x<8; x++)
	{
	    for(new y; y<8; y++)
	    {
	        if(playertextid == gPaintGrid[x][y])
	        {
	            SetPixelColour(playerid, x, y, gCursorColour[playerid]);
	        }
	    }
	}
	if(playertextid == swatchColour1Box)
	{
	    if((GetTickCount() - colourData[playerid][0][swatch_clicktick]) < DOUBLE_CLICK_TICK)
	    {
	        selectedSwatch[playerid] = 0;
	        FormatColourList(playerid);
	    }
	    else
	    {
	        gCursorColour[playerid] = colourData[playerid][0][swatch_colour];
	    }
		PlayerTextDrawColor(playerid, swatchColour1Txt, 0xFFFF00FF);
		PlayerTextDrawColor(playerid, swatchColour2Txt, 0xFFFFFFFF);
		ShowColourSwatch(playerid);
		colourData[playerid][0][swatch_clicktick] = GetTickCount();
	}
	if(playertextid == swatchColour2Box)
	{
	    if((GetTickCount() - colourData[playerid][1][swatch_clicktick]) < DOUBLE_CLICK_TICK)
	    {
	        selectedSwatch[playerid] = 1;
	        FormatColourList(playerid);
	    }
	    else
	    {
	        gCursorColour[playerid] = colourData[playerid][1][swatch_colour];
	    }
		PlayerTextDrawColor(playerid, swatchColour2Txt, 0xFFFF00FF);
		PlayerTextDrawColor(playerid, swatchColour1Txt, 0xFFFFFFFF);
		ShowColourSwatch(playerid);
		colourData[playerid][1][swatch_clicktick] = GetTickCount();
	}
}


DrawPixel(playerid, x, y, colour)
{
    gGridData[playerid][x][y] = colour;

	gPaintGrid[x][y]				=CreatePlayerTextDraw(playerid, ORIGIN_X+(x*xGap), ORIGIN_Y+(y*yGap), "_");
	PlayerTextDrawBackgroundColor	(playerid, gPaintGrid[x][y], 255);
	PlayerTextDrawFont				(playerid, gPaintGrid[x][y], 1);
	PlayerTextDrawLetterSize		(playerid, gPaintGrid[x][y], 0.6, ySize);
	PlayerTextDrawColor				(playerid, gPaintGrid[x][y], -1);
	PlayerTextDrawSetOutline		(playerid, gPaintGrid[x][y], 0);
	PlayerTextDrawSetProportional	(playerid, gPaintGrid[x][y], 1);
	PlayerTextDrawSetShadow			(playerid, gPaintGrid[x][y], 1);
	PlayerTextDrawUseBox			(playerid, gPaintGrid[x][y], 1);
	PlayerTextDrawBoxColor			(playerid, gPaintGrid[x][y], colour);
	PlayerTextDrawTextSize			(playerid, gPaintGrid[x][y], ORIGIN_X+(x*xGap)+xSize, 20.000000);
	PlayerTextDrawSetSelectable     (playerid, gPaintGrid[x][y], true);
	PlayerTextDrawShow				(playerid, gPaintGrid[x][y]);
}
DeletePixel(playerid, x, y)
{
    PlayerTextDrawDestroy(playerid, gPaintGrid[x][y]);
}
SetPixelColour(playerid, x, y, colour)
{
    DeletePixel(playerid, x, y);
    DrawPixel(playerid, x, y, colour);
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_PaintColList)
	{
	    if(response)
	    {
	        colourData[playerid][selectedSwatch[playerid]][swatch_colour] = colourArray[listitem][colour_value];
	        gCursorColour[playerid] = colourArray[listitem][colour_value];
	        SetSwatchBoxColour(playerid, selectedSwatch[playerid], colourArray[listitem][colour_value]);
	        SelectTextDraw(playerid, HOVER_COLOUR);
	    }
	    else SelectTextDraw(playerid, HOVER_COLOUR);
	}
	if(dialogid == d_PaintImgList)
	{
	    if(response)
	    {
	        if(ShowingImage[playerid])DeletePixelGrid(playerid);
			DrawImageFromData(playerid, listitem);
			EnterPaintMode(playerid);
	    }
	}
}

FormatColourList(playerid)
{
	new list[128];
	for(new i;i<MAX_COLOUR;i++)
	{
	    strcat(list, colourArray[i][colour_name]);
	    strcat(list, "\n");
	}
	ShowPlayerDialog(playerid, d_PaintColList, DIALOG_STYLE_LIST, "Choose a colour", list, "Accept", "Back");
}

SetSwatchBoxColour(playerid, swatch, colour)
{
	if(swatch == 0)PlayerTextDrawBoxColor(playerid, swatchColour1Box, colour);
	if(swatch == 1)PlayerTextDrawBoxColor(playerid, swatchColour2Box, colour);
    ShowColourSwatch(playerid);
}

stock RGBAToHex(r, g, b, a)
{
	return (r<<24 | g<<16 | b<<8 | a);
}


LoadPlayerTextDraws(playerid)
{
	swatchBackGround				=CreatePlayerTextDraw(playerid, 478.000000, 167.000000, "~n~~n~~n~");
	PlayerTextDrawBackgroundColor	(playerid, swatchBackGround, 255);
	PlayerTextDrawFont				(playerid, swatchBackGround, 1);
	PlayerTextDrawLetterSize		(playerid, swatchBackGround, 0.509999, 6.400000);
	PlayerTextDrawColor				(playerid, swatchBackGround, -1);
	PlayerTextDrawSetOutline		(playerid, swatchBackGround, 0);
	PlayerTextDrawSetProportional	(playerid, swatchBackGround, 1);
	PlayerTextDrawSetShadow			(playerid, swatchBackGround, 1);
	PlayerTextDrawUseBox			(playerid, swatchBackGround, 1);
	PlayerTextDrawBoxColor			(playerid, swatchBackGround, 255);
	PlayerTextDrawTextSize			(playerid, swatchBackGround, 592.000000, 10.000000);

	swatchColour1Txt				=CreatePlayerTextDraw(playerid, 535.000000, 170.000000, "Colour 1");
	PlayerTextDrawAlignment			(playerid, swatchColour1Txt, 2);
	PlayerTextDrawBackgroundColor	(playerid, swatchColour1Txt, 255);
	PlayerTextDrawFont				(playerid, swatchColour1Txt, 1);
	PlayerTextDrawLetterSize		(playerid, swatchColour1Txt, 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, swatchColour1Txt, 0xFFFF00FF);
	PlayerTextDrawSetOutline		(playerid, swatchColour1Txt, 1);
	PlayerTextDrawSetProportional	(playerid, swatchColour1Txt, 1);
	PlayerTextDrawSetShadow			(playerid, swatchColour1Txt, 1);
	PlayerTextDrawUseBox			(playerid, swatchColour1Txt, 1);
	PlayerTextDrawBoxColor			(playerid, swatchColour1Txt, 65535);
	PlayerTextDrawTextSize			(playerid, swatchColour1Txt, 590.000000, 110.000000);

	swatchColour2Txt				=CreatePlayerTextDraw(playerid, 535.000000, 258.000000, "Colour 2");
	PlayerTextDrawAlignment			(playerid, swatchColour2Txt, 2);
	PlayerTextDrawBackgroundColor	(playerid, swatchColour2Txt, 255);
	PlayerTextDrawFont				(playerid, swatchColour2Txt, 1);
	PlayerTextDrawLetterSize		(playerid, swatchColour2Txt, 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, swatchColour2Txt, -1);
	PlayerTextDrawSetOutline		(playerid, swatchColour2Txt, 1);
	PlayerTextDrawSetProportional	(playerid, swatchColour2Txt, 1);
	PlayerTextDrawSetShadow			(playerid, swatchColour2Txt, 1);
	PlayerTextDrawUseBox			(playerid, swatchColour2Txt, 1);
	PlayerTextDrawBoxColor			(playerid, swatchColour2Txt, 65535);
	PlayerTextDrawTextSize			(playerid, swatchColour2Txt, 590.000000, 110.000000);

	swatchColour1Box				=CreatePlayerTextDraw(playerid, 535.000000, 196.000000, "~n~~n~~n~");
	PlayerTextDrawAlignment			(playerid, swatchColour1Box, 2);
	PlayerTextDrawBackgroundColor	(playerid, swatchColour1Box, 255);
	PlayerTextDrawFont				(playerid, swatchColour1Box, 1);
	PlayerTextDrawLetterSize		(playerid, swatchColour1Box, 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, swatchColour1Box, -1);
	PlayerTextDrawSetOutline		(playerid, swatchColour1Box, 0);
	PlayerTextDrawSetProportional	(playerid, swatchColour1Box, 1);
	PlayerTextDrawSetShadow			(playerid, swatchColour1Box, 1);
	PlayerTextDrawUseBox			(playerid, swatchColour1Box, 1);
	PlayerTextDrawBoxColor			(playerid, swatchColour1Box, 0xFFFFFFFF);
	PlayerTextDrawTextSize			(playerid, swatchColour1Box, 590.000000, 110.000000);
	PlayerTextDrawSetSelectable     (playerid, swatchColour1Box, true);

	swatchColour2Box				=CreatePlayerTextDraw(playerid, 535.000000, 284.000000, "~n~~n~~n~");
	PlayerTextDrawAlignment			(playerid, swatchColour2Box, 2);
	PlayerTextDrawBackgroundColor	(playerid, swatchColour2Box, 255);
	PlayerTextDrawFont				(playerid, swatchColour2Box, 1);
	PlayerTextDrawLetterSize		(playerid, swatchColour2Box, 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, swatchColour2Box, -1);
	PlayerTextDrawSetOutline		(playerid, swatchColour2Box, 0);
	PlayerTextDrawSetProportional	(playerid, swatchColour2Box, 1);
	PlayerTextDrawSetShadow			(playerid, swatchColour2Box, 1);
	PlayerTextDrawUseBox			(playerid, swatchColour2Box, 1);
	PlayerTextDrawBoxColor			(playerid, swatchColour2Box, 0x000000FF);
	PlayerTextDrawTextSize			(playerid, swatchColour2Box, 590.000000, 110.000000);
	PlayerTextDrawSetSelectable     (playerid, swatchColour2Box, true);
}
ShowColourSwatch(playerid)
{
	PlayerTextDrawShow(playerid, swatchBackGround);
	PlayerTextDrawShow(playerid, swatchColour1Txt);
	PlayerTextDrawShow(playerid, swatchColour2Txt);
	PlayerTextDrawShow(playerid, swatchColour1Box);
	PlayerTextDrawShow(playerid, swatchColour2Box);
}
HideColourSwatch(playerid)
{
	PlayerTextDrawHide(playerid, swatchBackGround);
	PlayerTextDrawHide(playerid, swatchColour1Txt);
	PlayerTextDrawHide(playerid, swatchColour2Txt);
	PlayerTextDrawHide(playerid, swatchColour1Box);
	PlayerTextDrawHide(playerid, swatchColour2Box);
}

DeletePlayerTextDraws(playerid)
{
	PlayerTextDrawDestroy(playerid, swatchBackGround);
	PlayerTextDrawDestroy(playerid, swatchColour1Txt);
	PlayerTextDrawDestroy(playerid, swatchColour2Txt);
	PlayerTextDrawDestroy(playerid, swatchColour1Box);
	PlayerTextDrawDestroy(playerid, swatchColour2Box);
}
