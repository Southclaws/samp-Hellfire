/*==============================================================================

Southclaw's Interactivity Framework (SIF) (Formerly: Adventure API)


	This is a simple test gamemode designed to demonstrate the features
	available in the framework.

	SIF/Overview
	{
		SIF is a collection of high-level include scripts to make the
		development of interactive features easy for the developer while
		maintaining quality front-end gameplay for players.
	}

==============================================================================*/


#include <a_samp>
#include <SIF/SIF>



#define TILE_SIZE		(9.0)
#define TILES_X			(24)
#define TILES_Y			(14)
#define ROOM_POS_Z		(500.0)
#define ROOM_HEIGHT		(3)
#define ENTITY_HEIGHT	(ROOM_POS_Z + 1.5)


new
ItemType:	cookie;


main()
{
	print("Southclaw's Interactivity Framework Test Gamemode");
}

public OnGameModeInit()
{
	new temp;

	// Set up the environment

	AddPlayerClass(101, 0.0, 0.0, ENTITY_HEIGHT, 0.0, 0, 0, 0, 0, 0, 0);

	for(new x; x < TILES_X; x++)
	{
		for(new y; y < TILES_Y; y++)
		{
			// Floor
			temp = CreateDynamicObject(3095,
				(x * TILE_SIZE),
				(y * TILE_SIZE),
				ROOM_POS_Z,
				180.0, 0.0, 0.0);

			// Roof
			CreateDynamicObject(3095,
				(x * TILE_SIZE),
				(y * TILE_SIZE),
				ROOM_POS_Z + (TILE_SIZE * ROOM_HEIGHT),
				0.0, 0.0, 0.0);

			// Walls
			if(x == 0)
			{
				for(new i; i < ROOM_HEIGHT; i++)
				{
					temp = CreateDynamicObject(3095,
						(x * TILE_SIZE) - (TILE_SIZE / 2),
						(y * TILE_SIZE),
						ROOM_POS_Z + (i * (TILE_SIZE)) + (TILE_SIZE / 2),
						0.0, 90.0, 0.0);

					SetDynamicObjectMaterial(temp, 0, 18646, "matcolours", "white", 0);
				}
			}
			if(x == TILES_X - 1)
			{
				for(new i; i < ROOM_HEIGHT; i++)
				{
					temp = CreateDynamicObject(3095,
						(x * TILE_SIZE) + (TILE_SIZE / 2),
						(y * TILE_SIZE),
						ROOM_POS_Z + (i * (TILE_SIZE)) + (TILE_SIZE / 2),
						0.0, 90.0, 180.0);

					SetDynamicObjectMaterial(temp, 0, 18646, "matcolours", "white", 0);
				}
			}
			if(y == 0)
			{
				for(new i; i < ROOM_HEIGHT; i++)
				{
					temp = CreateDynamicObject(3095,
						(x * TILE_SIZE),
						(y * TILE_SIZE) - (TILE_SIZE / 2),
						ROOM_POS_Z + (i * (TILE_SIZE)) + (TILE_SIZE / 2),
						90.0, 0.0, 180.0);

					SetDynamicObjectMaterial(temp, 0, 18646, "matcolours", "white", 0);
				}
			}
			if(y == TILES_Y - 1)
			{
				for(new i; i < ROOM_HEIGHT; i++)
				{
					temp = CreateDynamicObject(3095,
						(x * TILE_SIZE),
						(y * TILE_SIZE) + (TILE_SIZE / 2),
						ROOM_POS_Z + (i * (TILE_SIZE)) + (TILE_SIZE / 2),
						90.0, 0.0, 0.0);

					SetDynamicObjectMaterial(temp, 0, 18646, "matcolours", "white", 0);
				}
			}
		}

	}


	// Define our data

	cookie = DefineItemType("cookies", 1252, ITEM_SIZE_SMALL);


	// Create entities

	LoadDemoArea_Doors();
}

new
	door_info			[10],
	door_set_obj		[2],
	door_set_delay		[2],
	door_set_speed		[2],
	door_set_sound		[2],
	door_set_posrot		[2],
	door_set_moveposrot	[2];


LoadDemoArea_Doors()
{
	new
		buttonarray[4];

	// Area 1

	CreateObject(1239, -3.90, 4.50, 501.50, 0.00, 0.00, 270.00);
	CreateObject(19273, -4.00, 7.00, 501.50, 0.00, 0.00, 90.00);

	door_info[0] = CreateButton(-3.90, 4.50, ENTITY_HEIGHT, "Press for info", .label = 1, .labeltext = "A simple door. Press to open, press to close.");
	buttonarray[0] = CreateButton(-4.00, 7.00, ENTITY_HEIGHT, "Press to open");

	CreateDoor(19302, buttonarray,
		-3.00, 9.00, 501.25, 0.00, 0.00, 0.00,
		-4.8, 9.00, 501.25, 0.00, 0.00, 0.00,
		 .maxbuttons = 1, .closedelay = 0);


	// Area 2

	CreateObject(1239, -3.90, 13.50, 501.50, 0.00, 0.00, 270.00);
	CreateObject(19273, -4.00, 16.00, 501.50, 0.00, 0.00, 90.00);

	door_info[1] = CreateButton(-3.90, 13.50, ENTITY_HEIGHT, "Press for info", .label = 1, .labeltext = "A delayed automatically closing door");
	buttonarray[0] = CreateButton(-4.00, 16.00, ENTITY_HEIGHT, "Press to open");

	CreateDoor(19302, buttonarray,
		-3.00, 18.00, 501.25, 0.00, 0.00, 0.00,
		-4.8, 18.00, 501.25, 0.00, 0.00, 0.00,
		 .maxbuttons = 1, .closedelay = 2000);


	// Area 3

	CreateObject(1239, -3.90, 22.50, 501.50, 0.00, 0.00, 270.00);
	CreateObject(19273, -4.00, 25.00, 501.50, 0.00, 0.00, 90.00);
	CreateObject(19273, -4.00, 29.00, 501.50, 0.00, 0.00, 90.00);

	door_info[2] = CreateButton(-3.90, 22.50, ENTITY_HEIGHT, "Press for info", .label = 1, .labeltext = "Multiple door buttons");
	buttonarray[0] = CreateButton(-4.00, 25.00, ENTITY_HEIGHT, "Press to open");
	buttonarray[1] = CreateButton(-4.00, 29.00, ENTITY_HEIGHT, "Press to open");

	CreateDoor(19302, buttonarray,
		-3.00, 27.00, 501.25, 0.00, 0.00, 0.00,
		-4.8, 27.00, 501.25, 0.00, 0.00, 0.00,
		 .maxbuttons = 2, .closedelay = 2000);


	// Area 4

	CreateObject(1239, -3.90, 31.50, 501.50, 0.00, 0.00, 270.00);
	CreateObject(19273, -4.00, 33.00, 501.50, 0.00, 0.00, 90.00);
	CreateObject(19273, -4.00, 35.00, 501.50, 0.00, 0.00, 90.00);
	CreateObject(19273, -4.00, 37.00, 501.50, 0.00, 0.00, 90.00);
	CreateObject(19273, -4.00, 39.00, 501.50, 0.00, 0.00, 90.00);

	door_info[3] = CreateButton(-3.90, 31.50, ENTITY_HEIGHT, "Press for info", .label = 1, .labeltext = "Any number of door buttons");
	buttonarray[0] = CreateButton(-4.00, 33.00, ENTITY_HEIGHT, "Press to open");
	buttonarray[1] = CreateButton(-4.00, 35.00, ENTITY_HEIGHT, "Press to open");
	buttonarray[2] = CreateButton(-4.00, 37.00, ENTITY_HEIGHT, "Press to open");
	buttonarray[3] = CreateButton(-4.00, 39.00, ENTITY_HEIGHT, "Press to open");

	CreateDoor(19302, buttonarray,
		-3.00, 36.00, 501.25, 0.00, 0.00, 0.00,
		-4.8, 36.00, 501.25, 0.00, 0.00, 0.00,
		 .maxbuttons = 4, .closedelay = 2000);


	// Area 5

	CreateObject(1239, -3.90, 40.50, 501.50, 0.00, 0.00, 270.00);
	CreateObject(19273, -4.00, 42.00, 501.50, 0.00, 0.00, 90.00);
	CreateObject(19273, -4.00, 48.00, 501.50, 0.00, 0.00, 90.00);

	door_info[4] = CreateButton(-3.90, 40.50, ENTITY_HEIGHT, "Press for info", .label = 1, .labeltext = "Setting a door's object");
	buttonarray[0] = CreateButton(-4.00, 42.00, ENTITY_HEIGHT, "Press to open");
	door_set_obj[0] = CreateButton(-4.00, 48.00, ENTITY_HEIGHT, "Press to change model");

	door_set_obj[1] = CreateDoor(19302, buttonarray,
		-3.00, 45.00, 501.25, 0.00, 0.00, 0.00,
		-4.8, 45.00, 501.25, 0.00, 0.00, 0.00,
		 .maxbuttons = 1, .closedelay = 2000);


	// Area 6

	CreateObject(1239, -3.90, 49.50, 501.50, 0.00, 0.00, 270.00);
	CreateObject(19273, -4.00, 51.00, 501.50, 0.00, 0.00, 90.00);
	CreateObject(19273, -4.00, 57.00, 501.50, 0.00, 0.00, 90.00);

	door_info[5] = CreateButton(-3.90, 49.50, ENTITY_HEIGHT, "Press for info", .label = 1, .labeltext = "Setting a door close delay.");
	buttonarray[0] = CreateButton(-4.00, 51.00, ENTITY_HEIGHT, "Press to open");
	door_set_delay[0] = CreateButton(-4.00, 57.00, ENTITY_HEIGHT, "Press to set delay to 5 seconds");

	door_set_delay[1] = CreateDoor(19302, buttonarray,
		-3.00, 54.00, 501.25, 0.00, 0.00, 0.00,
		-4.8, 54.00, 501.25, 0.00, 0.00, 0.00,
		 .maxbuttons = 1, .closedelay = 2000);


	// Area 7

	CreateObject(1239, -3.90, 58.50, 501.50, 0.00, 0.00, 270.00);
	CreateObject(19273, -4.00, 60.00, 501.50, 0.00, 0.00, 90.00);
	CreateObject(19273, -4.00, 66.00, 501.50, 0.00, 0.00, 90.00);

	door_info[6] = CreateButton(-3.90, 58.50, ENTITY_HEIGHT, "Press for info", .label = 1, .labeltext = "Setting a door's speed");
	buttonarray[0] = CreateButton(-4.00, 60.00, ENTITY_HEIGHT, "Press to open");
	door_set_speed[0] = CreateButton(-4.00, 66.00, ENTITY_HEIGHT, "Press to set speed");

	door_set_speed[1] = CreateDoor(19302, buttonarray,
		-3.00, 63.00, 501.25, 0.00, 0.00, 0.00,
		-4.8, 63.00, 501.25, 0.00, 0.00, 0.00,
		 .maxbuttons = 1, .closedelay = 2000);


	// Area 8

	CreateObject(1239, -3.90, 67.50, 501.50, 0.00, 0.00, 270.00);
	CreateObject(19273, -4.00, 69.00, 501.50, 0.00, 0.00, 90.00);
	CreateObject(19273, -4.00, 75.00, 501.50, 0.00, 0.00, 90.00);

	door_info[7] = CreateButton(-3.90, 67.50, ENTITY_HEIGHT, "Press for info", .label = 1, .labeltext = "Setting a door's move and stop sound");
	buttonarray[0] = CreateButton(-4.00, 69.00, ENTITY_HEIGHT, "Press to open");
	door_set_sound[0] = CreateButton(-4.00, 75.00, ENTITY_HEIGHT, "Press to set sounds");

	door_set_sound[1] = CreateDoor(19302, buttonarray,
		-3.00, 72.00, 501.25, 0.00, 0.00, 0.00,
		-4.8, 72.00, 501.25, 0.00, 0.00, 0.00,
		 .maxbuttons = 1, .closedelay = 2000);


	// Area 9

	CreateObject(1239, -3.90, 76.50, 501.50, 0.00, 0.00, 270.00);
	CreateObject(19273, -4.00, 78.00, 501.50, 0.00, 0.00, 90.00);
	CreateObject(19273, -4.00, 84.00, 501.50, 0.00, 0.00, 90.00);

	door_info[8] = CreateButton(-3.90, 76.50, ENTITY_HEIGHT, "Press for info", .label = 1, .labeltext = "Setting a door's position and rotation");
	buttonarray[0] = CreateButton(-4.00, 78.00, ENTITY_HEIGHT, "Press to open");
	door_set_posrot[0] = CreateButton(-4.00, 84.00, ENTITY_HEIGHT, "Press to change position and rotation");

	door_set_posrot[1] = CreateDoor(19302, buttonarray,
		-3.00, 81.00, 501.25, 0.00, 0.00, 0.00,
		-4.8, 81.00, 501.25, 0.00, 0.00, 0.00,
		 .maxbuttons = 1, .closedelay = 2000);


	// Area 10

	CreateObject(1239, -3.90, 85.50, 501.50, 0.00, 0.00, 270.00);
	CreateObject(19273, -4.00, 87.00, 501.50, 0.00, 0.00, 90.00);
	CreateObject(19273, -4.00, 93.00, 501.50, 0.00, 0.00, 90.00);

	door_info[9] = CreateButton(-3.90, 85.50, ENTITY_HEIGHT, "Press for info", .label = 1, .labeltext = "Setting a door's destination position and rotation");
	buttonarray[0] = CreateButton(-4.00, 87.00, ENTITY_HEIGHT, "Press to open");
	door_set_moveposrot[0] = CreateButton(-4.00, 93.00, ENTITY_HEIGHT, "Press to change destination");

	door_set_moveposrot[1] = CreateDoor(19302, buttonarray,
		-3.00, 90.00, 501.25, 0.00, 0.00, 0.00,
		-4.8, 90.00, 501.25, 0.00, 0.00, 0.00,
		 .maxbuttons = 1, .closedelay = 2000);


}

public OnButtonPress(playerid, buttonid)
{
	if(buttonid == door_info[0])
		ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Info", "This is a simple door, press the button to open it and press it again to close it.", "Close", "");

	if(buttonid == door_info[1])
		ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Info", "There's far more you can do with doors though, this one has a built in timer.", "Close", "");

	if(buttonid == door_info[2])
		ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Info", "Doors support multiple button, here's one with two buttons.", "Close", "");

	if(buttonid == door_info[3])
		ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Info", "And here's one with 4 buttons, which is the default limit.\nBut you could alter that limit and create a door with 40 buttons if you wanted to!.", "Close", "");

	if(buttonid == door_info[4])
		ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Info", "You can set the object ID of any door whenever you want too.", "Close", "");

	if(buttonid == door_info[5])
		ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Info", "The automatic close timer delay can be set too.", "Close", "");

	if(buttonid == door_info[6])
		ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Info", "You can change the movement speed of a door whenever you want.", "Close", "");

	if(buttonid == door_info[7])
		ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Info", "You can also assign custom sound effects for when the door moves or stops.", "Close", "");

	if(buttonid == door_info[8])
		ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Info", "Moving the door to a new position and rotation isn't a problem.", "Close", "");

	if(buttonid == door_info[9])
		ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Info", "You might want to change how the door opens too.", "Close", "");


	if(buttonid == door_set_obj[0])
		SetDoorModel(door_set_obj[1], 3093);
	
	if(buttonid == door_set_delay[0])
		SetDoorCloseDelay(door_set_delay[1], 5000);

	if(buttonid == door_set_speed[0])
		SetDoorMoveSpeed(door_set_speed[1], 0.1);

	if(buttonid == door_set_sound[0])
	{
		SetDoorMoveSound(door_set_sound[1], 6000);
		SetDoorStopSound(door_set_sound[1], 6002);
	}

	if(buttonid == door_set_posrot[0])
	{
		SetDoorPos(door_set_posrot[1], -3.00, 79.00, 502.25);
		SetDoorRot(door_set_posrot[1], 0.00, 10.00, 90.00);
	}

	if(buttonid == door_set_moveposrot[0])
	{
		SetDoorMovePos(door_set_moveposrot[1], -3.80, 91.00, 501.25);
		SetDoorMoveRot(door_set_moveposrot[1], 0.00, 0.00, 90.00);
	}

}





























































/*
writeobject(model, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	new
		File:file,
		str[256];

	if(!fexist("testroom.txt"))
		file = fopen("testroom.txt", io_write);

	else
		file = fopen("testroom.txt", io_append);

	format(str, 256, "CreateObject(%d, %f, %f, %f, %f, %f, %f);\r\n", model, x, y, z, rx, ry, rz);
	fwrite(file, str);

	fclose(file);

	return 1;
}
*/
