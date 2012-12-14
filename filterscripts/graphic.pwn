#include <a_samp>
#include <formatex>
#include <zcmd>
#include <streamer>
#include <colours>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16

#define MAX_GRAPHIC		(47)

new
	PlayerText:dm_GraMenu_Back,
	PlayerText:dm_GraMenu_Left,
	PlayerText:dm_GraMenu_Right,
	PlayerText:dm_GraMenu_LeftOpt,
	PlayerText:dm_GraMenu_MidOpt,
	PlayerText:dm_GraMenu_RightOpt,
	PlayerText:dm_GraMenu_Accept;


LoadTD(playerid)
{
	dm_GraMenu_Back					=CreatePlayerTextDraw(playerid, 150.000000, 324.000000, "_");
	PlayerTextDrawBackgroundColor	(playerid, dm_GraMenu_Back, 255);
	PlayerTextDrawFont				(playerid, dm_GraMenu_Back, 0);
	PlayerTextDrawLetterSize		(playerid, dm_GraMenu_Back, 0.000000, 10.200008);
	PlayerTextDrawColor				(playerid, dm_GraMenu_Back, 100);
	PlayerTextDrawSetOutline		(playerid, dm_GraMenu_Back, 0);
	PlayerTextDrawSetProportional	(playerid, dm_GraMenu_Back, 1);
	PlayerTextDrawSetShadow			(playerid, dm_GraMenu_Back, 1);
	PlayerTextDrawUseBox			(playerid, dm_GraMenu_Back, 1);
	PlayerTextDrawBoxColor			(playerid, dm_GraMenu_Back, 100);
	PlayerTextDrawTextSize			(playerid, dm_GraMenu_Back, 490.000000, 0.000000);

	dm_GraMenu_Left					=CreatePlayerTextDraw(playerid, 150.000000, 330.000000, "~<~");
	PlayerTextDrawBackgroundColor	(playerid, dm_GraMenu_Left, 255);
	PlayerTextDrawFont				(playerid, dm_GraMenu_Left, 0);
	PlayerTextDrawLetterSize		(playerid, dm_GraMenu_Left, 1.300000, 8.000000);
	PlayerTextDrawColor				(playerid, dm_GraMenu_Left, -1);
	PlayerTextDrawSetOutline		(playerid, dm_GraMenu_Left, 0);
	PlayerTextDrawSetProportional	(playerid, dm_GraMenu_Left, 1);
	PlayerTextDrawSetShadow			(playerid, dm_GraMenu_Left, 1);
	PlayerTextDrawSetSelectable		(playerid, dm_GraMenu_Left, true);

	dm_GraMenu_Right				=CreatePlayerTextDraw(playerid, 435.000000, 330.000000, "~>~");
	PlayerTextDrawBackgroundColor	(playerid, dm_GraMenu_Right, 255);
	PlayerTextDrawFont				(playerid, dm_GraMenu_Right, 0);
	PlayerTextDrawLetterSize		(playerid, dm_GraMenu_Right, 1.299999, 8.000000);
	PlayerTextDrawColor				(playerid, dm_GraMenu_Right, -16776961);
	PlayerTextDrawSetOutline		(playerid, dm_GraMenu_Right, 0);
	PlayerTextDrawSetProportional	(playerid, dm_GraMenu_Right, 1);
	PlayerTextDrawSetShadow			(playerid, dm_GraMenu_Right, 1);
	PlayerTextDrawSetSelectable		(playerid, dm_GraMenu_Right, true);

	dm_GraMenu_LeftOpt				=CreatePlayerTextDraw(playerid, 210.000000, 340.000000, "LD_TATT:8gun");
	PlayerTextDrawBackgroundColor	(playerid, dm_GraMenu_LeftOpt, 255);
	PlayerTextDrawFont				(playerid, dm_GraMenu_LeftOpt, 4);
	PlayerTextDrawLetterSize		(playerid, dm_GraMenu_LeftOpt, 0.000000, -3.000000);
	PlayerTextDrawColor				(playerid, dm_GraMenu_LeftOpt, -156);
	PlayerTextDrawSetOutline		(playerid, dm_GraMenu_LeftOpt, 0);
	PlayerTextDrawSetProportional	(playerid, dm_GraMenu_LeftOpt, 1);
	PlayerTextDrawSetShadow			(playerid, dm_GraMenu_LeftOpt, 1);
	PlayerTextDrawUseBox			(playerid, dm_GraMenu_LeftOpt, 1);
	PlayerTextDrawBoxColor			(playerid, dm_GraMenu_LeftOpt, 255);
	PlayerTextDrawTextSize			(playerid, dm_GraMenu_LeftOpt, 60.000000, 60.000000);

	dm_GraMenu_MidOpt				=CreatePlayerTextDraw(playerid, 280.000000, 330.000000, "LD_TATT:9gun");
	PlayerTextDrawBackgroundColor	(playerid, dm_GraMenu_MidOpt, 255);
	PlayerTextDrawFont				(playerid, dm_GraMenu_MidOpt, 4);
	PlayerTextDrawLetterSize		(playerid, dm_GraMenu_MidOpt, 0.000000, -3.000000);
	PlayerTextDrawColor				(playerid, dm_GraMenu_MidOpt, -1);
	PlayerTextDrawSetOutline		(playerid, dm_GraMenu_MidOpt, 0);
	PlayerTextDrawSetProportional	(playerid, dm_GraMenu_MidOpt, 1);
	PlayerTextDrawSetShadow			(playerid, dm_GraMenu_MidOpt, 1);
	PlayerTextDrawUseBox			(playerid, dm_GraMenu_MidOpt, 1);
	PlayerTextDrawBoxColor			(playerid, dm_GraMenu_MidOpt, 255);
	PlayerTextDrawTextSize			(playerid, dm_GraMenu_MidOpt, 80.000000, 80.000000);

	dm_GraMenu_RightOpt				=CreatePlayerTextDraw(playerid, 370.000000, 340.000000, "LD_TATT:7gun");
	PlayerTextDrawBackgroundColor	(playerid, dm_GraMenu_RightOpt, 255);
	PlayerTextDrawFont				(playerid, dm_GraMenu_RightOpt, 4);
	PlayerTextDrawLetterSize		(playerid, dm_GraMenu_RightOpt, 0.000000, -3.000000);
	PlayerTextDrawColor				(playerid, dm_GraMenu_RightOpt, -156);
	PlayerTextDrawSetOutline		(playerid, dm_GraMenu_RightOpt, 0);
	PlayerTextDrawSetProportional	(playerid, dm_GraMenu_RightOpt, 1);
	PlayerTextDrawSetShadow			(playerid, dm_GraMenu_RightOpt, 1);
	PlayerTextDrawUseBox			(playerid, dm_GraMenu_RightOpt, 1);
	PlayerTextDrawBoxColor			(playerid, dm_GraMenu_RightOpt, 255);
	PlayerTextDrawTextSize			(playerid, dm_GraMenu_RightOpt, 60.000000, 60.000000);

	dm_GraMenu_Accept				=CreatePlayerTextDraw(playerid, 320.000000, 304.000000, "Accept");
	PlayerTextDrawAlignment			(playerid, dm_GraMenu_Accept, 2);
	PlayerTextDrawBackgroundColor	(playerid, dm_GraMenu_Accept, 255);
	PlayerTextDrawFont				(playerid, dm_GraMenu_Accept, 1);
	PlayerTextDrawLetterSize		(playerid, dm_GraMenu_Accept, 0.400000, 1.600008);
	PlayerTextDrawColor				(playerid, dm_GraMenu_Accept, -1);
	PlayerTextDrawSetOutline		(playerid, dm_GraMenu_Accept, 0);
	PlayerTextDrawSetProportional	(playerid, dm_GraMenu_Accept, 1);
	PlayerTextDrawSetShadow			(playerid, dm_GraMenu_Accept, 1);
	PlayerTextDrawUseBox			(playerid, dm_GraMenu_Accept, 1);
	PlayerTextDrawBoxColor			(playerid, dm_GraMenu_Accept, 100);
	PlayerTextDrawTextSize			(playerid, dm_GraMenu_Accept, 10.000000, 84.000000);
	PlayerTextDrawSetSelectable		(playerid, dm_GraMenu_Accept, true);
}
UnloadTD(playerid)
{
	PlayerTextDrawHide(playerid, dm_GraMenu_Back);
	PlayerTextDrawHide(playerid, dm_GraMenu_Left);
	PlayerTextDrawHide(playerid, dm_GraMenu_Right);
	PlayerTextDrawHide(playerid, dm_GraMenu_LeftOpt);
	PlayerTextDrawHide(playerid, dm_GraMenu_MidOpt);
	PlayerTextDrawHide(playerid, dm_GraMenu_RightOpt);
	PlayerTextDrawHide(playerid, dm_GraMenu_Accept);

	PlayerTextDrawDestroy(playerid, dm_GraMenu_Back);
	PlayerTextDrawDestroy(playerid, dm_GraMenu_Left);
	PlayerTextDrawDestroy(playerid, dm_GraMenu_Right);
	PlayerTextDrawDestroy(playerid, dm_GraMenu_MidOpt);
	PlayerTextDrawDestroy(playerid, dm_GraMenu_LeftOpt);
	PlayerTextDrawDestroy(playerid, dm_GraMenu_RightOpt);
	PlayerTextDrawDestroy(playerid, dm_GraMenu_Accept);
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
};
new
    dm_GraMenuCurrent[MAX_PLAYERS];

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

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(playertextid == dm_GraMenu_Left)
	{
	    print("LEFT");
	    if(dm_GraMenuCurrent[playerid] > 0)
		{
			dm_GraMenuCurrent[playerid]--;
			dm_UpdateGraphicMenu(playerid);
		}
	}
	if(playertextid == dm_GraMenu_Right)
	{
	    print("RIGHT");
	    if(dm_GraMenuCurrent[playerid] < MAX_GRAPHIC-1)
		{
			dm_GraMenuCurrent[playerid]++;
			dm_UpdateGraphicMenu(playerid);
		}
	}
	if(playertextid == dm_GraMenu_Accept)
	{
	    print("ACCEPT");
	    dm_HideGraphicMenu(playerid);
	}
}

public OnPlayerRequestClass(playerid)
{
	SendClientMessage(playerid, -1, "REQUEST CLASS");
	SpawnPlayer(playerid);
}

CMD:gmenu(playerid, params[])
{
	LoadTD(playerid);
	return 1;
}
CMD:unload(playerid, params[])
{
	UnloadTD(playerid);
	return 1;
}
CMD:tatt(playerid, params[])
{
	dm_ShowGraphicMenu(playerid);
	return 1;
}
