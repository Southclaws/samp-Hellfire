//==============================================================================
#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS				(16)

#include <zcmd>
#include <YSI\y_timers>


//==============================================================================
#define MAX_TEXTDRAWS			(92)
#define MAX_PROJECTS			(100)
#define MAX_PROJECT_NAME		(32)
#define PROJECT_INDEX_FILE		"Textdraws/index.ini"
#define PROJECT_DATA_FILE		"Textdraws/%s.dat"
#define PROJECT_OUTPUT_FILE		"Textdraws/%s.txt"

#define Msg SendClientMessage


//==============================================================================
enum
{
	DIALOG_INDEX,
	DIALOG_NEW_PROJECT_NAME,
	DIALOG_LIST_EXISTING_PROJECTS,
	DIALOG_PROJECT_INDEX
}
enum
{
    PROJECT_ITEM_TEXT,
    PROJECT_ITEM_BOX,
    PROJECT_ITEM_SPRITE
}

enum E_PROJECT_DATA
{
Text:	td_Handle,
		td_Text[1024],
Float:	td_PosX,
Float:	td_PosY,

		td_Alignment,
		td_BackgroundColour,
		td_BoxColour,
		td_Colour,
		td_Font,

Float:	td_SizeX,
Float:	td_SizeY,

		td_Outline,
		td_Proportional,
		td_Shadow,

Float:	td_TextSizeX,
Float:	td_TextSizeY,

		td_Box
}


new
	gProjectList[MAX_PROJECTS][MAX_PROJECT_NAME],
	gText
	gTotalProjects;

new
	gEditorPlayerID,
	gCurrentProject;


//==============================================================================
public OnFilterScriptInit()
{
    gEditorPlayerID = -1;
    gCurrentProject = -1;
    
	new
		File:file,
		line[MAX_PROJECT_NAME],
		len,
		idx;

	if(!fexist(PROJECT_INDEX_FILE))
	{
		fopen(PROJECT_INDEX_FILE, io_write);
		return;
	}

	file = fopen(PROJECT_INDEX_FILE, io_read);
	
	while(fread(file, line))
	{
	    len = strlen(line);
		if(line[len-2] == '\r')line[len-2] = EOS;
		
		gProjectList[idx] = line;
		
		idx++;
	}
	
	gTotalProjects = idx;

	return;
}

public OnFilterScriptExit()
{
}


CMD:tde(playerid, params[])
{
	if(gEditorPlayerID == -1 || gEditorPlayerID == playerid)
	{
	    if(gCurrentProject != -1)
			ShowMenu(DIALOG_PROJECT_INDEX);

	    else
	    {
			gEditorPlayerID = playerid;
			ShowMenu(DIALOG_INDEX);
		}
	}
	else Msg(playerid, -1, "Error: Only one player can edit textdraws at a time");
	
	return 1;
}


ShowMenu(id)
{
	switch(id)
	{
		case DIALOG_INDEX:
		{
			ShowPlayerDialog(gEditorPlayerID, DIALOG_INDEX, DIALOG_STYLE_MSGBOX,
				"Textdraw Editor Main Menu",
				"Create a new textdraw project or load an existing one?",
				"New", "Load");
		}
		case DIALOG_NEW_PROJECT_NAME:
		{
			ShowPlayerDialog(gEditorPlayerID, DIALOG_NEW_PROJECT_NAME, DIALOG_STYLE_INPUT,
				"New Project",
				"Please enter the name of your new textdraw project:",
				"Accept", "Back");
		}
		case DIALOG_LIST_EXISTING_PROJECTS:
		{
		/*
			ShowPlayerDialog(gEditorPlayerID, DIALOG_NEW_PROJECT_NAME, DIALOG_STYLE_INPUT,
				"",
				"",
				"", "");
		*/
		}
		case DIALOG_PROJECT_INDEX:
		{
			ShowPlayerDialog(gEditorPlayerID, DIALOG_PROJECT_INDEX, DIALOG_STYLE_LIST,
				gProjectList[gCurrentProject],
				"Create Text\n\
				Create Box\n\
				Create Sprite\n\
				Delete Project\n\
				Export Project\n\
				Close Project",
				"Accept", "Back");
		}
	}
}


public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	    case DIALOG_INDEX:
	    {
	        if(response)	ShowMenu(DIALOG_NEW_PROJECT_NAME);
	        else			ShowMenu(DIALOG_LIST_EXISTING_PROJECTS);
	    }
	    case DIALOG_NEW_PROJECT_NAME:
	    {
	        CreateNewTextDrawProject(inputtext);
	        ShowMenu(DIALOG_PROJECT_INDEX);
	    }
		case DIALOG_PROJECT_INDEX:
		{
		    if(response)
		    {
		        switch(listitem)
		        {
					case 0:CreateNewProjectItem(PROJECT_ITEM_TEXT);
					case 1:CreateNewProjectItem(PROJECT_ITEM_BOX);
					case 2:CreateNewProjectItem(PROJECT_ITEM_SPRITE);
					case 4:ExportProject();
					case 5:CloseProject();
		        }
		    }
		    else
		    {
		    }
		}
	}
}

CreateNewTextDrawProject(name[])
{
	if(gTotalProjects >= MAX_PROJECTS-1)return 0;
	gTotalProjects++;

	strcat(gProjectList[gTotalProjects], name);
	gCurrentProject = gTotalProjects;

	return 1;
}

CreateNewProjectItem(type)
{
	switch(type)
	{
		case PROJECT_ITEM_TEXT:
		{
		}
		case PROJECT_ITEM_BOX:
		{
		}
		case PROJECT_ITEM_SPRITE:
		{
		}
	}
	gTotalTextdraws++;
}

ExportProject()
{
}

CloseProject()
{
	gTotalTextdraws = 0;
}
