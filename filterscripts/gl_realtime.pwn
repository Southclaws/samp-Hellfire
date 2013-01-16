//
// Keeps the in game time synced to the server's time and
// draws the current time on the player's hud using a textdraw/
// (1 minute = 1 minute real world time)
//
//  (c) 2009-2012 SA-MP Team

#include <a_samp>
#pragma tabsize 0

//--------------------------------------------------

new Text:txtTimeDisp;
new hour, minute;
new timestr[32];

forward UpdateTimeAndWeather();

//--------------------------------------------------

new fine_weather_ids[] = {1,2,3,4,5,6,7,12,13,14,15,17,18,24,25,26,27,28,29,30,40};
new foggy_weather_ids[] = {9,19,20,31,32};
new wet_weather_ids[] = {8};

stock UpdateWorldWeather()
{
	new next_weather_prob = random(100);
	if(next_weather_prob < 70) 		SetWeather(fine_weather_ids[random(sizeof(fine_weather_ids))]);
	else if(next_weather_prob < 95) SetWeather(foggy_weather_ids[random(sizeof(foggy_weather_ids))]);
	else							SetWeather(wet_weather_ids[random(sizeof(wet_weather_ids))]);
}

//--------------------------------------------------

//new last_weather_update=0;

public UpdateTimeAndWeather()
{
	// Update time
    gettime(hour, minute);

   	format(timestr,32,"%02d:%02d",hour,minute);
   	TextDrawSetString(txtTimeDisp,timestr);
   	SetWorldTime(hour);
   	
	new x=0;
	while(x!=MAX_PLAYERS) {
	    if(IsPlayerConnected(x) && GetPlayerState(x) != PLAYER_STATE_NONE) {
	        SetPlayerTime(x,hour,minute);
		 }
		 x++;
	}

	/* Update weather every hour
	if(last_weather_update == 0) {
	    UpdateWorldWeather();
	}
	last_weather_update++;
	if(last_weather_update == 60) {
	    last_weather_update = 0;
	}*/
}

//--------------------------------------------------

public OnGameModeInit()
{
	// Init our text display
	txtTimeDisp = TextDrawCreate(605.0,25.0,"00:00");
	TextDrawUseBox(txtTimeDisp, 0);
	TextDrawFont(txtTimeDisp, 3);
	TextDrawSetShadow(txtTimeDisp,0); // no shadow
    TextDrawSetOutline(txtTimeDisp,2); // thickness 1
    TextDrawBackgroundColor(txtTimeDisp,0x000000FF);
    TextDrawColor(txtTimeDisp,0xFFFFFFFF);
    TextDrawAlignment(txtTimeDisp,3);
	TextDrawLetterSize(txtTimeDisp,0.5,1.5);
	
	UpdateTimeAndWeather();
	SetTimer("UpdateTimeAndWeather",1000 * 60,1);

	return 1;
}

//--------------------------------------------------

public OnPlayerSpawn(playerid)
{
	TextDrawShowForPlayer(playerid,txtTimeDisp);
	
	gettime(hour, minute);
	SetPlayerTime(playerid,hour,minute);
	
	return 1;
}

//--------------------------------------------------

public OnPlayerDeath(playerid, killerid, reason)
{
    TextDrawHideForPlayer(playerid,txtTimeDisp);
 	return 1;
}

//--------------------------------------------------

public OnPlayerConnect(playerid)
{
    gettime(hour, minute);
    SetPlayerTime(playerid,hour,minute);
    return 1;
}

//--------------------------------------------------
