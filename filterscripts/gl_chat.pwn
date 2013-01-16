//
//
//  SA-MP Roleplay style chat module for Grand Larceny
//  (c) 2012 SA-MP Team
//   All rights reserved
//

#include <a_samp>
#include "../include/gl_common.inc"
#include "../include/gl_messages.inc" // <- contains all the main text/messaging functions

//---------------------------------------------

stock ProcessChatText(playerid, text[])
{
	new useindex=1;

    // Handle shouting prefix (!)
	if(text[0] == '!' && strlen(text) > 1) {
	    if(text[1] == ' ') useindex++;
     	TalkMessage(SHOUT_DISTANCE, playerid, "*shouts*", text[useindex]);
     	return;
	}

	// Handle quiet prefix (#)
	if(text[0] == '#' && strlen(text) > 1) {
	    if(text[1] == ' ') useindex++;
     	TalkMessage(LOW_DISTANCE, playerid, "*quietly*", text[useindex]);
     	return;
	}

	// Send to other players in range and fade
	TalkMessage(TALK_DISTANCE, playerid, "", text);
}

//---------------------------------------------

stock ProcessActionText(playerid, message[], actiontype)
{
    new ActionText[256+1];
    new ActionBubble[MAX_CHATBUBBLE_LENGTH+1];
    new PlayerName[MAX_PLAYER_NAME+1];

    GetPlayerName(playerid, PlayerName, sizeof(PlayerName));

	if(actiontype == ACTION_DO) {
		format(ActionText, 256, "* %s ((%s))", message, PlayerName);
		format(ActionBubble, MAX_CHATBUBBLE_LENGTH, "* (( %s ))", message);
	} else {
	    format(ActionText, 256, "* %s %s", PlayerName, message);
	    format(ActionBubble, MAX_CHATBUBBLE_LENGTH, "* %s", message);
	}
	
    LocalMessage(ACTION_DISTANCE, playerid, ACTION_COLOR, ActionText);
   	SetPlayerChatBubble(playerid, ActionBubble, ACTION_COLOR, ACTION_DISTANCE, CHAT_BUBBLE_TIME);
}

//---------------------------------------------

new gOOCDisabled = false;

stock GlobalOOCMessage(playerid, message[])
{
	new msg[256+1];
	new PlayerName[MAX_PLAYER_NAME+1];

	if(gOOCDisabled) {
		CmdErrorMessage(playerid, "The OOC channel is not enabled right now");
		return;
	}

	GetPlayerName(playerid, PlayerName, sizeof(PlayerName));
	format(msg, 256, "(( %s: %s ))", PlayerName, message);

	for(new i = 0; i < MAX_PLAYERS; i++) { // for every player
		if(IsPlayerConnected(i)) { // Todo: check if player accepts occ
		    PlayerMessage(i, OOC_COLOR, msg);
		}
	}
}

//---------------------------------------------

stock ToggleOOC(playerid)
{
	if(IsPlayerAdmin(playerid)) {
	    // toggle it
	    if(gOOCDisabled) gOOCDisabled = false;
		else gOOCDisabled = true;
		
	    if(!gOOCDisabled) {
	        GlobalMessage(GENERAL_COLOR, "{D0D0D0}[ooc] channel is {80CC80}enabled");
		} else {
		    GlobalMessage(GENERAL_COLOR, "{D0D0D0}[ooc] channel is {CC8080}disabled");
		}
	} else {
	    CmdErrorMessage(playerid, "Your admin level isn't high enough to change this");
	}
}

//---------------------------------------------

stock ProcessLocalOOC(playerid, message[])
{
	new new_message[256+1];
	new PlayerName[MAX_PLAYER_NAME+1];
	GetPlayerName(playerid, PlayerName, sizeof(PlayerName));
	format(new_message, 256, "%s (( %s ))", PlayerName, message);
	LocalMessage(TALK_DISTANCE, playerid, LOCAL_TALK_COLOR, new_message);
}

//---------------------------------------------

stock ProcessMegaphone(playerid, message[])
{
	// Todo: add permissions on megaphone usage
   	new new_message[256+1];
	new PlayerName[MAX_PLAYER_NAME+1];
	GetPlayerName(playerid, PlayerName, sizeof(PlayerName));
	format(new_message, 256, "(megaphone) %s >> %s", PlayerName, message);
	LocalMessage(MEGAPHONE_DISTANCE, playerid, MEGAPHONE_COLOR, new_message, 1);
}

//---------------------------------------------

stock ProcessWhisper(playerid, toplayerid, message[])
{
	new PlayerName[MAX_PLAYER_NAME+1];
	new ToPlayerName[MAX_PLAYER_NAME+1];
	new PmMessage[256+1];
	GetPlayerName(playerid,PlayerName,sizeof(PlayerName));
	GetPlayerName(toplayerid,ToPlayerName,sizeof(ToPlayerName));
	format(PmMessage, sizeof(PmMessage), ">> %s(%d): %s", ToPlayerName, toplayerid, message);
	PlayerMessage(playerid, WHISPER_COLOR, PmMessage);
	format(PmMessage, sizeof(PmMessage), "** %s(%d): %s", PlayerName, playerid, message);
	PlayerMessage(toplayerid, WHISPER_COLOR, PmMessage);
	PlayerPlaySound(toplayerid, 1085, 0.0, 0.0, 0.0);
}

//---------------------------------------------

stock ProcessChatCommands(playerid, cmdtext[])
{
    new cmd[256+1];
	new message[256+1];
	new	tmp[256+1];
	new	idx;

	cmd = strtok(cmdtext, idx);

    // Action commands
	if(!strcmp("/me", cmd, true))
	{
  	    message = strrest(cmdtext,idx);
  	    if(!strlen(message)) {
			CmdUsageMessage(playerid, "/me [action]");
			return 1;
		}
		ProcessActionText(playerid, message, ACTION_ME);
		return 1;
	}
	if(!strcmp("/do", cmd, true))
	{
  	    message = strrest(cmdtext,idx);
  	    if(!strlen(message)) {
			CmdUsageMessage(playerid, "/do [action]");
			return 1;
		}
		ProcessActionText(playerid, message, ACTION_DO);
		return 1;
	}
	// Talk commands

	// /low
	if(!strcmp("/l", cmd, true) || !strcmp("/low", cmd, true))
	{
  	    message = strrest(cmdtext,idx);
  	    if(!strlen(message)) {
			CmdUsageMessage(playerid, "(/l)ow [text]");
			return 1;
		}
		TalkMessage(LOW_DISTANCE, playerid, "*quietly*", message);
		return 1;
	}
	// /shout
	if(!strcmp("/s", cmd, true) || !strcmp("/shout", cmd, true))
	{
  	    message = strrest(cmdtext,idx);
  	    if(!strlen(message)) {
			CmdUsageMessage(playerid, "(/s)hout [text]");
			return 1;
		}
		TalkMessage(SHOUT_DISTANCE, playerid, "*shouts*", message);
		return 1;
	}
	// /b (local ooc)
	if(!strcmp("/b", cmd, true))
	{
  	    message = strrest(cmdtext,idx);
  	    if(!strlen(message)) {
			CmdUsageMessage(playerid, "/b [text]");
			return 1;
		}
	    ProcessLocalOOC(playerid, message);
		return 1;
	}
	// /megaphone
	if(!strcmp("/m", cmd, true) || !strcmp("/megaphone", cmd, true))
	{
  	    message = strrest(cmdtext,idx);
  	    if(!strlen(message)) {
			CmdUsageMessage(playerid, "(/m)egaphone [text]");
			return 1;
		}
		ProcessMegaphone(playerid, message);
		return 1;
	}
	// Global OOC /o and /ooc
	if(!strcmp("/o", cmd, true) || !strcmp("/ooc", cmd, true))
	{
  	    message = strrest(cmdtext,idx);
  	    if(!strlen(message)) {
			CmdUsageMessage(playerid, "(/o)oc [text]");
			return 1;
		}
		GlobalOOCMessage(playerid, message);
		return 1;
	}
	// Toggle the OOC channel /togooc
	if(!strcmp("/togooc", cmd, true))
	{
  	   	ToggleOOC(playerid);
		return 1;
	}
 	// /whisper /pm
	if(!strcmp("/w", cmd, true) || !strcmp("/wisper", cmd, true) || !strcmp("/pm", cmd, true))
	{
		tmp = strtok(cmdtext,idx);

		if(!strlen(tmp)) {
			CmdUsageMessage(playerid, "(/w)isper [playerid/PartOfName] [whisper text]");
			return 1;
		}
		
		new toplayerid = ReturnUser(tmp);

	    if(toplayerid == RETURN_USER_MULTIPLE) {
			CmdErrorMessage(playerid, "Multiple matches found for [name]. Please narrow the search.");
			return 1;
		}
		if(toplayerid == RETURN_USER_FAILURE || !IsPlayerConnected(toplayerid)) {
		    CmdErrorMessage(playerid, "That player isn't connected right now.");
			return 1;
		}
		
		message = strrest(cmdtext,idx);
			     
		if(!strlen(message)) {
			CmdUsageMessage(playerid, "(/w)isper [playerid/PartOfName] [whisper text]");
			return 1;
		}

		if(IsPlayerConnected(toplayerid)) {
		     ProcessWhisper(playerid, toplayerid, message);
		}
		
		return 1;
	}


	return 0;
}

//---------------------------------------------

public OnPlayerText(playerid, text[])
{
	ProcessChatText(playerid, text);
	return 0;
}

//------------------------------------------------

public OnPlayerCommandText(playerid, cmdtext[])
{
	if(ProcessChatCommands(playerid,cmdtext)) {
	    return 1;
	}
	return 0;
}

//---------------------------------------------

