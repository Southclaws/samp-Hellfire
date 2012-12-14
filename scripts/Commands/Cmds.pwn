/*
Activities
Teleports
Player
Vehicle
Miscellaneous
Animations
*/

CMD:fun(playerid, params[])
{
    new str[422];
	strcat(str, ""#C_YELLOW"/joindm\t\t"#C_YELLOW"Start or Join a deathmatch\n");
	strcat(str, ""#C_YELLOW"/minigames\t"#C_YELLOW"List of minigames to join at any time.\n");
	strcat(str, ""#C_YELLOW"/challenges\t"#C_YELLOW"List of challenges and how to play.\n");
	ShowPlayerDialog(playerid, d_Fun, DIALOG_STYLE_LIST, "Activities and Fun stuff to do", str, "Close", "");
	return 1;
}
CMD:pcmds(playerid, params[])
{
    new str[450];
	strcat(str, "/report - seen a player not obeying rules? report them to online admins!\n");
	strcat(str, "/psave - save your position and go back with /b\n");
	strcat(str, "/getstats - see the profile stats of another player\n");
	strcat(str, "/givecash - feeling charitable? give some money to another player!\n");
	strcat(str, "/colour - Change your player colour\n");
	strcat(str, "/skin - Change your skin\n");
	strcat(str, "/para - get a parachute\n");
	strcat(str, "/camera - get a camera");
	ShowPlayerDialog(playerid, d_PCmds, DIALOG_STYLE_LIST, "Player Commands List", str, "Close", "");
	return 1;
}
CMD:vcmds(playerid, params[])
{
    new str[210];
	strcat(str, "/f - fix and flip your car\n");
	strcat(str, "/lock - lock your car\n");
	strcat(str, "/unlock - unlock your car\n");
	strcat(str, "/nos - +Adds nitro boost to your car\n");
	strcat(str, "/ct - Switch to vehicle chat channel\n");
	strcat(str, "/v - Spawn a vehicle\n");
	strcat(str, "/mod - Choose some mods for your vehicle\n");
	ShowPlayerDialog(playerid, d_VCmds, DIALOG_STYLE_LIST, "Vehicle Commands List", str, "Close", "");
	return 1;
}
CMD:misc(playerid, params[])
{
    new str[170];
	strcat(str, "/sky - Try It!\n");
	strcat(str, "/para - Get a parachute\n");
	strcat(str, "/pos - Your coordinates\n");
	strcat(str, "/idea - Submit an idea to the server\n");
	strcat(str, "/bug - Report a bug on the server\n");
	strcat(str, "/rand - Generate a random number...\n");
	ShowPlayerDialog(playerid, d_Misc, DIALOG_STYLE_LIST, "Random Commands List", str, "Close", "");
	return 1;
}
CMD:animlist(playerid, params[])
{
	new str[730];
	strcat(str, "/fall - /fallback - /injured - /akick - /push - /lowbodypush - /handsup - /bomb - /drunk - /getarrested - /laugh - /sup\n");
	strcat(str, "/basket - /headbutt - /cpr - /spray - /robman - /taichi - /lookout - /kiss - /cellin - /cellout - /crossarms - /lay\n");
	strcat(str, "/deal - /crack - /smoke - /groundsit - /talk - /dance - /fucku - /strip - /cower - /vomit - /eat - /chairsit - /reload\n");
	strcat(str, "/koface - /kostomach - /rollfall - /carjacked1 - /carjacked2 - /rcarjack1 - /rcarjack2 - /lcarjack1 - /lcarjack2 - /bat\n");
	strcat(str, "/lifejump - /exhaust - /leftslap - /carlock - /hoodfrisked - /lightcig - /tapcig - /box - /lay2 - /chant - finger\n");
	strcat(str, "/shouting - /knife - /cop - /elbow - /kneekick - /airkick - /gkick - /gpunch - /fstance - /lowthrow - /highthrow - /aim\n");
	strcat(str, "/pee - /lean - /run\n");
	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Animation Commands List", str, "Close", "");
	return true;
}

