#include <YSI\y_va>
#include <YSI\y_hooks>
#include <formatex>

// MaxValues
#define MAX_HEALTH			(100.0)
#define REGEN_TICK			(8000)
#define TAG_TICK			(6000)
#define MAX_MAPS			(26)
#define MAX_REGION			(5)
#define MAX_MODE			(4)
#define MAX_RANK			(24)
#define MAX_KIT				(5)
#define MAX_CP				(4)
#define MAX_CPNAME			(16)
#define MAX_VENGE_TIME		(3000)
#define MAX_XPMSG_LEN		(150)
#define MAX_XPINT_LEN		(6)
#define MAX_XPMSG_LINE		(5)
#define EXP_TEXT_HIDE		(3000)
#define AWD_TEXT_HIDE		(3000)
#define MAX_DIST_BONUS		(50)
#define MAX_DM_WEP			(300)
#define MAX_MINES			(MAX_PLAYERS*4)
#define MAX_MINE_RAD		(3.0)
#define MAX_WEAPON			(19)
#define MAX_WEAPON_TYPE		(4)
#define MAX_WEAPON_GRP		(7)
#define MAX_LOADOUT_WEP		(3)
#define MAX_LOBBY_COUNT		(10)
#define MAX_SPAWN_COUNT		(5)
#define MAX_GEAR			(16)
#define MAX_SPOT_TIME		(10000)
#define MAX_CRATE_COOL		(20000)
#define MAX_GRAPHIC			(47)
#define MEDCRATE_HP			(10.0)
#define DM_MAX_OBJECTS		(1000)
#define DM_MAX_VEHICLE		(32)

#define MAX_AWARD			192
#define MAX_AWARD_NAME		24
#define MAX_AWARD_TAG		8
#define MAX_AWARD_GROUP		(6)
#define MAX_AWT_WEP			(18)
#define MAX_AWT_TYP			(4)
#define MAX_AWT_GRP			(7)
#define MAX_AWT_OBJ			(3)
#define MAX_AWT_SUP			(4)
#define MAX_AWT_KTP			(10)
#define MAX_RIBBON			(51)
#define MAX_MEDAL			(64)

// Files
#define DM_INDEX_FILE		"Deathmatch/index.ini"
#define DM_MAP_FILE			"Deathmatch/Maps/%s.map"
#define DM_CRATE_FILE		"Deathmatch/Crates/%d-%s.dat"
#define DM_VEHICLE_FILE		"Deathmatch/Vehicle/%d-%s.dat"
#define DM_DATA_FILE		"Deathmatch/%d-%s.ini"
#define DM_AWARD_FILE		"Deathmatch/Awards/Medals.dat"


#define WEAPON_SLOT_PRIMARY	(0)
#define WEAPON_SLOT_SIDEARM	(1)
#define WEAPON_SLOT_MELEE	(2)

#define DM_NORMAL			(0)
#define DM_HARDCORE			(1)
#define DM_BAREBONES		(2)
#define DM_SUDDENDEATH		(3)

#define SCORLIM_MIN			0
#define TICKLIM_MIN			5
#define FLAGLIM_MIN			1
#define FORCLIM_MIN			10

#define SCORLIM_MAX			100
#define TICKLIM_MAX			100
#define FLAGLIM_MAX			20
#define FORCLIM_MAX			300

#define MATCHTIME_MIN		0
#define MATCHTIME_MAX		30

#define MIN_DM_PLAYERS		2
#define MAX_DM_PLAYERS		MAX_PLAYERS

// Modes - Binary values for file loading
#define bDM_MODE_TDM		(8)
#define bDM_MODE_AD			(4)
#define bDM_MODE_CTF		(2)
#define bDM_MODE_CQS		(1)

// Modes - Integers for script use
#define DM_MODE_TDM			(0)
#define DM_MODE_AD			(1)
#define DM_MODE_CTF 		(2)
#define DM_MODE_CQS			(3)

// Kits
#define KIT_SUPPORT			(0)
#define KIT_MECHANIC		(1)
#define KIT_MEDIC			(2)
#define KIT_SPECOPS			(3)
#define KIT_BOMBER			(4)

// Keys
#define ACTION_KEY			(16)
#define EQUIPMENT_KEY		(262144)
#define GEAR_KEY			(131072)

#define TEXT_ACTION_KEY		"~k~~VEHICLE_ENTER_EXIT~"
#define TEXT_EQUIP_KEY		"~k~~GROUP_CONTROL_BWD~"
#define TEXT_GEAR_KEY		"~k~~CONVERSATION_NO~"

// Colours
#define FRIENDLY_PLAYER_VISIBLE		0x33CCFFFF
#define ENEMY_PLAYER_VISIBLE		0xFF0000FF

#define FRIENDLY_PLAYER_INVISIBLE	0x33CCFF00
#define ENEMY_PLAYER_INVISIBLE		0xFF000000

#define FRIENDLY_OBJECTIVE			0x33CCFFFF
#define ENEMY_OBJECTIVE				0xFF0000FF

// Dialog Texts
#define DIALOGTEXT_SCORLIM		"Enter the score limit below\nFirst dm_Team to reach this amount of kills wins the match.\n\n"#C_YELLOW"Between "#SCORLIM_MIN" and "#SCORLIM_MAX"."
#define DIALOGTEXT_TICKLIM		"Enter the Attackers Ticket Count\nEach time an attacking player is killed their dm_Team ticket count depletes by 1,\nwhen at 0 the match ends and Defenders win.\n\n"#C_YELLOW"Between "#TICKLIM_MIN" and "#TICKLIM_MAX"."
#define DIALOGTEXT_FLAGLIM		"Enter the CTF Flag limit below\nWhen a dm_Team captures this many flags the match ends and they win.\n\n"#C_YELLOW"Between "#FLAGLIM_MIN" and "#FLAGLIM_MAX"."
#define DIALOGTEXT_FORCLIM		"Enter the Reinforcement Ticket limit below\nEach time a player dies, their dm_Team ticket count depletes by 1,\nwhen at 0 the match ends and that dm_Team loses.\n\n"#C_YELLOW"Between "#FORCLIM_MIN" and "#FORCLIM_MAX"."
#define DIALOGTEXT_MATCHTIME	"Enter the Match Time in minutes.\n\n"#C_YELLOW"Between "#MATCHTIME_MIN" and "#MATCHTIME_MAX"."



// Forwards
forward Medic_RevivePlayer(playerid, targetid);
forward Engineer_Repair(playerid, vehicleid);
forward Bomber_PlaceMine(playerid);
forward ResetKitEquip(playerid);



enum E_PLAYER_DEATHMATCH_DATA
{
	dm_Kills,
	dm_Deaths,
	dm_Exp,
	dm_Rank,
	dm_HeadShots,
	dm_TeamKills,
	dm_HighStreak,
	dm_Wins,
	dm_Losses,

	dm_RoundExp,
	dm_RoundKills,
	dm_RoundDeaths,

	dm_Team,
	dm_Kit,
	dm_Gear,
	dm_Streak,
	dm_Combo
}
enum (<<=1)
{
	dm_InLobby = 1,
	dm_Ready,
	dm_Banned,
	dm_UsingEquip,
	dm_SupplyActive,
	dm_AwardNotif,

	dm_GearUse,
	dm_PlayingDead,
	dm_ExpNotif,

	dm_Bleeding,
	dm_Spotted,
	dm_Shooting,

	dm_HasFlag,
	dm_Capturing,

	dm_UsingSupplyCrate
}


new
	dm_PlayerData[MAX_PLAYERS][E_PLAYER_DEATHMATCH_DATA],
	pLoadout[MAX_PLAYERS][MAX_KIT][MAX_LOADOUT_WEP],
	pGraphic[MAX_PLAYERS],
	bPlayerDeathmatchSettings[MAX_PLAYERS];


new
	dm_Host 				= -1,
	dm_Map  				= -1,
	dm_Mode 				= -1,
    dm_MapNames				[MAX_MAPS][15],
	dm_MapModes				[MAX_MAPS],
	dm_MapRegion			[MAX_MAPS],
	dm_RegionIndex			[MAX_MAPS],
	dm_MapInfo_Bio			[MAX_MAPS][128],
	dm_MapInfo_Size			[MAX_MAPS][14],
	dm_MapInfo_Kit			[MAX_MAPS][26],
	dm_CurrentRegion,
	dm_TotalMaps,

	dm_SpawnCount			= MAX_SPAWN_COUNT,
	dm_WepListIndex			[2][6],

	Float:dm_PlayerSpawn	[MAX_PLAYERS][3],
	dm_MapSpawnSide			[2],
	dm_LobbyCount			= MAX_LOBBY_COUNT,
	dm_PlayerSpectateTarget	[MAX_PLAYERS],
	dm_PlayerWeaponDrop		[MAX_PLAYERS],

	tick_LastKill			[MAX_PLAYERS], // Use KILLERID
	tick_LastDeath			[MAX_PLAYERS], // Use PLAYERID
	tick_LastShot			[MAX_PLAYERS],
	tick_LastDamg			[MAX_PLAYERS],
	tick_LastTag			[MAX_PLAYERS],
	tick_Spotted			[MAX_PLAYERS],

	flag_LastKill			[MAX_PLAYERS],
	flag_LastShot			[MAX_PLAYERS],
	flag_ShotBy				[MAX_PLAYERS],
	flag_Spotted			[MAX_PLAYERS],


//======================Map File load variables

	Float:dm_SpecPos		[6],
	dm_Weather,
	dm_TimeH,
	dm_TimeM,
    dm_MapAuthor			[10],
	Float:dm_MapSpawnPos	[2][3],

//======================Menu Variables

	Menu:dm_LobbyMenu,
	Menu:dm_TeamMenu,

	dm_RegionList[60],
	dm_RegionMaps[5][100],

//======================Deathmatch Settings Variables

	dm_Preset = DM_NORMAL,
	dm_MatchTimeLimit,

	dm_BleedPoints[MAX_PLAYERS],
	dm_BleedPrtObj[MAX_PLAYERS],
	dm_BleedAttacker[MAX_PLAYERS],
	dm_BleedReason[MAX_PLAYERS],
	dm_BleedTotal,
	dm_EquipCount[MAX_PLAYERS],
	Timer:dm_GuiUpdateTimer[MAX_PLAYERS],

	dm_MsuVehicleID[2],
	bool:dm_MsuActive[2],
	Float:dm_GlobalMaxHP=MAX_HEALTH;

	enum
	{
		g_ProxDet,
		g_Ghillie,
		g_PlayDead,
		g_G12,
		g_Sneaky,
		g_Rocket,
		g_ExtraMags,
		g_ExtraMines,
		g_FMJ,
		g_Surprise,
		g_Disguise,
		g_Night,
		g_Thermal
	}

//======================Map Related Variables
new
	dm_CombatZone,
	dm_RadarBlock,
	Float:dm_CombatZonePos[4],
	dm_ObjectTable[DM_MAX_OBJECTS],
	dm_VehicleTable[DM_MAX_VEHICLE],
	Iterator:dm_ObjectTableIndex<DM_MAX_OBJECTS>,
	Iterator:dm_VehicleTableIndex<DM_MAX_VEHICLE>;

//======================Gamemode Names

new const
    dm_ModeNames[MAX_MODE][17]=
    {
	    "Team Deathmatch",
	    "Attack/Defend",
	    "Capture The Flag",
	    "Conquest"
    },

//======================Gamemode Name Abbreiviations

    dm_ModeNamesShort[MAX_MODE][4]=
    {
	    "TDM",
	    "A/D",
	    "CTF",
	    "CQS"
	},

//======================Map Region Names

    dm_RegionNames[MAX_REGION][21]=
    {
	    "City",
	    "Country",
	    "Desert",
	    "Ocean",
	    "San Andreas Original"
    },

//======================dm_Team Names

	dm_TeamNames[3][6]=
	{
		"Raven",
		"Valor",
		"Free"
	},

//======================dm_Kit Names

	dm_KitNames[MAX_KIT][10]=
	{
		"Support",
		"Mechanic",
		"Medic",
		"SpecOps",
		"Bomber"
	},

//======================dm_Gear Names

	dm_GearNames[13][19]=
	{
		"Proximity Detector",
		"Ghillie Suit",
		"Play Dead",
		"G12",
		"Sneaky",
		"Rocketman",
		"Extra Mags",
		"Extra Mines",
		"FMJ",
		"Surprise",
		"Disguise",
		"Night Vision",
		"Thermal Vision"
	},
	dm_GearInfo[13][121]=
	{
		"The Proximity Detector alerts you when someone shoots at you and when you are within 10 meters of an enemy mine.",
		"The Ghillie suit allows you to hide in a fake bush, useful for woodland maps. Activate with Left Alt (default Walk key)",
		"This lets you 'play dead' then to recover, press the crouch button. Activated with Left Alt (default Walk key)",
		"G12 makes you lethal with the two handed shotguns, adding an extra 10 hitpoints.",
		"Allows you to be invisible on the enemy's radar at all times.",
		"Gives you an RPG with one rocket when you spawn, useful for taking out tanks or vehicles.",
		"This gives you twice the amount of ammo in your primary and secondary weapon. Does not apply to throwables.",
		"This gives you 4 mines on the Bomber dm_Kit instead of 2",
		"Increases bullet penetration for all weapons and adds and extra 10 hitpoints",
		"Gives the enemy an explosive surprise when they kill you...",
		"Throughout the match you will have an enemy dm_Team skin, useful unless they notice the absence of a nametag!",
		"Spawns you with night vision goggles, make picking enemies out in the dark easy, good for night based maps",
		"Spawns you with thermal vision goggles, enemies glow red when these are in use good for dark maps"
	};

//======================Score Variables

	new
		dm_ScoreLimit  =	10,
		dm_FlagLimit   =	5;

	enum SCORE_TYPES
	{
		score_Kills,
		score_Flags,
		score_Tickets
	}
	new dm_TeamScore[SCORE_TYPES][2];

//======================Text Draw Variables

	new
		Text:ScoreBox,
		Text:ScoreStatus_Winning,
		Text:ScoreStatus_Tie,
		Text:ScoreStatus_Losing,
		Text:LobbyText,
		Text:SpawnCount,
		Text:HitMark_centre,
		Text:HitMark_offset,
		Text:MatchTimeCounter,

		PlayerText:dm_EquipText,
		PlayerText:XPtext,
		PlayerText:RankTextCurr,
		PlayerText:RankTextNext,

		PlayerText:AwdMsg_bg,
		PlayerText:AwdMsg_lCurve,
		PlayerText:AwdMsg_rCurve,
		PlayerText:AwdMsg_iconBox,
		PlayerText:AwdMsg_textBox,
		PlayerText:AwdMsg_iconMain,

		PlayerText:KillMsg_background,
		PlayerText:KillMsg_killerIcon,
		PlayerText:KillMsg_killerName,
		PlayerText:KillMsg_killerWeap,
		PlayerText:KillMsg_killerHlth,
		PlayerText:KillMsg_killerScor,
		PlayerText:KillMsg_killerKill,
		PlayerText:KillMsg_killerDeat,
		PlayerText:KillMsg_killerGear,
		PlayerText:KillMsg_dTitleWeap,
		PlayerText:KillMsg_dTitleHlth,
		PlayerText:KillMsg_dTitleScor,
		PlayerText:KillMsg_dTitleKill,
		PlayerText:KillMsg_dTitleDeat,
		PlayerText:KillMsg_dTitleGear,

		PlayerText:dm_GraMenu_Back,
		PlayerText:dm_GraMenu_Left,
		PlayerText:dm_GraMenu_Right,
		PlayerText:dm_GraMenu_LeftOpt,
		PlayerText:dm_GraMenu_MidOpt,
		PlayerText:dm_GraMenu_RightOpt,
		PlayerText:dm_GraMenu_Accept,

		PlayerBar:XPbar,
		PlayerBar:TankHeatBar,
		PlayerBar:BleedoutBar;

//======================Rank Variables

new
	RankNames[MAX_RANK][22]=
	{
		"FNG",
		"Private",
		"Private First Class",
		"Specialist",
		"Corporal",
		"Sergeant",
		"Staff Sergeant",
		"Sergeant First Flass",
		"Master Sergeant",
		"First Sergeant",
		"Sergeant Major",
		"Command Sergeant",
		"Second Lieutenant",
		"First Lieutenant",
		"Captain",
		"Major",
		"Lieutenant Colonel",
		"Colonel",
		"Brigadier General",
		"Major General",
		"Lieutenant General",
		"General",
		"General of the Army",
		"Chuck Norris"
	},
	RankColours[MAX_RANK]=
	{
		0x80461BFF,
		0x854C19FF,
		0x8A5218FF,
		0x8F5817FF,
		0x955E16FF,
		0x9A6415FF,
		0x9F6A14FF,
		0xA57013FF,
		0xAA7612FF,
		0xAF7C10FF,
		0xB4820FFF,
		0xBA880EFF,
		0xBF8E0DFF,
		0xC4940CFF,
		0xCA9A0BFF,
		0xCFA00AFF,
		0xD4A609FF,
		0xD9AC07FF,
		0xDFB206FF,
		0xE4B805FF,
		0xE9BE04FF,
		0xEFC403FF,
		0xF4CA02FF,
		0xFFD700FF
	},
	RankAbv[MAX_RANK][5] =
	{
		"FNG",
		"PVT",
		"PVT1",
		"SPC",
		"CPL",
		"SGT",
		"SSGT",
		"SFC",
		"MSG",
		"1SG",
		"SGM",
		"CSM",
		"2LT",
		"1LT",
		"CPT",
		"MAJ",
		"LTC",
		"COL",
		"BG",
		"MG",
		"LTG",
		"GEN",
		"GA",
		"CHK"
	},
	RequiredExp[MAX_RANK] =
	{
		0,		// 1
		200,	// 2
		550,	// 3
		800,	// 4
		1200,	// 5
		2000,	// 6
		4400,	// 7
		6800,	// 8
		8500,	// 9
		10900,	// 10
		13600,	// 11
		16000,	// 12
		21400,	// 13
		25800,	// 14
		300000,	// 15
		0,	// 16
		0,	// 17
		0,	// 18
		0,	// 19
		0,	// 20
		0,	// 21
		0,	// 22
		0,	// 23
		0	// 24
	};


//======================Skin Arrays

	new const
		KitSkins[2][MAX_KIT]=
		{
			{
				124,
				126,
				127,
				125,
				111
			},
			{
				30,
				247,
				100,
				248,
				242
			}
		};
		/*
		FFASkins[20]=
		{
		    122,
		    117,
		    118,
		    120,
		    247,
		    248,
		    254,
		    111,
		    112,
		    113,
		    124,
		    125,
		    126,
		    127,
		    285,
		    287,
		    165,
		    166,
		    179
		};
		*/

//======================Mines

	new
		Mine				[MAX_MINES],
		Float:MinePos		[MAX_MINES][3],
		MineOwner			[MAX_MINES],
		bool:MineExploded	[MAX_MINES],
		MineProx			[MAX_MINES],
		MineLoc				[MAX_MINES],
		MineID_Used         [MAX_MINES];

	stock CreateMine(playerid, Float:x, Float:y, Float:z)
	{
		new ID;
		while(MineID_Used[ID])ID++;
		Mine[ID] = CreateDynamicObject(1252, x, y, z, 90, 0, 0);
		MinePos[ID][0] = x;
		MinePos[ID][1] = y;
		MinePos[ID][2] = z;
		MineOwner[ID] = playerid;
		MineExploded[ID] = false;
		MineProx[ID]=CreateDynamicSphere(x, y, z, MAX_MINE_RAD);
		MineLoc[ID]=CreateDynamicSphere(x, y, z, MAX_MINE_RAD*3);
		MineID_Used[ID]=true;
	}
	stock ExplodeMine(mineID)
	{
	    PlayerLoop(i)if(IsPlayerInRangeOfPoint(i, MAX_MINE_RAD, MinePos[mineID][0], MinePos[mineID][1], MinePos[mineID][2]))dm_SetPlayerHP(i, 0.0, MineOwner[mineID], 39);
		CreateExplosion(MinePos[mineID][0], MinePos[mineID][1], MinePos[mineID][2], 12, MAX_MINE_RAD);
		DestroyDynamicObject(Mine[mineID]);
		MineExploded[mineID] = true;
		MineOwner[mineID] = -1;
		DestroyDynamicArea(MineProx[mineID]);
		DestroyDynamicArea(MineLoc[mineID]);
		MineID_Used[mineID]=false;
	}

//======================dm_Team Functions

stock GetPlayersInTeam(teamid)
{
	new count;
	PlayerLoop(i)if(pTeam(i)==teamid)count++;
	return count;
}

MsgDeathmatch(colour, text[])
{
    PlayerLoop(i)
		if(bPlayerGameSettings[i] & InDM)
			Msg(i, colour, text);

    return 1;
}

SetPlayerToTeam(playerid, team)
{
	SetPlayerTeam(playerid, 0);
	pTeam(playerid) = team;
	SetPlayerTeamSkin(playerid);
}
SetPlayerTeamSkin(playerid)
{
    new team = pTeam(playerid);

	if(dm_Preset != DM_BAREBONES && pGear(playerid)==g_Disguise)
		team =! team;

	SetPlayerSkin(playerid, KitSkins[team][pKit(playerid)]);
}
MsgTeam(team, colour, string[])
{
	if(strlen(string) > 127)
	{
		new
			string2[128],
			splitpos;

		for(new c = 128; c>0; c--)
		{
			if(string[c] == ' ' || string[c] ==  ',' || string[c] ==  '.')
			{
			    splitpos = c;
			    break;
			}
		}

		strcat(string2, string[splitpos]);
		string[splitpos] = EOS;

	    PlayerLoop(i)
	    {
	        if(pTeam(i) != team)
				continue;

			SendClientMessage(i, colour, string);
			SendClientMessage(i, colour, string2);
		}
	}
	else
	{
	    PlayerLoop(i)
	    {
	        if(pTeam(i) != team)
				continue;

			SendClientMessage(i, colour, string);
		}
	}

	return 1;
}


//======================Enf Match Stats Functions

	enum e_leaderboard_data
	{
		lb_ID,
		lb_Exp,
		lb_Kills,
		lb_Deaths
	}
	new dm_Leaderboard[MAX_PLAYERS][e_leaderboard_data];

	MostExp()
	{
		SortDeepArray(dm_Leaderboard, lb_Exp, .order = SORT_DESC);
		return dm_Leaderboard[0][lb_ID];
	}
	MostKills()
	{
		SortDeepArray(dm_Leaderboard, lb_Kills, .order = SORT_DESC);
		return dm_Leaderboard[0][lb_ID];
	}
	MostDeaths()
	{
		SortDeepArray(dm_Leaderboard, lb_Deaths, .order = SORT_DESC);
		return dm_Leaderboard[0][lb_ID];
	}

//======================Player XP Notification

new
		oldamount	[MAX_PLAYERS],
		oldmsg		[MAX_PLAYERS][MAX_XPMSG_LEN],
		xpMsgLines	[MAX_PLAYERS],
Timer:	XPtimer		[MAX_PLAYERS];

GiveXP(playerid, amount, text[])
{
	new
		szTextString[MAX_XPMSG_LEN],
		szExpString[MAX_XPINT_LEN],
		szFinalString[MAX_XPMSG_LEN];

	PlayerTextDrawHide(playerid, XPtext);
	xpMsgLines[playerid]++;

	if(bPlayerDeathmatchSettings[playerid] & dm_ExpNotif)
	{
		format(szTextString, MAX_XPMSG_LEN, "~b~%d ~y~%s~n~%s", amount, text, oldmsg[playerid]);
		if(xpMsgLines[playerid] > MAX_XPMSG_LINE)
		{
			new nlPos, len=strlen(szTextString);
			for(nlPos=len;nlPos>=0;nlPos--)if(szTextString[nlPos]=='~')break;
			for(new x=nlPos-2;x<len;x++)szTextString[x]=0;
			xpMsgLines[playerid]--;
		}
		format(szExpString, MAX_XPINT_LEN, "%dXP", oldamount[playerid]+amount);
		format(oldmsg[playerid], MAX_XPMSG_LEN, szTextString);
		stop XPtimer[playerid];
	}
	else
	{
		format(szTextString, MAX_XPMSG_LEN, "~b~%d ~y~%s", amount, text);
		format(szExpString, MAX_XPINT_LEN, "%dXP", amount);
		format(oldmsg[playerid], MAX_XPMSG_LEN, szTextString);
	}
	bitTrue(bPlayerDeathmatchSettings[playerid], dm_ExpNotif);
	oldamount[playerid]+=amount;
	format(szFinalString, MAX_XPMSG_LEN, "~b~%s~n~%s", szExpString, szTextString);

	PlayerTextDrawSetString(playerid, XPtext, szFinalString);
	PlayerTextDrawShow(playerid, XPtext);
	XPtimer[playerid] = defer ExpMsgDestroy(playerid);

	dm_PlayerData[playerid][dm_RoundExp] += amount;
	pExp(playerid) += amount;

	if(RankCheck(playerid))
		MsgF(playerid, LGREEN, " >  You Just Ranked Up! You are now rank %d", pRank(playerid));

	UpdatePlayerXPBar(playerid);
}
timer ExpMsgDestroy[EXP_TEXT_HIDE](playerid)
{
	PlayerTextDrawHide(playerid, XPtext);
	oldamount[playerid]=0;
	oldmsg[playerid][0]=EOS;
	xpMsgLines[playerid]=0;
	bitFalse(bPlayerDeathmatchSettings[playerid], dm_ExpNotif);
	if(dm_PlayerData[playerid][dm_Combo]>0)dm_PlayerData[playerid][dm_Combo]=0;
}

//======================Player Award Notification

#define MAX_AWD_QUEUE 8

new
	aw_notifQueue[MAX_PLAYERS][MAX_AWD_QUEUE][MAX_AWARD_NAME];

ShowAwardNotif(playerid, text[], icon[]="LD_NONE:ship3")
{
	if(bPlayerDeathmatchSettings[playerid] & dm_AwardNotif)
	{
	    new iLoop;
	    while(aw_notifQueue[playerid][iLoop][0] != 0 && iLoop < MAX_AWD_QUEUE)iLoop++;
		strcpy(aw_notifQueue[playerid][iLoop], text);
		return 0;
	}
	else
	{
	    new tmpStr[18+MAX_AWARD_NAME+1];
	    format(tmpStr, 128, "Award Unlocked:~n~%s", text);
		PlayerTextDrawShow(playerid, AwdMsg_bg);
		PlayerTextDrawShow(playerid, AwdMsg_lCurve);
		PlayerTextDrawShow(playerid, AwdMsg_rCurve);
		PlayerTextDrawShow(playerid, AwdMsg_iconBox);
		PlayerTextDrawShow(playerid, AwdMsg_textBox);
		PlayerTextDrawShow(playerid, AwdMsg_iconMain);

		PlayerTextDrawSetString(playerid, AwdMsg_textBox, tmpStr);
		PlayerTextDrawSetString(playerid, AwdMsg_iconMain, icon);

		t:bPlayerDeathmatchSettings[playerid]<dm_AwardNotif>;
		defer AwdNotifDestroy(playerid);
		return 1;
	}
}
timer AwdNotifDestroy[AWD_TEXT_HIDE](playerid)
{
	PlayerTextDrawHide(playerid, AwdMsg_bg);
	PlayerTextDrawHide(playerid, AwdMsg_lCurve);
	PlayerTextDrawHide(playerid, AwdMsg_rCurve);
	PlayerTextDrawHide(playerid, AwdMsg_iconBox);
	PlayerTextDrawHide(playerid, AwdMsg_textBox);
	PlayerTextDrawHide(playerid, AwdMsg_iconMain);
	f:bPlayerDeathmatchSettings[playerid]<dm_AwardNotif>;

	for(new i;i<MAX_AWD_QUEUE;i++)
	{
		if(aw_notifQueue[playerid][i][0] != 0)
		{
			ShowAwardNotif(playerid, aw_notifQueue[playerid][i]);
			aw_notifQueue[playerid][i][0] = 0;
		}
	}
}

//======================Update XP Text Draw Bar for player

stock UpdatePlayerXPBar(playerid)
{
	new str[4];

	if(pRank(playerid) >= (MAX_RANK-1))
	{
		SetPlayerProgressBarValue(playerid, XPbar, 100);
		SetPlayerProgressBarMaxValue(playerid, XPbar, 100);
		UpdatePlayerProgressBar(playerid, XPbar);

		valstr(str, MAX_RANK);
		PlayerTextDrawSetString(playerid, RankTextCurr, str);
		PlayerTextDrawShow(playerid, RankTextCurr);
		PlayerTextDrawHide(playerid, RankTextNext);
			
		return 0;
	}

	SetPlayerProgressBarValue(playerid, XPbar, pExp(playerid)-RequiredExp[pRank(playerid)]);
	SetPlayerProgressBarMaxValue(playerid, XPbar, RequiredExp[pRank(playerid)+1]-RequiredExp[pRank(playerid)]);
	UpdatePlayerProgressBar(playerid, XPbar);
		
	valstr(str, pRank(playerid)+1);
	PlayerTextDrawSetString(playerid, RankTextCurr, str);
	PlayerTextDrawShow(playerid, RankTextCurr);

	valstr(str, pRank(playerid)+2);
	PlayerTextDrawSetString(playerid, RankTextNext, str);
	PlayerTextDrawShow(playerid, RankTextNext);
		
	return 1;
}

//======================PlayersInLobby and PlayersInDM functions

stock GetPlayersInLobby()
{
	new count;
	PlayerLoop(i)
		if(bPlayerDeathmatchSettings[i] & dm_InLobby)count++;

	return count;
}
stock GetPlayersInDM()
{
	new count;
	PlayerLoop(i)
		if(bPlayerGameSettings[i] & InDM)count++;

	return count;
}

//======================Match Timer Stuff

	#define timers 100
	new
		Tsec,
		Tmin,
		TimerActive;

	MatchTime(minutes, seconds)
	{
		Tmin = minutes;
		Tsec = seconds;
		TimerActive=true;
		return 1;
	}
	StopMatchTime()
	{
		TimerActive=false;
	 	TextDrawHideForAll(MatchTimeCounter);
	}
	PauseMatchTime()TimerActive=false;
	ContinueMatchTime()TimerActive=true;
	TimerSet()
	{
		new string[6], M[3], S[3];
		if(Tsec >= 1) Tsec--;
		if(Tsec < 10) format(S, 3, "0%d", Tsec);
		else format(S, 3, "%d", Tsec);
		if(Tmin < 10) format(M, 3, "0%d", Tmin);
		else format(M, 3, "%d", Tmin);
		if(Tsec <= 0 && Tmin != 0) Tsec = 59, Tmin--;
		else if(Tmin == 0 && Tsec == 0)
		{
			TimerActive=false;
			EndMatchTime();
		}
		format(string, 6, "%s:%s",M, S);
		TextDrawSetString(MatchTimeCounter, string);
		return 1;
	}
	EndMatchTime()
	{
	 	TextDrawHideForAll(MatchTimeCounter);
		Tmin = 1000;
		Tsec = 1000;
		for(new i;i<2;i++)if(dm_TeamScore[score_Kills][i] > dm_TeamScore[score_Kills][!i])return EndRound(i);

	    PlayerLoop(i)if(bPlayerGameSettings[i]&InDM)
	    {
	        dm_Preset = DM_SUDDENDEATH;
			Msg(i, YELLOW, " >  Match scores are a "#C_BLUE"tie!"#C_YELLOW" First kill wins the round!");
			DMspawn(i);
	    }
	 	return 1;
	}

//======================Player Awards

enum WEP_TYPE_ENUM
{
	wt_Mel,
	wt_Sec,
	wt_Pri,
	wt_Eqp
}
enum WEP_GROUP_ENUM
{
	wg_Melee,
	wg_Pistol,
	wg_Shotgun,
	wg_Smg,
	wg_AssRif,
	wg_Rifle,
	wg_Heavy
}
enum OBJ_TYPE_ENUM
{
	st_AdCaps,
	st_CtfCaps,
	st_CqsCaps
}
enum SUP_TYPE_ENUM
{
	st_SupAmmo,
	st_SupHeal,
	st_SupRevv,
	st_SupRepr
}
enum KTP_TYPE_ENUM
{
	st_KtAdDefKill,
	st_KtAdAttKill,
	st_KtCtfDefKill,
	st_KtCtfAttKill,
	st_KtCqsDefKill,
	st_KtCqsAttKill,
	st_KtAssist,
	st_KtAvenge,
	st_KtRevenge,
	st_KtSaviour
}

enum STAT_ENUM
{
	st_Wep[MAX_WEAPON],
	st_Wtp[WEP_TYPE_ENUM],
	st_Wgp[WEP_GROUP_ENUM],
	st_Obj[OBJ_TYPE_ENUM],
	st_Sup[SUP_TYPE_ENUM],
	st_Ktp[KTP_TYPE_ENUM]
}
enum AWARD_DATA_ENUM
{
	aw_Name[MAX_AWARD_NAME],
	aw_Type,
	aw_Grp,
	aw_Req
}
enum // Totals
{
	at_Wep = MAX_AWT_WEP,
	at_Typ = MAX_AWT_WEP+MAX_AWT_TYP,
	at_Grp = MAX_AWT_WEP+MAX_AWT_TYP+MAX_AWT_GRP,
	at_Obj = MAX_AWT_WEP+MAX_AWT_TYP+MAX_AWT_GRP+MAX_AWT_OBJ,
	at_Sup = MAX_AWT_WEP+MAX_AWT_TYP+MAX_AWT_GRP+MAX_AWT_OBJ+MAX_AWT_SUP,
	at_Ktp = MAX_AWT_WEP+MAX_AWT_TYP+MAX_AWT_GRP+MAX_AWT_OBJ+MAX_AWT_SUP+MAX_AWT_KTP
}

/*

44 Total

	18 weps
	4 types
	7 groups
	3 objective
	4 support
	10 kill type

*/
enum AW_TYPE_ENUM
{
	wp_Unarmed,		// wp0
	wp_Knife,		// wp1
	wp_Colt45,		// wp2
	wp_Colt45sd,	// wp3
	wp_Deserteagle,	// wp4
	wp_Shotgun,		// wp5
	wp_Sawnoff,		// wp6
	wp_Spas12,		// wp7
	wp_Mac10,		// wp8
	wp_Mp5,			// wp9
	wp_Tec9,		// wp10
	wp_Ak47,		// wp11
	wp_M4,			// wp12
	wp_Rifle,		// wp13
	wp_Sniper,		// wp14
	wp_Rpg,			// wp15
	wp_Flamer,		// wp16
	wp_Minigun,		// wp17

	wt_Hand,		// wt0
	wt_Sidearm,     // wt1
	wt_Mainarm,     // wt2
	wt_Equip,       // wt3

	wg_Melee,       // wg0
	wg_Pistol,		// wg1
	wg_Shotgun,		// wg2
	wg_Smg,			// wg3
	wg_AssRif,		// wg4
	wg_Rifle,		// wg5
	wg_Heavy,		// wg6

	obj_ctfCap,		// flag captures (ctf)
	obj_cqsCap,		// cp captures (cqst)
	obj_adCap,		// a/d captures (a/d)

	sup_Ammo,		// ammo boxes used by others
	sup_Meds,		// health boxes used by others
	sup_Heal,		// friendly revives
	sup_Repr,		// friendly repairs

	kt_AdDef,		// base defence kill
	kt_AdAtt,		// base attack kill
	kt_CtfDef,		// kill someone while you have flag
	kt_CtfAtt,		// kill player with the flag
	kt_CqsDef,		// kill someone while they are capturing
	kt_CqsAtt,		// kill someone while you are capturing
	kt_Ast,			// assists
	kt_Avg,			// avenges
	kt_Rev,      	// revenges
	kt_Sav			// life-savers
}

new
    gTotalAwards,
    gTotalAwardsOfGroup[MAX_AWARD_GROUP],
	pStatCount[MAX_PLAYERS][STAT_ENUM],
	pAwardData[MAX_PLAYERS][MAX_AWARD_GROUP][MAX_AWARD],
	AwardData[MAX_AWARD][AWARD_DATA_ENUM],
	AwardTag[MAX_AWARD_GROUP][MAX_AWARD_TAG]=
	{
		"wp",		// MAX_AWT_WEP	wp0 - wp17
		"wt",		// MAX_AWT_TYP	wt0 - wt3
		"wg",		// MAX_AWT_GRP	wg0 - wg6
		"obj",      // MAX_AWT_OBJ
		"sup",      // MAX_AWT_SUP
		"kt"        // MAX_AWT_KTP
	},
	AwardSubTag[3][10][MAX_AWARD_TAG]=
	{
		{
			"Ad", // 3
			"Cf",
			"Cq",
			"<NULL>","<NULL>","<NULL>","<NULL>","<NULL>","<NULL>","<NULL>"
		},
		{
			"Ammo", // 4
			"Meds",
			"Heal",
			"Repr",
			"<NULL>","<NULL>","<NULL>","<NULL>","<NULL>","<NULL>"
		},
		{
			"AdDk", // 10
			"AdAk",
			"CfDk",
			"CfAk",
			"CqDk",
			"CqAk",
			"Ast",
			"Avg",
			"Rev",
			"Sav"
		}
	};



LoadAwards()
{
	new
		File:tmpFile = fopen(DM_AWARD_FILE, io_read),
		line[128],
		tmpAwdTag[MAX_AWARD_TAG],
		tmpAwdType,
		tmpAwdReq,
		tmpAwdName[MAX_AWARD_NAME],

		idx;

	while(fread(tmpFile, line))
	{
	    if(strlen(line)<5)continue;
		if(!sscanf(line, "p<,>s[" #MAX_AWARD_TAG "]ds[" #MAX_AWARD_NAME "]", tmpAwdTag, tmpAwdReq, tmpAwdName))
		{
			tmpAwdName[ strlen(tmpAwdName)-2 ] = EOS;

			for(new g;g<MAX_AWARD_GROUP;g++)
			{
				if(strfind(tmpAwdTag, AwardTag[g]) != -1)
				{
				    if(g < 3)
						tmpAwdType = strval(tmpAwdTag[ strlen(AwardTag[g]) ]);
				    else
				    {
				        for(new s;s<10;s++)
				        {
							new len = strlen(AwardTag[g]);
							if(!strcmp(tmpAwdTag[len], AwardSubTag[g-3][s]))
								tmpAwdType = s;
						}
					}
					AwardData[idx][aw_Name] = tmpAwdName;
					AwardData[idx][aw_Type] = tmpAwdType;
					AwardData[idx][aw_Req] = tmpAwdReq;
					AwardData[idx][aw_Grp] = g;
					gTotalAwardsOfGroup[g]++;
					idx++;
				}
			}

		}
		else print("ERROR: Loading Awards");
	}
	gTotalAwards = idx;
	return 1;

}



AwardDataUpdate(playerid, wp=0, wg=0, wt=0, obj=0, sup=0, ktp=0)
{
	for(new idx; idx<gTotalAwards; idx++)
	{
	    if(wp)
	    {
	        if(AwardData[idx][aw_Grp] == 0)
	        {
				for(new t;t<MAX_AWT_WEP;t++)
			        if(AwardData[idx][aw_Type] == t)
						if( pStatCount[playerid][st_Wep][t] >= AwardData[idx][aw_Req])
							GivePlayerAward(playerid, idx);
			}
	    }
	    if(wg)
	    {
	        if(AwardData[idx][aw_Grp] == 1)
	        {
		        for(new t;t<MAX_AWT_TYP;t++)
			        if(AwardData[idx][aw_Type] == t)
				        if( pStatCount[playerid][st_Wtp][WEP_TYPE_ENUM:t] >= AwardData[idx][aw_Req])
				            GivePlayerAward(playerid, idx);
			}
	    }
	    if(wt)
	    {
	        if(AwardData[idx][aw_Grp] == 2)
	        {
		        for(new t;t<MAX_AWT_GRP;t++)
			        if(AwardData[idx][aw_Type] == t)
				        if( pStatCount[playerid][st_Wgp][WEP_GROUP_ENUM:t] >= AwardData[idx][aw_Req])
				            GivePlayerAward(playerid, idx);
			}
		}
		if(obj)
		{
			if(AwardData[idx][aw_Grp] == 3)
				for(new t;t<MAX_AWT_OBJ;t++)
					if(AwardData[idx][aw_Type] == t)
						if( pStatCount[playerid][st_Obj][OBJ_TYPE_ENUM:t] >= AwardData[idx][aw_Req])
							GivePlayerAward(playerid, idx);
	    }
	    if(sup)
	    {
	        if(AwardData[idx][aw_Grp] == 4)
	        {
		        for(new t;t<MAX_AWT_SUP;t++)
			        if(AwardData[idx][aw_Type] == t)
				        if( pStatCount[playerid][st_Sup][SUP_TYPE_ENUM:t] >= AwardData[idx][aw_Req])
				            GivePlayerAward(playerid, idx);
			}
	    }
	    if(ktp)
	    {
	        if(AwardData[idx][aw_Grp] == 5)
	        {
		        for(new t;t<MAX_AWT_KTP;t++)
			        if(AwardData[idx][aw_Type] == t)
				        if( pStatCount[playerid][st_Ktp][KTP_TYPE_ENUM:t] >= AwardData[idx][aw_Req])
				            GivePlayerAward(playerid, idx);
			}
	    }
	}

}
GivePlayerAward(playerid, id)
{
    ShowAwardNotif(playerid, AwardData[id][aw_Name]);
    printf("Saving award: grp: %d id: %d", AwardData[id][aw_Grp], id);
    pAwardData[playerid][ AwardData[id][aw_Grp] ][id]++;
}




enum E_GRAPHIC_DATA
{
	grFile[8],
	grName[16]
}
new GraphicData[MAX_GRAPHIC][E_GRAPHIC_DATA]=
{
	{"5gun",	"Revolver"},
	{"8gun",	"Kalashnikov"},
	{"9gun2",	"Pistol"},
	{"9gun",	"Uzi"},
	{"9bullt",	"Bullet"},
	{"9homby",	"Dagger Heart"},
	{"12dager", "Dagger"},
	{"4spider",	"Spider"},
	{"9rasta",	"Rasta"},
	{"4weed",	"Weed 1"},
	{"10weed",	"Weed 2"},
	{"8poker",	"Poker"},
	{"11dice2", "Dice 1"},
	{"11dice",	"Dice 2"},
	{"10og",	"OG"},
	{"11jail",	"Jail"},
	{"11ggift", "Gods Gift"},
	{"12myfac", "Mayan Face"},
	{"12maybr", "Mayan Bird"},
	{"4rip",	"R.I.P."},
	{"5cross3", "Cross 1"},
	{"5cross2", "Cross 2"},
	{"5cross",	"Cross 3"},
	{"7cross3",	"Cross 4"},
	{"7cross2",	"Cross 5"},
	{"7cross",	"Cross 6"},
	{"7mary",	"Mary"},
	{"6crown",	"Crown 1"},
	{"9crown",	"Crown 2"},
	{"6clown",	"Clown"},
	{"6aztec",	"Aztec"},
	{"6africa",	"Africa"},
	{"12cross", "Cross"},
	{"12bndit", "Bandit"},
	{"12angel", "Angel"},
	{"8santos",	"Los Santos"},
	{"8sa3",	"San Fierro"},
	{"8sa2",	"Andreas"},
	{"8sa",		"Grove"},
	{"10ls5",	"LS 1"},
	{"10ls4",	"LS 2"},
	{"10ls3",	"LS 3"},
	{"10ls2",	"LS 4"},
	{"10ls",	"LS 5"},
	{"11grove", "Grove 1"},
	{"11grov3", "Grove 2"},
	{"11grov2", "Grove 3"}
},
dm_GraMenuCurrent[MAX_PLAYERS];










GetWeaponType(id)
{
	switch(id)
	{
		case 2..9, 14, 15:return 0;					// Melee
		case 22, 23, 24, 26, 28, 32:return 1;		// Secondary
		case 25, 27, 29, 30, 31, 34:return 2;		// Primary
		case 16, 18, 35, 36, 37, 38, 39:return 3;	// Equipment
		default:return -1;
	}
	return -1;
}
GetWeaponGroup(id)
{
	switch(id)
	{
		case 0, 4:return 0;		// Melee
		case 22..24:return 1;	// Pistol
		case 25..27:return 2;	// Shotgun
		case 28, 32:return 3;	// SMG
		case 30, 31:return 4;	// Assault Rifle
		case 33, 34:return 5;	// Rifle
		case 35..38:return 6;	// Heavy
		default:return -1;
	}
	return -1;
}

HasWeaponType(playerid, type)
{
	new W, A;
	for(new w;w<13;w++)
	{
		GetPlayerWeaponData(playerid, w, W, A);
	    if(GetWeaponType(W) == type && A>0)return W;
	}
	return -1;
}


//======================Libraries of Seperate Scripts

#include "../scripts/Deathmatch/SupplyCrate.pwn"
#include "../scripts/Deathmatch/KitEquip.pwn"
#include "../scripts/Deathmatch/Awareness.pwn"


#include "../scripts/Deathmatch/gm0_TDM.pwn"
#include "../scripts/Deathmatch/gm1_AD.pwn"
#include "../scripts/Deathmatch/gm2_CTF.pwn"
#include "../scripts/Deathmatch/gm3_CQST.pwn"





IsPlayerInGame(playerid)
{
	if(	!(bPlayerDeathmatchSettings[playerid]&dm_InLobby) &&
		!(bPlayerDeathmatchSettings[playerid]&dm_Ready) &&
		bPlayerGameSettings[playerid] & InDM &&
		bPlayerGameSettings[playerid] & Spawned )return 1;

	return 0;
}

task dm_Update[1000]()
{
	if(!(bServerGlobalSettings & dm_InProgress))
		return 0;

	if(GetPlayersInDM()==0 && GetPlayersInLobby()==0)EndDeathmatch();
	if(bServerGlobalSettings & dm_Started)
	{
		dm_SpawnCount--;
		new str[15];
		format(str, 15, "Spawning in %d", dm_SpawnCount);
		TextDrawSetString(SpawnCount, str);
		if(dm_SpawnCount<=0)
		{
			PlayerLoop(i)if((bPlayerDeathmatchSettings[i]&dm_Ready)&&(bServerGlobalSettings&dm_Started))DMspawn(i);
			dm_SpawnCount=MAX_SPAWN_COUNT;
		}
	}
	if(dm_Mode == DM_MODE_AD)
	{
		if(PointCT)AD_CaptureUpdate(capturer);
		else
		{
		    if(ADfill>0)
			{
				ADfill--;
				MoveADFlag();
			}
		}
	}
	if(dm_Mode == DM_MODE_CQS)
	{
		for(new cp;cp<MAX_CP;cp++)
		{
			if(CPtimer[cp])CP_CaptureUpdate(FirstToCapture[cp], cp);
			else if(CPowner[cp] == -1)
			{
				if(CPfill[cp] > 0)
				{
					CPfill[cp]--;
					MoveCPFlag(cp);
				}
			}
			else
			{
				if(CPfill[cp] < REQ_CAPTURE_POINTS)
				{
					CPfill[cp]++;
					MoveCPFlag(cp);
				}
			}
		}
	}
	if(bServerGlobalSettings&dm_LobbyCounting)UpdateQueueCountDown();
	if(TimerActive)TimerSet();

	return 1;
}

script_Deathmatch_PlayerUpdate(playerid)
{
	if( !(bPlayerGameSettings[playerid]&Spawned) )return 0;
	
	if( !(bPlayerDeathmatchSettings[playerid]&dm_Bleeding) && (dm_Preset != DM_HARDCORE) && tickcount()-tick_LastDamg[playerid] > REGEN_TICK)
	{
	    if(gPlayerHP[playerid]<dm_GlobalMaxHP)
	    {
			if(gPlayerHP[playerid]>=(dm_GlobalMaxHP/2))dm_SetPlayerHP(playerid, (gPlayerHP[playerid]+(dm_GlobalMaxHP/(MAX_HEALTH))));
			if(gPlayerHP[playerid]<=(dm_GlobalMaxHP/2))dm_SetPlayerHP(playerid, (gPlayerHP[playerid]+(dm_GlobalMaxHP/(MAX_HEALTH/3))));
			if(gPlayerHP[playerid]<=(dm_GlobalMaxHP/5))GameTextForPlayer(playerid, "~n~~n~~n~~r~(YOU ARE HURT)~n~(GET TO COVER!)", 1000, 5);
		}
		else if(gPlayerHP[playerid]>=dm_GlobalMaxHP)
		{
			flag_ShotBy[playerid] = -1;
			dm_SetPlayerHP(playerid, dm_GlobalMaxHP);
		}
	}
//	UpdateHealthBar(playerid);

	if(bPlayerDeathmatchSettings[playerid] & dm_Spotted)
		if(tickcount()-tick_Spotted[playerid] >= MAX_SPOT_TIME)UnSpotPlayer(playerid);


	return 1;
}
timer GuiUpdate[100](playerid)
{
	if(!(bPlayerGameSettings[playerid] & InDM))return 0;
	if(bPlayerDeathmatchSettings[playerid] & dm_Bleeding)
	{
	    new tmpAnim = GetPlayerAnimationIndex(playerid);
		if( (tmpAnim!=1207) && (tmpAnim!=1155) && (tmpAnim!=1150) )ApplyAnimation(playerid, "ped", "KO_shot_stom", 1, 0, 0, 0, 1, 0, 1);
		dm_BleedPoints[playerid]--;

		SetPlayerProgressBarValue(playerid, BleedoutBar, dm_BleedPoints[playerid]);
		UpdatePlayerProgressBar(playerid, BleedoutBar);

		if(dm_BleedPoints[playerid]<=0)
		{
			ExitBleedOut(playerid);
		    if(dm_BleedAttacker[playerid] == INVALID_PLAYER_ID)
			{
				dm_OnDeath(playerid);
			}
		    else
			{
				script_Deathmatch_OnPlayerKill(playerid, dm_BleedAttacker[playerid], dm_BleedReason[playerid]);
			}
		}
	}
	return 1;
}
script_Deathmatch_PlayerShoot(playerid)
{
	t:bPlayerDeathmatchSettings[playerid]<dm_Shooting>;

	for(new i=0;i<MAX_MINES;i++)
	{
		if(IsPlayerAimingAt(playerid, MinePos[i][0], MinePos[i][1], MinePos[i][2]+0.1, 0.6) && MineID_Used[i])
			ExplodeMine(i);
	}
}
script_Deathmatch_hitPlayer(playerid, targetid, head, weapon)
{
	if( dm_Preset != DM_HARDCORE && (pTeam(playerid)==pTeam(targetid)) ) return 1;

	if(bPlayerDeathmatchSettings[targetid]&dm_Bleeding)
	{
	    flag_ShotBy[targetid]=playerid;
		dm_BleedPoints[targetid]-=20;
		return 1;
	}

	new
		Float:HpLoss,
		Float:p_pos[3],
		Float:t_pos[3],
		Float:trgDist = GetPlayerDist3D(playerid, targetid);

	GetPlayerPos(playerid, p_pos[0], p_pos[1], p_pos[2]);
	GetPlayerPos(targetid, t_pos[0], t_pos[1], t_pos[2]);

	ShowHitMarker(playerid, weapon);
	if(trgDist < WepData[weapon][MinDis]) HpLoss = WepData[weapon][MaxDam];
	if(trgDist > WepData[weapon][MaxDis]) HpLoss = WepData[weapon][MinDam];
	else HpLoss = ((WepData[weapon][MinDam]-WepData[weapon][MaxDam])/(WepData[weapon][MaxDis]-WepData[weapon][MinDis])) * (trgDist-WepData[weapon][MaxDis]) + WepData[weapon][MinDam];


	flag_ShotBy[targetid]=playerid;
	flag_LastShot[playerid]=playerid;
	tick_LastShot[playerid]=tickcount();

	if( (trgDist<=1.5) && IsPlayerFacingPlayer(playerid, targetid, 60) && IsPlayerBehindPlayer(playerid, targetid, 10) )HpLoss+=frandom( (dm_GlobalMaxHP*0.5), dm_GlobalMaxHP);
    if(head)HpLoss*=1.5;
	if(dm_Preset != DM_BAREBONES)
	{
    	if(pGear(playerid) == g_ProxDet)
			GameTextForPlayer(targetid, "~r~Warning ~n~-~n~ Shots Fired", 1000, 5);

	    if(pGear(playerid) == g_G12)
	        if( (weapon == WEAPON_SPAS12 || weapon==WEAPON_SHOTGUN) && (trgDist <= 10.0) )
				HpLoss *= 1.1;

		if(pGear(playerid) == g_FMJ)
			HpLoss *= 1.1;
	}
    if((bPlayerDeathmatchSettings[targetid]&dm_PlayingDead) || (bPlayerDeathmatchSettings[targetid]&dm_Bleeding))HpLoss=dm_GlobalMaxHP;


	dm_SetPlayerHP(targetid, (gPlayerHP[targetid]-HpLoss), playerid, weapon, head);

	new str[64];

	format(str, 64, "DEATHMATCH~n~Did %.2f Damage", HpLoss);
	ShowMsgBox(playerid, str, 3000);

	format(str, 64, "DEATHMATCH~n~Took %.2f Damage", HpLoss);
	ShowMsgBox(targetid, str, 3000);
	return 1;
}
dm_GivePlayerHP(targetid, Float:amount, playerid=INVALID_PLAYER_ID, weapon=0, head=0, bleed=1)
{
    dm_SetPlayerHP(targetid, gPlayerHP[targetid] - amount, playerid, weapon, head, bleed);
}
dm_SetPlayerHP(targetid, Float:amount, playerid=INVALID_PLAYER_ID, weapon=0, head=0, bleed=1)
{
	if(!(bPlayerGameSettings[targetid]&Spawned))return 0;

	if( (amount <= 0.0) && !(bPlayerDeathmatchSettings[targetid]&dm_Bleeding) )
	{
		if(playerid==INVALID_PLAYER_ID || (targetid == playerid))
		{
			script_Deathmatch_OnPlayerDie(targetid);
		}
		else
		{
			if(!head && bleed)
			{
				EnterBleedout(targetid, playerid, weapon);
			}
			else
			{
				script_Deathmatch_OnPlayerKill(targetid, playerid, weapon, head);
			}
		}
		gPlayerHP[targetid]=0.1;
	}
	else gPlayerHP[targetid]=amount;
	return 1;
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

EnterBleedout(playerid, attacker=INVALID_PLAYER_ID, weapon=0)
{
	static
		Float:cx,
		Float:cy,
		Float:cz,
		Float:px,
		Float:py,
		Float:pz;

	GetPlayerPos(playerid, px, py, pz);
	GetPlayerCameraPos(playerid, cx, cy, cz);

	TogglePlayerControllable(playerid, false);
	ApplyAnimation(playerid, "ped", "KO_shot_stom", 1, 0, 0, 0, 1, 0, 1);
	bitTrue(bPlayerDeathmatchSettings[playerid], dm_Bleeding);
	dm_BleedPoints[playerid]=100;
	dm_BleedAttacker[playerid]=attacker;
	dm_BleedReason[playerid]=weapon;
	dm_BleedTotal++;

	ShowPlayerProgressBar(playerid, BleedoutBar);
	SetPlayerProgressBarMaxValue(playerid, BleedoutBar, 100);
	ShowMsgBox(playerid, "Press ~r~"#TEXT_ACTION_KEY" ~w~to Bleed-Out");
	dm_BleedPrtObj[playerid] = CreateDynamicObject(18706, px, py, pz-2.3, 0.0, 0.0, 0.0, DEATHMATCH_WORLD);

	SetPlayerCameraLookAt(playerid, px, py, pz);
	SetPlayerCameraPos(playerid, cx, cy, cz);

	if(dm_Mode == DM_MODE_AD)
	{
	    if(bPlayerDeathmatchSettings[playerid] & dm_Capturing)
		{
			f:bPlayerDeathmatchSettings[playerid]<dm_Capturing>;

			HideProgressBarForPlayer(playerid, ADbar);
			if(GetPlayersCapturingAD() == 0)
			{
				PointCT=false;
			    ContinueMatchTime();
			}
		}
	}
}
ExitBleedOut(playerid)
{
	HidePlayerProgressBar(playerid, BleedoutBar);
	HideMsgBox(playerid);
	DestroyDynamicObject(dm_BleedPrtObj[playerid]);
	bitFalse(bPlayerDeathmatchSettings[playerid], dm_Bleeding);
	dm_BleedTotal--;
	return 1;
}

script_Deathmatch_OnPlayerDie(playerid)
{
	if(flag_ShotBy[playerid]!=-1)GiveXP(flag_ShotBy[playerid], 3, "assisted suicide");
	GiveXP(playerid, -1, "suicide!");

	dm_OnDeath(playerid);
}
script_Deathmatch_OnPlayerKill(playerid, killerid, reason, head=0)
{
	if( (killerid==INVALID_PLAYER_ID) || !(bPlayerGameSettings[killerid]&InDM) || !(bPlayerGameSettings[playerid]&InDM) )
	{
	    dm_OnDeath(playerid);
	    return 1;
	}

	if(tickcount()-tick_LastKill[killerid]<=500)return 0;

	new
		Float:DPX, Float:DPY, Float:DPZ,
		Float:KPX, Float:KPY, Float:KPZ;

	GetPlayerPos(playerid, DPX, DPY, DPZ);
	GetPlayerPos(killerid, KPX, KPY, KPZ);

	DeathmatchDataUpdate(playerid, killerid);

	SetPlayerCameraPos(playerid, DPX, DPY, DPZ+0.2);
	SetPlayerCameraLookAt(playerid, KPX, KPY, KPZ);

	if(pTeam(killerid) != pTeam(playerid))
	{
	    GiveXP(killerid, 5, "kill");

		dm_TeamScore[score_Kills][pTeam(killerid)]++;

		if(dm_Mode==DM_MODE_AD)if(pTeam(playerid)!=DefendingTeam)dm_TeamScore[score_Tickets][!DefendingTeam]--;
		if(dm_Mode==DM_MODE_CQS)dm_TeamScore[score_Tickets][pTeam(playerid)]--;

		ShowDeathMSG(playerid, killerid, reason);
		KillStatsUpdate(playerid, killerid, reason, head);

		tick_LastKill[killerid]=tickcount();
		tick_LastDeath[playerid]=tickcount();
		flag_LastKill[killerid]=playerid;

		AwardDataUpdate(killerid, .wp=1, .wg=1, .wt=1, .obj=1, .ktp=1);
	}
	else
	{
		dm_PlayerData[killerid][dm_TeamKills]++;
		GiveXP(killerid, -10, "Teamkill");
		dm_SetPlayerHP(killerid, 0.0);
		GivePlayerScore(killerid, -1);
	}
	if(dm_Preset != DM_BAREBONES && pGear(playerid)==g_Surprise)CreateExplosion(DPX, DPY, DPZ, 12, 5.0);
	SendDeathMessage(killerid, playerid, reason);
	UpdatePlayerIconForAll(killerid);

	dm_OnDeath(playerid);
	return 1;
}
dm_OnDeath(playerid)
{
	stop dm_GuiUpdateTimer[playerid];
	stop crt_UpdateTimer[playerid];

	Msg(playerid, YELLOW, "I haven't added the death animation yet! D:");
	TogglePlayerControllable(playerid, false);
	ResetSpectatorTarget(playerid);
	f:bPlayerGameSettings[playerid]<Spawned>;

	crt_CrateUseTick[playerid][0]	= 0;
	crt_CrateUseTick[playerid][1]	= 0;
	crt_CrateUseTick[playerid][2]	= 0;
	flag_ShotBy[playerid]			= -1;
	pStreak(playerid)				= 0;

	DropCurrentWeapon(playerid);

	dm_SetPlayerHP(playerid, 0.1);
	TeamScoreUpdate();
	UpdatePlayerIconForAll(playerid);
	defer JoinLobby(playerid);
}


ShowDeathMSG(playerid, killerid, reason)
{
	new tmpStr[48];

	HideHUD(playerid);

	tmpStr = "LD_TATT:";
	strcat(tmpStr, GraphicData[pGraphic[killerid]][grFile]);
	PlayerTextDrawSetString(playerid, KillMsg_killerIcon, tmpStr);

	format(tmpStr, 48, "~b~%s(%d)~w~%s", RankAbv[pRank(killerid)], pRank(killerid)+1, GetNameGT(killerid));
	PlayerTextDrawSetString(playerid, KillMsg_killerName, tmpStr);

	format(tmpStr, 48, "%s", WepData[reason][WepName]);
	PlayerTextDrawSetString(playerid, KillMsg_killerWeap, tmpStr);

	format(tmpStr, 48, "%02f", gPlayerHP[killerid]);
	PlayerTextDrawSetString(playerid, KillMsg_killerHlth, tmpStr);

	format(tmpStr, 48, "%d", dm_PlayerData[killerid][dm_RoundExp]);
	PlayerTextDrawSetString(playerid, KillMsg_killerScor, tmpStr);

	format(tmpStr, 48, "%d", dm_PlayerData[killerid][dm_RoundKills]);
	PlayerTextDrawSetString(playerid, KillMsg_killerKill, tmpStr);

	format(tmpStr, 48, "%d", dm_PlayerData[killerid][dm_RoundDeaths]);
	PlayerTextDrawSetString(playerid, KillMsg_killerDeat, tmpStr);

	format(tmpStr, 48, "%s", dm_GearNames[pGear(killerid)]);
	PlayerTextDrawSetString(playerid, KillMsg_killerGear, tmpStr);


	PlayerTextDrawShow(playerid, KillMsg_background);
	PlayerTextDrawShow(playerid, KillMsg_killerIcon);
	PlayerTextDrawShow(playerid, KillMsg_killerName);
	PlayerTextDrawShow(playerid, KillMsg_killerWeap);
	PlayerTextDrawShow(playerid, KillMsg_killerHlth);
	PlayerTextDrawShow(playerid, KillMsg_killerScor);
	PlayerTextDrawShow(playerid, KillMsg_killerKill);
	PlayerTextDrawShow(playerid, KillMsg_killerDeat);
	PlayerTextDrawShow(playerid, KillMsg_killerGear);
	PlayerTextDrawShow(playerid, KillMsg_dTitleWeap);
	PlayerTextDrawShow(playerid, KillMsg_dTitleHlth);
	PlayerTextDrawShow(playerid, KillMsg_dTitleScor);
	PlayerTextDrawShow(playerid, KillMsg_dTitleKill);
	PlayerTextDrawShow(playerid, KillMsg_dTitleDeat);
	PlayerTextDrawShow(playerid, KillMsg_dTitleGear);
}
HideDeathMSG(playerid)
{
	PlayerTextDrawHide(playerid, KillMsg_background);
	PlayerTextDrawHide(playerid, KillMsg_killerIcon);
	PlayerTextDrawHide(playerid, KillMsg_killerName);
	PlayerTextDrawHide(playerid, KillMsg_killerWeap);
	PlayerTextDrawHide(playerid, KillMsg_killerHlth);
	PlayerTextDrawHide(playerid, KillMsg_killerScor);
	PlayerTextDrawHide(playerid, KillMsg_killerKill);
	PlayerTextDrawHide(playerid, KillMsg_killerDeat);
	PlayerTextDrawHide(playerid, KillMsg_killerGear);
	PlayerTextDrawHide(playerid, KillMsg_dTitleWeap);
	PlayerTextDrawHide(playerid, KillMsg_dTitleHlth);
	PlayerTextDrawHide(playerid, KillMsg_dTitleScor);
	PlayerTextDrawHide(playerid, KillMsg_dTitleKill);
	PlayerTextDrawHide(playerid, KillMsg_dTitleDeat);
	PlayerTextDrawHide(playerid, KillMsg_dTitleGear);
}
KillStatsUpdate(playerid, killerid, weapon, head)
{
	new
		tmpWepID = wOffset[weapon],
		tmpWepType = GetWeaponType(weapon),
		tmpWepGroup = GetWeaponGroup(weapon);

	GivePlayerMoney(killerid, 50);
	GivePlayerScore(killerid, 1);
	ResetPerLifeKills(playerid);
	pStatCount[killerid][st_Wep][tmpWepID]++;


	if(tmpWepType != -1)pStatCount[killerid][st_Wtp][WEP_TYPE_ENUM:tmpWepType]++;
	else printf("ERROR: tmpWepTyp = %d :: weapon = %d", tmpWepType, weapon);
	if(tmpWepGroup != -1)pStatCount[killerid][st_Wgp][WEP_GROUP_ENUM:tmpWepGroup]++;
	else printf("ERROR: tmpWepGrp = %d :: weapon = %d", tmpWepGroup, weapon);

    dm_PlayerData[killerid][dm_RoundKills] += 1;
	dm_PlayerData[playerid][dm_RoundDeaths] += 1;
	pKills(killerid) += 1;
	pDeaths(playerid) += 1;


// Headshot
	if(head)
	{
		pHeadShot(killerid)++;
		GiveXP(killerid, 5, "Headshot!");
	}


// Avenger
	if( ((tickcount()-tick_LastKill[playerid])<=MAX_VENGE_TIME) && pTeam(flag_LastKill[playerid]) != pTeam(killerid) )
	{
		GiveXP(killerid, 3, "Avenged");
		pStatCount[killerid][st_Ktp][st_KtAvenge]++;
	}


// Revenge
	if(flag_LastKill[playerid]==killerid)
	{
		GiveXP(killerid, 3, "Revenge Is Sweet!");
		pStatCount[killerid][st_Ktp][st_KtRevenge]++;
	}


// Streaks
	pStreak(killerid)++;
	if(pStreak(playerid)>=3)MsgDeathmatchF(YELLOW, " >  %P"#C_YELLOW" Ended %P"#C_YELLOW"'s dm_Streak of %d", killerid, playerid, pStreak(playerid));
	if(pStreak(playerid)>dm_PlayerData[killerid][dm_HighStreak])
	{
		dm_PlayerData[killerid][dm_HighStreak]=pStreak(playerid);
		if(pStreak(playerid)>3)Msg(playerid, BLUE, "You have beaten your highest Killchain!");
	}


// Assists
	if(flag_LastShot[playerid] != -1)
	{
		if( (flag_ShotBy[playerid]!=killerid) && (pTeam(flag_ShotBy[killerid])!=pTeam(playerid)) )
		{
			GiveXP(flag_ShotBy[playerid], 3, "assist");
			flag_ShotBy[playerid]=-1;
			pStatCount[killerid][st_Ktp][st_KtAssist]++;
		}
	}


// Saviour
	if(flag_LastShot[playerid] != -1)
	{
		if(pTeam(flag_LastShot[playerid]) == pTeam(killerid) && (tickcount()-tick_LastShot[playerid]) < 5000 )
		{
			GiveXP(flag_ShotBy[playerid], 3, "saviour");
			pStatCount[killerid][st_Ktp][st_KtSaviour]++;
		}
	}


// dm_Combo
	if(tickcount()-tick_LastKill[killerid]<2000)
	{
		dm_PlayerData[killerid][dm_Combo]++;
	    if(dm_PlayerData[killerid][dm_Combo]>1)
	    {
			new sComboInfo[10];
			format(sComboInfo, 10, "dm_Combo x%d", dm_PlayerData[killerid][dm_Combo]);
			GiveXP(killerid, (2*dm_PlayerData[killerid][dm_Combo]), sComboInfo);
			MsgF(killerid, WHITE, "** dm_Combo: %d tick: %d", dm_PlayerData[killerid][dm_Combo], tickcount()-tick_LastKill[killerid]);
		}
	}


// Weapon Type
	if(weapon == 34)
	{
		new Float:KillDistance = GetPlayerDist3D(killerid, playerid);
		if(KillDistance >= MAX_DIST_BONUS)GiveXP(playerid, floatround(KillDistance), "Distance Bonus");
	}
}
RankCheck(playerid)
{
	new
		currentrank = pRank(playerid),
		result = GetRankFromExp(pExp(playerid), currentrank);

	if(result > currentrank)
	{
		SetAllWeaponSkills(playerid, pRank(playerid)*100);
		pRank(playerid) = result;
	}
	return 0;
}
GetRankFromExp(exp, startrank = 0)
{
	new i = startrank;
	while(i < MAX_RANK-1)
	{
		if( (exp >= RequiredExp[i]) && (exp < RequiredExp[i+1]) )
			return i;

		i++;
	}
	return MAX_RANK-1;
}
TeamScoreUpdate()
{
	new score[48];
	if(dm_Mode==DM_MODE_TDM)
	{
	    if(dm_ScoreLimit==0)format(score, 40, "TDM~n~ Raven: %d~n~   Valor: %d", dm_TeamScore[score_Kills][0], dm_TeamScore[score_Kills][1]);
	    else
	    {
	        if(dm_Preset == DM_SUDDENDEATH)
				for(new i;i<2;i++)if(dm_TeamScore[score_Kills][i] > dm_TeamScore[score_Kills][!i])return EndRound(i);

			format(score, 48, "Score~n~ Raven: %d/%d~n~   Valor: %d/%d", dm_TeamScore[score_Kills][0], dm_ScoreLimit, dm_TeamScore[score_Kills][1], dm_ScoreLimit);
			for(new i;i<2;i++)if(dm_TeamScore[score_Kills][i] == dm_ScoreLimit)return EndRound(i);
		}
	}
	if(dm_Mode==DM_MODE_AD)
	{
		format(score, 48, "Tickets~n~ Attackers: %d", dm_TeamScore[score_Tickets][!DefendingTeam]);
		if(dm_TeamScore[score_Tickets][!DefendingTeam]==0)return EndRound(DefendingTeam);
	}
	if(dm_Mode==DM_MODE_CTF)
	{
		format(score, 48, "Flags~n~ Raven: %d/%d~n~   Valor: %d/%d", dm_TeamScore[score_Flags][0], dm_FlagLimit, dm_TeamScore[score_Flags][1], dm_FlagLimit);
		for(new i;i<2;i++)if(dm_TeamScore[score_Flags][i] >= dm_FlagLimit)return EndRound(i);
	}
	if(dm_Mode==DM_MODE_CQS)
	{
		format(score, 48, "Tickets~n~ Raven: %d~n~   Valor: %d", dm_TeamScore[score_Tickets][0], dm_TeamScore[score_Tickets][1]);
		if( (dm_TeamScore[score_Tickets][0] <= 0) || (dm_TeamScore[score_Tickets][1] <= 0) )
		{
			for(new i;i<2;i++)if(dm_TeamScore[score_Tickets][i]>0)return EndRound(i);
		}
	}
	TextDrawSetString(ScoreBox, score);
	if(dm_Mode!=DM_MODE_AD&&(bServerGlobalSettings&dm_Started))UpdateScoreStatus();

	return 1;
}
DeathmatchDataUpdate(playerid, killerid)
{
	if(dm_Mode==DM_MODE_AD)
	{
		if(bPlayerDeathmatchSettings[playerid]&dm_Capturing)
		{
			bitFalse(bPlayerDeathmatchSettings[playerid], dm_Capturing);
			HideProgressBarForPlayer(playerid, ADbar);
			if(GetPlayersCapturingAD() == 0)
			{
				PointCT=false;
			    ContinueMatchTime();
			}
			if(killerid!=INVALID_PLAYER_ID)
			{
				GiveXP(killerid, 3, "Defensive Kill");
				pStatCount[killerid][st_Ktp][st_KtAdDefKill]++;
			}
		}
		if(killerid!=INVALID_PLAYER_ID)
		{
			if(bPlayerDeathmatchSettings[killerid]&dm_Capturing)
			{
				GiveXP(killerid, 3, "Offensive Kill");
				pStatCount[playerid][st_Ktp][st_KtAdAttKill]++;
			}
		}
	}
	if(dm_Mode==DM_MODE_CTF)
	{
		if(bPlayerDeathmatchSettings[playerid]&dm_HasFlag)
		{
			bitFalse(bPlayerDeathmatchSettings[playerid], dm_HasFlag);
			CtfFlag[poTeam(playerid)] = CreateDynamicPickup(CTF_FLAG_MODEL, 1, CtfPosF[poTeam(playerid)][0], CtfPosF[poTeam(playerid)][1], CtfPosF[poTeam(playerid)][2]);
			UpdateFlagIcons();
			MsgDeathmatchF(RED, "%s Dropped The Flag!", playerid);
			if(killerid!=INVALID_PLAYER_ID)
			{
				GiveXP(killerid, 5, "Flag Denial");
				pStatCount[killerid][st_Ktp][st_KtCtfAttKill]++;
			}
		}
		if(killerid!=INVALID_PLAYER_ID)
		{
			if(bPlayerDeathmatchSettings[killerid]&dm_HasFlag)
			{
				GiveXP(killerid, 3, "Flag Protection");
				pStatCount[killerid][st_Ktp][st_KtCtfDefKill]++;
			}
		}
	}
	if(dm_Mode==DM_MODE_CQS)
	{
		if(CapturingCP[playerid] != -1)
		{
			new CP = CapturingCP[playerid];
			CapturingCP[playerid] = -1;
		    if(GetPlayersCapturing(CP)==0)
		    {
				CPtimer[CP]=false;
				CPowner[CP]=-1;
			}
			if(killerid!=INVALID_PLAYER_ID)
			{
				GiveXP(killerid, 10, "Defensive Kill");
				pStatCount[killerid][st_Ktp][st_KtCqsDefKill]++;
			}
		}
		if(killerid!=INVALID_PLAYER_ID)
		{
			if(CapturingCP[killerid] != -1)
			{
				GiveXP(killerid, 3, "Offensive Kill");
				pStatCount[killerid][st_Ktp][st_KtCqsAttKill]++;
			}
		}
	}
}
ResetPerLifeKills(playerid)for(new i;i<MAX_WEAPON;i++)pStatCount[playerid][st_Wep][i]=0;

DropCurrentWeapon(playerid)
{
	new
		Float:x,
		Float:y,
		Float:z,
		Float:a,
		ItemType:type = ItemType:GetPlayerWeapon(playerid);

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, a);

	if(IsValidItem(dm_PlayerWeaponDrop[playerid]))
		DestroyItem(dm_PlayerWeaponDrop[playerid]);

	if(0 < _:type <= WEAPON_PARACHUTE)
	{
		new
			ammo = GetPlayerAmmo(playerid),
			str[32];

		format(str, 32, "%s\nAmmo: %d", WepData[_:type][WepName], ammo);

		dm_PlayerWeaponDrop[playerid] = CreateItem(
				ItemType:type, x, y, z - 0.86,
				.rx = 90.0, .rz = a, .zoffset = 1.0,
				.world = DEATHMATCH_WORLD, .interior = 0);

		SetItemLabel(dm_PlayerWeaponDrop[playerid], str);
		SetItemExtraData(dm_PlayerWeaponDrop[playerid], ammo);
	}

	return 1;
}
script_Deathmatch_WeaponChange(playerid, newweapon)
{
	if(GetWeaponType(newweapon)==-1||GetWeaponType(newweapon)==0||GetWeaponType(newweapon)==3)
	{
	    if(HasWeaponType(playerid, 2)!=-1)SetPlayerAttachedObject(playerid, PRIMARY_SLOT, WepData[HasWeaponType(playerid, 2)][WepModel], 1, 0.1, -0.1, 0.18, 0.0, 160.0, 0.0);
	    if(HasWeaponType(playerid, 1)!=-1)SetPlayerAttachedObject(playerid, SIDEARM_SLOT, WepData[HasWeaponType(playerid, 1)][WepModel], 8, 0.0, 0.0, 0.1, 270.0, 0.0);
	}
	if(GetWeaponType(newweapon)==1)
	{
	    RemovePlayerAttachedObject(playerid, SIDEARM_SLOT);
	    if(HasWeaponType(playerid, 2)!=-1)SetPlayerAttachedObject(playerid, PRIMARY_SLOT, WepData[HasWeaponType(playerid, 2)][WepModel], 1, 0.1, -0.1, 0.18, 0.0, 160.0, 0.0);
	}
	if(GetWeaponType(newweapon)==2)
	{
	    RemovePlayerAttachedObject(playerid, PRIMARY_SLOT);
	    if(HasWeaponType(playerid, 1)!=-1)SetPlayerAttachedObject(playerid, SIDEARM_SLOT, WepData[HasWeaponType(playerid, 1)][WepModel], 8, 0.0, 0.0, 0.1, 270.0, 0.0);
	}
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(KEY_RELEASED(KEY_FIRE))
		f:bPlayerDeathmatchSettings[playerid]<dm_Shooting>;

	if(newkeys & EQUIPMENT_KEY)
	{
		if(dm_Preset != DM_BAREBONES && !IsPlayerInAnyVehicle(playerid) && (bPlayerGameSettings[playerid]&InDM) && !(bPlayerDeathmatchSettings[playerid]&dm_UsingEquip) && !(bPlayerDeathmatchSettings[playerid]&dm_Bleeding))
		{
			switch(pKit(playerid))
			{
				case KIT_SUPPORT:	KitEquip_Supp(playerid);
				case KIT_MECHANIC:	KitEquip_Mech(playerid);
				case KIT_MEDIC:		KitEquip_Meds(playerid);
				case KIT_SPECOPS:	KitEquip_Spec(playerid);
				case KIT_BOMBER:	KitEquip_Bomb(playerid);
			}
		}
	}
	if(newkeys & ACTION_KEY)
	{
		if(bPlayerDeathmatchSettings[playerid] & dm_Bleeding)
		{
			ExitBleedOut(playerid);
		    if(dm_BleedAttacker[playerid]==INVALID_PLAYER_ID)dm_OnDeath(playerid);
		    else script_Deathmatch_OnPlayerKill(playerid, dm_BleedAttacker[playerid], dm_BleedReason[playerid]);
		}
	}
	if(newkeys & GEAR_KEY)
	{
		if(pGear(playerid)==g_Ghillie)
		{
			if(!(bPlayerDeathmatchSettings[playerid]&dm_GearUse))
			{
				SetPlayerAttachedObject(playerid, GHILLIE_SLOT, 760, 1, _, _, _, 90, _, _);
				bitFalse(bPlayerDeathmatchSettings[playerid], dm_GearUse);
			}
			else
			{
				RemovePlayerAttachedObject(playerid, GHILLIE_SLOT);
				bitFalse(bPlayerDeathmatchSettings[playerid], dm_GearUse);
			}
		}
		if(pGear(playerid)==g_PlayDead)
		{
			ApplyAnimation(playerid, "ped", "die", 4.1, 0, 0, 0, 0, 0);
			bitFalse(bPlayerDeathmatchSettings[playerid], dm_PlayingDead);
			bitFalse(bPlayerDeathmatchSettings[playerid], dm_GearUse);
		}
	}
	if( (newkeys & 128) && (newkeys & 512) ) playerSpot(playerid);


	if(newkeys & KEY_JUMP)
	{
		if( bPlayerDeathmatchSettings[playerid]&dm_InLobby && bPlayerDeathmatchSettings[playerid]&dm_Ready )
		{
			JoinLobby(playerid);
			if(bServerGlobalSettings&dm_LobbyCounting)
			{
				bitFalse(bServerGlobalSettings, dm_LobbyCounting);
				dm_LobbyCount=MAX_LOBBY_COUNT;
				UpdateLobbyCount();
			}
		}
	}
	return 1;
}



script_Deathmatch_EnterArea(playerid, areaid)
{
	for(new i=0;i<MAX_MINES;i++)
	{
		if( (areaid==MineProx[i]) && (pTeam(playerid)!=pTeam(MineOwner[i])) && (GetPlayerSpecialAction(playerid)!=SPECIAL_ACTION_DUCK) )ExplodeMine(i);

		if(areaid==MineLoc[i]&&pTeam(playerid)!=pTeam(MineOwner[i])&&(dm_Preset != DM_BAREBONES && pGear(playerid)==g_ProxDet))
		{
			GameTextForPlayer(playerid, "~r~Warning ~n~-~n~ Mine", 1000, 5);
			PlayerPlaySound(playerid, 1085, MinePos[i][0], MinePos[i][1], MinePos[i][2]);
		}
	}
	if(pKit(playerid)==KIT_MEDIC)
	{
		PlayerLoop(i)
		{
			if(areaid==gPlayerArea[i] && playerid!=i)
			{
			    if(bPlayerDeathmatchSettings[i]&dm_Bleeding)ShowMsgBox(playerid, "Press ~g~"#TEXT_EQUIP_KEY" ~w~to revive player");
			    else if(gPlayerHP[i] < MAX_HEALTH)ShowMsgBox(playerid, "Press ~g~"#TEXT_EQUIP_KEY" ~w~to heal player");
				else return 1;
			}
		}
	}

	if(dm_Mode==DM_MODE_AD)
	{
		if(areaid == PointToCapture)
		{
			if( pTeam(playerid)!=DefendingTeam && IsPlayerInGame(playerid) )
			{
				bitTrue(bPlayerDeathmatchSettings[playerid], dm_Capturing);
				if(dm_MatchTimeLimit>0)PauseMatchTime();
				MsgDeathmatchF(BLUE, " >  %P"#C_BLUE" Is capturing the base", playerid);

				if(GetPlayersCapturingAD() == 1)
				{
					PointCT=true;
					capturer=playerid;
				}
			}
			else ShowMsgBox(playerid, "This is the base you defend", 3000);
		}
	}
	else if(dm_Mode==DM_MODE_CQS)
	{
		for(new cp;cp<MAX_CP;cp++)
		{
			if(areaid == CPflag[cp])
			{
				if( CPowner[cp]!=pTeam(playerid) && IsPlayerInGame(playerid) )
				{
					if(GetPlayersCapturing(cp)==0)FirstToCapture[cp]=playerid;
					CapturingCP[playerid] = cp;
					CPtimer[cp]=true;

					ShowProgressBarForPlayer(playerid, CPbar[cp]);
					MsgDeathmatchF(BLUE, " >  %P"#C_BLUE" Is Capturing %s!", playerid, CPname[cp]);
				}
			}
		}
	}
	return 1;
}
script_Deathmatch_ExitArea(playerid, areaid)
{
	PlayerLoop(i)if(areaid==gPlayerArea[i])HideMsgBox(playerid);

	if(areaid == dm_CombatZone)GameTextForPlayer(playerid, "~w~get back to the fight!", 500, 4);

	if(dm_Mode==DM_MODE_AD)
	{
		if(areaid == PointToCapture)
		{
		    ContinueMatchTime();
		    bitFalse(bPlayerDeathmatchSettings[playerid], dm_Capturing);
			if(GetPlayersCapturingAD() == 0) PointCT=false;
			HideProgressBarForPlayer(playerid, ADbar);
		}
	}
	if(dm_Mode==DM_MODE_CQS)
	{
		for(new cp=0;cp<MAX_CP;cp++)
		{
		    if(areaid == CPflag[cp])
		    {
				CapturingCP[playerid] = -1;
				if(GetPlayersCapturing(cp) == 0)CPtimer[cp]=false;
				HideProgressBarForPlayer(playerid, CPbar[cp]);
			}
		}
	}
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_RegionSelect)
	{
		if(response)
		{
		    if(listitem==MAX_REGION)
			{
				TogglePlayerControllable(playerid, true);
				dm_Host = -1;
			}
		    else
		    {
				ShowPlayerDialog(playerid, d_RegionMaps, DIALOG_STYLE_LIST, dm_RegionNames[listitem], dm_RegionMaps[listitem], "Accept", "Info");
				dm_CurrentRegion=listitem;
			}
		}
		else dm_FormatRegionInfo(playerid, listitem);
		return 1;
	}
	if(dialogid == d_RegionInfo)
	{
		ShowPlayerDialog(playerid, d_RegionSelect, DIALOG_STYLE_LIST, "Choose a map style category", dm_RegionList, "Accept", "Info");
		return 1;
	}

	if(dialogid == d_RegionMaps)
	{
	    for(new m;m<MAX_MAPS;m++)
	    {
	    	if(dm_MapRegion[m] == dm_CurrentRegion && dm_RegionIndex[m] == listitem)
	    	{
				if(response)
				{
	    		    dm_Map=m;
					dm_FormatModeSelect(playerid);
					return 1;
				}
				else
				{
					dm_FormatMapInfo(playerid, m);
					return 1;
				}
	    	}
		}
		ShowPlayerDialog(playerid, d_RegionSelect, DIALOG_STYLE_LIST, "Choose a map style category", dm_RegionList, "Accept", "Info");
	}
	if(dialogid == d_MapInfo)
	{
		ShowPlayerDialog(playerid, d_RegionMaps, DIALOG_STYLE_LIST, dm_RegionNames[dm_CurrentRegion], dm_RegionMaps[dm_CurrentRegion], "Accept", "Info");
		return 1;
	}

	if(dialogid == d_ModeSelect)
	{
		if(!strcmp(inputtext, "Back"))return ShowPlayerDialog(playerid, d_RegionMaps, DIALOG_STYLE_LIST, dm_RegionNames[dm_CurrentRegion], dm_RegionMaps[dm_CurrentRegion], "Accept", "Info");
		for(new i;i<MAX_MODE;i++)
		{
			if(!strcmp(inputtext, dm_ModeNames[i], false, strlen(dm_ModeNames[i])))
			{
				if(response)
				{
					dm_Mode=i;
					ResetDMSettings();
					dm_FormatSettingsMenu(playerid);
					return 1;
				}
				else dm_FormatGamemodeInfo(playerid, i);
			}
		}
	}
	if(dialogid == d_ModeInfo)
	{
		dm_FormatModeSelect(playerid);
		return 1;
	}

	if(dialogid == d_Settings)
	{
	    if(response)
	    {
			switch(listitem)
			{
				case 0: // Score Limit
				{
					if(dm_Mode==DM_MODE_TDM)ShowPlayerDialog(playerid, d_Scorelim, DIALOG_STYLE_INPUT, "Score Limit", DIALOGTEXT_SCORLIM, "Apply", "Clear");
					if(dm_Mode==DM_MODE_AD)ShowPlayerDialog(playerid, d_Ticketlim, DIALOG_STYLE_INPUT, "Attackers Tickets", DIALOGTEXT_TICKLIM, "Apply", "Clear");
					if(dm_Mode==DM_MODE_CTF)ShowPlayerDialog(playerid, d_Flaglim, DIALOG_STYLE_INPUT, "Flag Limit", DIALOGTEXT_FLAGLIM, "Apply", "Clear");
					if(dm_Mode==DM_MODE_CQS)ShowPlayerDialog(playerid, d_Forcelim, DIALOG_STYLE_INPUT, "Reinforcement Tickets", DIALOGTEXT_FORCLIM , "Apply", "Clear");
				}
				case 1: // Time Limit
				{
					ShowPlayerDialog(playerid, d_Matchtime, DIALOG_STYLE_INPUT, "Match Time Limit", "Enter the Match Time in minutes", "Apply", "Clear");
				}
				case 2: // Start DM
				{
					LoadDeathmatchData();
					MsgAllF(YELLOW, " >  %P"#C_YELLOW" Is hosting a Deathmatch, "#C_BLUE"Type /joindm to join.", playerid);
					Msg(playerid, ORANGE, " >  When everyone is ready the deathmatch will start.");
					JoinDeathMatch(playerid);
				}
				case 3: // Cancel DM
				{
					ResetDMVariables();
				    TogglePlayerControllable(playerid, true);
				}
		    }
		}
		else
		{
			switch(listitem)
			{
				case 0:
				{
				    if(dm_Mode==DM_MODE_TDM)ShowPlayerDialog(playerid, d_SettingsInfo, DIALOG_STYLE_MSGBOX, "Score Limit",			"Amount of kills teams need to win the game.\n0 for unlimited.", "Back", "");
				    if(dm_Mode==DM_MODE_AD)ShowPlayerDialog(playerid, d_SettingsInfo, DIALOG_STYLE_MSGBOX, "Attackers Tickets",		"Amount of reinforcement tickets attackers get,\nteam loses a ticket when a player of that dm_Team dies.\ndefenders get unlimited tickets.", "Back", "");
				    if(dm_Mode==DM_MODE_CTF)ShowPlayerDialog(playerid, d_SettingsInfo, DIALOG_STYLE_MSGBOX, "Flag Limit",			"Amount of flags teams need to capture to win the game.", "Back", "");
				    if(dm_Mode==DM_MODE_CQS)ShowPlayerDialog(playerid, d_SettingsInfo, DIALOG_STYLE_MSGBOX, "Reinforcement Tickets","Reinforcement Tickets each dm_Team is allocated at the start of the game.\nTeam loses a ticket when a player of that dm_Team dies.", "Back", "");
				}
				case 1:ShowPlayerDialog(playerid, d_SettingsInfo, DIALOG_STYLE_MSGBOX, "Time Limit",			"Amount of time before the game ends.\n 0 for unlimited.", "Back", "");
				case 2:ShowPlayerDialog(playerid, d_SettingsInfo, DIALOG_STYLE_MSGBOX, "Start Deathmatch",		"Start the deathmatch with current settings.", "Back", "");
				case 3:ShowPlayerDialog(playerid, d_SettingsInfo, DIALOG_STYLE_MSGBOX, "Cancel Deathmatch",		"Cancel all settings and return to freeroam mode.", "Back", "");
			}
		}
	}
	if(dialogid == d_SettingsInfo)
	{
		dm_FormatSettingsMenu(playerid);
		return 1;
	}

	if(dialogid == d_Scorelim)
	{
	    new value = strval(inputtext);
		if( (value<SCORLIM_MIN) || (value>SCORLIM_MAX) || (!response) )ShowPlayerDialog(playerid, d_Scorelim, DIALOG_STYLE_INPUT, "Score Limit", DIALOGTEXT_SCORLIM, "Apply", "Clear");
		else
		{
			dm_ScoreLimit = value;
		    dm_FormatSettingsMenu(playerid);
		}
	}
	if(dialogid == d_Ticketlim)
	{
	    new value = strval(inputtext);
		if( (value<TICKLIM_MIN) || (value>TICKLIM_MAX) || (!response) )ShowPlayerDialog(playerid, d_Ticketlim, DIALOG_STYLE_INPUT, "Attackers Tickets", DIALOGTEXT_TICKLIM, "Apply", "Clear");
		else
		{
			dm_TeamScore[score_Tickets][!DefendingTeam] = value;
		    dm_FormatSettingsMenu(playerid);
		}
	}
	if(dialogid == d_Flaglim)
	{
	    new value = strval(inputtext);
		if( (value<FLAGLIM_MIN) || (value>FLAGLIM_MAX) || (!response) )ShowPlayerDialog(playerid, d_Flaglim, DIALOG_STYLE_INPUT, "Score Limit", DIALOGTEXT_FLAGLIM, "Apply", "Clear");
		else
		{
			dm_FlagLimit = value;
		    dm_FormatSettingsMenu(playerid);
		}
	}
	if(dialogid == d_Forcelim)
	{
	    new value = strval(inputtext);
		if( (value<FORCLIM_MIN) || (value>FORCLIM_MAX) || (!response) )ShowPlayerDialog(playerid, d_Forcelim, DIALOG_STYLE_INPUT, "Reinforcement Limit", DIALOGTEXT_FORCLIM, "Apply", "Clear");
		else
		{
			dm_TeamScore[score_Tickets][1] = value;
			dm_TeamScore[score_Tickets][0] = value;
		    dm_FormatSettingsMenu(playerid);
		}
	}

	if(dialogid == d_Matchtime)
	{
	    new value = strval(inputtext);
		if( (value<MATCHTIME_MIN) || (value>MATCHTIME_MAX) || (!response) )ShowPlayerDialog(playerid, d_Matchtime, DIALOG_STYLE_INPUT, "Match Time Limit", DIALOGTEXT_MATCHTIME, "Apply", "Clear");
		else
		{
			dm_MatchTimeLimit = strval(inputtext);
		    dm_FormatSettingsMenu(playerid);
		}
	}



	if(dialogid == d_CustomiseMenu)
	{
	    if(response)
		{
		    if(listitem == 0)dm_FormatKitList(playerid);
		    if(listitem == 1)dm_FormatWeaponList(playerid, 0);
		    if(listitem == 2)dm_FormatWeaponList(playerid, 1);
		    if(listitem == 3)dm_ShowGraphicMenu(playerid);
		}
	    else ShowMenuForPlayer(dm_LobbyMenu, playerid);
	}
	if(dialogid == d_KitMenu)
	{
	    if(response)
	    {
	    	pKit(playerid) = listitem;
	    	dm_FormatCustomMenu(playerid);
	    }
	    else dm_FormatKitInfo(playerid, listitem);
	}
	if(dialogid == d_KitInfo)dm_FormatKitList(playerid);
	if(dialogid == d_LoadoutPri)
	{
		if(response)
		{
			new
			    file[MAX_PLAYER_FILE];

			GetFile(gPlayerName[playerid], file);

			pLoadout[playerid][pKit(playerid)][WEAPON_SLOT_PRIMARY] = dm_WepListIndex[0][listitem];

			file_Open(file);
			SaveDMLoadout(playerid);
			file_Save(file);
			file_Close();

			dm_FormatCustomMenu(playerid);
		}
		else dm_FormatCustomMenu(playerid);
	}
	if(dialogid == d_LoadoutAlt)
	{
		if(response)
		{
			new
			    file[40];

			GetFile(gPlayerName[playerid], file);

			pLoadout[playerid][pKit(playerid)][WEAPON_SLOT_SIDEARM] = dm_WepListIndex[1][listitem];

			file_Open(file);
			SaveDMLoadout(playerid);
			file_Save(file);
			file_Close();

			dm_FormatCustomMenu(playerid);
		}
		else dm_FormatCustomMenu(playerid);
	}

	if(dialogid == d_Gearselect)
	{
		if(response)
		{
			pGear(playerid)=listitem;
			ShowMenuForPlayer(dm_LobbyMenu, playerid);
		}
		else ShowPlayerDialog(playerid, d_Gearinfo, DIALOG_STYLE_MSGBOX, dm_GearNames[listitem], dm_GearInfo[listitem], "Back", "");
	}
	if(dialogid == d_Gearinfo)
	{
		dm_FormatGearMenu(playerid);
	}


	if(dialogid==d_Spawnpoint)
	{
	    if(listitem<4)
	    {
			if(CPowner[listitem]==pTeam(playerid))
			{
			    TogglePlayerSpectating(playerid, false);
				SetPlayerCameraPos(playerid, CPOfSet[listitem][0], CPOfSet[listitem][1], CPOfSet[listitem][2]);
				SetPlayerCameraLookAt(playerid, CPpoint[listitem][0], CPpoint[listitem][1], CPpoint[listitem][2]);
				SetPlayerPos(playerid, CPpoint[listitem][0], CPpoint[listitem][1], CPpoint[listitem][2]-1.0);
			    if(!response)
			    {
			        cq_Spawn[playerid] = listitem;
					dm_PlayerSpawn[playerid][0]=CPpoint[listitem][0],
					dm_PlayerSpawn[playerid][1]=CPpoint[listitem][1],
					dm_PlayerSpawn[playerid][2]=CPpoint[listitem][2];
					ShowMenuForPlayer(dm_LobbyMenu, playerid);
				}
				else dm_FormatSpawnMenu(playerid);
			}
			else
			{
				ShowMsgBox(playerid, "You haven't ~r~captured ~w~this ~y~command post ~w~yet", 3000);
				dm_FormatSpawnMenu(playerid);
			    TogglePlayerSpectating(playerid, false);
			}
		}
		else
		{
		    if(dm_MsuActive[pTeam(playerid)])
		    {
				TogglePlayerSpectating(playerid, true);
		        PlayerSpectateVehicle(playerid, dm_MsuVehicleID[pTeam(playerid)]);
		        if(!response)
		        {
		            new
						Float:vPos[4];

		            GetVehiclePos(dm_MsuVehicleID[pTeam(playerid)], vPos[0], vPos[1], vPos[2]);
		            GetVehicleZAngle(dm_MsuVehicleID[pTeam(playerid)], vPos[3]);
		            GetXYFromAngle(vPos[0], vPos[1], vPos[3], -4);
					dm_PlayerSpawn[playerid][0]=vPos[0],
					dm_PlayerSpawn[playerid][1]=vPos[1],
					dm_PlayerSpawn[playerid][2]=vPos[2];
					cq_Spawn[playerid] = listitem;
					ShowMenuForPlayer(dm_LobbyMenu, playerid);
		        }
		        else dm_FormatSpawnMenu(playerid);
		    }
		    else
			{
				Msg(playerid, RED, "The Mobile Spawn Unit has been destroyed");
				dm_FormatSpawnMenu(playerid);
		    	TogglePlayerSpectating(playerid, false);
			}
		}
	}
	return 1;
}
dm_ShowGraphicMenu(playerid)
{
	new
		tmpStr[16];

	tmpStr = "_";
	PlayerTextDrawSetString(playerid, dm_GraMenu_LeftOpt, tmpStr);

	tmpStr = "LD_TATT:";
	strcat(tmpStr, GraphicData[0][grFile]);
	PlayerTextDrawSetString(playerid, dm_GraMenu_MidOpt, tmpStr);

	tmpStr = "LD_TATT:";
	strcat(tmpStr, GraphicData[1][grFile]);
	PlayerTextDrawSetString(playerid, dm_GraMenu_RightOpt, tmpStr);

	PlayerTextDrawShow(playerid, dm_GraMenu_Back);
	PlayerTextDrawShow(playerid, dm_GraMenu_Left);
	PlayerTextDrawShow(playerid, dm_GraMenu_Right);
	PlayerTextDrawShow(playerid, dm_GraMenu_LeftOpt);
	PlayerTextDrawShow(playerid, dm_GraMenu_MidOpt);
	PlayerTextDrawShow(playerid, dm_GraMenu_RightOpt);
	PlayerTextDrawShow(playerid, dm_GraMenu_Accept);
	SelectTextDraw(playerid, 0x909090FF);
}
dm_HideGraphicMenu(playerid)
{
    dm_GraMenuCurrent[playerid] = 0;
	PlayerTextDrawHide(playerid, dm_GraMenu_Back);
	PlayerTextDrawHide(playerid, dm_GraMenu_Left);
	PlayerTextDrawHide(playerid, dm_GraMenu_Right);
	PlayerTextDrawHide(playerid, dm_GraMenu_LeftOpt);
	PlayerTextDrawHide(playerid, dm_GraMenu_MidOpt);
	PlayerTextDrawHide(playerid, dm_GraMenu_RightOpt);
	PlayerTextDrawHide(playerid, dm_GraMenu_Accept);
	return 1;

}
dm_UpdateGraphicMenu(playerid)
{
	new
	    tmpStr[32],
		tmpIdx = dm_GraMenuCurrent[playerid];

	if(tmpIdx == 0)tmpStr = "_";
	else
	{
		tmpStr = "LD_TATT:";
		strcat(tmpStr, GraphicData[tmpIdx-1][grFile]);
	}
	PlayerTextDrawSetString(playerid, dm_GraMenu_LeftOpt, tmpStr);

	tmpStr = "LD_TATT:";
	strcat(tmpStr, GraphicData[tmpIdx][grFile]);
	PlayerTextDrawSetString(playerid, dm_GraMenu_MidOpt, tmpStr);


	if(tmpIdx == MAX_GRAPHIC-1)tmpStr = "_";
	else
	{
		tmpStr = "LD_TATT:";
		strcat(tmpStr, GraphicData[tmpIdx+1][grFile]);
	}
	PlayerTextDrawSetString(playerid, dm_GraMenu_RightOpt, tmpStr);
}

hook OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(playertextid == dm_GraMenu_Left)
	{
	    if(dm_GraMenuCurrent[playerid] > 0)
		{
			dm_GraMenuCurrent[playerid]--;
			dm_UpdateGraphicMenu(playerid);
		}
	}
	if(playertextid == dm_GraMenu_Right)
	{
	    if(dm_GraMenuCurrent[playerid] < MAX_GRAPHIC-1)
		{
			dm_GraMenuCurrent[playerid]++;
			dm_UpdateGraphicMenu(playerid);
		}
	}
	if(playertextid == dm_GraMenu_Accept)
	{
		new
		    file[40];

		GetFile(gPlayerName[playerid], file);

	    pGraphic[playerid] = dm_GraMenuCurrent[playerid];
		file_Open(file);
		SaveDMLoadout(playerid);
		file_Save(file);
		file_Close();

		dm_HideGraphicMenu(playerid);
		CancelSelectTextDraw(playerid);
		dm_FormatCustomMenu(playerid);
	}
}

hook OnPlayerSelectedMenuRow(playerid, row, Menu:pMenu)
{
	if(pMenu == dm_TeamMenu)
	{
		new
			t0 = GetPlayersInTeam(0),
			t1 = GetPlayersInTeam(1);

		switch(row)
		{
			case 0:
			{
				if(t0 > t1)
				{
					Msg(playerid, ORANGE, "This dm_Team is full");
					ShowMenuForPlayer(dm_TeamMenu, playerid);
				}
				else
				{
					SetPlayerToTeam(playerid, 0);
					ShowMenuForPlayer(dm_LobbyMenu, playerid);
					MsgDeathmatchF(GREEN, " >  %P"#C_GREEN" Has Joined The Raven dm_Team", playerid);
					dm_FormatLobbyInfoForAll();
				}
			}
			case 1:
			{
				if(t1 > t0)
				{
					Msg(playerid, ORANGE, "This dm_Team is full");
					ShowMenuForPlayer(dm_TeamMenu, playerid);
				}
				else
				{
					SetPlayerToTeam(playerid, 1);
					ShowMenuForPlayer(dm_LobbyMenu, playerid);
					MsgDeathmatchF(GREEN, " >  %P"#C_GREEN" Has Joined The Valor dm_Team", playerid);
					dm_FormatLobbyInfoForAll();
				}
			}
		}
	}
	if(pMenu == dm_LobbyMenu)
	{
	    switch(row)
	    {
			case 0:
			{
				ShowMenuForPlayer(dm_TeamMenu, playerid);
				bitTrue(bPlayerGameSettings[playerid], FirstSpawn);
				pTeam(playerid) = 3;
			}
			case 1:
			{
			    dm_FormatCustomMenu(playerid);
			}
			case 2:
			{
				if(dm_Preset != DM_BAREBONES)dm_FormatGearMenu(playerid);
				else
				{
					Msg(playerid, ORANGE, " >  dm_Gear Items are disabled in "#C_BLUE"Barebones Mode");
			    	ShowMenuForPlayer(dm_LobbyMenu, playerid);
				}
			}
	        case 3:
	        {
	            if(dm_Mode==DM_MODE_CQS)dm_FormatSpawnMenu(playerid);
	            else
	            {
	                Msg(playerid, ORANGE, " >  Only available in "#C_BLUE"Conquest gamemodes");
	                ShowMenuForPlayer(dm_LobbyMenu, playerid);
	            }
	        }
	        // case 4 disabled
	        case 5:
	        {
				Msg(playerid, RED, "This feature is not active yet");
				ShowMenuForPlayer(dm_LobbyMenu, playerid);

	        }
	        case 6:
	        {
				SetPlayerToSpectate(playerid, true);
				Msg(playerid, RED, "This feature is not active yet");
				ShowMenuForPlayer(dm_LobbyMenu, playerid);
	        }
	        // case 7 disabled
	        case 8:
	        {
				JoinQueue(playerid);
				HideMenuForPlayer(dm_LobbyMenu, playerid);
				if(!(bServerGlobalSettings&dm_Started))
				{
					new
						iReadyPlayers,
						iPlayersInLobby = GetPlayersInLobby();
					PlayerLoop(i)if(bPlayerDeathmatchSettings[i]&dm_Ready)iReadyPlayers++;
					if( (iReadyPlayers==iPlayersInLobby) && (iPlayersInLobby>=MIN_DM_PLAYERS) )
					{
						dm_LobbyCount=MAX_LOBBY_COUNT;
						bitTrue(bServerGlobalSettings, dm_LobbyCounting);
					}
				}
	        }
	    }
	}
}
hook OnPlayerExitedMenu(playerid)
{
	new
		Menu:pMenu = GetPlayerMenu(playerid);

	if(pMenu == dm_LobbyMenu)
	{
		ShowMenuForPlayer(dm_LobbyMenu, playerid);
	}
    else if(pMenu == dm_TeamMenu)
    {
    	AutoAssignTeam(playerid);
		ShowMenuForPlayer(dm_LobbyMenu, playerid);
    }
	else TogglePlayerControllable(playerid, true);
	return 1;
}


dm_IsValidMapMode(map, mode)
{
	if(dm_MapModes[map]&mode)return 1;
	return 0;
}
dm_FormatLobbyInfo(playerid)
{
	HideMsgBox(playerid);
	new
		str[290],
		tmpRavenColour = 'b',
		tmpValorColour = 'r';

	if(pTeam(playerid) == TEAM_VALOR)
	{
		tmpRavenColour = 'r',
		tmpValorColour = 'b';
	}

	format(str, 290,
	"~y~~k~~PED_JUMPING~ ~w~to show lobby menu~n~~n~\
	dm_Team: ~b~%s~n~\
	~%c~Raven: ~g~%d~n~\
	~%c~Valor: ~g~%d~n~~n~\
	~w~dm_Kit: ~b~%s~n~\
	~w~dm_Gear: ~b~%s~n~~n~\
	~w~Map: ~r~%s~n~\
	~w~Mode: ~r~%s~n~\
	~w~Map Author: ~r~%s",
	dm_TeamNames[pTeam(playerid)],
	tmpRavenColour,
	GetPlayersInTeam(0),
	tmpValorColour,
	GetPlayersInTeam(1),
	dm_KitNames[pKit(playerid)],
	dm_GearNames[pGear(playerid)],
	dm_MapNames[dm_Map],
	dm_ModeNamesShort[dm_Mode],
	dm_MapAuthor);

	ShowMsgBox(playerid, str);
}
dm_FormatLobbyInfoForAll()
{
	PlayerLoop(i)
		if(bPlayerDeathmatchSettings[i]&dm_InLobby && bPlayerDeathmatchSettings[i]&dm_Ready)
			dm_FormatLobbyInfo(i);
}


dm_FormatModeSelect(playerid)
{
	new str[256], tmpstr[20], infostr[64];
	for(new i=1, x=(MAX_MODE-1);i<=0b1000;i<<=1,x--)
	{
		if(dm_IsValidMapMode(dm_Map, i))
		{
		    format(tmpstr, 20, "%s\n", dm_ModeNames[x]);
		    strcat(str, tmpstr);
		}
	}
	strcat(str, "Back");
	format(infostr, 64, "Available Gamemodes For "#C_BLUE"%s", dm_MapNames[dm_Map]);
	ShowPlayerDialog(playerid, d_ModeSelect, DIALOG_STYLE_LIST, infostr, str, "Accept", "Info");
	return 1;
}
dm_FormatRegionInfo(playerid, region)
{
	new szInfo[148];
	switch(region)
	{
	    case 0:szInfo="Built up areas with tight alley ways, side streets and open plazas perfect for ambushing and sniping.";
	    case 1:szInfo="Woodlands, fields and overgrown farms, lots of bushes and trees to sneak around in with the Ghillie suit dm_Gear item.";
	    case 2:szInfo="Open areas, rocks, desert villages but not a lot of bushes to hide in, ideal for assaults, but hiding my prove difficult.";
	    case 3:szInfo="Islands, docks and desolate refuges, attack vehicles are boats and the camouflage is the sea, brilliant for sniping and complex tactical planning.";
	    case 4:szInfo="Maps that are based around the original San Andreas towns and areas. There are modded map additions to most of these maps.";
	}
	ShowPlayerDialog(playerid, d_RegionInfo, DIALOG_STYLE_MSGBOX, dm_RegionNames[region], szInfo, "Back", "");
}
dm_FormatMapInfo(playerid, map)
{
	new szInfo[256];
	format(szInfo, 256, ""#C_YELLOW"Size:\t"#C_WHITE"%s\n\n"#C_YELLOW"dm_Kit:\t"#C_WHITE"%s\n\n"#C_YELLOW"Intel:\n\t"#C_WHITE"%s", dm_MapInfo_Size[map], dm_MapInfo_Kit[map], dm_MapInfo_Bio[map]);
	ShowPlayerDialog(playerid, d_MapInfo, DIALOG_STYLE_MSGBOX, dm_MapNames[map], szInfo, "Back", "");
	return 1;
}
dm_FormatGamemodeInfo(playerid, mode)
{
	new szInfo[232];
	switch(mode)
	{
	    case 0:szInfo="In this gamemode the objective is simply reach the score limit, do this by killing members of the enemy team.";
	    case 1:szInfo="One team defends a position and the other team has to capture it by staying in the area for long enough.\nLarger maps have three points to capture one after another.";
	    case 2:szInfo="Each team has a flag in their base, players have to pick up the enemy's flag and return it to their base to score points for their team.";
	    case 3:szInfo="Each map has 4 strategic points which teams aim to capture.\nEach team has a ticket count which depletes every time a team member is killed.\nIf your team captures all the positions or the enemy has no tickets left, your team wins.";
	}
	ShowPlayerDialog(playerid, d_ModeInfo, DIALOG_STYLE_MSGBOX, dm_ModeNames[mode], szInfo, "Back", "");
}

dm_FormatSettingsMenu(playerid)
{
	new
		str[128],
		tmpScoreType[12],
		tmpScoreValue;

	if(dm_Mode==DM_MODE_TDM)tmpScoreType = "Kill Limit",	tmpScoreValue = dm_ScoreLimit;
	if(dm_Mode==DM_MODE_AD)	tmpScoreType = "Tickets",		tmpScoreValue = dm_TeamScore[score_Tickets][!DefendingTeam];
	if(dm_Mode==DM_MODE_CTF)tmpScoreType = "Flag Limit",	tmpScoreValue = dm_FlagLimit;
	if(dm_Mode==DM_MODE_CQS)tmpScoreType = "Tickets",		tmpScoreValue = dm_TeamScore[score_Tickets][0];


	format(str, 256, "\
		%s:\t\t\t\t%d\n\
		Time Limit:\t\t\t\t%d\n\
		Start Deathmatch\n\
		Cancel Deathmatch",

		tmpScoreType,
		tmpScoreValue,
		dm_MatchTimeLimit);

	ShowPlayerDialog(playerid, d_Settings, DIALOG_STYLE_LIST, "Deathmatch Settings", str, "Change", "Info");
}
dm_FormatSpawnMenu(playerid)
{
	new str[64];
	format(str, 64, "%s\n%s\n%s\n%s\nMobile Spawn Unit", CPname[0], CPname[1], CPname[2], CPname[3]);
	ShowPlayerDialog(playerid, d_Spawnpoint, DIALOG_STYLE_LIST, "Choose Spawn Point", str, "View", "Accept");
}

dm_FormatCustomMenu(playerid)
{
	new list[128];
	format(list, 128,
		"Class: %s\nPrimary: %s\nSidearm: %s\nGraphic: %s\n",
		dm_KitNames[pKit(playerid)],
		WepData[pLoadout[playerid][pKit(playerid)][WEAPON_SLOT_PRIMARY]][WepName],
		WepData[pLoadout[playerid][pKit(playerid)][WEAPON_SLOT_SIDEARM]][WepName],
		GraphicData[pGraphic[playerid]][grName]);

	ShowPlayerDialog(playerid, d_CustomiseMenu, DIALOG_STYLE_LIST, "Customise", list, "Accept", "Back");
}
dm_FormatKitList(playerid)
{
	new list[10 * (MAX_KIT + 1)];
	for(new i;i<MAX_KIT;i++)
	{
	    strcat(list, dm_KitNames[i]);
	    strcat(list, "\n");
	}
	ShowPlayerDialog(playerid, d_KitMenu, DIALOG_STYLE_LIST, "Choose A Class", list, "Accept", "Back");
}
dm_FormatKitInfo(playerid, kit)
{
	new str[128];
	switch(kit)
	{
	    case 0:str = "The Support kit can drop ammo boxes for the dm_Team that allow for 5 ammo refills.";
	    case 1:str = "Mechanics can fix vehicles and deply motion sensors that make enemies appear on the map when nearby.";
	    case 2:str = "Medics can drop health kits and revive allies who are bleeding out.";
	    case 3:str = "Spec Ops players can place spawn beacons for fast dm_Team deployment and hack computer terminals.";
	    case 4:str = "The Bomber can place trip-mines and blow open certain doors with time bombs.";
	}
	ShowPlayerDialog(playerid, d_KitInfo, DIALOG_STYLE_MSGBOX, dm_KitNames[kit], str, "Back", "");
}
dm_FormatWeaponList(playerid, type)
{
	new
		list[256],
		idx;

	if(type == 0)
	{
		for(new i = 25; i <= 34; i++)
		{
			if(GetWeaponType(i) == 2)
			{
				strcat(list, WepData[i][WepName]);
				strcat(list, "\n");
			    dm_WepListIndex[type][idx]=i;
				idx++;
			}
		}
		ShowPlayerDialog(playerid, d_LoadoutPri, DIALOG_STYLE_LIST, "Select Weapon", list, "Accept", "Back");
	}
	if(type == 1)
	{
		for(new i = 22; i <= 32; i++)
		{
			if(GetWeaponType(i) == 1)
			{
				strcat(list, WepData[i][WepName]);
				strcat(list, "\n");
			    dm_WepListIndex[type][idx]=i;
				idx++;
			}
		}
		ShowPlayerDialog(playerid, d_LoadoutAlt, DIALOG_STYLE_LIST, "Select Weapon", list, "Accept", "Back");
	}
}
dm_FormatGearMenu(playerid)
{
	new
	    info[64],
		list[200];

	format(info, 64, "You are currently using "#C_YELLOW"%s", dm_GearNames[pGear(playerid)]);
	for(new i=0;i<sizeof(dm_GearNames);i++)format(list, 200, "%s\n%s", list, dm_GearNames[i]);
    ShowPlayerDialog(playerid, d_Gearselect, DIALOG_STYLE_LIST, info, list, "Accept", "Info");
}
GivePlayerKitWeapons(playerid, crate=0)
{
	new AdditionalMags;

	if(dm_Preset != DM_BAREBONES && pGear(playerid)==g_ExtraMags)AdditionalMags=2;
	ResetPlayerWeapons(playerid);

    pLoadout[playerid][pKit(playerid)][WEAPON_SLOT_MELEE] = 4;

	for(new w = MAX_LOADOUT_WEP-1; w >= 0; w--)
	{
		GivePlayerWeapon(playerid,
			pLoadout[playerid][pKit(playerid)][w],
			WepData[ pLoadout[playerid][pKit(playerid)][w] ][MagSize] * (4 + AdditionalMags)
		);
	}

	if(dm_Preset != DM_BAREBONES && !crate)dm_EquipCount[playerid] = 1;
	UpdateEqipmentText(playerid);
}
dm_SetUpPlayerSpawn(playerid)
{
	if(dm_Mode != DM_MODE_CQS)
	{
		new t=pTeam(playerid);
		for(new i;i<3;i++)dm_PlayerSpawn[playerid][i]=dm_MapSpawnPos[dm_MapSpawnSide[t]][i];
	}
	Streamer_Update(playerid);
}
forward BleedOut(id);

SetPlayerToSpectate(playerid, toggle)
{
	if(!toggle)
	{
	    TogglePlayerSpectating(playerid, false);
	    dm_PlayerSpectateTarget[playerid]=-1;
	    ShowMenuForPlayer(dm_LobbyMenu, playerid);
	    return 1;
	}
	PlayerLoop(i)
	{
	    if(bPlayerGameSettings[i] & InDM && bPlayerGameSettings[i] & Spawned)
	    {
	        dm_PlayerSpectateTarget[playerid] = i;
	        TogglePlayerSpectating(playerid, true);
	        PlayerSpectatePlayer(playerid, i);
	        return 1;
	    }
	}
	SpecDM(playerid);
	return 0;
}

stock Spectate_Next(playerid)
{
	new tmpID;
	while( (!IsPlayerConnected(tmpID)) && !(bPlayerGameSettings[tmpID]&InDM) && !(bPlayerGameSettings[tmpID]&Spawned) )
	{
	    if( tmpID==(MAX_PLAYERS-1) )tmpID=0;
	    if( tmpID==dm_PlayerSpectateTarget[playerid] )return 0;
	    tmpID++;
	}
	dm_PlayerSpectateTarget[playerid]=tmpID;
	PlayerSpectatePlayer(playerid, tmpID);
	return 1;
}
stock Spectate_Prev(playerid)
{
	new tmpID;
	while( (!IsPlayerConnected(tmpID)) && !(bPlayerGameSettings[tmpID]&InDM) && !(bPlayerGameSettings[tmpID]&Spawned) )
	{
	    if(tmpID==0)tmpID=(MAX_PLAYERS-1);
	    if(tmpID==dm_PlayerSpectateTarget[playerid] )return 0;
	    tmpID--;
	}
	dm_PlayerSpectateTarget[playerid]=tmpID;
	PlayerSpectatePlayer(playerid, tmpID);
	return 1;
}


LoadDeathmatchData()
{
	new
		dmFile[64],
		buffer[128];

	bitFalse(bServerGlobalSettings, dm_Started);
	bitTrue(bServerGlobalSettings, dm_InProgress);
	dm_MapSpawnSide[0]=random(1);
	dm_MapSpawnSide[1]=!dm_MapSpawnSide[0];

	SetGameModeText(dm_ModeNames[dm_Mode]);
	SetMapName(dm_MapNames[dm_Map]);

	format(dmFile, 50, DM_DATA_FILE, dm_Map, dm_MapNames[dm_Map]);

	if(!fexist(dmFile))return printf("File %s Not Found", dmFile);
	else file_Open(dmFile);


    file_GetStr("GEN_CamPos", buffer);
	sscanf(buffer, "p<,>ffffff", dm_SpecPos[0], dm_SpecPos[1], dm_SpecPos[2], dm_SpecPos[3], dm_SpecPos[4], dm_SpecPos[5]);

	dm_Weather = file_GetVal("GEN_Weather");

    file_GetStr("GEN_Time", buffer);
	sscanf(buffer, "p<,>dd", dm_TimeH, dm_TimeM);

    file_GetStr("GEN_Author", buffer);
	sscanf(buffer, "s[10]", dm_MapAuthor);

    file_GetStr("GEN_spawn1", buffer);
	sscanf(buffer, "p<,>fff", dm_MapSpawnPos[0][0], dm_MapSpawnPos[0][1], dm_MapSpawnPos[0][2]);

    file_GetStr("GEN_spawn2", buffer);
	sscanf(buffer, "p<,>fff", dm_MapSpawnPos[1][0], dm_MapSpawnPos[1][1], dm_MapSpawnPos[1][2]);


	LoadDeathmatchItems();
	file_Close();

	if(dm_Mode==DM_MODE_AD)
	{
	    file_Open(dmFile);
		DefendingTeam = file_GetVal("AD_DefendingTeam");
		MaxPoints=1;

		file_GetStr("AD_CapturePoint1", buffer);
		sscanf(buffer, "p<,>fff", CapturePoint[0][0], CapturePoint[0][1], CapturePoint[0][2]);

		if(file_IsKey("AD_CapturePoint2"))
		{
			file_GetStr("AD_CapturePoint2", buffer);
			sscanf(buffer, "p<,>fff", CapturePoint[1][0], CapturePoint[1][1], CapturePoint[1][2]);
			MaxPoints=2;
		}
		if(file_IsKey("AD_CapturePoint3"))
		{
			file_GetStr("AD_CapturePoint3", buffer);
			sscanf(buffer, "p<,>fff", CapturePoint[2][0], CapturePoint[2][1], CapturePoint[2][2]);
			MaxPoints=3;
		}
        file_Close();

        CreateCaptureBase(CapturePoint[0][0], CapturePoint[0][1], CapturePoint[0][2]);

		ADbar				=	CreateProgressBar(50, 200, 60, 5, YELLOW, ADcaptureTime);
		ADfill				=	0;
		CaptureProgress 	=	0;
	}
	if(dm_Mode==DM_MODE_CTF)
	{
	    file_Open(dmFile);

	    file_GetStr("CTF_flag1", buffer);
		sscanf(buffer, "p<,>fff", CtfPosF[0][0], CtfPosF[0][1], CtfPosF[0][2]);

		file_GetStr("CTF_flag2", buffer);
		sscanf(buffer, "p<,>fff", CtfPosF[1][0], CtfPosF[1][1], CtfPosF[1][2]);

        file_Close();

		CtfFlag[0] = CreateDynamicPickup(CTF_FLAG_MODEL, 1, CtfPosF[0][0], CtfPosF[0][1], CtfPosF[0][2], DEATHMATCH_WORLD, _, _, 300.0);
		CtfFlag[1] = CreateDynamicPickup(CTF_FLAG_MODEL, 1, CtfPosF[1][0], CtfPosF[1][1], CtfPosF[1][2], DEATHMATCH_WORLD, _, _, 300.0);
	}
	if(dm_Mode==DM_MODE_CQS)
	{
	    new tmpkey[13];
		file_Open(dmFile);
		for(new i; i < MAX_CP; i++)
		{
			format(tmpkey, 13, "CQS_point%d", i);
		    file_GetStr(tmpkey, buffer);
			sscanf(buffer, "p<,>fff", CPpoint[i][0], CPpoint[i][1], CPpoint[i][2]);

			format(tmpkey, 13, "CQS_name%d", i);
			file_GetStr(tmpkey, CPname[i]);

			format(tmpkey, 13, "CQS_CPOfSet%d", i);
			file_GetStr(tmpkey, buffer);
			sscanf(buffer, "p<,>fff", CPOfSet[i][0], CPOfSet[i][1], CPOfSet[i][2]);

			format(tmpkey, 13, "CQS_owner%d", i);
			CPowner[i] = file_GetVal(tmpkey);

			CreateCommandPost(i, CPpoint[i][0], CPpoint[i][1], CPpoint[i][2]);

			CPfill[i]	= 0;

		}
        file_Close();
		dm_MatchTimeLimit=0;
	}
	file_Close();
	dm_TeamScore[score_Kills][0] = 0;
	dm_TeamScore[score_Kills][1] = 0;
	dm_TeamScore[score_Flags][0] = 0;
	dm_TeamScore[score_Flags][1] = 0;
	dm_TeamScore[score_Tickets][0] = 100;
	dm_TeamScore[score_Tickets][1] = 100;
	TeamScoreUpdate();
	return 1;
}
StartDM()
{
	PlayerLoop(i)if(bPlayerDeathmatchSettings[i]&dm_InLobby && bPlayerDeathmatchSettings[i]&dm_Ready)DMspawn(i);
	bitFalse(bServerGlobalSettings, dm_LobbyCounting);
	TextDrawHideForAll(LobbyText);
	bitTrue(bServerGlobalSettings, dm_Started);
	if(dm_MatchTimeLimit>0)MatchTime(dm_MatchTimeLimit, 0);
}


JoinDeathMatch(playerid)
{
	bitFalse(bPlayerGameSettings[playerid], InDM);
	bitFalse(bPlayerGameSettings[playerid], Spawned);
	bitTrue(bPlayerDeathmatchSettings[playerid], dm_InLobby);
	bitFalse(bPlayerDeathmatchSettings[playerid], dm_Ready);
	pKit(playerid) = 0;
	bitTrue(pGear(playerid), g_ProxDet);
	AutoAssignTeam(playerid);

	if(bServerGlobalSettings & dm_Started)ShowMenuForPlayer(dm_LobbyMenu, playerid);

	if(dm_Mode==DM_MODE_CQS)
	{
		for(new cp=0;cp<MAX_CP;cp++)
		{
			if(CPowner[cp]==pTeam(playerid))
			{
				dm_PlayerSpawn[playerid][0]=CPpoint[cp][0],
				dm_PlayerSpawn[playerid][1]=CPpoint[cp][1],
				dm_PlayerSpawn[playerid][2]=CPpoint[cp][2];
			}
		}
	}

	SetPlayerWeather(playerid, dm_Weather);
	SetPlayerTime(playerid, dm_TimeH, dm_TimeM);
	SetPlayerVirtualWorld(playerid, DEATHMATCH_WORLD);
	GangZoneShowForPlayer(playerid, dm_RadarBlock, 0x000000FF);
	TogglePlayerControllable(playerid, 0);

	JoinLobby(playerid);

	UpdatePlayerIconForAll(playerid);

}
AutoAssignTeam(playerid)
{
	if(GetPlayersInTeam(0)>GetPlayersInTeam(1))pTeam(playerid)=1;
	else pTeam(playerid)=0;
	MsgF(playerid, YELLOW, " >  You have been auto-assigned to "#C_BLUE"%s"#C_YELLOW" dm_Team.", dm_TeamNames[pTeam(playerid)]);
}
timer JoinLobby[3000](playerid)
{
	bitTrue(bPlayerDeathmatchSettings[playerid], dm_InLobby);
	bitFalse(bPlayerDeathmatchSettings[playerid], dm_Ready);

	HideMsgBox(playerid);
	HideDeathMSG(playerid);
	SpecDM(playerid);
	TextDrawHideForPlayer(playerid, SpawnCount);
    if(!(bServerGlobalSettings&dm_Started) && !(bServerGlobalSettings&dm_LobbyCounting))
	{
        UpdateLobbyCount();
		TextDrawShowForPlayer(playerid, LobbyText);
	}

	dm_FormatLobbyInfoForAll();
	ShowMenuForPlayer(dm_LobbyMenu, playerid);
	dm_SetPlayerHP(playerid, dm_GlobalMaxHP);

	HideHUD(playerid);

	Streamer_Update(playerid);
}
JoinQueue(playerid)
{
	bitTrue(bPlayerDeathmatchSettings[playerid], dm_InLobby);
	bitTrue(bPlayerDeathmatchSettings[playerid], dm_Ready);
	dm_FormatLobbyInfo(playerid);

    if(bServerGlobalSettings&dm_Started)TextDrawShowForPlayer(playerid, SpawnCount);
    else TextDrawShowForPlayer(playerid, LobbyText);

	SpecDM(playerid);
	HideMenuForPlayer(dm_LobbyMenu, playerid);
	HideHUD(playerid);
	Streamer_Update(playerid);
}
UpdateLobbyCount()
{
	new str[70];
	format(str, 70, "%d Players In Lobby~n~Type /joindm to join~n~", GetPlayersInLobby());
	TextDrawSetString(LobbyText, str);
}
UpdateQueueCountDown()
{
	new lobbycountstr[100];
	format(lobbycountstr, 100, "%d Players In Lobby~n~Type /joindm to join~n~Deathmatch Starting In %02d",  GetPlayersInLobby(), dm_LobbyCount);
	TextDrawSetString(LobbyText, lobbycountstr);
	TextDrawShowForAll(LobbyText);
	if(dm_LobbyCount<=0)StartDM();
	dm_LobbyCount--;
}

ShowHUD(playerid)
{
	TextDrawShowForPlayer(playerid, ScoreBox);
	if(dm_MatchTimeLimit>0)
		TextDrawShowForPlayer(playerid, MatchTimeCounter);

	PlayerTextDrawShow(playerid, dm_EquipText);
	UpdatePlayerXPBar(playerid);
}
HideHUD(playerid)
{
	TextDrawHideForPlayer(playerid, ScoreBox);
	TextDrawHideForPlayer(playerid, MatchTimeCounter);
	TextDrawHideForPlayer(playerid, ScoreStatus_Winning);
	TextDrawHideForPlayer(playerid, ScoreStatus_Tie);
	TextDrawHideForPlayer(playerid, ScoreStatus_Losing);
	PlayerTextDrawHide(playerid, RankTextCurr);
	PlayerTextDrawHide(playerid, RankTextNext);
	PlayerTextDrawHide(playerid, dm_EquipText);
	HidePlayerProgressBar(playerid, XPbar);
	HidePlayerProgressBar(playerid, BleedoutBar);
}


UpdateScoreStatus(playerid=-1)
{
	new
		iaScore[2],
		iLeadTeam;

	if(dm_Mode==DM_MODE_TDM)
	{
	    iaScore[0]=dm_TeamScore[score_Kills][0];
	    iaScore[1]=dm_TeamScore[score_Kills][1];
	}
	if(dm_Mode==DM_MODE_CTF)
	{
	    iaScore[0]=dm_TeamScore[score_Flags][0];
	    iaScore[1]=dm_TeamScore[score_Flags][1];
	}
	if(dm_Mode==DM_MODE_CQS)
	{
	    iaScore[0]=dm_TeamScore[score_Tickets][0];
	    iaScore[1]=dm_TeamScore[score_Tickets][1];
	}

/*
	if(iaScore[0] > iaScore[1])iLeadTeam=0;
	else iLeadTeam=1;
*/

	if(iaScore[0] == iaScore[1])
	{
		SetScoreStatus(0, 0, playerid);
		SetScoreStatus(1, 0, playerid);
	}
	else
	{
		while(iaScore[iLeadTeam] < iaScore[!iLeadTeam])iLeadTeam=!iLeadTeam;
		SetScoreStatus(iLeadTeam, 2, playerid);
		SetScoreStatus(!iLeadTeam, 1, playerid);
	}
}

SetScoreStatus(team, status, playerid)
{
	if(playerid != -1)
	{
	    TextDrawHideForPlayer(playerid, ScoreStatus_Tie);
		TextDrawHideForPlayer(playerid, ScoreStatus_Losing);
		TextDrawHideForPlayer(playerid, ScoreStatus_Winning);
		if(status==0)TextDrawShowForPlayer(playerid, ScoreStatus_Tie);
		if(status==1)TextDrawShowForPlayer(playerid, ScoreStatus_Losing);
		if(status==2)TextDrawShowForPlayer(playerid, ScoreStatus_Winning);
		return 1;
	}
	PlayerLoop(i)
	{
	    if(pTeam(i) == team && bPlayerGameSettings[i]&Spawned)
	    {
			TextDrawHideForPlayer(i, ScoreStatus_Tie);
			TextDrawHideForPlayer(i, ScoreStatus_Losing);
			TextDrawHideForPlayer(i, ScoreStatus_Winning);
	        if(status==0)TextDrawShowForPlayer(i, ScoreStatus_Tie);
	        if(status==1)TextDrawShowForPlayer(i, ScoreStatus_Losing);
	        if(status==2)TextDrawShowForPlayer(i, ScoreStatus_Winning);
	    }
	}
	return 0;
}

LoadDeathmatchItems()
{
	LoadDM_Map(dm_Map);
	LoadDM_Crates();
	LoadDM_Vehicles();

    if(dm_Mode==DM_MODE_CQS)
    {
        new
            buffer[64],
			model,
			Float:x,
			Float:y,
			Float:z,
			Float:r;

        if(!file_IsKey("CQS_msu1"))print("ERROR: Loading MSU1 Data");
        if(!file_IsKey("CQS_msu2"))print("ERROR: Loading MSU2 Data");

		file_GetStr("CQS_msu1", buffer);
		sscanf(buffer, "p<,>dffff", model, x, y, z, r);
		dm_MsuVehicleID[0] = CreateVehicle(model, x, y, z, r, -1, -1, -1);

		file_GetStr("CQS_msu2", buffer);
		sscanf(buffer, "p<,>dffff", model, x, y, z, r);
		dm_MsuVehicleID[1] = CreateVehicle(model, x, y, z, r, -1, -1, -1);

		SetVehicleVirtualWorld(dm_MsuVehicleID[1], DEATHMATCH_WORLD);
		SetVehicleVirtualWorld(dm_MsuVehicleID[0], DEATHMATCH_WORLD);
		dm_MsuActive[0] = true;
		dm_MsuActive[1] = true;
    }
}
#define MAX_MATERIAL_SIZE	14
#define MAX_MATERIAL_LEN	8
LoadDM_Map(mapid)
{
    new
		File:file,
		fname[64],
		line[128],
		modelid,
		Float:px,
		Float:py,
		Float:pz,
		Float:rx,
		Float:ry,
		Float:rz,
		linecount=1,
		objId,

		tmpObjMatID,
		tmpObjIdx,
		tmpObjMod,
		tmpObjTxd[32],
		tmpObjTex[32],
		tmpObjMatCol,

		tmpObjText[128],
		tmpObjResName[32],
		tmpObjRes,
		tmpObjFont[32],
		tmpObjFontSize,
		tmpObjBold,
		tmpObjFontCol,
		tmpObjBackCol,
		tmpObjAlign,

		matSizeTable[MAX_MATERIAL_SIZE][MAX_MATERIAL_LEN] =
	    {
			"32x32",
			"64x32",
			"64x64",
			"128x32",
			"128x64",
			"128x128",
			"256x32",
			"256x64",
			"256x128",
			"256x256",
			"512x64",
			"512x128",
			"512x256",
			"512x512"
	    };


    format(fname, 50, DM_MAP_FILE, dm_MapNames[mapid]);
    file=fopen(fname, io_read);

    if(!file)return printf("File %s Not Found", fname);

    while(fread(file, line))
    {
		if(!sscanf(line, "p<(>{s[17]}p<,>dfffffp<)>f{s[4]}", modelid, px, py, pz, rx, ry, rz))
		{
		    objId = Iter_Free(dm_ObjectTableIndex);
			dm_ObjectTable[objId] = tmpObjMatID = CreateDynamicObject(modelid, px, py, pz, rx, ry, rz, DEATHMATCH_WORLD, _, _, MAX_RENDER_DISTANCE);
			Iter_Add(dm_ObjectTableIndex, objId);
		}
		else if(!sscanf(line, "'objtxt('p<\">{s[1]}s[32]p<,>{s[1]}ds[32]p<\">{s[1]}s[32]p<,>{s[1]}ddddp<)>d", tmpObjText, tmpObjIdx, tmpObjRes, tmpObjFont, tmpObjFontSize, tmpObjBold, tmpObjFontCol, tmpObjBackCol, tmpObjAlign))
		{
		    new len = strlen(tmpObjText);
			for(new i;i<sizeof matSizeTable;i++)if(strfind(tmpObjResName, matSizeTable[i])!=-1)tmpObjRes = (i + 1)*10;

			for(new c;c<len;c++)
			{
			    if(tmpObjText[c] == 92 && c != len-1)
				{
				    if(tmpObjText[c+1] == 'n')
				    {
						strdel(tmpObjText, c, c+1);
						tmpObjText[c] = '\n';
				    }
			    }
			}
			SetDynamicObjectMaterialText(tmpObjMatID, tmpObjIdx, tmpObjText, tmpObjRes, tmpObjFont, tmpObjFontSize, tmpObjBold, tmpObjFontCol, tmpObjBackCol, tmpObjAlign);
		}
		else if(!sscanf(line, "'objmat('p<,>dd p<\">{s[1]}s[32]p<,>{s[1]} p<\">{s[1]}s[32]p<,>{s[1]}p<)>d", tmpObjIdx, tmpObjMod, tmpObjTxd, tmpObjTex, tmpObjMatCol))
		{
			SetDynamicObjectMaterial(tmpObjMatID, tmpObjIdx, tmpObjMod, tmpObjTxd, tmpObjTex, tmpObjMatCol);
		}
		else printf("Error in file %s on line: %d objid: %d modelid: %d", fname, linecount, objId, modelid);
        linecount++;
    }
	printf("Deathmatch Map Loaded: %d Object Count: %d", mapid, Iter_Count(dm_ObjectTableIndex));
	return 1;
}
LoadDM_Crates()
{
	new FileStr[64];
	format(FileStr, 64, DM_CRATE_FILE, dm_Map, dm_MapNames[dm_Map]);
	if(!fexist(FileStr))return print("Error: Deathmatch Crate File Not Found");
	new
		File:File,
		line[128],
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	File=fopen(FileStr, io_read);
	while(fread(File, line))
	{
		if(!sscanf(line, "p<,>fffF(0.0)", x, y, z, r))
			CreateSupplyCrate(x, y, z, r, CRATE_TYPE_MAIN);

		else print("Error: Deathmatch Crate File");
	}
	fclose(File);
	return 1;
}
LoadDM_Vehicles()
{
	new vFileStr[64];
	format(vFileStr, 64, DM_VEHICLE_FILE, dm_Map, dm_MapNames[dm_Map]);
	if(!fexist(vFileStr))return 0;
	new
		File:vFile,
		line[128],
		modelid,
		Float:x,
		Float:y,
		Float:z,
		Float:r,
		vehId;

	vFile=fopen(vFileStr, io_read);
	while(fread(vFile, line))
	{
		if(!sscanf(line, "p<,>dffff", modelid, x, y, z, r))
		{
		    vehId = Iter_Free(dm_VehicleTableIndex);
			dm_VehicleTable[vehId] = CreateVehicle(modelid, x, y, z, r, -1, -1, 10000);
			SetVehicleVirtualWorld(dm_VehicleTable[vehId], DEATHMATCH_WORLD);
			Iter_Add(dm_VehicleTableIndex, vehId);
		}
		else print("Error: Deathmatch Vehicle File");
	}
	fclose(vFile);
	return 1;
}

SpecDM(playerid)
{
	SetPlayerVirtualWorld(playerid, DEATHMATCH_WORLD);
	TogglePlayerControllable(playerid, 0);
	if(dm_Mode==DM_MODE_CQS)
	{
	    if(cq_Spawn[playerid] == 4)
	    {
			TogglePlayerSpectating(playerid, true);
			PlayerSpectateVehicle(playerid, dm_MsuVehicleID[pTeam(playerid)]);
	    }
	    else
	    {
	    	for(new cp;cp<MAX_CP;cp++)
	    	{
			    if(CPowner[cp]==pTeam(playerid))
			    {
					SetPlayerCameraPos(playerid,	CPOfSet[cp][0], CPOfSet[cp][1], CPOfSet[cp][2]);
					SetPlayerCameraLookAt(playerid,	CPpoint[cp][0], CPpoint[cp][1], CPpoint[cp][2]);
					SetPlayerPos(playerid,			CPpoint[cp][0], CPpoint[cp][1], CPpoint[cp][2]-2.0);
					break;
				}
			}
		}
	}
	else
	{
		if(dm_Map==-2)SetCameraBehindPlayer(playerid);
		else
		{
			SetPlayerCameraPos(playerid,	dm_SpecPos[0], dm_SpecPos[1], dm_SpecPos[2]);
			SetPlayerCameraLookAt(playerid,	dm_SpecPos[3], dm_SpecPos[4], dm_SpecPos[5]);
			SetPlayerPos(playerid,			dm_SpecPos[3], dm_SpecPos[4], dm_SpecPos[5]-2.0);
		}
	}
	Streamer_Update(playerid);
}
script_Deathmatch_VehicleSpawn(vehicleid)
{
	if(vehicleid == dm_MsuVehicleID[0])dm_MsuActive[0] = true;
	if(vehicleid == dm_MsuVehicleID[1])dm_MsuActive[1] = true;
	return 1;
}
script_Deathmatch_VehicleDeath(vehicleid)
{
	if(vehicleid == dm_MsuVehicleID[0])dm_MsuActive[0] = false;
	if(vehicleid == dm_MsuVehicleID[1])dm_MsuActive[1] = false;
	return 1;
}
DMspawn(playerid)
{
	new rAng = random(360);

	bitFalse(bPlayerGameSettings[playerid], GodMode);
	bitTrue(bPlayerGameSettings[playerid], Spawned);

	// HUD
	TogglePlayerSpectating(playerid, false);
	TextDrawHideForPlayer(playerid, LobbyText);
	TextDrawHideForPlayer(playerid, SpawnCount);
	TextDrawHideForPlayer(playerid, InfoBar);
	TextDrawHideForPlayer(playerid, ClockText);
	ShowHUD(playerid);
//	UpdateHealthBar(playerid);
	HideMsgBox(playerid);
	UpdatePlayerIconForAll(playerid);
	UpdateScoreStatus(playerid);

	if(dm_Preset != DM_BAREBONES)
	{
		if(pGear(playerid)==g_Night)GivePlayerWeapon(playerid, WEAPON_NIGHTVISION, 1);
		if(pGear(playerid)==g_Thermal)GivePlayerWeapon(playerid, WEAPON_THERMALVISION, 1);
	}
	SetPlayerToTeam(playerid, pTeam(playerid));

	SetPlayerVirtualWorld(playerid, DEATHMATCH_WORLD);
	SetCameraBehindPlayer(playerid);
	SetPlayerArmour(playerid, 0.0);
	dm_SetPlayerHP(playerid, dm_GlobalMaxHP);
	ResetPlayerWeapons(playerid);
	GivePlayerKitWeapons(playerid);

	bitTrue(bPlayerGameSettings[playerid], InDM);
	bitFalse(bPlayerDeathmatchSettings[playerid], dm_InLobby);
	bitFalse(bPlayerDeathmatchSettings[playerid], dm_Ready);
	bitFalse(bPlayerGameSettings[playerid], FirstSpawn);

	bitTrue(bPlayerDeathmatchSettings[playerid], dm_GearUse);
	UpdatePlayerXPBar(playerid);
	UpdateEqipmentText(playerid);


	if(dm_Mode==DM_MODE_TDM)TextDrawShowForPlayer(playerid, ScoreBox);
	else if(dm_Mode==DM_MODE_AD)
	{
		dm_PlayerSpawn[playerid][0]=CapturePoint[CaptureProgress][0];
		dm_PlayerSpawn[playerid][1]=CapturePoint[CaptureProgress][1];
		dm_PlayerSpawn[playerid][2]=CapturePoint[CaptureProgress][2];
		UpdateBaseFlag(playerid);
	}
	else if(dm_Mode==DM_MODE_CTF)
	{
		TextDrawShowForPlayer(playerid, ScoreBox);
		bitFalse(bPlayerDeathmatchSettings[playerid], dm_HasFlag);
		UpdateFlagIcons();
	}
	else if(dm_Mode==DM_MODE_CQS)
	{
		TextDrawShowForPlayer(playerid, ScoreBox);
		UpdateAllCPsForPlayer(playerid);
	}


	if(dm_Mode!=DM_MODE_CQS)dm_SetUpPlayerSpawn(playerid);
	SetPlayerPos(playerid, dm_PlayerSpawn[playerid][0]+floatsin(rAng, degrees), dm_PlayerSpawn[playerid][1]+floatcos(rAng, degrees), dm_PlayerSpawn[playerid][2]+0.5);

	FreezePlayer(playerid, 1000);
	PreloadPlayerAnims(playerid);
	ResetPlayerDMVariables(playerid);
	dm_GuiUpdateTimer[playerid] = repeat GuiUpdate(playerid);

	Streamer_Update(playerid);
}
EndRound(WinningTeam)
{
	new
		TeamScores[2],
		HighestExp,
		HighestKills,
		HighestDeaths;

	defer NextRound();

	if(dm_Mode==DM_MODE_TDM)
	{
		TeamScores[0]=dm_TeamScore[score_Kills][0];
		TeamScores[1]=dm_TeamScore[score_Kills][1];
	}
	if(dm_Mode==DM_MODE_AD)
	{
		TeamScores[WinningTeam]=1;
		TeamScores[!WinningTeam]=0;
	}
	if(dm_Mode==DM_MODE_CTF)
	{
		TeamScores[0]=dm_TeamScore[score_Flags][0];
		TeamScores[1]=dm_TeamScore[score_Flags][1];
	}
	if(dm_Mode==DM_MODE_CQS)
	{
		TeamScores[WinningTeam]=1;
		TeamScores[!WinningTeam]=0;
	}

	if(TeamScores[0]>TeamScores[1])WinningTeam=0;
	if(TeamScores[0]<TeamScores[1])WinningTeam=1;
	if(TeamScores[0]==TeamScores[1])WinningTeam=-1;


	PlayerLoop(i)
	{
		if(bPlayerGameSettings[i] & InDM)
		{
			if(WinningTeam==pTeam(i))
			{
				GameTextForPlayer(i, "~n~~n~~b~Your dm_Team won!", 3000, 5);
				GiveXP(i, 30, "Winning");
			}
			if(WinningTeam==poTeam(i))
			{
				GameTextForPlayer(i, "~n~~n~~b~Your dm_Team lost!", 3000, 5);
				GiveXP(i, 10, "Taking Part");
			}
			if(WinningTeam==-1)
			{
				GameTextForPlayer(i, "~n~~n~~g~It was a draw", 3000, 5);
				GiveXP(i, 20, "Taking Part");
			}
			if(RankCheck(i))MsgF(i, LGREEN, " >  You Just Ranked Up! You are now rank %d", pRank(i));
		}
	}

	for(new i; i < MAX_PLAYERS; i++)
	{
	    if(!IsPlayerConnected(i) || !(bPlayerGameSettings[i] & InDM))
	    {
			dm_Leaderboard[i][lb_ID] = -1;
			dm_Leaderboard[i][lb_Exp] =  -1;
			dm_Leaderboard[i][lb_Kills] = -1;
			dm_Leaderboard[i][lb_Deaths] = -1;
	    }
	    else
	    {
			dm_Leaderboard[i][lb_ID] = i;
			dm_Leaderboard[i][lb_Exp] =  dm_PlayerData[i][dm_RoundExp];
			dm_Leaderboard[i][lb_Kills] = dm_PlayerData[i][dm_RoundKills];
			dm_Leaderboard[i][lb_Deaths] = dm_PlayerData[i][dm_RoundDeaths];
	    }
	}

	HighestExp = MostExp(),
	HighestKills = MostKills(),
	HighestDeaths = MostDeaths();

	PlayerLoop(i)
	{
		if(bPlayerGameSettings[i] & InDM)
		{
			SpecDM(i);

			Msg(i, BLUE, HORIZONTAL_RULE);
			Msg(i, YELLOW, " >  Match Stats:");

			MsgF(i, BLUE, " >  Most Exp: %P "#C_YELLOW"(%d)", HighestExp, dm_PlayerData[HighestExp][dm_RoundExp]);
			MsgF(i, BLUE, " >  Most Kills: %P "#C_YELLOW"(%d)", HighestKills, dm_PlayerData[HighestKills][dm_RoundKills]);
			MsgF(i, BLUE, " >  Most Deaths: %P "#C_YELLOW"(%d)", HighestDeaths, dm_PlayerData[HighestDeaths][dm_RoundDeaths]);

			MsgF(i, YELLOW, " >  Your Stats: Exp: "#C_WHITE"%d"#C_YELLOW" - Kills: "#C_WHITE"%d"#C_YELLOW" - Deaths: "#C_WHITE"%d",
				dm_PlayerData[i][dm_RoundExp], dm_PlayerData[i][dm_RoundKills], dm_PlayerData[i][dm_RoundDeaths]);

			Msg(i, BLUE, HORIZONTAL_RULE);

		}
		ResetPlayerMatchStats(i);
	}
	return 1;
}
timer NextRound[20000]()
{
	new
	    curMap = dm_Map,
		curMode = dm_Mode;

	StopMatchTime();
	for(new i=0;i<MAX_CP;i++)
	{
		CPowner[i]=-1;
		CPfill[i]=0;
	}
	PlayerLoop(i)
	{
		CapturingCP[i]=-1;
		if(dm_Mode==DM_MODE_AD)
		{
		   	DestroyDynamicArea(PointToCapture);
		   	StopMatchTime();
			DestroyDynamicMapIcon(CaptureIcon);
			DestroyProgressBar(ADbar);
		}
		if(dm_Mode==DM_MODE_CTF)
		{
			DestroyDynamicPickup(CtfFlag[0]);
			DestroyDynamicPickup(CtfFlag[1]);
			RemovePlayerMapIcon(i, CtfIcon);
		}
		if(dm_Mode==DM_MODE_CQS)
		{
			for(new cp=0;cp<MAX_CP;cp++)
			{
				DestroyDynamicArea(CPflag[cp]);
				DestroyDynamic3DTextLabel(CPlabel[cp][0]);
				DestroyDynamic3DTextLabel(CPlabel[cp][1]);
				DestroyDynamicMapIcon(CPicon[cp][0]);
				DestroyDynamicMapIcon(CPicon[cp][1]);
				DestroyProgressBar(CPbar[cp]);
			}
		}
	}

	UnloadDM();
	ResetDMVariables();

	dm_Map = random(MAX_MAPS);
	dm_Mode = curMode;
	dm_Preset = DM_NORMAL;
	
	new
		iModeBit = 1,
		iModeInt = (MAX_MODE - 1);

	while(iModeBit <= 0b1000)
	{
	    if(iModeInt == curMode)
	    {
			if(dm_IsValidMapMode(dm_Map, iModeBit) && dm_Map != curMap)break;
			else dm_Map = random(MAX_MAPS);
		}
		else
		{
			iModeBit <<= 1;
			iModeInt--;
		}
	}

	LoadDeathmatchData();

	PlayerLoop(i)if(bPlayerGameSettings[i]&InDM)JoinDeathMatch(i);
}


ExitDeathmatch(playerid)
{
	new
	    file[MAX_PLAYER_FILE];

	GetFile(gPlayerName[playerid], file);

	SaveDMStats(playerid);
	file_Open(file);
	SaveDMLoadout(playerid);
	SaveDMAwards(playerid);
	file_Save(file);
	file_Close();

	stop dm_GuiUpdateTimer[playerid];
	stop crt_UpdateTimer[playerid];
	ResetPlayerWeapons(playerid);

	HideHUD(playerid);
	HideDeathMSG(playerid);
	UpdatePlayerIconForAll(playerid);

	TextDrawHideForPlayer(playerid, LobbyText);
	TextDrawHideForPlayer(playerid, SpawnCount);

	TextDrawShowForPlayer(playerid, InfoBar);
	TextDrawShowForPlayer(playerid, ClockText);

	GangZoneHideForPlayer(playerid, dm_RadarBlock);
	HideMenuForPlayer(dm_LobbyMenu, playerid);
	HideMsgBox(playerid);

	RemovePlayerAttachedObject(playerid, PRIMARY_SLOT);
	RemovePlayerAttachedObject(playerid, SIDEARM_SLOT);

	SetPlayerPos(playerid, 2268.9895,1518.6492,42.8156);
	SetPlayerSkin(playerid, pSkin(playerid));
	SetSpawnInfo(playerid, -1, pSkin(playerid), 2268.9895,1518.6492,42.8156,271.1070, 0, 0, 0, 0, 0, 0);
	SetPlayerWorldBounds(playerid, 20000.0, -20000.0, 20000.0, -20000.0);
	SetPlayerVirtualWorld(playerid, FREEROAM_WORLD);
	SetPlayerInterior(playerid, 0);
	SetCameraBehindPlayer(playerid);
	TogglePlayerControllable(playerid, true);
	PlayerLoop(i)
	{
		ShowPlayerNameTagForPlayer	(playerid, i, true);
		ShowPlayerNameTagForPlayer	(i, playerid, true);
		SetPlayerColor(playerid, ColourData[gPlayerColour[playerid]][colour_value]);
	}
	pTeam(playerid) = -1;
	SetPlayerTeam(playerid, -1);
	bitFalse(bPlayerGameSettings[playerid], InDM);
	bitFalse(bPlayerDeathmatchSettings[playerid], dm_InLobby);
	bitFalse(bPlayerDeathmatchSettings[playerid], dm_Ready);
	ResetPlayerDMVariables(playerid);
	ResetSpectatorTarget(playerid);

    if(!(bServerGlobalSettings&dm_Started) && !(bServerGlobalSettings&dm_LobbyCounting))UpdateLobbyCount();
	if(GetPlayersInDM()==0 && GetPlayersInLobby()==0)EndDeathmatch();
}

LoadDMStats(playerid)
{
	new
		tmpQuery[64],
		DBResult:tmpResult,
		result[12];

	format(tmpQuery, sizeof(tmpQuery), "SELECT * FROM `Deathmatch` WHERE `"#ROW_NAME"` = '%s'", gPlayerName[playerid]);

	tmpResult = db_query(gAccounts, tmpQuery);

	db_get_field(tmpResult, 1, result, 12);
	dm_PlayerData[playerid][dm_Kills]		=	strval(result);

	db_get_field(tmpResult, 2, result, 12);
	dm_PlayerData[playerid][dm_Deaths]		=	strval(result);

	db_get_field(tmpResult, 3, result, 12);
	dm_PlayerData[playerid][dm_Exp]			=	strval(result);

	db_get_field(tmpResult, 4, result, 12);
	dm_PlayerData[playerid][dm_HeadShots]	=	strval(result);

	db_get_field(tmpResult, 5, result, 12);
	dm_PlayerData[playerid][dm_TeamKills]	=	strval(result);

	db_get_field(tmpResult, 6, result, 12);
	dm_PlayerData[playerid][dm_HighStreak]	=	strval(result);

	db_get_field(tmpResult, 7, result, 12);
	dm_PlayerData[playerid][dm_Wins]		=	strval(result);

	db_get_field(tmpResult, 8, result, 12);
	dm_PlayerData[playerid][dm_Losses]		=	strval(result);


    db_free_result(tmpResult);

	RankCheck(playerid);

}
LoadDMLoadout(playerid)
{
	new
		tmpKey[6],
		buffer[128];

	for(new c; c < MAX_KIT; c++)
	{
		format(tmpKey, 6, "dml%d", c);
		file_GetStr(tmpKey, buffer);

		sscanf(buffer, "p<|>ddd",
			pLoadout[playerid][c][0],
			pLoadout[playerid][c][1],
			pLoadout[playerid][c][2]);

		if(pLoadout[playerid][c][WEAPON_SLOT_MELEE]==0)pLoadout[playerid][c][WEAPON_SLOT_MELEE] = 4;
		if(pLoadout[playerid][c][WEAPON_SLOT_SIDEARM]==0)pLoadout[playerid][c][WEAPON_SLOT_SIDEARM] = 22;
		if(pLoadout[playerid][c][WEAPON_SLOT_PRIMARY]==0)pLoadout[playerid][c][WEAPON_SLOT_PRIMARY] = 29;
	}
}
LoadDMAwards(playerid)
{
	new
		tmpKey[6],
		buffer[128];

	for(new g; g < MAX_AWARD_GROUP; g++)
	{
		format(tmpKey, 6, "awd%d", g);
		file_GetStr(tmpKey, buffer);
		if(file_IsKey(tmpKey))sscanf(buffer, "p<|>a<d>["#MAX_AWARD"]", pAwardData[playerid][g]);
	}
}


SaveDMStats(playerid)
{
	new
		tmpQuery[256];

	format(tmpQuery, sizeof(tmpQuery), "\
		UPDATE `Deathmatch` SET \
		`"#ROW_KILLS"` = '%d', \
		`"#ROW_DEATHS"` = '%d', \
		`"#ROW_EXP"` = '%d', \
		`"#ROW_HEADSHOTS"` = '%d', \
		`"#ROW_TEAMKILLS"` = '%d', \
		`"#ROW_HIGHSTREAK"` = '%d', \
		`"#ROW_WINS"` = '%d', \
		`"#ROW_LOSSES"` = '%d' \
		WHERE `"#ROW_NAME"` = '%s'",
		dm_PlayerData[playerid][dm_Kills],
		dm_PlayerData[playerid][dm_Deaths],
		dm_PlayerData[playerid][dm_Exp],
		dm_PlayerData[playerid][dm_HeadShots],
		dm_PlayerData[playerid][dm_TeamKills],
		dm_PlayerData[playerid][dm_HighStreak],
		dm_PlayerData[playerid][dm_Wins],
		dm_PlayerData[playerid][dm_Losses],
		gPlayerName[playerid]);

	db_free_result(db_query(gAccounts, tmpQuery));
}
SaveDMLoadout(playerid)
{
	new
	    line[128],
	    tmpStr[8],
		tmpKey[8];

	for(new c;c<MAX_KIT;c++)
	{
	    format(tmpKey, 8, "dml%d", c);
	    if(pLoadout[playerid][c][WEAPON_SLOT_MELEE]==0)pLoadout[playerid][c][WEAPON_SLOT_MELEE] = 4;
	    if(pLoadout[playerid][c][WEAPON_SLOT_SIDEARM]==0)pLoadout[playerid][c][WEAPON_SLOT_SIDEARM] = 22;
	    if(pLoadout[playerid][c][WEAPON_SLOT_PRIMARY]==0)pLoadout[playerid][c][WEAPON_SLOT_PRIMARY] = 29;
	    for(new s;s<MAX_LOADOUT_WEP;s++)
	    {
	        valstr(tmpStr, pLoadout[playerid][c][s]);
	        strcat(line, tmpStr);
	        if(s<(MAX_LOADOUT_WEP-1))strcat(line, "|");
	    }
		file_SetStr(tmpKey, line);
		line[0] = EOS;
	}
	file_SetVal("dmlg", pGraphic[playerid]);
}
SaveDMAwards(playerid)
{
	new
	    line[128],
	    tmpKey[8],
		tmpStr[6];

	for(new g;g<MAX_AWARD_GROUP;g++)
	{
	    format(tmpKey, 8, "awd%d", g);
	    for(new s;s<gTotalAwardsOfGroup[g];s++)
	    {
			format(tmpStr, 6, "%d|", pAwardData[playerid][g][s]);
			strcat(line, tmpStr);
	    }
		file_SetStr(tmpKey, line);
		line[0] = EOS;
	}
}

EndDeathmatch()
{
	SetGameModeText("Freeroam [No DM]");
	SetMapName("San Andrawesome");

	StopMatchTime();
	for(new i=0;i<MAX_CP;i++)
	{
		CPowner[i]=-1;
		CPfill[i]=0;
	}
	PlayerLoop(i)
	{
		CapturingCP[i]=-1;
		if(dm_Mode==DM_MODE_AD)
		{
		   	DestroyDynamicArea(PointToCapture);
		   	StopMatchTime();
			DestroyDynamicMapIcon(CaptureIcon);
			DestroyProgressBar(ADbar);
		}
		if(dm_Mode==DM_MODE_CTF)
		{
			DestroyDynamicPickup(CtfFlag[0]);
			DestroyDynamicPickup(CtfFlag[1]);
			RemovePlayerMapIcon(i, CtfIcon);
		}
		if(dm_Mode==DM_MODE_CQS)
		{
			for(new cp=0;cp<MAX_CP;cp++)
			{
				DestroyDynamicArea(CPflag[cp]);
				DestroyDynamic3DTextLabel(CPlabel[cp][0]);
				DestroyDynamic3DTextLabel(CPlabel[cp][1]);
				DestroyDynamicMapIcon(CPicon[cp][0]);
				DestroyDynamicMapIcon(CPicon[cp][1]);
				DestroyProgressBar(CPbar[cp]);
			}
		}
	}
	UnloadDM();
	ResetDMVariables();
	PlayerLoop(i)if(bPlayerGameSettings[i]&InDM)ExitDeathmatch(i);
}
UnloadDM()
{
	foreach(new i : dm_VehicleTableIndex)
		DestroyVehicle(dm_VehicleTable[i]);

	foreach(new i : dm_ObjectTableIndex)
		DestroyDynamicObject(dm_ObjectTable[i]);

	printf("Deathmatch Map Unloaded: %d Object Count: %d", dm_Map, Iter_Count(dm_ObjectTableIndex));
	Iter_Clear(dm_ObjectTableIndex);
}

ResetPlayerMatchStats(playerid)
{
	dm_PlayerData[playerid][dm_RoundExp] = 0;
	dm_PlayerData[playerid][dm_RoundKills] = 0;
	dm_PlayerData[playerid][dm_RoundDeaths] = 0;
}
ResetPlayerDMVariables(playerid)
{
	flag_ShotBy			[playerid]		= -1;
	dm_PlayerSpawn		[playerid][0]	= 0.0;
	dm_PlayerSpawn		[playerid][1]	= 0.0;
	dm_PlayerSpawn		[playerid][2]	= 0.0;
	CapturingCP			[playerid]		= -1;

	tick_LastKill		[playerid]		= 0;
	tick_LastDeath		[playerid]		= 0;
	tick_LastShot		[playerid]		= 0;
	tick_Spotted		[playerid]		= 0;

	flag_LastKill		[playerid]		= -1;
	flag_LastShot		[playerid]		= -1;
	flag_ShotBy			[playerid]		= -1;
	flag_Spotted		[playerid]		= -1;

	crt_CrateUseTick	[playerid][0]	= 0;
	crt_CrateUseTick	[playerid][1]	= 0;
	crt_CrateUseTick	[playerid][2]	= 0;
}
ResetDMVariables()
{
	dm_TeamScore[score_Kills][0]		= 0,
	dm_TeamScore[score_Kills][1]		= 0,
	dm_TeamScore[score_Flags][0]		= 0,
	dm_TeamScore[score_Flags][1]		= 0,
	dm_TeamScore[score_Tickets][0]		= 100,
	dm_TeamScore[score_Tickets][1]		= 100,
	dm_ScoreLimit						= 10,
	dm_FlagLimit						= 10,

	ADfill								= 0,
	MaxPoints							= 0,
	CaptureProgress						= 0;

	for(new i;i<3;i++)
	{
		CapturePoint[i][0]				= 0.0,
		CapturePoint[i][1]				= 0.0,
		CapturePoint[i][2]				= 0.0;

		CtfPosF[0][i]					= 0.0,
		CtfPosF[1][i]					= 0.0;
	}
	PointCT=false,
	capturer=-1,
	ADfill=0,
	ADcaptureTime=30;

	for(new cp;cp<MAX_CP;cp++)
	{
		CPowner			[cp]			= -1;
		CPpoint			[cp][0]			= 0.0;
		CPpoint			[cp][1]			= 0.0;
		CPpoint			[cp][2]			= 0.0;
		CPOfSet			[cp][0]			= 0.0;
		CPOfSet			[cp][1]			= 0.0;
		CPOfSet			[cp][2]			= 0.0;
		CPfill			[cp]			= 0;
		CPtimer			[cp]			= false;
		FirstToCapture	[cp]			= -1;
	}

	dm_Host								= -1,
	dm_Map								= -1,
	dm_Mode								= -1,
	dm_MsuActive		[0]				= false,
	dm_MsuActive		[1]				= false,
	dm_CombatZonePos	[0]				= 0.0,
	dm_CombatZonePos	[1]				= 0.0,
	dm_CombatZonePos	[2]				= 0.0,
	dm_CombatZonePos	[3]				= 0.0,
	dm_Weather							= 0,
	dm_TimeH							= 0,
	dm_TimeM							= 0,
	bitFalse(bServerGlobalSettings, dm_InProgress);
	bitFalse(bServerGlobalSettings, dm_Started);

}
ResetDMSettings()
{
	dm_ScoreLimit						= 20;
	dm_FlagLimit						= 5;
	dm_TeamScore[score_Tickets][0]		= 100;
	dm_TeamScore[score_Tickets][1]		= 100;
	dm_MatchTimeLimit					= 20;
	dm_LobbyCount						= MAX_LOBBY_COUNT;
}

//==============================================================================Deathmatch Commands

CMD:dm(playerid, params[])
{
	cmd_joindm(playerid, params);
	return 1;
}

CMD:joindm(playerid, params[])
{
	if(bPlayerDeathmatchSettings[playerid] & dm_Banned)return Msg(playerid, RED, " >  You are banned from ALL deathmatches.");
	
	if(!IsPlayerInFreeRoam(playerid))return 2;

	if(bServerGlobalSettings & dm_InProgress)
	{
		JoinDeathMatch(playerid);
		MsgAllF(YELLOW, "%P"#C_YELLOW" Has joined the Deathmatch, type "#C_BLUE"/joindm"#C_YELLOW" to join", playerid);
	}
	else
	{
	    if(!IsPlayerConnected(dm_Host))dm_Host=-1;
		if(dm_Host == -1 || dm_Host == playerid)
		{
			ShowPlayerDialog(playerid, d_RegionSelect, DIALOG_STYLE_LIST, "Choose a map style category", dm_RegionList, "Accept", "Info");
			TogglePlayerControllable(playerid, false);
			dm_Host = playerid;
		}
		else if(dm_Host != -1)MsgF(playerid, YELLOW, " >  %P"#C_YELLOW" is already starting a deathmatch", dm_Host);
	}
	return 1;
}
ACMD:stopdm[1](playerid, params[])
{
	if(bServerGlobalSettings & dm_InProgress)
	{
		PlayerLoop(i)
			if( (bPlayerGameSettings[playerid] & InDM) || (bPlayerDeathmatchSettings[playerid] & dm_InLobby) )
				Msg(i, YELLOW, " >  DM Ended by Admin");

		EndDeathmatch();
	}
	return 1;
}
CMD:raven(playerid, params[])
{
	if(bPlayerGameSettings[playerid]&InDM)Msg(playerid, GREEN, " >  Use the spawn menu when in a deathmatch");
	else
	{
		if(bServerGlobalSettings&FreeDM)
		{
			dm_SetPlayerHP(playerid, 100.0);
			SetPlayerArmour(playerid, 0.0);
			SetPlayerToTeam(playerid, 0);

			Msg(playerid, LGREEN, "dm_Team: Raven, This is now your spawn point");
			MsgAllF(GREEN, " >  %P"#C_GREEN" Has Joined The Raven dm_Team", playerid);

			new Float:x, Float:y, Float:z, Float:rot;
			GetPlayerPos(playerid, x, y, z);
			GetPlayerFacingAngle(playerid, rot);
			SetSpawnInfo(playerid, 0, KitSkins[0][dm_PlayerData[playerid][dm_Kit]], x, y, z, rot, 0, 0, 0, 0, 0, 0);
		}
		else Msg(playerid, RED, "Free For All Deathmatch mode is disabled, ask an online admin to enable it.");
	}
	return 1;
}
CMD:valor(playerid, params[])
{
	if(bPlayerGameSettings[playerid]&InDM)Msg(playerid, GREEN, " >  Use the spawn menu when in a deathmatch");
	else
	{
		if(bServerGlobalSettings&FreeDM)
		{
			dm_SetPlayerHP(playerid, 100.0);
			SetPlayerArmour(playerid, 0.0);
			SetPlayerToTeam(playerid, 1);

			Msg(playerid, LGREEN, "dm_Team: Valor, This is now your spawn point");
			MsgAllF(GREEN, " >  %P"#C_GREEN" Has Joined The Valor dm_Team", playerid);

			new Float:x, Float:y, Float:z, Float:rot;
			GetPlayerPos(playerid, x, y, z);
			GetPlayerFacingAngle(playerid, rot);
			SetSpawnInfo(playerid, 1, KitSkins[1][dm_PlayerData[playerid][dm_Kit]], x, y, z, rot, 0, 0, 0, 0, 0, 0);
		}
		else Msg(playerid, RED, "Free For All Deathmatch mode is disabled, ask an online admin to enable it.");
	}
	return 1;
}
CMD:free(playerid, params[])
{
	if(bPlayerGameSettings[playerid]&InDM)Msg(playerid, GREEN, "Use the spawn menu when in a deathmatch");
	else
	{
		if(bServerGlobalSettings&FreeDM)
		{
			dm_SetPlayerHP(playerid, 100.0);
			SetPlayerArmour(playerid, 0.0);
			pTeam(playerid)=playerid+10;

			Msg(playerid, LGREEN, "You have left your dm_Team, you are now fighting for yourself!");

			new Float:x, Float:y, Float:z, Float:rot;
			GetPlayerPos(playerid, x, y, z);
			GetPlayerFacingAngle(playerid, rot);
			SetSpawnInfo(playerid, playerid+10, gPlayerData[playerid][ply_Skin], x, y, z, rot, 0, 0, 0, 0, 0, 0);
		}
		else Msg(playerid, RED, "Free For All Deathmatch mode is disabled, ask an online admin to enable it.");
	}
	return 1;
}
CMD:shotby(playerid, params[])
{
	new id = strval(params);
	dm_SetPlayerHP(playerid, gPlayerHP[playerid]-10.0, id, 31);
	return 1;
}
CMD:bleedout(playerid, params[])
{
	new id, wep;
	sscanf(params, "dd", id, wep);
	dm_SetPlayerHP(playerid, 0.0, id, wep, 0);
	return 1;
}
CMD:minekill(playerid, params[])
{
	new id = strval(params);
	dm_SetPlayerHP(playerid, 0.0, id, 39);
	return 1;
}
CMD:jdm(playerid,params[])
{
	new r;
	if(!sscanf(params,"d",r))OnPlayerCommandText(r, "/joindm");
	return 1;
}
CMD:jdmr(playerid,params[])
{
	new p;
	if(!sscanf(params,"d",p))
	{
		if(bServerGlobalSettings&dm_InProgress)
		{
			if(bServerGlobalSettings&dm_Started)JoinQueue(p);
			else
			{
				HideMenuForPlayer(dm_LobbyMenu, p);
				bitTrue(bPlayerDeathmatchSettings[p], dm_Ready);
				dm_FormatLobbyInfo(p);
				new r;
				PlayerLoop(i)if(bPlayerDeathmatchSettings[i] & dm_Ready)r++;
				if( (r==GetPlayersInLobby()) && (GetPlayersInLobby()>=MIN_DM_PLAYERS) )
				{
					dm_LobbyCount=10;
					bitTrue(bServerGlobalSettings, dm_LobbyCounting);
				}
			}
		}
		else HideMenuForPlayer(dm_LobbyMenu, p);
	}
	return 1;
}
CMD:getaward(playerid, params[])
{
	new id = strval(params);
    ShowAwardNotif(playerid, AwardData[id][aw_Name]);
	return 1;
}
CMD:getaward2(playerid, params[])
{
	pStatCount[playerid][st_Wep][_:13] = 10;
	pStatCount[playerid][st_Obj][st_CtfCaps] = 21;
	pStatCount[playerid][st_Ktp][st_KtRevenge] = 30;
	AwardDataUpdate(playerid, .wp=1, .obj=1, .ktp=1);
	return 1;
}

CMD:setcapturing(playerid, params[])
{
	new id = strval(params);
	t:bPlayerDeathmatchSettings[id]<dm_Capturing>;
	return 1;
}
CMD:notcapturing(playerid, params[])
{
	new id = strval(params);
	f:bPlayerDeathmatchSettings[id]<dm_Capturing>;
	return 1;
}
CMD:setteam(playerid, params[])
{
	new id, t;
	sscanf(params, "dd", id, t);
	SetPlayerToTeam(id, t);
	return 1;
}

CMD:matchstats(playerid, params[])
{
	new str[128];

	format(str, 128, "Current Match Stats:\n\nExp: %d\nKills: %d\nDeaths: %d",
		dm_PlayerData[playerid][dm_RoundExp], dm_PlayerData[playerid][dm_RoundKills], dm_PlayerData[playerid][dm_RoundDeaths]);

	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Match Stats", str, "Close", "");
	
	return 1;
}
