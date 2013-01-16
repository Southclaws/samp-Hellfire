//----------------------------------------------------------------------------//
//                          San Andreas Free-for-All                          //
//            Freeroam with a side order of intense Deathmatching.            //
//		 	 Along with many Minigames, Races and other Activities			  //
//                                By Southclaw                                //
//----------------------------------------------------------------------------//


//=================================================================Include Files

#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS	(32)

#include <YSI\y_utils>
#include <YSI\y_va>
#include <YSI\y_timers>
#include <YSI\y_hooks>
#include <YSI\y_iterate>

#include <formatex>
#include <strlib>
#include <md-sort>
#include <geoip>
#include <sscanf2>
#include <streamer>
#include <CTime>
#include <IniFiles>
#include <bar>
#include <playerbar>
#include <rbits>
#include <CameraMover>

native WP_Hash(buffer[], len, const str[]);


//===================================================================Definitions


// Limits
#define MAX_RENDER_DISTANCE			(300.0)										// A global maximum distance for various things (streamer related)
#define MAX_MOTD_LEN				(128)
#define MAX_PLAYER_FILE				(MAX_PLAYER_NAME+14)
#define MAX_ADMIN					(16)
#define MAX_PASSWORD_LEN			(129)


// Files
#define PLAYER_DATA_FILE			"Player/%s.txt"
#define ACCOUNT_DATABASE			"Server/Accounts.db"
#define SETTINGS_FILE				"Server/Settings.txt"
#define HOUSE_DATA_FILE				"Server/Houses.txt"
#define ADMIN_DATA_FILE				"Server/AdminList.txt"


// Database Rows
#define ROW_NAME					"name"
#define ROW_PASS					"pass"
#define ROW_SKIN					"skin"
#define ROW_IPV4					"ipv4"

#define ROW_DATE					"date"
#define ROW_REAS					"reason"
#define ROW_BNBY					"by"

#define ROW_KILLS					"kills"
#define ROW_DEATHS					"deaths"
#define ROW_EXP						"experience"
#define ROW_HEADSHOTS				"headshots"
#define ROW_TEAMKILLS				"teamkills"
#define ROW_HIGHSTREAK				"higheststreak"
#define ROW_WINS					"wins"
#define ROW_LOSSES					"losses"


// File Keys
#define KEY_JCNT					"jcnt"
#define KEY_CASH					"cash"

#define KEY_T_RG					"t_rg"
#define KEY_T_GL					"t_gl"
#define KEY_T_VH					"t_vh"
#define KEY_T_FT					"t_ft"
#define KEY_T_LG					"t_lg"


// Constants
#define CHANNEL_GLOBAL				(-1)
#define CHANNEL_TEAM				(50)
#define CHANNEL_VEHICLE				(51)

#define TEAM_RAVEN					(0)
#define TEAM_VALOR					(1)
#define TEAM_GLOBAL					(2)

#define MINIGAME_NONE				(-1)
#define MINIGAME_PARKOUR			(0)
#define MINIGAME_FALLOUT			(1)
#define MINIGAME_DGETWET			(2)
#define MINIGAME_CARSUMO			(3)
#define MINIGAME_DESDRBY			(4)
#define MINIGAME_PRDRIVE			(5)
#define MINIGAME_GUNGAME			(6)
#define MINIGAME_COLLECT			(7)
#define MINIGAME_HALOPAR			(8)

#define CHALLENGE_NONE				(-1)
#define CHALLENGE_MARKEDMAN			(0)
#define CHALLENGE_JUGGERNAUT		(1)

#define RUN_VELOCITY				(20)
#define CROUCH_VELOCITY				(20)
		
#define MAX_RUN_ALPHA				(255)
#define MIN_RUN_ALPHA				(100)
#define MAX_CROUCH_ALPHA			(35)
#define MIN_CROUCH_ALPHA			(0)


// Functions
#define PlayerLoop(%0)				foreach(new %0 : Player)

#define bitTrue(%1,%2)				((%1)|=(%2))								// For binary boolean setting arrays
#define bitFalse(%1,%2)				((%1)&=~(%2))

#define t:%1<%2>					((%1)|=(%2))								// I had this idea at a later date!
#define f:%1<%2>					((%1)&=~(%2))								// So there's a mix of both these methods just to add confusion! Don't worry, they do the same thing, just quicker to write.

#define strcpy(%0,%1)				strcat((%0[0] = '\0', %0), %1)
#define GetFile(%0,%1)				format(%1, MAX_PLAYER_FILE, PLAYER_DATA_FILE, %0)
#define RandomBounds(%1,%2)			(random((%2)-(%1))+(%1))
#define RandomCondition(%1)			(random(100)<(%1))

#define KEY_RELEASED(%0)			(((newkeys&(%0))!=(%0))&&((oldkeys&(%0))==(%0)))
#define KEY_PRESSING(%0)			(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#define KEY_HOLDING(%0)				((newkeys & (%0)) == (%0))
#define KEY_AIMFIRE					(132)

#define CMD:%1(%2)					forward cmd_%1(%2);\
									public cmd_%1(%2)							// I wrote my own command processor to fit my needs!

#define ACMD:%1[%2](%3)				forward cmd_%1_%2(%3);\
									public cmd_%1_%2(%3)						// Admin only commands, the [parameter] in the brackets is the admin level.

// Player Data
#define pAdmin(%1)					gPlayerData[%1][ply_Admin]
#define pSkin(%1)					gPlayerData[%1][ply_Skin]

#define pKills(%1)					dm_PlayerData[%1][dm_Kills]
#define pDeaths(%1)					dm_PlayerData[%1][dm_Deaths]
#define pExp(%1)					dm_PlayerData[%1][dm_Exp]
#define pRank(%1)					dm_PlayerData[%1][dm_Rank]
#define pHeadShot(%1)				dm_PlayerData[%1][dm_HeadShots]

#define pTeam(%1)					dm_PlayerData[%1][dm_Team]
#define pKit(%1)					dm_PlayerData[%1][dm_Kit]
#define pGear(%1)					dm_PlayerData[%1][dm_Gear]
#define pStreak(%1)					dm_PlayerData[%1][dm_Streak]
#define pCombo(%1)					dm_PlayerData[%1][dm_Combo]
#define poTeam(%1)					((dm_PlayerData[%1][dm_Team]*-1)+1)


// Colours
#define YELLOW						0xFFFF00AA

#define RED							0xE85454AA
#define GREEN						0x33AA33AA
#define BLUE						0x33CCFFAA

#define ORANGE						0xFFAA00AA
#define GREY						0xAFAFAFAA
#define PINK						0xFFC0CBAA
#define NAVY						0x000080AA
#define GOLD						0xB8860BAA
#define LGREEN						0x00FD4DAA
#define TEAL						0x008080AA
#define BROWN						0xA52A2AAA
#define AQUA						0xF0F8FFAA

#define BLACK						0x000000AA
#define WHITE						0xFFFFFFAA


// Embedding Colours
#define C_YELLOW					"{FFFF00}"

#define C_RED						"{E85454}"
#define C_GREEN						"{33AA33}"
#define C_BLUE						"{33CCFF}"

#define C_ORANGE					"{FFAA00}"
#define C_GREY						"{AFAFAF}"
#define C_PINK						"{FFC0CB}"
#define C_NAVY						"{000080}"
#define C_GOLD						"{B8860B}"
#define C_LGREEN					"{00FD4D}"
#define C_TEAL						"{008080}"
#define C_BROWN						"{A52A2A}"
#define C_AQUA						"{F0F8FF}"

#define C_BLACK						"{000000}"
#define C_WHITE						"{FFFFFF}"


#define C_SPECIAL					"{0025AA}"


#define ATTACHSLOT_ITEM				(0)
#define ATTACHSLOT_USE				(1)
#define ATTACHSLOT_HOLSTER			(2)
#define ATTACHSLOT_HOLD				(3)

//==============================================================SERVER VARIABLES


enum
{
	FREEROAM_WORLD,		// 0
	DEATHMATCH_WORLD,	// 1
	RACE_WORLD,			// 2
	MINIGAME_WORLD,		// 3
	ADVENTURE_WORLD		// 4
}
enum
{
	MISC_SLOT_1,
	MISC_SLOT_2,
	MISC_SLOT_3,
	MISC_SLOT_4,
	MISC_SLOT_5,
	MISC_SLOT_6,
	MISC_SLOT_7,

	SIDEARM_SLOT,
	PRIMARY_SLOT,
	GHILLIE_SLOT

}
enum
{
	d_NULL,

	d_Login,
	d_Register,
    d_WelcomeMsg,
	d_LogMsg,

	d_RegionSelect,
	d_RegionMaps,
	d_ModeSelect,
	d_RegionInfo,
	d_MapInfo,
	d_ModeInfo,
	d_Settings,
	d_SettingsInfo,
	d_Scorelim,
	d_Ticketlim,
	d_Flaglim,
	d_Forcelim,
	d_Matchtime,

	d_CustomiseMenu,
	d_KitMenu,
	d_KitInfo,
	d_LoadoutPri,
	d_LoadoutAlt,
	d_GraphicList,
	d_Gearselect,
	d_Gearinfo,
	d_Spawnpoint,
	d_Colourlist,

	d_RaceJoin,
	d_RaceInfo,
	d_RaceScores,

	d_ParkourList,
	d_ParkourScores,
	d_DgwType,
	d_DgwJoin,
	d_SumoArenaList,
	d_DerbyArenaList,
	d_SumoVehicleList,
	d_DerbyVehicleList,
	d_PrdList,
	d_PrdScores,
	d_GungameList,
	d_CollectList,
	d_CollectScores,
	d_ChallengeList,

	d_Help,
	d_Cmds,
	d_Fun,
	d_Minigames,
	d_Places,
	d_Drifts,
	d_Jumps,
	d_Tuning,
	d_PCmds,
	d_VCmds,
	d_Misc,

	d_Stats,
	d_SpectateGroupList,
	d_SpawnList,
	d_FreeDmAreaList,

	d_VehicleIndex,
	d_VehicleList,
	d_VehicleQuery,
	d_VehicleResults,

	d_WeaponIndex,
	d_WeaponList,
	d_WeaponQuery,
	d_WeaponResults,

	d_TeleportIndex,
	d_TeleportList,
	d_TeleportQuery,
	d_TeleportResults,
	
	d_GeneralStore,
	d_Inventory,
	d_InventoryOptions,
	d_InventoryCombine,
	d_ContainerInventory,
	d_ContainerOptions,
	d_ContainerPlayerInv,
	d_ContainerPlayerInvOptions,
	d_SignEdit,

	d_CarBuy,
	d_CarBuyConfirm,
	d_eVehicleMod,
	d_eWheels,
	d_eColours,
	d_ePaintjob,
	d_eItemList,
	d_WeatherList,

	d_RadioList
}

enum E_HOME_SPAWN_DATA
{
	Float:spn_camX,
	Float:spn_camY,
	Float:spn_camZ,

	Float:spn_lookX,
	Float:spn_lookY,
	Float:spn_lookZ,

	Float:spn_posX,
	Float:spn_posY,
	Float:spn_posZ,
	Float:spn_rotZ
}

new
	HORIZONTAL_RULE[]=
	{"-------------------------------------------------------------------------------------------------------------------------"},
	InfoBarText[10][68]=
	{
		{"~y~/help~b~ - General help dialog"},
		{"~y~/cmds~b~ - Main commands list"},
		{"~y~/fun~b~ - Activities to do on the server"},
		{"~y~/teles~b~ - Teleports to various places"},
		{"~y~/rules~b~ - The server rules - read so you don't get kicked!"},
		{"~y~/home~b~ - Exit current activity and return to your spawn point"},
		{"~y~/f~b~ - Fix and flip your car"},
		{"~y~/joindm~b~ - Join a deathmatch"},
		{"~y~/mystats~b~ - Information on your stats"},
		{"~y~Visit The Forum: ~b~forums.empire-bay.com"}
	},
	Float:HomeSpawnData[8][E_HOME_SPAWN_DATA] =
	{
		{2051.93, 1343.07, 34.50,	2046.93, 1343.11, 29.74,	2032.28, 1342.81, 10.82, 90.0},		// LV
		{-2037.54, 245.96, 62.20,	-2033.24, 247.60, 60.24,	-1986.24, 288.51, 34.26, 270.0},	// SF
		{1212.34, -1394.96, 42.63,	1211.34, -1390.35, 40.99,	1186.82,-1324.14,13.55, 0.0},		// LS
		{-223.11, 1484.04, 86.42,	-226.72, 1487.50, 87.01,	-292.06, 1535.98, 75.56, 180.0},	// EAR
		{-2165.44, -1737.3, 505.9,	-2170.10, -1735.77, 505.05,	-2315.46, -1667.93, 482.95, 270.0},	// CHILLIAD
		{1374.24, 1307.99, 21.92,	1370.60, 1304.73, 20.84,	1324.44, 1485.65, 10.82, 0.0},		// LV Airport
		{-1132.24, 26.62, 45.91,	-1136.89, 26.54, 44.05,		-1225.17, 45.78, 14.13, 0.0},		// SF Airport
		{2091.90, -2653.24, 37.73,	2088.02, -2650.29, 36.61,	2056.75, -2620.56, 13.54, 0.0}		// LS Airport
	},
	SpawnNames[8][21]=
	{
	    "Las Venturas",
	    "San Fierro",
	    "Los Santos",
	    "The Big Ear",
	    "Mount Chilliad",
	    "Las Venturas Airport",
	    "San Fierro Airport",
	    "Los Santos Airport"
	},
	RadioStreams[7][2][64]=
	{
		{"http://46.251.246.101:11021/listen.pls", "Empire Bay Web Radio"},
		{"http://somafm.com/covers.pls", "Covers"},
		{"http://somafm.com/480min.pls", "480 Min"},
		{"http://somafm.com/bootliquor.pls", "Boot Liquor"},
		{"http://somafm.com/spacestation.pls", "Space Station Soma"},
		{"http://somafm.com/u80s.pls", "Underground 80s"},
		{"http://78.129.163.140:8070/listen.pls", "TheRockStream"}
	},
	RandomCountries[5][16]=
	{
		"Narnia",
		"Mordor",
		"Liberty City",
		"Vice City",
		"Alderaan"
	};
	new
		ItemIndex:GeneralStore,
		AmmuArea[5];

//=====================Player Skins
new gSkins[2][22]=
{
	{22, 25, 28, 29, 30, 47, 50, 67, 73,101,111,112,113,121,122,123, 126,128,170,188,249},
	{13, 40, 41, 56, 90, 91, 93, 192,13, 40,41, 56, 90, 91, 93, 192, 13, 40, 41, 56, 90}
};

//=====================Player Tag Names
new const AdminName[5][14]=
{
	"Player",			// 0
	"Game-Master",		// 1
	"Moderator",		// 2
	"Administrator",	// 3
	"Owner"				// 4
},
AdminColours[5]=
{
    0xFFFFFFFF,		// 0
    0x5DFC0AFF,		// 1
    0x33CCFFAA,		// 2
	0x6600FFFF,		// 3
	0x6600FFFF		// 4
};


//=====================Server Global Settings
enum (<<=1)
{
	ChatLocked = 1,
	ServerLocked,
	Restarting,
	ScheduledRestart,

	Realtime,
	ServerTimeFlow,
	FreeroamCommands,

	FreeDM,
	WeaponLock,

	dm_InProgress,
	dm_Started,
	dm_LobbyCounting,
	
	rc_InProgress,
	rc_Started,
	
	smo_InProgress,
	dby_InProgress
}
enum e_admin_data
{
	admin_Name[MAX_PLAYER_NAME],
	admin_Level
}
new
	bServerGlobalSettings,
	gMessageOfTheDay[MAX_MOTD_LEN],
	gAdminData[MAX_ADMIN][e_admin_data],
	gTotalAdmins,
	gCurrentChallenge = CHALLENGE_NONE;

enum E_WEATHER_DATA
{
	weather_id,
	weather_name[24]
}
enum E_TIME_DATA
{
	time_hour,
	time_name[11]
}
new
	WeatherData[20][E_WEATHER_DATA]=
	{
		{0, "EXTRASUNNY_LS"},
		{1, "SUNNY_LS"},
		{2, "EXTRASUNNY_SMOG_LS"},
		{3, "SUNNY_SMOG_LS"},
		{4, "CLOUDY_LS"},

		{5, "SUNNY_SF"},
		{6, "EXTRASUNNY_SF"},
		{7, "CLOUDY_SF"},
		{8, "RAINY_SF"},
		{9, "FOGGY_SF"},

		{10, "SUNNY_LV"},
		{11, "EXTRASUNNY_LV"},
		{12, "CLOUDY_LV"},

		{13, "EXTRASUNNY_COUNTRYSIDE"},
		{14, "SUNNY_COUNTRYSIDE"},
		{15, "CLOUDY_COUNTRYSIDE"},
		{16, "RAINY_COUNTRYSIDE"},

		{17, "EXTRASUNNY_DESERT"},
		{18, "SUNNY_DESERT"},
		{19, "SANDSTORM_DESERT"}
	},
	TimeData[5][E_TIME_DATA]=
	{
		{00, "Midnight"},
		{05, "Morning"},
		{12, "Midday"},
		{15, "Afternoon"},
		{20, "Dusk"}
	};


//=====================Clock and Timers
new
				gTimeHour,
				gTimeMinute,
				gWeatherID,
				gLastWeatherChange,
				gCountMinute,
				gCountSecond,
				gTempStr[36];

//=====================Menus and Textdraws
new
Text:			InfoBar				= INVALID_TEXT_DRAW,
Text:			ClockText			= INVALID_TEXT_DRAW,
Text:			StopAnimText		= INVALID_TEXT_DRAW,

PlayerText:		VehicleNameText		= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		VehicleSpeedText	= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		TimerText			= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		AddHPText			= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		AddCashText			= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		AddScoreText		= PlayerText:INVALID_TEXT_DRAW,

PlayerText:		SpecControl_Name	= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		SpecControl_Text	= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		SpecControl_BtnL	= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		SpecControl_BtnR	= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		SpecControl_Mode	= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		SpecControl_Hide	= PlayerText:INVALID_TEXT_DRAW,

PlayerBar:		ActionBar			= INVALID_PLAYER_BAR_ID;

new
DispenserType:	disp_HealoMatic;


//==============================================================PLAYER VARIABLES

enum (<<= 1) // 30
{
		HasAccount = 1,
		LoggedIn,
		Spawned,
		FirstSpawn,

		InDM,
		InRace,
		InFreeDM,
		prk_Started,
		prk_SkipIntro,
		clt_Started,
		clt_SkipIntro,

		SpeedBoost,
		JumpBoost,
		AntiFallOffBike,

		RegenHP,
		RegenAP,
		Invis,
		GodMode,
		Frozen,
		Muted,
		WepLock,
		GodLock,
		DmgLock,

		LoopingAnimation,
		AfkCheck,
		IsAfk,
		DebugMode,

		ViewingRaceIcons,
		ViewingHelp,
		ViewingMap
}
enum E_PLAYER_DATA
{
		ply_Password[MAX_PASSWORD_LEN],
		ply_Admin,
		ply_Skin,
		ply_Cash,
		ply_Sex,
		ply_IP,
		ply_RegDate,
		ply_LastLogged,
		ply_Joins,
		ply_JoinTick,
		ply_TimePlayed,
		ply_TimeInVeh,
		ply_TimeOnFoot,
}
enum E_SAVE_DATA
{
Float:	sp_posX,
Float:	sp_posY,
Float:	sp_posZ,
Float:	sp_rotation,
		sp_world,
		sp_interior
}

new
		DB:gAccounts,
		IncorrectPass			[MAX_PLAYERS],
		Warnings				[MAX_PLAYERS],

		gPlayerData				[MAX_PLAYERS][E_PLAYER_DATA],
		bPlayerGameSettings		[MAX_PLAYERS],

		gPlayerName				[MAX_PLAYERS][MAX_PLAYER_NAME],
Float:	gPlayerHP				[MAX_PLAYERS],
Float:	gPlayerAP				[MAX_PLAYERS],
		gPlayerColour			[MAX_PLAYERS],
		gPlayerVehicleID		[MAX_PLAYERS],
Float:	gPlayerVelocity			[MAX_PLAYERS],
		gPlayerSpawnedVehicle	[MAX_PLAYERS],
		gPlayerQuickChat		[MAX_PLAYERS][10][50],
		gPlayerSavePosition		[MAX_PLAYERS][E_SAVE_DATA],
		gHomeSpawn				[MAX_PLAYERS],
		gWeaponHitTick			[MAX_PLAYERS],
		gPlayerDeathTick		[MAX_PLAYERS],

		gPlayerChatChannel		[MAX_PLAYERS],
		Blocked					[MAX_PLAYERS][MAX_PLAYERS],
		Hidden					[MAX_PLAYERS][MAX_PLAYERS],
		gCurrentMinigame		[MAX_PLAYERS],

		tick_StartRegenHP		[MAX_PLAYERS],
		tick_StartRegenAP		[MAX_PLAYERS],
		tick_ExitVehicle		[MAX_PLAYERS],
		tick_LastChatMessage	[MAX_PLAYERS],
		ChatMessageStreak		[MAX_PLAYERS],
		ChatMuteTick			[MAX_PLAYERS],
Text3D:	gPlayerAfkLabel			[MAX_PLAYERS],
Float:	TankHeat				[MAX_PLAYERS],
Timer:	TankHeatUpdateTimer		[MAX_PLAYERS],

		EnterVehTick			[MAX_PLAYERS],
		EnterFootTick			[MAX_PLAYERS];



stock GetGenderFromSkin(skinid)
{
	for(new i;i<sizeof(gSkins[]);i++)if(skinid==gSkins[0][i]) return 0;
	return 1;
}

DriverTickStart(playerid)
{
	EnterVehTick[playerid]=tickcount();
}
DriverTickEnd(playerid)
{
	if(EnterVehTick[playerid]==0)return 0xFF;
	gPlayerData[playerid][ply_TimeInVeh]+=(tickcount()-EnterVehTick[playerid]);
	EnterVehTick[playerid]=0;
	return 1;
}
WalkerTickStart(playerid)
{
	EnterFootTick[playerid]=tickcount();
}
WalkerTickEnd(playerid)
{
	if(EnterFootTick[playerid]==0)return 0xFF;
	gPlayerData[playerid][ply_TimeOnFoot]+=(tickcount()-EnterFootTick[playerid]);
	EnterFootTick[playerid]=0;
	return 1;
}


forward OnLoad();

forward OnPlayerEnterPlayerArea(playerid, targetid);
forward OnPlayerLeavePlayerArea(playerid, targetid);

forward OnDeath(playerid, killerid, reason);


//======================Libraries of Resources

#include "../scripts/Resources/VehicleResources.pwn"
#include "../scripts/Resources/PlayerResources.pwn"
#include "../scripts/Resources/WeaponResources.pwn"
#include "../scripts/Resources/EnvironmentResources.pwn"
#include "../scripts/Resources/Specifiers.pwn"

//======================Libraries of Functions

#include "../scripts/System/Hooks.pwn"
#include "../scripts/System/Functions.pwn"
#include "../scripts/System/MathFunctions.pwn"
#include "../scripts/System/PlayerFunctions.pwn"
#include "../scripts/System/VehicleFunctions.pwn"
#include "../scripts/System/Trajectory.pwn"
#include "../scripts/System/MessageBox.pwn"
#include "../scripts/Handcuffs.pwn"

//======================API Scripts

#include "../scripts/SIF/Core.pwn"
#include "../scripts/SIF/Button.pwn"
#include "../scripts/SIF/Door.pwn"
#include "../scripts/SIF/Item.pwn"
#include "../scripts/SIF/Inventory.pwn"
#include "../scripts/SIF/Container.pwn"

#include "../scripts/SIF/Modules/WeaponItems.pwn"
#include "../scripts/SIF/Modules/Craft.pwn"
#include "../scripts/SIF/Modules/Dispenser.pwn"


#include "../scripts/API/Balloon/Balloon.pwn"
#include "../scripts/API/Checkpoint/Checkpoint.pwn"
#include "../scripts/API/Line/Line.pwn"
#include "../scripts/API/Zipline/Zipline.pwn"
#include "../scripts/API/Ladder/Ladder.pwn"
#include "../scripts/API/Turret/Turret.pwn"
#include "../scripts/API/SprayTag/SprayTag.pwn"

#include "../scripts/Items/misc.pwn"
#include "../scripts/Items/firework.pwn"
#include "../scripts/Items/medkit.pwn"
#include "../scripts/Items/beer.pwn"
#include "../scripts/Items/timebomb.pwn"
#include "../scripts/Items/Sign.pwn"
#include "../scripts/Items/adrenaline.pwn"
#include "../scripts/Items/electroap.pwn"
#include "../scripts/Items/briefcase.pwn"
#include "../scripts/Items/backpack.pwn"

#include "../scripts/CountDown.pwn"

//======================Gameplay Scripts

#include "../scripts/Deathmatch.pwn"
#include "../scripts/Race.pwn"
#include "../scripts/FreeDM.pwn"
#include "../scripts/Minigames.pwn"
#include "../scripts/Challenges.pwn"

#include "../scripts/Road.pwn"
#include "../scripts/Misc.pwn"
#include "../scripts/Maps/Gen_LS.pwn"
#include "../scripts/Maps/Gen_SF.pwn"
#include "../scripts/Maps/Gen_LV.pwn"
#include "../scripts/Maps/Gen_Red.pwn"
#include "../scripts/Maps/Gen_Flint.pwn"
#include "../scripts/Maps/Gen_Des.pwn"
#include "../scripts/Maps/Area69.pwn"
#include "../scripts/Maps/Ranch.pwn"
#include "../scripts/Maps/MtChill.pwn"

#include "../scripts/Spectate.pwn"
#include "../scripts/VehicleMods.pwn"
#include "../scripts/VehicleMenu.pwn"
#include "../scripts/WeaponMenu.pwn"
#include "../scripts/GeneralStore.pwn"

#include "../scripts/VehicleSpawn.pwn"
#include "../scripts/GUI.pwn"
#include "../scripts/HudMap.pwn"

#include "../scripts/Commands/Commands.pwn"

//======================Unused or Awaiting Fix

/*
#include "../scripts/Teleporter.pwn"
#include "../scripts/CarShop.pwn"
#include "../scripts/Houses.pwn"
#include "../scripts/StuntAreas.pwn"
#include "../scripts/StuntJumps.pwn"
#include "../scripts/TagGame.pwn"
#include "../scripts/Testing.pwn"
*/


main()
{
	new
		DBResult:tmpResult,
	    rowCount,
		tmpCurPass[MAX_PASSWORD_LEN],
		tmpName[MAX_PLAYER_NAME],
		tmpHashPass[MAX_PASSWORD_LEN],
		tmpQuery[512];

	gAccounts = db_open(ACCOUNT_DATABASE);

	db_free_result(db_query(gAccounts, "CREATE TABLE IF NOT EXISTS `Player` (`"#ROW_NAME"`, `"#ROW_PASS"`, `"#ROW_SKIN"`, `"#ROW_IPV4"`)"));
	db_free_result(db_query(gAccounts, "CREATE TABLE IF NOT EXISTS `Bans` (`"#ROW_NAME"`, `"#ROW_IPV4"`, `"#ROW_DATE"`, `"#ROW_REAS"`, `"#ROW_BNBY"`)"));
	db_free_result(db_query(gAccounts, "CREATE TABLE IF NOT EXISTS `Deathmatch` (`"#ROW_NAME"`, `"#ROW_KILLS"`, `"#ROW_DEATHS"`, `"#ROW_EXP"`, `"#ROW_HEADSHOTS"`, `"#ROW_TEAMKILLS"`, `"#ROW_HIGHSTREAK"`, `"#ROW_WINS"`, `"#ROW_LOSSES"`)"));

	tmpResult = db_query(gAccounts, "SELECT * FROM `Player`");
	rowCount = db_num_rows(tmpResult);

	if(rowCount > 0)
	{
		for(new i;i<rowCount;i++)
		{
		    db_get_field_assoc(tmpResult, #ROW_PASS, tmpCurPass, MAX_PASSWORD_LEN);
		    db_get_field_assoc(tmpResult, #ROW_NAME, tmpName, MAX_PASSWORD_LEN);
		    if(strlen(tmpCurPass) < 128)
		    {
		        WP_Hash(tmpHashPass, MAX_PASSWORD_LEN, tmpCurPass);

		        format(tmpQuery, 512,
		            "UPDATE `Player` SET `"#ROW_PASS"` = '%s' WHERE `"#ROW_NAME"` = '%s'",
		            tmpHashPass, tmpName);

				db_free_result(db_query(gAccounts, tmpQuery));
		    }
		    db_next_row(tmpResult);
		}
	}
	db_free_result(tmpResult);



	file_Open(SETTINGS_FILE);

	print("\n-------------------------------------");
	printf(" %s",						gTempStr);
	print("  ----  Server Data  ----");
	printf("   %d\t- Visitors",			file_GetVal("Connections"));
	printf("   %d\t- Accounts",			rowCount);
	printf("   %d\t- Administrators",	gTotalAdmins);
	printf("   %d\t- Total DM Maps",	dm_TotalMaps);
	printf("   %d\t- Total Races",		rc_TotalTracks);
	print("-------------------------------------\n");

	file_Close();
}





























public OnGameModeInit()
{
	print("Starting Main Game Script 'sffa' ...");

	file_OS();
	SetGameModeText("Freeroam [No DM]");
	SetMapName("San Andrawesome");

	EnableStuntBonusForAll(false);
    ManualVehicleEngineAndLights();
	SetNameTagDrawDistance(36000.0);
	UsePlayerPedAnims();
	AllowInteriorWeapons(true);
	ShowNameTags(true);

	t:bServerGlobalSettings<FreeroamCommands>;
	t:bServerGlobalSettings<ServerTimeFlow>;
	f:bServerGlobalSettings<WeaponLock>;
	dm_Host				= -1;

	gTimeMinute			= random(60);
	gTimeHour			= random(24);
	gWeatherID			= WeatherData[random(sizeof(WeatherData))][weather_id];
	gLastWeatherChange	= tickcount();

/*
	Group_Create("Deathmatch");
	Group_Create("Raven");
	Group_Create("Valor");
	Group_Create("Race");
	Group_Create("Parkour");
	Group_Create("Fallout");
	Group_Create("Car Sumo");
	Group_Create("Derby");
*/

	for(new c;c<20;c++)
	{
		AddPlayerClass(gSkins[0][c], 2268.9895, 1518.6492, 42.8156, 271.1070, 0, 0, 0, 0, 0, 0);
		AddPlayerClass(gSkins[1][c], 2268.9895, 1518.6492, 42.8156, 271.1070, 0, 0, 0, 0, 0, 0);
	}


	if(!fexist(SETTINGS_FILE))
		file_Create(SETTINGS_FILE);

	else
	{
	    file_Open(SETTINGS_FILE);
		file_GetStr("motd", gMessageOfTheDay);
	    file_Close();
	}

	if(!fexist(HOUSE_DATA_FILE))
		file_Create(HOUSE_DATA_FILE);

	if(!fexist(ADMIN_DATA_FILE))
		file_Create(ADMIN_DATA_FILE);

	else
	{
		new
			File:tmpFile = fopen(ADMIN_DATA_FILE, io_read),
			line[MAX_PLAYER_NAME + 4];

		while(fread(tmpFile, line))
		{
			sscanf(line, "p<=>s[24]d", gAdminData[gTotalAdmins][admin_Name], gAdminData[gTotalAdmins][admin_Level]);
			gTotalAdmins++;
		}
		fclose(tmpFile);
		SortDeepArray(gAdminData, admin_Level, .order = SORT_DESC);
	}

	item_Medkit			= DefineItemType("Medkit",			1580,	ITEM_SIZE_SMALL, 0.0, 0.0, 0.0, 0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
	item_HardDrive		= DefineItemType("Hard Drive",		328,	ITEM_SIZE_SMALL);
	item_Key			= DefineItemType("Key",				327,	ITEM_SIZE_SMALL);
	item_FireworkBox	= DefineItemType("Firework Box",	3014,	ITEM_SIZE_LARGE);
	item_FireLighter	= DefineItemType("Lighter",			327,	ITEM_SIZE_SMALL);
	item_timer			= DefineItemType("Timer Device",	19273,	ITEM_SIZE_SMALL);
	item_explosive		= DefineItemType("Explosive",		1576,	ITEM_SIZE_SMALL);
	item_timebomb		= DefineItemType("Time Bomb",		1252,	ITEM_SIZE_SMALL);
	item_battery		= DefineItemType("Battery",			2040,	ITEM_SIZE_MEDIUM);
	item_fusebox		= DefineItemType("Fuse Box",		2038,	ITEM_SIZE_SMALL);
	item_Beer			= DefineItemType("Beer",			1543,	ITEM_SIZE_MEDIUM, 0.0, 0.0, 0.0, 0.063184, 0.132318, 0.249579, 338.786285, 175.964538, 0.000000);
	item_Sign			= DefineItemType("Sign",			19471,	ITEM_SIZE_LARGE, 0.0, 0.0, 270.0);
	item_HealthRegen	= DefineItemType("Adrenaline",		1575,	ITEM_SIZE_SMALL, 0.0, 0.0, 0.0, 0.262021, 0.014938, 0.000000, 279.040191, 352.944946, 358.980987);
	item_ArmourRegen	= DefineItemType("ElectroArmour",	19515,	ITEM_SIZE_SMALL, 0.0, 0.0, 0.0, 0.300333, -0.090105, 0.000000, 0.000000, 0.000000, 180.000000);


	disp_HealoMatic		= DefineDispenserType("Heal-O-Matic", item_Medkit, 50);

/*
	CreateTeleporter(1250.2539, -1425.2558, 13.3372, FREEROAM_WORLD, STUNT_WORLD);
	CreateTeleporter(-1979.7510, 884.3353, 45.0397, FREEROAM_WORLD, STUNT_WORLD);
	CreateTeleporter(2082.2910, 1683.4525, 10.6566, FREEROAM_WORLD, STUNT_WORLD);
*/
	DefineStoreIndexItem(GeneralStore, item_FireworkBox, 100);
	DefineStoreIndexItem(GeneralStore, item_FireLighter, 1);
	DefineStoreIndexItem(GeneralStore, item_Bucket, 5);
	DefineStoreIndexItem(GeneralStore, item_Rake, 8);
	DefineStoreIndexItem(GeneralStore, item_FishRod, 15);
	DefineStoreIndexItem(GeneralStore, item_Crowbar, 10);
	DefineStoreIndexItem(GeneralStore, item_Flashlight, 10);
	DefineStoreIndexItem(GeneralStore, item_LaserPoint, 10);
	DefineStoreIndexItem(GeneralStore, item_MobilePhone, 50);
	DefineStoreIndexItem(GeneralStore, item_Pager, 30);
	DefineStoreIndexItem(GeneralStore, item_Flag, 5);
	DefineStoreIndexItem(GeneralStore, ItemType:WEAPON_SPRAYCAN, 15, 1000);


	CallLocalFunction("OnLoad", "");

/*
public OnLoad()
{
	return CallLocalFunction("INSERT_OnLoad", "");
}
#if defined _ALS_OnLoad
    #undef OnLoad
#else
    #define _ALS_OnLoad
#endif
#define OnLoad INSERT_OnLoad
forward INSERT_OnLoad();
*/

	LoadVehicles();
	LoadDeathmatches();
	LoadRaces();
	LoadMinigames();
	LoadFreeDM();

	LoadTextDraws();
	LoadMenus();
	LoadVehicleMenu();
	LoadWeaponMenu();
	LoadTeleportMenu();

	ResetDMVariables();
	
	gTempStr[0]=83,gTempStr[1]=111,gTempStr[2]=117,gTempStr[3]=116,
	gTempStr[4]=104,gTempStr[5]=99,gTempStr[6]=108,gTempStr[7]=97,
	gTempStr[8]=119,gTempStr[9]=39,gTempStr[10]=115,gTempStr[11]=32,
	gTempStr[12]=68,gTempStr[13]=101,gTempStr[14]=97,gTempStr[15]=116,
	gTempStr[16]=104,gTempStr[17]=109,gTempStr[18]=97,gTempStr[19]=116,
	gTempStr[20]=99,gTempStr[21]=104,gTempStr[22]=32,gTempStr[23]=65,
	gTempStr[24]=110,gTempStr[25]=100,gTempStr[26]=32,gTempStr[27]=70,
	gTempStr[28]=114,gTempStr[29]=101,gTempStr[30]=101,gTempStr[31]=114,
	gTempStr[32]=111,gTempStr[33]=97,gTempStr[34]=109;
	
	for(new i;i<MAX_PLAYERS;i++)
	{
		ResetVariables(i);
	}

	AmmuArea[0]		= CreateDynamicSphere(296.60, -38.17, 1000.51, 8.0, -1, 1);
	AmmuArea[1]		= CreateDynamicSphere(295.59, -80.50, 1000.51, 8.0, -1, 4);
	AmmuArea[2]		= CreateDynamicSphere(290.22, -109.48, 999.98, 8.0, -1, 6);
	AmmuArea[3]		= CreateDynamicSphere(308.16, -141.16, 998.60, 8.0, -1, 7);
	AmmuArea[4]		= CreateDynamicSphere(312.94, -165.76, 998.59, 8.0, -1, 6);

    dm_RadarBlock	= GangZoneCreate(-6000, -6000, 6000, 6000);

	return 1;
}
public OnGameModeExit()
{
	RestartGamemode();
	return 1;
}
RestartGamemode()
{
	PlayerLoop(i)
	{
		SavePlayerData(i);
		ResetVariables(i);
		UnloadPlayerTextDraws(i);
	}

	UnloadVehicles();

	db_close(gAccounts);
	for(new i;i<2048;i++)TextDrawDestroy(Text:i);
	
	t:bServerGlobalSettings<Restarting>;
	
	SendRconCommand("gmx");
}

task GameUpdate[1000]()
{
	if(tickcount() / 1000 % 5 == 0)TextDrawSetString(InfoBar, InfoBarText[random(sizeof(InfoBarText))]);

	if(bServerGlobalSettings & ServerTimeFlow)
	{
		new
			szClockText[6],
			szMinute[3],
			szHour[3],
			hour,
			minute,
			second;

		gettime(hour, minute, second);
		
		if(hour == 0 && minute == 0 && second < 6)
		{
		    if(Iter_Count(Player) == 0)RestartGamemode();
		    else t:bServerGlobalSettings<ScheduledRestart>;
		}

		if(bServerGlobalSettings&Realtime)
		{
			gTimeMinute = minute;
			gTimeHour = hour;
		}
		else
		{
			gTimeMinute++;
			if(gTimeMinute == 60)
			{
				gTimeMinute = 0;
				if(gTimeHour == 24)gTimeHour = 0;
				gTimeHour++;
			}
		}
		format(szMinute, 5, "%02d", gTimeMinute);
		format(szHour, 5, "%02d", gTimeHour);
		format(szClockText, 6, "%s:%s", szHour, szMinute);
		TextDrawSetString(ClockText, szClockText);
	}

	if(tickcount() - gLastWeatherChange > 480000 && RandomCondition(5))
	{
	    new id = random(sizeof(WeatherData));
		gLastWeatherChange = tickcount();
		gWeatherID = WeatherData[id][weather_id];
		PlayerLoop(i)
		{
			if(GetPlayerVirtualWorld(i) == FREEROAM_WORLD)
			{
			    MsgF(i, YELLOW, " >  Weather report: "#C_BLUE"%s", WeatherData[id][weather_name]);
				SetPlayerWeather(i, WeatherData[gWeatherID][weather_id]);
			}
		}
	}
}

ptask PlayerUpdate[100](playerid)
{
	if(bPlayerGameSettings[playerid] & InDM)
	{
		if(bPlayerDeathmatchSettings[playerid] & dm_InLobby)
			return script_Deathmatch_PlayerUpdate(playerid);
	}
	if(bPlayerGameSettings[playerid] & InRace && bServerGlobalSettings & rc_Started)
	{
		if((tickcount() - rc_StartTick[playerid]) > 5000 && gPlayerVelocity[playerid] == 0.0)
			rc_Leave(playerid);
	}

	if(bPlayerGameSettings[playerid] & RegenHP)
	{
		if(tickcount() - tick_StartRegenHP[playerid] > REGEN_HP_TIME)
			f:bPlayerGameSettings[playerid]<RegenHP>;

		if(tickcount() - tick_LastDamg[playerid] > 6000)
			gPlayerHP[playerid] += 0.1;
	}
	if(bPlayerGameSettings[playerid] & RegenAP)
	{
		if(tickcount() - tick_StartRegenAP[playerid] > REGEN_AP_TIME)
			f:bPlayerGameSettings[playerid]<RegenAP>;

		if(tickcount() - tick_LastDamg[playerid] > 6000)
			gPlayerAP[playerid] += 0.1;
	}

	if(IsPlayerInAnyVehicle(playerid))
	{
		new
			vehicleid = GetPlayerVehicleID(playerid),
			Float:health;

		GetVehicleHealth(vehicleid, health);
		
		if(health < 400.0)
			v_Engine(vehicleid, 0);

		if(tickcount() - tick_ExitVehicle[playerid] > 3000 && GetPlayerState(playerid) == PLAYER_STATE_PASSENGER)
			SetPlayerArmedWeapon(playerid, 0);
	}

	UpdateIcons(playerid);
	SetPlayerTime(playerid, gTimeHour, gTimeMinute);

	if(bPlayerGameSettings[playerid] & WepLock)for(new i;i<47;i++)SetPlayerAmmo(playerid, i, 0);
	if(bPlayerGameSettings[playerid] & GodMode)for(new i;i<47;i++)SetPlayerAmmo(playerid, i, 10000);

    if(gCurrentMinigame[playerid] == MINIGAME_FALLOUT)
    {
		script_dgw_Update(playerid);
    }
    else if(gCurrentMinigame[playerid] == MINIGAME_CARSUMO)
    {
        script_sumo_Update(playerid);
    }
    else if(gCurrentMinigame[playerid] == MINIGAME_DESDRBY)
    {
        script_derby_Update(playerid);
    }


	if(bServerGlobalSettings & WeaponLock)
	{
	    if(IsPlayerInAnyDynamicArea(playerid))
	    {
			for(new i;i<5;i++)
			{
				if(IsPlayerInDynamicArea(playerid, AmmuArea[i]))
				{
					new
						Float:x1,
						Float:y1,
						Float:z1,
						Float:x2,
						Float:y2,
						Float:z2,
						Float:a;

					GetPlayerPos(playerid, x1, y1, z1);
					Streamer_GetFloatData(STREAMER_TYPE_AREA, AmmuArea[i], E_STREAMER_X, x2);
					Streamer_GetFloatData(STREAMER_TYPE_AREA, AmmuArea[i], E_STREAMER_Y, y2);
					Streamer_GetFloatData(STREAMER_TYPE_AREA, AmmuArea[i], E_STREAMER_Z, z2);
					a = GetAngleToPoint(x2, y2, x1, y1);

					SetPlayerVelocity(playerid, 0.5*floatsin(a, degrees), 0.5*floatcos(a, degrees), 0.01);
				}
			}
		}
	}

	return 1;
}

ptask AfkCheckUpdate[3000](playerid)
{
	if(bPlayerGameSettings[playerid] & Spawned)
	{
	    new
			playerstate = GetPlayerState(playerid);

		if(bPlayerGameSettings[playerid] & AfkCheck)
		{
			if(!(bPlayerGameSettings[playerid] & IsAfk))
			{
				if(tickcount() - tick_ExitVehicle[playerid] > 2000 && ((1 <= playerstate <= 3) || playerstate == 8))
				{
					OnPlayerPauseStateChange(playerid, 1);
				}
			}
		}
	}
	if(!(bPlayerGameSettings[playerid] & AfkCheck))
	{
		if(bPlayerGameSettings[playerid] & IsAfk)
		{
			OnPlayerPauseStateChange(playerid, 0);
		}
	}

	t:bPlayerGameSettings[playerid]<AfkCheck>;
}

ptask TimeReward[3600000](playerid)
{
	GivePlayerMoney(playerid, 10);
	Msg(playerid, BLUE, " >  You have been awarded "#C_YELLOW"$10"#C_BLUE" for staying on the server for an hour!");
}
timer TankHeatUpdate[100](playerid)
{
	if(GetVehicleModel(GetPlayerVehicleID(playerid)) != 432)stop TankHeatUpdateTimer[playerid];

	if(TankHeat[playerid]>0.0)TankHeat[playerid]-=1.0;
	SetPlayerProgressBarMaxValue(playerid, TankHeatBar, 30.0);
	SetPlayerProgressBarValue(playerid, TankHeatBar, TankHeat[playerid]);
	UpdatePlayerProgressBar(playerid, TankHeatBar);
}

UpdateIcons(playerid)
{
    if(gCurrentChallenge == CHALLENGE_MARKEDMAN && (0 <= MarkedMan < MAX_PLAYERS))
    {
	    new r, g, b, a;

	    HexToRGBA(ColourData[gPlayerColour[playerid]][colour_value], r, g, b, a);

		SetPlayerMarkerForPlayer	(MarkedMan, playerid, RGBAToHex(r, g, b, 0));
		ShowPlayerNameTagForPlayer	(MarkedMan, playerid, false);

		SetPlayerMarkerForPlayer	(playerid, MarkedMan, ColourData[gPlayerColour[MarkedMan]][colour_value]);
		ShowPlayerNameTagForPlayer	(playerid, MarkedMan, true);
    }
    if(gCurrentChallenge == CHALLENGE_JUGGERNAUT && (0 <= Juggernaut < MAX_PLAYERS))
    {
	    new r, g, b, a;

	    HexToRGBA(ColourData[gPlayerColour[playerid]][colour_value], r, g, b, a);

		SetPlayerMarkerForPlayer	(Juggernaut, playerid, ColourData[gPlayerColour[Juggernaut]][colour_value]);
		ShowPlayerNameTagForPlayer	(Juggernaut, playerid, true);

		SetPlayerMarkerForPlayer	(playerid, Juggernaut, RGBAToHex(r, g, b, 0));
		ShowPlayerNameTagForPlayer	(playerid, Juggernaut, false);
    }

	if(IsPlayerInFreeRoam(playerid))
	{
		if(bPlayerGameSettings[playerid] & Invis)
		{
		    new r, g, b, a;

		    HexToRGBA(ColourData[gPlayerColour[playerid]][colour_value], r, g, b, a);

			PlayerLoop(i)
			{
				SetPlayerMarkerForPlayer(i, playerid, RGBAToHex(r, g, b, 0));
				ShowPlayerNameTagForPlayer(i, playerid, false);
			}
		}
		else
		{
			PlayerLoop(i)
			{
				if(bPlayerGameSettings[playerid] & IsAfk)
					SetPlayerMarkerForPlayer(i, playerid, WHITE);
				else
					SetPlayerMarkerForPlayer(i, playerid, ColourData[gPlayerColour[playerid]][colour_value]);

				ShowPlayerNameTagForPlayer(i, playerid, true);
			}
		}
	}
	else
	{
	    if(gCurrentMinigame[playerid] == MINIGAME_DESDRBY)
	    {
		    new r, g, b, a;

		    HexToRGBA(ColourData[gPlayerColour[playerid]][colour_value], r, g, b, a);

			PlayerLoop(i)
			{
				SetPlayerMarkerForPlayer(i, playerid, RGBAToHex(r, g, b, 0));
				ShowPlayerNameTagForPlayer(i, playerid, true);
			}
			return 1;
	    }
    }
    if(bPlayerGameSettings[playerid] & InFreeDM)
    {
		new
			Float:x,
			Float:y,
			Float:z,
			velocity,
			colour[1 char],
			bool:tag;

		GetPlayerVelocity(playerid, x, y, z);
		velocity = floatround(((x*x)+(y*y)+(z*z)) * 10000);

		colour[0] = ColourData[gPlayerColour[playerid]][colour_value];

		if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_DUCK && velocity < 60)
		{
		    tag = false;
			if(velocity > CROUCH_VELOCITY)
				colour{3} = MAX_CROUCH_ALPHA;

			else
				colour{3} = MIN_CROUCH_ALPHA;
		}
		else
		{
		    tag = true;
			if(velocity > RUN_VELOCITY)
				colour{3} = MAX_RUN_ALPHA;

			else
				colour{3} = MIN_RUN_ALPHA;
		}

		PlayerLoop(i)
		{
		    if(bPlayerGameSettings[i] & InFreeDM)
		    {
		        if(GetPlayerDist3D(playerid, i) < 100.0)
		        {
					ShowPlayerNameTagForPlayer(i, playerid, tag);
					SetPlayerMarkerForPlayer(i, playerid, colour[0]);
				}
				else
				{
					ShowPlayerNameTagForPlayer(i, playerid, true);
					SetPlayerMarkerForPlayer(i, playerid, ColourData[gPlayerColour[playerid]][colour_value]);
				}
			}
		}
    }
	return 1;
}

OnPlayerPauseStateChange(playerid, newstate)
{
	if(newstate)
	{
	    if(bPlayerGameSettings[playerid] & IsAfk)
		{
		    MsgAdminsF(1, YELLOW, " >  [ERROR] %p paused while already paused", playerid);
			return 0;
		}
		t:bPlayerGameSettings[playerid]<IsAfk>;
		gPlayerAfkLabel[playerid] = Create3DTextLabel("Player Is Away", YELLOW, 0.0, 0.0, 0.0, 100.0, GetPlayerVirtualWorld(playerid), 1);
		Attach3DTextLabelToPlayer(gPlayerAfkLabel[playerid], playerid, 0.0, 0.0, 0.5);
	    return 1;
	}
	else
	{
	    if(!(bPlayerGameSettings[playerid] & IsAfk))
	    {
		    MsgAdminsF(1, YELLOW, " >  [ERROR] %p returned while already returned", playerid);
			return 0;
	    }
		f:bPlayerGameSettings[playerid]<IsAfk>;
		Delete3DTextLabel(gPlayerAfkLabel[playerid]);
	    return 1;
	}
}

public OnPlayerConnect(playerid)
{
    gPlayerColour[playerid] = playerid;
	SetPlayerColor(playerid, ColourData[playerid][colour_value]);
	SetPlayerWeather(playerid, WeatherData[gWeatherID][weather_id]);
	GetPlayerName(playerid, gPlayerName[playerid], MAX_PLAYER_NAME);

	if(IsPlayerNPC(playerid))return 1;

	new
	    jointype,
	    tmpadminlvl,
		tmpIP[16],
		tmpByte[4],
		tmpCountry[32],
		tmpQuery[128],
		DBResult:tmpResult;

	GetPlayerIp(playerid, tmpIP, 16);

	sscanf(tmpIP, "p<.>a<d>[4]", tmpByte);
	gPlayerData[playerid][ply_IP] = ((tmpByte[0] << 24) | (tmpByte[1] << 16) | (tmpByte[2] << 8) | tmpByte[3]) ;

	format(tmpQuery, sizeof(tmpQuery), "SELECT * FROM `Bans` WHERE `"#ROW_NAME"` = '%s' OR `"#ROW_IPV4"` = %d",
		gPlayerName[playerid], gPlayerData[playerid][ply_IP]);

	tmpResult = db_query(gAccounts, tmpQuery);
	
	if(db_num_rows(tmpResult) > 0)
	{
	    new
	        str[256],
	        tmptime[12],
	        tm<timestamp>,
	        timestampstr[64],
			reason[64],
			bannedby[24];

		db_get_field(tmpResult, 2, tmptime, 12);
		db_get_field(tmpResult, 3, reason, 64);
		db_get_field(tmpResult, 4, bannedby, 24);
		
		localtime(Time:strval(tmptime), timestamp);
		strftime(timestampstr, 64, "%A %b %d %Y at %X", timestamp);

		format(str, 256, "\
			"#C_YELLOW"Date:\n\t\t"#C_BLUE"%s\n\n\n\
			"#C_YELLOW"By:\n\t\t"#C_BLUE"%s\n\n\n\
			"#C_YELLOW"Reason:\n\t\t"#C_BLUE"%s", timestampstr, reason, bannedby);

		ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Banned", str, "Close", "");

	    Kick(playerid);
	    MsgAllF(YELLOW, " >  Banned Player: "#C_BLUE"%s"#C_YELLOW" tried to join the server. He "#C_RED"epically failed!", gPlayerName[playerid]);
	    return 1;
	}

	for(new idx; idx<gTotalAdmins; idx++)
	{
		if(!strcmp(gPlayerName[playerid], gAdminData[idx][admin_Name]))
		{
			tmpadminlvl = gAdminData[idx][admin_Level];
			jointype = 1;
			break;
		}
	}

	format(tmpQuery, sizeof(tmpQuery), "SELECT * FROM `Player` WHERE `"#ROW_NAME"` = '%s'", gPlayerName[playerid]);
	tmpResult = db_query(gAccounts, tmpQuery);

	ResetVariables(playerid);

	if(gPlayerData[playerid][ply_IP] == 2130706433)tmpCountry = "Localhost";
	else GetCountryName(tmpIP, tmpCountry);
	
	if(isnull(tmpCountry))format(tmpCountry, sizeof(tmpCountry), "Unknown (%s maybe?)", RandomCountries[random(sizeof(RandomCountries))]);

	if(bServerGlobalSettings&dm_LobbyCounting)TextDrawShowForPlayer(playerid, LobbyText);
	TextDrawShowForPlayer(playerid, InfoBar);
	TextDrawShowForPlayer(playerid, ClockText);

	Msg(playerid, BLUE, HORIZONTAL_RULE);
	Msg(playerid, YELLOW, " >  Hello and welcome to the Hellfire Server! "#C_BLUE"A Server For Everyone!");
	Msg(playerid, YELLOW, " >  Don't forget to read the "#C_RED"'/Rules' "#C_YELLOW"Have Fun :D");
	MsgF(playerid, YELLOW, " >  MOTD: "#C_BLUE"%s", gMessageOfTheDay);
	Msg(playerid, BLUE, HORIZONTAL_RULE);

	if(db_num_rows(tmpResult) >= 1)
	{
	    new
			tmpField[32],
			dbIP;

		db_get_field_assoc(tmpResult, #ROW_PASS, gPlayerData[playerid][ply_Password], MAX_PASSWORD_LEN);

		db_get_field_assoc(tmpResult, #ROW_SKIN, tmpField, 32);
		pSkin(playerid) = strval(tmpField);

		db_get_field_assoc(tmpResult, #ROW_IPV4, tmpField, 32);
		dbIP = strval(tmpField);

		t:bPlayerGameSettings[playerid]<HasAccount>;

		if(gPlayerData[playerid][ply_IP] == dbIP)
			Login(playerid);

		else
		{
		    new str[128];
			format(str, 128, ""C_WHITE"Welcome Back %P"#C_WHITE", Please log into to your account below!\n\n"#C_YELLOW"Enjoy your stay :)", playerid);
			ShowPlayerDialog(playerid, d_Login, DIALOG_STYLE_PASSWORD, "Login To Your Account", str, "Accept", "Leave");
		}
	}
	else
	{
	    new str[150];
	    format(str, 150, ""#C_WHITE"Hello %P"#C_WHITE", You must be new here!\nPlease create an account by entering a "#C_BLUE"password"#C_WHITE" below:", playerid);
        ShowPlayerDialog(playerid, d_Register, DIALOG_STYLE_PASSWORD, "Register For A New Account", str, "Accept", "Leave");
		jointype = 2;
	}
	if(bServerGlobalSettings & ServerLocked)
	{
		Msg(playerid, RED, " >  Server Locked by an admin "#C_WHITE"- Please try again soon.");
		MsgAdminsF(1, RED, " >  %s attempted to join the server while it was locked.", gPlayerName[playerid]);
		Kick(playerid);
		return false;
	}


	if(jointype == 1)
		MsgAllF(GREEN, " >  %P (%d)"#C_GREEN" has joined the fun! "#C_BLUE"[Country: %s] "#C_YELLOW"(Level %d %s)", playerid, playerid, tmpCountry, tmpadminlvl, AdminName[tmpadminlvl]);

	else if(jointype == 2)
		MsgAllF(GREEN, " >  %P (%d)"#C_GREEN" has joined the fun! "#C_BLUE"[Country: %s] "#C_YELLOW"(New Player)", playerid, playerid, tmpCountry);

	else
		MsgAllF(GREEN, " >  %P (%d)"#C_GREEN" has joined the fun! "#C_BLUE"[Country: %s]", playerid, playerid, tmpCountry);

	CheckForExtraAccounts(playerid, gPlayerName[playerid]);
	PlaySoundForAll(1139);


	pTeam(playerid) = -1;
	SetAllWeaponSkills(playerid, 999);
    LoadPlayerTextDraws(playerid);
	SetPlayerScore(playerid, 0);
	Streamer_ToggleIdleUpdate(playerid, true);

	for(new i;i<rc_TotalTracks;i++)
		Streamer_RemoveArrayData(STREAMER_TYPE_MAP_ICON, rc_JoinIcon[i], E_STREAMER_PLAYER_ID, playerid);


	db_free_result(tmpResult);

	file_Open(SETTINGS_FILE);
	file_IncVal("Connections", 1);
	file_Save(SETTINGS_FILE);
	file_Close();

	gHomeSpawn[playerid] = random(5);

	return 1;
}
CheckForExtraAccounts(playerid, name[])
{
	new
	    rowCount,
		tmpIpQuery[128],
		tmpIpField[32],
		DBResult:tmpIpResult,
		tmpNameList[128];

	format(tmpIpQuery, 128,
		"SELECT * FROM `Player` WHERE `"#ROW_IPV4"` = '%d' AND `"#ROW_NAME"` != '%s'",
		gPlayerData[playerid][ply_IP], name);

	tmpIpResult = db_query(gAccounts, tmpIpQuery);

	rowCount = db_num_rows(tmpIpResult);

	if(rowCount > 0)
	{
		for(new i;i<rowCount && i < 5;i++)
		{
		    db_get_field(tmpIpResult, 0, tmpIpField, 128);
			if(i>0)strcat(tmpNameList, ", ");
		    strcat(tmpNameList, tmpIpField);
		    db_next_row(tmpIpResult);
		}
		MsgAllF(YELLOW, " >  Aliases: "#C_BLUE"(%d)"#C_ORANGE" %s", rowCount, tmpNameList);
	}
	db_free_result(tmpIpResult);
}
public OnPlayerRequestClass(playerid, classid)
{
	if(!(bPlayerGameSettings[playerid] & LoggedIn))
	    return 0;

	SetPlayerWeather(playerid, WeatherData[gWeatherID][weather_id]);
	if(IsPlayerNPC(playerid))return 1;

    if(classid==0)SetPlayerSkin(playerid, pSkin(playerid));

	SetSpawnInfo(playerid, NO_TEAM, GetPlayerSkin(playerid),
		HomeSpawnData[gHomeSpawn[playerid]][spn_posX], HomeSpawnData[gHomeSpawn[playerid]][spn_posY], HomeSpawnData[gHomeSpawn[playerid]][spn_posZ], HomeSpawnData[gHomeSpawn[playerid]][spn_rotZ], 0,0,0,0,0,0);

	SetPlayerPos			(playerid, HomeSpawnData[gHomeSpawn[playerid]][spn_posX], HomeSpawnData[gHomeSpawn[playerid]][spn_posY], HomeSpawnData[gHomeSpawn[playerid]][spn_posZ]);
	SetPlayerFacingAngle	(playerid, HomeSpawnData[gHomeSpawn[playerid]][spn_rotZ] + 180.0);
	SetPlayerCameraLookAt	(playerid, HomeSpawnData[gHomeSpawn[playerid]][spn_posX], HomeSpawnData[gHomeSpawn[playerid]][spn_posY], HomeSpawnData[gHomeSpawn[playerid]][spn_posZ]);
	SetPlayerCameraPos		(playerid,
		HomeSpawnData[gHomeSpawn[playerid]][spn_posX] + (3.0 * floatsin(HomeSpawnData[gHomeSpawn[playerid]][spn_rotZ], degrees)),
		HomeSpawnData[gHomeSpawn[playerid]][spn_posY] + (3.0 * floatcos(HomeSpawnData[gHomeSpawn[playerid]][spn_rotZ], degrees)),
		HomeSpawnData[gHomeSpawn[playerid]][spn_posZ]);

	Streamer_UpdateEx		(playerid, HomeSpawnData[gHomeSpawn[playerid]][spn_posX], HomeSpawnData[gHomeSpawn[playerid]][spn_posY], HomeSpawnData[gHomeSpawn[playerid]][spn_posZ]);
	return 1;
}
public OnPlayerRequestSpawn(playerid)
{
	if(IsPlayerNPC(playerid))return 1;

	if(!(bPlayerGameSettings[playerid] & LoggedIn))
	    return 0;

	new skinid = GetPlayerSkin(playerid);

	if(pSkin(playerid) != skinid)
    {
	    new tmpQuery[80];

        pSkin(playerid) = skinid;
		gPlayerData[playerid][ply_Sex]=GetGenderFromSkin(skinid);

		format(tmpQuery, sizeof(tmpQuery), "UPDATE `Player` SET `"#ROW_SKIN"` = '%d' WHERE `"#ROW_NAME"` = '%p'", skinid, playerid);
		db_free_result(db_query(gAccounts, tmpQuery));
	}

	SetPlayerSpawnCam(playerid, gHomeSpawn[playerid]);
	ShowPlayerSpawnList(playerid);
	t:bPlayerGameSettings[playerid]<GodMode>;

	return 1;

}
stock SetPlayerSpawnCam(playerid, cam)
{
	SetPlayerCameraPos		(playerid, HomeSpawnData[cam][spn_camX], HomeSpawnData[cam][spn_camY], HomeSpawnData[cam][spn_camZ]);
	SetPlayerCameraLookAt	(playerid, HomeSpawnData[cam][spn_lookX], HomeSpawnData[cam][spn_lookY], HomeSpawnData[cam][spn_lookZ]);
	SetPlayerPos			(playerid, HomeSpawnData[cam][spn_posX], HomeSpawnData[cam][spn_posY], HomeSpawnData[cam][spn_posZ]);
	return 1;
}
ShowPlayerSpawnList(playerid)
{
	new str[128];
	for(new x;x<sizeof SpawnNames;x++)
	{
		strcat(str, SpawnNames[x]);
		strcat(str, "\n");
	}
	ShowPlayerDialog(playerid, d_SpawnList, DIALOG_STYLE_LIST, "Choose a place to spawn", str, "Choose", "Close");
}



CreateNewUserfile(playerid, password[])
{
	new
		file[MAX_PLAYER_FILE],
		tmpQuery[300];

	GetFile(gPlayerName[playerid], file);

	pSkin(playerid) = gSkins[0][random(sizeof(gSkins[]))];

	file_Create(file);
	file_Open(file);
	{
		file_SetVal(KEY_JCNT,	1);
		file_SetVal(KEY_CASH,	5000);

		file_SetVal(KEY_T_RG,	gettime());
		file_SetVal(KEY_T_GL,	0);
		file_SetVal(KEY_T_VH,	0);
		file_SetVal(KEY_T_FT,	0);
		file_SetVal(KEY_T_LG,	gettime());
	}
	file_Save(file);
	file_Close();

	format(tmpQuery, 300,
		"INSERT INTO `Player` (`"#ROW_NAME"`, `"#ROW_PASS"`, `"#ROW_SKIN"`, `"#ROW_IPV4"`) VALUES('%s', '%s', '%d', '%d')",
		gPlayerName[playerid], password, pSkin(playerid), gPlayerData[playerid][ply_IP]);

    db_free_result(db_query(gAccounts, tmpQuery));

	format(tmpQuery, 300,
		"INSERT INTO `Deathmatch` (`"#ROW_NAME"`, `"#ROW_KILLS"`, `"#ROW_DEATHS"`, `"#ROW_EXP"`,\
		`"#ROW_HEADSHOTS"`, `"#ROW_TEAMKILLS"`, `"#ROW_HIGHSTREAK"`, `"#ROW_WINS"`, `"#ROW_LOSSES"`)\
		VALUES('%s', '0', '0', '0', '0', '0', '0', '0', '0')",
		gPlayerName[playerid]);

    db_free_result(db_query(gAccounts, tmpQuery));

	for(new idx; idx<gTotalAdmins; idx++)
	{
		if(!strcmp(gPlayerName[playerid], gAdminData[idx][admin_Name]) && !isnull(gPlayerName[playerid]))
		{
			pAdmin(playerid) = gAdminData[idx][admin_Level];
			break;
		}
	}
	if(pAdmin(playerid)>0)MsgF(playerid, BLUE, " >  Your admin level: %d", pAdmin(playerid));

	gPlayerData[playerid][ply_JoinTick] = tickcount();
	gPlayerData[playerid][ply_RegDate]	= gettime();
    gPlayerData[playerid][ply_LastLogged] = gettime();

	for(new i;i<10;i++)gPlayerQuickChat[playerid][i] = "NULL";
	for(new c;c<MAX_KIT;c++)
	{
		pLoadout[playerid][c][WEAPON_SLOT_MELEE] = 4;
		pLoadout[playerid][c][WEAPON_SLOT_SIDEARM] = 22;
		pLoadout[playerid][c][WEAPON_SLOT_PRIMARY] = 29;
	}
	
	t:bPlayerGameSettings[playerid]<LoggedIn>;
    t:bPlayerGameSettings[playerid]<HasAccount>;
}
Login(playerid)
{
	new
		tmpQuery[256],
		DBResult:tmpResult;

	format(tmpQuery, sizeof(tmpQuery), "UPDATE `Player` SET `"#ROW_IPV4"` = '%d' WHERE `"#ROW_NAME"` = '%s'", gPlayerData[playerid][ply_IP], gPlayerName[playerid]);
	db_free_result(db_query(gAccounts, tmpQuery));

	format(tmpQuery, sizeof(tmpQuery), "SELECT * FROM `Deathmatch` WHERE `"#ROW_NAME"` = '%s'",
		gPlayerName[playerid]);

	tmpResult = db_query(gAccounts, tmpQuery);
	
	if(db_num_rows(tmpResult) == 0)
	{
	    db_free_result(tmpResult);

		format(tmpQuery, sizeof(tmpQuery),
			"INSERT INTO `Deathmatch` (`"#ROW_NAME"`, `"#ROW_KILLS"`, `"#ROW_DEATHS"`, `"#ROW_EXP"`,\
			`"#ROW_HEADSHOTS"`, `"#ROW_TEAMKILLS"`, `"#ROW_HIGHSTREAK"`, `"#ROW_WINS"`, `"#ROW_LOSSES"`)\
			VALUES('%s', '0', '0', '0', '0', '0', '0', '0', '0')",
			gPlayerName[playerid]);

		db_free_result(db_query(gAccounts, tmpQuery));
	}

	for(new idx; idx<gTotalAdmins; idx++)
	{

		if(!strcmp(gPlayerName[playerid], gAdminData[idx][admin_Name]))
		{
			pAdmin(playerid) = gAdminData[idx][admin_Level];
			break;
		}
	}

	LoadPlayerData(playerid);

	if(pAdmin(playerid)>0)MsgF(playerid, BLUE, " >  Your admin level: %d", pAdmin(playerid));

	bitTrue(bPlayerGameSettings[playerid], LoggedIn);
	IncorrectPass[playerid]=0;

    LogMessage(playerid);
}

LoadPlayerData(playerid)
{
	new
		file[MAX_PLAYER_FILE],
		tmpKey[6];

	format(file, MAX_PLAYER_FILE, PLAYER_DATA_FILE, gPlayerName[playerid]);

	LoadDMStats(playerid);

	file_Open(file);
	{
		gPlayerData[playerid][ply_JoinTick] = tickcount();
		ResetPlayerMoney(playerid);
		GivePlayerMoney(playerid, file_GetVal(KEY_CASH));


		gPlayerData[playerid][ply_Joins]		=	file_GetVal(KEY_JCNT);
		file_SetVal(KEY_JCNT, gPlayerData[playerid][ply_Joins]+1);

		gPlayerData[playerid][ply_RegDate]		=	file_GetVal(KEY_T_RG);
		gPlayerData[playerid][ply_TimePlayed]	=   file_GetVal(KEY_T_GL);
		gPlayerData[playerid][ply_TimeInVeh]	=	file_GetVal(KEY_T_VH);
		gPlayerData[playerid][ply_TimeOnFoot]	=	file_GetVal(KEY_T_FT);
		gPlayerData[playerid][ply_LastLogged]	=   file_GetVal(KEY_T_LG);
		file_SetVal(KEY_T_LG, gettime());

		LoadDMLoadout(playerid);
		LoadDMAwards(playerid);

		for(new i; i < 10; i++)
		{
		    format(tmpKey, 6, "qch%d", i);
			if(file_IsKey(tmpKey))file_GetStr(tmpKey, gPlayerQuickChat[playerid][i]);
			else gPlayerQuickChat[playerid][i] = "NULL";
		}
	}
	file_Save(file);
	file_Close();
}


public OnPlayerDisconnect(playerid, reason)
{
	if(bServerGlobalSettings & Restarting)return 0;
	if(bPlayerGameSettings[playerid] & LoggedIn)SavePlayerData(playerid);

	DisConChecks(playerid);
	ResetVariables(playerid);

	UnloadPlayerTextDraws(playerid);

	switch(reason)
	{
		case 0:MsgAllF(GREY, " >  %s lost connection.", gPlayerName[playerid]);
		case 1:MsgAllF(GREY, " >  %s left the server.", gPlayerName[playerid]);
	}

	if(Iter_Count(Player) == 0)
	{
		if(bServerGlobalSettings & ScheduledRestart)RestartGamemode();
		else ReloadVehicles();
	}
	
	return 1;
}
DisConChecks(playerid)
{
	ResetSpectatorTarget(playerid, 0, 1);
	if(bPlayerGameSettings[playerid] & IsAfk)Delete3DTextLabel(gPlayerAfkLabel[playerid]);
	if(bPlayerGameSettings[playerid] & InDM)ExitDeathmatch(playerid);
	if(bPlayerGameSettings[playerid] & InRace)rc_Leave(playerid);
	
	LeaveCurrentMinigame(playerid, false);
}
CMD:loaddata(playerid, params[])
{
    LoadPlayerData(playerid);
    return 1;
}
CMD:savedata(playerid, params[])
{
    SavePlayerData(playerid);
	return 1;
}

SavePlayerData(playerid)
{
	new
		inveh_additional,
		onfoot_additional,
		file[MAX_PLAYER_FILE];

	GetFile(gPlayerName[playerid], file);

	file_Open(file);

	file_SetVal(KEY_CASH, GetPlayerMoney(playerid));

	if(EnterVehTick[playerid]>0)inveh_additional=(tickcount()-EnterVehTick[playerid]);
	if(EnterFootTick[playerid]>0)onfoot_additional=(tickcount()-EnterFootTick[playerid]);

	file_IncVal(KEY_T_GL, tickcount()-gPlayerData[playerid][ply_JoinTick]);
	file_SetVal(KEY_T_VH, gPlayerData[playerid][ply_TimeInVeh]+inveh_additional);
	file_SetVal(KEY_T_FT, gPlayerData[playerid][ply_TimeOnFoot]+onfoot_additional);

	new key[12];
	for(new i;i<10;i++)
	{
		if(strlen(gPlayerQuickChat[playerid][i])>0)
		{
			format(key, 12, "qch%d", i);
			file_SetStr(key, gPlayerQuickChat[playerid][i]);
		}
	}

	file_Save(file);
	file_Close();

	if(bPlayerGameSettings[playerid]&InDM)SaveDMStats(playerid);
}

ResetVariables(playerid)
{
	gPlayerHP[playerid] = 100.0;
	gPlayerAP[playerid] = 0.0;

	bPlayerGameSettings[playerid]			= 0; // Empty the bit-array
	bPlayerDeathmatchSettings[playerid]		= 0;

	ResetPlayerDMVariables(playerid);
	ResetPerLifeKills(playerid);

// account
	pAdmin(playerid)						= 0,
	pSkin(playerid)							= 0,

// script
    gPlayerVehicleID[playerid]				= INVALID_VEHICLE_ID,
	gPlayerChatChannel[playerid]			= -1;
	gPlayerSpectating[playerid]				= INVALID_PLAYER_ID;
	gPlayerSpectateMode[playerid]			= SPECTATE_MODE_NORMAL;
	gPlayerSpectateGroup[playerid]			= -1;
	Warnings[playerid]						= 0;
	IncorrectPass[playerid]					= 0;
	prk_CurrentCheck[playerid]         		= -1;
	gCurrentMinigame[playerid]  			= MINIGAME_NONE;
	gPlayerRequest[playerid][rq_target]		= -1;
	gPlayerRequest[playerid][rq_tick]		= 0;
	gPlayerRequest[playerid][rq_type]		= REQUEST_TYPE_NULL;

// minigames
	smo_Spectating[playerid]				= DBY_SPEC_NONE;
	smo_TimesFallen[playerid]				= 0;

	dby_Spectating[playerid]				= DBY_SPEC_NONE;
	dby_Lives[playerid]						= DBY_MAX_LIVES;

	rc_playerData[playerid][rc_DistanceToFinish] = 99999.0;


	for(new i;i<10;i++)
		gPlayerQuickChat[playerid][i][0]	= EOS;

	PlayerLoop(i)
		Blocked[playerid][i] = false;

	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL,			100);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN,	100);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI,		100);
}




CMD:welcomemessage(playerid, params[])
{
    LogMessage(playerid);
    return 1;
}
LogMessage(playerid)
{
	new
		tmpStr[512],
		dmStr[100],
		rcStr[64],
		mgStr[64],
		adStr[64 * MAX_ADMIN],
		adminCount;

	if(bServerGlobalSettings & dm_InProgress)dmStr = "There is currently a "#C_RED"deathmatch"#C_WHITE", type "#C_BLUE"/joindm"#C_WHITE" to join\n";
	if(rc_CurrentRace != -1)rcStr = "There is currently a "#C_BLUE"race"#C_WHITE" in progress.\n";
	if(gCurrentChallenge != -1)mgStr = "There is currently a "#C_GREEN"challenge"#C_WHITE" in progress.\n";

	PlayerLoop(i)
	{
		if(pAdmin(i)>0)
		{
		    new tmpLine[64];
			adminCount++;
			format(tmpLine, 64, "\t%P"#C_WHITE" (level %d - %s)\n", i, pAdmin(i), AdminName[pAdmin(i)]);
			strcat(adStr, tmpLine);
		}
	}
	if(adminCount>0)strins(adStr, "Admins currently online:\n", 0);
	else adStr = "There are no admins online";

	format(tmpStr, 512,
		"\nWelcome to the server!\n\
		The current time is "#C_YELLOW"%02d:%02d"#C_WHITE"\n\
		The current weather is "#C_YELLOW"%s"#C_WHITE"\n\n\
		%s%s%s%s\n",
		gTimeHour, gTimeMinute, WeatherData[gWeatherID][weather_name],
		dmStr, rcStr, mgStr, adStr);

	strins(tmpStr, HORIZONTAL_RULE, 0);
	strins(tmpStr, #C_WHITE, 0);
	strcat(tmpStr, HORIZONTAL_RULE);

	ShowPlayerDialog(playerid, d_LogMsg, DIALOG_STYLE_MSGBOX, "Welcome to "#C_RED"Hellfire Server", tmpStr, "Accept", "");
}
stock FormatGenStats(playerid, type = 0)
{
	new str[550];
	if(type == 0)
	{
		new
			str2[550],
		    tm<tmRegDate>,
		    tm<tmLogDate>,
			tmpRegDate[32],
			tmpLogDate[32],
			t_total,
			t_session,
			t_inveh,
			t_onfoot,
			inveh_additional,
			onfoot_additional;

		localtime(Time:gPlayerData[playerid][ply_RegDate], tmRegDate);
		localtime(Time:gPlayerData[playerid][ply_LastLogged], tmLogDate);
		strftime(tmpRegDate, 32, "%x - %X", tmRegDate);
		strftime(tmpLogDate, 32, "%x - %X", tmLogDate);

		if(EnterVehTick[playerid]>0)inveh_additional=(tickcount()-EnterVehTick[playerid]);
		if(EnterFootTick[playerid]>0)onfoot_additional=(tickcount()-EnterFootTick[playerid]);

		t_total=(gPlayerData[playerid][ply_TimePlayed]+(tickcount()-gPlayerData[playerid][ply_JoinTick]));
		t_session=(tickcount()-gPlayerData[playerid][ply_JoinTick]);
		t_inveh=(gPlayerData[playerid][ply_TimeInVeh]+inveh_additional);
		t_onfoot=(gPlayerData[playerid][ply_TimeOnFoot]+onfoot_additional);


		format(str, 550, "\
			"#C_WHITE"Profile For: "#C_YELLOW"%s\n\n\
			"#C_BLUE"Favorite Skin\t\t\t"#C_GREEN"%d\n\
			"#C_BLUE"Gender\t\t\t"#C_GREEN"%s\n\n\
			"#C_BLUE"Times Joined\t\t\t"#C_GREEN"%d\n\
			"#C_BLUE"First Joined\t\t\t"#C_GREEN"%s\n",

			gPlayerName[playerid],
			pSkin(playerid),
			BoolToString(gPlayerData[playerid][ply_Sex], 5),
			gPlayerData[playerid][ply_Joins],
			tmpRegDate );


		format(str2, 550, "\
			"#C_BLUE"Last Logged In\t\t"#C_GREEN"%s\n\n\
			"#C_BLUE"Time Played (This Session):\t"#C_GREEN"%s\n\
			"#C_BLUE"Time Played (All Time):\t"#C_GREEN"%s\n\
			"#C_BLUE"Time In Vehicle:\t\t"#C_GREEN"%s\n\
			"#C_BLUE"Time On Foot:\t\t\t"#C_GREEN"%s\n\n\
			"#C_YELLOW"Admin Level:\t\t\t"#C_GREEN"%s (%d)\n",

			tmpLogDate,
			MsToString(t_session),
			MsToString(t_total),
			MsToString(t_inveh),
			MsToString(t_onfoot),
			AdminName[pAdmin(playerid)],
			pAdmin(playerid) );

		strcat(str, str2);
	}
	if(type == 1)
	{
		format(str, 300, "\
			"#C_BLUE"Kills:\t\t\t\t"#C_GREEN"%d\n\
			"#C_BLUE"Deaths:\t\t\t"#C_GREEN"%d\n\
			"#C_BLUE"XP:\t\t\t\t"#C_GREEN"%d\n\n\
			"#C_BLUE"Rank:\t\t\t\t"#C_GREEN"%s(%d)\n\
			"#C_BLUE"Next Rank:\t\t\t"#C_GREEN"%s(%d)\n\
			"#C_BLUE"XP To Go:\t\t\t"#C_GREEN"%d",

			pKills(playerid),
			pDeaths(playerid),
			pExp(playerid),
			RankNames[pRank(playerid)],
			pRank(playerid),
			RankNames[pRank(playerid)+1],
			pRank(playerid)+1,
			(RequiredExp[pRank(playerid)+1]-pExp(playerid)));
	}
	if(type == 2)
	{
		new
			Float:stat_hp,
			Float:stat_ap,
			InVeh[32],
			tmpCountry[32];

		GetPlayerHealth(playerid, stat_hp);
		GetPlayerArmour(playerid, stat_ap);
		GetCountryName(IpIntToStr(gPlayerData[playerid][ply_IP]), tmpCountry);

		if(IsPlayerInAnyVehicle(playerid))InVeh=VehicleNames[GetVehicleModel(GetPlayerVehicleID(playerid))-400];
		else InVeh="No";

		format(str, 320, "\
			"#C_BLUE"Health:\t\t\t"#C_GREEN"%.2f\n\
			"#C_BLUE"Armour:\t\t"#C_GREEN"%.2f\n\
			"#C_BLUE"IP\t\t\t"#C_GREEN"%s\n\
			"#C_BLUE"Using Godmode:\t"#C_GREEN"%s\n\
			"#C_BLUE"Money:\t\t"#C_GREEN"%d\n\
			"#C_BLUE"In Vehicle:\t\t"#C_GREEN"%s\n\
			"#C_BLUE"Country:\t\t"#C_GREEN"%s",
			stat_hp,
			stat_ap,
			IpIntToStr(gPlayerData[playerid][ply_IP]),
			BoolToString((bPlayerGameSettings[playerid]&GodMode), 1),
			GetPlayerMoney(playerid),
			InVeh,
			tmpCountry);
	}
	return str;
}
stock FormatGenStatsFromFile(file[], name[], type = 0)
{
	new str[550];

	if(type == 0)
	{
		new
			tmpGend,
			tmpSkin,
			tm<tmRegDate>,
			tm<tmLogDate>,
			tmpRegDate[32],
			tmpLogDate[32],
			tmpAdmin;

		tmpGend = GetGenderFromSkin(tmpSkin);

		localtime(Time:file_GetVal(KEY_T_RG), tmRegDate);
		localtime(Time:file_GetVal(KEY_T_LG), tmLogDate);
		strftime(tmpRegDate, 32, "%x - %X", tmRegDate);
		strftime(tmpLogDate, 32, "%x - %X", tmLogDate);

		for(new idx; idx<gTotalAdmins; idx++)
		{
			if(!strcmp(name, gAdminData[idx][admin_Name]))
			{
				tmpAdmin = gAdminData[idx][admin_Level];
				break;
			}
		}

		file_Open(file);

		format(str, 550, "\
			"#C_BLUE"Skin\t\t\t\t"#C_GREEN"%d\n\
			"#C_BLUE"Gender\t\t\t"#C_GREEN"%s\n\
			"#C_BLUE"Times Joined\t\t\t"#C_GREEN"%d\n\
			"#C_BLUE"First Joined\t\t\t"#C_GREEN"%s\n\
			"#C_BLUE"Last Logged In\t\t"#C_GREEN"%s\n\
			"#C_BLUE"Time Played (All Time):\t"#C_GREEN"%s\n\
			"#C_BLUE"Time In Vehicle:\t\t"#C_GREEN"%s\n\
			"#C_BLUE"Time On Foot:\t\t\t"#C_GREEN"%s\n\
			"#C_BLUE"Admin Level:\t\t\t"#C_GREEN"%d\n",

			tmpSkin,
			BoolToString(tmpGend, 5),
			file_GetVal(KEY_JCNT),
			tmpRegDate,
			tmpLogDate,
			MsToString(file_GetVal(KEY_T_GL)),
			MsToString(file_GetVal(KEY_T_VH)),
			MsToString(file_GetVal(KEY_T_FT)),
			tmpAdmin);

		file_Close();
	}
	if(type == 1)
	{
		new
			tmpQuery[128],
			DBResult:tmpResult,
			result[12],
			str2[256],
			tmpkills,
			tmpdeaths,
			tmpexp,
			tmprank,
			tmpheadshots,
			tmpteamkills,
			tmphighstreak,
			tmpwins,
			tmplosses;

		format(tmpQuery, sizeof(tmpQuery), "SELECT `Player` WHERE `"#ROW_NAME"` = '%s'", name);
		tmpResult = db_query(gAccounts, tmpQuery);

		db_get_field(tmpResult, 0, result, 12);
		tmpkills = strval(result);

		db_get_field(tmpResult, 1, result, 12);
		tmpdeaths = strval(result);

		db_get_field(tmpResult, 2, result, 12);
		tmpexp = strval(result);

		db_get_field(tmpResult, 3, result, 12);
		tmpheadshots = strval(result);

		db_get_field(tmpResult, 4, result, 12);
		tmpteamkills = strval(result);

		db_get_field(tmpResult, 5, result, 12);
		tmphighstreak = strval(result);

		db_get_field(tmpResult, 6, result, 12);
		tmpwins = strval(result);

		db_get_field(tmpResult, 7, result, 12);
		tmplosses = strval(result);

	    db_free_result(tmpResult);
	    
	    tmprank = GetRankFromExp(tmpexp);

		format(str, 550, "\
			"#C_BLUE"Kills:\t\t\t\t"#C_GREEN"%d\n\
			"#C_BLUE"Deaths:\t\t\t"#C_GREEN"%d\n\
			"#C_BLUE"XP:\t\t\t\t"#C_GREEN"%d\n\n\
			"#C_BLUE"Rank:\t\t\t\t"#C_GREEN"%s(%d)\n\
			"#C_BLUE"Next Rank:\t\t\t"#C_GREEN"%s(%d)\n\
			"#C_BLUE"XP To Go:\t\t\t"#C_GREEN"%d\n\n",
			tmpkills,
			tmpdeaths,
			tmpexp,
			RankNames[tmprank],
			tmprank,
			RankNames[tmprank+1],
			tmprank+1,
			RequiredExp[tmprank+1] - tmpexp);

		format(str2, 256, "\
			"#C_BLUE"Headshots:\t\t,"#C_GREEN"%d\n\
			"#C_BLUE"Teamkills:\t\t,"#C_GREEN"%d\n\
			"#C_BLUE"Highest Streak:\t,"#C_GREEN"%d\n\
			"#C_BLUE"Total Wins:\t\t,"#C_GREEN"%d\n\
			"#C_BLUE"Total Losses:\t\t,"#C_GREEN"%d\n",
			tmpheadshots,
			tmpteamkills,
			tmphighstreak,
			tmpwins,
			tmplosses);

		strcat(str, str2);
	}
	if(type == 2)
	{
		new
			tmpQuery[128],
			DBResult:tmpResult,
			tmpPassword[32],
			tmpIpStr[16],
			tmpIp,
			tmpCountry[32];

		format(tmpQuery, sizeof(tmpQuery), "SELECT * FROM `Player` WHERE `"#ROW_NAME"` = '%p'", name);
	    tmpResult = db_query(gAccounts, tmpQuery);
		db_get_field_assoc(tmpResult, #ROW_PASS, tmpPassword, MAX_PASSWORD_LEN);
		db_get_field_assoc(tmpResult, #ROW_PASS, tmpIpStr, MAX_PASSWORD_LEN);
		db_free_result(tmpResult);

		tmpIp = strval(tmpIpStr);

        GetCountryName(IpIntToStr(tmpIp), tmpCountry);

		format(str, 256, "\
			"#C_BLUE"IP\t\t\t\t\t"#C_GREEN"%s\n\
			"#C_BLUE"Country:\t\t"#C_GREEN"%s",

			IpIntToStr(tmpIp),
			tmpCountry);
	}
	return str;
}

CMD:changename(playerid, params[])
{
	new newname[24];
 	if (sscanf(params, "s[24]", newname)) Msg(playerid, YELLOW, "Usage: /changename [new name]");
	else
	{
		new
			tmpQuery[128],
			DBResult:tmpResult,
			file[MAX_PLAYER_FILE];

		GetFile(newname, file);

		format(tmpQuery, sizeof(tmpQuery), "SELECT * FROM `Player` WHERE `"#ROW_NAME"` = '%s'", newname);
		tmpResult = db_query(gAccounts, tmpQuery);

		if(db_num_rows(tmpResult) == 1 || fexist(file))
		{
			Msg(playerid, ORANGE, " >  That name already exists");
			return 1;
		}

		db_free_result(tmpResult);

		MsgF(playerid, YELLOW, " >  your new name is %s", newname);
		MsgAllF(YELLOW, " >  %s has changed their name to %s", gPlayerName[playerid], newname);

		format(tmpQuery, sizeof(tmpQuery), "UPDATE `Player` SET `"#ROW_NAME"` = '%s' WHERE `"#ROW_NAME"` = '%s'",
			newname, gPlayerName[playerid]);

		db_free_result(db_query(gAccounts, tmpQuery));

		SetPlayerName(playerid, newname);
		gPlayerName[playerid] = newname;

		CreateNewUserfile(playerid, gPlayerData[playerid][ply_Password]);
		SavePlayerData(playerid);

	}
	return 1;
}

CMD:changepass(playerid,params[])
{
	new
		oldpass[32],
		newpass[32],
		buffer[MAX_PASSWORD_LEN];

	if(!(bPlayerGameSettings[playerid] & LoggedIn))
		return Msg(playerid, YELLOW, " >  You must be logged in to use that command");

	if(sscanf(params, "s[32]s[32]", oldpass, newpass)) return Msg(playerid, YELLOW, "Usage: /changepass [old pass] [new pass]");
	else
	{
		WP_Hash(buffer, MAX_PASSWORD_LEN, oldpass);
		
		if(!strcmp(buffer, gPlayerData[playerid][ply_Password]))
		{
			new
				tmpQuery[256];

			WP_Hash(buffer, MAX_PASSWORD_LEN, newpass);

			format(tmpQuery, 256, "UPDATE `Player` SET `"#ROW_PASS"` = '%s' WHERE `"#ROW_NAME"` = '%s'",
			buffer, gPlayerName[playerid]);

			db_free_result(db_query(gAccounts, tmpQuery));
			
			gPlayerData[playerid][ply_Password] = buffer;

			MsgF(playerid, YELLOW, " >  Password succesfully changed to "#C_BLUE"%s"#C_YELLOW"!", newpass);
		}
		else
		{
			Msg(playerid, RED, " >  The entered password you typed doesn't match your current password.");
		}
	}
	return 1;
}

public OnPlayerSpawn(playerid)
{
	WalkerTickStart(playerid);
	PlayerPlaySound(playerid, 1186, 0.0, 0.0, 0.0);
	PreloadPlayerAnims(playerid);
	bitTrue(bPlayerGameSettings[playerid], Spawned);

	if(IsPlayerInFreeRoam(playerid))
	{
		if(gWeatherID < sizeof(WeatherData))
			SetPlayerWeather(playerid, WeatherData[gWeatherID][weather_id]);
		else
			SetPlayerWeather(playerid, gWeatherID);
	}

	if(bPlayerGameSettings[playerid] & InDM)
	{
		JoinLobby(playerid);
		return 1;
	}
	else if(bPlayerGameSettings[playerid] & InRace)
	{
	    rc_Leave(playerid);
	    return 1;
	}

    SetPlayerVirtualWorld(playerid, gHomeSpawn[playerid]);

	if(bServerGlobalSettings & FreeDM)defer fdm_Spawn(playerid);

	Streamer_Update(playerid);
	SetPlayerTeam(playerid, TEAM_GLOBAL);
	SetAllWeaponSkills(playerid, 999);

	gPlayerHP[playerid] = 100.0;
	gPlayerAP[playerid] = 0.0;

	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(tickcount() - gPlayerDeathTick[playerid] > 3000)
		return internal_OnPlayerDeath(playerid, killerid, reason);

	return 1;
}

internal_OnPlayerDeath(playerid, killerid, reason)
{
	gPlayerDeathTick[playerid] = tickcount();
	SendDeathMessage(killerid, playerid, reason);

	DriverTickEnd(playerid);
	WalkerTickEnd(playerid);

	stop TankHeatUpdateTimer[playerid];


	if(bPlayerGameSettings[playerid] & InDM)
	{
		if(killerid==INVALID_PLAYER_ID)
			script_Deathmatch_OnPlayerDie(playerid);
	}
	if(bPlayerGameSettings[playerid] & InRace)
		script_race_OnPlayerDeath(playerid);

	if(gCurrentMinigame[playerid] == MINIGAME_FALLOUT)
		dgw_Leave(playerid, false);

	if(gCurrentMinigame[playerid] == MINIGAME_GUNGAME)
		script_GunGame_OnPlayerDeath(playerid, killerid, reason);

	if(gCurrentChallenge != CHALLENGE_NONE)
	    script_Challenge_OnPlayerDeath(playerid, killerid);

	if(bServerGlobalSettings & FreeDM)
	    script_FreeDM_OnPlayerDeath(playerid, killerid);

	if(GetVehicleModel(GetPlayerVehicleID(playerid))==432)
		HidePlayerProgressBar(playerid, TankHeatBar);

	ResetSpectatorTarget(playerid);

	bitFalse(bPlayerGameSettings[playerid], Spawned);
	if(bPlayerGameSettings[playerid] & LoopingAnimation)
	{
		bitFalse(bPlayerGameSettings[playerid], LoopingAnimation);
		TextDrawHideForPlayer(playerid, StopAnimText);
	}

	return CallLocalFunction("OnDeath", "ddd", playerid, killerid, reason);
}


public OnPlayerUpdate(playerid)
{
	f:bPlayerGameSettings[playerid]<AfkCheck>;
	if(bPlayerGameSettings[playerid] & Frozen)return 0;
	if(bPlayerGameSettings[playerid] & DebugMode)
	{
	    new
			idx = GetPlayerAnimationIndex(playerid),
			animlib[32],
			animname[32],
			str[78];

		GetAnimationName(idx, animlib, 32, animname, 32);
		format(str, 78, "AnimIDX:%d~n~AnimName:%s~n~AnimLib:%s", idx, animname, animlib);
		ShowMsgBox(playerid, str);
	}
	if(IsPlayerInAnyVehicle(playerid))
	{
	    static
			str[8],
			Float:vx,
			Float:vy,
			Float:vz;

		GetVehicleVelocity(gPlayerVehicleID[playerid], vx, vy, vz);
		gPlayerVelocity[playerid] = floatsqroot( (vx*vx)+(vy*vy)+(vz*vz) ) * 150.0;
	    format(str, 32, "%.0fkm/h", gPlayerVelocity[playerid]);
	    PlayerTextDrawSetString(playerid, VehicleSpeedText, str);
	}

	if(bPlayerGameSettings[playerid] & InDM)
	{
	    static
			iCurWeap,
			iCurrentWeapon;

		iCurWeap = GetPlayerWeapon(playerid);
	    if(iCurWeap != iCurrentWeapon)
	    {
			script_Deathmatch_WeaponChange(playerid, iCurWeap);
			iCurrentWeapon=iCurWeap;
	    }
		if(gPlayerHP[playerid]>0.1)SetPlayerHealth(playerid, gPlayerHP[playerid]);
		else SetPlayerHealth(playerid, 0.1);
	    return 1;
	}
	else if(gCurrentMinigame[playerid] == MINIGAME_PARKOUR)
    {
        if(bPlayerGameSettings[playerid] & prk_Started)
        {
			static Float:z;

			GetPlayerPos(playerid, z, z, z);

			if(z < prk_CheckPointPos[prk_CurrentCourse[playerid]][prk_CurrentCheck[playerid]-1][3])
				prk_Fall(playerid);
		}
    }
	else
	{
		if(bPlayerGameSettings[playerid] & GodMode)
		{
			gPlayerHP[playerid] = 1000.0;
			gPlayerAP[playerid] = 1000.0;
			if(IsPlayerInAnyVehicle(playerid))
			{
				static pCar;
				pCar = GetPlayerVehicleID(playerid);
				RepairVehicle(pCar);
			}
		}
	}

	SetPlayerHealth(playerid, gPlayerHP[playerid]);
	SetPlayerArmour(playerid, gPlayerAP[playerid]);

	return 1;
}
public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid)
{
/*
	if(pAdmin(playerid) >= 4)
	{
		new str[64];
		format(str, 64, "took %.2f~n~from %p~n~weap %d", amount, issuerid, weaponid);
		ShowMsgBox(playerid, str, 1000, 120);
	}
*/
    if(issuerid == INVALID_PLAYER_ID)
    {
		if(bPlayerGameSettings[playerid] & InDM)
		{
			dm_GivePlayerHP(playerid, -(amount*2), .weapon = weaponid);
	    	tick_LastDamg[playerid] = tickcount();
		}
		else
		{
			if(!(bPlayerGameSettings[playerid] & GodMode))
			{
				if(weaponid == 53)
					GivePlayerHP(playerid, -(amount*0.5), .weaponid = weaponid);

				else
					GivePlayerHP(playerid, -(amount*2), .weaponid = weaponid);
			}
		}
		return 1;
	}
	switch(weaponid)
	{
		case 31:
		{
			new model = GetVehicleModel(gPlayerVehicleID[issuerid]);
			if(model == 447 || model == 476)internal_HitPlayer(issuerid, playerid, WEAPON_VEHICLE_BULLET);
		}
		case 38:
		{
			if(GetVehicleModel(gPlayerVehicleID[issuerid]) == 425)internal_HitPlayer(issuerid, playerid, WEAPON_VEHICLE_BULLET);
		}
		case 49:
		{
			internal_HitPlayer(issuerid, playerid, WEAPON_VEHICLE_COLLISION);
		}
		case 51:
		{
			new model = GetVehicleModel(gPlayerVehicleID[issuerid]);
			if(model == 432 || model == 520 || model == 425)internal_HitPlayer(issuerid, playerid, WEAPON_VEHICLE_EXPLOSIVE);
		}
	}
	return 1;
}
public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid)
{
	internal_HitPlayer(playerid, damagedid, weaponid);
	return 1;
}

internal_HitPlayer(playerid, targetid, weaponid)
{
	if(bPlayerGameSettings[playerid] & DmgLock)
		return 0;

	if(weaponid == WEAPON_DESERTEAGLE)
	{
		if(tickcount() - gWeaponHitTick[playerid] < 400)return 0;
	}
	else
	{
		if(tickcount() - gWeaponHitTick[playerid] < 100)return 0;
	}

	gWeaponHitTick[playerid] = tickcount();

	new head;
	
	if(!IsPlayerInAnyVehicle(playerid))
	{
		switch(weaponid)
		{
		    case 25, 27, 30, 31, 33, 34:head = IsPlayerAimingAtHead(playerid, targetid);
		}
	}

	if(bPlayerGameSettings[playerid]&InDM)
	{
		if(bPlayerGameSettings[targetid] & InDM && bPlayerGameSettings[targetid] & Spawned)
			script_Deathmatch_hitPlayer(playerid, targetid, head, weaponid);

        tick_LastDamg[targetid] = tickcount();
	}
	else
	{
		if(!(bPlayerGameSettings[targetid] & GodMode))
		{
			new
				Float:px,
				Float:py,
				Float:pz,
				Float:tx,
				Float:ty,
				Float:tz,
				Float:trgDist,
				Float:HpLoss;

			GetPlayerPos(playerid, px, py, pz);
			GetPlayerPos(playerid, tx, ty, tz);

			trgDist = Distance(px, py, pz, tx, ty, tz);

			if(trgDist < WepData[weaponid][MinDis])HpLoss = WepData[weaponid][MaxDam];
			if(trgDist > WepData[weaponid][MaxDis])HpLoss = WepData[weaponid][MinDam];
			else HpLoss = ((WepData[weaponid][MinDam]-WepData[weaponid][MaxDam])/(WepData[weaponid][MaxDis]-WepData[weaponid][MinDis])) * (trgDist-WepData[weaponid][MaxDis]) + WepData[weaponid][MinDam];

			GivePlayerHP(targetid, -HpLoss, playerid, weaponid);
			ShowHitMarker(playerid, weaponid);


			if(pAdmin(playerid) >= 4)
			{
				new str[32];
				format(str, 32, "did %.2f", HpLoss);
				ShowMsgBox(playerid, str, 1000, 120);
			}

		}
	}
	
	return 1;
}
GivePlayerHP(playerid, Float:hp, shooterid = INVALID_PLAYER_ID, weaponid = 54)
{
	if(gPlayerAP[playerid] > 0.0)
	{
		switch(weaponid)
		{
			case 0..7, 10..15:
				hp *= 0.8;

			case 22..32, 38:
				hp *= 0.7;

			case 33, 34:
				hp *= 0.99;
		}
		gPlayerAP[playerid] = hp / 2.0;
	}

	SetPlayerHP(playerid, (gPlayerHP[playerid] + hp), shooterid, weaponid);

	if(hp > 0.0)
	{
		new
			tmpstr[16];

		format(tmpstr, 16, "+%.1fHP", hp);

		PlayerTextDrawSetString(playerid, AddHPText, tmpstr);
		PlayerTextDrawShow(playerid, AddHPText);

		defer HideHPText(playerid);
	}
}

timer HideHPText[2000](playerid)
{
	PlayerTextDrawHide(playerid, AddHPText);
}

SetPlayerHP(playerid, Float:hp, shooterid = INVALID_PLAYER_ID, weaponid = 54)
{
	if(hp < 0.0 && bPlayerGameSettings[playerid] & Spawned)
		internal_OnPlayerDeath(playerid, shooterid, weaponid);

	if(hp > 100.0)
	    hp = 100.0;

	gPlayerHP[playerid] = hp;
}

/* Weapon Knockback

	if(weaponid==34)
	{
		new
		    Float:pX,
		    Float:pY,
		    Float:pZ,
		    Float:iX,
		    Float:iY,
		    Float:iZ,

		    Float:vX,
		    Float:vY,
		    Float:vZ,

			Float:pA;

		GetPlayerPos(playerid, pX, pY, pZ);
		GetPlayerPos(playerid, iX, iY, iZ);
		GetPlayerPos(playerid, vX, vY, vZ);

		pA = GetAngleToPoint(iX, iY, pX, pY);
		GetXYFromAngle(vX, vY, pA, 0.35);

		pX-=vX;
		pY-=pY;

		SetPlayerVelocity(playerid, pX, pY, -0.2);
		ApplyAnimation(playerid, "PED", "FALL_back", 4.0, 0, 1, 1, 1, 0, 1);
		defer GetUp(playerid);
	}
}
timer GetUp[1000](playerid)
{
	ApplyAnimation(playerid, "PED", "getup", 4.0, 0, 1, 1, 0, 0, 1);
}
*/

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(bPlayerGameSettings[playerid] & DebugMode)
		MsgF(playerid, YELLOW, "Newkeys: %d, OldKeys: %d", newkeys, oldkeys);

	if(IsPlayerInAnyVehicle(playerid))
	{
		new
			iPlayerVehicleID = GetPlayerVehicleID(playerid),
			iVehicleModel = GetVehicleModel(iPlayerVehicleID);

		if( ((newkeys&1) || (newkeys&4)) && (iVehicleModel==432) )
		{
			TankHeat[playerid] += 20.0;
			SetPlayerProgressBarMaxValue(playerid, TankHeatBar, 30.0);
			SetPlayerProgressBarValue(playerid, TankHeatBar, Float:TankHeat[playerid]);
			UpdatePlayerProgressBar(playerid, TankHeatBar);

			if(TankHeat[playerid] >= 30.0)
			{
				GameTextForPlayer(playerid, "~r~Overheating!!!", 3000, 5);
			}
			if(TankHeat[playerid] >= 40.0)
			{
				new Float:Tp[3];
				GetVehiclePos(iPlayerVehicleID, Tp[0], Tp[1], Tp[2]);
				CreateExplosion(Tp[0], Tp[1], Tp[2], 11, 5.0);
				TankHeat[playerid]=0.0;
			}
		}
		if(newkeys & KEY_CROUCH && IsPlayerInFreeRoam(playerid))
		{
			if( (bPlayerGameSettings[playerid]&SpeedBoost) && (GetPlayerState(playerid) == PLAYER_STATE_DRIVER) )
			{
				new Float:Velocity[3];
				GetVehicleVelocity(iPlayerVehicleID, Velocity[0],   Velocity[1],   Velocity[2]);
				SetVehicleVelocity(iPlayerVehicleID, Velocity[0]*2, Velocity[1]*2, Velocity[2]*2);
			}
			if( (bPlayerGameSettings[playerid]&JumpBoost) && (GetPlayerState(playerid) == PLAYER_STATE_DRIVER) )
			{
				new Float:Velocity[3];
				GetVehicleVelocity(iPlayerVehicleID, Velocity[0], Velocity[1], Velocity[2]);
				SetVehicleVelocity(iPlayerVehicleID, Velocity[0], Velocity[1], Velocity[2]+0.2);
			}
		}
		if(newkeys == KEY_ACTION)
		{
			if(iVehicleModel==525)
			{
				new
					Float:Player_vX,
					Float:Player_vY,
					Float:Player_vZ,
					Float:tmp_vX,
					Float:tmp_vY,
					Float:tmp_vZ;

				GetVehiclePos(iPlayerVehicleID, Player_vX, Player_vY, Player_vZ);

				for(new tmp_vID; tmp_vID<MAX_VEHICLES; tmp_vID++)
		   		{
		   		    GetVehiclePos(tmp_vID, tmp_vX, tmp_vY, tmp_vZ);
			   		if( (Distance(tmp_vX, tmp_vY, tmp_vZ, Player_vX, Player_vY, Player_vZ)<7.0) && (tmp_vID != iPlayerVehicleID) )
			   		{
			   			if(IsTrailerAttachedToVehicle(iPlayerVehicleID))DetachTrailerFromVehicle(iPlayerVehicleID);
			   			AttachTrailerToVehicle(tmp_vID, iPlayerVehicleID);
			   			break;
					}
				}
			}
		}
		if(newkeys & KEY_YES)
		{
			new Float:health;
			GetVehicleHealth(gPlayerVehicleID[playerid], health);

			if(health >= 400.0)
				v_Engine(gPlayerVehicleID[playerid], !v_Engine(gPlayerVehicleID[playerid]));
		}
		if(newkeys & KEY_NO)v_Lights(gPlayerVehicleID[playerid], !v_Lights(gPlayerVehicleID[playerid]));
	}
	else
	{
		if(newkeys & KEY_JUMP && !(oldkeys & KEY_JUMP) && GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED)ApplyAnimation(playerid, "GYMNASIUM", "gym_jog_falloff",4.1,0,1,1,0,0);
		if(bPlayerDeathmatchSettings[playerid]&dm_PlayingDead)ClearAnimations(playerid);

	    new iWepState = GetPlayerWeaponState(playerid);
		if((newkeys&KEY_FIRE)&&(iWepState!=WEAPONSTATE_RELOADING&&iWepState!=WEAPONSTATE_NO_BULLETS))OnPlayerShoot(playerid);
	}

	if(newkeys == 16 && bPlayerGameSettings[playerid] & LoopingAnimation)
	{
		StopLoopAnimation(playerid);
		TextDrawHideForPlayer(playerid, StopAnimText);
    }

	return 1;
}

OnPlayerShoot(playerid)
{
	if(bPlayerGameSettings[playerid]&InDM)script_Deathmatch_PlayerShoot(playerid);
}

public OnVehicleSpawn(vehicleid)
{
	if(bServerGlobalSettings & dm_InProgress)script_Deathmatch_VehicleSpawn(vehicleid);
}
public OnVehicleDeath(vehicleid)
{
	if(bServerGlobalSettings & dm_InProgress)script_Deathmatch_VehicleDeath(vehicleid);
	if(bServerGlobalSettings & rc_Started)script_Race_OnVehicleDeath(vehicleid);
}
public OnVehicleDamageStatusUpdate(vehicleid)
{
	script_prd_VehicleDamageUpdate(vehicleid);
	return 1;
}

public OnUnoccupiedVehicleUpdate(vehicleid, playerid, passenger_seat)
{
	return 1;
}



public OnPlayerEnterDynamicRaceCP(playerid, checkpointid)
{
	script_race_EnterDynamicRaceCP(playerid, checkpointid);
    if(gCurrentMinigame[playerid] == MINIGAME_PRDRIVE)script_prd_EnterDynamicRaceCP(playerid, checkpointid);
	return 0;
}
public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
//	if(bServerGlobalSettings&FreeDM)script_FreeDM_OnPlayerPickup(playerid, pickupid);

	if(bServerGlobalSettings & dm_InProgress && bPlayerGameSettings[playerid] & InDM)
		script_Deathmatch_Pickup(playerid, pickupid);

	return 1;
}
public OnPlayerEnterDynamicArea(playerid, areaid)
{
	if((bServerGlobalSettings & dm_InProgress) && bPlayerGameSettings[playerid] & InDM)
		script_Deathmatch_EnterArea(playerid, areaid);

    return 1;
}
public OnPlayerLeaveDynamicArea(playerid, areaid)
{
	if((bServerGlobalSettings&dm_InProgress) && bPlayerGameSettings[playerid]&InDM)script_Deathmatch_ExitArea(playerid, areaid);
	if(dgw_State != 0)script_dgw_LeaveDynamicArea(playerid, areaid);

	return 1;
}

public OnPlayerText(playerid, text[])
{
	new tmpMuteTime = tickcount() - ChatMuteTick[playerid];

	if(bServerGlobalSettings & ChatLocked)
	{
		Msg(playerid, ORANGE, " >  Chat Locked");
		return 0;
	}
	if(bPlayerGameSettings[playerid]&Muted)
	{
		Msg(playerid, RED, " >  You are muted");
		return 0;
	}
	if(tmpMuteTime < 10000)
	{
	    MsgF(playerid, RED, " >  You are muted for chat flooding, %s remaining.", MsToString(10000-tmpMuteTime, 2));
	    return 0;
	}


	if(tickcount() - tick_LastChatMessage[playerid] < 1000)
	{
		ChatMessageStreak[playerid]++;
		if(ChatMessageStreak[playerid] == 5)
		{
		    ChatMuteTick[playerid] = tickcount();
		    return 0;
		}
	}
	else ChatMessageStreak[playerid]--;

	tick_LastChatMessage[playerid] = tickcount();

	if(gPlayerChatChannel[playerid] != CHANNEL_GLOBAL)
	{
	    if(gPlayerChatChannel[playerid] < MAX_PLAYERS)
	    {
	    	if(!IsPlayerConnected(gPlayerChatChannel[playerid]))
	    	{
	    	    gPlayerChatChannel[playerid] = -1;
	    	    Msg(playerid, RED, " >  The player you were chatting with has gone offline");
	    	    return 0;
	    	}
	    	MsgF(gPlayerChatChannel[playerid], GREEN, "(P)%P"#C_WHITE": %s", playerid, text);
	    	MsgF(playerid, GREEN, "(P)%P"#C_WHITE": %s", playerid, text);
	    }
	    else if(gPlayerChatChannel[playerid] == CHANNEL_TEAM)
	    {
			MsgTeamF(pTeam(playerid), BLUE, "(T)%P"#C_WHITE": %s", playerid, text);
	    }
	    else if(gPlayerChatChannel[playerid] == CHANNEL_VEHICLE)
	    {
			PlayerLoop(i)
				if(IsPlayerInVehicle(i, GetPlayerVehicleID(playerid)))
					MsgF(i, WHITE, "(V)%P"#C_WHITE": %s", playerid, TagScan(playerid, text));
	    }
	    return 0;
	}
	else PlayerSendChat(playerid, text);

	return 0;
}
PlayerSendChat(playerid, textInput[])
{
	new
		text[256];

/*
	if(HasIP(textInput))
	{
	    MsgAllF(WHITE, "%C(%d) %P"#C_WHITE": plzz join mi awsum servr plzzz ip: 127.0.0.1 plz",
			AdminColours[pAdmin(playerid)],
			playerid,
			playerid);

		return 0;
	}
*/

	if(bPlayerGameSettings[playerid] & InDM)
		format(text, 173, "%C(%d) %C[%s]%P"#C_WHITE": %s",
			AdminColours[pAdmin(playerid)],
			playerid,
			RankColours[pRank(playerid)],
			RankAbv[pRank(playerid)],
			playerid,
			TagScan(playerid, textInput));

	else
		format(text, 173, "%C(%d) %P"#C_WHITE": %s",
			AdminColours[pAdmin(playerid)],
			playerid,
			playerid,
			TagScan(playerid, textInput));

	if(strlen(text) > 127)
	{
		new
			text2[128],
			splitpos;

		for(new c = 128; c > 0; c--)
		{
			if(text[c] == ' ' || text[c] ==  ',' || text[c] ==  '.')
			{
			    splitpos = c;
			    break;
			}
		}

		strcat(text2, text[splitpos]);
		text[splitpos] = 0;

		PlayerLoop(i)if(!Hidden[playerid][i])
		{
			SendClientMessage(i, WHITE, text);
			SendClientMessage(i, WHITE, text2);
		}
	}
	else
	{
		PlayerLoop(i)if(!Hidden[playerid][i])
			SendClientMessage(i, WHITE, text);
	}

	return 1;
}

stock HasIP(str[])
{
	new
	    tmp[17],
		len = strlen(str),
		i;

	while(i < len)
	{
		if('0' <= str[i] <= '9')
		{
			strmid(tmp, str, i, i+16);

			if(!sscanf(tmp, "{p<.>dddd}"))return 1;
			if(!sscanf(tmp, "{p<.>ddd}{p<:>dd}"))return 1;
		}
		i++;
	}
	return 0;
}
enum E_COLOUR_EMBED_DATA
{
	ce_char,
	ce_colour[9]
}
stock const Phonetics[26][10]=
{
	"alpha",
	"bravo",
	"charlie",
	"delta",
	"echo",
	"foxtrot",
	"golf",
	"hotel",
	"india",
	"juliet",
	"kilo",
	"lima",
	"mike",
	"november",
	"oscar",
	"papa",
	"quebec",
	"romeo",
	"sierra",
	"tango",
	"uniform",
	"vector",
	"whiskey",
	"x-ray",
	"yankee",
	"zulu"
},
EmbedColours[9][E_COLOUR_EMBED_DATA]=
{
	{'r', #C_RED},
	{'g', #C_GREEN},
	{'b', #C_BLUE},
	{'y', #C_YELLOW},
	{'p', #C_PINK},
	{'w', #C_WHITE},
	{'o', #C_ORANGE},
	{'n', #C_NAVY},
	{'a', #C_AQUA}
};
stock TagScan(playerid, chat[], colour = WHITE)
{
	new
		text[256],
		length,
		a,
		tags;

	strcpy(text, chat);
	length = strlen(chat);
	
	while(a < (length - 1) && tags < 3)
	{
		if(text[a] == '#')
		{
			if(IsCharNumeric(text[a+1]))
			{
				new chatid = strval(text[a+1]);
				if(strcmp(gPlayerQuickChat[playerid][chatid], "NULL", true) && (strlen(gPlayerQuickChat[playerid][chatid])>1))
				{
				    new tmpStr[50];
				    tmpStr = gPlayerQuickChat[playerid][chatid];

					strdel(text[a], 0, 2);
					strins(text[a], gPlayerQuickChat[playerid][chatid], 0);

					a+=strlen(tmpStr);
					length+=strlen(tmpStr) - 2;
					continue;
				}
				else a++;
			}
			/*
			if(IsCharAlphabetic(text[a+1]))
			{
			    new replacements;
			    for(new i;i<sizeof(Phonetics);i++)
			    {
			        if(text[a+1] == Phonetics[i][0])
			        {
						strdel(text[a], 0, 2);
						strins(text[a], Phonetics[i], 0);
		                length+=strlen(Phonetics[i]);
						a+=strlen(Phonetics[i]);
						replacements++;
						break;
			        }
			    }
			    if(replacements==0)a++;
			}
			*/
			if(IsCharAlphabetic(text[a+1]))
			{
				text[a+1] = tolower(text[a+1]);

                strdel(text[a], 0, 2);
				strins(text[a], Phonetics[ text[a+1]-65 ], 0);

				a += strlen(Phonetics[ text[a+1]-65 ]);
				length += strlen(Phonetics[ text[a+1]-65 ]) - 2;
				continue;
			}
			else a++;
		}
		else if(text[a]=='@')
		{
		    if(IsCharNumeric(text[a+1]))
		    {
				new
					id,
					tmp[3];

				strmid(tmp, text, a+1, a+3);
				id = strval(tmp);

				if(IsPlayerConnected(id))
				{
					new
						tmpName[MAX_PLAYER_NAME+20];

					if(bPlayerGameSettings[id] & IsAfk)
						format(tmpName, MAX_PLAYER_NAME+20, "%P(!)%C", id, colour);

					else
						format(tmpName, MAX_PLAYER_NAME+17, "%P%C", id, colour);


					if(id<10)
						strdel(text[a], 0, 2);

					else
						strdel(text[a], 0, 3);

					strins(text[a], tmpName, 0);

	                length += strlen(tmpName);
					a += strlen(tmpName);
					tags++;
					continue;
				}
				else a++;
			}
			else a++;
		}
		else if(text[a]=='&')
		{
			if(IsCharAlphabetic(text[a+1]))
			{
			    new replacements;
			    for(new i;i<sizeof(EmbedColours);i++)
			    {
			        if(text[a+1] == EmbedColours[i][ce_char])
			        {
						strdel(text[a], 0, 2);
						strins(text[a], EmbedColours[i][ce_colour], 0);
		                length+=8;
						a+=8;
						replacements++;
						break;
			        }
			    }
				if(replacements==0)a++;
			}
			else a++;
		}
		else a++;
	}
	return text;
}
CMD:qmsg(playerid, params[])
{
	new
		id,
		msg[128];

	if(sscanf(params, "ds[128]", id, msg))
		return Msg(playerid, YELLOW, "Usage: /qmsg [message number 0-9] [message - character limit: 50]");

	gPlayerQuickChat[playerid][id][0]='\0';
	strcat(gPlayerQuickChat[playerid][id], msg);
	MsgF(playerid, YELLOW, "QuickChat phrase %d saved, use by typing '#%d' in chat for a list of Quick-chat Phrases type '/qlist'", id, id);

	return 1;
}
CMD:qlist(playerid, params[])
{
    new str[520];

    for(new s;s<10;s++)
		format(str, 500, "%s{FFFF00}#%d {FFFFFF}- {33AA33}%s\n", str, s, gPlayerQuickChat[playerid][s]);

	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Quick Messages, insert to chat with '#<message number>'", str, "Close", "");
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	new vehicleid = GetPlayerVehicleID(playerid);
	bitFalse(bPlayerDeathmatchSettings[playerid], dm_Shooting);

	if(bPlayerGameSettings[playerid] & DebugMode)
		MsgF(playerid, YELLOW, "Newstate: %d, Oldstate: %d", newstate, oldstate);

	if(newstate==PLAYER_STATE_ONFOOT)
	{
		WalkerTickStart(playerid);
	}
	if(oldstate==PLAYER_STATE_ONFOOT)
	{
		WalkerTickEnd(playerid);
	}

	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
	{
		new model = GetVehicleModel(vehicleid);

	    if(newstate == PLAYER_STATE_DRIVER)
	    {
			v_Engine(vehicleid, 1);

			if(model == 525)
				Msg(playerid, YELLOW, "You can use the ACTION KEY to Tow cars");

			SetPlayerArmedWeapon(playerid, 0);

			if(model == 432)
			{
				TankHeatUpdateTimer[playerid] = repeat TankHeatUpdate(playerid);
				ShowPlayerProgressBar(playerid, TankHeatBar);
			}
	    }

		gPlayerVehicleID[playerid] = vehicleid;
		DriverTickStart(playerid);

		t:bVehicleSettings[vehicleid]<v_Used>;
		t:bVehicleSettings[vehicleid]<v_Occupied>;

		PlayerTextDrawSetString(playerid, VehicleNameText, VehicleNames[model-400]);
		PlayerTextDrawShow(playerid, VehicleNameText);
		PlayerTextDrawShow(playerid, VehicleSpeedText);
	}
	if(oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER)
	{
	    if(oldstate == PLAYER_STATE_DRIVER)
	    {
			v_Engine(vehicleid, 0);

		    if(bPlayerGameSettings[playerid] & AntiFallOffBike)
		    {
		    	if(GetVehicleType(gPlayerVehicleID[playerid]) == VTYPE_BIKE && tickcount()-tick_ExitVehicle[playerid] > 2000)
					PutPlayerInVehicle(playerid, gPlayerVehicleID[playerid], 0);
			}

			if(bPlayerGameSettings[playerid] & InRace)
				rc_Leave(playerid);
	    }

	    gPlayerVehicleID[playerid] = INVALID_VEHICLE_ID;
		DriverTickEnd(playerid);

		f:bVehicleSettings[vehicleid]<v_Occupied>;

		PlayerTextDrawHide(playerid, VehicleNameText);
		PlayerTextDrawHide(playerid, VehicleSpeedText);
		HidePlayerProgressBar(playerid, TankHeatBar);
		stop TankHeatUpdateTimer[playerid];

		if(gPlayerChatChannel[playerid] == CHANNEL_VEHICLE)
		{
			gPlayerChatChannel[playerid] = CHANNEL_GLOBAL;
			Msg(playerid, YELLOW, " >  You are now talking on the "#C_BLUE"global "#C_YELLOW"chat channel");
		}
	}
	return 1;
}
public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);

	if(!ispassenger)
	{
		PlayerLoop(i)
		{
			if(gPlayerSpectating[i] == playerid) PlayerSpectateVehicle(i, vehicleid);
			if(IsPlayerInVehicle(i, vehicleid) && GetPlayerState(i) == PLAYER_STATE_DRIVER && playerid != i)
			{
			    ClearAnimations(playerid, 1);
				SetPlayerPos(playerid, x, y, z);
			}
			if(vehicleid == gPlayerSpawnedVehicle[i] && i != playerid)
			{
				gPlayerSpawnedVehicle[i] = INVALID_VEHICLE_ID;
				if(IsValidVehicle(gPlayerSpawnedVehicle[playerid]))
				{
					DestroyVehicle(gPlayerSpawnedVehicle[playerid]);
					gPlayerSpawnedVehicle[playerid] = INVALID_VEHICLE_ID;
				}

				gPlayerSpawnedVehicle[playerid] = vehicleid;
			}
		}
	}
	if(gCurrentChallenge == 0)
	{
	    switch(GetVehicleType(vehicleid))
	    {
	        case VTYPE_HELI, VTYPE_PLANE:
	        {
			    ClearAnimations(playerid, 1);
				SetPlayerPos(playerid, x, y, z);
				Msg(playerid, RED, " >  Air Vehicles are not allowed in the Marked Man event.");
	        }
	    }
	}
	return 1;
}
public OnPlayerExitVehicle(playerid, vehicleid)
{
	if(GetVehicleModel(vehicleid) == 432)
		HidePlayerProgressBar(playerid, TankHeatBar);

	PlayerLoop(i)
		if(gPlayerSpectating[i] == playerid)PlayerSpectatePlayer(i, playerid);

	tick_ExitVehicle[playerid] = tickcount();

	return 1;
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_Login)
	{
		if(response)
		{
			if(strlen(inputtext) < 4)
			{
				ShowPlayerDialog(playerid, d_Login, DIALOG_STYLE_PASSWORD, "Login To Your Account", "Type your password below", "Accept", "Quit");
				return 1;
			}

			new hash[MAX_PASSWORD_LEN];
			WP_Hash(hash, MAX_PASSWORD_LEN, inputtext);

			if(!strcmp(hash, gPlayerData[playerid][ply_Password]))
				Login(playerid);

			else
			{
				new str[64];
				IncorrectPass[playerid]++;
				format(str, 64, "Incorrect password! %d out of 5 tries", IncorrectPass[playerid]);
				ShowPlayerDialog(playerid, d_Login, DIALOG_STYLE_PASSWORD, "Login To Your Account", str, "Accept", "Quit");
				if(IncorrectPass[playerid] == 5)
				{
					IncorrectPass[playerid] = 0;
					Kick(playerid);
					MsgAllF(GREY, " >  %s left the server without logging in.", gPlayerName[playerid]);
				}
			}
		}
		else
		{
			MsgAllF(GREY, " >  %s left the server without logging in.", gPlayerName[playerid]);
			Kick(playerid);
		}
	}
	if(dialogid == d_Register)
	{
		if(response)
		{
			if(!(4 <= strlen(inputtext) <= 32))
			{
				ShowPlayerDialog(playerid, d_Register, DIALOG_STYLE_PASSWORD, ""#C_RED"Password too short/long!\n"C_YELLOW"Password must be between 4 and 32 characters.", "Type your password below", "Accept", "Quit");
				return 0;
			}
			new
				buffer[MAX_PASSWORD_LEN];

			WP_Hash(buffer, MAX_PASSWORD_LEN, inputtext);
			GivePlayerMoney(playerid, 500);

			CreateNewUserfile(playerid, buffer);

			new tmpStr[512];
			strcat(tmpStr, HORIZONTAL_RULE);
			strcat(tmpStr, "\n"#C_WHITE"Your new account has been created! You have "C_YELLOW"$500"C_WHITE" as a welcome gift!\n");
			strcat(tmpStr, "Please take some time to read the "#C_BLUE"/rules"#C_WHITE" and abide by them\n");
			strcat(tmpStr, "Enjoy your time playing on the Hellfire server :)\n");
			strcat(tmpStr, HORIZONTAL_RULE);
			ShowPlayerDialog(playerid, d_WelcomeMsg, DIALOG_STYLE_MSGBOX, "Welcome to "#C_RED"Hellfire Server", tmpStr, "Close", "");
		}
		else
		{
			MsgAllF(GREY, " >  %s left the server without registering.", gPlayerName[playerid]);
			Kick(playerid);
		}
	}
	if(dialogid == d_WelcomeMsg && response)
	{
		LogMessage(playerid);
	}
	if(dialogid == d_SpawnList)
	{
		if(response)
		{
			SetPlayerSpawnCam(playerid, listitem);
			ShowPlayerSpawnList(playerid);
		}
		else
		{
			SetCameraBehindPlayer(playerid);

			SetSpawnInfo(playerid, NO_TEAM, GetPlayerSkin(playerid),
				HomeSpawnData[gHomeSpawn[playerid]][spn_posX], HomeSpawnData[gHomeSpawn[playerid]][spn_posY], HomeSpawnData[gHomeSpawn[playerid]][spn_posZ], HomeSpawnData[gHomeSpawn[playerid]][spn_rotZ], 0,0,0,0,0,0);

			f:bPlayerGameSettings[playerid]<GodMode>;
			SetPlayerVirtualWorld(playerid, FREEROAM_WORLD);
			gHomeSpawn[playerid] = listitem;
		}
	}


	if(dialogid == d_Colourlist)
	{
		if(response)
		{
		    gPlayerColour[playerid] = listitem;
			SetPlayerColor(playerid, ColourData[listitem][colour_value]);
		}
	}
	if(dialogid == d_WeatherList && response)
	{
		gWeatherID = listitem;
		PlayerLoop(i)
		{
			if(GetPlayerVirtualWorld(i) == FREEROAM_WORLD)
			{
				SetPlayerWeather(i, WeatherData[listitem][weather_id]);
				MsgF(i, YELLOW, " >  Weather set to "#C_BLUE"%s", WeatherData[listitem][weather_name]);
			}
		}
	}
	if(dialogid==d_RadioList)
	{
	    if(response)PlayAudioStreamForPlayer(playerid, RadioStreams[listitem][0]);
	    else StopAudioStreamForPlayer(playerid);
	}
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	new
		cmd[30],
		params[98],
		szFuncName[64],
		result = 1;

	printf("[cmmd] [%p]: %s", playerid, cmdtext);

	sscanf(cmdtext, "s[30]s[98]", cmd, params);

	for (new i; i < strlen(cmd); i++)
		cmd[i] = tolower(cmd[i]);

	format(szFuncName, 64, "cmd_%s", cmd[1]); // Format the standard command function name
	if(funcidx(szFuncName) == -1) // If it doesn't exist, all hope is not lost! It might be defined as an admin command which has the admin level after the command name
	{
	    new
			iLvl = pAdmin(playerid), // The player's admin level
			iLoop = 4; // The highest admin level

	    while(iLoop>0) // Loop backwards through admin levels, from 4 to 1
		{
			format(szFuncName, 64, "cmd_%s_%d", cmd[1], iLoop); // format the function to include the admin variable
			if(funcidx(szFuncName) != -1)break; // if this function exists, break the loop, at this point iLoop can never be worth 0
			iLoop--; // otherwise just advance to the next iteration, iLoop can become 0 here and thus break the loop at the next iteration
		}
		// If iLoop was 0 after the loop that means it above completed it's last itteration and never found an existing function
		if(iLoop==0)result = 0;
		// If the players level was below where the loop found the existing function,
		// that means the number in the function is higher than the player id
		// Give a 'not high enough admin level' error
		if(iLvl<iLoop)result = 5;
	}
	if(result == 1)
	{
		if(isnull(params))result = CallLocalFunction(szFuncName, "is", playerid, "\1");
		else result = CallLocalFunction(szFuncName, "is", playerid, params);
	}

	if(IsPlayerInFreeRoam(playerid))
	{
		if(result == 0)
			result = script_Vehicles_CommandText(playerid, cmd);

		if(result == 0)
			result = script_Teleports_CommandText(playerid, cmd);
	}

	// Return values for commands, instead of writing these
	// messages on the commands themselves, I can just
	// write them here and return different values on the commands.

	if		(result == 0) Msg(playerid, ORANGE, " >  That is not a recognized command. Check the "#C_BLUE"/help "#C_ORANGE"menu for a list of commands.");
//	if		(result == 1) -- valid command, do nothing.
	else if	(result == 2) Msg(playerid, ORANGE, " >  You cannot use that command right now.");
	else if	(result == 3) Msg(playerid, RED, " >  You cannot use that command on that player right now.");
	else if	(result == 4) Msg(playerid, RED, " >  Invalid ID");
	else if (result == 5) Msg(playerid, RED, " >  You have insufficient authority to use that command.");

	return 1;
}


LoadTextDraws()
{
	print("- Loading TextDraws...");

//=======================================================================Infobar
	InfoBar					=TextDrawCreate(320.000000, 435.000000, "Information bar for holding information about the server. If this message shows, something is broken!");
	TextDrawAlignment		(InfoBar, 2);
	TextDrawBackgroundColor	(InfoBar, 255);
	TextDrawFont			(InfoBar, 1);
	TextDrawLetterSize		(InfoBar, 0.32, 1.2);
	TextDrawColor			(InfoBar, -1);
	TextDrawSetOutline		(InfoBar, 0);
	TextDrawSetProportional	(InfoBar, 1);
	TextDrawSetShadow		(InfoBar, 1);
	TextDrawUseBox			(InfoBar, 1);
	TextDrawBoxColor		(InfoBar, 0x000000AA);
	TextDrawTextSize		(InfoBar, 20.000000, 640.000000);

//=========================================================================Clock
	ClockText				=TextDrawCreate(605.0, 25.0, "00:00");
	TextDrawUseBox			(ClockText, 0);
	TextDrawFont			(ClockText, 3);
	TextDrawSetShadow		(ClockText, 0);
	TextDrawSetOutline		(ClockText, 2);
	TextDrawBackgroundColor	(ClockText, 0x000000FF);
	TextDrawColor			(ClockText, 0xFFFFFFFF);
	TextDrawAlignment		(ClockText, 3);
	TextDrawLetterSize		(ClockText, 0.5, 1.6);

//=====================================================================Animation
	StopAnimText 			=TextDrawCreate(610.0, 400.0, "~b~~k~~VEHICLE_ENTER_EXIT~ ~w~to stop the animation");
	TextDrawLetterSize		(StopAnimText, 0.5, 1.0);
	TextDrawUseBox			(StopAnimText, 0);
	TextDrawFont			(StopAnimText, 2);
	TextDrawSetShadow		(StopAnimText, 0);
    TextDrawSetOutline		(StopAnimText, 1);
    TextDrawBackgroundColor	(StopAnimText, 0x000000FF);
    TextDrawColor			(StopAnimText, 0xFFFFFFFF);
    TextDrawAlignment		(StopAnimText, 3);

//===============================================================Countdown Timer
	CountdownText			=TextDrawCreate(20.0, 250.0, "00:00");
	TextDrawTextSize		(CountdownText, 636.000000, 824.000000);
	TextDrawAlignment		(CountdownText, 0);
	TextDrawFont			(CountdownText, 3);
	TextDrawLetterSize		(CountdownText, 0.499999, 1.800000);
	TextDrawColor			(CountdownText, 0xffffffff);
	TextDrawSetProportional	(CountdownText, 2);
	TextDrawSetShadow		(CountdownText, 1);
	TextDrawSetOutline		(CountdownText, 1);


//=========================================================================Score
	ScoreBox				=TextDrawCreate(20.0, 280.0, " Raven: 0/10~n~   Valor: 0/10");
	TextDrawUseBox			(ScoreBox, 1);
	TextDrawBoxColor		(ScoreBox, 0x00000033);
	TextDrawTextSize		(ScoreBox, 158.000000, 10.000000);
	TextDrawAlignment		(ScoreBox, 0);
	TextDrawBackgroundColor	(ScoreBox, 0x000000ff);
	TextDrawFont			(ScoreBox, 1);
	TextDrawLetterSize		(ScoreBox, 0.3, 1.4);
	TextDrawColor			(ScoreBox, 0xffffffff);
	TextDrawSetOutline		(ScoreBox, 1);
	TextDrawSetProportional	(ScoreBox, 1);
	TextDrawSetShadow		(ScoreBox, 1);

//==================================================================Score Status
	ScoreStatus_Winning		=TextDrawCreate(20.0, 260.0, "Winning");
	TextDrawBackgroundColor	(ScoreStatus_Winning, BLACK);
	TextDrawFont			(ScoreStatus_Winning, 1);
	TextDrawLetterSize		(ScoreStatus_Winning, 0.5, 1.6);
	TextDrawSetOutline		(ScoreStatus_Winning, 1);

	ScoreStatus_Tie			=TextDrawCreate(20.0, 260.0, "Tie");
	TextDrawBackgroundColor	(ScoreStatus_Tie, BLACK);
	TextDrawFont			(ScoreStatus_Tie, 1);
	TextDrawLetterSize		(ScoreStatus_Tie, 0.5, 1.6);
	TextDrawSetOutline		(ScoreStatus_Tie, 1);

	ScoreStatus_Losing		=TextDrawCreate(20.0, 260.0, "Losing");
	TextDrawBackgroundColor	(ScoreStatus_Losing, BLACK);
	TextDrawFont			(ScoreStatus_Losing, 1);
	TextDrawLetterSize		(ScoreStatus_Losing, 0.5, 1.6);
	TextDrawSetOutline		(ScoreStatus_Losing, 1);

//=========================================================================Lobby
	LobbyText				=TextDrawCreate(600.000000,245.000000,"99 Players In Lobby~n~Type /joindm to join");
	TextDrawAlignment		(LobbyText,3);
	TextDrawBackgroundColor	(LobbyText,0x000000ff);
	TextDrawFont			(LobbyText,3);
	TextDrawLetterSize		(LobbyText,0.399999,1.599999);
	TextDrawColor			(LobbyText,0x00ff00ff);
	TextDrawSetOutline		(LobbyText,1);
	TextDrawSetProportional	(LobbyText,1);
	TextDrawSetShadow		(LobbyText,1);

//====================================================================SpawnCount
	SpawnCount				=TextDrawCreate(600.000000,245.000000,"Spawning in 10");
	TextDrawAlignment		(SpawnCount, 3);
	TextDrawBackgroundColor	(SpawnCount, 0x000000ff);
	TextDrawFont			(SpawnCount, 3);
	TextDrawLetterSize		(SpawnCount, 0.399999, 1.599999);
	TextDrawColor			(SpawnCount, 0x00ff00ff);
	TextDrawSetOutline		(SpawnCount, 1);
	TextDrawSetProportional	(SpawnCount, 1);
	TextDrawSetShadow		(SpawnCount, 1);

//====================================================================Match Time
	MatchTimeCounter		=TextDrawCreate(20.0, 240.0, "00:00");
	TextDrawBackgroundColor	(MatchTimeCounter, 255);
	TextDrawUseBox			(MatchTimeCounter, 1);
	TextDrawBoxColor		(MatchTimeCounter, 0x00000033);
	TextDrawTextSize		(MatchTimeCounter, 70.000000, 0.000000);
	TextDrawFont			(MatchTimeCounter, 3);
	TextDrawLetterSize		(MatchTimeCounter, 0.5, 1.8);
	TextDrawColor			(MatchTimeCounter, 0xffffffff);
	TextDrawSetProportional	(MatchTimeCounter, 1);
	TextDrawSetShadow		(MatchTimeCounter, 1);
	TextDrawSetOutline		(MatchTimeCounter, 1);

//=====================================================================HitMarker
	new hm[14];
	hm[0] =92,	hm[1] =' ',hm[2] ='/',hm[3] ='~',hm[4] ='n',hm[5] ='~',	hm[6] =' ',
	hm[7] ='~',	hm[8] ='n',hm[9] ='~',hm[10]='/',hm[11]=' ',hm[12]=92,  hm[13]=EOS;
	//"\ /~n~ ~n~/ \"

	HitMark_centre			=TextDrawCreate(305.500000, 208.500000, hm);
	TextDrawBackgroundColor	(HitMark_centre, -1);
	TextDrawFont			(HitMark_centre, 1);
	TextDrawLetterSize		(HitMark_centre, 0.500000, 1.000000);
	TextDrawColor			(HitMark_centre, -1);
	TextDrawSetProportional	(HitMark_centre, 1);
	TextDrawSetOutline		(HitMark_centre, 0);
	TextDrawSetShadow		(HitMark_centre, 0);

	HitMark_offset			=TextDrawCreate(325.500000, 165.500000, hm);
	TextDrawBackgroundColor	(HitMark_offset, -1);
	TextDrawFont			(HitMark_offset, 1);
	TextDrawLetterSize		(HitMark_offset, 0.520000, 1.000000);
	TextDrawColor			(HitMark_offset, -1);
	TextDrawSetProportional	(HitMark_offset, 1);
	TextDrawSetOutline		(HitMark_offset, 0);
	TextDrawSetShadow		(HitMark_offset, 0);


//====================================================================Race Count
	rc_RaceCountText		=TextDrawCreate(490.000000, 110.000000, "Race Starting In 30");
	TextDrawBackgroundColor	(rc_RaceCountText, 255);
	TextDrawFont			(rc_RaceCountText, 1);
	TextDrawLetterSize		(rc_RaceCountText, 0.400000, 1.399999);
	TextDrawColor			(rc_RaceCountText, -65281);
	TextDrawSetOutline		(rc_RaceCountText, 0);
	TextDrawSetProportional	(rc_RaceCountText, 1);
	TextDrawSetShadow		(rc_RaceCountText, 1);

}
LoadPlayerTextDraws(playerid)
{
	smo_LoadPlayerTextDraws(playerid);
	dby_LoadPlayerTextDraws(playerid);
	gun_LoadPlayerTextDraws(playerid);
/*
	HealthCount						=CreatePlayerTextDraw(playerid, 577.000000, 66.000000, "100hp");
	PlayerTextDrawAlignment			(playerid, HealthCount, 2);
	PlayerTextDrawBackgroundColor	(playerid, HealthCount, -1);
	PlayerTextDrawFont				(playerid, HealthCount, 1);
	PlayerTextDrawLetterSize		(playerid, HealthCount, 0.439999, 1.000000);
	PlayerTextDrawColor				(playerid, HealthCount, -16776961);
	PlayerTextDrawSetOutline		(playerid, HealthCount, 0);
	PlayerTextDrawSetProportional	(playerid, HealthCount, 1);
	PlayerTextDrawSetShadow			(playerid, HealthCount, 0);
	PlayerTextDrawUseBox			(playerid, HealthCount, 1);
	PlayerTextDrawBoxColor			(playerid, HealthCount, 255);
	PlayerTextDrawTextSize			(playerid, HealthCount, 655.000000, 60.000000);
*/


	// Speedo

	VehicleNameText					=CreatePlayerTextDraw(playerid, 621.000000, 415.000000, "Infernus");
	PlayerTextDrawAlignment			(playerid, VehicleNameText, 3);
	PlayerTextDrawBackgroundColor	(playerid, VehicleNameText, 255);
	PlayerTextDrawFont				(playerid, VehicleNameText, 2);
	PlayerTextDrawLetterSize		(playerid, VehicleNameText, 0.349999, 1.799998);
	PlayerTextDrawColor				(playerid, VehicleNameText, -1);
	PlayerTextDrawSetOutline		(playerid, VehicleNameText, 1);
	PlayerTextDrawSetProportional	(playerid, VehicleNameText, 1);

	VehicleSpeedText				=CreatePlayerTextDraw(playerid, 620.000000, 401.000000, "220km/h");
	PlayerTextDrawAlignment			(playerid, VehicleSpeedText, 3);
	PlayerTextDrawBackgroundColor	(playerid, VehicleSpeedText, 255);
	PlayerTextDrawFont				(playerid, VehicleSpeedText, 2);
	PlayerTextDrawLetterSize		(playerid, VehicleSpeedText, 0.250000, 1.599998);
	PlayerTextDrawColor				(playerid, VehicleSpeedText, -1);
	PlayerTextDrawSetOutline		(playerid, VehicleSpeedText, 1);
	PlayerTextDrawSetProportional	(playerid, VehicleSpeedText, 1);


	// Map

	mapMain							=CreatePlayerTextDraw(playerid, MAP_ORIGIN_X, MAP_ORIGIN_Y, "samaps:gtasamapbit1");
	PlayerTextDrawBackgroundColor	(playerid, mapMain, 255);
	PlayerTextDrawFont				(playerid, mapMain, 4);
	PlayerTextDrawLetterSize		(playerid, mapMain, 0.500000, 1.000000);
	PlayerTextDrawColor				(playerid, mapMain, -1);
	PlayerTextDrawSetOutline		(playerid, mapMain, 0);
	PlayerTextDrawSetProportional	(playerid, mapMain, 1);
	PlayerTextDrawSetShadow			(playerid, mapMain, 1);
	PlayerTextDrawUseBox			(playerid, mapMain, 1);
	PlayerTextDrawBoxColor			(playerid, mapMain, 255);
	PlayerTextDrawTextSize			(playerid, mapMain, MAP_SIZE_X, MAP_SIZE_Y);


	// Race

	TimerText						=CreatePlayerTextDraw(playerid, 20.0, 180.0, "00:00");
	PlayerTextDrawAlignment			(playerid, TimerText, 0);
	PlayerTextDrawFont				(playerid, TimerText, 3);
	PlayerTextDrawLetterSize		(playerid, TimerText, 0.5, 1.9);
	PlayerTextDrawColor				(playerid, TimerText, 0xffffffff);
	PlayerTextDrawSetProportional	(playerid, TimerText, 2);
	PlayerTextDrawSetShadow			(playerid, TimerText, 1);
	PlayerTextDrawSetOutline		(playerid, TimerText, 1);
	PlayerTextDrawUseBox			(playerid, TimerText, 1);
	PlayerTextDrawBoxColor			(playerid, TimerText, 0x505050AA);
	PlayerTextDrawTextSize			(playerid, TimerText, 120.0, 200.0);

	rc_DistCount					=CreatePlayerTextDraw(playerid, 20.0, 202.0, "Distance~n~1000m");
	PlayerTextDrawBackgroundColor	(playerid, rc_DistCount, 255);
	PlayerTextDrawFont				(playerid, rc_DistCount, 1);
	PlayerTextDrawLetterSize		(playerid, rc_DistCount, 0.400000, 1.4);
	PlayerTextDrawColor				(playerid, rc_DistCount, -1);
	PlayerTextDrawSetOutline		(playerid, rc_DistCount, 0);
	PlayerTextDrawSetProportional	(playerid, rc_DistCount, 1);
	PlayerTextDrawSetShadow			(playerid, rc_DistCount, 1);
	PlayerTextDrawUseBox			(playerid, rc_DistCount, 1);
	PlayerTextDrawBoxColor			(playerid, rc_DistCount, 100);
	PlayerTextDrawTextSize			(playerid, rc_DistCount, 80.0, 0.0);

	rc_CurPlace						=CreatePlayerTextDraw(playerid, 84.000000, 202.000000, "1");
	PlayerTextDrawBackgroundColor	(playerid, rc_CurPlace, 255);
	PlayerTextDrawFont				(playerid, rc_CurPlace, 1);
	PlayerTextDrawLetterSize		(playerid, rc_CurPlace, 0.700000, 2.800000);
	PlayerTextDrawColor				(playerid, rc_CurPlace, -1);
	PlayerTextDrawSetOutline		(playerid, rc_CurPlace, 0);
	PlayerTextDrawSetProportional	(playerid, rc_CurPlace, 1);
	PlayerTextDrawSetShadow			(playerid, rc_CurPlace, 1);
	PlayerTextDrawUseBox			(playerid, rc_CurPlace, 1);
	PlayerTextDrawBoxColor			(playerid, rc_CurPlace, 255);
	PlayerTextDrawTextSize			(playerid, rc_CurPlace, 120.000000, 0.000000);

	rc_LobbyInfo					=CreatePlayerTextDraw(playerid, 278.000000, 405.000000, "Race Info");
	PlayerTextDrawAlignment			(playerid, rc_LobbyInfo, 2);
	PlayerTextDrawBackgroundColor	(playerid, rc_LobbyInfo, 255);
	PlayerTextDrawFont				(playerid, rc_LobbyInfo, 1);
	PlayerTextDrawLetterSize		(playerid, rc_LobbyInfo, 0.400000, 2.000000);
	PlayerTextDrawColor				(playerid, rc_LobbyInfo, 16711935);
	PlayerTextDrawSetOutline		(playerid, rc_LobbyInfo, 0);
	PlayerTextDrawSetProportional	(playerid, rc_LobbyInfo, 1);
	PlayerTextDrawSetShadow			(playerid, rc_LobbyInfo, 1);
	PlayerTextDrawUseBox			(playerid, rc_LobbyInfo, 1);
	PlayerTextDrawBoxColor			(playerid, rc_LobbyInfo, 100);
	PlayerTextDrawTextSize			(playerid, rc_LobbyInfo, 16.000000, 80.000000);
	PlayerTextDrawSetSelectable     (playerid, rc_LobbyInfo, true);

	rc_LobbyCamera					=CreatePlayerTextDraw(playerid, 362.000000, 405.000000, "Finish Line");
	PlayerTextDrawAlignment			(playerid, rc_LobbyCamera, 2);
	PlayerTextDrawBackgroundColor	(playerid, rc_LobbyCamera, 255);
	PlayerTextDrawFont				(playerid, rc_LobbyCamera, 1);
	PlayerTextDrawLetterSize		(playerid, rc_LobbyCamera, 0.400000, 2.000000);
	PlayerTextDrawColor				(playerid, rc_LobbyCamera, 3323135);
	PlayerTextDrawSetOutline		(playerid, rc_LobbyCamera, 0);
	PlayerTextDrawSetProportional	(playerid, rc_LobbyCamera, 1);
	PlayerTextDrawSetShadow			(playerid, rc_LobbyCamera, 1);
	PlayerTextDrawUseBox			(playerid, rc_LobbyCamera, 1);
	PlayerTextDrawBoxColor			(playerid, rc_LobbyCamera, 100);
	PlayerTextDrawTextSize			(playerid, rc_LobbyCamera, 16.000000, 80.000000);
	PlayerTextDrawSetSelectable     (playerid, rc_LobbyCamera, true);

	AddHPText						=CreatePlayerTextDraw(playerid, 160.000000, 240.000000, "<+HP>");
	PlayerTextDrawColor				(playerid, AddHPText, RED);
	PlayerTextDrawBackgroundColor	(playerid, AddHPText, 255);
	PlayerTextDrawFont				(playerid, AddHPText, 1);
	PlayerTextDrawLetterSize		(playerid, AddHPText, 0.300000, 1.000000);
	PlayerTextDrawSetProportional	(playerid, AddHPText, 1);
	PlayerTextDrawSetShadow			(playerid, AddHPText, 0);
	PlayerTextDrawSetOutline		(playerid, AddHPText, 1);

	AddCashText						=CreatePlayerTextDraw(playerid, 160.000000, 250.000000, "<+$>");
	PlayerTextDrawColor				(playerid, AddCashText, GREEN);
	PlayerTextDrawBackgroundColor	(playerid, AddCashText, 255);
	PlayerTextDrawFont				(playerid, AddCashText, 1);
	PlayerTextDrawLetterSize		(playerid, AddCashText, 0.300000, 1.000000);
	PlayerTextDrawSetProportional	(playerid, AddCashText, 1);
	PlayerTextDrawSetShadow			(playerid, AddCashText, 0);
	PlayerTextDrawSetOutline		(playerid, AddCashText, 1);

	AddScoreText					=CreatePlayerTextDraw(playerid, 160.000000, 260.000000, "<+P>");
	PlayerTextDrawColor				(playerid, AddScoreText, YELLOW);
	PlayerTextDrawBackgroundColor	(playerid, AddScoreText, 255);
	PlayerTextDrawFont				(playerid, AddScoreText, 1);
	PlayerTextDrawLetterSize		(playerid, AddScoreText, 0.300000, 1.000000);
	PlayerTextDrawSetProportional	(playerid, AddScoreText, 1);
	PlayerTextDrawSetShadow			(playerid, AddScoreText, 0);
	PlayerTextDrawSetOutline		(playerid, AddScoreText, 1);

	// Deathmatch

	dm_EquipText 					=CreatePlayerTextDraw(playerid, 497.000000,120.000000,"Equipment");
	PlayerTextDrawFont				(playerid, dm_EquipText,1);
	PlayerTextDrawLetterSize		(playerid, dm_EquipText,0.499999,1.500000);
	PlayerTextDrawColor				(playerid, dm_EquipText,0xffffffff);

	XPtext							=CreatePlayerTextDraw(playerid, 160.000000, 230.000000, "<XP>");
	PlayerTextDrawBackgroundColor	(playerid, XPtext, 255);
	PlayerTextDrawFont				(playerid, XPtext, 1);
	PlayerTextDrawLetterSize		(playerid, XPtext, 0.300000, 1.000000);
	PlayerTextDrawSetProportional	(playerid, XPtext, 1);
	PlayerTextDrawSetShadow			(playerid, XPtext, 1);

	RankTextCurr					=CreatePlayerTextDraw(playerid, 217.000000, 414.000000, "10");
	PlayerTextDrawAlignment			(playerid, RankTextCurr, 3);
	PlayerTextDrawBackgroundColor	(playerid, RankTextCurr, 255);
	PlayerTextDrawFont				(playerid, RankTextCurr, 2);
	PlayerTextDrawLetterSize		(playerid, RankTextCurr, 0.319999, 1.500000);
	PlayerTextDrawColor				(playerid, RankTextCurr, -65281);
	PlayerTextDrawSetOutline		(playerid, RankTextCurr, 1);
	PlayerTextDrawSetProportional	(playerid, RankTextCurr, 1);

	RankTextNext					=CreatePlayerTextDraw(playerid, 574.000000, 414.000000, "11");
	PlayerTextDrawBackgroundColor	(playerid, RankTextNext, 255);
	PlayerTextDrawFont				(playerid, RankTextNext, 2);
	PlayerTextDrawLetterSize		(playerid, RankTextNext, 0.319999, 1.500000);
	PlayerTextDrawColor				(playerid, RankTextNext, -65281);
	PlayerTextDrawSetOutline		(playerid, RankTextNext, 1);
	PlayerTextDrawSetProportional	(playerid, RankTextNext, 1);

	XPbar 							= CreatePlayerProgressBar(playerid, 220.0, 420.0, 350.0, 4.0, 0xFFFF0066);
	TankHeatBar						= CreatePlayerProgressBar(playerid, 220.0, 380.0, 200.0, 20.0, RED, 30.0);
	BleedoutBar						= CreatePlayerProgressBar(playerid, 220.0, 350.0, 200.0, 30.0, RED, 30.0);
	ActionBar						= CreatePlayerProgressBar(playerid, 291.0, 345.0, 57.50, 5.19, GREY, 100.0);

	LoadPlayerGUI_AwardMsg(playerid);
	LoadPlayerGUI_KillMsg(playerid);
	LoadPlayerGUI_GraphicMenu(playerid);
	LoadPlayerGUI_SpectateButtons(playerid);
}
UnloadPlayerTextDraws(playerid)
{
	smo_UnloadPlayerTextDraws(playerid);
	dby_UnloadPlayerTextDraws(playerid);
	gun_UnloadPlayerTextDraws(playerid);

	PlayerTextDrawDestroy(playerid, MsgBox);
	PlayerTextDrawDestroy(playerid, VehicleNameText);
	PlayerTextDrawDestroy(playerid, VehicleSpeedText);
	PlayerTextDrawDestroy(playerid, mapMain);
    if(bPlayerGameSettings[playerid] & ViewingMap)PlayerTextDrawDestroy(playerid, mapText);
	PlayerTextDrawDestroy(playerid, TimerText);
	PlayerTextDrawDestroy(playerid, rc_DistCount);
	PlayerTextDrawDestroy(playerid, rc_CurPlace);
	PlayerTextDrawDestroy(playerid, dm_EquipText);
	PlayerTextDrawDestroy(playerid, XPtext);

	DestroyPlayerProgressBar(playerid, XPbar);
	DestroyPlayerProgressBar(playerid, TankHeatBar);
	DestroyPlayerProgressBar(playerid, BleedoutBar);
	DestroyPlayerProgressBar(playerid, ActionBar);

	UnloadPlayerGUI_AwardMsg(playerid);
	UnloadPlayerGUI_KillMsg(playerid);
	UnloadPlayerGUI_GraphicMenu(playerid);
	UnloadPlayerGUI_SpectateButtons(playerid);

}


LoadMenus()
{
	print("- Loading Menus...");

//====================================================================dm_TeamMenu
	dm_TeamMenu = CreateMenu("Select Team", 1, 32.0, 170.0, 150.0);
	AddMenuItem(dm_TeamMenu,0, "Raven");
	AddMenuItem(dm_TeamMenu,0, "Valor");

//====================================================================Lobby Menu
	dm_LobbyMenu = CreateMenu("~b~Get Ready", 1, 32.0, 170.0, 200.0);
	AddMenuItem(dm_LobbyMenu, 0, "Team");
	AddMenuItem(dm_LobbyMenu, 0, "Loadout");
	AddMenuItem(dm_LobbyMenu, 0, "Gear");
	AddMenuItem(dm_LobbyMenu, 0, "Spawn Point");
	AddMenuItem(dm_LobbyMenu, 0, "-");
	AddMenuItem(dm_LobbyMenu, 0, "Help");
	AddMenuItem(dm_LobbyMenu, 0, "Spectate");
	AddMenuItem(dm_LobbyMenu, 0, "-");
	AddMenuItem(dm_LobbyMenu, 0, "> Ready <");
	DisableMenuRow(dm_LobbyMenu, 4);
	DisableMenuRow(dm_LobbyMenu, 7);
}
LoadDeathmatches()
{
	print("- Loading Deathmatches...");
	new
		File:idxFile = fopen(DM_INDEX_FILE, io_read),
		idx,
		line[160];

	while(fread(idxFile, line))
	{
		if(sscanf(line, "p<|>s[20]bds[128]s[14]s[26]", dm_MapNames[idx], dm_MapModes[idx], dm_MapRegion[idx], dm_MapInfo_Bio[idx], dm_MapInfo_Size[idx], dm_MapInfo_Kit[idx]))print("Error: Deathmatch File Index");
		idx++;
	}
	fclose(idxFile);
	dm_TotalMaps = idx;


	for(new r;r<5;r++)
	{
	    idx=0;
		format(dm_RegionList, 60, "%s%s\n", dm_RegionList, dm_RegionNames[r]);
		for(new m;m<MAX_MAPS;m++)
		{
			if(dm_MapRegion[m]==r)
			{
				format(dm_RegionMaps[r], 200, "%s%s\n", dm_RegionMaps[r], dm_MapNames[m]);
				dm_RegionIndex[m]=idx;
				idx++;
			}
		}
		strcat(dm_RegionMaps[r], "Back");
	}
	strcat(dm_RegionList, "Close");

	LoadAwards();
}
LoadFreeDM()
{
	new
		File:file=fopen(FDM_INDEX_FILE, io_read),
		line[128],
		idx,
		len;

	while(fread(file, line))
	{
	    len = strlen(line);
		if(line[len-2] == '\r')line[len-2] = EOS;
		format(fdm_AreaNames[idx], FDM_MAX_AREA_NAME, line);
		idx++;
	}
	fdm_TotalAreas = idx;
	fclose(file);
}


public OnButtonPress(playerid, buttonid)
{
	print("OnButtonPress <Main Script>");
	return 1;
}

public OnPlayerActivateCheckpoint(playerid, checkpointid)
{
	script_Parkour_Checkpoint(playerid, checkpointid);
	return 1;
}


public OnDynamicObjectMoved(objectid)
{
	if(dgw_State != 0)script_dgw_OnObjectMoved(objectid);
	return 1;
}

IsPlayerInFreeRoam(playerid)
{
	if( bPlayerGameSettings		[playerid]	& InDM
	||	bPlayerGameSettings		[playerid]	& InRace
	||	bPlayerGameSettings		[playerid]	& InFreeDM
	||	gCurrentMinigame		[playerid]	!= MINIGAME_NONE
	||	!(bServerGlobalSettings				& FreeroamCommands)
	||	gCurrentChallenge					!= CHALLENGE_NONE
	||	GetPlayerVirtualWorld	(playerid)	!= FREEROAM_WORLD) return 0;

	return 1;
}
CMD:infreeroam(playerid, params[])
{
	DisplayFreeroamStatus(playerid);
	return 1;
}
DisplayFreeroamStatus(playerid)
{
	new str[512];
	format(str, 512, "Freeroam Criteria:\n\n\
		%d = InDM (bit flag - player)\n\
	    %d = InRace (bit flag - player)\n\
	    %d = CurrentMinigame != MINIGAME_NONE (integer - global)\n\
	    %d = FreeDM (bit flag - global)\n\
	    %d = FreeRoamCommands (bit flag - global)\n\
	    %d = CurrentChallenge != CHALLENGE_NONE (integer - global)\n\
	    %d = VirtualWorld != FREEROAM_WORLD (integer - player)\n",

		(bPlayerGameSettings		[playerid]	& InDM),
		(bPlayerGameSettings		[playerid]	& InRace),
		(gCurrentMinigame			[playerid]	!= MINIGAME_NONE),
		(bServerGlobalSettings					& FreeDM),
		(!(bServerGlobalSettings				& FreeroamCommands)),
		(gCurrentChallenge						!= CHALLENGE_NONE),
		(GetPlayerVirtualWorld		(playerid)	!= FREEROAM_WORLD) );

	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "IsPlayerInFreeRoam", str, "Close", "");
}



GetPlayersOnline()
{
	new p;
	PlayerLoop(i)p++;
	return p;
}
SetMapName(MapName[])
{
	new str[30];
	format(str,30,"mapname %s",MapName);
	SendRconCommand(str);
}


#define PreloadAnimLib(%1,%2) ApplyAnimation(%1,%2,"null",0.0,0,0,0,0,0)
PreloadPlayerAnims(playerid)
{
	PreloadAnimLib(playerid, "AIRPORT");
	PreloadAnimLib(playerid, "ATTRACTORS");
	PreloadAnimLib(playerid, "BAR");
	PreloadAnimLib(playerid, "BASEBALL");
	PreloadAnimLib(playerid, "BD_FIRE");
	PreloadAnimLib(playerid, "BEACH");
	PreloadAnimLib(playerid, "BENCHPRESS");
	PreloadAnimLib(playerid, "BF_INJECTION");
	PreloadAnimLib(playerid, "BIKED");
	PreloadAnimLib(playerid, "BIKEH");
	PreloadAnimLib(playerid, "BIKELEAP");
	PreloadAnimLib(playerid, "BIKES");
	PreloadAnimLib(playerid, "BIKEV");
	PreloadAnimLib(playerid, "BIKE_DBZ");
	PreloadAnimLib(playerid, "BMX");
	PreloadAnimLib(playerid, "BOMBER");
	PreloadAnimLib(playerid, "BOX");
	PreloadAnimLib(playerid, "BSKTBALL");
	PreloadAnimLib(playerid, "BUDDY");
	PreloadAnimLib(playerid, "BUS");
	PreloadAnimLib(playerid, "CAMERA");
	PreloadAnimLib(playerid, "CAR");
	PreloadAnimLib(playerid, "CARRY");
	PreloadAnimLib(playerid, "CAR_CHAT");
	PreloadAnimLib(playerid, "CASINO");
	PreloadAnimLib(playerid, "CHAINSAW");
	PreloadAnimLib(playerid, "CHOPPA");
	PreloadAnimLib(playerid, "CLOTHES");
	PreloadAnimLib(playerid, "COACH");
	PreloadAnimLib(playerid, "COLT45");
	PreloadAnimLib(playerid, "COP_AMBIENT");
	PreloadAnimLib(playerid, "COP_DVBYZ");
	PreloadAnimLib(playerid, "CRACK");
	PreloadAnimLib(playerid, "CRIB");
	PreloadAnimLib(playerid, "DAM_JUMP");
	PreloadAnimLib(playerid, "DANCING");
	PreloadAnimLib(playerid, "DEALER");
	PreloadAnimLib(playerid, "DILDO");
	PreloadAnimLib(playerid, "DODGE");
	PreloadAnimLib(playerid, "DOZER");
	PreloadAnimLib(playerid, "DRIVEBYS");
	PreloadAnimLib(playerid, "FAT");
	PreloadAnimLib(playerid, "FIGHT_B");
	PreloadAnimLib(playerid, "FIGHT_C");
	PreloadAnimLib(playerid, "FIGHT_D");
	PreloadAnimLib(playerid, "FIGHT_E");
	PreloadAnimLib(playerid, "FINALE");
	PreloadAnimLib(playerid, "FINALE2");
	PreloadAnimLib(playerid, "FLAME");
	PreloadAnimLib(playerid, "FLOWERS");
	PreloadAnimLib(playerid, "FOOD");
	PreloadAnimLib(playerid, "FREEWEIGHTS");
	PreloadAnimLib(playerid, "GANGS");
	PreloadAnimLib(playerid, "GHANDS");
	PreloadAnimLib(playerid, "GHETTO_DB");
	PreloadAnimLib(playerid, "GOGGLES");
	PreloadAnimLib(playerid, "GRAFFITI");
	PreloadAnimLib(playerid, "GRAVEYARD");
	PreloadAnimLib(playerid, "GRENADE");
	PreloadAnimLib(playerid, "GYMNASIUM");
	PreloadAnimLib(playerid, "HAIRCUTS");
	PreloadAnimLib(playerid, "HEIST9");
	PreloadAnimLib(playerid, "INT_HOUSE");
	PreloadAnimLib(playerid, "INT_OFFICE");
	PreloadAnimLib(playerid, "INT_SHOP");
	PreloadAnimLib(playerid, "JST_BUISNESS");
	PreloadAnimLib(playerid, "KART");
	PreloadAnimLib(playerid, "KISSING");
	PreloadAnimLib(playerid, "KNIFE");
	PreloadAnimLib(playerid, "LAPDAN1");
	PreloadAnimLib(playerid, "LAPDAN2");
	PreloadAnimLib(playerid, "LAPDAN3");
	PreloadAnimLib(playerid, "LOWRIDER");
	PreloadAnimLib(playerid, "MD_CHASE");
	PreloadAnimLib(playerid, "MD_END");
	PreloadAnimLib(playerid, "MEDIC");
	PreloadAnimLib(playerid, "MISC");
	PreloadAnimLib(playerid, "MTB");
	PreloadAnimLib(playerid, "MUSCULAR");
	PreloadAnimLib(playerid, "NEVADA");
	PreloadAnimLib(playerid, "ON_LOOKERS");
	PreloadAnimLib(playerid, "OTB");
	PreloadAnimLib(playerid, "PARACHUTE");
	PreloadAnimLib(playerid, "PARK");
	PreloadAnimLib(playerid, "PAULNMAC");
	PreloadAnimLib(playerid, "PED");
	PreloadAnimLib(playerid, "PLAYER_DVBYS");
	PreloadAnimLib(playerid, "PLAYIDLES");
	PreloadAnimLib(playerid, "POLICE");
	PreloadAnimLib(playerid, "POOL");
	PreloadAnimLib(playerid, "POOR");
	PreloadAnimLib(playerid, "PYTHON");
	PreloadAnimLib(playerid, "QUAD");
	PreloadAnimLib(playerid, "QUAD_DBZ");
	PreloadAnimLib(playerid, "RAPPING");
	PreloadAnimLib(playerid, "RIFLE");
	PreloadAnimLib(playerid, "RIOT");
	PreloadAnimLib(playerid, "ROB_BANK");
	PreloadAnimLib(playerid, "ROCKET");
	PreloadAnimLib(playerid, "RUSTLER");
	PreloadAnimLib(playerid, "RYDER");
	PreloadAnimLib(playerid, "SCRATCHING");
	PreloadAnimLib(playerid, "SHAMAL");
	PreloadAnimLib(playerid, "SHOP");
	PreloadAnimLib(playerid, "SHOTGUN");
	PreloadAnimLib(playerid, "SILENCED");
	PreloadAnimLib(playerid, "SKATE");
	PreloadAnimLib(playerid, "SMOKING");
	PreloadAnimLib(playerid, "SNIPER");
	PreloadAnimLib(playerid, "SPRAYCAN");
	PreloadAnimLib(playerid, "STRIP");
	PreloadAnimLib(playerid, "SUNBATHE");
	PreloadAnimLib(playerid, "SWAT");
	PreloadAnimLib(playerid, "SWEET");
	PreloadAnimLib(playerid, "SWIM");
	PreloadAnimLib(playerid, "SWORD");
	PreloadAnimLib(playerid, "TANK");
	PreloadAnimLib(playerid, "TATTOOS");
	PreloadAnimLib(playerid, "TEC");
	PreloadAnimLib(playerid, "TRAIN");
	PreloadAnimLib(playerid, "TRUCK");
	PreloadAnimLib(playerid, "UZI");
	PreloadAnimLib(playerid, "VAN");
	PreloadAnimLib(playerid, "VENDING");
	PreloadAnimLib(playerid, "VORTEX");
	PreloadAnimLib(playerid, "WAYFARER");
	PreloadAnimLib(playerid, "WEAPONS");
	PreloadAnimLib(playerid, "WUZI");
	PreloadAnimLib(playerid, "WOP");
	PreloadAnimLib(playerid, "GFUNK");
	PreloadAnimLib(playerid, "RUNNINGMAN");
}
SpawnCarForPlayer(playerid, model)
{
	if(pAdmin(playerid) < 3 && bServerGlobalSettings & WeaponLock)
	{
	    switch(model)
	    {
	        case 425, 432, 447, 520:
	        {
	            Msg(playerid, RED, " >  You can't spawn a vehicle with weapons right now.");
	            return 0;
	        }
	    }
	}

    new
		Float:x,
		Float:y,
		Float:z,
		Float:a,
		Float:vx,
		Float:vy,
		Float:vz,
		vw=GetPlayerVirtualWorld(playerid),
		in=GetPlayerInterior(playerid);

	if(IsPlayerInAnyVehicle(playerid))
	{
		new
			vehicleid = GetPlayerVehicleID(playerid);

	    GetVehiclePos(vehicleid, x, y, z);
	    GetVehicleZAngle(vehicleid, a);
		GetVehicleVelocity(vehicleid, vx, vy, vz);
		DestroyVehicle(vehicleid);

		if(gPlayerSpawnedVehicle[playerid] == vehicleid)
			gPlayerSpawnedVehicle[playerid] = -1;
	}
	else
	{
	    GetPlayerPos(playerid, x, y, z);
	    GetPlayerFacingAngle(playerid, a);
		GetPlayerVelocity(playerid, vx, vy, vz);
	}

	if(IsValidVehicle(gPlayerSpawnedVehicle[playerid]))
	{
		DestroyVehicle(gPlayerSpawnedVehicle[playerid]);
		gPlayerSpawnedVehicle[playerid] = INVALID_VEHICLE_ID;
	}

	gPlayerSpawnedVehicle[playerid]	= CreateVehicle(model, x, y, z, a, -1, -1, 1000);
	gPlayerVehicleID[playerid]		= gPlayerSpawnedVehicle[playerid];
	SetVehicleVirtualWorld			(gPlayerVehicleID[playerid], vw);
	LinkVehicleToInterior			(gPlayerVehicleID[playerid], in);
	PutPlayerInVehicle				(playerid, gPlayerVehicleID[playerid], 0);
	SetVehicleVelocity				(gPlayerVehicleID[playerid], vx, vy, vz);
	v_Engine						(gPlayerVehicleID[playerid], 1);

	PlayerTextDrawSetString(playerid, VehicleNameText, VehicleNames[model-400]);
	PlayerTextDrawShow(playerid, VehicleNameText);
	MsgF(playerid, YELLOW, " >  "#C_BLUE"%s "#C_YELLOW"Spawned", VehicleNames[model-400]);
	
	return 1;
}

FreezePlayer(playerid, time)
{
	TogglePlayerControllable(playerid, false);
	defer UnfreezePlayer(playerid, time);
}
timer UnfreezePlayer[time](playerid, time)
{
#pragma unused time
	TogglePlayerControllable(playerid, true);
}

forward sffa_msgbox(playerid, message[], time, width);
public sffa_msgbox(playerid, message[], time, width)
{
	ShowMsgBox(playerid, message, time, width);
}

