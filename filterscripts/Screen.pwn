/*
 *	~Southclaw
 */
#include <a_samp>
#include <formatex>
#include <sscanf2>
#include <foreach>
#include <zcmd>
#include <streamer>

#define MAX_SCREEN			(8)
#define MAX_WIDTH			(64)
#define MAX_HEIGHT			(64)

#define MAX_IMAGE           (32)
#define MAX_IMAGE_NAME      (32)
#define IMAGE_INDEX			"Images/index.txt"
#define IMAGE_FILE          "Images/%s.dat"
#define GRID_SIZE			(8)
#define d_PaintImgList		2175

new
	Iterator:scr_Iterator<MAX_SCREEN>,
	scrObj[MAX_SCREEN][MAX_WIDTH][MAX_HEIGHT],
	Float:scr_Origin[MAX_SCREEN][3],
	scr_Size[MAX_SCREEN][2];

// From paint.pwn

enum E_IMAGE_DATA
{
	image_data[GRID_SIZE*GRID_SIZE],
	image_maker[MAX_PLAYER_NAME],
	image_name[MAX_IMAGE_NAME]
}

new
	TotalImages,
    gImageData[MAX_IMAGE][E_IMAGE_DATA];

public OnFilterScriptInit()
{
	LoadImages();
}
public OnFilterScriptExit()
{
	foreach(new i : scr_Iterator)
	{
	    i += DestroyScreen(i);
	}
}
new gID;
CMD:screen(playerid, params[])
{
    gID = CreateScreen(0.0, 10.0, 16.0, 8, 8);
    return 1;
}
CMD:bigscreen(playerid, params[])
{
    gID = CreateScreen(0.0, 10.0, 16.0, 16, 9);
    return 1;
}

CMD:setpix(playerid, params[])
{
	new x, y, c;
	if(sscanf(params, "ddx", x, y, c))return SendClientMessage(playerid, -1, "Usage: /setpix [x] [y] [colour]");

	SetScreenPixel(gID, x, y, c);

	return 1;
}
CMD:setbox(playerid, params[])
{
	new minx, miny, maxx, maxy, c;
	if(sscanf(params, "ddddx", minx, miny, maxx, maxy, c))return SendClientMessage(playerid, -1, "Usage: /setpix [min x] [min y] [max x] [max y] [colour]");

	DrawBox(gID, minx, miny, maxx, maxy, c);
	return 1;
}


CreateScreen(Float:x, Float:y, Float:z, width, height)
{
	new id = Iter_Free(scr_Iterator);

	for(new xLoop;xLoop<width;xLoop++)
	{
		for(new yLoop;yLoop<height;yLoop++)
		{
			scrObj[id][xLoop][yLoop] = CreateDynamicObject(18762, x+xLoop, y, z-yLoop, 90.0, 0.0, 0.0);
			SetDynamicObjectMaterial(scrObj[id][xLoop][yLoop], 0, 18646, "matcolours", "white", ARGBToHex(255, xLoop*64, yLoop*32, xLoop*64));
		}
	}
    scr_Origin[id][0] = x;
    scr_Origin[id][1] = y;
    scr_Origin[id][2] = z;
    scr_Size[id][0] = width;
    scr_Size[id][1] = height;

	Iter_Add(scr_Iterator, id);
	return id;
}
DestroyScreen(scrid)
{
	new next;

	for(new xLoop;xLoop<scr_Size[scrid][0];xLoop++)
		for(new yLoop;yLoop<scr_Size[scrid][0];yLoop++)DestroyDynamicObject(scrObj[scrid][xLoop][yLoop]);

    scr_Origin[scrid][0] = 0.0;
    scr_Origin[scrid][1] = 0.0;
    scr_Origin[scrid][2] = 0.0;

	Iter_SafeRemove(scr_Iterator, scrid, next);
	return next;
}

SetScreenPixel(scrid, x, y, colour)
{
	SetDynamicObjectMaterial(scrObj[scrid][x][y], 0, 18646, "matcolours", "white", colour);
}

stock DrawBox(scrid, minx, miny, maxx, maxy, colour)
{
	new
	    xLoop = minx,
	    yLoop = miny;

	while(xLoop <= maxx)
	{
	    while(yLoop <= maxy)
	    {
	        SetScreenPixel(scrid, xLoop, yLoop, colour);
	        yLoop++;
	    }
	    yLoop=miny;
	    xLoop++;
	}
}



// From paint.pwn

CMD:imagelist(playerid, params[])
{
	FormatImageList(playerid);
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
DrawImageFromData(scrid, idx, x, y)
{
	new
	    xLoop = x,
	    yLoop = y;

	for(new i;i<(GRID_SIZE*GRID_SIZE);i++)
	{
	    if(xLoop == GRID_SIZE)xLoop = 0;
	    if(i % GRID_SIZE == 0 && i!=0)yLoop++;

		SetScreenPixel(scrid, xLoop, yLoop, gImageData[idx][image_data][i] >>> 8 | gImageData[idx][image_data][i] << 24 );

	    xLoop++;
	}
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
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_PaintImgList)
	{
	    if(response)
	    {
			DrawImageFromData(gID, listitem, 0, 0);
	    }
	}
}

stock ARGBToHex(a, r, g, b)
{
	return (a<<24 | r<<16 | g<<8 | b);
}

