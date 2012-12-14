/*
--------------------------------------------------------------------------------

 	- iAnims Animation Creation Kit 1.1
 	- Author: Iggy
 	- Special Thanks To Aelfred. Owner Of BionixGaming.
 	- And Thanks To Everyone In The BionixGaming Community.
 	
1.1 - Dialogs and /browse anim command added
 	
--------------------------------------------------------------------------------

	Credits: ( alphabetical order )
	
	Slice   - BUD ( blazing user database ) / also used the animation enum for reference.
	Y_Less  - sscanf2
	ZeeX    - zcmd
	
	
	Also Obviously - The SA-MP Development Team.
	Last but not least - Anyone who uses this script :)
	
--------------------------------------------------------------------------------



WARNING!!!!!!!!!!!!!!!WARNING!!!!!!!!!!!!!!!WARNING!!!!!!!!!!!!!!!WARNING

It is highly advised you DO NOT load this filterscript while your server is running.
Unless the LOAD_ON_START define is commented, the server WILL hang for 2 - 6 seconds,
maybe even more those numbers were just the average on my tests.
2 - 3 Seconds if the animation database exists, and 5 - 6 seconds if the script
creates the database.

WARNING!!!!!!!!!!!!!!!WARNING!!!!!!!!!!!!!!!WARNING!!!!!!!!!!!!!!!
*/


#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <BUD>

// CONFIG //////////////////////////////////////////////////////////////////////

#define LOAD_ON_START// comment this to stop the script from reading and loading
                     // animation parameters in "OnFilerScriptInit.
					 // loading will hang the server for 2 - 6 seconds on my tests.
					 // approx 2 seconds if the database exists and approx 5 seconds if it doesn't.
					 
//#define ADD_RCON_PROTECTION //uncomment to enable rcon check on commands ( this is a must if your going to use on a public server )

////////////////////////////////////////////////////////////////////////////////
#undef INVALID_TEXT_DRAW
#define INVALID_TEXT_DRAW  			(Text:0xFFFF)

#define iAnim_zcmd          		(0)
#define iAnim_ycmd          		(1)

#define MAX_COMMAND_NAME        	(MAX_PLAYER_NAME)

#define MAX_ANIMS               	(1812)

#define SINGLE_SAVE_FILEPATH        ("iSavedAnimation.txt")
#define MULTI_SAVE_FILEPATH         ("iSavedAnimations.txt")
#define SAVED_ZCMD_ANIMS            ("iSavedZcmdAnimations.txt")
#define SAVED_YCMD_ANIMS            ("iSavedYcmdAnimations.txt")

#define IANIM_DEFAULT_TIME      	(5000)
#define IANIM_DEFAULT_SPEED     	(2.0)
#define IANIM_DEFAULT_LOOP      	(0)
#define IANIM_DEFAULT_LOCKX     	(1)
#define IANIM_DEFAULT_LOCKY     	(1)
#define IANIM_DEFAULT_FREEZE    	(0)
#define IANIM_DEFAULT_FORCESYNC 	(1)

#define IANIM_HELP_COLOR            (0xFFFF33AA)
#define IANIM_ORANGE                (0xFF8F00AA)

#define IANIM_ANIMINDEX_DIALOG      (1984)
#define IANIM_ANIMPARAM_DIALOG      (1985)
#define IANIM_ANIMVALUE_DIALOG      (1986)

#define SPEED_PARAM         		(1)
#define LOOP_PARAM                  (2)
#define LOCKX_PARAM         		(3)
#define LOCKY_PARAM 				(4)
#define FREEZE_PARAM  				(5)
#define TIME_PARAM                  (6)
#define FORCESYNC_PARAM             (7)

enum IANIM_DATA
{
	Float:iAnim_Speed,
	iAnim_Loop,
	iAnim_Lockx,
	iAnim_Locky,
	iAnim_Freeze,
	iAnim_Time,
	iAnim_ForceSync
}

new iAnim_AnimData[ MAX_ANIMS ][ IANIM_DATA ];

new bool:iAnim_PlayerUsingAnim[ MAX_PLAYERS char ];

new
	Text:AnimScrollText = INVALID_TEXT_DRAW,
	Text:AnimlibDisplay[ MAX_PLAYERS ] = {INVALID_TEXT_DRAW, ...};

public OnFilterScriptInit()
{
    BUD::Setting(opt.Database, "iAnims.db" );
	BUD::Setting(opt.Asynchronous, true );
	BUD::Setting(opt.KeepAliveTime, 3000 );
	BUD::Initialize();
	BUD::VerifyColumn("speed",		BUD::TYPE_FLOAT, IANIM_DEFAULT_SPEED);
	BUD::VerifyColumn("loop",		BUD::TYPE_NUMBER, IANIM_DEFAULT_LOOP);
    BUD::VerifyColumn("lockx",		BUD::TYPE_NUMBER, IANIM_DEFAULT_LOCKX);
    BUD::VerifyColumn("locky",		BUD::TYPE_NUMBER, IANIM_DEFAULT_LOCKY);
    BUD::VerifyColumn("freeze",		BUD::TYPE_NUMBER, IANIM_DEFAULT_FREEZE);
    BUD::VerifyColumn("time",		BUD::TYPE_NUMBER, IANIM_DEFAULT_TIME);
    BUD::VerifyColumn("forcesync",	BUD::TYPE_NUMBER, IANIM_DEFAULT_FORCESYNC);

#if defined LOAD_ON_START
    new
        dbstr[64];

    for(new i = 1; i < MAX_ANIMS; i++)
    {
        format(dbstr, sizeof( dbstr ), "Animation%d", i);
        if( !BUD::IsNameRegistered( dbstr ) )
        {
            BUD::RegisterName(dbstr, dbstr);
        	iAnim_AnimData[ i ][ iAnim_Speed ] 		= IANIM_DEFAULT_SPEED;
        	iAnim_AnimData[ i ][ iAnim_Loop ] 		= IANIM_DEFAULT_LOOP;
        	iAnim_AnimData[ i ][ iAnim_Lockx ]  	= IANIM_DEFAULT_LOCKX;
        	iAnim_AnimData[ i ][ iAnim_Locky ]  	= IANIM_DEFAULT_LOCKY;
        	iAnim_AnimData[ i ][ iAnim_Freeze ] 	= IANIM_DEFAULT_FREEZE;
        	iAnim_AnimData[ i ][ iAnim_Time ]   	= IANIM_DEFAULT_TIME;
        	iAnim_AnimData[ i ][ iAnim_ForceSync ] 	= IANIM_DEFAULT_FORCESYNC;
        }
        else
        {
            BUD::MultiGet( i , "fiiiiii",
        		"speed", 	iAnim_AnimData[ i ][ iAnim_Speed ],
        		"loop", 	iAnim_AnimData[ i ][ iAnim_Loop ],
        		"lockx", 	iAnim_AnimData[ i ][ iAnim_Lockx ],
        		"locky", 	iAnim_AnimData[ i ][ iAnim_Locky ],
        		"freeze", 	iAnim_AnimData[ i ][ iAnim_Freeze ],
        		"time",		iAnim_AnimData[ i ][ iAnim_Time ],
        		"forcesync",iAnim_AnimData[ i ][ iAnim_ForceSync ]
    		);
        }
    }
#endif
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	iAnim_PlayerUsingAnim{ playerid } = false;
	return 1;
}

public OnPlayerSpawn(playerid)
{
	PreloadAnimLib( playerid, "BOMBER");
	PreloadAnimLib( playerid, "RAPPING");
	PreloadAnimLib( playerid, "SHOP");
	PreloadAnimLib( playerid, "BEACH");
	PreloadAnimLib( playerid, "SMOKING");
	PreloadAnimLib( playerid, "FOOD");
	PreloadAnimLib( playerid, "ON_LOOKERS");
	PreloadAnimLib( playerid, "DEALER");
	PreloadAnimLib( playerid, "CRACK");
	PreloadAnimLib( playerid, "CARRY");
	PreloadAnimLib( playerid, "COP_AMBIENT");
	PreloadAnimLib( playerid, "PARK");
	PreloadAnimLib( playerid, "INT_HOUSE");
	PreloadAnimLib( playerid, "FOOD" );
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(GetPVarInt(playerid, "browsinganims") == 1)
	{
	    if(newkeys & KEY_ANALOG_LEFT)
	    {
	        new
 				animlib[32], animname[32];
	        if(GetPVarInt(playerid, "currentanim") == 1)
	        {
	            SetPVarInt(playerid, "currentanim", 1811);
	            GetAnimationName(GetPVarInt(playerid, "currentanim"), animlib, 32, animname, 32);
				ApplyAnimation(playerid , animlib , animname ,
					iAnim_AnimData[GetPVarInt(playerid, "currentanim")][iAnim_Speed],
					iAnim_AnimData[GetPVarInt(playerid, "currentanim")][iAnim_Loop],
					iAnim_AnimData[GetPVarInt(playerid, "currentanim")][iAnim_Lockx],
					iAnim_AnimData[GetPVarInt(playerid, "currentanim")][iAnim_Locky],
					iAnim_AnimData[GetPVarInt(playerid, "currentanim")][iAnim_Freeze],
					iAnim_AnimData[GetPVarInt(playerid, "currentanim")][iAnim_Time],
					iAnim_AnimData[GetPVarInt(playerid, "currentanim")][iAnim_ForceSync]
				);
				UpdateBrowseTextDraw(playerid);
	        }
	        else
	        {
	            SetPVarInt(playerid, "currentanim", GetPVarInt(playerid, "currentanim") - 1);
	            GetAnimationName(GetPVarInt(playerid, "currentanim"), animlib, 32, animname, 32);
				ApplyAnimation(playerid , animlib , animname ,
					iAnim_AnimData[GetPVarInt(playerid, "currentanim")][iAnim_Speed],
					iAnim_AnimData[GetPVarInt(playerid, "currentanim")][iAnim_Loop],
					iAnim_AnimData[GetPVarInt(playerid, "currentanim")][iAnim_Lockx],
					iAnim_AnimData[GetPVarInt(playerid, "currentanim")][iAnim_Locky],
					iAnim_AnimData[GetPVarInt(playerid, "currentanim")][iAnim_Freeze],
					iAnim_AnimData[GetPVarInt(playerid, "currentanim")][iAnim_Time],
					iAnim_AnimData[GetPVarInt(playerid, "currentanim")][iAnim_ForceSync]
				);
				UpdateBrowseTextDraw(playerid);
	        }
	    }
	    else if(newkeys & KEY_ANALOG_RIGHT)
	    {
	        new
 				animlib[32], animname[32];
	        if(GetPVarInt(playerid, "currentanim") == 1811)
	        {
	            SetPVarInt(playerid, "currentanim", 1);
	            GetAnimationName(GetPVarInt(playerid, "currentanim"), animlib, 32, animname, 32);
				ApplyAnimation(playerid , animlib , animname ,
					iAnim_AnimData[GetPVarInt(playerid, "currentanim")][iAnim_Speed],
					iAnim_AnimData[GetPVarInt(playerid, "currentanim")][iAnim_Loop],
					iAnim_AnimData[GetPVarInt(playerid, "currentanim")][iAnim_Lockx],
					iAnim_AnimData[GetPVarInt(playerid, "currentanim")][iAnim_Locky],
					iAnim_AnimData[GetPVarInt(playerid, "currentanim")][iAnim_Freeze],
					iAnim_AnimData[GetPVarInt(playerid, "currentanim")][iAnim_Time],
					iAnim_AnimData[GetPVarInt(playerid, "currentanim")][iAnim_ForceSync]
				);
				UpdateBrowseTextDraw(playerid);
	        }
	        else
	        {
	            SetPVarInt(playerid, "currentanim", GetPVarInt(playerid, "currentanim") + 1);
	            GetAnimationName(GetPVarInt(playerid, "currentanim"), animlib, 32, animname, 32);
				ApplyAnimation(playerid , animlib , animname ,
					iAnim_AnimData[GetPVarInt(playerid, "currentanim")][iAnim_Speed],
					iAnim_AnimData[GetPVarInt(playerid, "currentanim")][iAnim_Loop],
					iAnim_AnimData[GetPVarInt(playerid, "currentanim")][iAnim_Lockx],
					iAnim_AnimData[GetPVarInt(playerid, "currentanim")][iAnim_Locky],
					iAnim_AnimData[GetPVarInt(playerid, "currentanim")][iAnim_Freeze],
					iAnim_AnimData[GetPVarInt(playerid, "currentanim")][iAnim_Time],
					iAnim_AnimData[GetPVarInt(playerid, "currentanim")][iAnim_ForceSync]
				);
				UpdateBrowseTextDraw(playerid);
	        }
	    }
	    return 1;
	}
	if(iAnim_PlayerUsingAnim{ playerid } == true)
	{
 		ClearAnimations(playerid, 1);
   		ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0);
   		iAnim_PlayerUsingAnim{ playerid } = false;
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
 	switch(dialogid)
 	{
 	    case IANIM_ANIMINDEX_DIALOG:
 	    {
 	        if(response)
 	        {
 	            new
 	                iAnimIndex = strval(inputtext);
 	            if(iAnimIndex < 1 || iAnimIndex >= MAX_ANIMS)return SendClientMessage(playerid, 0xFF8433AA, "INVALID ANIMATION INDEX");
 	            else
 	            {
 	            	ShowPlayerDialog(playerid, IANIM_ANIMPARAM_DIALOG , DIALOG_STYLE_LIST , "{00FF00}Please Select A Parameter To Edit", "{FFCCFF}Speed \n{CCCCFF}Loop \n{99CCFF}Lockx \n{66CCFF}Locky \n\
	 					{33CCFF}Freeze \n{00CCFF}Time \n{33CCCC}ForceSync", "Accept", "Back");
	 				SetPVarInt(playerid, "editinganim", iAnimIndex);
	 				//show textdraw
	 				return 1;
					 
 	            }
 	        }
 	    }
 	    case IANIM_ANIMPARAM_DIALOG:
 	    {
 	        if(response)
	 		{
			 	switch(listitem)
			 	{
			 	    case 0: {//speed
			 	        SetPVarInt(playerid, "editingparam", SPEED_PARAM);
			 	        ShowPlayerDialog(playerid, IANIM_ANIMVALUE_DIALOG, DIALOG_STYLE_INPUT, "{00FF00}Please Enter A Value for Speed","{FF6666}Floating point number", "Enter", "Back");
			 	        return 1;
			 	    }
			 	    case 1://loop
					{
					    SetPVarInt(playerid, "editingparam", LOOP_PARAM);
		     			ShowPlayerDialog(playerid, IANIM_ANIMVALUE_DIALOG, DIALOG_STYLE_INPUT, "{00FF00}Please Enter A Value for Loop ","{00FF00}Expected values: {FF6666}0 - 1 ", "Enter", "Back");
						return 1;
					}
					case 2://lockx
					{
					    SetPVarInt(playerid, "editingparam", LOCKX_PARAM);
		     			ShowPlayerDialog(playerid, IANIM_ANIMVALUE_DIALOG, DIALOG_STYLE_INPUT, "{00FF00}Please Enter A Value for Lockx ","{00FF00}Expected values: {FF6666}0 - 1 ", "Enter", "Back");
						return 1;
					}
					case 3://locky
					{
					    SetPVarInt(playerid, "editingparam", LOCKY_PARAM);
		     			ShowPlayerDialog(playerid, IANIM_ANIMVALUE_DIALOG, DIALOG_STYLE_INPUT, "{00FF00}Please Enter A Value for Locky ","{00FF00}Expected values: {FF6666}0 - 1 ", "Enter", "Back");
						return 1;
					}
					case 4://freeze
					{
					    SetPVarInt(playerid, "editingparam", FREEZE_PARAM);
		     			ShowPlayerDialog(playerid, IANIM_ANIMVALUE_DIALOG, DIALOG_STYLE_INPUT, "{00FF00}Please Enter A Value for freeze ","{00FF00}Expected values: {FF6666}0 - 1 ", "Enter", "Back");
						return 1;
					}
					case 5://time
					{
					    SetPVarInt(playerid, "editingparam", TIME_PARAM);
		     			ShowPlayerDialog(playerid, IANIM_ANIMVALUE_DIALOG, DIALOG_STYLE_INPUT, "{00FF00}Please Enter A Value for time ","{00FF00}Time in milliseconds. '0' for infinite loop ", "Enter", "Back");
						return 1;
					}
					case 6://forcesync
					{
					    SetPVarInt(playerid, "editingparam", FORCESYNC_PARAM);
		     			ShowPlayerDialog(playerid, IANIM_ANIMVALUE_DIALOG, DIALOG_STYLE_INPUT, "{00FF00}Please Enter A Value for forcesync ","{00FF00}Expected values: {FF6666}0 - 1 ", "Enter", "Back");
						return 1;
					}
			 	}
	 		}
	 		else
	 		{
	 		    //show animindex dialog
	 		}
 	    }
 	    case IANIM_ANIMVALUE_DIALOG:
 	    {
 	        if(response)
 	        {
 	            switch(GetPVarInt(playerid, "editingparam"))
 	            {
 	                case SPEED_PARAM:
 	                {
 	                    new
 	                        Float:fdelta;
 	                        
 	                    if( sscanf( inputtext, "f", fdelta ) )
 	                    {
 	                        SendClientMessage(playerid, 0xFF8433AA, "| iAnim |: ERROR: You must enter a number.");
 	                        return 1;
 	                    }
 	                    else
 	                    {
 	                        iAnim_AnimData[ GetPVarInt(playerid, "editinganim") ][ iAnim_Speed ] = fdelta;
	        				SendClientMessage( playerid, IANIM_ORANGE, "| iAnim |: Animation changed." );
       						BUD::SetFloatEntry( GetPVarInt(playerid, "editinganim"), "speed", fdelta );
       						return 1;
 	                    }
 	                }
 	                case LOOP_PARAM:
 	                {
 	                    new
 	                        value = strval( inputtext );
 	                        
 	                    if(value < 0 || value > 1)
						 {
 	                        ShowPlayerDialog(playerid, IANIM_ANIMVALUE_DIALOG, DIALOG_STYLE_INPUT, "{00FF00}Please Enter A Value for Loop ","{00FF00}Expected values: {FF6666}0 - 1 ", "Enter", "Back");
 	                        SendClientMessage(playerid, 0xFF6666AA, "| iAnim Error |: Invalid value. Expected values for that parameter are 0 and 1");
 	                        return 1;
 	                    }
 	                    else
 	                    {
 	                        iAnim_AnimData[ GetPVarInt(playerid, "editinganim") ][ iAnim_Loop ] = value;
					        SendClientMessage(playerid, IANIM_ORANGE, "| iAnim |: Animation changed.");
					        BUD::SetIntEntry( GetPVarInt(playerid, "editinganim") , "loop", value );
					        return 1;
 	                    }
 	                }
 	                case LOCKX_PARAM:
 	                {
                  		new
                    		value = strval( inputtext );

 	                    if(value < 0 || value > 1)
						{
						    ShowPlayerDialog(playerid, IANIM_ANIMVALUE_DIALOG, DIALOG_STYLE_INPUT, "{00FF00}Please Enter A Value for Lockx ","{00FF00}Expected values: {FF6666}0 - 1 ", "Enter", "Back");
 	                        SendClientMessage(playerid, 0xFF6666AA, "| iAnim Error |: Invalid value. Expected values for that parameter are 0 and 1");
 	                        return 1;
						}
						else
						{
						    iAnim_AnimData[ GetPVarInt(playerid, "editinganim") ][ iAnim_Lockx ] = value;
					        SendClientMessage(playerid, IANIM_ORANGE, "| iAnim |: Animation changed.");
					        BUD::SetIntEntry( GetPVarInt(playerid, "editinganim"), "lockx", value );
					        return 1;
						}
 	                }
 	                case LOCKY_PARAM:
 	                {
 	                    new
                    		value = strval( inputtext );

 	                    if(value < 0 || value > 1)
						{
						    ShowPlayerDialog(playerid, IANIM_ANIMVALUE_DIALOG, DIALOG_STYLE_INPUT, "{00FF00}Please Enter A Value for Locky ","{00FF00}Expected values: {FF6666}0 - 1 ", "Enter", "Back");
 	                        SendClientMessage(playerid, 0xFF6666AA, "| iAnim Error |: Invalid value. Expected values for that parameter are 0 and 1");
 	                        return 1;
						}
						else
						{
						    iAnim_AnimData[ GetPVarInt(playerid, "editinganim") ][ iAnim_Locky ] = value;
					        SendClientMessage(playerid, IANIM_ORANGE, "| iAnim |: Animation changed.");
					        BUD::SetIntEntry( GetPVarInt(playerid, "editinganim"), "locky", value );
					        return 1;
						}
 	                }
 	                case FREEZE_PARAM:
 	                {
 	                    new
                    		value = strval( inputtext );

 	                    if(value < 0 || value > 1)
						{
						    ShowPlayerDialog(playerid, IANIM_ANIMVALUE_DIALOG, DIALOG_STYLE_INPUT, "{00FF00}Please Enter A Value for freeze ","{00FF00}Expected values: {FF6666}0 - 1 ", "Enter", "Back");
 	                        SendClientMessage(playerid, 0xFF6666AA, "| iAnim Error |: Invalid value. Expected values for that parameter are 0 and 1");
 	                        return 1;
						}
						else
						{
						   	iAnim_AnimData[ GetPVarInt(playerid, "editinganim") ][ iAnim_Freeze ] = value;
					        SendClientMessage(playerid, IANIM_ORANGE, "| iAnim |: Animation changed.");
					        BUD::SetIntEntry( GetPVarInt(playerid, "editinganim"), "freeze", value );
					        return 1;
						}
 	                }
 	                case TIME_PARAM:
 	                {
 	                    new
                    		value = strval( inputtext );

 	                    if(value < 0 || value > 30000)
						{
						    ShowPlayerDialog(playerid, IANIM_ANIMVALUE_DIALOG, DIALOG_STYLE_INPUT, "{00FF00}Please Enter A Value for time ","{00FF00}Time in milliseconds. '0' for infinite loop", "Enter", "Back");
 	                        SendClientMessage(playerid, 0xFF6666AA, "| iAnim Error |: Invalid value. Expected values for that parameter are 0 to 30000");
 	                        return 1;
						}
						else
						{
						   	iAnim_AnimData[ GetPVarInt(playerid, "editinganim") ][ iAnim_Time ] = value;
					        SendClientMessage(playerid, IANIM_ORANGE, "| iAnim |: Animation changed.");
					        BUD::SetIntEntry( GetPVarInt(playerid, "editinganim"), "time", value );
					        return 1;
						}
 	                }
 	                case FORCESYNC_PARAM:
 	                {
 	                    new
                    		value = strval( inputtext );

 	                    if(value < 0 || value > 1)
						{
						    ShowPlayerDialog(playerid, IANIM_ANIMVALUE_DIALOG, DIALOG_STYLE_INPUT, "{00FF00}Please Enter A Value for forcesync ","{00FF00}Expected values: {FF6666}0 - 1 ", "Enter", "Back");
 	                        SendClientMessage(playerid, 0xFF6666AA, "| iAnim Error |: Invalid value. Expected values for that parameter are 0 and 1");
 	                        return 1;
						}
						else
						{
						   	iAnim_AnimData[ GetPVarInt(playerid, "editinganim") ][ iAnim_ForceSync ] = value;
					        SendClientMessage(playerid, IANIM_ORANGE, "| iAnim |: Animation changed.");
					        BUD::SetIntEntry( GetPVarInt(playerid, "editinganim"), "forcesync", value );
					        return 1;
						}
 	                }
 	            }
 	        }
 	        else
 	        {
 	            //show animparam dialog
 	        }
 	    }
 	}
    return 1;
}

COMMAND:animconfig(playerid, params[])
{
	ShowPlayerDialog(playerid, IANIM_ANIMINDEX_DIALOG, DIALOG_STYLE_INPUT, "{00FF00}Please Enter An Animation Index", " ", "Accept" , "Close");
	return 1;
}

COMMAND:animhelp(playerid, params[])
{
	#if defined ADD_RCON_PROTECTION
	    if(!IsPlayerAdmin(playerid))
	    	return 1;
	#endif
	
	SendClientMessage( playerid, 0xFFFFFFAA, "========================= {FFA366}iAnim Commands {FFFFFF}=========================");
	SendClientMessage( playerid, 0xFFFF33AA, "/ianim [animation index]. - Browse through anims (1 - 1811)");
	SendClientMessage( playerid, 0xFFFF33AA, "/editanim [animation index][animation parameter][value]");
	SendClientMessage( playerid, 0xFFFF33AA, "/animspeed [animationindex][value]. - ( for higher precision speed )");
	SendClientMessage( playerid, 0xFFFF33AA, "/saveanim [animationindex][comment]. - leave comment for identification.");
	SendClientMessage( playerid, 0xFFFF33AA, "/saveallanims. - Will save all animations to iSavedAnimations.txt");
	SendClientMessage( playerid, 0xFFFF33AA, "/saveanimcommand [animationindex][command processor][commandname]");
	SendClientMessage( playerid, 0xFF6666AA, "NOTE: Valid command processors are zcmd and ycmd.");
	SendClientMessage( playerid, 0xFF6666AA, "Alternate names: /saa ( /saveallanims ). /sac ( /saveanimcommand )");
	SendClientMessage( playerid, 0xFFFFFFAA, "==================================================================");
	return 1;
}

COMMAND:ianim(playerid, params[])
{
    #if defined ADD_RCON_PROTECTION
	    if(!IsPlayerAdmin(playerid))
	    	return 1;
	#endif
	new
 		animlib[32], animname[32],
	    iAnimIndex = strval(params);
    if(iAnimIndex < 1 || iAnimIndex >= MAX_ANIMS)return SendClientMessage(playerid, 0xFF8433AA, "INVALID ANIMATION INDEX");
    else
    {
		SetPVarInt(playerid, "currentanim", iAnimIndex);
		UpdateBrowseTextDraw(playerid);
		GetAnimationName(iAnimIndex, animlib, 32, animname, 32);
		ApplyAnimation(playerid , animlib , animname ,
			iAnim_AnimData[iAnimIndex][iAnim_Speed],
			iAnim_AnimData[iAnimIndex][iAnim_Loop],
			iAnim_AnimData[iAnimIndex][iAnim_Lockx],
			iAnim_AnimData[iAnimIndex][iAnim_Locky],
			iAnim_AnimData[iAnimIndex][iAnim_Freeze],
			iAnim_AnimData[iAnimIndex][iAnim_Time],
			iAnim_AnimData[iAnimIndex][iAnim_ForceSync]
		);
		iAnim_PlayerUsingAnim{ playerid } = true;
	}
	return 1;
}

COMMAND:editanim(playerid, params[])
{
    #if defined ADD_RCON_PROTECTION
	    if(!IsPlayerAdmin(playerid))
	    	return 1;
	#endif
	new
	    iAnimIndex, animparam[15], newvalue;

	if(sscanf(params, "ds[15]d", iAnimIndex, animparam, newvalue)) {
	    SendClientMessage(playerid, IANIM_ORANGE, "|iAnims|: Usage /editanim [animindex][animparam][newvalue]");
	    SendClientMessage(playerid, IANIM_ORANGE, "|iAnims|: Example usage /editanim 100 loop 1");
	}
	else if(iAnimIndex < 1 || iAnimIndex >= MAX_ANIMS)return SendClientMessage(playerid, 0xFF8433AA, "INVALID ANIMATION INDEX");
	else {

	    if(!strcmp(animparam, "speed", true, 3) || !strcmp(animparam, "fdelta", true)) {
	        iAnim_AnimData[ iAnimIndex ][ iAnim_Speed ] = newvalue;
	        SendClientMessage( playerid, IANIM_ORANGE, "| iAnim |: Animation changed." );
	        BUD::SetIntEntry( iAnimIndex, "speed", newvalue );
	        return 1;
	    }
	    else if(!strcmp(animparam, "loop", true, 3)) {
	        if(newvalue < 0 || newvalue > 1)return SendClientMessage(playerid, 0xFF8433AA, "| iAnim |: ERROR: Expected values are 0 - 1 (off/on)");
	        iAnim_AnimData[ iAnimIndex ][ iAnim_Loop ] = newvalue;
	        SendClientMessage(playerid, IANIM_ORANGE, "| iAnim |: Animation changed.");
	        BUD::SetIntEntry( iAnimIndex, "loop", newvalue );
	        return 1;
 		}
	    else if(!strcmp(animparam, "lockx", true)) {
	        if(newvalue < 0 || newvalue > 1)return SendClientMessage(playerid, 0xFF8433AA, "| iAnim |: ERROR: Expected values are 0 - 1 (off/on)");
	        iAnim_AnimData[ iAnimIndex ][ iAnim_Lockx ] = newvalue;
	        SendClientMessage(playerid, IANIM_ORANGE, "| iAnim |: Animation changed.");
	        BUD::SetIntEntry( iAnimIndex, "lockx", newvalue );
	        return 1;
	    }
	    else if(!strcmp(animparam, "locky", true)) {
	        if(newvalue < 0 || newvalue > 1)return SendClientMessage(playerid, 0xFF8433AA, "| iAnim |: ERROR: Expected values are 0 - 1 (off/on)");
	        iAnim_AnimData[ iAnimIndex ][ iAnim_Locky ] = newvalue;
	        SendClientMessage(playerid, IANIM_ORANGE, "| iAnim |: Animation changed.");
	        BUD::SetIntEntry( iAnimIndex, "locky", newvalue );
	        return 1;
   		}
	    else if(!strcmp(animparam, "freeze", true, 3)) {
	        if(newvalue < 0 || newvalue > 1)return SendClientMessage(playerid, 0xFF8433AA, "| iAnim |: ERROR: Expected values are 0 - 1 (off/on)");
	        iAnim_AnimData[ iAnimIndex ][ iAnim_Freeze ] = newvalue;
	        SendClientMessage(playerid, IANIM_ORANGE, "| iAnim |: Animation changed.");
	        BUD::SetIntEntry( iAnimIndex, "freeze", newvalue );
	        return 1;
	    }
	    else if(!strcmp(animparam, "time", true, 2)) {
	        if(newvalue < 0 || newvalue > 60000)return SendClientMessage(playerid, 0xFF8433AA, "| iAnim |: ERROR: Expected values are 0 - 60000 ( use '0' for a continuous loop )");
	        iAnim_AnimData[ iAnimIndex ][ iAnim_Time ] = newvalue;
	        SendClientMessage(playerid, IANIM_ORANGE, "| iAnim |: Animation changed.");
	        BUD::SetIntEntry( iAnimIndex, "time", newvalue );
	        return 1;
	    }
	    else if(!strcmp(animparam, "forcesync", true, 2)) {
	        if(newvalue < 0 || newvalue > 1)return SendClientMessage(playerid, 0xFF8433AA, "| iAnim |: ERROR: Expected values are 0 - 1 (off/on)");
	        iAnim_AnimData[ iAnimIndex ][ iAnim_ForceSync ] = newvalue;
	        SendClientMessage(playerid, IANIM_ORANGE, "| iAnim |: Animation changed.");
	        BUD::SetIntEntry( iAnimIndex, "forcesync", newvalue );
	        return 1;
	    }
	    else
	        SendClientMessage(playerid, 0xFF8433AA, "| iAnim |: ERROR: Invalid parameter name.");
	}
	return 1;
}

COMMAND:animspeed(playerid, params[])
{
    #if defined ADD_RCON_PROTECTION
	    if(!IsPlayerAdmin(playerid))
	    	return 1;
	#endif
	new
	 	iAnimIndex,
	    Float:fdelta;
	if(sscanf(params, "df", iAnimIndex, fdelta)) {
	    SendClientMessage( playerid, 0xFF3333AA, "ERROR: Usage /animspeed [Float: speed]." );
	    SendClientMessage( playerid, 0xFF3333AA, "Good speeds are 0.1 - 10.0" );
	    return 1;
	}
	else {
	    iAnim_AnimData[ iAnimIndex ][ iAnim_Speed ] = fdelta;
      	BUD::SetFloatEntry( iAnimIndex, "speed", fdelta );
      	SendClientMessage( playerid, IANIM_ORANGE, "| iAnim |: Animation changed." );
	}
	return 1;
}

COMMAND:saveallanims(playerid, params[])
{
    #if defined ADD_RCON_PROTECTION
	    if(!IsPlayerAdmin(playerid))
	    	return 1;
	#endif
    iSaveAllAnimsToFile();
    SendClientMessage(playerid, IANIM_ORANGE, "| iAnim |: All animations saved to iSavedAnimations.txt");
	return 1;
}
COMMAND:saa(playerid, params[]) {
	return cmd_saveallanims(playerid, params);
}

COMMAND:saveanim(playerid, params[])
{
    #if defined ADD_RCON_PROTECTION
	    if(!IsPlayerAdmin(playerid))
	    	return 1;
	#endif
	new
	    iAnimIndex,
		comment[64];

	if(sscanf(params, "dS(iAnims)[64]", iAnimIndex, comment))
	    SendClientMessage(playerid, 0xFF5C67AA, "ERROR: Usage /saveanim [AnimIndex][comment]");
	else {
	    iSaveAnimToFile(iAnimIndex, comment);
	    SendClientMessage(playerid, IANIM_ORANGE, "| iAnims |: Animation saved to iSavedAnimation.txt");
	}
	return 1;
}

COMMAND:saveanimcommand(playerid, params[])
{
    #if defined ADD_RCON_PROTECTION
	    if(!IsPlayerAdmin(playerid))
	    	return 1;
	#endif
	new
	    iAnimIndex,
	    iCommandProcessor[5],
	    zCommandName[MAX_COMMAND_NAME];
	if(sscanf(params, "ds[5]s[26]", iAnimIndex, iCommandProcessor, zCommandName))
		SendClientMessage(playerid, 0xFF3333AA, "ERROR: Usage /saveanimcommand [animindex][zcmd/ycmd][commandname]");
	else {
	    if(iAnimIndex >= MAX_ANIMS || iAnimIndex < 1)return SendClientMessage(playerid, 0xFF3333AA, "ERROR: Invalid animation index. (1 - 1811)");
	    if(!strcmp(iCommandProcessor, "zcmd", true)) {
	        SaveAnimAsCommand( iAnimIndex, iAnim_zcmd , zCommandName);
         	SendClientMessage(playerid, IANIM_ORANGE, "| iAnims |: zcmd command saved to iSavedZcmdAnimations.txt.");
	        return 1;
	    }
	    else if(!strcmp(iCommandProcessor, "ycmd", true)) {
	        SaveAnimAsCommand( iAnimIndex, iAnim_ycmd , zCommandName);
	        SendClientMessage(playerid, IANIM_ORANGE, "| iAnims |: ycmd command saved to iSavedYcmdAnimations.txt.");
	        return 1;
	    }
	    else
	        SendClientMessage(playerid, 0xFF3333AA, "ERROR: Invalid command processor. Options: ycmd/zcmd.");
	}
	return 1;
}
COMMAND:sac(playerid, params[]) {
	return cmd_saveanimcommand(playerid, params);
}

COMMAND:browseanims(playerid, params[])
{
    #if defined ADD_RCON_PROTECTION
	    if(!IsPlayerAdmin(playerid))
	    	return 1;
	#endif
	
	if(GetPVarInt(playerid, "browsinganims") == 1) {
		DeletePVar(playerid, "browsinganims");
	    SetCameraBehindPlayer(playerid);
	    TogglePlayerControllable(playerid, true);
	    SendClientMessage(playerid, IANIM_ORANGE, "| iAnim |: Finished browsing animations");
	    HidePlayerBrowseTextDraws(playerid);
	    return 1;
	}
	else
	{
	
		new
	    	Float:pX, Float:pY, Float:pZ,
	    	Float:cX, Float:cY, Float:cZ;
	    
		GetPlayerPos(playerid, pX, pY, pZ);
 		GetXYZInFrontOfPlayer(playerid, 8.0, cX, cY, cZ);
 		SetPlayerCameraPos(playerid, cX, cY, cZ + 0.5);
 		SetPlayerCameraLookAt(playerid, pX, pY, pZ);
 		TogglePlayerControllable(playerid, false);
 		SendClientMessage(playerid, IANIM_ORANGE, "| iAnim |: Use /browseanims or /ba. To set the camera back to nornal.");
 		SetPVarInt(playerid, "browsinganims", 1);
 		ShowPlayerBrowseTextDraws(playerid);
 		ApplyAnimation( playerid, "AIRPORT" , "THRW_BARL_THRW" , 4.0 , 0 , 1 , 1 , 0 , 5000 , 1);
 	}
	return 1;
}
COMMAND:ba(playerid, params[]) {
	return cmd_browseanims(playerid, params);
}

iSaveAnimToFile(iAnimIndex, zComment[])
{
	new
	    finput[100],
	    animlib[32], animname[32],
		File:AnimFile = fopen( SINGLE_SAVE_FILEPATH , io_append);
		
	format(finput, sizeof(finput), "ApplyAnimation( playerid, \"%s\" , \"%s\" , %.1f , %d , %d , %d , %d , %d , %d);//%s\r\n" ,
		animlib , animname ,
		iAnim_AnimData[ iAnimIndex ][ iAnim_Speed ]  , iAnim_AnimData[ iAnimIndex ][ iAnim_Loop  ] ,
		iAnim_AnimData[ iAnimIndex ][ iAnim_Lockx ]  , iAnim_AnimData[ iAnimIndex ][ iAnim_Locky ] ,
		iAnim_AnimData[ iAnimIndex ][ iAnim_Freeze ] , iAnim_AnimData[ iAnimIndex ][ iAnim_Time  ] ,
		iAnim_AnimData[ iAnimIndex ][ iAnim_ForceSync ], zComment
	);
	fwrite( AnimFile, finput );
	fclose( AnimFile );
}

iSaveAllAnimsToFile()
{
	if(fexist( MULTI_SAVE_FILEPATH ))
		fremove( MULTI_SAVE_FILEPATH );
    new
        count,
        finput[500],
        animlib[32], animname[32],
		File:AnimFile = fopen( MULTI_SAVE_FILEPATH , io_append );
/*	new
	    result;
		ticks = GetTickCount();*/
	for( new iAnimIndex = 1; iAnimIndex < MAX_ANIMS; iAnimIndex++ )
	{
	    count++;
	    GetAnimationName( iAnimIndex, animlib, 32, animname, 32 );
	    if( count == 5 )
	    {
	        format(finput, sizeof(finput), "%sApplyAnimation( playerid, \"%s\" , \"%s\" , %.1f , %d , %d , %d , %d , %d , %d);\r\n" ,
				finput, animlib , animname ,
				iAnim_AnimData[ iAnimIndex ][ iAnim_Speed ]  , iAnim_AnimData[ iAnimIndex ][ iAnim_Loop ] ,
				iAnim_AnimData[ iAnimIndex ][ iAnim_Lockx ]  , iAnim_AnimData[ iAnimIndex ][ iAnim_Locky ] ,
				iAnim_AnimData[ iAnimIndex ][ iAnim_Freeze ] , iAnim_AnimData[ iAnimIndex ][ iAnim_Time ] ,
				iAnim_AnimData[ iAnimIndex ][ iAnim_ForceSync ]
			);
			fwrite( AnimFile, finput );
			strdel( finput, 0, sizeof( finput ) );
			count = 0;
	    }
	    else
	    {
	        format(finput, sizeof(finput), "%sApplyAnimation( playerid, \"%s\" , \"%s\" , %.1f , %d , %d , %d , %d , %d , %d);\r\n" ,
				finput, animlib , animname ,
				iAnim_AnimData[ iAnimIndex ][ iAnim_Speed ]  , iAnim_AnimData[ iAnimIndex ][ iAnim_Loop ] ,
				iAnim_AnimData[ iAnimIndex ][ iAnim_Lockx ]  , iAnim_AnimData[ iAnimIndex ][ iAnim_Locky ] ,
				iAnim_AnimData[ iAnimIndex ][ iAnim_Freeze ] , iAnim_AnimData[ iAnimIndex ][ iAnim_Time ] ,
				iAnim_AnimData[ iAnimIndex ][ iAnim_ForceSync ]
			);
	    }
	}
	fwrite( AnimFile, finput );
	fclose( AnimFile );
/*	result = GetTickCount() - ticks;
	printf("It Took %d milliseconds to save 1811 animations!", result);  */
}

PreloadAnimLib( playerid, animlib[] )//credit to kyeman
{
	ApplyAnimation( playerid, animlib , "null" ,0.0,0,0,0,0,0 );
}

SaveAnimAsCommand( iAnimIndex, iCommandProcessor , zCommandName[] )
{
	switch( iCommandProcessor )
	{
	    case iAnim_zcmd:
	    {
	        new
	            finput[200],
	            animlib[32], animname[32],
	            File:AnimFile = fopen( SAVED_ZCMD_ANIMS , io_append );
	        GetAnimationName( iAnimIndex, animlib, 32, animname, 32 );
	        
	        format( finput, sizeof( finput ),"ApplyAnimation( playerid, \"%s\" , \"%s\" , %.1f , %d , %d , %d , %d , %d , %d);" ,
 				animlib , animname ,
				iAnim_AnimData[ iAnimIndex ][ iAnim_Speed ]  , iAnim_AnimData[ iAnimIndex ][ iAnim_Loop ] ,
				iAnim_AnimData[ iAnimIndex ][ iAnim_Lockx ]  , iAnim_AnimData[ iAnimIndex ][ iAnim_Locky ] ,
				iAnim_AnimData[ iAnimIndex ][ iAnim_Freeze ] , iAnim_AnimData[ iAnimIndex ][ iAnim_Time ] ,
				iAnim_AnimData[ iAnimIndex ][ iAnim_ForceSync ]
			);
			
	        format( finput, sizeof( finput ), "COMMAND:%s(playerid, params[])\r\n{\r\n    %s\r\n    return 1;\r\n}\r\n\r\n", zCommandName , finput);
	        fwrite( AnimFile, finput );
	        fclose( AnimFile );
	    }
	    case iAnim_ycmd:
	    {
	        new
	            finput[250],
	            animlib[32], animname[32],
	            File:AnimFile = fopen( SAVED_YCMD_ANIMS , io_append );
	        GetAnimationName( iAnimIndex, animlib, 32, animname, 32 );

	        format( finput, sizeof( finput ),"ApplyAnimation( playerid, \"%s\" , \"%s\" , %.1f , %d , %d , %d , %d , %d , %d);" ,
 				animlib , animname ,
				iAnim_AnimData[ iAnimIndex ][ iAnim_Speed ]  , iAnim_AnimData[ iAnimIndex ][ iAnim_Loop ] ,
				iAnim_AnimData[ iAnimIndex ][ iAnim_Lockx ]  , iAnim_AnimData[ iAnimIndex ][ iAnim_Locky ] ,
				iAnim_AnimData[ iAnimIndex ][ iAnim_Freeze ] , iAnim_AnimData[ iAnimIndex ][ iAnim_Time ] ,
				iAnim_AnimData[ iAnimIndex ][ iAnim_ForceSync ]
			);

	        format( finput, sizeof( finput ), "YCMD:%s(playerid, params[], help)\r\n{\r\n    if(help)\r\n    {\r\n        //helptext here\r\n    }\r\n    \
			else\r\n    {\r\n        %s\r\n    }\r\n    return 1;\r\n}\r\n\r\n", zCommandName , finput);
	        fwrite( AnimFile, finput );
	        fclose( AnimFile );
	    }
	}
}

GetXYZInFrontOfPlayer(playerid, Float:range = 1.0, &Float:x, &Float:y, &Float:z)
{
	new
		Float:fPX, Float:fPY, Float:fPZ,
		Float:fVX, Float:fVY, Float:fVZ;

	GetPlayerCameraPos(playerid, fPX, fPY, fPZ);
	GetPlayerCameraFrontVector(playerid, fVX, fVY, fVZ);

	x = fPX + floatmul(fVX, range);
	y = fPY + floatmul(fVY, range);
	z = fPZ + floatmul(fVZ, range);
}

ShowPlayerBrowseTextDraws(playerid)
{
	AnimScrollText = TextDrawCreate(86.000000 + 10.0, 303.000000, "~g~Press ~r~NUM4 ~g~and ~r~NUM6~n~~g~To Browse Through~n~Animations");
	TextDrawAlignment(AnimScrollText, 2);
	TextDrawFont(AnimScrollText, 1);
	TextDrawLetterSize(AnimScrollText, 0.500000, 1.000000);
	TextDrawColor(AnimScrollText, -1);
	TextDrawSetOutline(AnimScrollText, 0);
	TextDrawSetProportional(AnimScrollText, 1);
	TextDrawSetShadow(AnimScrollText, 1);
	TextDrawShowForPlayer(playerid, AnimScrollText);
	
	new
	    textstr[100],
	    animlib[32], animname[32];
    GetAnimationName( GetPVarInt(playerid, "editinganim"), animlib, 32, animname, 32);
	format(textstr, sizeof( textstr ), "~g~AnimLib: ~r~%s~n~~g~AnimName: ~r~%s~n~INDEX: %d", animlib, animname, GetPVarInt(playerid, "currentanim"));
	AnimlibDisplay[ playerid ] = TextDrawCreate(10.000000, 259.000000, textstr);
	TextDrawBackgroundColor(AnimlibDisplay[ playerid ], 255);
	TextDrawFont(AnimlibDisplay[ playerid ], 2);
	TextDrawLetterSize(AnimlibDisplay[ playerid ], 0.230000, 1.100000);
	TextDrawColor(AnimlibDisplay[ playerid ], -1);
	TextDrawSetOutline(AnimlibDisplay[ playerid ], 0);
	TextDrawSetProportional(AnimlibDisplay[ playerid ], 1);
	TextDrawSetShadow(AnimlibDisplay[ playerid ], 1);
	TextDrawShowForPlayer(playerid, AnimlibDisplay[ playerid ] );
}

HidePlayerBrowseTextDraws(playerid)
{
	TextDrawHideForPlayer(playerid, AnimScrollText);
	TextDrawHideForPlayer(playerid, AnimlibDisplay[ playerid ]);
	AnimlibDisplay[ playerid ] = INVALID_TEXT_DRAW;
}

UpdateBrowseTextDraw(playerid)
{
	new
	    textstr[100],
	    animlib[32], animname[32];
	GetAnimationName( GetPVarInt(playerid, "currentanim"), animlib, 32, animname, 32);
	format(textstr, sizeof( textstr ), "~g~AnimLib: ~r~%s~n~~g~AnimName: ~r~%s ~n~~g~INDEX: ~r~%d", animlib, animname, GetPVarInt(playerid, "currentanim"));
	TextDrawSetString(AnimlibDisplay[ playerid ], textstr);
}
