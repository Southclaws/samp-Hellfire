#include <a_samp>
new Text:TetrisNextBrick;
enum TetrisData
{
	X,Y,
	Color,
	Group,
bool:Skip
};
//native gpci(playerid, serial[], len);
#define TotalBlocksX 8   // X-MAX
#define TotalBlocksY 10 // Y-MAX
#define TotalBlocks TotalBlocksX*TotalBlocksY
new TetrisBlocks[TotalBlocks+1][TetrisData];
new Text:TetrisUI[10], Text:TetrisGame[4];
new TetrisGameTimer, Float:TetrisCamera[]={
	/*||*/ 1526.7089,-1346.9009,329.9922};
new Text:TetrisInfo, Text:TetrisMusic;
public OnFilterScriptInit()
{
	// Create the textdraws:
	TetrisInfo = TextDrawCreate(187.000000, 371.000000, "Use ~k~~GO_LEFT~/~k~~GO_RIGHT~ Keys to move brick~n~Drop Brick with ~k~~VEHICLE_ENTER_EXIT~ Key~n~Rotate Brick with ~k~~PED_SPRINT~ Key");
	TextDrawBackgroundColor(TetrisInfo, 255);
	TextDrawFont(TetrisInfo, 1);
	TextDrawLetterSize(TetrisInfo, 0.480000, 1.600000);
	TextDrawColor(TetrisInfo, -1);
	TextDrawSetOutline(TetrisInfo, 1);
	TextDrawSetProportional(TetrisInfo, 1);

	TetrisMusic = TextDrawCreate(275.000000, 417.000000, "Toggle Music");
	TextDrawBackgroundColor(TetrisMusic, 255);
	TextDrawFont(TetrisMusic, 1);
	TextDrawLetterSize(TetrisMusic, 0.480000, 1.600000);
	TextDrawColor(TetrisMusic, 0xFFFF00FF);
	TextDrawSetOutline(TetrisMusic, 1);
	TextDrawSetProportional(TetrisMusic, 1);
	TextDrawSetSelectable(TetrisMusic, 1);

	TetrisUI[0] = TextDrawCreate(165, 100, "_");
	TextDrawBackgroundColor(TetrisUI[0], 255);
	TextDrawFont(TetrisUI[0], 1);
	TextDrawLetterSize(TetrisUI[0], 0.500000, 29.899999);
	TextDrawColor(TetrisUI[0], -1);
	TextDrawSetOutline(TetrisUI[0], 0);
	TextDrawSetProportional(TetrisUI[0], 1);
	TextDrawSetShadow(TetrisUI[0], 1);
	TextDrawUseBox(TetrisUI[0], 1);
	TextDrawBoxColor(TetrisUI[0], 119);
	TextDrawTextSize(TetrisUI[0], 485, 5);
	TetrisUI[1] = TextDrawCreate(169, 117, "---------------------");
	TextDrawBackgroundColor(TetrisUI[1], 255);
	TextDrawFont(TetrisUI[1], 3);
	TextDrawLetterSize(TetrisUI[1], 0.979999, 1.700002);
	TextDrawColor(TetrisUI[1], -65281);
	TextDrawSetOutline(TetrisUI[1], 1);
	TextDrawSetProportional(TetrisUI[1], 1);
	TetrisUI[2] = TextDrawCreate(169, 97, "~r~Tetris");
	TextDrawBackgroundColor(TetrisUI[2], 51);
	TextDrawFont(TetrisUI[2], 2);
	TextDrawLetterSize(TetrisUI[2], 0.979999, 2.600002);
	TextDrawColor(TetrisUI[2], 119);
	TextDrawSetOutline(TetrisUI[2], 1);
	TextDrawSetProportional(TetrisUI[2], 1);
	TetrisUI[3] = TextDrawCreate(477, 97, "~r~elixeH");
	TextDrawBackgroundColor(TetrisUI[3], 51);
	TextDrawFont(TetrisUI[3], 2);
	TextDrawLetterSize(TetrisUI[3], -0.979999, 2.600002);
	TextDrawColor(TetrisUI[3], 119);
	TextDrawSetOutline(TetrisUI[3], 1);
	TextDrawSetProportional(TetrisUI[3], 1);
	TetrisUI[4] = TextDrawCreate(383, 131, "l~n~l~n~l~n~l~n~l~n~l~n~l~n~l~n~l~n~l~n~l~n~l~n~l~n~l~n~l");
	TextDrawBackgroundColor(TetrisUI[4], 255);
	TextDrawFont(TetrisUI[4], 1);
	TextDrawLetterSize(TetrisUI[4], 0.369998, 1.700001);
	TextDrawColor(TetrisUI[4], -65281);
	TextDrawSetOutline(TetrisUI[4], 1);
	TextDrawSetProportional(TetrisUI[4], 1);
	TetrisUI[5] = TextDrawCreate(169, 355, "---------------------");
	TextDrawBackgroundColor(TetrisUI[5], 255);
	TextDrawFont(TetrisUI[5], 3);
	TextDrawLetterSize(TetrisUI[5], 0.979999, 1.700002);
	TextDrawColor(TetrisUI[5], -65281);
	TextDrawSetOutline(TetrisUI[5], 1);
	TextDrawSetProportional(TetrisUI[5], 1);
	TetrisUI[6] = TextDrawCreate(388, 301, "Player");
	TextDrawBackgroundColor(TetrisUI[6], 255);
	TextDrawFont(TetrisUI[6], 1);
	TextDrawLetterSize(TetrisUI[6], 0.500000, 1.500002);
	TextDrawColor(TetrisUI[6], -65281);
	TextDrawSetOutline(TetrisUI[6], 1);
	TextDrawSetProportional(TetrisUI[6], 1);
	TetrisUI[7] = TextDrawCreate(388, 131.5, "Score~n~~w~1234567~n~~b~Level~n~~w~45~n~~r~Record~n~~w~142~n~~b~47~n~~g~Time~n~~w~32M 16S");
	TextDrawBackgroundColor(TetrisUI[7], 255);
	TextDrawFont(TetrisUI[7], 1);
	TextDrawLetterSize(TetrisUI[7], 0.599999, 1.700002);
	TextDrawColor(TetrisUI[7], -65281);
	TextDrawSetOutline(TetrisUI[7], 1);
	TextDrawSetProportional(TetrisUI[7], 1);
	TetrisUI[8] = TextDrawCreate(388, 317, "<Unknown>");
	TextDrawBackgroundColor(TetrisUI[8], 255);
	TextDrawFont(TetrisUI[8], 1);
	TextDrawLetterSize(TetrisUI[8], 0.300000, 1.400002);
	TextDrawColor(TetrisUI[8], -1);
	TextDrawSetOutline(TetrisUI[8], 1);
	TextDrawSetProportional(TetrisUI[8], 1);
	TetrisUI[9] = TextDrawCreate(388, 331, "Record~n~~w~Level 35: 1234567");
	TextDrawBackgroundColor(TetrisUI[9], 255);
	TextDrawFont(TetrisUI[9], 1);
	TextDrawLetterSize(TetrisUI[9], 0.300000, 1.600002);
	TextDrawColor(TetrisUI[9], -65281);
	TextDrawSetOutline(TetrisUI[9], 1);
	TextDrawSetProportional(TetrisUI[9], 1);
	printf("Tetris GUI Created");
	for(new i; i<MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i)) continue;
		for(new t; t<sizeof(TetrisUI); t++) TextDrawShowForPlayer(i, TetrisUI[t]);
	}

	for(new t=0; t < TotalBlocks; t++) TetrisBlocks[t][Group]=-1;

	TetrisNextBrick = TextDrawCreate(397, 272, "~l~####~n~####");
	TextDrawBackgroundColor(TetrisNextBrick, 255);
	TextDrawFont(TetrisNextBrick, 1);
	TextDrawLetterSize(TetrisNextBrick, 0.500000, 1.500002);
	TextDrawColor(TetrisNextBrick, -65281);
	TextDrawSetOutline(TetrisNextBrick, 1);
	TextDrawSetProportional(TetrisNextBrick, 1);

	for(new g=0; g < sizeof(TetrisGame); g++)
	{
		TetrisGame[g] = TextDrawCreate(166.000000, 129.000000+(70*g), " ");
		TextDrawBackgroundColor(TetrisGame[g], 255);
		TextDrawFont(TetrisGame[g], 3);
		TextDrawLetterSize(TetrisGame[g], 0.979999, 2.600002);
		TextDrawColor(TetrisGame[g], -1);
		TextDrawSetOutline(TetrisGame[g], 1);
		TextDrawSetProportional(TetrisGame[g], 1);
	}
	printf("Tetris System Loading...");
	for(new i; i<MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i)) continue;
		/*new tmp[256];   / Not related to
gpci(i, tmp, sizeof(tmp));  Tetris|Game
printf("gpci returned: %i = >%s<", i, tmp);*/
		TextDrawShowForPlayer(i, TetrisMusic);
		TextDrawShowForPlayer(i, TetrisInfo);
		TextDrawShowForPlayer(i, TetrisNextBrick);
		SelectTextDraw(i, 0x00FFFFFF);
		for(new t; t<sizeof(TetrisGame); t++) TextDrawShowForPlayer(i, TetrisGame[t]);
	}
	for(new y=1; y <= TotalBlocksY; y++)
	{
		for(new x=1; x <= TotalBlocksX; x++) TetrisBlocks[x*y][Group]=2;
	}
	TetrisGameTimer=SetTimer("Tetris", 300, true);
	printf("Tetris FS Initalized!");
	return 1;
}
public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(_:clickedid != INVALID_TEXT_DRAW)
	{
		if(_:clickedid == _:TetrisMusic)
		{
			if(GetPVarInt(playerid, "TetrisMusic") < 1)
			{
				PlayAudioStreamForPlayer(playerid, "http://ccmixter.org/content/George_Ellinas/George_Ellinas_-_Pulse_(George_Ellinas_remix).mp3");
				SetPVarInt(playerid, "TetrisMusic", 1);
				SelectTextDraw(playerid, 0xFF0000FF);
			}else{
				SelectTextDraw(playerid, 0x00FFFFFF);
				StopAudioStreamForPlayer(playerid);
				DeletePVar(playerid, "TetrisMusic");
			}
		}
	}
	//CancelSelectTextDraw(playerid);
	return 1;
}
public OnFilterScriptExit()
{
	for(new i; i<MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i)) continue;
		StopAudioStreamForPlayer(i);
		SetCameraBehindPlayer(i);
		CancelSelectTextDraw(i);
	}
	KillTimer(TetrisGameTimer);
	for(new t; t<sizeof(TetrisUI); t++)
	{
		TextDrawHideForAll(TetrisUI[t]);
		TextDrawDestroy(TetrisUI[t]);
	}
	for(new g; g<sizeof(TetrisGame); g++)
	{
		TextDrawHideForAll(TetrisGame[g]);
		TextDrawDestroy(TetrisGame[g]);
	}
	TextDrawHideForAll(TetrisNextBrick);
	TextDrawDestroy(TetrisNextBrick);
	TextDrawHideForAll(TetrisMusic);
	TextDrawHideForAll(TetrisInfo);
	TextDrawDestroy(TetrisMusic);
	TextDrawDestroy(TetrisInfo);
	return 1;
}
forward Tetris();
public Tetris()
{
	new GameFeild=0; // 0-2 = 3 Feilds
	new TetrisFeild[sizeof(TetrisGame)][128], x, y;

	// Upcoming block
	new TetrisNext[64];
	for(new n=1; n <= 4; n++)
	{
		switch(random(7)-1)
		{
		case 0: strcat(TetrisNext, "~y~#", sizeof(TetrisNext));// Alive Block
		case 1: strcat(TetrisNext, "~r~#", sizeof(TetrisNext));// Alive Block
		case 2: strcat(TetrisNext, "~g~#", sizeof(TetrisNext));// Alive Block
		case 3: strcat(TetrisNext, "~b~#", sizeof(TetrisNext));// Alive Block
		case 4: strcat(TetrisNext, "~p~#", sizeof(TetrisNext));// Alive Block
		case 5: strcat(TetrisNext, "~w~#", sizeof(TetrisNext));// Alive Block
		default: strcat(TetrisNext, "~l~#", sizeof(TetrisNext));// Dead Block
		}
	}
	strcat(TetrisNext, "~n~", sizeof(TetrisNext));
	for(new n=1; n <= 4; n++)
	{
		switch(random(7)-1)
		{
		case 0: strcat(TetrisNext, "~y~#", sizeof(TetrisNext));// Alive Block
		case 1: strcat(TetrisNext, "~r~#", sizeof(TetrisNext));// Alive Block
		case 2: strcat(TetrisNext, "~g~#", sizeof(TetrisNext));// Alive Block
		case 3: strcat(TetrisNext, "~b~#", sizeof(TetrisNext));// Alive Block
		case 4: strcat(TetrisNext, "~p~#", sizeof(TetrisNext));// Alive Block
		case 5: strcat(TetrisNext, "~w~#", sizeof(TetrisNext));// Alive Block
		default: strcat(TetrisNext, "~l~#", sizeof(TetrisNext));// Dead Block
		}
	}
	strcat(TetrisNext, "_", sizeof(TetrisNext));
	TextDrawSetString(TetrisNextBrick,TetrisNext);

	// Redraw game feild & update area content
	for(y=1; y <= TotalBlocksY; y++)
	{
		if(y == 4 || y == 7 || y == TotalBlocksY) GameFeild++; // Swap TextDraw Feild
		for(x=1; x <= TotalBlocksX; x++)
		{
			//if(TetrisBlocks[x*y][Skip]==true) continue;
			TetrisBlocks[x*y][Skip]=true;
			// COLOR SWAPPING
			TetrisBlocks[y*x][Color]=random(6); // Random Demo
			if(TetrisBlocks[y*x][Group] == -1)
			{
				strcat(TetrisFeild[GameFeild], "~l~#", 128);// Dead Block
			}else{
				TetrisBlocks[y*x][Group]=random(TotalBlocks); // Random Demo
				/* Here we need some sort of collision checking
		** If color of the block x*y is same color as nearby blocks
		** Then kill the corresponing blocks
		*/
				/*for(new zy=1; zy <= TotalBlocksY; zy++)
		{
				if(zy == y) continue;
				for(new zx=1; zx <= TotalBlocksX; zx++)
				{
						if(zx == x) continue;
						
						if(zx == x+1)
						{
								if(TetrisBlocks[y*x][Color] == TetrisBlocks[zy*zx][Color])
								{
										TetrisBlocks[y*x][Group] = -1;// Kill Block
		}
		}
		}
		}*/
				switch(TetrisBlocks[y*x][Color])
				{
				case 0: strcat(TetrisFeild[GameFeild], "~y~#", 128);// Alive Block
				case 1: strcat(TetrisFeild[GameFeild], "~r~#", 128);// Alive Block
				case 2: strcat(TetrisFeild[GameFeild], "~g~#", 128);// Alive Block
				case 3: strcat(TetrisFeild[GameFeild], "~b~#", 128);// Alive Block
				case 4: strcat(TetrisFeild[GameFeild], "~p~#", 128);// Alive Block
				case 5: strcat(TetrisFeild[GameFeild], "~w~#", 128);// Alive Block
				}
			}
		}
		switch(y)
		{
		case 1..2, 4..5, 7..8: strcat(TetrisFeild[GameFeild], "~n~", 128);
		}
	}
	for(y=1; y <= TotalBlocksY; y++)
	{
		for(x=1; x <= TotalBlocksX; x++) TetrisBlocks[x*y][Skip]=false;
	}
	for(new g; g<sizeof(TetrisGame); g++)
	{
		TextDrawSetString(TetrisGame[g], TetrisFeild[g]);
	}
	for(new t; t<sizeof(TetrisGame); t++)
	{
		for(new i; i<MAX_PLAYERS; i++)
		{
			if(IsPlayerConnected(i) && IsPlayerInRangeOfPoint(i, 150, 366.1998,2542.1997,16.7876))
			{
				SetPlayerTime(i, 4, 17);
				for(new u; u<sizeof(TetrisUI); u++) TextDrawShowForPlayer(i, TetrisUI[u]);
				SetPlayerCameraPos(i, TetrisCamera[0], TetrisCamera[1], TetrisCamera[2]);
				SetPlayerCameraLookAt(i, TetrisCamera[0]-2, TetrisCamera[1]-4, TetrisCamera[2]+17);
				TextDrawShowForPlayer(i, TetrisNextBrick);
				TextDrawShowForPlayer(i, TetrisGame[t]);
				TextDrawShowForPlayer(i, TetrisMusic);
				TextDrawShowForPlayer(i, TetrisInfo);
				SelectTextDraw(i, 0x00FFFFFF);
			}
		}
	}
}
public OnPlayerCommandText(playerid, cmdtext[])
{
	if(!strcmp(cmdtext, "/tdselect", true))
	{
		SelectTextDraw(playerid, 0x00FF00FF); // Highlight green when hovering over
		SendClientMessage(playerid, 0xFFFFFFFF, "SERVER: Please select a textdraw!");
		return 1;
	}
	if(!strcmp(cmdtext, "/cancelselect", true))
	{
		CancelSelectTextDraw(playerid);
		SendClientMessage(playerid, 0xFFFFFFFF, "SERVER: TextDraw selection disabled!");
		return 1;
	}
	return 0;
}