#include <a_samp> // Credits To SAMP Team
#include <streamer> // Credits To Incognito
#include <j_fader> // Credits To Joestaff

new Text3D:FreeCandy[MAX_VEHICLES],v_ID;
new PedoCheck;
new pFadeComplete[MAX_PLAYERS];

//-------------------------------------------------

public OnFilterScriptInit()
{
    FadeInit();
    v_ID = CreateVehicle(418,305.70001221,-1868.90002441,3.00000000,90.00000000,126,126,-1);
    FreeCandy[v_ID] = Create3DTextLabel( "Free Candy", 0xFF69B4FF, 0.0, 0.0, 0.0, 50.0, 0, 1 );
    Attach3DTextLabelToVehicle( FreeCandy[v_ID] , v_ID, 0.0, 0.0, 2.0);
	return 1;
}

//-------------------------------------------------

public OnFilterScriptExit()
{
	FadeExit();
    Delete3DTextLabel(FreeCandy[v_ID]);
	return 1;
}

//-------------------------------------------------

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
    if(vehicleid == v_ID)
    {
    	SetVehicleParamsForPlayer(v_ID,playerid,0,1);
    }
    return 1;
}

//-------------------------------------------------

public OnPlayerConnect(playerid)
{
    FadePlayerConnect(playerid);
    SendClientMessageToAll(-1,"This Script Is Using Pedo-Phile Candy Giveaway By Littlehelper[MDZ]");
	PedoCheck = CreateDynamicCP(306.1897,-1864.3198,2.9359,3,-1,-1,-1,100.0);
	return 1;
}

//-------------------------------------------------

public OnPlayerDisconnect(playerid)
{
    FadePlayerDisconnect(playerid);
  	return 1;
}

//-------------------------------------------------
public OnPlayerEnterDynamicCP(playerid, checkpointid)
{
	if(checkpointid == PedoCheck)
	{
	    ShowPlayerDialog(playerid,250,DIALOG_STYLE_INPUT,"{FF00EA}Free Candy Give-Away","{FF00EA}What's Your Age?\n{FF00EA}Input Below","Okay","");
 	}
	return 1;
}

//-------------------------------------------------

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        case 250:
        {
            if(response)
            {
                new value = strval(inputtext);
                if(value < 1 || value > 12) return ShowPlayerDialog(playerid,250,DIALOG_STYLE_INPUT,"{FF00EA}Free Candy Give-Away","{FF00EA}What's Your Age?\n{FF00EA}You're Age Must Be Between 1-12!","Okay","");
                PutPlayerInVehicle(playerid,v_ID,3);
                SendClientMessage(playerid,-1,"Here's Some Candy, Now Get In The Van!");
                TogglePlayerControllable(playerid, 0);
                pFadeComplete[playerid] = 1;
                FadeColorForPlayer(playerid,255,0,0,0,255,0,0,255,100,10);
                }
       	  }
    }
    return 1;
}

//-------------------------------------------------

public OnFadeComplete(playerid,beforehold)
{
	if(beforehold)
	{
	    switch(pFadeComplete[playerid])
	    {
			case 1:
			{
				pFadeComplete[playerid] = 2;
  				FadeColorForPlayer(playerid,255,0,0,0,255,0,0,255,100,10);
			}
			case 2:
			{
			    pFadeComplete[playerid] = 3;
				FadeColorForPlayer(playerid,255,0,0,0,255,0,0,255,100,10);
			}
			case 3:
			{
			    pFadeComplete[playerid] = 0;
				FadeColorForPlayer(playerid,0,0,0,255,0,0,0,0,15,0);
				new szString[128],pName[24];
				GetPlayerName(playerid,pName,sizeof(pName));
				format(szString,sizeof(szString),"[NEWS]: It Has Been Confirmed That %s Has Been Fatally Plus Brutally Raped By Pedo-Bear!",pName);
				new Float:x,Float:y,Float:z;
    			RemovePlayerFromVehicle(playerid);
   			 	GetPlayerPos(playerid,x,y,z);
    			SetPlayerPos(playerid,1178.0436,-1323.6395,14.1006);
    			SetPlayerFacingAngle(playerid,270.1267);
				TogglePlayerControllable(playerid,1);
				SendClientMessageToAll(0xFF69B4FF,szString);
				SendClientMessage(playerid,-1,">> Pm From Pedobear : Visit Me Again For Free Candy!");
			}
		}
	}
	return 1;
}

//-------------------------------------------------

//-------------------------------------------------
