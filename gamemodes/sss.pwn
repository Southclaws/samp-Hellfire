/*==============================================================================


	Southclaw's Scavenge and Survive

		Big thanks to Onfire559/Adam for the initial concept long ago.
		Recently influenced by Minecraft and DayZ, credits to the creators of
		those games and their fundamental mechanics and concepts.


==============================================================================*/


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
#define MAX_PLAYER_FILE				(MAX_PLAYER_NAME+16)
#define MAX_ADMIN					(16)
#define MAX_PASSWORD_LEN			(129)


// Files
#define PLAYER_DATA_FILE			"SSS/Player/%s.inv"
#define SPAWNS_DATA					"SSS/Spawns/%s.dat"
#define ACCOUNT_DATABASE			"SSS/Accounts.db"
#define SETTINGS_FILE				"SSS/Settings.txt"
#define ADMIN_DATA_FILE				"SSS/AdminList.txt"


// Database Rows
#define ROW_NAME					"name"
#define ROW_PASS					"pass"
#define ROW_SKIN					"skin"
#define ROW_IPV4					"ipv4"
#define ROW_ALIVE					"alive"
#define ROW_SPAWN					"spawn"

#define ROW_DATE					"date"
#define ROW_REAS					"reason"
#define ROW_BNBY					"by"


// Constants
#define SKIN_M_NORMAL				(60)
#define SKIN_M_HERO					(133)
#define SKIN_M_MECH					(33)
#define SKIN_M_BANDIT				(50)

#define SKIN_F_NORMAL				(192)
#define SKIN_F_HERO					(191)
#define SKIN_F_MECH					(298)
#define SKIN_F_BANDIT				(131)

#define CHANNEL_GLOBAL				(-1)
#define CHANNEL_TEAM				(50)
#define CHANNEL_VEHICLE				(51)

#define RUN_VELOCITY				(20)
#define CROUCH_VELOCITY				(20)

#define MAX_RUN_ALPHA				(255)
#define MIN_RUN_ALPHA				(100)
#define MAX_CROUCH_ALPHA			(35)
#define MIN_CROUCH_ALPHA			(0)


// Functions
#define PlayerLoop(%0)				foreach(new %0 : Player)

#define t:%1<%2>					((%1)|=(%2))								// I had this idea at a later date!
#define f:%1<%2>					((%1)&=~(%2))								// So there's a mix of both these methods just to add confusion! Don't worry, they do the same thing, just quicker to write.

#define SetSpawn(%0,%1,%2,%3,%4)	SetSpawnInfo(%0, NO_TEAM, 0, %1, %2, %3, %4, 0,0,0,0,0,0)
#define GetFile(%0,%1)				format(%1, MAX_PLAYER_FILE, PLAYER_DATA_FILE, %0)
#define RandomBounds(%1,%2)			(random((%2)-(%1))+(%1))
#define RandomCondition(%1)			(random(100)<(%1))
#define pAdmin(%1)					gPlayerData[%1][ply_Admin]

#define KEY_RELEASED(%0)			(((newkeys&(%0))!=(%0))&&((oldkeys&(%0))==(%0)))
#define KEY_PRESSING(%0)			(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#define KEY_HOLDING(%0)				((newkeys & (%0)) == (%0))
#define KEY_AIMFIRE					(132)

#define CMD:%1(%2)					forward cmd_%1(%2);\
									public cmd_%1(%2)							// I wrote my own command processor to fit my needs!

#define ACMD:%1[%2](%3)				forward cmd_%1_%2(%3);\
									public cmd_%1_%2(%3)						// Admin only commands, the [parameter] in the brackets is the admin level.

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
	d_NULL,

	d_Login,
	d_Register,
    d_WelcomeMsg,
	d_LogMsg,

	d_Stats,

	d_Inventory,
	d_InventoryOptions,
	d_InventoryCombine,
	d_ContainerInventory,
	d_ContainerOptions,
	d_ContainerPlayerInv,
	d_ContainerPlayerInvOptions,
	d_SignEdit,

	d_NotebookPage,
	d_NotebookEdit,
	d_NotebookError
}


new
	HORIZONTAL_RULE[] = {"-------------------------------------------------------------------------------------------------------------------------"},
	RandomCountries[5][16] =
	{
		"Narnia",
		"Mordor",
		"Liberty City",
		"Vice City",
		"Alderaan"
	};


//=====================Player Tag Names
new const AdminName[4][14]=
{
	"Player",			// 0
	"Moderator",		// 1
	"Administrator",	// 2
	"Developer"			// 3
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
	ServerTimeFlow
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
	gTotalAdmins;

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
				gLastWeatherChange;

//=====================Menus and Textdraws
new
Text:			DeathText			= INVALID_TEXT_DRAW,
Text:			DeathButton			= INVALID_TEXT_DRAW,
Text:			ClockText			= INVALID_TEXT_DRAW,
Text:			MapCover1			= INVALID_TEXT_DRAW,
Text:			MapCover2			= INVALID_TEXT_DRAW,
Text:			HitMark_centre		= INVALID_TEXT_DRAW,
Text:			HitMark_offset		= INVALID_TEXT_DRAW,

PlayerText:		ClassBackGround		= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		ClassButtonMale		= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		ClassButtonFemale	= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		HelpTipText			= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		VehicleNameText		= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		VehicleSpeedText	= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		AddHPText			= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		AddScoreText		= PlayerText:INVALID_TEXT_DRAW,

PlayerBar:		TankHeatBar			= INVALID_PLAYER_BAR_ID,
PlayerBar:		ActionBar			= INVALID_PLAYER_BAR_ID,
				MiniMapOverlay;

//==============================================================PLAYER VARIABLES


enum (<<= 1) // 14
{
		HasAccount = 1,
		LoggedIn,
		Gender,
		Alive,
		Dying,
		Spawned,
		FirstSpawn,
		HelpTips,

		RegenHP,
		RegenAP,
		Frozen,
		Muted,

		AfkCheck,
		IsAfk,
		DebugMode,
}
enum E_PLAYER_DATA
{
		ply_Password[MAX_PASSWORD_LEN],
		ply_Admin,
		ply_Skin,
		ply_IP,
Float:	ply_posX,
Float:	ply_posY,
Float:	ply_posZ,
Float:	ply_rotZ
}


new
DB:		gAccounts,
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
Float:	gCurrentVelocity		[MAX_PLAYERS],

		gClassBoxFadeLevel		[MAX_PLAYERS],
Timer:	gClassFadeTimer			[MAX_PLAYERS],
Float:	gPlayerDeathPos			[MAX_PLAYERS][4],
		gPlayerChatChannel		[MAX_PLAYERS],
		Blocked					[MAX_PLAYERS][MAX_PLAYERS],
		Hidden					[MAX_PLAYERS][MAX_PLAYERS],

		tick_WeaponHit			[MAX_PLAYERS],
		tick_LastDeath			[MAX_PLAYERS],
		tick_LastDamg			[MAX_PLAYERS],
		tick_StartRegenHP		[MAX_PLAYERS],
		tick_StartRegenAP		[MAX_PLAYERS],
		tick_ExitVehicle		[MAX_PLAYERS],
		tick_LastChatMessage	[MAX_PLAYERS],
		ChatMessageStreak		[MAX_PLAYERS],
		ChatMuteTick			[MAX_PLAYERS],

Text3D:	gPlayerAfkLabel			[MAX_PLAYERS],
Float:	TankHeat				[MAX_PLAYERS],
Timer:	TankHeatUpdateTimer		[MAX_PLAYERS];


forward OnLoad();
forward OnDeath(playerid, killerid, reason);


//======================Library Predefinitions

#define NOTEBOOK_FILE "SSS/Notebook/%s.dat"
#define MAX_FILE_NAME (MAX_PLAYER_NAME + 18)

//======================Libraries of Resources

#include "../scripts/Resources/VehicleResources.pwn"
#include "../scripts/Resources/PlayerResources.pwn"
#include "../scripts/Resources/WeaponResources.pwn"
#include "../scripts/Resources/EnvironmentResources.pwn"
#include "../scripts/Resources/Specifiers.pwn"
#include "../scripts/Handcuffs.pwn"

//======================Libraries of Functions

#include "../scripts/System/Hooks.pwn"
#include "../scripts/System/Functions.pwn"
#include "../scripts/System/MathFunctions.pwn"
#include "../scripts/System/PlayerFunctions.pwn"
#include "../scripts/System/VehicleFunctions.pwn"
#include "../scripts/System/Trajectory.pwn"
#include "../scripts/System/MessageBox.pwn"

//======================API Scripts

#include "../scripts/SIF/Core.pwn"
#include "../scripts/SIF/Button.pwn"
#include "../scripts/SIF/Door.pwn"
#include "../scripts/SIF/Item.pwn"
#include "../scripts/SIF/Inventory.pwn"
#include "../scripts/SIF/Container.pwn"

#include "../scripts/SIF/Modules/WeaponItems.pwn"
#include "../scripts/SIF/Modules/NewMelee.pwn"
#include "../scripts/SIF/Modules/Craft.pwn"
#include "../scripts/SIF/Modules/Notebook.pwn"


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
#include "../scripts/Items/repair.pwn"
#include "../scripts/Items/shield.pwn"
#include "../scripts/Items/handcuffs.pwn"
#include "../scripts/Items/capmine.pwn"

//======================Gameplay Features

#include "../scripts/SSS/Spawns.pwn"
#include "../scripts/SSS/LootData.pwn"
#include "../scripts/SSS/LootSpawn.pwn"
#include "../scripts/SSS/HouseLoot.pwn"
#include "../scripts/SSS/VehicleData.pwn"
#include "../scripts/SSS/VehicleSpawn.pwn"
#include "../scripts/SSS/Inventory.pwn"
#include "../scripts/SSS/Tutorial.pwn"

#include "../scripts/SSS/Lvl_1.pwn"
#include "../scripts/SSS/Lvl_2.pwn"
#include "../scripts/SSS/Lvl_3.pwn"
#include "../scripts/SSS/Admin.pwn"

//======================Map Scripts

#include "../scripts/SSS/Maps/Gen_LS.pwn"
#include "../scripts/SSS/Maps/Gen_SF.pwn"
#include "../scripts/SSS/Maps/Gen_LV.pwn"
#include "../scripts/SSS/Maps/Gen_Red.pwn"
#include "../scripts/SSS/Maps/Gen_Flint.pwn"
#include "../scripts/SSS/Maps/Gen_Des.pwn"
#include "../scripts/Maps/Area69.pwn"
#include "../scripts/Maps/Ranch.pwn"
#include "../scripts/Maps/MtChill.pwn"




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

	db_free_result(db_query(gAccounts, "CREATE TABLE IF NOT EXISTS `Player` (`"#ROW_NAME"`, `"#ROW_PASS"`, `"#ROW_SKIN"`, `"#ROW_IPV4"`, `"#ROW_ALIVE"`, `"#ROW_SPAWN"`)"));
	db_free_result(db_query(gAccounts, "CREATE TABLE IF NOT EXISTS `Bans` (`"#ROW_NAME"`, `"#ROW_IPV4"`, `"#ROW_DATE"`, `"#ROW_REAS"`, `"#ROW_BNBY"`)"));

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
	print(" Southclaw's Scavenge And Survive");
	print("  ----  Server Data  ----");
	printf("   %d\t- Visitors",			file_GetVal("Connections"));
	printf("   %d\t- Accounts",			rowCount);
	printf("   %d\t- Administrators",	gTotalAdmins);
	print("-------------------------------------\n");

	file_Close();
}





























public OnGameModeInit()
{
	print("Starting Main Game Script 'SSS' ...");

	file_OS();
	SetGameModeText("Scavenge And Survive 0.1a");
	SetMapName("San Androcalypse");

	EnableStuntBonusForAll(false);
    ManualVehicleEngineAndLights();
	SetNameTagDrawDistance(1.0);
	UsePlayerPedAnims();
	AllowInteriorWeapons(true);
	DisableInteriorEnterExits();
	ShowNameTags(true);

	t:bServerGlobalSettings<ServerTimeFlow>;
	t:bServerGlobalSettings<Realtime>;

	gTimeMinute			= random(60);
	gTimeHour			= random(24);
	gWeatherID			= WeatherData[random(sizeof(WeatherData))][weather_id];
	gLastWeatherChange	= tickcount();

	MiniMapOverlay = GangZoneCreate(-6000, -6000, 6000, 6000);

	if(!fexist(SETTINGS_FILE))
		file_Create(SETTINGS_FILE);

	else
	{
	    file_Open(SETTINGS_FILE);
		file_GetStr("motd", gMessageOfTheDay);
	    file_Close();
	}

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
	item_Beer			= DefineItemType("Beer",			1543,	ITEM_SIZE_SMALL, 0.0, 0.0, 0.0, 0.063184, 0.132318, 0.249579, 338.786285, 175.964538, 0.000000);
	item_Sign			= DefineItemType("Sign",			19471,	ITEM_SIZE_LARGE, 0.0, 0.0, 270.0);
	item_HealthRegen	= DefineItemType("Adrenaline",		1575,	ITEM_SIZE_SMALL, 0.0, 0.0, 0.0, 0.262021, 0.014938, 0.000000, 279.040191, 352.944946, 358.980987);
	item_ArmourRegen	= DefineItemType("ElectroArmour",	19515,	ITEM_SIZE_SMALL, 0.0, 0.0, 0.0, 0.300333, -0.090105, 0.000000, 0.000000, 0.000000, 180.000000);
	item_FishRod		= DefineItemType("Fishing Rod",		18632,	ITEM_SIZE_LARGE, 0.0, 0.0, 0.0, 0.091496, 0.019614, 0.000000, 185.619995, 354.958374, 0.000000);
	item_Wrench			= DefineItemType("Wrench",			18633,	ITEM_SIZE_SMALL, 0.0, 0.0, 0.0, 0.084695, -0.009181, 0.152275, 98.865089, 270.085449, 0.000000);
	item_Crowbar		= DefineItemType("Crowbar",			18634,	ITEM_SIZE_SMALL, 0.0, 0.0, 0.0, 0.066177, 0.011153, 0.038410, 97.289527, 270.962554, 1.114514);
	item_Hammer			= DefineItemType("Hammer",			18635,	ITEM_SIZE_SMALL, 0.0, 0.0, 0.0, 0.000000, -0.008230, 0.000000, 6.428617, 0.000000, 0.000000);
	item_Shield			= DefineItemType("Shield",			18637,	ITEM_SIZE_LARGE, 0.0, 0.0, 0.0, -0.262389, 0.016478, -0.151046, 103.597534, 6.474381, 38.321765);
	item_Flashlight		= DefineItemType("Flashlight",		18641,	ITEM_SIZE_SMALL, 0.0, 0.0, 0.0, 0.061910, 0.022700, 0.039052, 190.938354, 0.000000, 0.000000);
	item_Taser			= DefineItemType("Taser",			18642,	ITEM_SIZE_SMALL, 0.0, 0.0, 0.0, 0.079878, 0.014009, 0.029525, 180.000000, 0.000000, 0.000000);
	item_LaserPoint		= DefineItemType("Laser Pointer",	18643,	ITEM_SIZE_SMALL, 0.0, 0.0, 0.0, 0.066244, 0.010838, -0.000024, 6.443027, 287.441467, 0.000000);
	item_Screwdriver	= DefineItemType("Screwdriver",		18644,	ITEM_SIZE_SMALL, 0.0, 0.0, 0.0, 0.099341, 0.021018, 0.009145, 193.644195, 0.000000, 0.000000);
	item_MobilePhone	= DefineItemType("Mobile Phone",	18865,	ITEM_SIZE_SMALL, 0.0, 0.0, 0.0, 0.103904, -0.003697, -0.015173, 94.655189, 184.031860, 0.000000);
	item_Pager			= DefineItemType("Pager",			18875,	ITEM_SIZE_SMALL, 0.0, 0.0, 0.0, 0.097277, 0.027625, 0.013023, 90.819244, 191.427993, 0.000000);
	item_Rake			= DefineItemType("Rake",			18890,	ITEM_SIZE_SMALL, 0.0, 0.0, 0.0, -0.002599, 0.003984, 0.026356, 190.231231, 0.222518, 271.565185);
	item_HotDog			= DefineItemType("Hotdog",			19346,	ITEM_SIZE_SMALL, 0.0, 0.0, 0.0, 0.088718, 0.035828, 0.008570, 272.851745, 354.704772, 9.342185);
	item_EasterEgg		= DefineItemType("Easter Egg",		19345,	ITEM_SIZE_SMALL, 0.0, 0.0, 0.0, 0.000000, 0.000000, 0.000000, 0.000000, 90.000000, 0.000000);
	item_Cane			= DefineItemType("Cane",			19348,	ITEM_SIZE_MEDIUM, 0.0, 0.0, 0.0, 0.041865, 0.022883, -0.079726, 4.967216, 10.411237, 0.000000);
	item_HandCuffs		= DefineItemType("Handcuffs",		19418,	ITEM_SIZE_SMALL, 0.0, 0.0, 0.0, 0.077635, 0.011612, 0.000000, 0.000000, 90.000000, 0.000000);
	item_Bucket			= DefineItemType("Bucket",			19468,	ITEM_SIZE_MEDIUM, 0.0, 0.0, 0.0, 0.293691, -0.074108, 0.020810, 148.961685, 280.067260, 151.782791);
	item_GasMask		= DefineItemType("Gas Mask",		19472,	ITEM_SIZE_SMALL, 0.0, 0.0, 0.0, 0.062216, 0.055396, 0.001138, 90.000000, 0.000000, 180.000000);
	item_Flag			= DefineItemType("Flag",			2993,	ITEM_SIZE_SMALL, 0.0, 0.0, 0.0, 0.045789, 0.026306, -0.078802, 8.777217, 0.272155, 0.000000);
	item_Briefcase		= DefineItemType("Briefcase",		1210,	ITEM_SIZE_MEDIUM, 0.0, 0.0, 90.0, 0.285915, 0.078406, -0.009429, 0.000000, 270.000000, 0.000000);
	item_Backpack		= DefineItemType("Backpack",		3026,	ITEM_SIZE_MEDIUM, 0.0, 270.0, 0.0, 0.470918, 0.150153, 0.055384, 181.319580, 7.513789, 163.436065);
	item_Satchel		= DefineItemType("Patrol Pack",		363,	ITEM_SIZE_MEDIUM, 0.0, 0.0, 0.0, 0.052853, 0.034967, -0.177413, 0.000000, 261.397491, 349.759826);
	item_Wheel			= DefineItemType("Wheel",			1025,	ITEM_SIZE_MEDIUM, 0.0, 270.0, 0.0, 0.340184, -0.096594, 0.054843, 0.000000, 359.105285, 90.000000);
	item_Canister1		= DefineItemType("Canister",		1008,	ITEM_SIZE_MEDIUM, 0.0, 0.0, 0.0, 0.303921, 0.033764, -0.105052, 0.000000, 0.000000, 0.000000);
	item_Canister2		= DefineItemType("Canister",		1009,	ITEM_SIZE_MEDIUM, 0.0, 0.0, 0.0, 0.314470, 0.022019, -0.013475, 0.000000, 0.000000, 0.000000);
	item_Canister3		= DefineItemType("Canister",		1010,	ITEM_SIZE_MEDIUM, 0.0, 0.0, 0.0, 0.301039, 0.077488, 0.022019, 90.000000, 0.000000, 0.000000);
	item_MotionSense	= DefineItemType("Motion Sensor",	327,	ITEM_SIZE_SMALL, 0.0, 0.0, 0.0, 0.008151, 0.012682, -0.050635, 0.000000, 0.000000, 0.000000);
	item_CapCase		= DefineItemType("Cap Case",		1213,	ITEM_SIZE_SMALL, 0.0, 0.0, 0.0, 0.191558, 0.000000, 0.040402, 90.000000, 0.000000, 0.000000);
	item_CapMineBad		= DefineItemType("Bad Cap Mine",	1576,	ITEM_SIZE_SMALL, 0.0, 0.0, 0.0, 0.191558, 0.000000, 0.040402, 90.000000, 0.000000, 0.000000);
	item_CapMine		= DefineItemType("Cap Mine",		1213,	ITEM_SIZE_SMALL, 0.0, 0.0, 0.0, 0.262021, 0.014938, 0.000000, 279.040191, 352.944946, 358.980987);

	DefineItemDamage(item_Beer,			23.0,	"SWORD", 		"sword_1");
	DefineItemDamage(item_Sign,			23.0,	"SWORD", 		"sword_1");
	DefineItemDamage(item_FishRod,		23.0,	"SWORD", 		"sword_1");
	DefineItemDamage(item_Shield,		23.0,	"SWORD", 		"sword_1");
	DefineItemDamage(item_Wrench,		23.0,	"SWORD", 		"sword_1");
	DefineItemDamage(item_Crowbar,		23.0,	"SWORD", 		"sword_1");
	DefineItemDamage(item_Hammer,		23.0,	"SWORD", 		"sword_1");
	DefineItemDamage(item_Screwdriver,	23.0,	"SWORD", 		"sword_1");
	DefineItemDamage(item_Cane,			23.0,	"SWORD", 		"sword_1");
	DefineItemDamage(item_Rake,			23.0,	"SWORD", 		"sword_1");
	DefineItemDamage(item_Canister1,	23.0,	"SWORD", 		"sword_1");
	DefineItemDamage(item_Canister2,	23.0,	"SWORD", 		"sword_1");
	DefineItemDamage(item_Canister3,	23.0,	"SWORD", 		"sword_1");


	DefineItemCombo(item_timer, item_explosive, item_timebomb);
	DefineItemCombo(item_explosive, item_MotionSense, item_CapMineBad);
	DefineItemCombo(item_CapMineBad, item_CapCase, item_CapMine);

	CallLocalFunction("OnLoad", "");

	LoadVehicles();
	LoadTextDraws();

	for(new i; i < MAX_PLAYERS; i++)
	{
		ResetVariables(i);
	}

	defer SpawnVehicles();

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

timer SpawnVehicles[1000]()
{
	for(new i; i < MAX_VEHICLES; i++)
		SetVehicleToRespawn(i);
}

task GameUpdate[1000]()
{
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

		if(bServerGlobalSettings & Realtime)
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
			if(GetPlayerVirtualWorld(i) == 0)
			{
			    MsgF(i, YELLOW, " >  Weather report: "#C_BLUE"%s", WeatherData[id][weather_name]);
				SetPlayerWeather(i, WeatherData[gWeatherID][weather_id]);
			}
		}
	}
}

ptask PlayerUpdate[100](playerid)
{
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
		
		if(300.0 < health < 500.0)
		{
			if(v_Engine(vehicleid) && gPlayerVelocity[playerid] > 30.0)
			{
				if(random(100) < (50 - ((health - 400.0) / 4)))
				{
					if(health < 400.0)
						v_Engine(vehicleid, 0);
	
					SetVehicleHealth(vehicleid, health - (((200 - (health - 300.0)) / 100.0) / 2.0));
				}
			}
			else
			{
				if(random(100) < 100 - (50 - ((health - 400.0) / 4)))
				{
					if(health < 400.0)
						v_Engine(vehicleid, 1);
				}
			}
		}
		if(v_Engine(vehicleid))
		{
			if(health < 300.0 || gVehicleFuel[vehicleid] <= 0.0)
				v_Engine(vehicleid, 0);

			if(gVehicleFuel[vehicleid] > 0.0)
			{
				gVehicleFuel[vehicleid] -= (VehicleFuelData[GetVehicleModel(vehicleid) - 400][veh_fuelCons] / 100) * (((gPlayerVelocity[playerid]/60)/60)/10);
			}

			if(tickcount() - tick_ExitVehicle[playerid] > 3000 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
				SetPlayerArmedWeapon(playerid, 0);
		}
		new str[150];
		format(str, 150,
			"Fuel:~n~%.2fL/%.2fL~n~\
			v hp: %f~n~-hp/s: %f~n~\
			eng off ch: %f~n~eng on ch: %f~n~~n~\
			Velocity change: %f",
			gVehicleFuel[vehicleid], VehicleFuelData[GetVehicleModel(vehicleid) - 400][veh_maxFuel],
			health, ((200 - (health - 300.0)) / 100.0),
			(50 - ((health - 400.0) / 4)),
			100 - (50 - ((health - 400.0) / 4)),
			floatabs(gCurrentVelocity[playerid] - gPlayerVelocity[playerid]));

		ShowMsgBox(playerid, str, 0, 150);

		if(floatabs(gCurrentVelocity[playerid] - gPlayerVelocity[playerid]) > 20.0)
		{
			GivePlayerHP(playerid, -(floatabs(gCurrentVelocity[playerid] - gPlayerVelocity[playerid]) * 0.3));
		}

		gCurrentVelocity[playerid] = gPlayerVelocity[playerid];
	}

	UpdateIcons(playerid);
	SetPlayerTime(playerid, gTimeHour, gTimeMinute);

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
	new colour[1 char];

	colour[0] = ColourData[gPlayerColour[playerid]][colour_value];

	colour{3} = 0;

	PlayerLoop(i)
	{
		ShowPlayerNameTagForPlayer(i, playerid, false);
		SetPlayerMarkerForPlayer(i, playerid, colour[0]);
	}

	return 1;
}

OnPlayerPauseStateChange(playerid, newstate)
{
	if(newstate)
	{
		t:bPlayerGameSettings[playerid]<IsAfk>;
		gPlayerAfkLabel[playerid] = Create3DTextLabel("Player Is Away", YELLOW, 0.0, 0.0, 0.0, 100.0, GetPlayerVirtualWorld(playerid), 1);
		Attach3DTextLabelToPlayer(gPlayerAfkLabel[playerid], playerid, 0.0, 0.0, 0.5);
	    return 1;
	}
	else
	{
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
			if(tmpadminlvl > 3) tmpadminlvl = 3;
			jointype = 1;
			break;
		}
	}

	format(tmpQuery, sizeof(tmpQuery), "SELECT * FROM `Player` WHERE `"#ROW_NAME"` = '%s'", gPlayerName[playerid]);
	tmpResult = db_query(gAccounts, tmpQuery);

	ResetVariables(playerid);

	if(gPlayerData[playerid][ply_IP] == 2130706433)
		tmpCountry = "Localhost";

	else
		GetCountryName(tmpIP, tmpCountry);
	
	if(isnull(tmpCountry))format(tmpCountry, sizeof(tmpCountry), "Unknown (%s maybe?)", RandomCountries[random(sizeof(RandomCountries))]);

	TextDrawShowForPlayer(playerid, ClockText);

	Msg(playerid, BLUE, HORIZONTAL_RULE);
	Msg(playerid, YELLOW, " >  Hello and welcome to the Hellfire Server! "#C_BLUE"A Server For Everyone!");
	Msg(playerid, YELLOW, " >  Don't forget to read the "#C_RED"'/Rules' "#C_YELLOW"Have Fun :D");
	MsgF(playerid, YELLOW, " >  MOTD: "#C_BLUE"%s", gMessageOfTheDay);
	Msg(playerid, BLUE, HORIZONTAL_RULE);

	if(db_num_rows(tmpResult) >= 1)
	{
	    new
			tmpField[50],
			dbIP;

		db_get_field_assoc(tmpResult, #ROW_PASS, gPlayerData[playerid][ply_Password], MAX_PASSWORD_LEN);

		db_get_field_assoc(tmpResult, #ROW_SKIN, tmpField, 4);
		gPlayerData[playerid][ply_Skin] = strval(tmpField);

		db_get_field_assoc(tmpResult, #ROW_IPV4, tmpField, 12);
		dbIP = strval(tmpField);

		db_get_field_assoc(tmpResult, #ROW_ALIVE, tmpField, 2);
		if(tmpField[0] == '1')
			t:bPlayerGameSettings[playerid]<Alive>;
		else
			f:bPlayerGameSettings[playerid]<Alive>;

		db_get_field_assoc(tmpResult, #ROW_SPAWN, tmpField, 50);
		sscanf(tmpField, "ffff",
			gPlayerData[playerid][ply_posX],
			gPlayerData[playerid][ply_posY],
			gPlayerData[playerid][ply_posZ],
			gPlayerData[playerid][ply_rotZ]);

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


	SetAllWeaponSkills(playerid, 500);
    LoadPlayerTextDraws(playerid);
	SetPlayerScore(playerid, 0);
	Streamer_ToggleIdleUpdate(playerid, true);


	db_free_result(tmpResult);

	file_Open(SETTINGS_FILE);
	file_IncVal("Connections", 1);
	file_Save(SETTINGS_FILE);
	file_Close();

	t:bPlayerGameSettings[playerid]<HelpTips>;
	SetSpawn(playerid, -907.5452, 272.7235, 1014.1449, 0.0);
	SpawnPlayer(playerid);

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
	t:bPlayerGameSettings[playerid]<FirstSpawn>;

	SetSpawn(playerid, -907.5452, 272.7235, 1014.1449, 0.0);

	return 0;
}
public OnPlayerRequestSpawn(playerid)
{
	t:bPlayerGameSettings[playerid]<FirstSpawn>;

	SetSpawn(playerid, -907.5452, 272.7235, 1014.1449, 0.0);

	return 1;
}


CreateNewUserfile(playerid, password[])
{
	new
		file[MAX_PLAYER_FILE],
		tmpQuery[300];

	GetFile(gPlayerName[playerid], file);

	gPlayerData[playerid][ply_Skin] = SKIN_M_NORMAL;

	fclose(fopen(file, io_write));

	format(tmpQuery, 300,
		"INSERT INTO `Player` (`"#ROW_NAME"`, `"#ROW_PASS"`, `"#ROW_SKIN"`, `"#ROW_IPV4"`, `"#ROW_ALIVE"`, `"#ROW_SPAWN"`) \
		VALUES('%s', '%s', '%d', '%d', '0', '0.0, 0.0, 0.0, 0.0')",
		gPlayerName[playerid], password, gPlayerData[playerid][ply_Skin], gPlayerData[playerid][ply_IP]);

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

	t:bPlayerGameSettings[playerid]<LoggedIn>;
    t:bPlayerGameSettings[playerid]<HasAccount>;
}
Login(playerid)
{
	new
		tmpQuery[256];

	format(tmpQuery, sizeof(tmpQuery), "UPDATE `Player` SET `"#ROW_IPV4"` = '%d' WHERE `"#ROW_NAME"` = '%s'", gPlayerData[playerid][ply_IP], gPlayerName[playerid]);
	db_free_result(db_query(gAccounts, tmpQuery));

	for(new idx; idx<gTotalAdmins; idx++)
	{

		if(!strcmp(gPlayerName[playerid], gAdminData[idx][admin_Name]))
		{
			pAdmin(playerid) = gAdminData[idx][admin_Level];
			break;
		}
	}

	if(pAdmin(playerid)>0)MsgF(playerid, BLUE, " >  Your admin level: %d", pAdmin(playerid));

	t:bPlayerGameSettings[playerid]<LoggedIn>;
	IncorrectPass[playerid]=0;

    LogMessage(playerid);
}

SavePlayerData(playerid)
{
	new
		tmpQuery[256];

	if(bPlayerGameSettings[playerid] & Alive)
	{
		new
			Float:x,
			Float:y,
			Float:z,
			Float:a;

		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, a);

		if(Distance(x, y, z, -907.5452, 272.7235, 1014.1449) < 50.0)
			return 0;

		format(tmpQuery, sizeof(tmpQuery),
			"UPDATE `Player` SET \
			`"#ROW_ALIVE"` = '1', \
			`"#ROW_SPAWN"` = '%f %f %f %f' \
			WHERE `"#ROW_NAME"` = '%s'",
			x, y, z, a,
			gPlayerName[playerid]);

		SavePlayerInventory(playerid);
	}
	else
	{
		format(tmpQuery, sizeof(tmpQuery),
			"UPDATE `Player` SET \
			`"#ROW_ALIVE"` = '0', \
			`"#ROW_SPAWN"` = '0.0 0.0 0.0 0.0' \
			WHERE `"#ROW_NAME"` = '%s'",
			gPlayerName[playerid]);

		ClearPlayerInventoryFile(playerid);
	}

	db_free_result(db_query(gAccounts, tmpQuery));

	return 1;
}

SavePlayerInventory(playerid)
{
	new
		filename[MAX_PLAYER_FILE],
		File:file,
		healtharmour[2],
		helditems[2],
		inventoryitems[8];

	GetFile(gPlayerName[playerid], filename);

	file = fopen(filename, io_write);

	healtharmour[0] = _:gPlayerHP[playerid];
	healtharmour[1] = _:gPlayerAP[playerid];

	printf("SAVE: Health: %f Armour: %f", healtharmour[0], healtharmour[1]);

	fblockwrite(file, healtharmour, 2);

	if(GetPlayerHolsteredWeapon(playerid) != 0)
	{
		helditems[0] = GetPlayerHolsteredWeapon(playerid);
		helditems[1] = GetPlayerHolsteredWeaponAmmo(playerid);
		fblockwrite(file, helditems, 2);
	}
	else
	{
		helditems[0] = 0;
		helditems[1] = 0;
		fblockwrite(file, helditems, 2);
	}

	if(GetPlayerWeapon(playerid) > 0)
	{
		helditems[0] = GetPlayerWeapon(playerid);
		helditems[1] = GetPlayerAmmo(playerid);
		fblockwrite(file, helditems, 2);
	}
	else
	{
		if(IsValidItem(GetPlayerItem(playerid)))
		{
			helditems[0] = _:GetItemType(GetPlayerItem(playerid));
			helditems[1] = GetItemExtraData(GetPlayerItem(playerid));
			fblockwrite(file, helditems, 2);
		}
		else
		{
			helditems[0] = -1;
			helditems[1] = -1;
			fblockwrite(file, helditems, 2);
		}
	}

	for(new i, j; j < 4; i += 2, j++)
	{
		inventoryitems[i] = _:GetItemType(GetInventorySlotItem(playerid, j));
		inventoryitems[i+1] = GetItemExtraData(GetInventorySlotItem(playerid, j));
	}

	fblockwrite(file, inventoryitems, 8);

	if(IsValidItem(GetPlayerBackpackItem(playerid)))
	{
		new
			containerid = GetItemExtraData(GetPlayerBackpackItem(playerid)),
			bagdata[17];

		bagdata[0] = _:GetItemType(GetPlayerBackpackItem(playerid));

		for(new i = 1, j; j < GetContainerSize(containerid); i += 2, j++)
		{
			bagdata[i] = _:GetItemType(GetContainerSlotItem(containerid, j));
			bagdata[i+1] = GetItemExtraData(GetContainerSlotItem(containerid, j));
		}
		fblockwrite(file, bagdata, 17);
	}

	fclose(file);
}
LoadPlayerInventory(playerid)
{
	new
		filename[MAX_PLAYER_FILE],
		File:file,
		filepos,
		healtharmour[2],
		helditems[2],
		inventoryitems[8],
		bagdata[17],
		itemid;

	GetFile(gPlayerName[playerid], filename);

	if(!fexist(filename))
	{
		ClearPlayerInventoryFile(playerid);
		return 0;
	}

	file = fopen(filename, io_read);

	fblockread(file, healtharmour, 2);

	printf("LOAD: Health: %f Armour: %f", healtharmour[0], healtharmour[1]);

	gPlayerHP[playerid] = Float:healtharmour[0];
	gPlayerAP[playerid] = Float:healtharmour[1];

	fblockread(file, helditems, 2);

	printf("holster: %d %d", helditems[0], helditems[1]);
	if(helditems[0] != -1)
	{
		if(0 < helditems[0] <= WEAPON_PARACHUTE)
		{
			HolsterWeapon(playerid, helditems[0], helditems[1]);
		}
	}

	fblockread(file, helditems, 2);
	printf("helditems: %d %d", helditems[0], helditems[1]);
	if(helditems[0] != -1)
	{
		if(0 < helditems[0] <= WEAPON_PARACHUTE)
		{
			GivePlayerWeapon(playerid, helditems[0], helditems[1]);
		}
		else
		{
			itemid = CreateItem(ItemType:helditems[0], 0.0, 0.0, 0.0);
			SetItemExtraData(itemid, helditems[1]);
			GiveWorldItemToPlayer(playerid, itemid, false);
		}
	}

	filepos = fblockread(file, inventoryitems, 8);

	for(new i; i < 8; i += 2)
	{
		if(inventoryitems[i] == _:INVALID_ITEM_TYPE)
			continue;

		itemid = CreateItem(ItemType:inventoryitems[i], 0.0, 0.0, 0.0);
		SetItemExtraData(itemid, inventoryitems[i + 1]);
		AddItemToInventory(playerid, itemid);
	}

	if(filepos != 0)
	{
		new
			containerid;

		fblockread(file, bagdata, 17);

		if(bagdata[0] == _:item_Satchel)
		{
			itemid = CreateItem(item_Satchel, 0.0, 0.0, 0.0);
			GivePlayerBackpack(playerid, itemid);
			containerid = GetItemExtraData(itemid);

			for(new i = 1; i < 8; i += 2)
			{
				if(bagdata[i] == _:INVALID_ITEM_TYPE)
					continue;

				itemid = CreateItem(ItemType:bagdata[i], 0.0, 0.0, 0.0);
				SetItemExtraData(itemid, bagdata[i+1]);
				AddItemToContainer(containerid, itemid);
			}
		}

		if(bagdata[0] == _:item_Backpack)
		{
			itemid = CreateItem(item_Backpack, 0.0, 0.0, 0.0);
			GivePlayerBackpack(playerid, itemid);
			containerid = GetItemExtraData(itemid);

			for(new i = 1; i < 16; i += 2)
			{
				if(bagdata[i] == _:INVALID_ITEM_TYPE)
					continue;

				itemid = CreateItem(ItemType:bagdata[i], 0.0, 0.0, 0.0);
				SetItemExtraData(itemid, bagdata[i+1]);
				AddItemToContainer(containerid, itemid);
			}
		}
	}

	fclose(file);

	return 1;
}
ClearPlayerInventoryFile(playerid)
{
	new
		filename[MAX_PLAYER_FILE],
		File:file;

	GetFile(gPlayerName[playerid], filename);

	file = fopen(filename, io_write);
	fblockwrite(file, {0}, 1);
	fclose(file);
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
	if(bPlayerGameSettings[playerid] & IsAfk)Delete3DTextLabel(gPlayerAfkLabel[playerid]);
}


ResetVariables(playerid)
{
	gPlayerHP[playerid] = 100.0;
	gPlayerAP[playerid] = 0.0;

	bPlayerGameSettings[playerid]			= 0;

	pAdmin(playerid)						= 0,
	gPlayerData[playerid][ply_Skin]			= 0,

    gPlayerVehicleID[playerid]				= INVALID_VEHICLE_ID,
	gPlayerChatChannel[playerid]			= -1;
	Warnings[playerid]						= 0;
	IncorrectPass[playerid]					= 0;

	PlayerLoop(i)
		Blocked[playerid][i] = false;

	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL,			100);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN,	100);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI,		100);
}




LogMessage(playerid)
{
	new
		str1[700],
		str2[300],
		admins[48],
		admincount;

	PlayerLoop(i)
	{
		if(pAdmin(i)>0)
			admincount++;
	}

	if(admincount > 0)
		format(admins, 48, "Admins currently online: "#C_GREEN"%d", admincount);

	else
		admins = "There are no admins online";

	format(str1, 400,
		""#C_WHITE"%s\n\n\
		Welcome to "#C_BLUE"Scavenge and Survive!\n\n\n\n\
		"#C_WHITE"The object is to survive for as long as possible.\n\n\
		You will have a better chance if you are in a group.\n\n\
		But be careful who you trust.\n\n\
		Items can be found scattered around.\n\n",
		HORIZONTAL_RULE);

	format(str2, 300,
		"Weapons are rare so conserve your ammunition.\n\n\
		And last but not least...\n\n\
		"#C_RED"NEVER "#C_WHITE"attack an unarmed player.\n\n\n\n\
		"#C_WHITE"The current time is "#C_YELLOW"%02d:%02d"#C_WHITE"\n\
		The current weather is "#C_YELLOW"%s"#C_WHITE"\n\n\n\n\
		%s",
		gTimeHour,
		gTimeMinute,
		WeatherData[gWeatherID][weather_name],
		admins,
		HORIZONTAL_RULE);

	strcat(str1, str2);

	ShowPlayerDialog(playerid, d_LogMsg, DIALOG_STYLE_MSGBOX, "Welcome to the Server", str1, "Accept", "");
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
	if(IsPlayerNPC(playerid))
		return 1;

	SetPlayerWeather(playerid, WeatherData[gWeatherID][weather_id]);

	print("OnPlayerSpawn");

	if(bPlayerGameSettings[playerid] & Dying)
	{
		TogglePlayerSpectating(playerid, true);

		defer SetDeathCamera(playerid);

		SetPlayerCameraPos(playerid,
			gPlayerDeathPos[playerid][0] - floatsin(-gPlayerDeathPos[playerid][3], degrees),
			gPlayerDeathPos[playerid][1] - floatcos(-gPlayerDeathPos[playerid][3], degrees),
			gPlayerDeathPos[playerid][2]);

		SetPlayerCameraLookAt(playerid, gPlayerDeathPos[playerid][0], gPlayerDeathPos[playerid][1], gPlayerDeathPos[playerid][2]);

		TextDrawShowForPlayer(playerid, DeathText);
		TextDrawShowForPlayer(playerid, DeathButton);
		SelectTextDraw(playerid, 0xFFFFFF88);
		gPlayerHP[playerid] = 100.0;
	}
	else
	{
		if(bPlayerGameSettings[playerid] & Alive)
		{
			SetPlayerSkin(playerid, gPlayerData[playerid][ply_Skin]);

			SetPlayerPos(playerid,
				gPlayerData[playerid][ply_posX],
				gPlayerData[playerid][ply_posY],
				gPlayerData[playerid][ply_posZ]);

			SetPlayerFacingAngle(playerid, gPlayerData[playerid][ply_rotZ]);
			SetCameraBehindPlayer(playerid);
			TogglePlayerControllable(playerid, true);
			LoadPlayerInventory(playerid);
			t:bPlayerGameSettings[playerid]<Spawned>;

			GangZoneShowForPlayer(playerid, MiniMapOverlay, 0x000000FF);
			TextDrawShowForPlayer(playerid, MapCover1);
			TextDrawShowForPlayer(playerid, MapCover2);
		}
		else
		{
			gPlayerHP[playerid] = 100.0;
			PlayerCreateNewCharacter(playerid);
		}
	}

	PlayerPlaySound(playerid, 1186, 0.0, 0.0, 0.0);
	PreloadPlayerAnims(playerid);

	SetPlayerWeather(playerid, WeatherData[gWeatherID][weather_id]);

	Streamer_Update(playerid);
	SetAllWeaponSkills(playerid, 500);

	return 1;
}

PlayerCreateNewCharacter(playerid)
{
	SetPlayerPos(playerid, -907.5452, 272.7235, 1014.1449);
	SetPlayerFacingAngle(playerid, 0.0);
	SetPlayerCameraLookAt(playerid, -907.5452, 272.7235, 1014.1449);
	SetPlayerCameraPos(playerid, -907.4642, 277.0962, 1014.1492);
	Streamer_UpdateEx(playerid, -907.5452, 272.7235, 1014.1449);

	gClassBoxFadeLevel[playerid] = 255;
	PlayerTextDrawBoxColor(playerid, ClassBackGround, gClassBoxFadeLevel[playerid]);
	PlayerTextDrawShow(playerid, ClassBackGround);
	PlayerTextDrawShow(playerid, ClassButtonMale);
	PlayerTextDrawShow(playerid, ClassButtonFemale);
	SelectTextDraw(playerid, 0xFFFFFF88);
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(playertextid == ClassButtonMale)
	{
		t:bPlayerGameSettings[playerid]<Gender>;
		OnPlayerSelectGender(playerid);
	}
	if(playertextid == ClassButtonFemale)
	{
		f:bPlayerGameSettings[playerid]<Gender>;
		OnPlayerSelectGender(playerid);
	}
}

timer SetDeathCamera[50](playerid)
{
	InterpolateCameraPos(playerid,
		gPlayerDeathPos[playerid][0] - floatsin(-gPlayerDeathPos[playerid][3], degrees),
		gPlayerDeathPos[playerid][1] - floatcos(-gPlayerDeathPos[playerid][3], degrees),
		gPlayerDeathPos[playerid][2] + 1.0,
		gPlayerDeathPos[playerid][0] - floatsin(-gPlayerDeathPos[playerid][3], degrees),
		gPlayerDeathPos[playerid][1] - floatcos(-gPlayerDeathPos[playerid][3], degrees),
		gPlayerDeathPos[playerid][2] + 20.0,
		30000, CAMERA_MOVE);

	InterpolateCameraLookAt(playerid,
		gPlayerDeathPos[playerid][0],
		gPlayerDeathPos[playerid][1],
		gPlayerDeathPos[playerid][2],
		gPlayerDeathPos[playerid][0],
		gPlayerDeathPos[playerid][1],
		gPlayerDeathPos[playerid][2] + 1.0,
		30000, CAMERA_MOVE);
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == DeathButton)
	{
		f:bPlayerGameSettings[playerid]<Dying>;
		TogglePlayerSpectating(playerid, false);
		CancelSelectTextDraw(playerid);
		TextDrawHideForPlayer(playerid, DeathText);
		TextDrawHideForPlayer(playerid, DeathButton);
	}
}

OnPlayerSelectGender(playerid)
{
	new
		r = random(MAX_SPAWNS),
		backpackitem,
		tmpitem;

	if(bPlayerGameSettings[playerid] & Gender)
		SetPlayerSkin(playerid, SKIN_M_NORMAL);

	else
		SetPlayerSkin(playerid, SKIN_F_NORMAL);

	SetPlayerPos(playerid, gSpawns[r][0], gSpawns[r][1], gSpawns[r][2]);
	SetPlayerFacingAngle(playerid, gSpawns[r][3]);
	SetCameraBehindPlayer(playerid);
	TogglePlayerControllable(playerid, true);
	SetAllWeaponSkills(playerid, 500);
	GangZoneShowForPlayer(playerid, MiniMapOverlay, 0x000000FF);
	TextDrawShowForPlayer(playerid, MapCover1);
	TextDrawShowForPlayer(playerid, MapCover2);

	CancelSelectTextDraw(playerid);
	PlayerTextDrawHide(playerid, ClassButtonMale);
	PlayerTextDrawHide(playerid, ClassButtonFemale);

	t:bPlayerGameSettings[playerid]<Spawned>;
	t:bPlayerGameSettings[playerid]<Alive>;

	gClassBoxFadeLevel[playerid] = 255;
	stop gClassFadeTimer[playerid];
	gClassFadeTimer[playerid] = repeat FadeOutClassBackground(playerid);

	backpackitem = CreateItem(item_Satchel, gSpawns[r][0], gSpawns[r][1], gSpawns[r][2]);

	GivePlayerBackpack(playerid, backpackitem);

	tmpitem = CreateItem(ItemType:WEAPON_COLT45, gSpawns[r][0], gSpawns[r][1], gSpawns[r][2]);
	SetItemExtraData(tmpitem, WepData[WEAPON_COLT45][MagSize] * 2);
	AddItemToContainer(GetItemExtraData(backpackitem), tmpitem);

	tmpitem = CreateItem(ItemType:WEAPON_KNIFE, gSpawns[r][0], gSpawns[r][1], gSpawns[r][2]);
	SetItemExtraData(tmpitem, 1);
	AddItemToContainer(GetItemExtraData(backpackitem), tmpitem);

	tmpitem = CreateItem(item_Medkit, gSpawns[r][0], gSpawns[r][1], gSpawns[r][2]);
	AddItemToContainer(GetItemExtraData(backpackitem), tmpitem);

	tmpitem = CreateItem(item_Wrench, gSpawns[r][0], gSpawns[r][1], gSpawns[r][2]);
	AddItemToContainer(GetItemExtraData(backpackitem), tmpitem);

	Tutorial_Start(playerid);

}

timer FadeOutClassBackground[100](playerid)
{
	PlayerTextDrawBoxColor(playerid, ClassBackGround, gClassBoxFadeLevel[playerid]);
	PlayerTextDrawShow(playerid, ClassBackGround);
	gClassBoxFadeLevel[playerid] -= 4;

	if(gClassBoxFadeLevel[playerid] <= 0)
		stop gClassFadeTimer[playerid];
}


public OnPlayerDeath(playerid, killerid, reason)
{
	print("OnPlayerDeath");

	if(tickcount() - tick_LastDeath[playerid] > 3000)
		return internal_OnPlayerDeath(playerid, killerid, reason);

	return 1;
}

internal_OnPlayerDeath(playerid, killerid, reason)
{
	new backpackitem = GetPlayerBackpackItem(playerid);
	print("internal_OnPlayerDeath");

	f:bPlayerGameSettings[playerid]<Spawned>;
	t:bPlayerGameSettings[playerid]<Dying>;

	GetPlayerPos(playerid, gPlayerDeathPos[playerid][0], gPlayerDeathPos[playerid][1], gPlayerDeathPos[playerid][2]);
	GetPlayerFacingAngle(playerid, gPlayerDeathPos[playerid][3]);

	f:bPlayerGameSettings[playerid]<Alive>;
	tick_LastDeath[playerid] = tickcount();

	stop TankHeatUpdateTimer[playerid];

	TextDrawHideForPlayer(playerid, MapCover1);
	TextDrawHideForPlayer(playerid, MapCover2);

	if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 432)
		HidePlayerProgressBar(playerid, TankHeatBar);

	if(GetPlayerHolsteredWeapon(playerid) > 0)
	{
		CreateItem(ItemType:GetPlayerHolsteredWeapon(playerid),
			gPlayerDeathPos[playerid][0] + floatsin(195.0, degrees),
			gPlayerDeathPos[playerid][1] + floatcos(195.0, degrees),
			gPlayerDeathPos[playerid][2] - FLOOR_OFFSET);

		ClearPlayerHolsterWeapon(playerid);
	}

	if(GetPlayerWeapon(playerid) > 0)
	{
		CreateItem(ItemType:GetPlayerWeapon(playerid),
			gPlayerDeathPos[playerid][0] + floatsin(45.0, degrees),
			gPlayerDeathPos[playerid][1] + floatcos(45.0, degrees),
			gPlayerDeathPos[playerid][2] - FLOOR_OFFSET);
	}

	for(new i; i < INV_MAX_SLOTS; i++)
	{
		new itemid = GetInventorySlotItem(playerid, 0);

		if(!IsValidItem(itemid))
			break;

		RemoveItemFromInventory(playerid, 0);
		CreateItemInWorld(itemid,
			gPlayerDeathPos[playerid][0] + floatsin( (360.0 / 4.0) * float(i), degrees),
			gPlayerDeathPos[playerid][1] + floatcos( (360.0 / 4.0) * float(i), degrees),
			gPlayerDeathPos[playerid][2] - FLOOR_OFFSET);
	}

	if(IsValidItem(backpackitem))
	{
		RemovePlayerBackpack(playerid);
		SetItemPos(backpackitem, gPlayerDeathPos[playerid][0], gPlayerDeathPos[playerid][1], gPlayerDeathPos[playerid][2] - FLOOR_OFFSET);
		SetItemRot(backpackitem, 0.0, 0.0, 0.0, true);
	}

	SpawnPlayer(playerid);

	return CallLocalFunction("OnDeath", "ddd", playerid, killerid, reason);
}



ShowHelpTip(playerid, text[], time = 0)
{
	PlayerTextDrawSetString(playerid, HelpTipText, text);
	PlayerTextDrawShow(playerid, HelpTipText);

	if(time > 0)
		defer HideHelpTip(playerid, time);
}
timer HideHelpTip[time](playerid, time)
{
	#pragma unused time
	PlayerTextDrawHide(playerid, HelpTipText);
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
		if(weaponid == 53)
			GivePlayerHP(playerid, -(amount*0.5), .weaponid = weaponid);

		else
			GivePlayerHP(playerid, -(amount*2), .weaponid = weaponid);
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

internal_HitPlayer(playerid, targetid, weaponid, type = 0)
{
	if(weaponid == WEAPON_DESERTEAGLE)
	{
		if(tickcount() - tick_WeaponHit[playerid] < 400)
			return 0;
	}
	else
	{
		if(tickcount() - tick_WeaponHit[playerid] < 100)
			return 0;
	}

	tick_WeaponHit[playerid] = tickcount();

	new head;
	
	if(!IsPlayerInAnyVehicle(playerid))
	{
		switch(weaponid)
		{
		    case 25, 27, 30, 31, 33, 34:head = IsPlayerAimingAtHead(playerid, targetid);
		}
	}

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
	GetPlayerPos(targetid, tx, ty, tz);

	trgDist = Distance(px, py, pz, tx, ty, tz);

	if(type == 0)
	{
		if(trgDist < WepData[weaponid][MinDis])HpLoss = WepData[weaponid][MaxDam];
		if(trgDist > WepData[weaponid][MaxDis])HpLoss = WepData[weaponid][MinDam];
		else HpLoss = ((WepData[weaponid][MinDam]-WepData[weaponid][MaxDam])/(WepData[weaponid][MaxDis]-WepData[weaponid][MinDis])) * (trgDist-WepData[weaponid][MaxDis]) + WepData[weaponid][MinDam];

		if(head)
			HpLoss *= 1.5;
	}
	else if(type == 1)
	{
		HpLoss = itd_Data[weaponid][itd_damage];
	}

	if(GetItemType(GetPlayerItem(targetid)) == item_Shield)
	{
		new
			Float:angleto,
			Float:targetangle;

		GetPlayerFacingAngle(targetid, targetangle);

		angleto = absoluteangle(targetangle - GetAngleToPoint(px, py, tx, ty));

		if(225.0 < angleto < 315.0)
		{
			GameTextForPlayer(targetid, "Shield!", 1000, 5);
			HpLoss *= 0.2;
		}
	}

	GivePlayerHP(targetid, -HpLoss, playerid, weaponid);
	ShowHitMarker(playerid, weaponid);


	if(pAdmin(playerid) >= 3)
	{
		new str[32];
		format(str, 32, "did %.2f", HpLoss);
		ShowMsgBox(playerid, str, 1000, 120);
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

ShowHitMarker(playerid, weapon)
{
	if(weapon == 34 || weapon == 35)
	{
		TextDrawShowForPlayer(playerid, HitMark_centre);
		defer HideHitMark(playerid, HitMark_centre);
	}
	else
	{
		TextDrawShowForPlayer(playerid, HitMark_offset);
		defer HideHitMark(playerid, HitMark_offset);
	}
}
timer HideHitMark[500](playerid, Text:hitmark)
{
	TextDrawHideForPlayer(playerid, hitmark);
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

		if( ((newkeys & 1) || (newkeys & 4)) && (iVehicleModel == 432) )
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
		if(newkeys == KEY_ACTION)
		{
			if(iVehicleModel == 525)
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

			if(health >= 300.0 && gVehicleFuel[gPlayerVehicleID[playerid]] > 0.0)
				v_Engine(gPlayerVehicleID[playerid], !v_Engine(gPlayerVehicleID[playerid]));
		}
		if(newkeys & KEY_NO)v_Lights(gPlayerVehicleID[playerid], !v_Lights(gPlayerVehicleID[playerid]));
	}
	else
	{
		if(newkeys & KEY_JUMP && !(oldkeys & KEY_JUMP) && GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED)ApplyAnimation(playerid, "GYMNASIUM", "gym_jog_falloff",4.1,0,1,1,0,0);

	    new iWepState = GetPlayerWeaponState(playerid);
		if((newkeys&KEY_FIRE)&&(iWepState!=WEAPONSTATE_RELOADING&&iWepState!=WEAPONSTATE_NO_BULLETS))OnPlayerShoot(playerid);
	}

	return 1;
}

OnPlayerShoot(playerid)
{
	#pragma unused playerid
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
	    else if(gPlayerChatChannel[playerid] == CHANNEL_VEHICLE)
	    {
			PlayerLoop(i)
				if(IsPlayerInVehicle(i, GetPlayerVehicleID(playerid)))
					MsgF(i, WHITE, "(V)%P"#C_WHITE": %s", playerid, TagScan(text));
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

	format(text, 173, "%C(%d) %P"#C_WHITE": %s",
		AdminColours[pAdmin(playerid)],
		playerid,
		playerid,
		TagScan(textInput));

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
stock TagScan(chat[], colour = WHITE)
{
	new
		text[256],
		length,
		a,
		tags;

	strcpy(text, chat, 256);
	length = strlen(chat);
	
	while(a < (length - 1) && tags < 3)
	{
		if(text[a] == '#')
		{
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

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	new vehicleid = GetPlayerVehicleID(playerid);

	if(bPlayerGameSettings[playerid] & DebugMode)
		MsgF(playerid, YELLOW, "Newstate: %d, Oldstate: %d", newstate, oldstate);

	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
	{
		new model = GetVehicleModel(vehicleid);

	    if(newstate == PLAYER_STATE_DRIVER)
	    {
			SetPlayerArmedWeapon(playerid, 0);

			if(model == 432)
			{
				TankHeatUpdateTimer[playerid] = repeat TankHeatUpdate(playerid);
				ShowPlayerProgressBar(playerid, TankHeatBar);
			}
	    }

		gPlayerVehicleID[playerid] = vehicleid;

		t:bVehicleSettings[vehicleid]<v_Used>;
		t:bVehicleSettings[vehicleid]<v_Occupied>;

		PlayerTextDrawSetString(playerid, VehicleNameText, VehicleNames[model-400]);
		PlayerTextDrawShow(playerid, VehicleNameText);
		PlayerTextDrawShow(playerid, VehicleSpeedText);

		Streamer_SetFloatData(STREAMER_TYPE_AREA, gPlayerArea[playerid], E_STREAMER_SIZE, 20.0);
		AttachDynamicAreaToVehicle(gPlayerArea[playerid], vehicleid);
	}
	if(oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER)
	{
	    gPlayerVehicleID[playerid] = INVALID_VEHICLE_ID;

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

		Streamer_SetFloatData(STREAMER_TYPE_AREA, gPlayerArea[playerid], E_STREAMER_SIZE, 1.4);
		AttachDynamicAreaToPlayer(gPlayerArea[playerid], playerid);
	}
	return 1;
}
public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}
public OnPlayerExitVehicle(playerid, vehicleid)
{
	if(GetVehicleModel(vehicleid) == 432)
		HidePlayerProgressBar(playerid, TankHeatBar);

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

//=========================================================================Death
	DeathText				=TextDrawCreate(320.000000, 300.000000, "YOU ARE DEAD!");
	TextDrawAlignment			(DeathText, 2);
	TextDrawBackgroundColor		(DeathText, 255);
	TextDrawFont				(DeathText, 1);
	TextDrawLetterSize			(DeathText, 0.500000, 2.000000);
	TextDrawColor				(DeathText, -1);
	TextDrawSetOutline			(DeathText, 0);
	TextDrawSetProportional		(DeathText, 1);
	TextDrawSetShadow			(DeathText, 1);
	TextDrawUseBox				(DeathText, 1);
	TextDrawBoxColor			(DeathText, 85);
	TextDrawTextSize			(DeathText, 20.000000, 150.000000);

	DeathButton					=TextDrawCreate(320.000000, 323.000000, ">Play Again<");
	TextDrawAlignment			(DeathButton, 2);
	TextDrawBackgroundColor		(DeathButton, 255);
	TextDrawFont				(DeathButton, 1);
	TextDrawLetterSize			(DeathButton, 0.370000, 1.599999);
	TextDrawColor				(DeathButton, -1);
	TextDrawSetOutline			(DeathButton, 0);
	TextDrawSetProportional		(DeathButton, 1);
	TextDrawSetShadow			(DeathButton, 1);
	TextDrawUseBox				(DeathButton, 1);
	TextDrawBoxColor			(DeathButton, 85);
	TextDrawTextSize			(DeathButton, 20.000000, 150.000000);
	TextDrawSetSelectable		(DeathButton, true);

//=========================================================================Clock
	ClockText					=TextDrawCreate(605.0, 25.0, "00:00");
	TextDrawUseBox				(ClockText, 0);
	TextDrawFont				(ClockText, 3);
	TextDrawSetShadow			(ClockText, 0);
	TextDrawSetOutline			(ClockText, 2);
	TextDrawBackgroundColor		(ClockText, 0x000000FF);
	TextDrawColor				(ClockText, 0xFFFFFFFF);
	TextDrawAlignment			(ClockText, 3);
	TextDrawLetterSize			(ClockText, 0.5, 1.6);

//=========================================================================Clock
	MapCover1					=TextDrawCreate(87.000000, 316.000000, "O");
	TextDrawAlignment			(MapCover1, 2);
	TextDrawBackgroundColor		(MapCover1, 255);
	TextDrawFont				(MapCover1, 1);
	TextDrawLetterSize			(MapCover1, 4.159998, 13.600000);
	TextDrawColor				(MapCover1, 255);
	TextDrawSetOutline			(MapCover1, 0);
	TextDrawSetProportional		(MapCover1, 1);
	TextDrawSetShadow			(MapCover1, 0);

	MapCover2					=TextDrawCreate(87.000000, 345.000000, "O");
	TextDrawAlignment			(MapCover2, 2);
	TextDrawBackgroundColor		(MapCover2, 255);
	TextDrawFont				(MapCover2, 1);
	TextDrawLetterSize			(MapCover2, 2.169998, 7.699997);
	TextDrawColor				(MapCover2, 255);
	TextDrawSetOutline			(MapCover2, 0);
	TextDrawSetProportional		(MapCover2, 1);
	TextDrawSetShadow			(MapCover2, 0);

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

}
LoadPlayerTextDraws(playerid)
{
//==============================================================Character Create
	ClassBackGround					=CreatePlayerTextDraw(playerid, 0.000000, 0.000000, "_");
	PlayerTextDrawBackgroundColor	(playerid, ClassBackGround, 255);
	PlayerTextDrawFont				(playerid, ClassBackGround, 1);
	PlayerTextDrawLetterSize		(playerid, ClassBackGround, 0.500000, 50.000000);
	PlayerTextDrawColor				(playerid, ClassBackGround, -1);
	PlayerTextDrawSetOutline		(playerid, ClassBackGround, 0);
	PlayerTextDrawSetProportional	(playerid, ClassBackGround, 1);
	PlayerTextDrawSetShadow			(playerid, ClassBackGround, 1);
	PlayerTextDrawUseBox			(playerid, ClassBackGround, 1);
	PlayerTextDrawBoxColor			(playerid, ClassBackGround, 255);
	PlayerTextDrawTextSize			(playerid, ClassBackGround, 640.000000, 0.000000);

	ClassButtonMale					=CreatePlayerTextDraw(playerid, 250.000000, 200.000000, "~n~Male~n~~n~");
	PlayerTextDrawAlignment			(playerid, ClassButtonMale, 2);
	PlayerTextDrawBackgroundColor	(playerid, ClassButtonMale, 255);
	PlayerTextDrawFont				(playerid, ClassButtonMale, 1);
	PlayerTextDrawLetterSize		(playerid, ClassButtonMale, 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, ClassButtonMale, -1);
	PlayerTextDrawSetOutline		(playerid, ClassButtonMale, 0);
	PlayerTextDrawSetProportional	(playerid, ClassButtonMale, 1);
	PlayerTextDrawSetShadow			(playerid, ClassButtonMale, 1);
	PlayerTextDrawUseBox			(playerid, ClassButtonMale, 1);
	PlayerTextDrawBoxColor			(playerid, ClassButtonMale, 255);
	PlayerTextDrawTextSize			(playerid, ClassButtonMale, 300.000000, 100.000000);
	PlayerTextDrawSetSelectable		(playerid, ClassButtonMale, true);

	ClassButtonFemale				=CreatePlayerTextDraw(playerid, 390.000000, 200.000000, "~n~Female~n~~n~");
	PlayerTextDrawAlignment			(playerid, ClassButtonFemale, 2);
	PlayerTextDrawBackgroundColor	(playerid, ClassButtonFemale, 255);
	PlayerTextDrawFont				(playerid, ClassButtonFemale, 1);
	PlayerTextDrawLetterSize		(playerid, ClassButtonFemale, 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, ClassButtonFemale, -1);
	PlayerTextDrawSetOutline		(playerid, ClassButtonFemale, 0);
	PlayerTextDrawSetProportional	(playerid, ClassButtonFemale, 1);
	PlayerTextDrawSetShadow			(playerid, ClassButtonFemale, 1);
	PlayerTextDrawUseBox			(playerid, ClassButtonFemale, 1);
	PlayerTextDrawBoxColor			(playerid, ClassButtonFemale, 255);
	PlayerTextDrawTextSize			(playerid, ClassButtonFemale, 300.000000, 100.000000);
	PlayerTextDrawSetSelectable		(playerid, ClassButtonFemale, true);


//======================================================================HelpTips

	HelpTipText						=CreatePlayerTextDraw(playerid, 150.000000, 350.000000, "Tip: You can access the trunks of cars by pressing F at the back");
	PlayerTextDrawBackgroundColor	(playerid, HelpTipText, 255);
	PlayerTextDrawFont				(playerid, HelpTipText, 1);
	PlayerTextDrawLetterSize		(playerid, HelpTipText, 0.300000, 1.499999);
	PlayerTextDrawColor				(playerid, HelpTipText, 16711935);
	PlayerTextDrawSetOutline		(playerid, HelpTipText, 1);
	PlayerTextDrawSetProportional	(playerid, HelpTipText, 1);
	PlayerTextDrawSetShadow			(playerid, HelpTipText, 0);
	PlayerTextDrawUseBox			(playerid, HelpTipText, 1);
	PlayerTextDrawBoxColor			(playerid, HelpTipText, 0);
	PlayerTextDrawTextSize			(playerid, HelpTipText, 520.000000, 0.000000);


//========================================================================Speedo

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


//======================================================================Stat GUI

	AddHPText						=CreatePlayerTextDraw(playerid, 160.000000, 240.000000, "<+HP>");
	PlayerTextDrawColor				(playerid, AddHPText, RED);
	PlayerTextDrawBackgroundColor	(playerid, AddHPText, 255);
	PlayerTextDrawFont				(playerid, AddHPText, 1);
	PlayerTextDrawLetterSize		(playerid, AddHPText, 0.300000, 1.000000);
	PlayerTextDrawSetProportional	(playerid, AddHPText, 1);
	PlayerTextDrawSetShadow			(playerid, AddHPText, 0);
	PlayerTextDrawSetOutline		(playerid, AddHPText, 1);

	AddScoreText					=CreatePlayerTextDraw(playerid, 160.000000, 260.000000, "<+P>");
	PlayerTextDrawColor				(playerid, AddScoreText, YELLOW);
	PlayerTextDrawBackgroundColor	(playerid, AddScoreText, 255);
	PlayerTextDrawFont				(playerid, AddScoreText, 1);
	PlayerTextDrawLetterSize		(playerid, AddScoreText, 0.300000, 1.000000);
	PlayerTextDrawSetProportional	(playerid, AddScoreText, 1);
	PlayerTextDrawSetShadow			(playerid, AddScoreText, 0);
	PlayerTextDrawSetOutline		(playerid, AddScoreText, 1);

	ActionBar						= CreatePlayerProgressBar(playerid, 291.0, 345.0, 57.50, 5.19, GREY, 100.0);
	TankHeatBar						= CreatePlayerProgressBar(playerid, 220.0, 380.0, 200.0, 20.0, RED, 30.0);
}
UnloadPlayerTextDraws(playerid)
{
	PlayerTextDrawDestroy(playerid, ClassBackGround);
	PlayerTextDrawDestroy(playerid, ClassButtonMale);
	PlayerTextDrawDestroy(playerid, ClassButtonFemale);
	PlayerTextDrawDestroy(playerid, HelpTipText);
	PlayerTextDrawDestroy(playerid, VehicleNameText);
	PlayerTextDrawDestroy(playerid, VehicleSpeedText);
	PlayerTextDrawDestroy(playerid, AddHPText);
	PlayerTextDrawDestroy(playerid, AddScoreText);

	DestroyPlayerProgressBar(playerid, TankHeatBar);
	DestroyPlayerProgressBar(playerid, ActionBar);
}


public OnButtonPress(playerid, buttonid)
{
	print("OnButtonPress <Main Script>");
	return 1;
}

public OnPlayerActivateCheckpoint(playerid, checkpointid)
{
	return 1;
}


public OnDynamicObjectMoved(objectid)
{
	return 1;
}

stock GetPlayersOnline()
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

stock CancelPlayerMovement(playerid)
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);
	SetPlayerPos(playerid, x, y, z);
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

