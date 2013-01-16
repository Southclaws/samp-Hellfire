#include <YSI\y_hooks>


#if !defined NOTEBOOK_FILE
	#define NOTEBOOK_FILE		"Notebook/%s.dat"
#endif

#if !defined MAX_PAGES
	#define MAX_PAGES			(8)
#endif

#if !defined MAX_NOTE_TEXT
	#define MAX_NOTE_TEXT		128
#endif

#if !defined MAX_FILE_NAME
	#define MAX_FILE_NAME		(MAX_PLAYER_NAME + 14)
#endif

#define INVALID_NOTEBOOK_PAGE	(-1)


new
		nbk_Data[MAX_PLAYERS][MAX_PAGES][MAX_NOTE_TEXT],
		nbk_CurrentPage[MAX_PLAYERS],
		nbk_InventoryItem[MAX_PLAYERS],
Text:	nbk_PageLeft,
Text:	nbk_PageRight;


ShowPlayerNotebook(playerid, page)
{
	if(!(0 <= page < MAX_PAGES))
		return 0;

	new
		pagetitle[8];

	format(pagetitle, 8, "Page %d", page+1);

	if(isnull(nbk_Data[playerid][page]))
		ShowPlayerDialog(playerid, d_NotebookPage, DIALOG_STYLE_MSGBOX, pagetitle, "(This page is empty)", "Close", "Edit");

	else
		ShowPlayerDialog(playerid, d_NotebookPage, DIALOG_STYLE_MSGBOX, pagetitle, nbk_Data[playerid][page], "Close", "Edit");

	TextDrawShowForPlayer(playerid, nbk_PageLeft);
	TextDrawShowForPlayer(playerid, nbk_PageRight);

	nbk_CurrentPage[playerid] = page;

	return 1;
}

HidePlayerNotebook(playerid)
{
	TextDrawHideForPlayer(playerid, nbk_PageLeft);
	TextDrawHideForPlayer(playerid, nbk_PageRight);

	nbk_CurrentPage[playerid] = INVALID_NOTEBOOK_PAGE;
}

EditNotebookPage(playerid)
{
	if(nbk_CurrentPage[playerid] == INVALID_NOTEBOOK_PAGE)
		return 0;

	new
		pagetitle[13];

	format(pagetitle, 13, "Edit Page %d", nbk_CurrentPage[playerid]+1);

	if(isnull(nbk_Data[playerid][nbk_CurrentPage[playerid]]))
		ShowPlayerDialog(playerid, d_NotebookEdit, DIALOG_STYLE_INPUT, pagetitle, "(This page is empty)", "Accept", "Cancel");

	else
		ShowPlayerDialog(playerid, d_NotebookEdit, DIALOG_STYLE_INPUT, pagetitle, nbk_Data[playerid][nbk_CurrentPage[playerid]], "Accept", "Cancel");

	TextDrawHideForPlayer(playerid, nbk_PageLeft);
	TextDrawHideForPlayer(playerid, nbk_PageRight);

	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_NotebookPage)
	{
		if(response)
		{
			HidePlayerNotebook(playerid);
			DisplayPlayerInventory(playerid);
		}
		else
		{
			EditNotebookPage(playerid);
		}
	}
	if(dialogid == d_NotebookEdit)
	{
		if(response)
		{
			if(strlen(inputtext) >= MAX_NOTE_TEXT)
			{
				ShowPlayerDialog(playerid, d_NotebookError, DIALOG_STYLE_MSGBOX, "Error", "You exceeded the character limit of "#MAX_NOTE_TEXT" characters.", "Back", "");
				return 1;
			}

			nbk_Data[playerid][nbk_CurrentPage[playerid]][0] = EOS;
			strcat(nbk_Data[playerid][nbk_CurrentPage[playerid]], inputtext);
			ShowPlayerNotebook(playerid, nbk_CurrentPage[playerid]);
		}
		else
		{
			ShowPlayerNotebook(playerid, nbk_CurrentPage[playerid]);
		}
	}
	if(dialogid == d_NotebookError)
	{
		EditNotebookPage(playerid);
	}

	return 1;
}

hook OnPlayerConnect(playerid)
{
	new
		File:file,
		filename[MAX_FILE_NAME],
		name[MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	format(filename, MAX_FILE_NAME, NOTEBOOK_FILE, name);

	if(!fexist(filename))
		return 0;

	file = fopen(filename, io_read);

	for(new i; i < MAX_PAGES; i++)
	{
		fblockread(file, nbk_Data[playerid][i], MAX_NOTE_TEXT);
	}

	fclose(file);

	return 1;
}

hook OnPlayerDisconnect(playerid)
{
	new
		File:file,
		filename[MAX_FILE_NAME],
		name[MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	format(filename, MAX_FILE_NAME, NOTEBOOK_FILE, name);

	file = fopen(filename, io_write);

	for(new i; i < MAX_PAGES; i++)
	{
		fblockwrite(file, nbk_Data[playerid][i], MAX_NOTE_TEXT);
	}

	fclose(file);
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == nbk_PageLeft)
	{
		nbk_CurrentPage[playerid]--;

		if(nbk_CurrentPage[playerid] < 0)
			nbk_CurrentPage[playerid] = MAX_PAGES - 1;

		ShowPlayerNotebook(playerid, nbk_CurrentPage[playerid]);
	}
	if(clickedid == nbk_PageRight)
	{
		nbk_CurrentPage[playerid]++;

		if(nbk_CurrentPage[playerid] >= MAX_PAGES)
			nbk_CurrentPage[playerid] = 0;

		ShowPlayerNotebook(playerid, nbk_CurrentPage[playerid]);
	}
}

public OnPlayerOpenInventory(playerid)
{
	nbk_InventoryItem[playerid] = AddInventoryListItem(playerid, "Notebook");

	return CallLocalFunction("nbk_OnPlayerOpenInventory", "d", playerid);
}
#if defined _ALS_OnPlayerOpenInventory
	#undef OnPlayerOpenInventory
#else
	#define _ALS_OnPlayerOpenInventory
#endif
#define OnPlayerOpenInventory nbk_OnPlayerOpenInventory
forward OnPlayerOpenInventory(playerid);

public OnPlayerSelectExtraItem(playerid, item)
{
	if(item == nbk_InventoryItem[playerid])
	{
		ShowPlayerNotebook(playerid, 0);
	}

	return CallLocalFunction("nbk_OnPlayerSelectExtraItem", "dd", playerid, item);
}
#if defined _ALS_OnPlayerSelectExtraItem
	#undef OnPlayerSelectExtraItem
#else
	#define _ALS_OnPlayerSelectExtraItem
#endif
#define OnPlayerSelectExtraItem nbk_OnPlayerSelectExtraItem
forward OnPlayerSelectExtraItem(playerid, item);

hook OnGameModeInit()
{
	nbk_PageLeft				=TextDrawCreate(280.000000, 320.000000, "<");
	TextDrawAlignment			(nbk_PageLeft, 2);
	TextDrawBackgroundColor		(nbk_PageLeft, 255);
	TextDrawFont				(nbk_PageLeft, 1);
	TextDrawLetterSize			(nbk_PageLeft, 0.500000, 2.000000);
	TextDrawColor				(nbk_PageLeft, -1);
	TextDrawSetOutline			(nbk_PageLeft, 0);
	TextDrawSetProportional		(nbk_PageLeft, 1);
	TextDrawSetShadow			(nbk_PageLeft, 1);
	TextDrawUseBox				(nbk_PageLeft, 1);
	TextDrawBoxColor			(nbk_PageLeft, 128);
	TextDrawTextSize			(nbk_PageLeft, 25.000000, 75.000000);
	TextDrawSetSelectable		(nbk_PageLeft, true);

	nbk_PageRight				=TextDrawCreate(360.000000, 320.000000, ">");
	TextDrawAlignment			(nbk_PageRight, 2);
	TextDrawBackgroundColor		(nbk_PageRight, 255);
	TextDrawFont				(nbk_PageRight, 1);
	TextDrawLetterSize			(nbk_PageRight, 0.500000, 2.000000);
	TextDrawColor				(nbk_PageRight, -1);
	TextDrawSetOutline			(nbk_PageRight, 0);
	TextDrawSetProportional		(nbk_PageRight, 1);
	TextDrawSetShadow			(nbk_PageRight, 1);
	TextDrawUseBox				(nbk_PageRight, 1);
	TextDrawBoxColor			(nbk_PageRight, 128);
	TextDrawTextSize			(nbk_PageRight, 25.000000, 75.000000);
	TextDrawSetSelectable		(nbk_PageRight, true);
}

hook OnGameModeExit()
{
	TextDrawDestroy(nbk_PageLeft);
	TextDrawDestroy(nbk_PageRight);
}
