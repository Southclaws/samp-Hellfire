////////////////////////////////////////////
///////////////////RatEdit//////////////////
/////////////Made by: [FSaF]Jarno///////////
////////////////Version: 0.1////////////////
//////You are free to edit this script//////
//////for your own use, if you won't  //////
//////claim it as your own.           //////
//////Do not reupload this script to  //////
//////any website without asking the  //////
//////author. Report any bugs to the  //////
//////forum post.                     //////
//////Note: This script is not 100    //////
//////percent made by [FSaF]Jarno.    //////
//////Some functions are found from   //////
//////the internet.                   //////
////////////////////////////////////////////
/////////////////Have fun!//////////////////
////////////////////////////////////////////

#include <a_samp>
#include <dutils>
#include <dini>
#define VERSION 0.1
#pragma unused ret_memcpy
#define ADMINCHECK "GetAdminLevel" // Replace this with your own adminlevel check callback. If you don't have one, leave it like that and define "RCON_ONLY" to true.
#define ADMINLEVEL 3 // Adminlevel needed to use the script. If you are only using RCON, leave this like that.
#define ADMINFORMAT "%d" // Adminlevel check format. If you use RCON instead of your own scripts, don't change this.
#define ADMININPUT playerid // Adminlevel input. If oyu use RCON instead of your own scripts, don't change this.
#define RCON_ONLY false // If you want to use RCON instead of your own adminscript define this to true.
#define OBJECTDIALOG 4531// This will be the dialogid for the script. The script takes 10 dialogs. (OBJECTDIALOG - OBJECTDIALOG+9)
#define MOVETIME 70 // The interval of updating the moving timer.
#define AUTOSAVE true // Set this to "false" if you don't want to use the autosave feature (not recommended)
#define AUTOSAVEINTERVAL 60// Set this to the amount of seconds the autosave feature will save the objects.

#pragma dynamic 9216 // Don't change this, please.
#define RE_MAX_OBJECTS 300 // The maximum objects to be used in this script. If you need more, just increase the number.

// Object data
new ObjectName[MAX_OBJECTS][64];
new Float:ObjectX[MAX_OBJECTS];
new Float:ObjectY[MAX_OBJECTS];
new Float:ObjectZ[MAX_OBJECTS];
new Float:ObjectRX[MAX_OBJECTS];
new Float:ObjectRY[MAX_OBJECTS];
new Float:ObjectRZ[MAX_OBJECTS];
new ObjectModel[MAX_OBJECTS];
new bool:ObjectIsRatEdited[MAX_OBJECTS];
new ObjectAmount;

//Player data
new Float:Speed[MAX_PLAYERS];
new ObjectID[MAX_PLAYERS];
new EditMode[MAX_PLAYERS];
new PlayerModelID[MAX_PLAYERS];
new PlayerPage[MAX_PLAYERS];
new PlayerInputText[MAX_PLAYERS][128];
new PlayerLanguage[MAX_PLAYERS];

//Forwards
forward Movetimer();
forward GetPlayerEditMode(playerid);
forward AutoSave();

public OnFilterScriptInit()
{
	SetTimer("AutoSave",AUTOSAVEINTERVAL*1000,1);
	SetTimer("Movetimer",MOVETIME,1);
	for(new i; i<MAX_PLAYERS; i++)
	{
	    Speed[i] = 1.0;
	    if (IsPlayerConnected(i))OnPlayerConnect(i);
	}
	ReadObjects();
	print("\n\n--------------------------------------------");
	printf("    RatEdit v%2.1f [FSaF]Jarno loaded!",VERSION);
	print("--------------------------------------------\n\n");
	return 1;
}

stock SendLanguageText(playerid,color,string1[],string2[])
{
	if (PlayerLanguage[playerid] == 1)SendClientMessage(playerid,color,string2);
	else SendClientMessage(playerid,color,string1);
	return 1;
}

public OnPlayerDisconnect(playerid,reason)
{
    #if RCON_ONLY == true
	if (IsPlayerAdmin(playerid))
	{
	#else
	if (CallRemoteFunction(ADMINCHECK,ADMINFORMAT,ADMININPUT) >= ADMINLEVEL)
	{
	#endif
		new file[128], PlayerName[32];
		GetPlayerName(playerid,PlayerName,32);
		format(file,128,"/RatEdit/PlayerData/%s.ini",PlayerName);
		dini_IntSet(file,"Language",PlayerLanguage[playerid]);
	}
	return 1;
}

public AutoSave()
{
	SaveObjects();
	return 1;
}

public OnPlayerConnect(playerid)
{
    #if RCON_ONLY == true
	if (IsPlayerAdmin(playerid))
	{
	#else
	if (CallRemoteFunction(ADMINCHECK,ADMINFORMAT,ADMININPUT) >= ADMINLEVEL)
	{
	#endif
	    ObjectID[playerid] = -1;
		new file[128], PlayerName[32];
		GetPlayerName(playerid,PlayerName,32);
		format(file,128,"/RatEdit/PlayerData/%s.ini",PlayerName);
		PlayerLanguage[playerid] = dini_Int(file,"Language");
	}
	return 1;
}


stock CreateRatObject(modelid,Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, name[])
{
	new objid = CreateObject(modelid,x,y,z,rx,ry,rz);
	SetObjectMaterial(objid, 0, 3942, "bistro", "mp_snow", 0);
	ObjectIsRatEdited[objid] = true;
	ObjectX[objid] = x;
	ObjectY[objid] = y;
	ObjectZ[objid] = z;
	ObjectRX[objid] = rx;
	ObjectRY[objid] = ry;
	ObjectRZ[objid] = rz;
	ObjectModel[objid] = modelid;
	format(ObjectName[objid],64,"%s",name);
	return objid;
}

stock DestroyRatObject(objectid)
{
	if (ObjectIsRatEdited[objectid] == true)
	{
	    for(new i; i<MAX_PLAYERS; i++)
	    {
			if (ObjectID[i] == objectid)
			{
				ObjectID[i] = -1;
				EditMode[i] = 0;
			}
		}
		format(ObjectName[objectid],64,"");
		DestroyObject(objectid);
		ObjectIsRatEdited[objectid] = false;
		return 1;
	}
	else return 0;
}

stock GetXYInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance)
{
	new Float:a;
	GetPlayerPos(playerid, x, y, a);
	GetPlayerFacingAngle(playerid, a);
	if (GetPlayerVehicleID(playerid))
	{
	    GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	}
	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
}
	

public OnFilterScriptExit()
{
	print("\n\n--------------------------------------------");
	printf("    RatEdit v%2.1f [FSaF]Jarno unloaded!",VERSION);
	print("--------------------------------------------\n\n");
	SaveObjects();
	for(new i; i<MAX_OBJECTS; i++)
	{
		if (ObjectIsRatEdited[i] == true)DestroyRatObject(i);
	}
	for(new i; i<MAX_PLAYERS; i++)
	{
	    if (IsPlayerConnected(i))OnPlayerDisconnect(i,1);
	    new playerid = i;
	    #if RCON_ONLY == true
		if (IsPlayerAdmin(playerid))
		{
		#else
		if (CallRemoteFunction(ADMINCHECK,ADMINFORMAT,ADMININPUT) >= ADMINLEVEL)
		{
		#endif
			new file[128], PlayerName[32];
			GetPlayerName(playerid,PlayerName,32);
			format(file,128,"/RatEdit/PlayerData/%s.ini",PlayerName);
			if (!dini_Exists(file))dini_Create(file);
			dini_IntSet(file,"Language",PlayerLanguage[playerid]);
		}
	}
 	return 1;
}

stock ReadObjectList(list [], file[]="index.ini", index=1) // Originally made by Allan
{
	new farq[256];
	set(farq,file);
	format(file,MAX_STRING,"/RatEdit/Objects/%s",file);
	new line[256], File:fl = fopen(file,io_append), first=(index-1)*80, i=0, last = index*80;
	list[0] = 0;
	fclose(fl);
	fl = fopen(file,io_read);
	while(i < last && fread(fl, line))
	{
	    if(i < first)
	    {
	        i++;
	        continue;
	    }
  		StripNewLine(line);
  		if(line[0] == '/')
  		    continue;
  		strcat(list,line,4096);
  		strcat(list,"\n",4096);
  		i++;
	}
	if(list[strlen(list)-1] == '\n')
	    list[strlen(list)-1] = 0;
 	fclose(fl);
 	set(file,farq);
	return list;
}

stock strrest(const string[], &index, stringer=0)
{
	new length = strlen(string);
	while ((index < length) && (string[index] <= stringer))
	{
		index++;
	}
	new offset = index;
	new result[128];
	while ((index < length) && ((index - offset) < (sizeof(result) - 1)))
	{
		result[index - offset] = string[index];
		index++;
	}
	result[index - offset] = EOS;
	return result;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	new idx;
	new cmd[256];
	cmd = strtok(cmdtext,idx);
	#if RCON_ONLY == true
	if (IsPlayerAdmin(playerid))
	{
	#else
	if (CallRemoteFunction(ADMINCHECK,ADMINFORMAT,ADMININPUT) >= ADMINLEVEL)
	{
	#endif

		if (strcmp("/add", cmd, true, 10) == 0)
		{
		    if (ObjectAmount >= RE_MAX_OBJECTS)
		    {
		        SendLanguageText(playerid,0xFFAAAAFF,"Object amount over object limit!","Objektim‰‰r‰ ylitt‰‰ objektirajan!");
		        return 1;
			}
			new tmp[256], name[256], modelid;
			tmp = strtok(cmdtext,idx);
			name = strrest(cmdtext,idx);
			modelid = strval(tmp);
			new returner;
			if ((!strlen(tmp)) || (!strlen(name)))
			{
			    new list[4096];
			    ReadObjectList(list);
			    if (PlayerLanguage[playerid] == 0)ShowPlayerDialog(playerid,OBJECTDIALOG,DIALOG_STYLE_LIST,"Select Category",list,"OK","Cancel");
			    else ShowPlayerDialog(playerid,OBJECTDIALOG,DIALOG_STYLE_LIST,"Valitse kategoria",list,"OK","Peruuta");
			    return 1;
			}
			for(new i; i<MAX_OBJECTS; i++)
			{
			    if (!strlen(ObjectName[i]))continue;
			    if (!strcmp(ObjectName[i],name))
			    {
					new msg[128], msg2[128];
					format(msg,128,"%s - Name already exists! [MODELID: %d]",name,modelid);
					format(msg2,128,"%s - Nimi on jo k‰ytˆss‰! [MODELID: %d]",name,modelid);
					SendLanguageText(playerid,0xFFAAAAFF,msg,msg2);
					returner = 1;
					break;
				}
			}
			if (returner == 1) return 1;
			new Float:x, Float:y, Float:z;
			GetPlayerPos(playerid,x,y,z);
			GetXYInFrontOfPlayer(playerid,x,y,3);
			new object = CreateRatObject(modelid,x,y,z,0,0,0,name);
			ObjectAmount++;
			new msg[128], msg2[128];
			format(msg,128,"%s - Object created! [MODELID: %d] [OBJECTID: %d]",ObjectName[object],ObjectModel[object],object);
			format(msg2,128,"%s - Objekti luotu! [MODELID: %d] [OBJECTID: %d]",ObjectName[object],ObjectModel[object],object);
			SendLanguageText(playerid,0xAAFFAAFF,msg,msg2);
			ObjectID[playerid] = object;
			return 1;
		}
		
		if(!strcmp("/rehelp",cmdtext))
		{
		    new msg[128];
		    format(msg,128,"===============RatEdit v%2.1f by [FSaF]Jarno===============",VERSION);
		    SendClientMessage(playerid,0xAAFFAAFF,msg);
		    SendClientMessage(playerid,0xFFFFFFFF,"/add [modelid] [name] /del [name] /sel [name] /deleteallobjects");
		    SendClientMessage(playerid,0xFFFFFFFF,"Move/rotate objects with:");
		    SendClientMessage(playerid,0xFFFFFFFF,"~k~~CONVERSATION_NO~, ~k~~CONVERSATION_YES~, ~k~~VEHICLE_TURRETLEFT~, ~k~~VEHICLE_TURRETRIGHT~");
			SendClientMessage(playerid,0xFFFFFFFF,"~k~~PED_SPRINT~ + ~k~~CONVERSATION_NO~, ~k~~PED_SPRINT~ + ~k~~CONVERSATION_YES~");
		    SendClientMessage(playerid,0xFFFFFFFF,"And to open the menu use ~k~~GROUP_CONTROL_BWD~");
		    return 1;
		}

		if (!strcmp("/editmode",cmd,true))
		{
			new tmp[256];
			tmp = strtok(cmdtext,idx);
			EditMode[playerid] = strval(tmp);
			return 1;
		}

		if (!strcmp("/speed",cmd,true))
		{
			new tmp[256];
			tmp = strtok(cmdtext,idx);
			Speed[playerid] = floatstr(tmp);
			return 1;
		}

		if (!strcmp("/sel",cmd,true))
		{
			new name[256];
			name = strtok(cmdtext,idx);
			for(new i; i<MAX_OBJECTS; i++)
			{
			    if (!strlen(ObjectName[i])) continue;
				if (!strcmp(ObjectName[i],name,true))
				{
					new msg[128], msg2[128];
					format(msg,128,"%s - Object selected! [MODELID: %d] [OBJECTID: %d]",ObjectName[i],ObjectModel[i],i);
					format(msg2,128,"%s - Objekti valittu! [MODELID: %d] [OBJECTID: %d]",ObjectName[i],ObjectModel[i],i);
					SendLanguageText(playerid,0xAAFFAAFF,msg,msg2);
					ObjectID[playerid] = i;
				}
			}
			return 1;
		}

		if (!strcmp("/del",cmd,true))
		{
		    new name[256];
		    name = strtok(cmdtext,idx);
		    if (strlen(name))
		    {
		        for(new i; i<MAX_OBJECTS; i++)
		        {
			    	if (!strlen(ObjectName[i])) continue;
		            if (!strcmp(ObjectName[i],name,true))
					{
						new msg[128], msg2[128];
						format(msg,128,"%s - Object deleted! [MODELID: %d] [OBJECTID: %d]",ObjectName[i],ObjectModel[i],i);
						format(msg2,128,"%s - Objekti poistettu! [MODELID: %d] [OBJECTID: %d]",ObjectName[i],ObjectModel[i],i);
						SendLanguageText(playerid,0xAAFFAAFF,msg,msg2);
						DestroyRatObject(i);
						break;
					}
				}
			}
			else
			{
			    new msg[128], msg2[128];
				format(msg,128,"%s - Object deleted! [MODELID: %d] [OBJECTID: %d]",ObjectName[ObjectID[playerid]],ObjectModel[ObjectID[playerid]],ObjectID[playerid]);
				format(msg2,128,"%s - Objekti poistettu! [MODELID: %d] [OBJECTID: %d]",ObjectName[ObjectID[playerid]],ObjectModel[ObjectID[playerid]],ObjectID[playerid]);
				SendLanguageText(playerid,0xAAFFAAFF,msg,msg2);
				DestroyRatObject(ObjectID[playerid]);
			}
			return 1;
		}

		if (!strcmp("/deleteallobjects",cmd,true))
		{
	 		for(new i; i<MAX_OBJECTS; i++)
	   		{
	     		if (ObjectIsRatEdited[i] == true)
				{
					new msg[128], msg2[128];
					format(msg,128,"%s - Object deleted! [MODELID: %d] [OBJECTID: %d]",ObjectName[i],ObjectModel[i],i);
					format(msg2,128,"%s - Objekti poistettu! [MODELID: %d] [OBJECTID: %d]",ObjectName[i],ObjectModel[i],i);
					SendLanguageText(playerid,0xAAFFAAFF,msg,msg2);
					DestroyRatObject(i);
				}
			}
			return 1;
		}
	}
	return 0;
}

public GetPlayerEditMode(playerid)
{
	return EditMode[playerid];
}

public Movetimer()
{
	for(new i; i<MAX_PLAYERS; i++)
	{
	    if (!IsPlayerConnected(i))continue;
		new objectid = ObjectID[i];
	    new ud,lr,keys;
	    GetPlayerKeys(i,keys,ud,lr);
     	if (EditMode[i] == 1)
     	{
     	    if ((keys & KEY_HANDBRAKE) && (IsPlayerInAnyVehicle(i)))
     	    {
	     	    if (keys & KEY_YES)
	     	    {
					if (ObjectID[i] != -1)
					{
					    MoveObject(ObjectID[i],ObjectX[objectid],ObjectY[objectid],ObjectZ[objectid]+Speed[i],Speed[i]*16);
						ObjectZ[objectid] = ObjectZ[objectid]+Speed[i];
						return 1;
					}
				}
	     	    if (keys & KEY_NO)
	     	    {
					if (ObjectID[i] != -1)
					{
					    MoveObject(ObjectID[i],ObjectX[objectid],ObjectY[objectid],ObjectZ[objectid]-Speed[i],Speed[i]*16);
						ObjectZ[objectid] = ObjectZ[objectid]-Speed[i];
						return 1;
					}
				}
			}
     	    if (keys & KEY_SPRINT)
     	    {
	     	    if (keys & KEY_YES)
	     	    {
					if (ObjectID[i] != -1)
					{
					    MoveObject(ObjectID[i],ObjectX[objectid],ObjectY[objectid],ObjectZ[objectid]+Speed[i],Speed[i]*16);
						ObjectZ[objectid] = ObjectZ[objectid]+Speed[i];
						return 1;
					}
				}
	     	    if (keys & KEY_NO)
	     	    {
					if (ObjectID[i] != -1)
					{
					    MoveObject(ObjectID[i],ObjectX[objectid],ObjectY[objectid],ObjectZ[objectid]-Speed[i],Speed[i]*16);
						ObjectZ[objectid] = ObjectZ[objectid]-Speed[i];
						return 1;
					}
				}
			}
     	    if (keys & KEY_YES)
     	    {
				if (ObjectID[i] != -1)
				{
				    MoveObject(ObjectID[i],ObjectX[objectid],ObjectY[objectid]+Speed[i],ObjectZ[objectid],Speed[i]*16);
					ObjectY[objectid] = ObjectY[objectid]+Speed[i];
				}
			}
     	    if (keys & KEY_NO)
     	    {
				if (ObjectID[i] != -1)
				{
				    MoveObject(ObjectID[i],ObjectX[objectid],ObjectY[objectid]-Speed[i],ObjectZ[objectid],Speed[i]*16);
					ObjectY[objectid] = ObjectY[objectid]-Speed[i];
				}
			}
     	    if (keys & KEY_ANALOG_LEFT)
     	    {
				if (ObjectID[i] != -1)
				{
				    MoveObject(ObjectID[i],ObjectX[objectid]-Speed[i],ObjectY[objectid],ObjectZ[objectid],Speed[i]*16);
					ObjectX[objectid] = ObjectX[objectid]-Speed[i];
				}
			}
     	    if (keys & KEY_ANALOG_RIGHT)
     	    {
				if (ObjectID[i] != -1)
				{
				    MoveObject(ObjectID[i],ObjectX[objectid]+Speed[i],ObjectY[objectid],ObjectZ[objectid],Speed[i]*16);
					ObjectX[objectid] = ObjectX[objectid]+Speed[i];
				}
			}
		}
		if (EditMode[i] == 2)
     	{
     	    if ((keys & KEY_HANDBRAKE) || (keys & KEY_SPRINT))
     	    {
	     	    if (keys & KEY_YES)
	     	    {
					if (ObjectID[i] != -1)
					{
						ObjectRY[objectid] = ObjectRY[objectid]+Speed[i];
						while(ObjectRY[objectid] > 360)
						{
						    ObjectRY[objectid] = ObjectRY[objectid]-360;
						}
						while(ObjectRY[objectid] < 0)
						{
						    ObjectRY[objectid] = ObjectRY[objectid]+360;
						}
					    MoveObject(ObjectID[i],ObjectX[objectid],ObjectY[objectid],ObjectZ[objectid],Speed[i]*16,ObjectRX[objectid],ObjectRY[objectid],ObjectRZ[objectid]);
						return 1;
					}
				}
	     	    if (keys & KEY_NO)
	     	    {
					if (ObjectID[i] != -1)
					{
						ObjectRY[objectid] = ObjectRY[objectid]-Speed[i];
						while(ObjectRY[objectid] > 360)
						{
						    ObjectRY[objectid] = ObjectRY[objectid]-360;
						}
						while(ObjectRY[objectid] < 0)
						{
						    ObjectRY[objectid] = ObjectRY[objectid]+360;
						}
					    MoveObject(ObjectID[i],ObjectX[objectid],ObjectY[objectid],ObjectZ[objectid],Speed[i]*16,ObjectRX[objectid],ObjectRY[objectid],ObjectRZ[objectid]);
						return 1;
					}
				}
			}
     	    if (keys & KEY_YES)
     	    {
				if (ObjectID[i] != -1)
				{
						ObjectRX[objectid] = ObjectRX[objectid]+Speed[i];
						while(ObjectRX[objectid] > 360)
						{
						    ObjectRX[objectid] = ObjectRX[objectid]-360;
						}
						while(ObjectRX[objectid] < 0)
						{
						    ObjectRX[objectid] = ObjectRX[objectid]+360;
						}
					    MoveObject(ObjectID[i],ObjectX[objectid],ObjectY[objectid],ObjectZ[objectid],Speed[i]*16,ObjectRX[objectid],ObjectRY[objectid],ObjectRZ[objectid]);
				}
			}
     	    if (keys & KEY_NO)
     	    {
				if (ObjectID[i] != -1)
				{
						ObjectRX[objectid] = ObjectRX[objectid]-Speed[i];
						while(ObjectRX[objectid] > 360)
						{
						    ObjectRX[objectid] = ObjectRX[objectid]-360;
						}
						while(ObjectRX[objectid] < 0)
						{
						    ObjectRX[objectid] = ObjectRX[objectid]+360;
						}
					    MoveObject(ObjectID[i],ObjectX[objectid],ObjectY[objectid],ObjectZ[objectid],Speed[i]*16,ObjectRX[objectid],ObjectRY[objectid],ObjectRZ[objectid]);
				}
			}
     	    if (keys & KEY_ANALOG_LEFT)
     	    {
				if (ObjectID[i] != -1)
				{
						ObjectRZ[objectid] = ObjectRZ[objectid]-Speed[i];
						while(ObjectRZ[objectid] > 360)
						{
						    ObjectRZ[objectid] = ObjectRZ[objectid]-360;
						}
						while(ObjectRZ[objectid] < 0)
						{
						    ObjectRZ[objectid] = ObjectRZ[objectid]+360;
						}
					    MoveObject(ObjectID[i],ObjectX[objectid],ObjectY[objectid],ObjectZ[objectid],Speed[i]*16,ObjectRX[objectid],ObjectRY[objectid],ObjectRZ[objectid]);
				}
			}
     	    if (keys & KEY_ANALOG_RIGHT)
     	    {
				if (ObjectID[i] != -1)
				{
						ObjectRZ[objectid] = ObjectRZ[objectid]+Speed[i];
						while(ObjectRZ[objectid] > 360)
						{
						    ObjectRZ[objectid] = ObjectRZ[objectid]-360;
						}
						while(ObjectRZ[objectid] < 0)
						{
						    ObjectRZ[objectid] = ObjectRZ[objectid]+360;
						}
					    MoveObject(ObjectID[i],ObjectX[objectid],ObjectY[objectid],ObjectZ[objectid],Speed[i]*16,ObjectRX[objectid],ObjectRY[objectid],ObjectRZ[objectid]);
				}
			}
		}
	}
	return 1;
}
	    
	

stock ReadObjects() { // Originally made by Allan.
    new File:hFile;
    new tmpres[MAX_STRING],i=0;

    new Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, modelid, name[64];

    new file[256];
    format(file,128,"/RatEdit/SAVE.txt");

    if (!(fexist(file))) {
        print("RatEdit: '/scriptfiles/RatEdit/SAVE.TXT' not found!");
        return 0;
    }
    else {
        hFile = fopen(file, io_read);
        tmpres[0]=0;
        while (fread(hFile, tmpres))
		{
            StripNewLine(tmpres);
            if (tmpres[0]!=0)
				{
				    if (ObjectAmount >= RE_MAX_OBJECTS) break;
				    modelid = strval(strtok(tmpres,i,','));
				    x = Float:floatstr(strtok(tmpres,i,','));
				    y = Float:floatstr(strtok(tmpres,i,','));
				    z = Float:floatstr(strtok(tmpres,i,','));
				    rx = Float:floatstr(strtok(tmpres,i,','));
				    ry = Float:floatstr(strtok(tmpres,i,','));
				    rz = Float:floatstr(strtok(tmpres,i,','));
				    set(name,strrest(tmpres,i,','));
					CreateRatObject(modelid,x,y,z,rx,ry,rz,name);
					ObjectAmount++;
                }
            tmpres[0]=0;
            i=0;
        }
        fclose(hFile);
        return 1;
    }
}

stock SaveObjects()
{
 	new File:F_OBJECTS = fopen("/RatEdit/SAVE.txt", io_write);
  	if(F_OBJECTS)
	{
	    new line[256];
	    for(new i; i<MAX_OBJECTS; i++)
	    {
	        if (ObjectIsRatEdited[i] == true)
	        {
				format(line,256,"%d,%f,%f,%f,%f,%f,%f,%s\r\n",ObjectModel[i],ObjectX[i],ObjectY[i],ObjectZ[i],ObjectRX[i],ObjectRY[i],ObjectRZ[i],ObjectName[i]);
				fwrite(F_OBJECTS,line);
			}
		}
	}
	fclose(F_OBJECTS);
 	F_OBJECTS = fopen("/RatEdit/Objects.txt", io_write);
  	if(F_OBJECTS)
	{
	    new line[256];
	    for(new i; i<MAX_OBJECTS; i++)
	    {
	        if (ObjectIsRatEdited[i] == true)
	        {
				format(line,256,"CreateObject(%d,%f,%f,%f,%f,%f,%f); //%s\r\n",ObjectModel[i],ObjectX[i],ObjectY[i],ObjectZ[i],ObjectRX[i],ObjectRY[i],ObjectRZ[i],ObjectName[i]);
				fwrite(F_OBJECTS,line);
			}
		}
	}
	fclose(F_OBJECTS);
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	new idx;
    new modelid = strval(strtok(inputtext,idx,'-'));
    if (dialogid == OBJECTDIALOG)
    {
        if (response == 1)
        {
            set(PlayerInputText[playerid],inputtext);
	        new file[256], lines;
	        set(file,inputtext);
	        strcat(file,".txt");
	        lines = GetNumberOfLines(file);
	        new TheList[4096];
			ReadObjectList(TheList,file);
	        if (lines <= 80)
	        {
	            new title[128], title2[128];
	            format(title,128,"%s - Add Object",inputtext);
	            format(title2,128,"%s - Lis‰‰ objekti",inputtext);
	            if (PlayerLanguage[playerid] == 0)ShowPlayerDialog(playerid,OBJECTDIALOG+2,DIALOG_STYLE_LIST,title,TheList,"OK","Cancel");
	            else ShowPlayerDialog(playerid,OBJECTDIALOG+2,DIALOG_STYLE_LIST,title2,TheList,"OK","Peruuta");
				return 1;
			}
			else
	        {
	            PlayerPage[playerid] = 1;
	            new title[128], title2[128];
	            format(title,128,"%s - Add Object - Page 1",inputtext);
	            format(title2,128,"%s - Lis‰‰ objekti - Sivu 1",inputtext);
	            if (PlayerLanguage[playerid] == 0)ShowPlayerDialog(playerid,OBJECTDIALOG+1,DIALOG_STYLE_LIST,title,TheList,"OK","Cancel");
	            else ShowPlayerDialog(playerid,OBJECTDIALOG+1,DIALOG_STYLE_LIST,title2,TheList,"OK","Peruuta");
				return 1;
			}
		}
	}
	if (dialogid == OBJECTDIALOG+1)
	{
	    if (response == 1)
	    {
	        PlayerModelID[playerid] = modelid;
			new title[128], title2[128];
			format(title,128,"%s - Name",inputtext);
			format(title2,128,"%s - Nimi",inputtext);
			if (PlayerLanguage[playerid] == 0)ShowPlayerDialog(playerid,OBJECTDIALOG+3,DIALOG_STYLE_INPUT,title,"Type in the name for your object:","OK","Cancel");
			else ShowPlayerDialog(playerid,OBJECTDIALOG+3,DIALOG_STYLE_INPUT,title2,"Kirjoita objektille nimi:","OK","Peruuta");
			return 1;
		}
		else
		{
	        new file[256], lines;
	        set(file,PlayerInputText[playerid]);
	        strcat(file,".txt");
	        lines = GetNumberOfLines(file)-PlayerPage[playerid]*80;
	        new TheList[4096];
	    	PlayerPage[playerid]++;
			ReadObjectList(TheList,file,PlayerPage[playerid]);
	    	if (lines <= 80)
	    	{
	            new title[128], title2[128];
	            format(title,128,"%s - Add Object - Page %d",PlayerInputText[playerid],PlayerPage[playerid]);
	            format(title2,128,"%s - Lis‰‰ objekti - Sivu %d",PlayerInputText[playerid],PlayerPage[playerid]);
	            if (PlayerLanguage[playerid] == 0)ShowPlayerDialog(playerid,OBJECTDIALOG+1,DIALOG_STYLE_LIST,title,TheList,"OK","Cancel");
	            else ShowPlayerDialog(playerid,OBJECTDIALOG+1,DIALOG_STYLE_LIST,title2,TheList,"OK","Peruuta");
				return 1;
			}
			else
	    	{
	            new title[128], title2[128];
	            format(title,128,"%s - Add Object - Page %d",PlayerInputText[playerid],PlayerPage[playerid]);
	            format(title2,128,"%s - Lis‰‰ objekti - Sivu %d",PlayerInputText[playerid],PlayerPage[playerid]);
	            if (PlayerLanguage[playerid] == 0)ShowPlayerDialog(playerid,OBJECTDIALOG+1,DIALOG_STYLE_LIST,title,TheList,"OK","Next Page");
	            else ShowPlayerDialog(playerid,OBJECTDIALOG+1,DIALOG_STYLE_LIST,title2,TheList,"OK","Seur. Sivu");
				return 1;
			}
		}
	}
	    	
	if (dialogid == OBJECTDIALOG+2)
	{
	    if (response == 1)
	    {
		PlayerModelID[playerid] = modelid;
		new title[128], title2[128];
		format(title,128,"%s - Name",inputtext);
		format(title2,128,"%s - Nimi",inputtext);
		if (PlayerLanguage[playerid] == 0)ShowPlayerDialog(playerid,OBJECTDIALOG+3,DIALOG_STYLE_INPUT,title,"Type in the name for your object:","OK","Cancel");
		else ShowPlayerDialog(playerid,OBJECTDIALOG+3,DIALOG_STYLE_INPUT,title2,"Kirjoita objektille nimi:","OK","Peruuta");
		}
		return 1;
	}
	if (dialogid == OBJECTDIALOG+3)
	{
	    if (strlen(inputtext))
	    {
	        new UnAllowedName;
	        for(new i; i<MAX_OBJECTS; i++)
	        {
	            if (!strlen(ObjectName[i]))continue;
	            if (!strcmp(ObjectName[i],inputtext)) UnAllowedName = 1;
			}
			if (UnAllowedName == 0)
			{
		        new command[128];
				format(command,128,"/add %d %s",PlayerModelID[playerid],inputtext);
				OnPlayerCommandText(playerid,command);
			}
			else
			{
			    if (PlayerLanguage[playerid] == 0)ShowPlayerDialog(playerid,OBJECTDIALOG+3,DIALOG_STYLE_INPUT,"Name","Type in the name for your object:\n{FF0000}Object name is already used!","OK","Cancel");
			    else ShowPlayerDialog(playerid,OBJECTDIALOG+3,DIALOG_STYLE_INPUT,"Nimi","Kirjoita objektille nimi:\n{FF0000Objektin nimi on jo k‰ytˆss‰!","OK","Peruuta");
			}
			return 1;
		}
		else
		{
		    if (response != 0)
			{
				if (PlayerLanguage[playerid] == 0)ShowPlayerDialog(playerid,OBJECTDIALOG+3,DIALOG_STYLE_INPUT,"Name","Type in the name for your object:","OK","Cancel");
				else ShowPlayerDialog(playerid,OBJECTDIALOG+3,DIALOG_STYLE_INPUT,"Nimi","Kirjoita objektille nimi:","OK","Peruuta");
			}
			return 1;
		}
	}
	if (dialogid == OBJECTDIALOG+4)
	{
	    if (response == 1)
	    {
	        switch(listitem)
	        {
	            case 0:
				{
					if (PlayerLanguage[playerid] == 0)ShowPlayerDialog(playerid,OBJECTDIALOG+5,DIALOG_STYLE_INPUT,"Select object","Type in the name of the object:","OK","Cancel");
					else ShowPlayerDialog(playerid,OBJECTDIALOG+5,DIALOG_STYLE_INPUT,"Valitse objekti","Kirjoita objektin nimi:","OK","Peruuta");
				}
	            case 1: OnPlayerCommandText(playerid,"/add");
	            case 2:
	            {
	                SaveObjects();
	                new msg[128];
	                new msg2[128];
					format(msg,128,"%d objects saved!",ObjectAmount);
					format(msg2,128,"%d objektia tallennettu!",ObjectAmount);
	                SendLanguageText(playerid,0xAAFFAAFF,msg,msg2);
				}
				case 3:
				{
				    if (PlayerLanguage[playerid] == 0)ShowPlayerDialog(playerid,OBJECTDIALOG+9,DIALOG_STYLE_MSGBOX,"Select Language","Select your language:","English","Suomi");
				    else ShowPlayerDialog(playerid,OBJECTDIALOG+9,DIALOG_STYLE_MSGBOX,"Valitse kieli","Valitse kielesi:","Englanti","Suomi");
				}
	            case 4:
				{
					if (PlayerLanguage[playerid] == 0)ShowPlayerDialog(playerid,OBJECTDIALOG+6,DIALOG_STYLE_INPUT,"Copy object","Type in the name of the new object:","OK","Cancel");
					else ShowPlayerDialog(playerid,OBJECTDIALOG+6,DIALOG_STYLE_INPUT,"Kopioi objekti","Kirjoita uuden objektin nimi:","OK","Peruuta");
				}
	            case 5: EditMode[playerid] = 1;
	            case 6: EditMode[playerid] = 2;
	            case 7:
				{
					if (PlayerLanguage[playerid] == 0)ShowPlayerDialog(playerid,OBJECTDIALOG+7,DIALOG_STYLE_MSGBOX,"Delete object","Are you sure you want to delete this object?\n{FF0000}Note: This can not be undone!","No","Yes");
					else ShowPlayerDialog(playerid,OBJECTDIALOG+7,DIALOG_STYLE_MSGBOX,"Poista objekti","Oletko varma ett‰ haluat poistaa t‰m‰n objektin?\n{FF0000}Huom: T‰t‰ ei voi peruuttaa!","Ei","Kyll‰");
				}
				case 8:
	            {
	                ObjectID[playerid] = -1;
	                EditMode[playerid] = 0;
	                new msg[128];
					format(msg,128,"%s - Object deselected!",ObjectName[ObjectID[playerid]]);
	                SendLanguageText(playerid,0xAAFFAAFF,msg,"Mik‰‰n ei ole en‰‰ valittuna!");
				}
				case 9:
				{
				    SetPlayerPos(playerid,ObjectX[ObjectID[playerid]],ObjectY[ObjectID[playerid]],ObjectZ[ObjectID[playerid]]);
				    SendLanguageText(playerid,0xAAFFAAFF,"You have been teleported to your object.","Sinut on teleportattu objektisi luo.");
				}
				case 10:
				{
				    if (PlayerLanguage[playerid] == 0)ShowPlayerDialog(playerid,OBJECTDIALOG+8,DIALOG_STYLE_INPUT,"Change moving/rotating speed","Type in the new speed value (The default is 1):","OK","Cancel");
				    else ShowPlayerDialog(playerid,OBJECTDIALOG+8,DIALOG_STYLE_INPUT,"Vaihda siirron/k‰‰nnˆn nopeutta","Syˆt‰ uusi nopeusluku: (Oletusluku on 1)","OK","Peruuta");
				}
				case 11: EditMode[playerid] = 0;
			}
		}
	}
	if (dialogid == OBJECTDIALOG+5)
	{
	    if (response == 1)
	    {
			if (strlen(inputtext))
			{
				new cmd[128];
				format(cmd,128,"/sel %s",inputtext);
				OnPlayerCommandText(playerid,cmd);
			}
		}
	}
	if (dialogid == OBJECTDIALOG+6)
	{
	    if (response == 1)
	    {
			if (strlen(inputtext))
			{
				new obj = ObjectID[playerid], Nope;
				for(new i; i<MAX_OBJECTS; i++)
				{
				    if (!strlen(ObjectName[i]))continue;
				    if (!strcmp(ObjectName[i],inputtext)) Nope = 1;
				}
				if (Nope != 1)
				{
					new objid = CreateRatObject(ObjectModel[obj],ObjectX[obj],ObjectY[obj],ObjectZ[obj],ObjectRX[obj],ObjectRY[obj],ObjectRZ[obj],inputtext);
					new msg[128], msg2[128];
					format(msg,128,"%s - Object copied!",inputtext);
					format(msg2,128,"%s - Objekti kopioitu!",inputtext);
					SendLanguageText(playerid,0xAAFFAAFF,msg,msg2);
					ObjectID[playerid] = objid;
				}
				else
				{
					if (PlayerLanguage[playerid] == 0)ShowPlayerDialog(playerid,OBJECTDIALOG+6,DIALOG_STYLE_INPUT,"Copy object","Type in the name of the new object:\n{FF0000}The name already exists!","OK","Cancel");
					else ShowPlayerDialog(playerid,OBJECTDIALOG+6,DIALOG_STYLE_INPUT,"Kopioi objekti","Kirjoita uuden objektin nimi:\n{FF0000}Objekti on jo olemassa!","OK","Peruuta");
				}
			}
		}
	}
	if (dialogid == OBJECTDIALOG+7)
	{
	    if (response == 0)
	    {
			OnPlayerCommandText(playerid,"/del");
		}
	}
	if (dialogid == OBJECTDIALOG+8)
	{
	    if (response == 1)
	    {
	        if (strlen(inputtext))
	        {
	            new cmd[128];
	            format(cmd,128,"/speed %f",floatstr(inputtext));
				OnPlayerCommandText(playerid,cmd);
			}
			else
			{
   				if (PlayerLanguage[playerid] == 0)ShowPlayerDialog(playerid,OBJECTDIALOG+8,DIALOG_STYLE_INPUT,"Change moving/rotating speed","Type in the new speed value (The default is 1):","OK","Cancel");
			    else ShowPlayerDialog(playerid,OBJECTDIALOG+8,DIALOG_STYLE_INPUT,"Vaihda siirron/k‰‰nnˆn nopeutta","Syˆt‰ uusi nopeusluku: (Oletusluku on 1)","OK","Peruuta");
			}
		}
	}
	if (dialogid == OBJECTDIALOG+9)
	{
	    if (response == 1)
	    {
	        SendClientMessage(playerid,0xAAFFAAFF,"Your language is now english");
	        PlayerLanguage[playerid] = 0;
		}
		else
		{
		    SendClientMessage(playerid,0xAAFFAAFF,"Kielesi on nyt suomi.");
		    PlayerLanguage[playerid] = 1;
		}
	}
	return 0;
}

stock GetNumberOfLines(file[]) // Found on the internet, credits to whoever made this
{
	new tempfile[256];
	set(tempfile,file);
	format(file,MAX_STRING,"/RatEdit/Objects/%s",file);
	new line[256], File:file2 = fopen(file,io_append), i=0;
	fclose(file2);
	file2 = fopen(file,io_read);
	while(fread(file2, line))
	{
		i++;
	}
 	fclose(file2);
 	set(file,tempfile);
 	return i;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if (newkeys & KEY_CTRL_BACK)
	{
	    #if RCON_ONLY == true
		if (IsPlayerAdmin(playerid))
		{
		#else
		if (CallRemoteFunction(ADMINCHECK,ADMINFORMAT,ADMININPUT) >= ADMINLEVEL)
		{
		#endif
		    if (ObjectID[playerid] == -1)
		    {
		        new msg[128];
		        format(msg,128,"RatEdit v%2.1f by [FSaF]Jarno",VERSION);
		        if (PlayerLanguage[playerid] == 0)ShowPlayerDialog(playerid,OBJECTDIALOG+4,DIALOG_STYLE_LIST,msg,"Select object\nAdd object\nSave objects\nSelect language","OK","Cancel");
		        else ShowPlayerDialog(playerid,OBJECTDIALOG+4,DIALOG_STYLE_LIST,msg,"Valitse objekti\nLis‰‰ objekti\nTallenna objektit\nValitse kieli","OK","Peruuta");
			}
			else
		    {
		        new msg[128];
		        format(msg,128,"RatEdit v%2.1f by [FSaF]Jarno",VERSION);
		        if (PlayerLanguage[playerid] == 0)ShowPlayerDialog(playerid,OBJECTDIALOG+4,DIALOG_STYLE_LIST,msg,"Select object\nAdd object\nSave object\nSelect language\nCopy object\nMove object\nRotate object\nDelete object\nDeselect object\nTeleport to object\nChange moving/rotating speed\nStop moving/rotating\nAttach/deattach object","OK","Cancel");
		        else ShowPlayerDialog(playerid,OBJECTDIALOG+4,DIALOG_STYLE_LIST,msg,"Valitse objekti\nLis‰‰ objekti\nTallenna objektit\nValitse kieli\nKopioi objekti\nSiirr‰ objektia\nK‰‰nn‰ objektia\nPoista objekti\nPeruuta valinta\nTeleporttaa objektin luo\nVaihda siirron/k‰‰nnˆn nopeutta\nLopeta siirt‰minen/k‰‰nt‰minen\nKiinnit‰/irrota objekti","OK","Peruuta");
			}
		}
	}	
	return 1;
}
