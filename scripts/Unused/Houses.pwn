/*
	~Southclaw
	    -Created January 2012
			+Base System
			+Parking Spaces
			+Notes
		-Updated Febuary 2012
		    +Add more comments as I decided to release
	    -Updated March 2012
	        +Furniture

	Dependancies:
	    sscanf
	    streamer
	    button
*/

#define MAX_HOUSE                   (64)    // Max amount of houses to be loaded
#define MAX_HINTERIOR               7		// Max amount of interior layouts
#define MAX_HCAR					(5)     // Max amount of vehicles per garage
#define MAX_HFURN                   (256)   // Max amount of furniture items per house
#define MAX_HNOTE					(8)     // Max amount of notes per house
#define MAX_HNOTE_LEN               (128)   // Max string length of each note
#define MAX_CAR_COMPONENT           (14)    // Max components on a car (This will probably never change)

#define HouseIndex					"Houses/index.ini"          // Index Location
#define HouseFileDir				"Houses/%s.%04d.ini"        // House file directory (%s:StreetName %04d:HouseNumber)

#define BTNTEXT_FORSALE             "Press F to buy this house" // Message shown when a player doesn't own a house
#define BTNTEXT_OWNED               "Press F for menu"          // Message shown when a player owns a house

#define VIRTUALWORLD_OFFSET         (1000)  // Where house virtual worlds start

#define XMIN 0
#define XMAX 1
#define YMIN 2
#define YMAX 3

#include "../scripts/HousesData.pwn"

forward KeyCheck(playerid);


enum HOUSE_ENUM
{
		h_Valid,                			// bool:    Is the house created?
		h_Owner			[MAX_PLAYER_NAME],	// string:	Owner of the house
		h_Price,        					// int:     Price of the house
		h_Street		[28],				// string:  Street name of the house
		h_Number,               			// int:     Number of the house on the street
		h_Locked,               			// int:     Boolean whether house is locked or not
		h_IntID,        					// int:     Interior ID - determines the XYZ and INTID of the interior
		h_EntButton,						// int:     Button ID for entering the house
		h_ExtButton,            			// int:     Button ID for exiting the house
Text3D:	h_Label,							// int:     Text Label ID in the game environment that tells you information about the house

Float:	h_DoorX,							// float:   Door position - pickup & label
Float:	h_DoorY,
Float:	h_DoorZ,
	
		h_MaxCarCount,
		h_CarID			[MAX_HCAR],			// int:     Vehicle ID
		h_CarModel		[MAX_HCAR],			// int:     Vehicle model
		h_CarC1			[MAX_HCAR],			// int:     Vehicle colour 1
		h_CarC2			[MAX_HCAR],			// int:     Vehicle colour 2

Float:	h_CarX			[MAX_HCAR],			// float:   Garage position & rotation
Float:	h_CarY			[MAX_HCAR],
Float:	h_CarZ			[MAX_HCAR],
Float:	h_CarA			[MAX_HCAR],
		h_CarArea		[MAX_HCAR],			// int:     Area ID for garage
	
		h_Furniture		[MAX_HFURN]
}

/*
	Interiors accessed by a single value!
	    I didn't see any point in putting interior data (interior, x, y, z) into
	    every house file when they are probably going to be the same!
	    So each house has an Interior ID (not a GTA SA one!) which corresponds
	    to this array, so if my house was IntID:0 I would be in a small 1 floor
	    1 bedroom flat! But if it was 6 I would be in a nice big mansion!
	    As you've probably guessed from looking they are in order of size.
*/
enum INTERIOR_ENUM
{
	intID,
	Float:intPosX,
	Float:intPosY,
	Float:intPosZ
}

/*
	Furniture, make yourself at home!
	
*/
enum FURNITURE_ENUM
{
	frnModelID,
	frnPosX,
	frnPosY,
	frnPosZ,
	frnRotZ
}
new
	InteriorData[MAX_HINTERIOR][INTERIOR_ENUM]=
	{													// f = number of floors b = number of bedrooms
	    {1, 223.043991, 1289.259888, 1082.199951},		// SMALL	1f 4r small bungalow
	    {15, 385.803986, 1471.769897, 1080.209961},		// SMALL	1f 3r small apartment
	    {15, 295.138977, 1474.469971, 1080.519897},		// MEDIUM	1f 6r medium bungalow
	    {15, 328.493988, 1480.589966, 1084.449951},		// SMALL	1f 2
	    {2, 225.756989, 1240.000000, 1082.149902},		// MEDIUM	1f 1
	    {3, 235.284683, 1186.681030, 1080.257812},		// LARGE	2f 8r
	    {7, 225.630997, 1022.479980, 1084.069946}		// VLARGE	2f 4
	},
	HouseData[MAX_HOUSE][HOUSE_ENUM],					// Array holds data of HOUSE_ENUM for each house
	HouseNote[MAX_HOUSE][MAX_HNOTE][128],				// Has to be out of the main array, too many dimentions!
	HouseCar[MAX_HOUSE][MAX_HCAR][MAX_CAR_COMPONENT],	// Car mods, again too many dimensions to be in the main array
	InsideHouse[MAX_PLAYERS]=-1,						// To check whether a player is actually inside a house
	CurrentHouse[MAX_PLAYERS]=-1,						// To check what house a player is at when using dialogs
	CurrentNote[MAX_PLAYERS]=-1;//,						// To check what note a player is reading when using dialogs
//	FurnitureData[MAX_HOUSE][MAX_HFURN][FURNITURE_ENUM];// Holds furniture data for each object in each house

/*
	LoadHouses all the slow stuff is done at the start!
	    LoadHouses is where all the file data is put into variables, because
	    while the game is running it's much faster to read from the cache than
	    to read from a file on the hard disk.
	    I wasn't too bothered about efficiency here as all this happens when the
	    gamemode loads, and it doesn't really matter if it stops for half a
	    second as no one is playing yet!
*/
LoadHouses()
{
	new
		File:h_idx = fopen(HouseIndex, io_read),
		line[32],
		tmpFileDir[64],
		idx,
		szStreet[28],
		MaxOnStreet,
		szLabel[64];

	while(fread(h_idx, line))
	{
		sscanf(line, "p<=>s[28]d", szStreet, MaxOnStreet);
		for(new num=1;num<=MaxOnStreet;num++)
		{
		    HouseData[idx][h_Valid] = true;
			HouseData[idx][h_Number] = num;
			HouseData[idx][h_Street] = szStreet;

			format(tmpFileDir, 64, HouseFileDir, szStreet, num);
			file_Open(tmpFileDir);

			HouseData[idx][h_Price] = file_GetVal("price");
			HouseData[idx][h_IntID] = file_GetVal("intid");

			HouseData[idx][h_DoorX] = file_GetFloat("doorx");
			HouseData[idx][h_DoorY] = file_GetFloat("doory");
			HouseData[idx][h_DoorZ] = file_GetFloat("doorz");
			if(HouseData[idx][h_DoorZ]==10.0)HouseData[idx][h_DoorZ]=10.81;
			file_SetFloat("doorz", HouseData[idx][h_DoorZ]);
			for(new c;c<MAX_HCAR;c++)
			{
			    new tmpStr[8];
			    format(tmpStr, 8, "car%02d", c);

				tmpStr[5]='m'; // 'm' stands for "Model ID"
				if(file_IsKey(tmpStr))HouseData[idx][h_CarModel][c] = file_GetVal(tmpStr);
				tmpStr[5]='p'; // 'p' stands for "Primary Colour"
				if(file_IsKey(tmpStr))HouseData[idx][h_CarC1][c] = file_GetVal(tmpStr);
				else HouseData[idx][h_CarC1][c]=-1;
				tmpStr[5]='s'; // 's' stands for "Secondary Colour"
				if(file_IsKey(tmpStr))HouseData[idx][h_CarC2][c] = file_GetVal(tmpStr);
				else HouseData[idx][h_CarC2][c]=-1;

				tmpStr[5]='x'; // x coordinate
				HouseData[idx][h_CarX][c] = file_GetFloat(tmpStr);
				tmpStr[5]='y'; // y coordinate
				HouseData[idx][h_CarY][c] = file_GetFloat(tmpStr);
				tmpStr[5]='z'; // z coordinate
				HouseData[idx][h_CarZ][c] = file_GetFloat(tmpStr);
				tmpStr[5]='a'; // 'a' stands for "Angle"
				HouseData[idx][h_CarA][c] = file_GetFloat(tmpStr);

				if((HouseData[idx][h_CarX][c]+HouseData[idx][h_CarY][c]+HouseData[idx][h_CarZ][c])!=0.0)
				{
					HouseData[idx][h_MaxCarCount]++;
					HouseData[idx][h_CarArea][c]=CreateDynamicSphere(HouseData[idx][h_CarX][c], HouseData[idx][h_CarY][c], HouseData[idx][h_CarZ][c], 4.0, 0, 0);
					if(613 > HouseData[idx][h_CarModel][c] > 400)HouseData[idx][h_CarID][c]=CreateVehicle(HouseData[idx][h_CarModel][c], HouseData[idx][h_CarX][c], HouseData[idx][h_CarY][c], HouseData[idx][h_CarZ][c], HouseData[idx][h_CarA][c], HouseData[idx][h_CarC1][c], HouseData[idx][h_CarC2][c], 1000);

					tmpStr[5]='c'; // 'c' stands for "Components"
					if(file_IsKey(tmpStr))
					{
						sscanf(file_GetStr(tmpStr), "p<|>a<d>[14]", HouseCar[idx][c]);
						for(new m;m<MAX_CAR_COMPONENT;m++)AddVehicleComponent(HouseData[idx][h_CarID][c], HouseCar[idx][c][m]);
					}

				}
			}
			for(new n;n<MAX_HNOTE;n++)
			{
				new tmpStr[7];
				format(tmpStr, 7, "note%02d", n+1);
				if(file_IsKey(tmpStr))format(HouseNote[idx][n], MAX_HNOTE_LEN, file_GetStr(tmpStr));
			}

		    if(file_IsKey("Owner") || strlen(file_GetStr("owner"))>0)
		    {
				format(HouseData[idx][h_Owner], 24, file_GetStr("owner"));
				format(szLabel, 64, "%d, %s\nOwner: %s", num, szStreet, HouseData[idx][h_Owner]);

				HouseData[idx][h_EntButton]=CreateButton(HouseData[idx][h_DoorX], HouseData[idx][h_DoorY], HouseData[idx][h_DoorZ], BTNTEXT_OWNED);
				HouseData[idx][h_Label]=CreateDynamic3DTextLabel(szLabel, BLUE, HouseData[idx][h_DoorX], HouseData[idx][h_DoorY], HouseData[idx][h_DoorZ]+1.0, 10.0);
			}
			else
			{
				format(szLabel, 64, "%d, %s\nPrice $%d", num, szStreet, HouseData[idx][h_Price]);

				HouseData[idx][h_EntButton]=CreateButton(HouseData[idx][h_DoorX], HouseData[idx][h_DoorY], HouseData[idx][h_DoorZ], BTNTEXT_FORSALE);
				HouseData[idx][h_Label]=CreateDynamic3DTextLabel(szLabel, GREEN, HouseData[idx][h_DoorX], HouseData[idx][h_DoorY], HouseData[idx][h_DoorZ]+1.0, 10.0);
			}
			HouseData[idx][h_ExtButton]=CreateButton(InteriorData[HouseData[idx][h_IntID]][intPosX], InteriorData[HouseData[idx][h_IntID]][intPosY], InteriorData[HouseData[idx][h_IntID]][intPosZ], BTNTEXT_OWNED, idx+VIRTUALWORLD_OFFSET, InteriorData[HouseData[idx][h_IntID]][intID]);
			file_Close();
			idx++;
		}
	}
	TotalHouses=idx;
}

/*
	Buying, selling, entering and exiting!
	    All in their own neat little functions and can be called from anywhere,
	    providing you have the right data to pass to the function (usually just
	    house id, which can be obtained with the CurrentHouse[] variable)
	    For instance you might want to scrap the dialog system and make players
	    enter the house as soon as they press the button, simple move the
	    function call from OnDialogResponse to OnButtonPress!
	    
	    You could also add additional checks to the function, as you can see
	    PlayerBuyHouse already has a player cash check, it returns 0 if the
	    player is skint! This way the message sending is handled from where the
		function is called, rather than the function itself (you might call the
		function from two different places and want two different return
		messages depending on that place)
		You could add more checks, like amount of houses a single player can own
		Or even when the player tries to sell the house the economy might have
		crashed! Therefore they can't sell their house! (I might make an economy
		script!)
*/
PlayerBuyHouse(playerid, houseid)
{
	new
		pMoney = GetPlayerMoney(playerid),
		szLabel[64];

	if(pMoney < HouseData[houseid][h_Price])return 0;
	else
	{
		HouseData[houseid][h_Owner] = gPlayerName[playerid];
		GivePlayerMoney(playerid, -HouseData[houseid][h_Price]);
		HouseData[houseid][h_Owner]=pName;
		format(szLabel, 64, "%d, %s\nOwner: %s", , HouseData[houseid][h_Street], gPlayerName[playerid]);
		UpdateDynamic3DTextLabelText(HouseData[houseid][h_Label], BLUE, szLabel);
		UpdateHouseData(houseid);
		SetButtonMessage(HouseData[houseid][h_EntButton], BTNTEXT_OWNED);
		return 1;
	}
}

PlayerSellHouse(playerid, houseid)
{
	new szLabel[64];

	GivePlayerMoney(playerid, floatround(HouseData[houseid][h_Price] * 0.9));
	HouseData[houseid][h_Owner][0]=0;
	format(szLabel, 64, "%d, %s\nPrice: $%d", HouseData[houseid][h_Number], HouseData[houseid][h_Street], HouseData[houseid][h_Price]);
	UpdateDynamic3DTextLabelText(HouseData[houseid][h_Label], GREEN, szLabel);
	UpdateHouseData(houseid);
	SetButtonMessage(HouseData[houseid][h_EntButton], BTNTEXT_FORSALE);
}
PlayerEnterHouse(playerid, houseid)
{
	SetPlayerVirtualWorld(playerid, houseid+VIRTUALWORLD_OFFSET);
	SetPlayerInterior(playerid, InteriorData[HouseData[houseid][h_IntID]][intID]);
	SetPlayerPos(playerid, InteriorData[HouseData[houseid][h_IntID]][intPosX], InteriorData[HouseData[houseid][h_IntID]][intPosY], InteriorData[HouseData[houseid][h_IntID]][intPosZ]);
    InsideHouse[playerid]=houseid;
}
PlayerExitHouse(playerid, houseid)
{
	SetPlayerVirtualWorld(playerid, FREEROAM_WORLD);
	SetPlayerInterior(playerid, 0);
	SetPlayerPos(playerid, HouseData[houseid][h_DoorX], HouseData[houseid][h_DoorY], HouseData[houseid][h_DoorZ]);
	CurrentHouse[playerid]=-1;
    InsideHouse[playerid]=-1;
}

/*
	Buttons are better than spinning blue houses!
	    I decided to use my button script instead of SA pickups, gives the
	    player a little more control as they might want to stand in the doorway
	    but not access the menu (maybe for a movie)
	    Easily changable though, simple move the loop and all code inside it to
	    another function (OnPlayerPickUp/EnterCheckpoint/EnterArea)
*/
script_Houses_OnButtonPress(playerid, buttonid)
{
	for(new h;h<TotalHouses;h++)
	{
	    if(!HouseData[h][h_Valid])continue;
	    if(buttonid==HouseData[h][h_EntButton])
		{
		    CurrentHouse[playerid]=h;
		    if(HouseData[h][h_Owner][0]==0)
			{
			    new szBuyStr[48];
			    format(szBuyStr, 48, "Do you want to buy this house for $%d?", HouseData[h][h_Price]);
				ShowPlayerDialog(playerid, d_HouseBuyConfirm, DIALOG_STYLE_MSGBOX, "Buy House", szBuyStr, "Confirm", "Cancel");
				break;
			}
			else
			{
				FormatHouseDialog(playerid, CurrentHouse[playerid]);
				break;
			}
		}
	    if(buttonid==HouseData[h][h_ExtButton])
		{
			FormatHouseDialog(playerid, CurrentHouse[playerid]);
			break;
		}
	}
}
/*
	The Menu
	    Decided to use dialogs rather than just entering/exiting/buying/selling
		the house with commands, it's a little easier to use and no commands to
		remember! Plus it looks nice :D

		Menu Items:
			OWNER
			    -Enter House
			    -Lock House
			    -Notes (# OF NOTES)
			    -Sell House
			VISITOR
			    If Locked
			    	-Knock
			    	-Leave Message
				If Unlocked
			    	-Enter
			    	-Leave Message
		    
*/
script_Houses_DialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_HouseBuyConfirm && response)
	{
		if(PlayerBuyHouse(playerid, CurrentHouse[playerid]))Msg(playerid, YELLOW, "Enjoy you're new home!");
		else Msg(playerid, RED, "You do not have enough money!");
	}
	if(dialogid == d_HouseSellConfirm && response)PlayerSellHouse(playerid, CurrentHouse[playerid]);
	if(dialogid == d_HouseOwner)
	{
	    if(response)
	    {
	    	switch(listitem)
	    	{
	    	    case 0:
				{
					if(InsideHouse[playerid]==CurrentHouse[playerid])PlayerExitHouse(playerid, CurrentHouse[playerid]);
					else PlayerEnterHouse(playerid, CurrentHouse[playerid]);
				}
	    	    case 1:
	    	    {
					HouseData[CurrentHouse[playerid]][h_Locked]=~HouseData[CurrentHouse[playerid]][h_Locked];
					FormatHouseDialog(playerid, CurrentHouse[playerid]);
	    	    }
	    	    case 2:FormatNoteList(playerid, CurrentHouse[playerid]);
	    	    case 3:ShowPlayerDialog(playerid, d_HouseSellConfirm, DIALOG_STYLE_MSGBOX, "Sell House", "Do you really want to sell your property?", "Confirm", "Cancel");
	    	}
	    }
	}
	if(dialogid == d_HouseVisit)
	{
	    if(response)
	    {
	        switch(listitem)
	        {
	            case 0:
	            {
					if(InsideHouse[playerid]==CurrentHouse[playerid])PlayerExitHouse(playerid, CurrentHouse[playerid]);
					else
					{
	                	if(HouseData[CurrentHouse[playerid]][h_Locked])KnockHouse(CurrentHouse[playerid]);
	                	else PlayerEnterHouse(playerid, CurrentHouse[playerid]);
	                }
	            }
	            case 1:ShowPlayerDialog(playerid, d_HouseNoteLeave, DIALOG_STYLE_INPUT, "Leave a note", "Write a note to leave\nthe owner will read it when he is home.\nDon't forget to leave your name!", "Leave", "Cancel");
	        }
	    }
	}
	if(dialogid == d_HouseNoteLeave)
	{
		if(response)
		{
			if(PlayerLeaveNote(CurrentHouse[playerid], inputtext))Msg(playerid, YELLOW, "Note posted through the letterbox!");
			else Msg(playerid, RED, "There are too many notes at this house!");
		}
	}
	if(dialogid == d_HouseNoteList)
	{
	    if(response)PlayerReadNote(playerid, CurrentHouse[playerid], listitem);
	    else FormatHouseDialog(playerid, CurrentHouse[playerid]);
	}
	if(dialogid == d_HouseNote)
	{
	    if(response)
	    {
	        DeleteNote(CurrentHouse[playerid], CurrentNote[playerid]);
		    CurrentNote[playerid]=-1;
			FormatNoteList(playerid, CurrentHouse[playerid]);
	    }
	    else
		{
		    CurrentNote[playerid]=-1;
			FormatNoteList(playerid, CurrentHouse[playerid]);
		}
	}
	if(dialogid == d_HouseEditMenu)
	{
	}
	if(dialogid == d_HouseFurniture)
	{
	}
}
FormatHouseDialog(playerid, houseid)
{
	new szStr[128];
	if(IsPlayerHouseOwner(playerid, houseid))
	{
	    new szNoteStr[12];
	    if(InsideHouse[playerid]==houseid)strcat(szStr, "Exit House\n");
	    else strcat(szStr, "Enter House\n");
	    if(HouseData[houseid][h_Locked])strcat(szStr, "Unlock House\n");
	    else strcat(szStr, "Lock House\n");
	    format(szNoteStr, 12, "Notes (%d)\n", CountNotes(houseid));
	    strcat(szStr, szNoteStr);
	    strcat(szStr, "Sell House");
		ShowPlayerDialog(playerid, d_HouseOwner, DIALOG_STYLE_LIST, "Your House", szStr, "Ok", "Cancel");
	}
	else
	{
	    new szCaption[33];
	    if(HouseData[houseid][h_Locked])szStr="Knock\nLeave Message";
	    else
		{
		    if(InsideHouse[playerid]==houseid)szStr="Exit House\nLeave Message";
		    else szStr="Enter House\nLeave Message";
		}
	    format(szCaption, 33, "%s's House", HouseData[houseid][h_Owner]);
		ShowPlayerDialog(playerid, d_HouseVisit, DIALOG_STYLE_LIST, szCaption, szStr, "Ok", "Cancel");
	}
}


/*
	Notes system
	    Players can leae notes at houses for the owner to read at another time
	    There is a max notes limit (mainly for the size of the array) if you
	    change this number you might need to increase the string size of strings
	    like "note%02d" and make the '02' into an '03' so more numbers can be in
	    that string (3 digits incase someone spams a house with 700 notes!!)
*/
//--
FormatNoteList(playerid, houseid)
{
	new
	    NoteCount = CountNotes(houseid),
	    TmpNoteLine[32],
		szList[(32*MAX_HNOTE)];
	if(NoteCount>0)
	{
		for(new n;n<NoteCount;n++)
		{
		    strmid(TmpNoteLine, HouseNote[houseid][n], 0, 32-6);
			format(TmpNoteLine, 32, "%s...\n", TmpNoteLine);
			strcat(szList, TmpNoteLine);
		}
	}
	else szList="No notes";
	ShowPlayerDialog(playerid, d_HouseNoteList, DIALOG_STYLE_LIST, "Notes", szList, "Open", "Back");
}
PlayerLeaveNote(houseid, Msg[])
{
	for(new i;i<MAX_HNOTE;i++)
	{
		if(HouseNote[houseid][i][0]==0)
		{
			new
				tmpFileDir[64],
				tmpStr[7];
			format(tmpFileDir, 64, HouseFileDir, HouseData[houseid][h_Street], HouseData[houseid][h_Number]);
			format(HouseNote[houseid][i], 128, Msg);
			if(file_Open(tmpFileDir))
			{
				format(tmpStr, 7, "note%02d", i+1);
				file_SetStr(tmpStr, Msg);
			}
			file_Save(tmpFileDir);
			file_Close();
			return 1;
		}
	}
	return 0;
}
PlayerReadNote(playerid, houseid, noteid)
{
	new szTmpCaption[7];
	format(szTmpCaption, 7, "note%02d", noteid+1);
	ShowPlayerDialog(playerid, d_HouseNote, DIALOG_STYLE_MSGBOX, szTmpCaption, HouseNote[houseid][noteid], "Close+Delete", "Close+Save");
	CurrentNote[playerid]=noteid;
}
DeleteNote(houseid, noteid)
{
	new
		tmpFileDir[64],
		tmpStr[7];
	format(tmpFileDir, 64, HouseFileDir, HouseData[houseid][h_Street], HouseData[houseid][h_Number]);
    HouseNote[houseid][noteid][0]=0;
    file_Open(tmpFileDir);
    for(new n=noteid;n<MAX_HNOTE-1;n++)
    {
		format(tmpStr, 7, "note%02d", n+1);
		HouseNote[houseid][n]=HouseNote[houseid][n+1];
		file_SetStr(tmpStr, HouseNote[houseid][n]);
	}
	file_Save(tmpFileDir);
	file_Close();
}
CountNotes(houseid)
{
	new iCount;
	while(HouseNote[houseid][iCount][0]!=0 && (iCount<MAX_HNOTE-1))iCount++;
	return iCount;
}
//--

/*
	Knocking on heavens door!
	    Knocking on a door will send a message to everyone in the house!
	    But it doesn't tell you who is at the door! I decided on that for
	    realism (RP players always seem to be obsessed with realism!)
	    I might add a Peephole that puts the camera to the door so you can see
		who's there! Problem there is making sure the door positions are in the
		right place so the camera doesn't go in a wall!
*/
KnockHouse(houseid)
{
	PlayerLoop(i)
	{
		if(InsideHouse[i]==houseid)
		{
			Msg(i, YELLOW, "Someone is knocking at the door!");
			// Play knocking sound 3 times (if there is one!)
		}
	}
}
IsPlayerHouseOwner(playerid, houseid)
{
	new pName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, pName, MAX_PLAYER_NAME);
	if(!strcmp(pName, HouseData[houseid][h_Owner], true) && strlen(HouseData[houseid][h_Owner])>0)return 1;
	else return 0;
}

UpdateHouseData(houseid)
{
	new tmpFileDir[64];
	format(tmpFileDir, 64, HouseFileDir, HouseData[houseid][h_Street], HouseData[houseid][h_Number]);
	if(file_Open(tmpFileDir))
	{
	    file_SetStr("owner", HouseData[houseid][h_Owner]);
		file_SetVal("price", HouseData[houseid][h_Price]);
		file_SetVal("intid", HouseData[houseid][h_IntID]);

		file_SetFloat("doorx", HouseData[houseid][h_DoorX]);
		file_SetFloat("doory", HouseData[houseid][h_DoorY]);
		file_SetFloat("doorz", HouseData[houseid][h_DoorZ]);
	}
	file_Save(tmpFileDir);
	file_Close();
}


/*
	Buy a house Get a free car!
	    Added a vehicle system, not huge, just saves the car along with all mods
	    from the various car pimping stores!
*/
script_Houses_OnEnterArea(playerid, areaid)
{
	for(new h;h<TotalHouses;h++)
	{
		for(new g;g<HouseData[h][h_MaxCarCount];g++)
		{
			if(areaid==HouseData[h][h_CarArea][g])
			{
			    if(IsPlayerHouseOwner(playerid, h))ShowMsgBox(playerid, "Save your car here");
				else ShowMsgBox(playerid, "This is someone elses house");
			}
		}
	}
}
script_Houses_OnExitArea(playerid, areaid)
{
	for(new h;h<TotalHouses;h++)
	{
		for(new g;g<HouseData[h][h_MaxCarCount];g++)
		{
			if(areaid==HouseData[h][h_CarArea][g])
			{
			    if(bPlayerGameSettings[playerid]&vMsgBox)HideMsgBox(playerid);
			}
		}
	}
}
script_Houses_OnEnterExitMod(playerid, enterexit)
{
	new vehicleid = GetPlayerVehicleID(playerid);
	if(!enterexit)
	{
		for(new h;h<TotalHouses;h++)
		{
		    for(new g;g<HouseData[h][h_MaxCarCount];g++)if(vehicleid==HouseData[h][h_CarID][g])SaveHouseCar(h, g, vehicleid);
		}
	}
}
script_Houses_OnEnterVeh(playerid, vehicleid)
{
	new
		Float:x,
		Float:y,
		Float:z;
	GetPlayerPos(playerid, x, y, z);
	for(new h;h<TotalHouses;h++)
	{
		for(new g;g<HouseData[h][h_MaxCarCount];g++)
		{
			if(vehicleid==HouseData[h][h_CarID][g])
			{
				if(!IsPlayerHouseOwner(playerid, h))
				{
					SetPlayerPos(playerid, x, y, z);
					Msg(playerid, RED, "This car does not belong to you");
				}
			}
		}
	}
}
script_Houses_OnExitVeh(playerid, vehicleid)
{
	for(new h;h<TotalHouses;h++)
	{
	    for(new g;g<HouseData[h][h_MaxCarCount];g++)
	    {
			if(IsPlayerInDynamicArea(playerid, HouseData[h][h_CarArea][g]))
			{
			    if(IsPlayerHouseOwner(playerid, h))
			    {
					SaveHouseCar(h, g, vehicleid);
					ShowMsgBox(playerid, "Car saved!", 3000);
					return 1;
				}
				else ShowMsgBox(playerid, "~r~You can't park there!~n~~w~This house does not belong to you!", 3000);
			}
		}
	}
	return 1;
}

SaveHouseCar(houseid, garageslot, vehicleid, color1=-1, color2=-1)
{
	HouseData[houseid][h_CarModel][garageslot]=GetVehicleModel(vehicleid);
	HouseData[houseid][h_CarC1][garageslot]=color1;
	HouseData[houseid][h_CarC2][garageslot]=color2;

	new tmpFileDir[64];
	format(tmpFileDir, 64, HouseFileDir, HouseData[houseid][h_Street], HouseData[houseid][h_Number]);
	if(file_Open(tmpFileDir))
	{
		new
			tmpStr[8],
			tmpComponent[8],
			CarModLine[14*5];

		format(tmpStr, 8, "car%02d", garageslot);

		tmpStr[5]='m';
		file_SetVal(tmpStr, HouseData[houseid][h_CarModel][garageslot]);
		tmpStr[5]='p';
		file_SetVal(tmpStr, HouseData[houseid][h_CarC1][garageslot]);
		tmpStr[5]='s';
		file_SetVal(tmpStr, HouseData[houseid][h_CarC2][garageslot]);
		
		tmpStr[5]='c';
		for(new m;m<MAX_CAR_COMPONENT;m++)
		{
		    format(tmpComponent, 8, "%d|", GetVehicleComponentInSlot(vehicleid, m));
		    strcat(CarModLine, tmpComponent);
		}
		file_SetStr(tmpStr, CarModLine);
	}
	file_Save(tmpFileDir);
	file_Close();
}

/*
	Dynamic new house adding!
	    This function can be added to a large script that saves houses on the
	    press of a button and automatically sets up the number to increment each
	    time! (I might make and release that some time soon)
	    Or it can be added to a simple command where the player inputs the
	    street name and number manually each time (though this would be tedious)
*/
stock AddNewHouse(street[], num, intid, price, Float:x, Float:y, Float:z, Float:gx, Float:gy, Float:gz)
{
	new tmpFileDir[64];

	file_Open(HouseIndex);
	{
		if(file_IsKey(street) && num>file_GetVal(street))file_SetVal(street, num);
		else file_SetVal(street, num);
	}
	file_Save(HouseIndex);
	file_Close();

	format(tmpFileDir, 64, HouseFileDir, street, num);

	file_Create(tmpFileDir);
	file_Open(tmpFileDir);
	{
	    file_SetVal("intid", intid);
	    file_SetVal("price", price);

	    file_SetFloat("doorx", x);
	    file_SetFloat("doory", y);
	    file_SetFloat("doorz", z);
	    
	    file_SetFloat("car00x", gx);
	    file_SetFloat("car00y", gy);
	    file_SetFloat("car00z", gz);
	}
	file_Save(tmpFileDir);
	file_Close();
}


/*
	Editing, Saving, Loading and using Furniture!
	    The player can enter 'Edit Mode' and move their furniture around.
*/
enum EDIT_TYPE
{
	House,
	Object,
	Room
}
new
	frnObjectMod[MAX_PLAYERS],
	Float:frnObjectPos[MAX_PLAYERS][4],
	Float:frnObjectPos_tmp[MAX_PLAYERS][3],
	PlayerEditing[MAX_PLAYERS][EDIT_TYPE],
	HouseEditTimer[MAX_PLAYERS];

CMD:edithouse(playerid, params[])
{
    PlayerEnterEditMode(playerid, InsideHouse[playerid], strval(params));
	return 1;
}

CMD:resetid(playerid, params[])
{
    PlayerEditing[playerid][House]=-1;
	KillTimer(HouseEditTimer[playerid]);
	return 1;
}
stock FormatEditMenu(playerid)
{
	new
	    list[128],
		str[16],
		iLoop;

	while(iLoop < GetHouseRoomCount(InHouse[playerid]))
	{
		format(str, 16, "Room %d\n", iLoop); // Needs room names... somehow... file loaded data maybe?
		strcat(list, str);
	}

	ShowPlayerDialog(playerid, d_HouseEditMenu, DIALOG_STYLE_LIST, "Choose a room to edit", str, "Edit", "Back");
}
stock FormatFurnitureList(playerid)
{
	new str[256];
	// furniture loop, loaded form files or static?
	format(str, 256, "Table\nChair");
}
PlayerEnterEditMode(playerid, houseid, roomid)
{
	PlayerEditing[playerid][House]=houseid;
	PlayerEditing[playerid][Room]=roomid;

	frnObjectPos[playerid][0]=RoomStartPos[HouseData[houseid][h_IntID]][roomid][0];
	frnObjectPos[playerid][1]=RoomStartPos[HouseData[houseid][h_IntID]][roomid][1];
	frnObjectPos[playerid][2]=RoomStartPos[HouseData[houseid][h_IntID]][roomid][2];

	frnObjectPos_tmp[playerid][0]=frnObjectPos[playerid][0];
	frnObjectPos_tmp[playerid][1]=frnObjectPos[playerid][1];
	frnObjectPos_tmp[playerid][2]=frnObjectPos[playerid][2];

    PlayerEditing[playerid][Object]=CreateDynamicObject(frnObjectMod[playerid], frnObjectPos[playerid][0], frnObjectPos[playerid][1], frnObjectPos[playerid][2], 0.0, 0.0, 0.0, houseid+VIRTUALWORLD_OFFSET, InteriorData[HouseData[houseid][h_IntID]][intID], playerid);
	TogglePlayerControllable(playerid, false);
	if(HouseEditTimer[playerid]!=-1)KillTimer(HouseEditTimer[playerid]);
	HouseEditTimer[playerid] = SetTimerEx("KeyCheck", 100, true, "d", playerid);
}
public KeyCheck(playerid)
{
	new
		k,
		ud,
		lr,
		Float:xMove,
		Float:yMove,
		Float:zRot,
		Float:AngToObj,
		houseid = PlayerEditing[playerid][House],
		roomid = PlayerEditing[playerid][Room];
	GetPlayerKeys(playerid, k, ud, lr);
	
	new btn[32];
	btn="NONE~n~";
	
	if(lr>0) // Right
	{
	    btn="Right~n~";
		if(k==32)zRot=-10.0;
		else xMove=0.5;
	}
	if(lr<0) // Left
	{
	    btn="Left~n~";
		if(k==32)zRot=10.0;
		else xMove=-0.5;
	}
	if(ud<0) // Up
	{
	    btn="Up~n~";
		yMove=0.5;
	}
	if(ud>0) // Down
	{
	    btn="Down~n~";
		yMove=-0.5;
	}

	AngToObj = GetAngleToPoint(HouseRoomCamPos[HouseData[houseid][h_IntID]][roomid][0], HouseRoomCamPos[HouseData[houseid][h_IntID]][roomid][1], frnObjectPos[playerid][0], frnObjectPos[playerid][1]);
/*
 * 	The above function outputs negative values for the top-left sector
 *	(supposed to be 270 to 360 but are outputted as -90 to 0.0)
 *	Just add the negative value to 360 to subtract it then assign that to the variable:
 */

	if(AngToObj < 0.0)AngToObj=360.0+AngToObj;

	new Ang[32];
	format(Ang, 32, "~b~NONE", AngToObj);

	if(315 <= AngToObj < 360.0 || 0.0 <= AngToObj < 45) // "(315 <= AngToObj < 45)" won't work because a number can't be below 45 and be above 315 at the same time (The computer doesn't know we are working with degrees of a circle) This annoys me because now the statement doesn't match the other statements and I had to write this really long line explaining why it doesn't match! >:'(
	{
		Ang="~b~NORTH";
	    if(CheckArea(0, playerid, houseid, roomid, xMove, yMove))
		{
			frnObjectPos[playerid][0]+=xMove;
			frnObjectPos[playerid][1]+=yMove;
		}
	}
	if(45 <= AngToObj < 135)
	{
		Ang="~b~EAST";
	    if(CheckArea(1, playerid, houseid, roomid, xMove, yMove))
		{
			frnObjectPos[playerid][0]+=yMove;
			frnObjectPos[playerid][1]-=xMove;
		}
	}
	if(135 <= AngToObj < 225)
	{
		Ang="~b~SOUTH";
	    if(CheckArea(2, playerid, houseid, roomid, xMove, yMove))
		{
			frnObjectPos[playerid][0]-=xMove;
			frnObjectPos[playerid][1]-=yMove;
		}
	}
	if(225 <= AngToObj < 315) //|| -135 <= AngToObj < -45)
	{
		Ang="~b~WEST";
	    if(CheckArea(3, playerid, houseid, roomid, xMove, yMove))
		{
			frnObjectPos[playerid][0]-=yMove;
			frnObjectPos[playerid][1]+=xMove;
		}
	}

	frnObjectPos[playerid][3]+=zRot;

	MoveDynamicObject(PlayerEditing[playerid][Object], frnObjectPos[playerid][0], frnObjectPos[playerid][1], frnObjectPos[playerid][2], 10.0, 0.0, 0.0, frnObjectPos[playerid][3]);
	InterpolateCameraPos(playerid, HouseRoomCamPos[HouseData[houseid][h_IntID]][roomid][0], HouseRoomCamPos[HouseData[houseid][h_IntID]][roomid][1], HouseRoomCamPos[HouseData[houseid][h_IntID]][roomid][2], HouseRoomCamPos[HouseData[houseid][h_IntID]][roomid][0], HouseRoomCamPos[HouseData[houseid][h_IntID]][roomid][1], HouseRoomCamPos[HouseData[houseid][h_IntID]][roomid][2], 1000, CAMERA_MOVE);
	InterpolateCameraLookAt(playerid, frnObjectPos_tmp[playerid][0], frnObjectPos_tmp[playerid][1], frnObjectPos_tmp[playerid][2], frnObjectPos[playerid][0], frnObjectPos[playerid][1], frnObjectPos[playerid][2], 500, CAMERA_MOVE);
	Streamer_UpdateEx(playerid, HouseRoomCamPos[HouseData[houseid][h_IntID]][roomid][0], HouseRoomCamPos[HouseData[houseid][h_IntID]][roomid][1], HouseRoomCamPos[HouseData[houseid][h_IntID]][roomid][2], houseid+VIRTUALWORLD_OFFSET, InteriorData[HouseData[PlayerEditing[playerid][House]][h_IntID]][intID]);

	frnObjectPos_tmp[playerid][0]=frnObjectPos[playerid][0];
	frnObjectPos_tmp[playerid][1]=frnObjectPos[playerid][1];


	new str[256];
	format(str, 256, "%.1f < %.1f < %0.1f~n~~n~%.1f < %.01f < %01f~n~~n~~y~ANG:%f~n~%s",
	HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][0],
	frnObjectPos[playerid][0],
	HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][1],

	HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][2],
	frnObjectPos[playerid][1],
	HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][3],

	AngToObj,
	Ang);

	ShowMsgBox(playerid, str);
}

CheckArea(direction, playerid, houseid, roomid, Float:xMove, Float:yMove)
{
	if(direction==0)
	{
	    if(frnObjectPos[playerid][0]+xMove != frnObjectPos[playerid][0])
	    {
	    	if(frnObjectPos[playerid][0]+xMove<HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][XMIN])
			{
				frnObjectPos[playerid][0]=HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][XMIN];
				return 0;
			}
			if(frnObjectPos[playerid][0]+xMove>HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][XMAX])
			{
				frnObjectPos[playerid][0]=HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][XMAX];
				return 0;
			}
		}
	    if(frnObjectPos[playerid][1]+yMove != frnObjectPos[playerid][1])
	    {
			if(frnObjectPos[playerid][1]+yMove<HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][YMIN])
			{
				frnObjectPos[playerid][1]=HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][YMIN];
				return 0;
			}
			if(frnObjectPos[playerid][1]+yMove>HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][YMAX])
			{
				frnObjectPos[playerid][1]=HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][YMAX];
				return 0;
			}
		}
	}
	if(direction==1)
	{
	    if(frnObjectPos[playerid][0]+yMove != frnObjectPos[playerid][0])
	    {
		    if(frnObjectPos[playerid][0]+yMove<HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][XMIN])
		    {
				frnObjectPos[playerid][0]=HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][XMIN];
				return 0;
			}
			if(frnObjectPos[playerid][0]+yMove>HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][XMAX])
			{
				frnObjectPos[playerid][0]=HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][XMAX];
				return 0;
			}
		}
	    if(frnObjectPos[playerid][1]-xMove != frnObjectPos[playerid][1])
	    {
			if(frnObjectPos[playerid][1]-xMove<HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][YMIN])
			{
				frnObjectPos[playerid][1]=HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][YMIN];
				return 0;
			}
			if(frnObjectPos[playerid][1]-xMove>HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][YMAX])
			{
				frnObjectPos[playerid][1]=HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][YMAX];
				return 0;
			}
		}
	}
	if(direction==2)
	{
	    if(frnObjectPos[playerid][0]-xMove != frnObjectPos[playerid][0])
	    {
	    	if(frnObjectPos[playerid][0]-xMove<HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][XMIN])
	    	{
				frnObjectPos[playerid][0]=HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][XMIN];
				return 0;
			}
			if(frnObjectPos[playerid][0]-xMove>HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][XMAX])
			{
				frnObjectPos[playerid][0]=HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][XMAX];
				return 0;
			}
		}
	    if(frnObjectPos[playerid][1]-yMove != frnObjectPos[playerid][1])
	    {
			if(frnObjectPos[playerid][1]-yMove<HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][YMIN])
			{
				frnObjectPos[playerid][1]=HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][YMIN];
				return 0;
			}
			if(frnObjectPos[playerid][1]-yMove>HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][YMAX])
			{
				frnObjectPos[playerid][1]=HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][YMAX];
				return 0;
			}
		}
	}
	if(direction==3)
	{
	    if(frnObjectPos[playerid][0]-yMove != frnObjectPos[playerid][0])
	    {
		    if(frnObjectPos[playerid][0]-yMove<HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][XMIN])
			{
				frnObjectPos[playerid][0]=HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][XMIN];
				return 0;
			}
			if(frnObjectPos[playerid][0]-yMove>HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][XMAX])
			{
				frnObjectPos[playerid][0]=HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][XMAX];
				return 0;
			}
		}
		if(frnObjectPos[playerid][1]+xMove != frnObjectPos[playerid][1])
		{
			if(frnObjectPos[playerid][1]+xMove<HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][YMIN])
			{
				frnObjectPos[playerid][1]=HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][YMIN];
				return 0;
			}
			if(frnObjectPos[playerid][1]+xMove>HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][YMAX])
			{
				frnObjectPos[playerid][1]=HouseRoomBounds[HouseData[houseid][h_IntID]][roomid][YMAX];
				return 0;
			}
		}
	}
	return 1;
}
script_Houses_ResetPlayerData(playerid)
{
	PlayerEditing[playerid][House]	=-1;
	PlayerEditing[playerid][Object]	=-1;
	InsideHouse[playerid]			=-1;
	CurrentHouse[playerid]			=-1;
	CurrentNote[playerid]			=-1;
	HouseEditTimer[playerid]		=-1;
}



