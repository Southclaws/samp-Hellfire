#define MAX_ITEMS   56

enum itemENUM
{
	itemName[32],
	itemModel,
	itemExtra
}

new
    ItemData[MAX_ITEMS][itemENUM]=
	{
	    // Weapons
		{"Fist",			000, 0}, 	// 0
		{"Knuckle Duster",	331, 0}, 	// 1
		{"Golf Club",		333, 0}, 	// 2
		{"Baton", 			334, 0}, 	// 3
		{"Knife",			335, 0}, 	// 4
		{"Baseball Bat",	336, 0}, 	// 5
		{"Spade",			337, 0}, 	// 6
		{"Pool Cue",		338, 0}, 	// 7
		{"Sword",			339, 0}, 	// 8
		{"Chainsaw",		341, 0}, 	// 9
		{"Dildo",			321, 0}, 	// 10
		{"Dildo",			322, 0}, 	// 11
		{"Dildo",			323, 0}, 	// 12
		{"Dildo",			324, 0}, 	// 13
		{"Flowers",			325, 0}, 	// 14
		{"Cane",			326, 0}, 	// 15
		{"Grenade",			342, 1}, 	// 16
		{"Teargas",			343, 1}, 	// 17
		{"Molotov",			344, 1}, 	// 18
		{"<null>",			000, 0}, 	// 19
		{"<null>",			000, 0}, 	// 20
		{"<null>",			000, 0}, 	// 21
		{"M9",				346, 17},	// 22   // 9mm
		{"M9 SD",			347, 17}, 	// 23   // 9mm
		{"Desert Eagle",	348, 7}, 	// 24   // .50
		{"Shotgun",			349, 1}, 	// 25   // 12g
		{"Sawnoff",			350, 2}, 	// 26   // 12g
		{"Spas 12",			351, 7}, 	// 27   // 12g
		{"Mac 10",			352, 100}, 	// 28   // 10mm
		{"MP5",				353, 30},	// 29   // 9mm
		{"AK-47",			355, 30},	// 30   // 5.56
		{"M4-A1",			356, 50},	// 31   // 5.56
		{"Tec 9",			372, 100},	// 32   // 10mm
		{"Rifle",			357, 1},	// 33   // .308
		{"Sniper",			358, 1},	// 34   // .308
		{"RPG-7",			359, 1},	// 35   // rocket
		{"Heatseek",		360, 1},	// 36   // rocket
		{"Flamer",			361, 100},	// 37   // fuel
		{"Chaingun",		362, 500},	// 38   // fuel
		{"C4",				363, 1},	// 39
		{"Detonator",		364, 1},	// 40
		{"Spray Paint",		365, 1},	// 41
		{"Extinguisher",	366, 1},	// 42
		{"Camera",			367, 1},	// 43
		{"Night Vision",	000, 1},	// 44
		{"Thermal Vision",	000, 1},	// 45
		{"Parachute",		371, 1},	// 46

		// Ammo
		{"9mm Round",		000, 0},
		{".50 Round",		000, 0},
		{"5.56 Round",		000, 0},
		{"7.62 Round",		000, 0},
		{".308 Round",		000, 0},
		{"12 Guage",		000, 0},
		
		// Other
		{"Health",			344, 0},
		{"Radio",			000, 0},
		{"Food",			000, 0}
	};
