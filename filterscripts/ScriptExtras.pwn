#include <a_samp>
#include <IniFiles>
#include <sscanf2>

#undef MAX_PLAYERS
#define MAX_PLAYERS 10

#define switchbool(%1) ((%1*-1)+1)
#define cmd(%1) if((!strcmp(cmd,%1,true,strlen(%1)))&&(cmd[strlen(%1)]==EOS))


#define RED				0xAA3333AA
#define YELLOW			0xFFFF00AA
#define GREEN			0x33AA33AA
#define BLUE			0x33CCFFAA
#define PINK			0xFFC0CBAA
#define PURPLE          0x7D26CDAA
#define BLACK           0x00000000
#define WHITE           0xFFFFFFFF

new Jump[MAX_PLAYERS];

new cArray[8][2][8]=
{
	{"mRED",		"AA3333"},
	{"mYELLOW",		"FFFF00"},
	{"mGREEN",		"33AA33"},
	{"mBLUE",		"33CCFF"},
	{"mPINK",		"FFC0CB"},
	{"mPURPLE",		"7D26CD"},
	{"mBLACK",		"000000"},
	{"mWHITE",		"FFFFFF"}
};

#define DIALOG_ID_START_ID 1
new
	VEHICLE_DIALOG=DIALOG_ID_START_ID+0,
	MOD_DIALOG=DIALOG_ID_START_ID+1,
	WHEEL_DIALOG=DIALOG_ID_START_ID+2,
	COLOUR_DIALOG=DIALOG_ID_START_ID+3,
	PAINT_DIALOG=DIALOG_ID_START_ID+4,
	ITEM_DIALOG=DIALOG_ID_START_ID+5,
	CUSTOMCAR_DIALOG=DIALOG_ID_START_ID+6,
	WEATHER_DIALOG=DIALOG_ID_START_ID+7,
	TIMEZONE_DIALOG=DIALOG_ID_START_ID+8,
	REGISTER_DIALOG=DIALOG_ID_START_ID+9,
	LOGIN_DIALOG=DIALOG_ID_START_ID+10;

new VehiclesInMenu[19]=
{
	541,
	506,
	411,
	451,
	496,
	557,
	495,
	568,
	573,
	471,
	468,
	522,
	539,
	571,
	457,
	510,

	432,
	520,
	425
};

new VehicleNames[212][30]=
{
   "Landstalker",
   "Bravura",
   "Buffalo",
   "Linerunner",
   "Pereniel",
   "Sentinel",
   "Dumper",
   "Firetruck",
   "Trashmaster",
   "Stretch",
   "Manana",
   "Infernus",
   "Voodoo",
   "Pony",
   "Mule",
   "Cheetah",
   "Ambulance",
   "Leviathan",
   "Moonbeam",
   "Esperanto",
   "Taxi",
   "Washington",
   "Bobcat",
   "Mr Whoopee",
   "BF Injection",
   "Hunter",
   "Premier",
   "Enforcer",
   "Securicar",
   "Banshee",
   "Predator",
   "Bus",
   "Rhino",
   "Barracks",
   "Hotknife",
   "Trailer", //artict1
   "Previon",
   "Coach",
   "Cabbie",
   "Stallion",
   "Rumpo",
   "RC Bandit",
   "Romero",
   "Packer",
   "Monster",
   "Admiral",
   "Squalo",
   "Seasparrow",
   "Pizzaboy",
   "Tram",
   "Trailer", //artict2
   "Turismo",
   "Speeder",
   "Reefer",
   "Tropic",
   "Flatbed",
   "Yankee",
   "Caddy",
   "Solair",
   "Berkley's RC Van",
   "Skimmer",
   "PCJ-600",
   "Faggio",
   "Freeway",
   "RC Baron",
   "RC Raider",
   "Glendale",
   "Oceanic",
   "Sanchez",
   "Sparrow",
   "Patriot",
   "Quad",
   "Coastguard",
   "Dinghy",
   "Hermes",
   "Sabre",
   "Rustler",
   "ZR3 50",
   "Walton",
   "Regina",
   "Comet",
   "BMX",
   "Burrito",
   "Camper",
   "Marquis",
   "Baggage",
   "Dozer",
   "Maverick",
   "News Chopper",
   "Rancher",
   "FBI Rancher",
   "Virgo",
   "Greenwood",
   "Jetmax",
   "Hotring Racer 1",
   "Sandking",
   "Blista Compact",
   "Police Maverick",
   "Boxville",
   "Benson",
   "Mesa",
   "RC Goblin",
   "Hotring Racer 2", //hotrina
   "Hotring Racer 3", //hotrinb
   "Bloodring Banger",
   "Rancher",
   "Super GT",
   "Elegant",
   "Journey",
   "Bike",
   "Mountain Bike",
   "Beagle",
   "Cropdust",
   "Stunt",
   "Tanker", //petro
   "RoadTrain",
   "Nebula",
   "Majestic",
   "Buccaneer",
   "Shamal",
   "Hydra",
   "FCR-900",
   "NRG-500",
   "HPV1000",
   "Cement Truck",
   "Tow Truck",
   "Fortune",
   "Cadrona",
   "FBI Truck",
   "Willard",
   "Forklift",
   "Tractor",
   "Combine",
   "Feltzer",
   "Remington",
   "Slamvan",
   "Blade",
   "Freight",
   "Streak",
   "Vortex",
   "Vincent",
   "Bullet",
   "Clover",
   "Sadler",
   "Firetruck", //firela
   "Hustler",
   "Intruder",
   "Primo",
   "Cargobob",
   "Tampa",
   "Sunrise",
   "Merit",
   "Utility",
   "Nevada",
   "Yosemite",
   "Windsor",
   "Monster", //monstera
   "Monster", //monsterb
   "Uranus",
   "Jester",
   "Sultan",
   "Stratum",
   "Elegy",
   "Raindance",
   "RC Tiger",
   "Flash",
   "Tahoma",
   "Savanna",
   "Bandito",
   "Freight", //freiflat
   "Trailer", //streakc
   "Kart",
   "Mower",
   "Duneride",
   "Sweeper",
   "Broadway",
   "Tornado",
   "AT-400",
   "DFT-30",
   "Huntley",
   "Stafford",
   "BF-400",
   "Newsvan",
   "Tug",
   "Trailer", //petrotr
   "Emperor",
   "Wayfarer",
   "Euros",
   "Hotdog",
   "Club",
   "Trailer", //freibox
   "Trailer", //artict3
   "Andromada",
   "Dodo",
   "RC Cam",
   "Launch",
   "Police Car (LSPD)",
   "Police Car (SFPD)",
   "Police Car (LVPD)",
   "Police Ranger",
   "Picador",
   "S.W.A.T. Van",
   "Alpha",
   "Phoenix",
   "Glendale",
   "Sadler",
   "Luggage Trailer", //bagboxa
   "Luggage Trailer", //bagboxb
   "Stair Trailer", //tugstair
   "Boxville",
   "Farm Plow", //farmtr1
   "Utility Trailer" //utiltr1
},pVehicle[MAX_VEHICLES];
enum WheelEnum{mod,name[10]}
new Wheels[17][WheelEnum]=
{
	{1073, "Shadow"},
	{1074, "Mega"},
	{1075, "Rimshine"},
	{1076, "Wires"},
	{1077, "Classic"},
	{1078, "Twist"},
	{1079, "Cutter"},
	{1080, "Switch"},
	{1081, "Grove"},
	{1082, "Import"},
	{1083, "Dollar"},
	{1084, "Trance"},
	{1085, "Atomic"},
	{1096, "Ahab"},
	{1097, "Virtual"},
	{1098, "Access"},
	{1025, "Offroad"}
};
enum ColourEnum{colour1,colour2,name[10]}
new Colours[8][ColourEnum]=
{
	{0, 0, "Black"},
	{1, 1, "White"},
	{7, 7, "Blue"},
	{3, 3, "Red"},
	{6, 6, "Yellow"},
	{86, 86, "Green"},
	{126, 126, "Pink"},
	{148, 148, "Purple"}
};
enum WeatherEnum{wid,name[10]}
new Weathers[9][WeatherEnum]=
{
	{0, "Sunny"},
	{8, "Stormy"},
	{9, "Foggy"},
	{11, "Hot"},
	{12, "Dull"},
	{16, "Rainy"},
	{19, "Sandstorm"},
	{20, "Green"},
	{43, "Toxic"}
};
enum TimeZoneEnum{time,name[10]}
new TimeZones[25][TimeZoneEnum]=
{
	{12, "GMT+12"},
	{11, "GMT+11"},
	{10, "GMT+10"},
	{9, "GMT+9"},
	{8, "GMT+8"},
	{7, "GMT+7"},
	{6, "GMT+6"},
	{5, "GMT+5"},
	{4, "GMT+4"},
	{3, "GMT+3"},
	{2, "GMT+2"},
	{1, "GMT+1"},
	{0, "GMT"},
	{-1, "GMT+1"},
	{-2, "GMT+2"},
	{-3, "GMT+3"},
	{-4, "GMT+4"},
	{-5, "GMT+5"},
	{-6, "GMT+6"},
	{-7, "GMT+7"},
	{-8, "GMT+8"},
	{-9, "GMT+9"},
	{-10, "GMT+10"},
	{-11, "GMT+11"},
	{-12, "GMT+12"}
},TimeZone[MAX_PLAYERS],Text:ClockText[MAX_PLAYERS];

new pRaceVeh[MAX_PLAYERS];

//Account Stuff
new
    p_LoggedIn[MAX_PLAYERS],
    p_Admin[MAX_PLAYERS],
	p_Spectating[MAX_PLAYERS]=-1;


public OnFilterScriptInit()
{
	file_OS();
	for(new i;i<MAX_PLAYERS;i++)
	{
		ClockText[i] = TextDrawCreate(605.0,25.0,"00:00");
		TextDrawUseBox(ClockText[i], 0);
		TextDrawFont(ClockText[i], 3);
		TextDrawSetShadow(ClockText[i],0);
		TextDrawSetOutline(ClockText[i],2);
		TextDrawBackgroundColor(ClockText[i],0x000000FF);
		TextDrawColor(ClockText[i],0xFFFFFFFF);
		TextDrawAlignment(ClockText[i],3);
		TextDrawLetterSize(ClockText[i],0.5,1.6);
	}
	for(new v;v<MAX_VEHICLES;v++)pVehicle[v]=-1;

	SetTimer("TimeUpdate", 1000, true);
	return 1;
}
forward TimeUpdate();
public TimeUpdate()
{
	new h, m, s;
	gettime(h, m, s);
	for(new i;i<MAX_PLAYERS;i++)if(IsPlayerConnected(i))
	{
		new string[10], mStr[5], hStr[5], mInt=m, hInt=(h+TimeZone[i]);
		if(hInt>24) hInt-=24;
	 	if(mInt<10)	format(mStr,	5, "0%i", 	mInt);
	  	if(mInt>9)	format(mStr,	5, "%i", 	mInt);
	  	if(hInt<10)	format(hStr,	5, "0%i", 	hInt);
	  	if(hInt>9)	format(hStr,	5, "%i", 	hInt);
		format(string, 10, "%s:%s", hStr, mStr);
		TextDrawSetString(ClockText[i], string);
		SetPlayerTime(i, hInt, mInt);
	}
}
public OnPlayerConnect(playerid)
{
	TextDrawShowForPlayer(playerid, ClockText[playerid]);
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid)
{
	v_Engine(vehicleid, 1);
	v_Lights(vehicleid, 1);
}
public OnPlayerExitVehicle(playerid, vehicleid)
{
	v_Engine(vehicleid, 0);
	v_Lights(vehicleid, 0);
	if(vehicleid==pRaceVeh[playerid])DestroyVehicle(vehicleid);
	for(new v;v<MAX_VEHICLES;v++)
	{
		if(pVehicle[v]==vehicleid)
		{
			DestroyVehicle(vehicleid);
			pVehicle[v]=-1;
			break;
		}
	}
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	new cmd[30], params[100];
	sscanf(cmdtext, "s[30]s[100]", cmd, params);

	if(CMDS_Lists(playerid, cmd))return 1;
	if(CMDS_Teles(playerid, cmd))return 1;
	if(CMDS_Funcs(playerid, cmd))return 1;


	cmd("/rallynotinuse")
    {
		SetPlayerInterior(playerid, 4);
		SetPlayerAmmo(playerid,24, 0);

		pRaceVeh[playerid]=CreateVehicle(471,-1432.7351,-638.6186,1049.5912,346.6718,7,7,1000);
		LinkVehicleToInterior(pRaceVeh[playerid], 4);
		PutPlayerInVehicle(playerid, pRaceVeh[playerid], 0);
		AddVehicleComponent(pRaceVeh[playerid],1010);

		new string[64], pName[MAX_PLAYER_NAME];
		GetPlayerName(playerid,pName,MAX_PLAYER_NAME);
		format(string,sizeof string,"%s has gone to /rally",pName);
		SendClientMessageToAll(0xFF0000AA,string);
	}

	cmd("/racenotinuse")
	{
	    SetPlayerInterior(playerid, 7);
	    SetPlayerAmmo(playerid,24, 0);

		pRaceVeh[playerid]=CreateVehicle(411,-1403.8160,-255.0917,1043.2385,346.6718,7,7,1000);
	    LinkVehicleToInterior(pRaceVeh[playerid], 7);
	    PutPlayerInVehicle(playerid, pRaceVeh[playerid], 0);
	    AddVehicleComponent(pRaceVeh[playerid],1010);

	    new string[64], pName[MAX_PLAYER_NAME];
	   	GetPlayerName(playerid,pName,MAX_PLAYER_NAME);
	   	format(string,sizeof string,"%s has gone to /race",pName);
	   	SendClientMessageToAll(0xFF0000AA,string);
	}

	
	cmd("/v")
	{
		ShowCarMenu(playerid);
		return 1;
	}
	cmd("/mod")
	{
		ShowModMenu(playerid);
		return 1;
	}
	cmd("/items")
	{
		ShowItemMenu(playerid);
		return 1;
	}
	cmd("/weather")
	{
		ShowWeatherMenu(playerid);
		return 1;
	}
	cmd("/time")
	{
		ShowTimeMenu(playerid);
		return 1;
	}

	cmd("/engine")
	{
	    v_Engine(GetPlayerVehicleID(playerid), switchbool(v_Engine(GetPlayerVehicleID(playerid))));
		return 1;
	}
	cmd("/lights")
	{
	    v_Lights(GetPlayerVehicleID(playerid), switchbool(v_Lights(GetPlayerVehicleID(playerid))));
		return 1;
	}


	cmd("/noinuse1")
	{
	    if(!fexist("Accounts.ini"))file_Create("Accounts.ini");
	    file_Open("Accounts.ini");
	    if(file_IsKey(GetName(playerid)))SysMsg(playerid, "You already have an account, use /login");
	    else
	    {
	    	if(p_LoggedIn[playerid])SysMsg(playerid, "You are already logged in");
			else ShowPlayerDialog(playerid, REGISTER_DIALOG, DIALOG_STYLE_INPUT, FormatColours("Please {mYELLOW}Register{mWHITE} a new account"), FormatColours("Type your {mYELLOW}Password {mWHITE}Below"), "Enter", "");
	    }
	    file_Close();
	    return 1;
	}
	cmd("/notinuse2")
	{
	    if(!fexist("Accounts.ini"))file_Create("Accounts.ini");
	    file_Open("Accounts.ini");
	    if(!file_IsKey(GetName(playerid)))SysMsg(playerid, "You don't have an account yet, please use /register");
	    else
	    {
	    	if(p_LoggedIn[playerid])SysMsg(playerid, "You are already logged in");
	    	else ShowPlayerDialog(playerid, LOGIN_DIALOG, DIALOG_STYLE_INPUT, FormatColours("Please {mYELLOW}Login{mWHITE} to your account"), FormatColours("Type your {mYELLOW}Password {mWHITE}Below"), "Enter", "");
	    }
	    file_Close();
	    return 1;
	}
	cmd("/notinuse3")
	{
		if(p_LoggedIn[playerid])
		{
			p_LoggedIn[playerid]=false;
			p_Admin[playerid]=0;
			SysMsg(playerid, "You have logged out.");
	    }
	    else SysMsg(playerid, "You aren't logged in");
	    return 1;
	}
	if(p_Admin[playerid])
	{
		cmd("/goto")
		{
		    new id=strval(params);
			if(!IsPlayerConnected(id)) return SysMsg(playerid, "{mRED}Invalid ID");
			else
			{
				new Float:x, Float:y, Float:z, Float:a, pv=GetPlayerVehicleID(playerid);
				if(IsPlayerInAnyVehicle(id))GetVehiclePos(pv, x, y, z),GetVehicleZAngle(pv, a);
				else GetPlayerPos(id, x, y, z),GetPlayerFacingAngle(id, a);
				SetPlayerPos(playerid, x, y, z+2);
				SetPlayerFacingAngle(playerid, a);
				if(IsPlayerInAnyVehicle(playerid))
				{
					SetVehiclePos(pv, x, y, z+2);
					SetVehicleZAngle(pv, a);
					PutPlayerInVehicle(playerid, pv, 0);
				}
			}
			return 1;
		}
		cmd("/announce")
		{
			GameTextForAll(params, 5000, 5);
			return 1;
		}
		cmd("/spectate")
		{
		    if(!strcmp(params, "off"))
			{
				TogglePlayerSpectating(playerid, false);
				p_Spectating[playerid]=-1;
				SysMsg(playerid, "Spectate Mode Off");
			}
		    else
		    {
				new id=strval(params);
				if(IsPlayerConnected(id))
				{
					TogglePlayerSpectating(playerid, true);
					if(IsPlayerInAnyVehicle(id))PlayerSpectateVehicle(playerid, GetPlayerVehicleID(id));
					else PlayerSpectatePlayer(playerid, id);
					p_Spectating[playerid]=id;
					SysMsg(playerid, "You are spectating");
				}
				else SysMsg(playerid, "{mRED}Invalid Player ID");
			}
			return 1;
		}
	}
	if(IsPlayerAdmin(playerid))
	{
	    cmd("/makeadmin")
	    {
	        new id=strval(params);
	        if(!IsPlayerConnected(id)) return SysMsg(playerid, "{mRED}Invalid ID");
	        else
	        {
	            p_Admin[id]=1;
	            SysMsg(id, "You are now an administrator");
	        }
			return 1;
	    }
	}
	return 0;
}
public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate==PLAYER_STATE_DRIVER)
	{
	    for(new i;i<MAX_PLAYERS;i++)
	    {
	    	if(p_Spectating[i]==playerid)
	    	{
	    	    PlayerSpectateVehicle(i, GetPlayerVehicleID(playerid));
	    	}
	    }
	}
	if(newstate==PLAYER_STATE_ONFOOT&&oldstate==PLAYER_STATE_DRIVER)
	{
	    for(new i;i<MAX_PLAYERS;i++)
	    {
	    	if(p_Spectating[i]==playerid)
	    	{
	    	    PlayerSpectatePlayer(i, playerid);
	    	}
	    }
	}
}
/*
public OnPlayerDeath(playerid, killerid, reason)
{
	for(new i;i<MAX_PLAYERS;i++)
	{
		if(p_Spectating[i]==playerid)
		{
			SpawnPlayer(i);
		}
	}
}
*/
public OnPlayerSpawn(playerid)
{
	for(new i;i<MAX_PLAYERS;i++)
	{
		if(p_Spectating[i]==playerid)
		{
			PlayerSpectatePlayer(i, playerid);
		}
	}
}
ShowCarMenu(playerid)
{
	new str[256], str2[256], adminminus;
	str=VehicleNames[VehiclesInMenu[0]-400];
	if(!IsPlayerAdmin(playerid))adminminus=3;
	for(new x=1;x<(sizeof(VehiclesInMenu)-adminminus);x++)
	{
		format(str2, 256, "%s\n%s", str, VehicleNames[VehiclesInMenu[x]-400]);
		str=str2;
	}
	if(IsPlayerAdmin(playerid))strins(str, "\nEnter ID", strlen(str));
	ShowPlayerDialog(playerid, VEHICLE_DIALOG, DIALOG_STYLE_LIST, "Choose a car to spawn", str, "spawn", "cancel");
}
ShowModMenu(playerid)
{
	ShowPlayerDialog(playerid, MOD_DIALOG, DIALOG_STYLE_LIST, "Choose some mods for your car", "Nitro\nHydraulics\nWheels\nColours\nPaintjobs", "Select", "Cancel");
}
ShowWheelMenu(playerid)
{
	new str[128], str2[128];
	format(str, 128, Wheels[0][name]);
	for(new x=1;x<sizeof(Wheels);x++)
	{
		format(str2, 128, "%s\n%s", str, Wheels[x][WheelEnum:1]);
		str=str2;
	}
	ShowPlayerDialog(playerid, WHEEL_DIALOG, DIALOG_STYLE_LIST, "Choose some wheels to add to your vehicle", str, "Select", "Cancel");
}
ShowColourMenu(playerid)
{
	new str[128], str2[128];
	format(str, 128, Colours[0][name]);
	for(new x=1;x<sizeof(Colours);x++)
	{
		format(str2, 128, "%s\n%s", str, Colours[x][ColourEnum:1]);
		str=str2;
	}
	ShowPlayerDialog(playerid, COLOUR_DIALOG, DIALOG_STYLE_LIST, FormatColours("Choose vehicle {FFFF00}colours"), str, "Set", "Cancel");
}
ShowPaintjobMenu(playerid)
{
	ShowPlayerDialog(playerid, PAINT_DIALOG, DIALOG_STYLE_LIST, FormatColours("Choose a vehicle {FFFF00}Paintjob"), "Paintjob 1\nPaintjob 2\nPaintjob 3", "Set", "Cancel");
}
ShowItemMenu(playerid)
{
	ShowPlayerDialog(playerid, ITEM_DIALOG, DIALOG_STYLE_LIST, "Item menu", "Parachute\nCamera\nJetpack", "Set", "Cancel");
}
ShowCustomCarDialog(playerid)
{
	ShowPlayerDialog(playerid, CUSTOMCAR_DIALOG, DIALOG_STYLE_INPUT, "Custom Vehicle Spawn", "Enter a vehicle ID {FF0000}between 400 and 612", "Spawn", "Cancel");
}
ShowWeatherMenu(playerid)
{
	new str[128], str2[128];
	format(str, 128, Weathers[0][name]);
	for(new x=1;x<sizeof(Weathers);x++)
	{
		format(str2, 128, "%s\n%s", str, Weathers[x][WeatherEnum:1]);
		str=str2;
	}
	ShowPlayerDialog(playerid, WEATHER_DIALOG, DIALOG_STYLE_LIST, "Choose a weather type", str, "Set", "Cancel");
}
ShowTimeMenu(playerid)
{
	new str[150], str2[150];
	format(str, 128, TimeZones[0][name]);
	for(new x=1;x<sizeof(TimeZones);x++)
	{
		format(str2, 150, "%s\n%s", str, TimeZones[x][TimeZoneEnum:1]);
		str=str2;
	}
	ShowPlayerDialog(playerid, TIMEZONE_DIALOG, DIALOG_STYLE_LIST, "Choose a time zone", str, "Set", "Cancel");
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == VEHICLE_DIALOG && response)
	{
	    if(listitem < sizeof(VehiclesInMenu))SpawnVehicleForPlayer(playerid, VehiclesInMenu[listitem]);
	    else ShowCustomCarDialog(playerid);
	}
	if(dialogid == MOD_DIALOG && response)
	{
		switch(listitem)
		{
			case 0:{AddVehicleComponent(GetPlayerVehicleID(playerid), 1010),ShowModMenu(playerid),PlayerPlaySound(playerid, 1133, 0, 0, 0);}
			case 1:{AddVehicleComponent(GetPlayerVehicleID(playerid), 1087),ShowModMenu(playerid),PlayerPlaySound(playerid, 1133, 0, 0, 0);}
			case 2:ShowWheelMenu(playerid);
			case 3:ShowColourMenu(playerid);
			case 4:ShowPaintjobMenu(playerid);
		}
	}
	if(dialogid == WHEEL_DIALOG && response){AddVehicleComponent(GetPlayerVehicleID(playerid), Wheels[listitem][mod]),PlayerPlaySound(playerid, 1133, 0, 0, 0);}
	if(dialogid == COLOUR_DIALOG && response)ChangeVehicleColor(GetPlayerVehicleID(playerid), Colours[listitem][colour1], Colours[listitem][colour2]);
	if(dialogid == PAINT_DIALOG && response)ChangeVehiclePaintjob(GetPlayerVehicleID(playerid), listitem);
	if(dialogid == ITEM_DIALOG && response)
	{
		switch(listitem)
		{
			case 0:GivePlayerWeapon(playerid, 46, 1);
			case 1:GivePlayerWeapon(playerid, 43, 1);
			case 2:SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
		}
	}
	if(dialogid == CUSTOMCAR_DIALOG && response)
	{
	    new value = strval(inputtext);
	    if(value >= 400 || value <= 612)SpawnVehicleForPlayer(playerid, value);
	    else ShowCustomCarDialog(playerid);
	}
	if(dialogid == WEATHER_DIALOG && response)SetPlayerWeather(playerid, Weathers[listitem][WeatherEnum:0]);
	if(dialogid == TIMEZONE_DIALOG && response)TimeZone[playerid]=TimeZones[listitem][TimeZoneEnum:0];
	if(dialogid == REGISTER_DIALOG && response && strlen(inputtext)>1)
	{
//	    new y, m, d, h, mn, s, t[20]
		new pName[24];
		pName=GetName(playerid);
	    SysMsg(playerid, "Welcome to Hellfire Stunts!");
	    SysMsg(playerid, "Your account has been saved, {mBLUE}Enjoy your time on this server {mYELLOW}:D");
	    SysMsg(playerid, "{mRED}Report any bad players to online admins");

		new strWrite[128];

		strcat(strWrite, inputtext);

		file_Open("Accounts.ini");
		file_SetStr(pName, strWrite);
		file_Save("Accounts.ini");
		file_Close();

		p_LoggedIn[playerid]=true;
	}
	if(dialogid == LOGIN_DIALOG && response)
	{
		new pass[128], admin, pLine[80], pName[24];
		pName = GetName(playerid);

		file_Open("Accounts.ini");
		strcat(pLine, file_GetStr(pName));
		file_Close();

		sscanf(pLine, "s[128]d", pass, admin);

		if(!strcmp(pass, inputtext))
		{
			p_LoggedIn[playerid]=1;
			p_Admin[playerid]=admin;
		}
		else
		{
			SysMsg(playerid, "{mRED}Incorrect Password!");
			ShowPlayerDialog(playerid, LOGIN_DIALOG, DIALOG_STYLE_INPUT, FormatColours("Please {mYELLOW}Login{mWHITE} to your account"), FormatColours("Type your {mYELLOW}Password {mWHITE}Below"), "Enter", "");
		}
	}
	return 1;
}
//==============================================================Custom Functions
SpawnVehicleForPlayer(playerid, model)
{
	new Float:x, Float:y, Float:z, Float:a;
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, a);
	if(IsPlayerInAnyVehicle(playerid))
	{
		new v = GetPlayerVehicleID(playerid);
		DestroyVehicle(v);
		for(new s;s<MAX_VEHICLES;s++)
		{
			if(pVehicle[s]==v)
			{
				pVehicle[s]=-1;
				break;
			}
		}
	}
	for(new i;i<MAX_VEHICLES;i++)
	{
		if(pVehicle[i]==-1)
		{
			pVehicle[i]=CreateVehicle(model, x, y, z, a, -1, -1, 1000);
			PutPlayerInVehicle(playerid, pVehicle[i], 0);
			break;
		}
	}
}
stock v_Engine(v, t=-1)
{
	new e, l, a, d, bn, bt, o;
	GetVehicleParamsEx(v, e, l, a, d, bn, bt, o);
	if(t!=-1)SetVehicleParamsEx(v, t, l, a, d, bn, bt, o);
	return e;
}
stock v_Lights(v, t=-1)
{
	new e, l, a, d, bn, bt, o;
	GetVehicleParamsEx(v, e, l, a, d, bn, bt, o);
	if(t!=-1)SetVehicleParamsEx(v, e, t, a, d, bn, bt, o);
	return l;
}
stock v_Alarm(v, t=-1)
{
	new e, l, a, d, bn, bt, o;
	GetVehicleParamsEx(v, e, l, a, d, bn, bt, o);
	if(t!=-1)SetVehicleParamsEx(v, e, l, t, d, bn, bt, o);
	return a;
}
stock v_Doors(v, t=-1)
{
	new e, l, a, d, bn, bt, o;
	GetVehicleParamsEx(v, e, l, a, d, bn, bt, o);
	if(t!=-1)SetVehicleParamsEx(v, e, l, a, t, bn, bt, o);
	return d;
}
stock v_Bonnet(v, t=-1)
{
	new e, l, a, d, bn, bt, o;
	GetVehicleParamsEx(v, e, l, a, d, bn, bt, o);
	if(t!=-1)SetVehicleParamsEx(v, e, l, a, d, t, bt, o);
	return bn;
}
stock v_Boot(v, t=-1)
{
	new e, l, a, d, bn, bt, o;
	GetVehicleParamsEx(v, e, l, a, d, bn, bt, o);
	if(t!=-1)SetVehicleParamsEx(v, e, l, a, d, bn, t, o);
	return bt;
}


SysMsg(playerid, msg[])
{
	static _message[128];
	format(_message, 128, "{FFFF00}[] {FFFFFF}%s", FormatColours(msg));
	SendClientMessage(playerid, 0xFFFFFFFF, _message);
	return false;
}
FormatColours(str[])
{
	new result[256];
	for(new x;x<8;x++)
	{
	    new c;
	    while(c < strlen(str))
	    {
	    	new f=strfind(str, cArray[x][0], false, c);
	    	if(f!=-1)
			{
			    strdel(str, f, f+strlen(cArray[x][0]));
				strins(str, cArray[x][1], f, strlen(cArray[x][1]));
				c=f+strlen(cArray[x][1]);
			}
			else
			{
				break;
			}
		}
	}
	format(result, 256, "%s", str);
	return result;
}
GetName(playerid)
{
	static _n[24];
	GetPlayerName(playerid, _n, 24);
	return _n;
}
/*
CheckStrGameText(str[])
{
	static _s[100];
	format(_s, 100, str);
	new trillChr[9]={'r','g','b','w','y','p','b','n','h'};
	for(new c;c<strlen(_s);c++)
	{
	    if(_s[c]=='~')
	    {
			for(new x=0;x<9;x++)
			{
			    if(_s[c+1]==trillChr[x] && _s[c+2]=='~')
				{
					printf("RIGHT %c :: %c", _s[c+1], trillChr[x]);
					printf(" %c %c %c ", _s[c], _s[c+1], _s[c+2]);
					break;
				}
				else
				{
					printf("ERROR %c :: %c", _s[c+1], trillChr[x]);
					_s[c]='?';
				}
			}
		}
	}
	return _s;
}
*/


public OnPlayerKeyStateChange(playerid,newkeys,oldkeys)
{
	if(newkeys&KEY_CROUCH)
	{
		if( (Jump[playerid]) && (GetPlayerState(playerid) == PLAYER_STATE_DRIVER) )
		{
			new Float:Velocity[3];
			GetVehicleVelocity(GetPlayerVehicleID(playerid), Velocity[0], Velocity[1], Velocity[2]);
			SetVehicleVelocity(GetPlayerVehicleID(playerid), Velocity[0], Velocity[1], Velocity[2]+0.2);
		}
	}
}

CMDS_Lists(playerid, cmd[])
{
	cmd("/help")
	{
		SendClientMessage(playerid,0xFF0000AA,"*HELP*");
		SendClientMessage(playerid,0x0000FFAA,"For Rules -> {FFFF00}/rules");
	    SendClientMessage(playerid,0x0000FFAA,"For Teleport Commads -> {FFFF00}/tcmds");
	    SendClientMessage(playerid,0x0000FFAA,"For Vehicle Commands -> {FFFF00}/vcmds");
	    SendClientMessage(playerid,0x0000FFAA,"For Player Commands -> {FFFF00}/pcmds");
	    return 1;
	}
	cmd("/tcmds")
	{
	    SendClientMessage(playerid,0xFF0000AA,"Teleport Commands For The Server");
	    SendClientMessage(playerid,0x0000FFAA,"/stunts");
	    SendClientMessage(playerid,0x0000FFAA,"/jumps");
	    SendClientMessage(playerid,0x0000FFAA,"/drifts");
	    SendClientMessage(playerid,0x0000FFAA,"/modshops");
	    SendClientMessage(playerid,0x0000FFAA,"/fun");
	    return 1;
	}
	cmd("/vcmds")
	{
		SendClientMessage(playerid,0xFF0000AA,"Vehicle Commands For The Server");
	    SendClientMessage(playerid,0x0000FFAA,"/v -> Vehicle spawn menu");
	    SendClientMessage(playerid,0x0000FFAA,"/mod -> Vehicle mod menu");
	    SendClientMessage(playerid,0x0000FFAA,"/f -> To fix your car");
	    SendClientMessage(playerid,0x0000FFAA,"/ff -> To flip & fix your car");
	    SendClientMessage(playerid,0x0000FFAA,"/jump -> Bunny hops car (Press H)");
	    SendClientMessage(playerid,0x0000FFAA,"/nos -> To add 10x NOS to your car");
	    return 1;
	}
	cmd("/pcmds")
	{
		SendClientMessage(playerid,0xFF0000AA,"Player Commands For The Server");
	    SendClientMessage(playerid,0x0000FFAA,"/Heal -> To heal your self");
	    SendClientMessage(playerid,0x0000FFAA,"/kill -> To kill your self");
	    SendClientMessage(playerid,0x0000FFAA,"/skins -> List of Skins");
	    return 1;
	}
	cmd("/rules")
	{
		SendClientMessage(playerid,0xFF0000AA,"Rules For The Server");
 		SendClientMessage(playerid,0x0000FFAA,"Please do not annoy other players");
 		SendClientMessage(playerid,0x0000FFAA,"Do not use any cheats or mods that");
 		SendClientMessage(playerid,0x0000FFAA,"you can use to your advantage");
 		SendClientMessage(playerid,0x0000FFAA,"If admins notice any signs of Racism you'll get kicked immediately");
	    return 1;
	}
	
	cmd("/skins")
	{
		SendClientMessage(playerid,0xFF0000AA,"List of Skins");
	    SendClientMessage(playerid,0x0000FFAA,"/swat /fbi /army /medic /cop /fireman");
	    SendClientMessage(playerid,0x0000FFAA,"/biker /cj /whore /boxer /clown /elvis /punk");
	    return 1;
	}
	
	cmd("/drifts")
	{
	    SendClientMessage(playerid,0xFF0000AA,"Teleports To Drift Tracks");
	    SendClientMessage(playerid,0x0000FFAA,"/drfit -> Desert Down Hill Drift");
	    SendClientMessage(playerid,0x0000FFAA,"/drift2 -> Country Side Drift");
	    SendClientMessage(playerid,0x0000FFAA,"/drift3 -> Drift To University");
	    return 1;
	}
	
	cmd("/stunts")
	{
	    SendClientMessage(playerid,0xFF0000AA,"Teleports To Stunt Parks");
	    SendClientMessage(playerid,0x0000FFAA,"/lvair -> Stunt Park At LV Airport");
	    SendClientMessage(playerid,0x0000FFAA,"/sfair -> Stunt Park At SF Airport");
	    SendClientMessage(playerid,0x0000FFAA,"/lsair -> Stunt Park at LS Airport");
	    SendClientMessage(playerid,0x0000FFAA,"/aa -> Stunt Park at Desert Airport");
	    SendClientMessage(playerid,0x0000FFAA,"/bstunts -> Stunt Park At Stadium (Will be added soon)");
	    return 1;
	}
	
	cmd("/jumps")
	{
	    SendClientMessage(playerid,0xFF0000AA,"Teleports To Jumps");
	    SendClientMessage(playerid,0x0000FFAA,"/lvjump -> Big Jump At LV Airport");
	    SendClientMessage(playerid,0x0000FFAA,"/aajump -> Big Jump At Desert Airport");
	    SendClientMessage(playerid,0x0000FFAA,"/lsjump -> Big Jump At LS Airport");
	    return 1;
	}
	
	cmd("/fun")
	{
	    SendClientMessage(playerid,0xFF0000AA,"Teleports To Fun Places");
	    SendClientMessage(playerid,0x0000FFAA,"/sumo -> Push Other Player Off The Building");
	    return 1;
	}
	
	cmd("/modshop")
	{
		SendClientMessage(playerid,0xFF0000AA,"/mod1");
	    SendClientMessage(playerid,0x0000FFAA,"/mod2");
	    SendClientMessage(playerid,0x0000FFAA,"/mod3");
	    SendClientMessage(playerid,0x0000FFAA,"/mod4");
	    return 1;
	}


	return 0;
}
CMDS_Teles(playerid, cmd[])
{
    cmd("/aajump")
    {
        if(IsPlayerInAnyVehicle(playerid)) SetVehiclePos(GetPlayerVehicleID(playerid), -1322.4812,2499.4392,684.1712);
        else SetPlayerPos(playerid,-1322.4812,2499.4392,684.1712);

        new string[64], pName[MAX_PLAYER_NAME];
    	GetPlayerName(playerid,pName,MAX_PLAYER_NAME);
    	format(string,sizeof string,"%s has gone to /aajump",pName);
    	SendClientMessageToAll(0xFF0000AA,string);
        return 1;
    }
	cmd("/sumo")
    {
        SetPlayerPos(playerid,-1771.9243,575.0182,234.8906);
   	    SetPlayerInterior(playerid, 0);
	    SetPlayerAmmo(playerid,24, 0);
        new string[64], pName[MAX_PLAYER_NAME];
    	GetPlayerName(playerid,pName,MAX_PLAYER_NAME);
    	format(string,sizeof string,"%s has gone to /sumo",pName);
    	SendClientMessageToAll(0xFF0000AA,string);
        return 1;
    }
	cmd("/lvjump")
    {
		if(GetPlayerState(playerid) == PLAYER_STATE_PASSENGER)
		{
			SendClientMessage(playerid,0xDEEE20FF,"You must be the driver");
		}
		else if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT || PLAYER_STATE_DRIVER)
		{
			new getv = GetPlayerVehicleID(playerid);
			SetVehiclePos(getv,1468.4205,174.0364,779.9617);
			SetPlayerPos(playerid,1468.4205,174.0364,779.9617);
			PutPlayerInVehicle(playerid,getv,0);
			new string[64], pName[MAX_PLAYER_NAME];
			GetPlayerName(playerid,pName,MAX_PLAYER_NAME);
			format(string,sizeof string,"%s has gone to /lvjump",pName);
			SendClientMessageToAll(0xFF0000AA,string);
		}
		return 1;
	}

	cmd("/mod1")
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_PASSENGER)SendClientMessage(playerid,0xDEEE20FF,"You must be the driver");
		else if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT || PLAYER_STATE_DRIVER)
		{
			new getv = GetPlayerVehicleID(playerid);
			SetVehiclePos(getv,-2688.2578,217.0226,3.7908);
			SetPlayerPos(playerid,-2688.2578,217.0226,3.7908);
			PutPlayerInVehicle(playerid,getv,0);
			new string[64], pName[MAX_PLAYER_NAME];
			GetPlayerName(playerid,pName,MAX_PLAYER_NAME);
			format(string,sizeof string,"%s has gone to /mod1",pName);
			SendClientMessageToAll(0xFF0000AA,string);
		}
		return 1;
    }
    
   	cmd("/mod2")
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_PASSENGER)SendClientMessage(playerid,0xDEEE20FF,"You must be the driver");
		else if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT || PLAYER_STATE_DRIVER)
		{
			new getv = GetPlayerVehicleID(playerid);
			SetVehiclePos(getv,-1935.4657,227.6112,33.7667);
			SetPlayerPos(playerid,-1935.4657,227.6112,33.7667);
			PutPlayerInVehicle(playerid,getv,0);
			new string[64], pName[MAX_PLAYER_NAME];
			GetPlayerName(playerid,pName,MAX_PLAYER_NAME);
			format(string,sizeof string,"%s has gone to /mod2",pName);
			SendClientMessageToAll(0xFF0000AA,string);
		}
		return 1;
    }
    
   	cmd("/mod3")
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_PASSENGER)SendClientMessage(playerid,0xDEEE20FF,"You must be the driver");
		else if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT || PLAYER_STATE_DRIVER)
		{
			new getv = GetPlayerVehicleID(playerid);
			SetVehiclePos(getv,2645.2939,-2023.4714,13.1572);
			SetPlayerPos(playerid,2645.2939,-2023.4714,13.1572);
			PutPlayerInVehicle(playerid,getv,0);
			new string[64], pName[MAX_PLAYER_NAME];
			GetPlayerName(playerid,pName,MAX_PLAYER_NAME);
			format(string,sizeof string,"%s has gone to /mod3",pName);
			SendClientMessageToAll(0xFF0000AA,string);
		}
		return 1;
    }

   	cmd("/mod4")
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_PASSENGER)SendClientMessage(playerid,0xDEEE20FF,"You must be the driver");
		else if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT || PLAYER_STATE_DRIVER)
		{
			new getv = GetPlayerVehicleID(playerid);
			SetVehiclePos(getv,2385.9702,1028.5890,10.4302);
			SetPlayerPos(playerid,2385.9702,1028.5890,10.4302);
			PutPlayerInVehicle(playerid,getv,0);
			new string[64], pName[MAX_PLAYER_NAME];
			GetPlayerName(playerid,pName,MAX_PLAYER_NAME);
			format(string,sizeof string,"%s has gone to /mod4",pName);
			SendClientMessageToAll(0xFF0000AA,string);
		}
		return 1;
    }

	cmd("/lv")
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_PASSENGER)SendClientMessage(playerid,0xDEEE20FF,"You must be the driver");
		else if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT || PLAYER_STATE_DRIVER)
		{
			new getv = GetPlayerVehicleID(playerid);
			SetVehiclePos(getv,1290.2660,1417.4924,11.1652);
			SetPlayerPos(playerid,1290.2660,1417.4924,11.1652);
			PutPlayerInVehicle(playerid,getv,0);
			new string[64], pName[MAX_PLAYER_NAME];
			GetPlayerName(playerid,pName,MAX_PLAYER_NAME);
			format(string,sizeof string,"%s has gone to /lv",pName);
			SendClientMessageToAll(0xFF0000AA,string);
		}
		return 1;
    }

	cmd("/lvsj")
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_PASSENGER)SendClientMessage(playerid,0xDEEE20FF,"You must be the driver");
		else if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT || PLAYER_STATE_DRIVER)
		{
			new getv = GetPlayerVehicleID(playerid);
			SetVehiclePos(getv,2063.3315,57.7492,569.1525);
			SetPlayerPos(playerid,2063.3315,57.7492,569.1525);
			PutPlayerInVehicle(playerid,getv,0);
			new string[64], pName[MAX_PLAYER_NAME];
			GetPlayerName(playerid,pName,MAX_PLAYER_NAME);
			format(string,sizeof string,"%s has gone to /lvsj",pName);
			SendClientMessageToAll(0xFF0000AA,string);
		}
		return 1;
    }
    
   	cmd("/sfair")
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_PASSENGER)SendClientMessage(playerid,0xDEEE20FF,"You must be the driver");
		else if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT || PLAYER_STATE_DRIVER)
		{
			new getv = GetPlayerVehicleID(playerid);
			SetVehiclePos(getv,-1257.1857,32.6583,13.2848);
			SetPlayerPos(playerid,-1257.1857,32.6583,13.2848);
			PutPlayerInVehicle(playerid,getv,0);
			new string[64], pName[MAX_PLAYER_NAME];
			GetPlayerName(playerid,pName,MAX_PLAYER_NAME);
			format(string,sizeof string,"%s has gone to /sfair",pName);
			SendClientMessageToAll(0xFF0000AA,string);
		}
		return 1;
    }
    
   	cmd("/lsjump")
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_PASSENGER)SendClientMessage(playerid,0xDEEE20FF,"You must be the driver");
		else if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT || PLAYER_STATE_DRIVER)
		{
			new getv = GetPlayerVehicleID(playerid);
			SetVehiclePos(getv,270.1019,-2592.0759,788.6701);
			SetPlayerPos(playerid,270.1019,-2592.0759,788.6701);
			PutPlayerInVehicle(playerid,getv,0);
			new string[64], pName[MAX_PLAYER_NAME];
			GetPlayerName(playerid,pName,MAX_PLAYER_NAME);
			format(string,sizeof string,"%s has gone to /lsjump",pName);
			SendClientMessageToAll(0xFF0000AA,string);
		}
		return 1;
    }
    

   	cmd("/lsair")
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_PASSENGER)SendClientMessage(playerid,0xDEEE20FF,"You must be the driver");
		else if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT || PLAYER_STATE_DRIVER)
		{
			new getv = GetPlayerVehicleID(playerid);
			SetVehiclePos(getv,2022.5292,-2630.5203,13.2996);
			SetPlayerPos(playerid,2022.5292,-2630.5203,13.2996);
			PutPlayerInVehicle(playerid,getv,0);
			new string[64], pName[MAX_PLAYER_NAME];
			GetPlayerName(playerid,pName,MAX_PLAYER_NAME);
			format(string,sizeof string,"%s has gone to /lsair",pName);
			SendClientMessageToAll(0xFF0000AA,string);
		}
		return 1;
    }

   	cmd("/drift")
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_PASSENGER)SendClientMessage(playerid,0xDEEE20FF,"You must be the driver");
		else if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT || PLAYER_STATE_DRIVER)
		{
			new getv = GetPlayerVehicleID(playerid);
			SetVehiclePos(getv,-295.4120,1538.9082,75.1729);
			SetPlayerPos(playerid,-295.4120,1538.9082,75.1729);
			PutPlayerInVehicle(playerid,getv,0);
			new string[64], pName[MAX_PLAYER_NAME];
			GetPlayerName(playerid,pName,MAX_PLAYER_NAME);
			format(string,sizeof string,"%s has gone to /drift",pName);
			SendClientMessageToAll(0xFF0000AA,string);
		}
		return 1;
    }
    
   	cmd("/drift2")
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_PASSENGER)SendClientMessage(playerid,0xDEEE20FF,"You must be the driver");
		else if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT || PLAYER_STATE_DRIVER)
		{
			new getv = GetPlayerVehicleID(playerid);
			SetVehiclePos(getv,-763.7161,-1679.6746,96.8421);
			SetPlayerPos(playerid,-763.7161,-1679.6746,96.8421);
			PutPlayerInVehicle(playerid,getv,0);
			new string[64], pName[MAX_PLAYER_NAME];
			GetPlayerName(playerid,pName,MAX_PLAYER_NAME);
			format(string,sizeof string,"%s has gone to /drift2",pName);
			SendClientMessageToAll(0xFF0000AA,string);
		}
		return 1;
    }

   	cmd("/drift3")
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_PASSENGER)SendClientMessage(playerid,0xDEEE20FF,"You must be the driver");
		else if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT || PLAYER_STATE_DRIVER)
		{
			new getv = GetPlayerVehicleID(playerid);
			SetVehiclePos(getv,-2406.8704,-597.5021,132.2579);
			SetPlayerPos(playerid,-2406.8704,-597.5021,132.2579);
			PutPlayerInVehicle(playerid,getv,0);
			new string[64], pName[MAX_PLAYER_NAME];
			GetPlayerName(playerid,pName,MAX_PLAYER_NAME);
			format(string,sizeof string,"%s has gone to /drift3",pName);
			SendClientMessageToAll(0xFF0000AA,string);
		}
	  	return 1;
    }
    return 0;
}


CMDS_Funcs(playerid, cmd[])
{
	cmd("/f")
    {
        print("called f");
        if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, 0xFFFFFFFF, "You are not in a vehicle!");
        RepairVehicle(GetPlayerVehicleID(playerid));
        SendClientMessage(playerid, 0xFFFFFFFF, "Your vehicle has been successfully repaired!");
        return 1;
    }
    cmd("/ff")
    {
        print("called ff");
        if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, 0xFFFFFFFF, "You are not in a vehicle!");
        new Float:a;
        RepairVehicle(GetPlayerVehicleID(playerid));
        GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
        SetVehicleZAngle(GetPlayerVehicleID(playerid), a);
        SendClientMessage(playerid, 0xFFFFFFFF, "Your vehicle has been flipped and fixed");
        return 1;
    }
    cmd("/jump")
    {
        if(Jump[playerid])
        {
            Jump[playerid]=false;
			SendClientMessage(playerid, 0xFFFFFFFF, "Jump Mode Off");
        }
        else
        {
            Jump[playerid]=true;
			SendClientMessage(playerid, 0xFFFFFFFF, "Jump Mode On");
        }
        return 1;
    }
    cmd("/heal")
    {
        SetPlayerHealth(playerid, 100);
        return 1;
    }
	cmd("/kill")
    {
        SetPlayerHealth(playerid, 0);
        return 1;
	}
    cmd("/nos")
    {
		new cs = GetPlayerState(playerid);
      	if(IsPlayerInAnyVehicle(playerid) && cs==PLAYER_STATE_DRIVER)
	  	{
 			new V_Id=GetPlayerVehicleID(playerid);
        	new vid=GetVehicleModel(V_Id);
        	if(vid==499 || vid==538 || vid==570 || vid==537 || vid==569 || vid==590 || vid==611 || vid==584 || vid==608 || vid==610 || vid==607 || vid==606 || vid==591 || vid==450 || vid==435 || vid==454 || vid==446 || vid==452 || vid==453 || vid==430 || vid==484 || vid==595 || vid==493 || vid==473 || vid==472 || vid==522 || vid==462 || vid==52 || vid==461 || vid==463 || vid==581 || vid==488 || vid==586 || vid==523 || vid==468 || vid==509 || vid==510 || vid==481)
			{
        		SendClientMessage(playerid, 0xFF0000AA, "ERROR: Current vehicle doesn't support Nitro Boost");
            	return 1;
        	}
        	else
			{
           		new string [256];
            	format(string, sizeof(string), "10x Nitro Boost Added.");
            	SendClientMessage(playerid,0x00FF00AA,string);
            	AddVehicleComponent(V_Id,1010);
            	return 1;
        	}
		}
		else
		{
             SendClientMessage(playerid, 0xFF0000AA, "ERROR: You need to be the driver of a vehicle.");
             return 1;
        }
	}

	return 0;
}
