#include <YSI\y_hooks>

new
	ItemType:item_HardDrive		= INVALID_ITEM_TYPE,
	ItemType:item_Key			= INVALID_ITEM_TYPE,
	ItemType:item_timer			= INVALID_ITEM_TYPE,
	ItemType:item_explosive		= INVALID_ITEM_TYPE,
	ItemType:item_battery		= INVALID_ITEM_TYPE,
	ItemType:item_fusebox		= INVALID_ITEM_TYPE;

new
	RanchPcButton,
	RanchHdd,
	RanchPcState = 0,
	RanchPcObj,
	RanchPcCam,
	RanchPcPlayerViewing[MAX_PLAYERS],

	QuarryShedNote,
	QuarryShedPC,
	QuarryDoor,
	QuarryDoorKey,
	QuarryDoorState,
	CaveDoor,
	CaveLift,
	CaveLiftButtonT,
	CaveLiftButtonB,
	LiftPos,

	OutskirtsElevator,
	ElevatorPos;


new
	MAP23_ElevatorT,
	MAP23_ElevatorB;


public OnLoad()
{
	RanchHdd			= CreateItem(item_HardDrive, -693.1787, 942.0, 15.93, 90.0, 0.0, 37.5, .zoffset = FLOOR_OFFSET);
	QuarryDoorKey		= CreateItem(item_Key, -2813.96, -1530.55, 140.97, 0.36, -85.14, 25.00);


	CreateItem(item_Beer, 2121.0, -1864.0, 12.69, .zoffset = FLOOR_OFFSET);
	CreateItem(item_Beer, 2117.0, -1876.0, 12.69, .zoffset = FLOOR_OFFSET);
	CreateItem(item_Beer, 2115.0, -1872.0, 12.69, .zoffset = FLOOR_OFFSET);
	CreateItem(item_Beer, 2124.0, -1875.0, 12.69, .zoffset = FLOOR_OFFSET);

	CreateItem(item_timer, -102.15, 1365.88, 9.27, -90.00, 0.00, -128.00, .zoffset = FLOOR_OFFSET);
	CreateItem(item_explosive, -101.23, 1371.59, 9.35, 0.00, 0.00, 0.00, .zoffset = FLOOR_OFFSET);

	DefineItemCombo(item_timer, item_explosive, item_timebomb);


	// Ziplines in SF (for testing)
    CreateZipline(
		-2176.1233, 624.6251, 64.5186,
		-2199.2416, 599.1184, 58.2986);

    CreateZipline(
		-2172.7917, 598.8414, 71.2611,
		-2225.6408, 661.6533, 67.7622);

	// Ziplines in Las Colinas parkour map
    CreateZipline(
		2159.08, -986.47, 70.59,
		2063.30, -993.57, 59.38, .worldid = 3);

    CreateZipline(
		2152.75, -1027.94, 73.47,
		2191.36, -1051.42, 57.25, .worldid = 3);

    CreateZipline(
		2228.26, -1120.77, 48.88,
		2200.78, -1096.47, 42.13, .worldid = 3);

	CreateLadder(1177.6424, -1305.6337, 13.9241, 29.0859, 0.0);
	CreateLadder(-1164.6187, 370.0174, 1.9609, 14.1484, 221.1218);
	CreateLadder(-1182.6258, 60.4429, 1.9609, 14.1484, 134.2914);
	CreateLadder(-1736.4494, -445.9549, 1.9609, 14.1484, 270.7138);
	CreateLadder(-1392.0263, -15.0978, 213.9799, 234.0190, 183.5498);
	CreateLadder(-2208.4399, 646.6311, 53.9300, 63.7599, 90.7508);

	AddSprayTag(1172.8808, -1313.0510, 14.2463, 10.0, 0.0, 180.0);
	AddSprayTag(1237.39, -1631.60, 28.02, 0.00, 0.00, 91.00);
	AddSprayTag(1118.51, -1540.14, 24.66, 0.00, 0.00, 178.46);
	AddSprayTag(1202.11, -1201.55, 20.47, 0.00, 0.00, 90.00);
	AddSprayTag(1264.15, -1270.28, 15.16, 0.00, 0.00, 270.00);
	AddSprayTag(-399.77, 1514.92, 76.96, 0.00, 0.00, 0.00);
	AddSprayTag(-2442.17, 2299.23, 5.71, 0.00, 0.00, 270.00);
	AddSprayTag(-2662.95, 2121.44, 2.14, 0.00, 0.00, 180.00);
	AddSprayTag(-229.34, 1082.35, 20.89, 0.00, 0.00, 0.00);
	AddSprayTag(146.92, 1831.78, 18.02, 0.00, 0.00, 90.00);
	AddSprayTag(2267.55, 1518.13, 46.33, 0.00, 0.00, 180.00);
	AddSprayTag(-1908.91, 299.56, 41.52, 0.00, 0.00, 180.00);
	AddSprayTag(-2636.70, 635.52, 15.63, 0.00, 0.00, 0.00);
	AddSprayTag(-2224.75, 881.27, 84.13, 0.00, 0.00, 90.00);
	AddSprayTag(-1788.32, 748.42, 25.36, 0.00, 0.00, 270.00);

	RanchPcCam = LoadCameraMover("ranch");
	CreateDynamicObject(2574, -2811.88, -1530.59, 139.84, 0.00, 0.00, 180.00);
	CaveLift=CreateDynamicObject(7246, -2759.4704589844, 3756.869140625, 6.9, 270, 180, 340.91540527344, FREEROAM_WORLD);

	new
		buttonid[2];


	// Probe Inn

	buttonid[0]=CreateButton(-101.579933, 1374.613769, 10.4698, "Press F to enter", FREEROAM_WORLD, 0);
	buttonid[1]=CreateButton(-217.913787, 1402.804199, 27.7734, "Press F to exit", FREEROAM_WORLD, 18);
	LinkTP(buttonid[0], buttonid[1]);


	// SF Hideout 1
	
	buttonid[0] = CreateButton(-2208.2568, 579.8558, 35.7653, "Press F to activate", FREEROAM_WORLD);
	buttonid[1] = CreateButton(-2208.2561, 584.4679, 35.7653, "Press F to activate", FREEROAM_WORLD);
	CreateDoor(16501, buttonid,
		-2211.40, 581.99, 36.37,   0.00, 0.00, 90.00,
		-2211.40, 581.99, 39.61,   0.00, 0.00, 90.00);

	buttonid[0] = CreateButton(-2243.0400, 640.7287, 49.9911, "Press F to activate", FREEROAM_WORLD);
	buttonid[1] = CreateButton(-2238.6035, 641.0287, 49.9911, "Press F to activate", FREEROAM_WORLD);
	CreateDoor(16501, buttonid,
		-2241.90, 643.55, 50.69,   0.00, 0.00, 0.00,
		-2241.90, 643.55, 53.96,   0.00, 0.00, 0.00);

// ABD World Stuff

	// Quarry

	RanchPcButton = CreateButton(-691.1692, 942.1066, 13.6328, "Press F to use", FREEROAM_WORLD);
	QuarryShedNote = CreateButton(491.629486, 782.667846, -22.067182, "Press F to use", FREEROAM_WORLD);
	QuarryShedPC = CreateButton(489.710601, 785.067932, -22.021251, "Press F to use", FREEROAM_WORLD);

	QuarryDoor = CreateButton(495.451873, 780.096191, -21.747426, "Press F to enter", FREEROAM_WORLD); // quarry
	CaveDoor = CreateButton(-2702.358398, 3801.477050, 52.652801, "Press F to enter", FREEROAM_WORLD); // cave 1

	buttonid[0]=CreateButton(-2811.1840, -1524.0532, 140.8437, "Press F to enter", FREEROAM_WORLD);
	CreateDoor(1497, buttonid,
		-2811.41, -1524.75, 139.84,   0.00, 0.00, 455.82,
		-2811.41, -1524.72, 139.84,   0.00, 0.00, 570.18, .maxbuttons = 1, .movespeed = 0.1);

	buttonid[0]=CreateButton(-2821.0671, -1518.6484, 140.8437, "Press F to enter", FREEROAM_WORLD);
	CreateDoor(1497, buttonid,
		-2821.19, -1519.46, 139.84, 0.00, 0.00, 450.60,
		-2821.19, -1519.44, 139.84, 0.00, 0.00, 353.28, .maxbuttons = 1, .movespeed = 0.1);


	buttonid[0]=CreateButton(-2796.933349, 3682.779785, 02.515481, "Press F to enter", FREEROAM_WORLD); // cave 1
	buttonid[1]=CreateButton(-785.9272, 3727.1111, 0.5293, "Press F to enter", FREEROAM_WORLD); // cave 2
	LinkTP(buttonid[0], buttonid[1]);

	// Subway/Metro interior 1=inside 2=surface

	buttonid[0]=CreateButton(-1007.395263, 5782.741210, 42.951477, "Press F to climb up the ladder", FREEROAM_WORLD);
	buttonid[1]=CreateButton(2526.719482, -1648.620605, 14.471982, "Press F to climb down the ladder", FREEROAM_WORLD);
	LinkTP(buttonid[0], buttonid[1]);

	buttonid[0]=CreateButton(250.599380, -154.643936, -50.768798, "Press F to enter", FREEROAM_WORLD);
	buttonid[1]=CreateButton(247.878799, -154.444061, 02.399550, "Press F to enter", FREEROAM_WORLD);
	LinkTP(buttonid[0], buttonid[1]);

	buttonid[0]=CreateButton(-2276.608642, 5324.488281, 41.677970, "Press F to enter", FREEROAM_WORLD);
	buttonid[1]=CreateButton(-734.773986, 3861.994628, 12.482711, "Press F to enter", FREEROAM_WORLD); // cave
	LinkTP(buttonid[0], buttonid[1]);

	// Fort Claw underground

	buttonid[0]=CreateButton(246.698684, -178.849655, -50.199367, "Press F to enter", FREEROAM_WORLD); // underground
	buttonid[1]=CreateButton(-952.559326, 5137.799804, 46.183383, "Press F to enter", FREEROAM_WORLD); // metro station
	LinkTP(buttonid[0], buttonid[1]);

	CreateButton(-972.153869, 4303.185058, 48.666248, "~r~Locked", FREEROAM_WORLD);

	// Lift Sequence

	CaveLiftButtonT=CreateButton(-2764.0332, 3757.0466, 46.8343, "Press F to use the lift", FREEROAM_WORLD);
	CaveLiftButtonB=CreateButton(-2764.3410, 3755.5153, 8.2390, "Press F to use the lift", FREEROAM_WORLD);
	LiftPos=0;

	// Fort Claw Door

	buttonid[0] = CreateButton(264.316284, -171.135223, -50.206447, "Press F to activate", FREEROAM_WORLD);
	buttonid[1] = CreateButton(265.862182, -170.113632, -50.204307, "Press F to activate", FREEROAM_WORLD);
	CreateDoor(5779, buttonid,
		265.0330, -168.9362, -49.9792, 0.0, 0.0, 0.0,
		265.0322, -168.9355, -46.8575, 0.0, 0.0, 0.0,
		.worldid = FREEROAM_WORLD);

	// Brokenfac
	
	buttonid[0] = CreateButton(-917.56622300, 336.82446300, -4.09188300, "Press F", FREEROAM_WORLD);
	CreateDoor(1966, buttonid,
		-917.56622300, 336.82446300, -4.09188300, 0.0, 0.0, -90.0,
		-917.60461400, 336.83703600, -0.66687700, 0.0, 0.0, -90.0,
		.worldid = FREEROAM_WORLD, .maxbuttons = 1);

	buttonid[0] = CreateButton(-927.35900900, 323.35788000, -4.18895400, "Press F", FREEROAM_WORLD);
	CreateDoor(1966, buttonid,
		-927.35900900, 323.35788000, -4.18895400, 0.0, 0.0, 0.0,
		-927.57336400, 323.29223600, 0.54039900, 0.0, 0.0, 0.0,
		.worldid = FREEROAM_WORLD, .maxbuttons = 1);

	buttonid[0] = CreateButton(-917.47625700, 293.18270900, -4.15709200, "Press F", FREEROAM_WORLD);
	CreateDoor(1966, buttonid,
		-917.47625700, 293.18270900, -4.15709200, 0.0, 0.0, -90.0,
		-917.46575900, 293.12200900, -0.42325200, 0.0, 0.0, -90.0,
		.worldid = FREEROAM_WORLD, .maxbuttons = 1);


// Deathmatch Stuff
	buttonid[0] = CreateButton(-1280.388549, -141.772979, 721.0, "Press F to enter", DEATHMATCH_WORLD);
	buttonid[1] = CreateButton(-1278.898193, -141.713790, 721.0, "Press F to enter", DEATHMATCH_WORLD);
	LinkTP(buttonid[0], buttonid[1]);

	buttonid[0] = CreateButton(-1337.346191, -143.784347, 721.0, "Press F to enter", DEATHMATCH_WORLD);
	buttonid[1] = CreateButton(-1337.411132, -145.632156, 721.0, "Press F to enter", DEATHMATCH_WORLD);
	LinkTP(buttonid[0], buttonid[1]);

	buttonid[0] = CreateButton(-1392.069946, -15.105671, 713.0, "Press F to climb up", DEATHMATCH_WORLD);
	buttonid[1] = CreateButton(-1392.069946, -17.105671, 733.0, "Press F to climb down", DEATHMATCH_WORLD);
	LinkTP(buttonid[0], buttonid[1]);

	OutskirtsElevator=CreateDynamicObject(18755, -1293.7974, -773.43, 215.1900, 0.0000, 0.0000, 270.0000, DEATHMATCH_WORLD);
	MAP23_ElevatorB=CreateButton(-1293.7974, -773.43, 215.1900, "Press F to activate", DEATHMATCH_WORLD);
	MAP23_ElevatorT=CreateButton(-1293.7974, -773.43, 223.79, "Press F to activate", DEATHMATCH_WORLD);


// Army base interior

	// Front Gate
	buttonid[0] = CreateButton(97.6948, 1918.5541, 18.1833, "Press to activate gate");//frontin
	buttonid[1] = CreateButton(95.7846, 1918.5755, 18.1172, "Press to activate gate");//frontout
	CreateDoor(969, buttonid,
		96.902634, 1918.947876, 17.330902, 0.0, 0.0, 90.0,
		96.886208, 1922.040039, 17.310095, 0.0, 0.0, 90.0);

	// Front Blast Doors
	buttonid[0] = CreateButton(210.3842, 1876.6578, 13.1406, "Press to activate door");
	buttonid[1] = CreateButton(209.5598, 1874.3828, 13.1469, "Press to activate door");
	CreateDoor(2927, buttonid,
		215.9915, 1875.2880, 13.9389, 0.0, 0.0, 0.0,
		219.8936, 1875.2880, 13.9389, 0.0, 0.0, 0.0, .movespeed = 0.4);
	CreateDoor(2929, buttonid,
		211.8555, 1875.2880, 13.9389, 0.0, 0.0, 0.0,
		207.8556, 1875.2880, 13.9389, 0.0, 0.0, 0.0, .movespeed = 0.4);

	// First door - to storage room
	buttonid[0] = CreateButton(237.4928,1871.3110,11.4609, "Press to activate door");
	buttonid[1] = CreateButton(239.3345,1870.4381,11.4609, "Press to activate door");
	CreateDoor(5422, buttonid,
		238.4573, 1872.2921, 12.4737, 0.0, 0.0, 0.0,
		238.4573, 1872.2921, 14.6002, 0.0, 0.0, 0.0);

	// Storage room to generator room
	buttonid[0] = CreateButton(247.3196, 1842.8588, 8.7614, "Press to activate door");
	buttonid[1] = CreateButton(247.3196, 1840.5961, 8.7578, "Press to activate door");
	CreateDoor(5422, buttonid,
		248.275406, 1842.032104, 9.7770, 0.0, 0.0, 90.0,
		248.270325, 1842.033691, 11.9806, 0.0, 0.0, 90.0);

	// Big doors in storage room leading to passage
	buttonid[0] = CreateButton(255.3204, 1842.7847, 8.7578, "Press to activate door");
	buttonid[1] = CreateButton(257.0612, 1843.4278, 8.7578, "Press to activate door");
	CreateDoor(9093, buttonid,
		256.3291, 1845.7827, 9.5281, 0.0, 0.0, 0.0,
		256.3291, 1845.7827, 12.1, 0.0, 0.0, 0.0);

	// Big doors in generator room leading to passage
	buttonid[0] = CreateButton(255.5610, 1832.4649, 4.7109, "Press to activate door");
	buttonid[1] = CreateButton(257.0517, 1833.1218, 4.7109, "Press to activate door");
	CreateDoor(9093, buttonid,
		256.3094, 1835.3549, 5.4820, 0.0, 0.0, 0.0,
		256.3094, 1835.3549, 8.0035, 0.0, 0.0, 0.0);

	// Generator room leading to walkway
	buttonid[0] = CreateButton(249.3303, 1805.2384, 7.4796, "Press to activate door");
	buttonid[1] = CreateButton(249.0138, 1806.8889, 7.5546, "Press to activate door");
	CreateDoor(5422, buttonid,
		248.3001, 1805.8772, 8.5633, 0.0, 0.0, 90.0,
		248.3001, 1805.8772, 10.8075, 0.0, 0.0, 90.0);

	// Headquaters room
	buttonid[0] = CreateButton(234.1869,1821.3165,7.4141, "Press to activate door");
	buttonid[1] = CreateButton(228.3555,1820.2427,7.4141, "Press to activate door");
	CreateDoor(1508, buttonid,
		233.793884, 1825.885498, 7.097370, 0.0, 0.0, 0.0,
		233.793884, 1827.063477, 7.097370, 0.0, 0.0, 0.0);
	CreateDoor(1508, buttonid,
		233.793884, 1819.572388, 7.097370, 0.0, 0.0, 0.0,
		233.793884, 1818.413452, 7.097370, 0.0, 0.0, 0.0);

	// Labs to Shaft
	buttonid[0] = CreateButton(269.4969,1873.1721,8.6094, "Press to activate door");
	buttonid[1] = CreateButton(270.6281,1875.8774,8.4375, "Press to activate door");
	CreateDoor(5422, buttonid,
		267.051788, 1875.100952, 9.267685, 0.0, 0.0, 90.0,
		264.048431, 1875.085449, 9.267685, 0.0, 0.0, 90.0);

	return CallLocalFunction("interactive_OnLoad", "");
}
#if defined _ALS_OnLoad
    #undef OnLoad
#else
    #define _ALS_OnLoad
#endif
#define OnLoad interactive_OnLoad
forward interactive_OnLoad();


script_Interactive_ButtonPress(playerid, buttonid)
{
	if(buttonid==RanchPcButton)
	{
	    if(RanchPcState == 0)ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Computer", "You try to turn on the computer but the hard disk is missing.\nYou wonder where it could be and think it's mighty suspicious.\nThere is nothing useful nearby.", "Close", "");
	    if(RanchPcState == 1)
	    {
			if(RanchPcPlayerViewing[playerid])
			{
			    ExitCamera(playerid);
			    TogglePlayerControllable(playerid, true);
			    RanchPcPlayerViewing[playerid] = false;
			}
			else
			{
			    PlayCameraMover(playerid, RanchPcCam, .loop = true, .tp = false);
			    RanchPcPlayerViewing[playerid] = true;
			}
	    }

	}
	if(buttonid==QuarryShedNote)
	{
	    ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Note",
			"The note reads:\n\nThere's been strange goings on in the old shaft next to my work hut!\n\
			I don't want people looking around it so I locked it up. I left a copy of the key in my ranch house\n\
			in ... .. .\n\n\nThe rest of the note has been torn off.", "Close", "");
	}
	if(buttonid==QuarryShedPC)
	{
	    ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Computer", "You try to turn on the computer but the hard disk is missing.\nYou wonder where it could be and think it's mighty suspicious.\nThere is nothing useful nearby.", "Close", "");
	}

	if(buttonid == QuarryDoor)
	{
	    if(QuarryDoorState == 0)ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Door", "You pull on the door but it won't budge, the lock seems sturdy.\nThere's no way you can get through here without a key.\nPerhaps you should search the shed?", "Close", "");
	    else
	    {
			SetPlayerVirtualWorld(playerid, FREEROAM_WORLD);
			SetPlayerPos(playerid, -2702.358398, 3801.477050, 52.652801);
			FreezePlayer(playerid, 1000);
	    }
	}
	if(buttonid == CaveDoor)
	{
	    SetPlayerVirtualWorld(playerid, FREEROAM_WORLD);
		SetPlayerPos(playerid, 495.451873, 780.096191, -21.747426);
	}
	if(buttonid==CaveLiftButtonT)
	{
		if(LiftPos)
		{
		    MoveDynamicObject(CaveLift, -2759.4704589844, 3756.869140625, 6.9, 2.0, 270, 180, 340.9);
		    LiftPos=0;
		}
		else
		{
		    MoveDynamicObject(CaveLift, -2759.4704589844, 3756.869140625, 45.4, 2.0, 270, 180, 340.9);
		    LiftPos=1;
		}
	}
	if(buttonid==CaveLiftButtonB)
	{
		if(LiftPos)
		{
		    MoveDynamicObject(CaveLift, -2759.4704589844, 3756.869140625, 45.4, 2.0, 270, 180, 340.9);
		    LiftPos=0;
		}
		else
		{
		    MoveDynamicObject(CaveLift, -2759.4704589844, 3756.869140625, 6.9, 2.0, 270, 180, 340.9);
		    LiftPos=1;
		}
	}
	if(buttonid==MAP23_ElevatorT)
	{
		if(ElevatorPos)
		{
			MoveDynamicObject(OutskirtsElevator, -1293.7974, -773.43, 215.1900, 3.0);
			ElevatorPos=0;
		}
		else
		{
			MoveDynamicObject(OutskirtsElevator, -1293.7974, -773.43, 223.79, 3.0);
			ElevatorPos=1;
		}
	}
	if(buttonid==MAP23_ElevatorB)
	{
		if(ElevatorPos)
		{
			MoveDynamicObject(OutskirtsElevator, -1293.7974, -773.43, 223.79, 3.0);
			ElevatorPos=0;
		}
		else
		{
			MoveDynamicObject(OutskirtsElevator, -1293.7974, -773.43, 215.1900, 3.0);
			ElevatorPos=1;
		}
	}

	return 1;
}

public OnPlayerUseItemWithButton(playerid, buttonid, itemid)
{
	if(buttonid == RanchPcButton && itemid == RanchHdd)
	{
	    ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Computer", "You begin reattaching the hard drive to the computer.", "Close", "");
		ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 5.0, 0, 0, 0, 1, 450);
		defer AttachRanchHdd(playerid);
	}
	if(QuarryDoorState == 0 && buttonid == QuarryDoor && itemid == QuarryDoorKey)
	{
	    ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Door", "You have unlocked the mystery door!", "Close", "");
	    QuarryDoorState = 1;
	}
    return CallLocalFunction("int_OnPlayerUseItemWithButton", "ddd", playerid, buttonid, itemid);
}
#if defined _ALS_OnPlayerUseItemWithButton
    #undef OnPlayerUseItemWithButton
#else
    #define _ALS_OnPlayerUseItemWithButton
#endif
#define OnPlayerUseItemWithButton int_OnPlayerUseItemWithButton
forward int_OnPlayerUseItemWithButton(playerid, buttonid, itemid);


timer AttachRanchHdd[2500](playerid)
{
	DestroyItem(RanchHdd);
	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Computer", "You successfully install the hard drive without electricuting yourself, well done!", "Close", "");
    ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_2IDLE", 4.0, 0, 0, 0, 0, 0);
    RanchPcState = 1;

	RanchPcObj = CreateDynamicObject(19475, -690.966735, 942.852416, 13.642812, 0.000000, 0.000000, -110.324981),
	SetDynamicObjectMaterialText(RanchPcObj, 0,
		"system:\n\
		  >login terminal\\root\\user\\steve\n\
		  >open diary\\entry\\recent\n\
		   I have left the ranch, they are after me\n\
		   whoever finds this, I decided to go to a friends\n\
		   place on chilliad, he was dead when I got there\n\
		   I've hidden the key there, they won't find it\n\
		   I dont know how long it will be before they find me",
		OBJECT_MATERIAL_SIZE_512x512, "Courier New", 16, 1, -1, 0, 0);
}

public OnDoorStateChange(doorid, doorstate)
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetDoorPos(doorid, x, y, z);

	if(doorstate == DR_STATE_OPENING || doorstate == DR_STATE_CLOSING)
	{
		PlaySound(6000, x, y, z);
	}
	if(doorstate == DR_STATE_OPEN || doorstate == DR_STATE_CLOSED)
	{
		PlaySound(6002, x, y, z);
	}
}
