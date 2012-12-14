/**
 *  Progress Bar Creator
 *  Copyright 2007-2010 Infernus' Group,
 *  Flávio Toribio (flavio_toibio@hotmail.com)
 *
 *  This is an add-on for the include Progress Bar
 *  http://forum.sa-mp.com/index.php?topic=138556
 */

#include <a_samp>
#include <bar>

#if !defined SetPVarInt
    #error Version 0.3 R7 or higher of SA:MP Server requiered
#endif

#if _progress_version < 0x1310
    #error Version 1.3.1 or higher of progress.inc required
#endif

#define DIALOG_BAR      1834
#define DIALOG_COLOR    1835
#define DIALOG_DONE     1836

#define ITEM_MOVE       0
#define ITEM_RESIZE     1
#define ITEM_COLOR      2
#define ITEM_DONE       3

#define MOVE_NONE       0
#define MOVE_POSITION   1
#define MOVE_SIZE       2

static Bars[MAX_BARS][e_bar];

public OnFilterScriptInit()
{
    for(new i = 0; i < MAX_PLAYERS; ++i) if(IsPlayerConnected(i))
    {
        OnPlayerSpawn(i);
    }
    print("Progress Bar Creator by Flavio Toribio loaded");
    return 1;
}

public OnFilterScriptExit()
{
    for(new i = 0; i < MAX_PLAYERS; ++i) if(IsPlayerConnected(i))
    {
        OnPlayerDisconnect(i, 0);
        if(GetPVarInt(i, "MovingBar"))
        {
            TogglePlayerControllable(i, true);
        }
        if(GetPVarInt(i, "CreatingBar"))
        {
            DeletePVar(i, "BarID");
            DeletePVar(i, "MovingBar");
            DeletePVar(i, "CreatingBar");
        }
    }
    print("Progress Bar Creator by Flavio Toribio unloaded");
    return 1;
}

public OnPlayerSpawn(playerid)
{
    SendClientMessage(playerid, 0xFFF000AA, "Use /bar to start making a progress bar!");
    return 1;
}

GetVars(index, &Float:x, &Float:y, &Float:w, &Float:h, &color)
{
    x = Bars[index][pb_x];
    y = Bars[index][pb_y];
    w = Bars[index][pb_w];
    h = Bars[index][pb_h];
    color = Bars[index][pb_color];
}

UpdateVars(index, Float:x, Float:y, Float:w, Float:h, color)
{
    Bars[index][pb_x] = x;
    Bars[index][pb_y] = y;
    Bars[index][pb_w] = w;
    Bars[index][pb_h] = h;
    Bars[index][pb_color] = color;
}

DeleteVars(index)
{
    Bars[index][pb_x] = 0.0;
    Bars[index][pb_y] = 0.0;
    Bars[index][pb_w] = 0.0;
    Bars[index][pb_h] = 0.0;
    Bars[index][pb_color] = 0;
}

public OnPlayerUpdate(playerid)
{
    if(GetPVarInt(playerid, "MovingBar"))
    {
        new keys, ud, lr;
        GetPlayerKeys(playerid, keys, ud, lr);

        new Bar:barid = Bar:GetPVarInt(playerid, "BarID");
        new Float:x, Float:y, Float:w, Float:h, color;

        if(ud || lr)
        {
            DestroyProgressBar(barid);
            GetVars(_:barid, x, y, w, h, color);
            DeleteVars(_:barid);
            if(ud == KEY_UP)
            {
                if(GetPVarInt(playerid, "MovingBar") == MOVE_POSITION)
                {
                    y -= keys & KEY_SPRINT ? 2.0 : 1.0;
                    if(y < 0.0) y = 0.0;
                }
                else if(GetPVarInt(playerid, "MovingBar") == MOVE_SIZE)
                {
                    h -= keys & KEY_SPRINT ? 2.0 : 1.0;
                    if(h < 1.5) h = 1.5;
                }
            }
            else if(ud == KEY_DOWN)
            {
                if(GetPVarInt(playerid, "MovingBar") == MOVE_POSITION)
                {
                    y += keys & KEY_SPRINT ? 2.0 : 1.0;
                    if(y > 480.0) y = 480.0;
                }
                else if(GetPVarInt(playerid, "MovingBar") == MOVE_SIZE)
                {
                    h += keys & KEY_SPRINT ? 2.0 : 1.0;
                    if(h > 480.0) h = 480.0;
                }
            }
            if(lr == KEY_LEFT)
            {
                if(GetPVarInt(playerid, "MovingBar") == MOVE_POSITION)
                {
                    x -= keys & KEY_SPRINT ? 2.0 : 1.0;
                    if(x < 0.0) x = 0.0;
                }
                else if(GetPVarInt(playerid, "MovingBar") == MOVE_SIZE)
                {
                    w -= keys & KEY_SPRINT ? 2.0 : 1.0;
                    if(w < 1.5) w = 1.5;
                }
            }
            else if(lr == KEY_RIGHT)
            {
                if(GetPVarInt(playerid, "MovingBar") == MOVE_POSITION)
                {
                    x += keys & KEY_SPRINT ? 2.0 : 1.0;
                    if(x > 640.0) x = 640.0;
                }
                else if(GetPVarInt(playerid, "MovingBar") == MOVE_SIZE)
                {
                    w += keys & KEY_SPRINT ? 2.0 : 1.0;
                    if(w > 640.0) w = 640.0;
                }
            }
            barid = CreateProgressBar(x, y, w, h, color, 100.0);
            SetProgressBarValue(barid, 50.0);
            ShowProgressBarForPlayer(playerid, barid);
            UpdateVars(_:barid, x, y, w, h, color);
            SetPVarInt(playerid, "BarID", _:barid);
        }
    }
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if(newkeys & KEY_SECONDARY_ATTACK)
    {
        if(GetPVarInt(playerid, "MovingBar"))
        {
            TogglePlayerControllable(playerid, true);
            SetPVarInt(playerid, "MovingBar", MOVE_NONE);
            SendClientMessage(playerid, 0xFFF000AA, "Now you can use /bar again to modify or finalize it.");
        }
    }
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    if(GetPVarInt(playerid, "MovingBar"))
    {
        TogglePlayerControllable(playerid, true);
        SetPVarInt(playerid, "MovingBar", MOVE_NONE);
    }
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if(GetPVarInt(playerid, "CreatingBar") == 1)
    {
        DestroyProgressBar(Bar:GetPVarInt(playerid, "BarID"));
        DeleteVars(GetPVarInt(playerid, "BarID"));
    }
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    if(!strcmp(cmdtext, "/bar", true))
    {
        if(GetPVarInt(playerid, "CreatingBar") == 0)
        {
            new Bar:barid;
            if((barid = CreateProgressBar(320.0, 240.0, 56.50, 3.39, 0xFF0000FF, 100.0)) == INVALID_BAR_ID)
            {
                SendClientMessage(playerid, 0xFF0000AA, "Internal error occurred when creating progress bar.");
                return 1;
            }
            SetProgressBarValue(barid, 50.0);
            ShowProgressBarForPlayer(playerid, barid);
            TogglePlayerControllable(playerid, false);
            UpdateVars(_:barid, 320.0, 240.0, 55.5, 3.2, 0xFF0000FF);

            SetPVarInt(playerid, "MovingBar", MOVE_POSITION);
            SetPVarInt(playerid, "CreatingBar", 1);
            SetPVarInt(playerid, "BarID", _:barid);

            SendClientMessage(playerid, 0xFFF000AA, "Use the arrow keys to move the bar arround the screen.");
            SendClientMessage(playerid, 0xFFF000AA, "Keep pressing 'Sprint' key to move faster.");
            SendClientMessage(playerid, 0xFFF000AA, "Press the 'Enter car' key when done.");
        }
        else
        {
            ShowPlayerDialog(playerid, DIALOG_BAR, DIALOG_STYLE_LIST, "Progress Bar", "Change Position\nChange Size\nChange Color\nI'm done, save bar!", "OK", "Cancel");
        }
        return 1;
    }
    return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == DIALOG_BAR)
    {
        if(response)
        {
            if(listitem == ITEM_MOVE)
            {
                SetPVarInt(playerid, "MovingBar", MOVE_POSITION);
                TogglePlayerControllable(playerid, false);
                SendClientMessage(playerid, 0xFFF000AA, "Use the arrow keys to move the bar arround the screen.");
                SendClientMessage(playerid, 0xFFF000AA, "Keep pressing 'Sprint' key to move faster.");
                SendClientMessage(playerid, 0xFFF000AA, "Press the 'Enter car' key when done.");
            }
            else if(listitem == ITEM_RESIZE)
            {
                SetPVarInt(playerid, "MovingBar", MOVE_SIZE);
                TogglePlayerControllable(playerid, false);
                SendClientMessage(playerid, 0xFFF000AA, "Use the arrow keys to resize the bar.");
                SendClientMessage(playerid, 0xFFF000AA, "Keep pressing 'Sprint' key to resize faster.");
                SendClientMessage(playerid, 0xFFF000AA, "Press the 'Enter car' key when done.");
            }
            else if(listitem == ITEM_COLOR)
            {
                ShowPlayerDialog(playerid, DIALOG_COLOR, DIALOG_STYLE_INPUT, "Change Color", "Type the color in hexadecimal format.\nExample: 0xFFF000FF\nRemember the alpha parameter (the last 2 numbers),\nthey define the transparency.\nIf you have doubts, use an external Color Picker.", "OK", "Cancel");
            }
            else if(listitem == ITEM_DONE)
            {
                ShowPlayerDialog(playerid, DIALOG_DONE, DIALOG_STYLE_INPUT, "Saving Bar", "Type the file name which you want to save the bar;\nYou don't need to specify the extension;\nThe default one is .txt;\nThe file will be created in the scriptfiles folder;\nAny file with the same name will be replaced automatically.", "Save", "Cancel");
            }
        }
    }
    else if(dialogid == DIALOG_COLOR)
    {
        SetProgressBarColor(Bar:GetPVarInt(playerid, "BarID"), hexstr(inputtext));
        UpdateProgressBar(Bar:GetPVarInt(playerid, "BarID"), playerid);
        Bars[GetPVarInt(playerid, "BarID")][pb_color] = hexstr(inputtext);
    }
    else if(dialogid == DIALOG_DONE)
    {
        new File:file, name[32], line[128], barid;

        if(strlen(inputtext) > 32 - 4)
        {
            strdel(inputtext, 32 - 4, strlen(inputtext));
        }
        format(name, sizeof name, "%s.txt", inputtext);

        if(!(file = fopen(name, io_write)))
        {
            SendClientMessage(playerid, 0xFF0000AA, "There was an error on file writing, try again.");
            ShowPlayerDialog(playerid, DIALOG_DONE, DIALOG_STYLE_INPUT, "Saving Bar", "Type the file name which you want to save the bar;\nYou don't need to specify the extension;\nThe default one is .txt;\nThe file will be created in the scriptfiles folder;\nAny file with the same name will be replaced automatically.", "Save", "Cancel");
            return 1;
        }
        barid = GetPVarInt(playerid, "BarID");
        format(line, sizeof line, "new Bar:bar = CreateProgressBar(%.2f, %.2f, %.2f, %.2f, %d, 100.0);\r\n",
            Bars[barid][pb_x], Bars[barid][pb_y], Bars[barid][pb_w], Bars[barid][pb_h], Bars[barid][pb_color]);

        fwrite(file, line);
        fwrite(file, "ShowProgressBarForAll(bar);\r\n");
        fwrite(file, "\r\nNow, take a look at the official SA:MP forum topic to know how to use this:\r\n\r\nhttp://forum.sa-mp.com/index.php?topic=138556\r\n");
        fclose(file);

        DeleteVars(barid);
        DestroyProgressBar(Bar:barid);
        DeletePVar(playerid, "BarID");
        DeletePVar(playerid, "MovingBar");
        DeletePVar(playerid, "CreatingBar");

        SendClientMessage(playerid, 0xFFFF00AA, "All done! Now take a look at your file to see the result!");
        SendClientMessage(playerid, 0xFFFFFFAA, "You can create another progress bar now.");
    }
    return 1;
}

stock hexstr(string[])
{
	new ret, val, i;
	if(string[0] == '0' && (string[1] == 'x' || string[1] == 'X')) i = 2;
	while(string[i])
	{
		ret <<= 4;
		val = string[i++] - '0';
		if(val > 0x09) val -= 0x07;
		if(val > 0x0F) val -= 0x20;
		if(val < 0x01) continue;
		if(val < 0x10) ret += val;
	}
	return ret;
}
