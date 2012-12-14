CMD:help(playerid, params[])
{
	new str[512];
	strcat(str, ""#C_YELLOW"General Info\t"#C_BLUE"(/info)\n");
	strcat(str, ""#C_YELLOW"Rules\t\t"#C_BLUE"(/rules)\n");
	strcat(str, ""#C_YELLOW"Commands\t"#C_BLUE"(/cmds)\n");
	strcat(str, ""#C_YELLOW"Chat Help\t"#C_BLUE"(/chatinfo)\n");
	strcat(str, ""#C_YELLOW"Credits\t\t"#C_BLUE"(/credits)\n");
	strcat(str, ""#C_YELLOW"Online Admins\t"#C_BLUE"(/admins)");
	ShowPlayerDialog(playerid, d_Help, DIALOG_STYLE_LIST, "Help List", str, "Select", "Close");
	return 1;
}


CMD:info(playerid, params[])
{
	new str[1024];
	strcat(str, ""#C_WHITE"This server is a "#C_YELLOW"multi-game"#C_WHITE" server\nThere are many activities to choose from, including:\n\n\n");
	strcat(str, ""#C_RED"Deathmatches\n\t\t\tIntense firefights between two teams, customisable loadouts\n\t\t\tearn points and level up. Many different maps to choose from with 4 different gamemodes to play.\n\n");
	strcat(str, ""#C_BLUE"Races\n\t\t\tChallenge other players to fast paced sprints across San Andreas for rewards.\n\t\t\tYou can find checkpoints around the map to start races. You can race other players or do a timetrial.\n\n");
	strcat(str, ""#C_GREEN"Activities\n\t\t\tMinigames you can join where players can either work together to reach a goal or compete to win.\n\t\t\tSome of these you can just play on your own such as time trials.\n\n");
	strcat(str, ""#C_YELLOW"Challenges\n\t\t\tEvents started by admins that give all players a global objective to complete.\n\t\t\tThese objectives can include killing another player, retrieving an item, or working together.\n\n");
	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "General Information", str, "Close", "");
	return 1;
}
CMD:rules(playerid, params[])
{
	new str[593];

	strcat(str,
		"\t"#C_YELLOW"Don't "#C_RED"deathmatch "#C_YELLOW"while freeroaming\n\n\
		\tNo "#C_RED"annoying, bullying, discrimination or racism"#C_YELLOW"\n\n\
		\tNo "#C_RED"cheats/hacks/cleos"#C_YELLOW" - these can crash and annoy people!\n\n");

	strcat(str,
		"\tNo "#C_RED"spawn killing"#C_YELLOW" or "#C_RED"team killing"#C_YELLOW" in a deathmatch\n\n\
		\tDon't "#C_RED"Park Kill "#C_YELLOW"(parking on top of a player to kill them)\n\n\
		\tTry not to "#C_RED"obstruct"#C_YELLOW" stunt areas or teleport locations.");

	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Rules List", str, "Close", "");
	return 1;
}
CMD:cmds(playerid, params[])
{
	new str[512];
	strcat(str, ""#C_YELLOW"Activities\t"#C_BLUE"(/fun)\n");
	strcat(str, ""#C_YELLOW"Teleports\t"#C_BLUE"(/teles)\n");
	strcat(str, ""#C_YELLOW"Player\t\t"#C_BLUE"(/pcmds)\n");
	strcat(str, ""#C_YELLOW"Vehicle\t\t"#C_BLUE"(/vcmds)\n");
	strcat(str, ""#C_YELLOW"Miscellaneous\t"#C_BLUE"(/misc)\n");
	strcat(str, ""#C_YELLOW"Animations\t"#C_BLUE"(/animlist)\n");
	ShowPlayerDialog(playerid, d_Cmds, DIALOG_STYLE_LIST, "Commands", str, "Select", "Close");
	return 1;
}
CMD:chatinfo(playerid, params[])
{
    new
        tmp[128],
		str[1024],
		randomPlayerId = Iter_Random(Player);

	format(tmp, 128,
		""#C_GREEN"Chat Commands:\n\n\
		"#C_YELLOW"\t/me - "#C_BLUE"Action message: "#C_YELLOW">  %p is happy\n",
		playerid);
	strcat(str, tmp);

	strcat(str,
		""C_YELLOW"\t/g "#C_BLUE"- Global chat channel\n\
		"C_YELLOW"\t/t "#C_BLUE"- Team chat channel (Deathmatch)\n\
		"C_YELLOW"\t/vc "#C_BLUE"- Vehicle chat channel (When in a vehicle)\n");

	strcat(str,
		""C_YELLOW"\t/chat "#C_BLUE"- Join a private chat channel with another player\n\
		"C_YELLOW"\t/hide "#C_BLUE"- Hide a players chat text from appearing in your chatbox\n\
		"C_YELLOW"\t/block "#C_BLUE"- Block a player from using private chat with you\n\
		"C_YELLOW"\t/qlist "#C_BLUE"- Show quickchat message list.\n\n\n");


	format(tmp, 128,
	    ""#C_GREEN"Chat Features:\n\n\
		"C_YELLOW"\tPlayer Tagging: "#C_BLUE"'@' and a player ID: '@%d' for %P"#C_BLUE"\n",
		randomPlayerId, randomPlayerId);
	strcat(str, tmp);

	strcat(str,
		""C_YELLOW"\tColour embedding: "#C_BLUE"'&' and a letter: '&r' for "#C_RED"red text!\n\
		"C_YELLOW"\t\tAvailable Colours: "#C_RED"r, "#C_GREEN"g, "#C_BLUE"b, "#C_YELLOW"y, "#C_PINK"p, "#C_WHITE"w, "#C_ORANGE"o, "#C_NAVY"n, "#C_AQUA"a\n\
		"C_YELLOW"\tQuick Messages: "#C_BLUE"'#' and a number (/qmsg to save quick messages)");

	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Chat commands and info", str, "Close", "");
	return 1;
}
CMD:credits(playerid, params[])
{
	new str[1024];
	strcat(str, ""#C_YELLOW"Server Development Credits\n");
	strcat(str, ""#C_BLUE"Southclaw"#C_YELLOW" - Scripting, Mapping, Ideas, Creator/Founder\n");
	strcat(str, ""#C_BLUE"Onfire559"#C_YELLOW" - Mapping, Ideas, Hosting, Managing, Support\n");
	strcat(str, ""#C_BLUE"Cagatay"#C_YELLOW" - Mapping, Ideas, Support\n");
	strcat(str, ""#C_BLUE"Defiance"#C_YELLOW" - Mapping, Ideas, Support\n");
	strcat(str, ""#C_BLUE"Pandemonium"#C_YELLOW" - Mapping, Ideas, Support\n");
	strcat(str, ""#C_BLUE"SirDewie"#C_YELLOW" - Many Great Ideas\n\n");
	strcat(str, ""#C_YELLOW"Contributions\n");
	strcat(str, ""#C_BLUE"Y_Less"#C_YELLOW" - Lots of script help and influence\n");
	strcat(str, ""#C_BLUE"RyDeR`"#C_YELLOW" - Help with the math-y side of things\n");
	strcat(str, ""#C_BLUE"Seif"#C_YELLOW" - Used some scripts from Seif\n");
	strcat(str, ""#C_BLUE"Sandra"#C_YELLOW" - Used some scripts from Sandra\n");
	strcat(str, ""#C_BLUE"Fallout"#C_YELLOW" - Used some scripts and shared ideas with Fallout\n");
	strcat(str, ""#C_BLUE"Patrik356b"#C_YELLOW" - Script and Map contributions, and lots of idea sharing!\n\n");
	strcat(str, ""#C_BLUE"Pizzy"#C_YELLOW" - Hosting my server and generally being awesome\n\n");
	strcat(str, ""#C_YELLOW"Beta Testers - They made sure all the stuff worked!\n");
	strcat(str, ""#C_BLUE"Rudy\n");
	strcat(str, ""#C_BLUE"LittleHelper[MDZ]\n");
	strcat(str, ""#C_BLUE"s0nic\n");
	strcat(str, ""#C_BLUE"Fusez\n");
	strcat(str, ""#C_BLUE"Lexi\n");
	strcat(str, ""#C_GREEN"Big Thanks to the SA:MP Team for making this mod possible\n");
	strcat(str, ""#C_GREEN"And to the SA:MP Community for sharing scripts, help, ideas and support!\n");
	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Server Credits", str, "Close", "");
	return 1;
}

CMD:challenges(playerid, params[])
{
    new str[300];
	strcat(str, ""#C_YELLOW"Marked Man\n\t\t\t"#C_WHITE"One player is 'marked' The first player to kill him gets a reward. But watch out, he will fight back for his own rewards!\n\n");
	strcat(str, ""#C_YELLOW"Juggernaut\n\t\t\t"#C_WHITE"One player is chosen to be the 'Juggernaut' other players must team up to take him down, he's heavily armed and extremely dangerous!\n\n");
	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Challenges", str, "Close", "");
	return 1;
}
CMD:minigames(playerid, params[])
{
    new str[300] = {"This list needs to be filled Southclaw you lazy fucker,"};
	ShowPlayerDialog(playerid, d_Minigames, DIALOG_STYLE_MSGBOX, "Challenges", str, "Close", "");
	return 1;
}

