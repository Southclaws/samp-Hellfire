#include <YSI\y_hooks>

public OnLoad()
{
	CreateItem(item_timer, -102.15, 1365.88, 9.27, -90.00, 0.00, -128.00, .zoffset = FLOOR_OFFSET);
	CreateItem(item_explosive, -101.23, 1371.59, 9.35, 0.00, 0.00, 0.00, .zoffset = FLOOR_OFFSET);

	DefineItemCraftSet(item_timebomb, item_timer, false, item_explosive, false);

	new
		buttonid[2];
	
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


	buttonid[0] = CreateButton(-1280.388549, -141.772979, 721.0, "Press F to enter", DEATHMATCH_WORLD);
	buttonid[1] = CreateButton(-1278.898193, -141.713790, 721.0, "Press F to enter", DEATHMATCH_WORLD);
	LinkTP(buttonid[0], buttonid[1]);

	buttonid[0] = CreateButton(-1337.346191, -143.784347, 721.0, "Press F to enter", DEATHMATCH_WORLD);
	buttonid[1] = CreateButton(-1337.411132, -145.632156, 721.0, "Press F to enter", DEATHMATCH_WORLD);
	LinkTP(buttonid[0], buttonid[1]);

	buttonid[0] = CreateButton(-1392.069946, -15.105671, 713.0, "Press F to climb up", DEATHMATCH_WORLD);
	buttonid[1] = CreateButton(-1392.069946, -17.105671, 733.0, "Press F to climb down", DEATHMATCH_WORLD);
	LinkTP(buttonid[0], buttonid[1]);

//	OutskirtsElevator=CreateDynamicObject(18755, -1293.7974, -773.43, 215.1900, 0.0000, 0.0000, 270.0000, DEATHMATCH_WORLD);

	return CallLocalFunction("misc_OnLoad", "");
}
#if defined _ALS_OnLoad
    #undef OnLoad
#else
    #define _ALS_OnLoad
#endif
#define OnLoad misc_OnLoad
forward misc_OnLoad();


