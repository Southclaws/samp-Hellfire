#include <a_samp>
#include <audio>

#define PLAYERS 10

#define MAX_SONGS 15
#define MAX_TRACKS (MAX_SONGS*3)

new
	Songs[MAX_SONGS]= // All song ID's from K-Rose
	{
	    1369,   // Each song is 7 numbers away from each other
	    1376,   // on each 'side' of the ID are 3 ID's for the intro and 3 ID's for the outro [randomised]
	    1383,
	    1390,
	    1397,
	    1404,
	    1411,
	    1418,
	    1425,
	    1432,
	    1439,
	    1446,
	    1453,
	    1460,
	    1467
	},
	SongPlaylist[MAX_TRACKS],
	SongUsed[MAX_SONGS],
	CurrentTrack,
	RadioActive[MAX_VEHICLES],
	RadioHandle[MAX_VEHICLES];
	
/*
	Picks a random intro for the song,
	because all the intros and outros are up to 3 numbers difference
	I didn't have to make 2 more arrays for the intros/outros :D
*/
GetSongIntro(songid)return songid-(random(2)+1);
GetSongOutro(songid)return songid+(random(2)+1);

/*
	Creates a playlist of random songs and their intros
	it doesnt let a song repeat itself in the playlist
	it adds the intro and outro on the cell before and cell after the cell with the song ID in
*/
CreatePlaylist()
{
	new id=random(MAX_SONGS), idx;
	for(new s;s<MAX_SONGS;s++)
	{
	    while(SongUsed[id])id=random(MAX_SONGS);
		SongPlaylist[idx]	= GetSongIntro(Songs[id]);
		SongPlaylist[idx+1]	= Songs[id];
		SongPlaylist[idx+2]	= GetSongOutro(Songs[id]);
		SongUsed[id]=true;
		idx+=3;
	}
}

/*
	Toggles the radio on or off for a vehicle
	playerid: if set then the function will stop the audio for just that player
	this system can probably be scripted a lot better :P
*/
ToggleRadio(vehicleid, toggle, playerid=-1)
{
	if(toggle)
	{
	    if(playerid==-1)PlayRadioInCar(vehicleid, SongPlaylist[CurrentTrack]);
	    else PlayRadioForPlayer(playerid);
	    RadioActive[vehicleid]=true;
	}
	else
	{
	    if(playerid==-1)StopRadioInCar(vehicleid);
	    else StopRadioForPlayer(playerid, vehicleid);
	    RadioActive[vehicleid]=false;
	}
}

// These should be self explanitory
PlayRadioInCar(vehicleid, song)for(new i;i<PLAYERS;i++)if(IsPlayerInVehicle(i, vehicleid))RadioHandle[vehicleid]=Audio_Play(i, song);
StopRadioInCar(vehicleid)for(new i;i<PLAYERS;i++)if(IsPlayerInVehicle(i, vehicleid))Audio_Stop(i, RadioHandle[vehicleid]);

PlayRadioForPlayer(playerid)
{
	new v=GetPlayerVehicleID(playerid);
	RadioHandle[v]=Audio_Play(playerid, SongPlaylist[CurrentTrack]);
}
StopRadioForPlayer(playerid, v)
{
	Audio_Stop(playerid, RadioHandle[v]);
	PlayRadioInCar(v, SongPlaylist[CurrentTrack]);
}

/*
	When the song stops, it plays the next one
	When the final song finishes it creates a new playlist
	Probably doesn't work, I never tested it for when the playlist ended
	[I couldn't be arsed, again]
*/
public Audio_OnStop(playerid, handleid)
{
	for(new v;v<MAX_VEHICLES;v++)
	{
		if(handleid==RadioHandle[v])
		{
			CurrentTrack++;
			if(CurrentTrack==MAX_TRACKS)CreatePlaylist(),CurrentTrack=0;
			PlayRadioInCar(v, SongPlaylist[CurrentTrack]);
		    break;
		}
	}
}


public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print(" Streamed Radio Script Loaded");
	print("--------------------------------------\n");
	Audio_SetPack("radio_pack", true);
	for(new i;i<PLAYERS;i++)if(IsPlayerConnected(i))Audio_TransferPack(i);
	CreatePlaylist();
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if(!strcmp("/radio", cmdtext))
	{
	    if(IsPlayerInAnyVehicle(playerid))
	    {
	        new v=GetPlayerVehicleID(playerid);
	        if(RadioActive[v])ToggleRadio(v, 0);
	        else ToggleRadio(v, 1);
	    }
		return 1;
	}
	return 0;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	// If the player enters a vehicle with radio active, start playing it for that player
	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
	{
		new v=GetPlayerVehicleID(playerid);
		if(RadioActive[v])ToggleRadio(v, 1, playerid);
	}
	// When the player exits, stop radio for that player [I don't think this worked when I tested]
	if(newstate == PLAYER_STATE_ONFOOT && (oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER))
	{
		new v=GetPlayerVehicleID(playerid);
		if(RadioActive[v])ToggleRadio(v, 0, playerid);
		/*
		{
		    new Float:x, Float:y, Float:z;
		    GetVehiclePos(v, x, y, z);
			Audio_Set3DPosition(playerid, RadioHandle[v], x, y, z, 10.0);
			// My useless attempt at trying to make the radio play form the car when you get out, like in GTA:IV but it doesn't work for some reason :(
		}
		*/
	}
	return 1;
}
